/**
 * @copyright   Copyright (c) 2019 by General Electric Company. All Rights Reserved.
 *
 * @file        phaseCorrection.e
 *
 * @brief       Code to support 2D phase correction by correcting blip area for EPI
 *
 * @author      Lei Gao
 *
 * @since       MR28.0
 *
 */

/* do not edit anything above this line */

/*
 * Comments:
 *
 * 25 Dec 2019    Lei Gao
 * Initial Creation
 *
 */



@global phaseCorrectionGlobal
/*
 *@inline phaseCorrection.e phaseCorrectionGlobal 
 */

#include "phaseCorrection.h"
#define MAGNITUDE_WEIGHTING            0
#define PHASE_WEIGHTING                1
#define MAX_DUMMY_COUNT                1000
#define ENTRY_PRESCAN                  0
#define ENTRY_NON_INTEG_REF            1
#define ENTRY_INTEG_REF                2
#define ENTRY_SCAN                     3

@cv phaseCorrectionCV
/*
 *@inline phaseCorrection.e phaseCorrectionCV
 */
int    pc2dSupport                      = 0 with {0, 1, 0, VIS, "EPI 2D Phase Correction support, 0: not support, 1: support",};
int    pc2dFlag                         = 0 with {0, 1, 0, VIS, "flag for EPI 2D Phase Correction, 0: off, 1: on",};
int    pc2dDebugFlag                    = 0 with {0, 1, 0, VIS, "flag for EPI 2D Phase Correction debug, 0: off, 1: on",};
int    pc2dSliceQuant                   = 0;
int    pc2dRspUpdateDone                = 0;
int    weightingOption                  = 1 with {0, 1, 1, VIS, "Weighing algorithm, 0 magnitude weighted, 1 phase weighted" , };
float  referenceFOV                     = 2.0;
float  scaleAmp                         = 1.0;
int    phaseCorrectionDummyTime         = 4ms;
int    scanEntryType                    = 0;

@host phaseCorrectionCVInit
/* 
 * @inline phaseCorrection.e phaseCorrectionCVInit
 * Determine if EPI 2D PC feature is supported
 * Currently it is supported in 1.5T & head & opdiffuse & oblique
 * Multiband and rtb0 is out of scope
 * Determine weight option by anatomy
 */

if((cffield == B0_15000) || ((is3TSystemType()) && (isRioSystem() || is750System())))
{
    pc2dSupport = PSD_ON;
}
else
{
    pc2dSupport = PSD_OFF;
}

if((PSD_ON == pc2dSupport) && (isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_HEAD)) && (PSD_ON == exist(opdiffuse)) && (exist(opplane) == PSD_OBL) && (PSD_OFF == mux_flag) && (PSD_OFF == rtb0_flag))

{
    pc2dFlag = PSD_ON;
}
else
{
    pc2dFlag = PSD_OFF;
}
if(PSD_ON == pc2dFlag)
{
    if(isCategoryMatchForAnatomy(opanatomy, ATTRIBUTE_CATEGORY_HEAD))
    {
        weightingOption = MAGNITUDE_WEIGHTING;
    }
    else
    {
        weightingOption = PHASE_WEIGHTING;
    }
}

@host phaseCorrectionCVEval
/* 
 * @inline phaseCorrection.e phaseCorrectionCVEval
 * Activate 2D reference scan;
 * Calculate blip area ratio between 2D reference and scan
 */
if(PSD_ON == pc2dFlag)
{
    pipc2d_reference_scan = 1;                  /* Control 2D PC reference scan ON/OFF */
    referenceFOV = 2*(1/asset_factor)*opnshots; /* 2D reference scan FOV factor compared with scan FOV */
    scaleAmp = -1*asset_factor/opnshots;
}
else
{
    pipc2d_reference_scan = 0;                  /* Control 2D PC reference scan ON/OFF */
}

if(PSD_ON == mux_flag)
{
    pc2dSliceQuant = mux_slquant;
}
else
{
    pc2dSliceQuant = opslquant;
}
@host phaseCorrectionCVCheck
/* 
 * CV Check for EPI 2D PC feature
 * Check Multiband compatiblity with EPI 2D PC feature
 */

if(mux_flag && pc2dFlag)
{
    epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "EPI 2D Phase Correction", STRING_ARG, "Multiband" );
    return FAILURE;
}

if(rtb0_flag && pc2dFlag)
{
    epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "EPI 2D Phase Correction", STRING_ARG, "RTB0" );
    return FAILURE;
}

@host phaseCorrectionUpdaterhpcctrl
/* 
 * @inline phaseCorrection.e phaseCorrectionUpdaterhpcctrl
 * Update rhpcctrl to RECON
 * RECON will enable 2D Phase Correction pipeline, and choose weight option and parameters according to rhpcctrl
 */
if(PSD_ON == pc2dFlag)
{
    rhpcctrl |= RHPCCTRL_2DPC;
    switch(weightingOption)
    {
        case MAGNITUDE_WEIGHTING:
            rhpcctrl &= ~RHPCCTRL_2DPC_PHASE_WEIGHT;
            rhpc2d_phase_noise_threshold = 0.0;
            rhpc2d_magnitude_threshold = 0.0;
            break;
        case PHASE_WEIGHTING:
            rhpcctrl |= RHPCCTRL_2DPC_PHASE_WEIGHT;
            rhpc2d_phase_noise_threshold = 0.8;
            rhpc2d_magnitude_threshold = 0.05;
            break;
        default:
            rhpcctrl |= RHPCCTRL_2DPC_PHASE_WEIGHT;
            rhpc2d_phase_noise_threshold = 0.8;
            rhpc2d_magnitude_threshold = 0.05;
            break;
    }
}
else
{
    rhpcctrl &= ~RHPCCTRL_2DPC;
    rhpcctrl &= ~RHPCCTRL_2DPC_PHASE_WEIGHT;
}

@pg phaseCorrectionPGDummy
/*
 * @inline phaseCorrection.e phaseCorrectionPGDummy
 * set phaseCorrectionDummyTime
 */
if (PSD_ON == pc2dFlag)
{
    SEQLENGTH(phaseCorrectionDummy, phaseCorrectionDummyTime, phaseCorrectionDummy); /*dummy time */
}

@rsp phaseCorrectionDummyCoreEpi2
/*
 * @inline phaseCorrection.e phaseCorrectionDummyCoreEpi2
 * play 2D PC dummy pulse sequence
 */
void playPhaseCorrectionDummySeq()
{
    if(PSD_ON == pc2dFlag)
    {
        int dummyCount = 0;
        int pc2dRspSliceUpdateDone = 0;
        settriggerarray((SHORT)1, rsptrigger_temp); /* set trigger to TRIG_INTERN for dummy seq*/
        boffset(off_phaseCorrectionDummy);

        while(0 == pc2dRspUpdateDone && dummyCount <= MAX_DUMMY_COUNT)
        {
            startseq((SHORT)0, (SHORT)MAY_PAUSE);
            dummyCount++;
            pc2dRspSliceUpdateDone = 0;
            for(int i=0;i<pc2dSliceQuant;i++)
            {
                pc2dRspSliceUpdateDone += pc2dBlipCorrectionFactorUpdate[i];
            }

            if(pc2dRspSliceUpdateDone == pc2dSliceQuant)
            {
                pc2dRspUpdateDone = SUCCESS;
            }
            else
            {
                pc2dRspUpdateDone = FAILURE;
            }
        }
        if(PSD_ON == pc2dDebugFlag)
        {
            printf("EPI 2D Phase Correction RSPUPDATE status: %d dummy count: %d\n", pc2dRspUpdateDone, dummyCount);
            for(int ii = 0; ii < pc2dSliceQuant; ii++)
            {
                printf("pc2dBlipCorrectionFactor[%d] = %f\n", ii, pc2dBlipCorrectionFactor[ii]);
            }
       }
    }
}

@rsp PhaseCorrectionPGDeclaration
/*
 * @inline phaseCorrection.e PhaseCorrectionPGDeclaration
 * Decalre 2D PC variable
 */
int     *pc2dBlipCorrectionFactorUpdate;    /* EPI 2D Phase Correction RSP Update form RECON   */
float   *pc2dBlipCorrectionFactor;          /* EPI 2D Phase Correction Blip Correction Factor  */


@pg PhaseCorrectionPGInit
/*
 * @inline phaseCorrection.e PhaseCorrectionPGInit
 * Initialize 2D Phase Correction RSP variable 
 */
STATUS PhaseCorrectionPGInit()
{
    pc2dBlipCorrectionFactor = (float *)AllocNode(pc2dSliceQuant*sizeof(float));
    pc2dBlipCorrectionFactorUpdate = (int *)AllocNode(pc2dSliceQuant*sizeof(int));
    for (int i=0; i<pc2dSliceQuant; i++)
    {
        pc2dBlipCorrectionFactor[i] = 0.0;
        pc2dBlipCorrectionFactorUpdate[i] = 0;
    }

    return SUCCESS;

}

@rsp phaseCorrectionLoop

/*************************** SCANLOOP for phase correction *******************************/

#ifdef __STDC__ 
STATUS phaseCorrectionLoop(void)
#else /* !__STDC__ */
    STATUS phaseCorrectionLoop() 
#endif /* __STDC__ */

{
    printdbg("Greetings from phaseCorrectionLoop", debugstate);

    if(cs_sat == PSD_ON)
        cstun = 1;

    SpSat_Saton(0);

    if(cs_sat > 0)
        setiamp(ia_rfcssat, &rfcssat, 0);

    setiamp(ia_rf1, &rf1, 0);   /* Reset amplitudes */
    if (oppseq == PSD_SE)
    {
        if (PSD_OFF == dualspinecho_flag)
        {
            setiamp(ia_rf2, &rf2, 0);
        }
        else
        {
            setiamp(ia_rf2, &rf2right, 0);
            setiamp(ia_rf2, &rf2left, 0);
        }
    }

    strcpy(psdexitarg.text_arg, "scan");

    setperiod(scan_deadtime, &seqcore, 0);

    inversRspRot(inversRR, rsprot_unscaled[0]);

    diff_pass_counter = 0;
    diff_pass_counter_save = 0;

    /* BJM: passreps control diffusion gradients */
    for (pass_rep = 0; pass_rep < rspprp; pass_rep++) 
    {
        rsppepolar = pepolar;
        invertGy1 = 1;

        if ((opdiffuse == 1 && incr == 1) || (tensor_flag == PSD_ON)) 
        {
            diffstep(pass_rep);
        }

        diff_pass_counter_save = diff_pass_counter;

        for (pass = rspacqb; pass < rspacq; pass++) 
        {

 
            pass_index = pass + pass_rep*rspacq;

            /* MRIge57446: acquire baselines for the 1st rep of first pass */
            if (pass_index < rspacq)
            {   
                if (baseline > 0)
                {
                    if (baseline > 1)
                        setperiod(bl_acq_tr1, &seqblineacq, 0);
                    else
                        setperiod(bl_acq_tr2, &seqblineacq, 0);
                    blineacq();
                }
            }

            boffset(off_seqcore);

            setperiod(scan_deadtime, &seqcore, 0);

            /* initialize wait time and pass packet for disdacqs, etc. */
            setwamp(SSPDS, &pass_pulse, 0);
            setwamp( SSPD, &pass_pulse, 2);
            setwamp(SSPDS, &pass_pulse, 4);

            for(int i=0; i<num_passdelay; i++)
                setperiod(1, &ssp_pass_delay, i);

            /* int pause = MAY_PAUSE; */
            printdbg("Null ssp pass packet", debugstate);
            diff_pass_counter = diff_pass_counter_save;

            core(); /* acquire the data */
            settriggerarray((SHORT)1, rsptrigger_temp);

            /* Return to standard trigger array and core offset */
            settriggerarray((SHORT)(opslquant*opphases), rsptrigger);
            
            /* If this isn't the last pass and we are, doing relaxers  */
            if((SatRelaxers)&&( (pass!=(rspacq-1)) && (pass_rep!=(rspprp-1)) ) )
                SpSatPlayRelaxers();
            
        }
    }

    printdbg("Normal End of phaseCorrectionLoop", debugstate);
    return SUCCESS;
}

