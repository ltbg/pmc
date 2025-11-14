/*@Start***********************************************************/
/* GEMSBG C source File
 * Copyright (C) 2010 The General Electric Company
 * 
 * File Name:  RTB0.e
 * Developer:  J Xie
 */

/*@Synopsis
 *
 * RTB0.e contains the EPIC code necessary for RTP real-time B0 central
 * frequency monitoring and correction.
 */

/* **************************************************************************
 * Internal
 * Release Date         Person SPR#           Comments
   PX26.1  28-Apr-2017  YUK    HCSDM00456890  Added Linear fit residual as Confidence metric
                                              Added cf_smooth_with_keep_edge filter to improve DWIBS station connectivity
                                              Enable RTB0 even if SPSP=Off as long as opirprep=On
   MR27.0  21-Aug-2017  ZT     HCSDM00467723  Enable RTB0 for K15 and SV System

   MR27.0  10-Jul-2017  WHB    HCSDM00455295  Promote code for feature PRICE which remove R2 function, oversample and downsample data. Data type
                                              is changed to float from int.

**********************************************************************/

@cv RTB0cv
/*MF B0 correction: add mode for integrated b0 corr into ref scan*/
int rtb0_flag = 0 with {0,1,0,VIS,"flag to turn on/off B0drift monitoring",};
int rtb0_enable = 0 with {0,1,0,VIS,"RTB0 enabling status: 0=not enabled, 1=enabled",};
int rtb0_support = 0 with {0,1,0,VIS,"RTB0 correction support flag: 0=not support, 1=support",};
int rtb0_first_skip = 20 with {0,50,20,INVIS,"number of points skipped in the begining",};
int rtb0_last_skip = 20 with {0,50,20,INVIS,"number of points skipped in the end",};
int rtb0_movAvg = 5 with {1,30,5,INVIS,"number of points used for moving average",};
int rtb0_min_points = 10 with {5,,10,INVIS,"min number of points used for RTP processing",};
int rtb0DebugFlag = PSD_OFF;
int rtb0SaveRaw = PSD_OFF;
int rtb0_phase_method = 1 with {0,1,1,VIS,"RTB0 phase estimation: 0=Ahn, 1=LSQ",};
int rtb0_coil_combine = 1 with {0,2,0,VIS,"RTB0 coil combine: 0=Peak channel only, 1=phase estimate first, 2=coil combine first",};
int rtb0_timing_flag = PSD_OFF with {0,1,0,VIS,"1 = round-trip timing measurements, 0= disable timing measurements",};

/*PG timing related*/
int rtb0dummy_time = 1200ms;
int rtb0fittingwaittime = 1000ms;
int rtb0resultwaittime = 1ms;
int rtb0fittingwaittimeLoop = 1; /*number of fitting time to play*/
int rtb0dummyseq = 1 with {0,1,0,VIS, "Play dummy seq prior to RTP init()"};

/*RTB0 compensation & debug flags*/
int rtb0_comp_flag = 0 with {0,1,0,VIS, "Flag to realtime b0 drift compensation",};
int rtb0_acq_delay = 0 with {0,,2ms,VIS, "Delay time of realtime b0 drift acquisition",};
int rtb0_minintervalb4acq = 0;
int rtb0_r1_delta = 2 with {0,13,2,VIS, "R1 reduced for rtb0 acquisition",};
int pw_dynr1=4;
int rtb0_filter_cf_flag = 1 with {0,1,1,VIS, "Flag to filter center frequency along slice",};
int rtb0_recvphase_comp_flag = 0 with {0,1,0,VIS, "Flag to slice receive phase compensation",};
int rtb0_comp_debug_flag = 0 with {-1, 1, 0, VIS, "dtb0 phase compensation debug flag",};
float rtb0_cfoffset_debug = 0.0;
int rtb0_slice_shift = 0 with {,,0,VIS, "Slice offset for RTB0 peak channel selection (0=use 1st slice)"};/*???*/

/*RTB0 weighted fit related*/
int cf_interpolation = 4 with {0,4,4,VIS, "Center frequency Interpolation method: 0=median, 1=linear fit, 2=quadratic fit, 3=3rd order fit, 4=smooth with keep edge"};
float rtb0_max_range = 300.0 with {-1000.0,1000.0,300.0,VIS, "Maximum +/- range of RTB0 CF offset correction [Hz]"};
int rtb0_rejectnoise = 1 with {0,2,0,VIS, "RTB0 method to reject noisy data (0=OFF, 1=setMagToZero, 2=setCFToMaxRange)"};
int rtb0_smooth_kernel_size = 9 with {0,DATA_ACQ_MAX,5,VIS, "Smoothing kernel size for CF smoothing (use odd integer)"};
int rtb0_smooth_cf_flag = 0 with {0,1,0,VIS, "Flag to smooth center frequency along slice",};
int rtb0_median_kernel_size = 3 with {0,13,3,VIS, "Median kernel size for CF median filtering (use odd integer)"};
int rtb0_min_kernel_keep_edge = 1 with {1,5,1,VIS, "Minimum kernel size for CF smooth with keep edge filtering (use odd integer)"};
float rtb0_max_kernel_percent = 50.0 with {0.0,100.0,50.0,VIS, "Percent of slice coverage to use as Maximum kernel size for CF smooth with keep edge filtering"};
int rtb0_max_kernel_keep_edge = 1 with {0,99,1,VIS, "Maximum kernel size for CF smooth with keep edge filtering (use odd integer)"};
int rtb0_confidence_method = 1 with {0,2,1,VIS, "Thresholding method for RTB0 slice interpolation: 0=do not threshold, 1=linear fit residual, 2=stddev across channels"};
float rtb0_cfstddev_threshold    = 100.0 with {0.0,300.0,100.0,VIS, "Cutoff threshold for CF Stddev across channels to identify slices with high confidence [Hz]"};
float rtb0_cfresidual_threshold  = 100.0 with {0.0,300.0,100.0,VIS, "Cutoff threshold for CF Linear fit residual to identify slices with high confidence [Hz]"};
float rtb0_confidence_thresh_val = 100.0 with {0.0,300.0,100.0,VIS, "Cutoff threshold as determined by rtb0_confidence_method used to identify slices with high confidence [Hz]"};
int rtb0_gzrf0_off = 1 with {0,1,1,VIS, "Whether to turn off Gz for IR pulse if it is in rtb0 loop"};
int rtb0_spsp_flag = 0 with {0,1,0,VIS, "WBI mode for broadband SPSP. Enable this will turn d_cf from 50Hz to 0 for SPSP2 pulses."};
int rtb0_dda = 0 with {0, , 0, INVIS, "number of disdaqs in RTB0 loop", ""};
int rtb0_debug = 0 with {0,1,0,VIS, "Debug Flag for RTB0: print CF to file & print status in AGP window"};

/*RTB0 from epi.e*/
int rtb0_midsliceindex = -1 with {-1,,-1, VIS, "Index of middle slice (-1: all slices)",};
float rtb0_outlier_threshold = 10.0 with {0.0,,10.0,VIS, "CF offset outlier threshold in one TR (Hz)",};
float rtb0_outlier_duration = 30.0 with {0.0,,30.0,VIS, "CF offste outlier duration (s)",};
int rtb0_outlier_nTRs;

@host RTB0init
STATUS rtb0Init() 
{
    rtb0_movAvg = 5;

    /* For small number of sample points, reduce the num of skipped points */
    if ( (int) ((rhfrsize - rtb0_min_points)/2) < 20 )
    {
        rtb0_first_skip = (int) ((rhfrsize-rtb0_min_points)/2);
        rtb0_last_skip = rtb0_first_skip;
    } else {
        rtb0_first_skip = 20;
        rtb0_last_skip = 20;
    }
    return SUCCESS;
}

/* Determine if RTB0 is supported or not */
@host RTB0SupportMode
{ /* Start of code inlined from RTB0.e RTB0SupportMode */

    /* Open RTB0 feature for all systems */
    rtb0_support = PSD_ON;

} /* End of code inlined from RTB0.e RTB0SupportMode */

@host RTB0Filter
    /*MF B0 correction*/
    if(rtb0_flag)
    {
        filter_rtb0echo = scanslot;
    }

@host RTB0Cveval

    {
        INT numcoils = getRxNumChannels();
        char attribute_codeMeaning[ATTRIBUTE_RESULT_SIZE] = "";
        getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CODE_MEANING, attribute_codeMeaning);

        if ( (rtb0_support == PSD_ON) && (exist(opdiffuse) == PSD_ON) && exist(opirmode) == 0 && epi_flair == PSD_OFF 
            && (((ss_rf1 > 0) || (exist(opirprep) == PSD_ON)) || (cffield == B0_15000))
            && rfov_flag == PSD_OFF && exist(opnav) == PSD_OFF && mux_flag == PSD_OFF 
            && (opnumgroups <= 1) && numcoils > 1
            && !(strstr(attribute_codeMeaning, "Breast")) ) /*HCSDM00405553 lock out breast in clinical mode*/
        {
            rtb0_enable = PSD_ON;
        }
        else
        {
            rtb0_enable = PSD_OFF;
        }	

        /* Show/hide RTB0 checkbox according to rtb0_enable value */
        if (rtb0_enable)
        {
            pirtb0vis = 1;
            pirtb0nub = 1;
            rtb0_flag = oprtb0; /* rtb0_flag determines RTB0 is on or off; oprtb0 is input from UI */
        }
        else
        {
            pirtb0vis = 1;
            pirtb0nub = 0;
            rtb0_flag = 0;
        }

    }
	
@host RTB0Cveval1

    if (rtb0_flag == PSD_ON)
    {
        int tmp_kernel = 1;

        rtb0_dda = 1;

        /*B0 correction: turn on smoothing if polynomial filter is not used*/
        if ((cf_interpolation == 0) || (cf_interpolation == 4))
            rtb0_smooth_cf_flag=PSD_ON;
        else
            rtb0_smooth_cf_flag=PSD_OFF;

        if (rtb0_smooth_cf_flag==PSD_ON)
        {
            /* Choose kernel size based on acqs (distance between data pts depends on acqs).
             * Also, make sure kernel size is odd. */
            tmp_kernel = (acqs%2 ==0)?(acqs*3-1):(acqs*3);
            if (tmp_kernel< _rtb0_smooth_kernel_size.maxval)
                rtb0_smooth_kernel_size = tmp_kernel;
            else
                rtb0_smooth_kernel_size = _rtb0_smooth_kernel_size.maxval;
        }

        if (rtb0_debug)
        {
            rtb0DebugFlag = PSD_ON; /*turn on kspace saving also*/
        }

        /*For breast/prone, use standard spsp setting (ie d_cf = 50Hz), otherwise, use d_cf = 0Hz to reduce upper t-spine signal loss at the shoulder level*/
        if (existcv(oppos) && (exist(oppos) == 2))
        {
            rtb0_spsp_flag = 0;
        }
        else
        {
            rtb0_spsp_flag = 1;
        }

    	/*MF*/
    	if ((rtb0_coil_combine == 1) && (rtb0_phase_method == 1))
        {
            rtb0resultwaittime = 1500;
        } 
        else 
        {
            rtb0resultwaittime = 1000;
        }

        if (opdiffuse == PSD_ON)
            rtb0_acq_delay = 2000; /*2ms*/
        else
            rtb0_acq_delay = 0;
    }
    else
    {
        rtb0_dda = 0;
        rtb0_spsp_flag = 0;
        rtb0_acq_delay = 0;
        rtb0DebugFlag = PSD_OFF;
    }

@host RTB0Cvcheck_epi
    /* RTB0 flag in RTB0.e (rtb0_flag) should never be different from equivalent flag in <psd>.e (rtb0_comp_flag) */
    if (rtb0_flag != rtb0_comp_flag)
    {
        if (rtb0_flag == PSD_ON)
        {
            epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                       STRING_ARG, "rtb0_flag=On", 
                       STRING_ARG, "rtb0_comp_flag=Off");
        }
        else
        {
            epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                       STRING_ARG, "rtb0_flag=Off", 
                       STRING_ARG, "rtb0_comp_flag=On");
        }
        return FAILURE;
    }

    /* RTB0 requires Internal reference scan(s) */
    if ((iref_etl == 0) && (rtb0_flag == PSD_ON))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "Real Time Center Frequency", 
                   STRING_ARG, "No ETLs for dynamic PC (iref_etl=0)");
        return FAILURE;
    }

    /* Confidence thresholding cannot be used for polynomial fits */
    if (((cf_interpolation > 0) && (cf_interpolation < 4)) && (rtb0_confidence_method > 0))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "rtb0_confidence_method>0", 
                   STRING_ARG, "cf_interpolation=1,2,3");
        return FAILURE; 
    }

    /* Confidence thresholding using Linear fit residual incompatible with Ahn Cho fits */ 
    if ((rtb0_confidence_method == 1) && (rtb0_phase_method == 0))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "rtb0_confidence_method=1", 
                   STRING_ARG, "rtb0_phase_method=0");
        return FAILURE; 
    }

@host RTB0Cvcheck_epi2
    /* RTB0 flag in RTB0.e (rtb0_flag) should never be different from equivalent flag in <psd>.e (rtb0_comp_flag) */
    if (rtb0_flag != rtb0_comp_flag)
    {
        if (rtb0_flag == PSD_ON)
        {
            epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                       STRING_ARG, "rtb0_flag=On", 
                       STRING_ARG, "rtb0_comp_flag=Off");
        }
        else
        {
            epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                       STRING_ARG, "rtb0_flag=Off", 
                       STRING_ARG, "rtb0_comp_flag=On");
        }
        return FAILURE;
    }

    /* Support only Axial and Obl-Axial */
    if ( ! ((exist(opplane) == PSD_AXIAL) || ((exist(opplane) == PSD_OBL) && (exist(opobplane) == PSD_AXIAL))) /* NOT (Axial or Obl-Axial) */ 
         && (rtb0_flag == PSD_ON) )                                                                            /*       and RTB0=ON        */
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "Real Time Center Frequency", 
                   STRING_ARG, "Non-Axial acquisitions");
        return FAILURE;
    }

    /* In general, dda should not be <= 0 for DW-EPI. If it is, show RTB0 incompatibility error. */
    if ((dda <= 0) && (rtb0_flag == PSD_ON)) 
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "Real Time Center Frequency", 
                   STRING_ARG, "No Disdaqs");
        return FAILURE;
    }

    /* Real Time Center Frequency is incompatible with FLAIR */
    if ((epi_flair == PSD_ON) && (rtb0_flag == PSD_ON)) 
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "Real Time Center Frequency",
                   STRING_ARG, "FLAIR");
        return FAILURE;
    }

    /* Real Time Center Frequency is incompatible with FOCUS */
    if ((rfov_flag == PSD_ON) && (rtb0_flag == PSD_ON)) 
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "Real Time Center Frequency",
                   STRING_ARG, "FOCUS");
        return FAILURE;
    }

    /* Confidence thresholding cannot be used for polynomial fits */
    if (((cf_interpolation > 0) && (cf_interpolation < 4)) && (rtb0_confidence_method > 0))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "rtb0_confidence_method>0", 
                   STRING_ARG, "cf_interpolation=1,2,3");
        return FAILURE; 
    }

    /* Confidence thresholding using Linear fit residual incompatible with Ahn Cho fits */ 
    if ((rtb0_confidence_method == 1) && (rtb0_phase_method == 0))
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "rtb0_confidence_method=1", 
                   STRING_ARG, "rtb0_phase_method=0");
        return FAILURE; 
    }

@pg RTB0pg
    /*MF B0 correction*/
    if ( rtb0_flag == PSD_ON )
    {
        SEQLENGTH(seqrtb0dummy, rtb0dummy_time, seqrtb0dummy); /*dummy time for rtpinit()*/
        SEQLENGTH(seqrtb0fitwait, rtb0fittingwaittime, seqrtb0fitwait); /*dummy time for polynomial slice-by-slice CF fitting*/
        SEQLENGTH(seqrtprtb0, rtb0resultwaittime, seqrtprtb0); /*1ms wait time cycle for rtp result return*/
    }

@rspvar RTB0rspvar
int isrtplaunched = 0;

@rspvar RTB0rspvar_epi2
float slice_cfoffset[DATA_ACQ_MAX];
float slice_cfoffset_filtered[DATA_ACQ_MAX];
float slice_cfoffset_bySlice[DATA_ACQ_MAX];
int slice_cfoffset_TARDIS[DATA_ACQ_MAX];
float slice_fidmean[DATA_ACQ_MAX]; /*MF B0 correction*/
float slice_cfresidual[DATA_ACQ_MAX];   /* Confidence metric when rtb0_confidence_method = 1 */
float slice_cfstddev[DATA_ACQ_MAX];     /* Confidence metric when rtb0_confidence_method = 2 */
float slice_cfconfidence[DATA_ACQ_MAX]; /* Confidence metric actually passed into appropriate weighted fit function
                                         * as determined by rtb0_confidence_method switch */
float cf_coeff[4]; /*polyfit coefficient MAX is 3rd order, so 4 coefficient*/

@rsp RTB0Core 
#include "RtpPsd.h"
#include "RTB0.h"
#include "rtB0RTP.h"
#include "rtp_feedback_task.h"

#ifdef PSD_HW
#include "clockApi.h"
#endif

/*for epi2.e*/
int rtb0_processed_index = 0;
float rtb0_cfoffset = 0;
float rtb0_fidmean = 0; /*MF weighted fit*/
float rtb0_cfresidual = 0; /* Confidence metric when rtb0_confidence_method = 1 */
float rtb0_cfstddev = 0;   /* Confidence metric when rtb0_confidence_method = 2 */
int rtb0_initialized = 0;
int in_rtb0_loop = 0; /*indicate whether to play rtb0 related code*/
int rtb0_CFupdated = 0; /*indicate whether new CF is updated in L_SCAN (only used when ref_in_scan_flag is ON)*/

/*for epi.e*/
float rtb0_base_cfoffset = 0.0; /* center frequency offste at the first time point */
float rtb0_comp_cfoffset = 0.0; /* center frequency offset for compensation */
int rtb0_comp_cfoffset_TARDIS = 0;
int rtb0_rtp_1streturn = PSD_OFF;
int rtb0_outlier_count = 0;

/* DVMR: Variables to measure VRF and Ethernet feedback pathway times */
#if defined(MGD_TGT) && defined(PSD_HW)
long rtb0_feedback_time = 0;
long max_rtb0_feedback_time = 0;
long min_rtb0_feedback_time = 9999;
long sum_rtb0_feedback_times = 0;
double rtb0_fitting_time = 0.0;
long rtb0_num_frames_processed = 0;
#define RTB0_NUM_TIMING_POINTS 200
long rtb0_roundtrip_timing_array[RTB0_NUM_TIMING_POINTS];
long rtb0_roundtrip_index = 0;
# endif

STATUS rtB0ComRspInit( void )
{

#ifdef PSD_HW
    int status;
#endif
    RtpDataValuesPkt rtB0RtpPkt;

#if defined(MGD_TGT) && defined(PSD_HW)
    status = rtp_register_opcode(RTP_RESULT_RTB0, sizeof(rtB0Result), NULL);
    if (0 != status)
    {
        psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "rtp_register_opcode failed",
            PSD_ARG_STRING, "rtp_register_opcode:RTB0", 0);
    }
#endif


    /* Fill RtpDataTransportPkt values */
    strncpy(rtB0RtpPkt.rtpDataVal.path, "/usr/g/bin", sizeof(rtB0RtpPkt.rtpDataVal.path));
    strncpy(rtB0RtpPkt.rtpDataVal.func, "rtB0RTP", sizeof(rtB0RtpPkt.rtpDataVal.func));

    /* BAM Allocations */
    rtB0RtpPkt.rtpDataVal.frameSize = rhfrsize; /* xres */
    rtB0RtpPkt.rtpDataVal.dacqType = dacq_data_type;
    rtB0RtpPkt.rtpDataVal.hubIndex = coilInfo_tgt[0].hubIndex;
    rtB0RtpPkt.rtpDataVal.numRtpReceivers = 0;
    rtB0RtpPkt.rtpDataVal.bodyCoilCombine = rtp_bodyCoilCombine;
    rtB0RtpPkt.rtpDataVal.acquiredIndex = 0;
    rtB0RtpPkt.rtpDataVal.processedIndex = 0;

    rtb0_processed_index = 0; /*MF B0 correction, initialize it*/

    rtB0RtpPkt.rtpDataVal.floatVar_1 = oprbw; /* send BW to RTP for freq calculation */

    rtB0RtpPkt.rtpDataVal.intVar_1 = rtb0_first_skip; /* num of points skipped in the beginning */
    rtB0RtpPkt.rtpDataVal.intVar_2 = rtb0_last_skip; /* num of points skipped in the end */
    rtB0RtpPkt.rtpDataVal.intVar_3 = rtb0_movAvg;  /* num of points for moving average */
    rtB0RtpPkt.rtpDataVal.intVar_4 = rtb0_coil_combine;  /* MF B0 correction: coil combine method */
    rtB0RtpPkt.rtpDataVal.intVar_5 = rtb0_phase_method;  /* MF B0 correction: phase estimation method*/
    
    rtB0RtpPkt.rtpDataVal.vreDebug = rtb0DebugFlag;
    rtB0RtpPkt.rtpDataVal.writeRawData = rtb0SaveRaw;  /* flag to save nav data */

#ifdef PSD_HW

    status = RtpInit(&rtB0RtpPkt);
    if(status!=SUCCESS) {
        RtpEnd();  /* do this to be safe? */
        psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "RtpInit failed", PSD_ARG_STRING, "RtpInit:rtB0", 0);
    }

    rtb0_roundtrip_index = 0; /* Initialize index for Roundtrip time computation */

    isrtplaunched = 1;

#endif

    return SUCCESS;
}


/*
 * gets rtB0 processedIndex and cfoffset from RTP App.  ProcessedIndex and cfoffset are 
 * unchanged if there is no new data available.
 *
 * @param[out] *processedIndex - Pointer to the processedIndex
 * @param[out] *phase - pointer to the cfoffset 
 * @return 1 if new data available.  0 otherwise
 *
 */

int getRTB0Feedback(int * processedIndex, float * cfoffset, float * fidmean, float * cfstddev, float * cfresidual)
{
    n32 packed = 1;
    rtB0Result rtpResult;
    int nBytes = 0;

    rtpResult.processedIndex = 0; 
    rtpResult.cfoffset = 0.0; 
    rtpResult.fidmean = 0.0; 
    rtpResult.cfstddev = 0.0; 
    rtpResult.cfresidual = 0.0; 
#if defined(MGD_TGT) && defined(PSD_HW)
    nBytes = rtp_get_feedback_data(&rtpResult, sizeof(rtpResult), &packed, RTP_RESULT_RTB0, RTP_QUEUE_OLDEST);
#endif    

    if( nBytes > 0 )
    {
        if (0 == packed)
        {
            /* Results are a rtB0Result structure */
            if( nBytes != sizeof(rtpResult) )
            {
                RtpEnd();
                psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "Failure in reading results", 
                        PSD_ARG_STRING, "rtB0:getRTBOFeedback", 0);
            }

            *processedIndex = rtpResult.processedIndex;
            *cfoffset = rtpResult.cfoffset;
            *fidmean = rtpResult.fidmean;
            *cfstddev = rtpResult.cfstddev;
            *cfresidual = rtpResult.cfresidual;
        }
        else
        {
            RtpEnd(); 
            psdexit(EM_PSD_ROUTINE_FAILURE,0,"","Received packed result",PSD_ARG_STRING,"getRTB0Feedback:RTB0",0);  
        }    
        return 1;
    }
    else
    {
        /* No new feedback data */
        return 0;
    }
}

@rsp RTB0Core_epi /*MF include only in epi. Don't include in epi2 because it's already defined by Monitor.e*/
/* called by MCT task once the scan stops due to abort, crash, etc */
n32 psdcleanup(n32 abort)
{
    n32 rv = EM_PSD_NO_ERROR;
    int rtpendstatus = 0;
    abort = 1; /* Dummy to avoid compilation failure for unused variables - Used in Monitor.e */

    if( ((rtb0_flag == PSD_ON) && (isrtplaunched == PSD_ON))
        || ((track_flag == PSD_ON) && (isrtplaunched == PSD_ON)) )
    {
       printdbg("\nRtpEnd in RTB0", debugstate);
       rtpendstatus = RtpEnd();
       if(rtpendstatus == SUCCESS)
       {
           isrtplaunched = 0;
           rv = EM_PSD_NO_ERROR;
           printdbg(" : OK. \n", debugstate);
       }
       else
       {
           rv = EM_PSD_RTP_CLEANUP_FAILED;
           printdbg(" : failed. \n", debugstate);
       }
    }

    /*Moved from the end of scanloop in epi.e to ensure*/
    if ( (oprealtime == PSD_ON ) && (rspent == L_SCAN) )
    {
%ifdef DEBUG
        printdbg("Free id value buffers.\n", rtia_ipg_debug);
%endif /* DEBUG */
        FreeNode(input_id_values_buffer);
        FreeNode(recon_id_values_buffer);
    }

    return rv;
}

@rsp RTB0Core_epi2 /*MF B0 correction: Code to include for RTB0 DWI/DTI*/
void play_rtb0dummyseq(int count)
{
    int i = 0;
    if (rtb0dummyseq){
        boffset(off_seqrtb0dummy);
        settriggerarray((SHORT)1, rsptrigger_temp); /*set trigger to TRIG_INTERN for dummy seq*/
        for (i = 0; i < count; i++)
        {
            startseq((SHORT)0, (SHORT)MAY_PAUSE);
        }
    }
}

void play_rtb0resultwaitseq(int count)
{
    int i = 0;
    boffset(off_seqrtprtb0); /* offset to feedback wait pulse */
    settriggerarray((SHORT)1, rsptrigger_temp); /*set trigger to TRIG_INTERN for dummy seq*/
    for (i = 0; i < count; i++)
    {
        startseq((SHORT)0, (SHORT)MAY_PAUSE);
    }
}

void play_rtb0fitwaitseq(int count)
{
    int i = 0;
    boffset(off_seqrtb0fitwait);
    settriggerarray((SHORT)1, rsptrigger_temp); /*set trigger to TRIG_INTERN for dummy seq*/
    for (i = 0; i < count; i++)
    {
        startseq((SHORT)0, (SHORT)MAY_PAUSE);
    }
}


void set_dynr1(int r1)
{
    attenlockoff(&atten);
    setwamp(SSPDS+RDC,&dynr1,0);
    setwamp(SSPOC+RFHUBSEL,&dynr1,1);
    setwamp(SSPD+R1IND+r1-1,&dynr1,2);
}

/*MF B0 correction*/
void cf_medianfilter_acqinterpolation(const int slcindex_num, const int kernel_size, const int confidence_method, const float *slice_cfconfidence, const float conf_threshold)
{
    int i = 0, pass2 = 0, slcindex = 0;

    int cnt            = 0;
    int slcno          = 0;
    int validPts       = 0;
    int nextValidIndex = 0;

    float cfd[5] = {0.0};
    int half_kernel     = 0;
    int half_kernel_tmp = 0;
    int validity[slcindex_num];

    half_kernel = (kernel_size%2==0)?(kernel_size/2):(kernel_size-1)/2;

    /* median filtering */
    if (rtb0_debug)
    {
        fprintf(fp_cfdata, "Pass Slice-Index Slice-Loc \
                            Fid-Mean Measure-CF Filtered-CF \
                            CF-stddev CF-residual \
                            Slc-No p0Slc1 p0Slc2 \
                            p0SlcInd1 p0SlcInd2\n");
    }

    if(rtb0_filter_cf_flag)
    {
        if (confidence_method > 0)
        {
            /* Compute validity mask */
            for (slcindex = 0; slcindex < slcindex_num; slcindex++)
            {            
                validity[slcindex] = (slice_cfconfidence[slcindex] <= conf_threshold) ? 1 : 0;
            }

            for (slcindex = 0; slcindex < slcindex_num; slcindex++)
            {
                if (validity[slcindex]==1)
                {
                    cfd[0]=slice_cfoffset[slcindex];/*fill center point*/
                    cnt = 1;
                    half_kernel_tmp = half_kernel; /*3 point median, 1 on each side + 1 in the middle*/
                }
                else
                {
                    cnt = 0;
                    half_kernel_tmp = half_kernel+1; /*4 point median, 2 on each side*/
                }

                validPts = 0;
                slcno = sltime2slloc[slcindex];

                /*search on -ve side*/
                nextValidIndex = slcno-1*acqs; 
                while (validPts < half_kernel_tmp && nextValidIndex>=0)
                {
                    if (validity[slloc2sltime[nextValidIndex]]==1)
                    {
                        cfd[cnt]=slice_cfoffset[slloc2sltime[nextValidIndex]];
                        cnt++;
                        validPts++;
                        nextValidIndex -= acqs;
                    }
                    else
                    {
                        nextValidIndex -= acqs;
                    }
                }	

                validPts = 0; /*restart*/
			
                /*search on +ve side*/
                nextValidIndex = slcno+1*acqs;
                while (validPts < half_kernel_tmp && nextValidIndex < opslquant)
                {
                    if (validity[slloc2sltime[nextValidIndex]]==1)
                    {
                        cfd[cnt]=slice_cfoffset[slloc2sltime[nextValidIndex]];
                        cnt++;
                        validPts++;
                        nextValidIndex += acqs;
                    }
                    else
                    {
                        nextValidIndex += acqs;
                    }
                }

                /* sorting to find the median*/
                if(cnt == 1)
                {
                    slice_cfoffset_filtered[slcindex] = cfd[0];
                }
                else
                {
                    slice_cfoffset_filtered[slcindex]= median(cfd, cnt);
                }
            }/*end for loop*/
        }
        else
        {
            for (slcindex = 0; slcindex < slcindex_num; slcindex++)
            {
                cnt = 0;
                slcno = sltime2slloc[slcindex];
                for (i = -half_kernel; i <= half_kernel; i++)
                {
                    if((slcno+i*acqs >= 0) && (slcno+i*acqs < opslquant))
                    {
                        cfd[cnt] = slice_cfoffset[slloc2sltime[slcno+i*acqs]];
                        cnt++;
                    }
                }
                
                /* sorting to find the median */
                if (cnt == 1) 
                {
                    slice_cfoffset_filtered[slcindex] = cfd[0];
                }
                else
                {
                    slice_cfoffset_filtered[slcindex]= median(cfd, cnt);
                }
            }
        }/*end if confidence_method > 0*/
    }
    else
    {
        for (slcindex = 0; slcindex < slcindex_num; slcindex++)
        {
            slice_cfoffset_filtered[slcindex] = slice_cfoffset[slcindex];
        }
    }
    
    /*print for debug*/
    if (rtb0_debug)
    {
        for (slcindex = 0; slcindex < slcindex_num; slcindex++)
        {
            fprintf(fp_cfdata, "0 %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f\n",
                    slcindex, rsp_info[slcindex].rsptloc,
                    slice_fidmean[slcindex], slice_cfoffset[slcindex], slice_cfoffset_filtered[slcindex], 
                    slice_cfstddev[slcindex], slice_cfresidual[slcindex]);
        }
    }

    /*fill in 2nd pass*/
    for (pass2 = 1; pass2 < rspacq; pass2++)
    {
        int p0slcno1 = 0, p0slcindex1 = 0;
        int p0slcno2 = 0, p0slcindex2 = 0;
        int the_slcindex = 0;
        int slcno        = 0;

        for (slcindex = 0; slcindex < slc_in_acq[pass2]; slcindex++)
        {
            the_slcindex = (acq_ptr[pass2] + slcindex)%opslquant;
            slcno = sltime2slloc[the_slcindex];

            p0slcno1 = slcno/rspacq*rspacq;
            p0slcindex1 = slloc2sltime[p0slcno1];
            p0slcno2 = p0slcno1+rspacq;
            p0slcindex2 = slloc2sltime[p0slcno2];

            if(p0slcno2 >= opslquant)
            {
                slice_cfoffset_filtered[the_slcindex] = slice_cfoffset_filtered[p0slcindex1];
                if (rtb0_debug)
                {
                    fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d * %d *\n", 
                            pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                            slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                            slice_cfstddev[slcindex], slice_cfresidual[slcindex],
                            slcno, p0slcno1, p0slcindex1);
                }
                continue;
            }
            else
            {	
                slice_cfoffset_filtered[the_slcindex]
                = (slice_cfoffset_filtered[p0slcindex2]-slice_cfoffset_filtered[p0slcindex1])*
                  (float)(slcno-p0slcno1)/(float)(p0slcno2-p0slcno1)+slice_cfoffset_filtered[p0slcindex1];

                if (rtb0_debug)
                {
                    fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d %d %d %d\n", 
                            pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                            slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                            slice_cfstddev[slcindex], slice_cfresidual[slcindex],
                            slcno, p0slcno1, p0slcno2, 
                            p0slcindex1, p0slcindex2);
                }
            }	
        }
    }
}

/* Moving average filter with variable kernel size for RTB0 correction.
 * Designed to keep values near edge of slice coverage closer to original RTP values.
 * Implemented to improve DWIBS inter-station connectivity.*/
void cf_smooth_with_keep_edge(const int slcindex_num, const int min_kernel_size, const int max_kernel_size, const int confidence_method, const float *slice_cfconfidence, const float conf_threshold)
{
    int pass2 = 0, slcindex = 0, slcno = 0, slcno_for_ave = 0;

    /* Range of points used for moving average will depend on kernel size & number of points from edge */
    int half_kernel        = 0;
    int points_from_edge   = 0;
    int min_slcno_for_ave  = 0;
    int max_slcno_for_ave  = 0;
    int all_slices_invalid = 1; /* Later, if valid slice(s) exist, flag will be updated to 0 */

    int   n_averageSlices = 0;   /* Number of  RTB0 which were added up */
    float sum_delta_CF    = 0.0; /* Sum of all RTB0 for all edge slices */

    int validity[slcindex_num];

    for (slcindex = 0; slcindex < slcindex_num; slcindex++)
    {
        if ((confidence_method > 0) && (slice_cfconfidence[slcindex] > conf_threshold))
        {
            validity[slcindex] = 0;
        }
        else /* If Confidence thresholding is turned Off, or if confidence_value <= threshold */
        {
            all_slices_invalid = 0; /* At least one of the slices is valid */
            validity[slcindex] = 1;
        }
    }

    /* Print for debug */
    if (rtb0_debug)
    {
        fprintf(fp_cfdata, "Pass Slice-Index Slice-Loc \
                            Fid-Mean Measure-CF Filtered-CF \
                            CF-stddev CF-residual \
                            Slc-No p0Slc1 p0Slc2 \
                            p0SlcInd1 p0SlcInd2\n");
    }

    for (slcno = 0; slcno < slcindex_num; slcno++)
    {
        points_from_edge = IMin(2, slcno, slcindex_num - 1 - slcno);
        half_kernel = IMin(2, IMax(2, points_from_edge, (min_kernel_size - 1) / 2), (max_kernel_size - 1) / 2);
        min_slcno_for_ave = IMax(2, 0, slcno - half_kernel);
        max_slcno_for_ave = IMin(2, slcindex_num - 1, slcno + half_kernel);
        
        if (all_slices_invalid)
        {
            slice_cfoffset_filtered[slloc2sltime[slcno * acqs]] = slice_cfoffset[slloc2sltime[slcno * acqs]];
        }
        else /* Compute cf offset based on valid point(s) */
        {
            /* 1. Set min/max range for averaging */

            n_averageSlices = 0;

            while (n_averageSlices == 0)
            {
                for (slcno_for_ave = min_slcno_for_ave; slcno_for_ave <= max_slcno_for_ave; slcno_for_ave++)
                {
                    if (validity[slloc2sltime[slcno_for_ave * acqs]] == 1)
                    {
                        n_averageSlices = n_averageSlices + 1;
                    }
                }
                
                /* If no points to average, extend min/max slice range and interatively find valid slice(s) */
                if (n_averageSlices == 0)
                {
                    min_slcno_for_ave = IMax(2, 0, min_slcno_for_ave - 1);
                    max_slcno_for_ave = IMin(2, slcindex_num - 1, max_slcno_for_ave + 1);
                }

                /* If end of slice coverage reached, break from while loop */
                if ((min_slcno_for_ave == 0) && (max_slcno_for_ave == (slcindex_num - 1)))
                {
                    min_slcno_for_ave = 0;
                    max_slcno_for_ave = slcindex_num;
                    break;
                }
            }

            /* 2. Perform averaging over min/max range */
            
            n_averageSlices = 0;
            sum_delta_CF    = 0.0;

            for (slcno_for_ave = min_slcno_for_ave; slcno_for_ave <= max_slcno_for_ave; slcno_for_ave++)
            {
                if (validity[slloc2sltime[slcno_for_ave * acqs]] == 1)
                {
                    n_averageSlices = n_averageSlices + 1;
                    sum_delta_CF = sum_delta_CF + slice_cfoffset[slloc2sltime[slcno_for_ave * acqs]];
                }
            }
            if( n_averageSlices > 0 )
            {
                slice_cfoffset_filtered[slloc2sltime[slcno * acqs]] = sum_delta_CF / n_averageSlices;
            }
            else
            {
                /* if n_averageSlices is 0, sum_delta_CF is also 0, skip the division */
                slice_cfoffset_filtered[slloc2sltime[slcno * acqs]] = 0.0;
            }
        } /* End computation of cf offset */
    } /* End loop over all slices */

    /* Print linear interpolated CF values for debug */
    if (rtb0_debug)
    {
        for (slcindex = 0; slcindex < slcindex_num; slcindex++)
        {
            fprintf(fp_cfdata, "0 %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f\n",
                    slcindex, rsp_info[slcindex].rsptloc,
                    slice_fidmean[slcindex], slice_cfoffset[slcindex], slice_cfoffset_filtered[slcindex], 
                    slice_cfstddev[slcindex], slice_cfresidual[slcindex]);
        }
    }

    /* Fill in 2nd Pass using 1st Pass information */
    for(pass2 = 1; pass2 < rspacq; pass2++)
    {
        int p0slcno1 = 0, p0slcindex1 = 0;
        int p0slcno2 = 0, p0slcindex2 = 0;
        int the_slcindex = 0;
        int slcno        = 0;

        for(slcindex = 0; slcindex < slc_in_acq[pass2]; slcindex++)
        {
            the_slcindex = (acq_ptr[pass2] + slcindex)%opslquant;
            slcno = sltime2slloc[the_slcindex];

            p0slcno1 = slcno/rspacq*rspacq;
            p0slcindex1 = slloc2sltime[p0slcno1];
            p0slcno2 = p0slcno1+rspacq;
            p0slcindex2 = slloc2sltime[p0slcno2];

            if(p0slcno2 >= opslquant)
            {
                slice_cfoffset_filtered[the_slcindex] = slice_cfoffset_filtered[p0slcindex1];
                if (rtb0_debug)
                {
                    fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d * %d *\n", 
                            pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                            slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                            slice_cfstddev[slcindex], slice_cfresidual[slcindex], 
                            slcno, p0slcno1, p0slcindex1);
                }
                continue;
            }
            else
            {	
                slice_cfoffset_filtered[the_slcindex]
                = (slice_cfoffset_filtered[p0slcindex2]-slice_cfoffset_filtered[p0slcindex1])*
                  (float)(slcno-p0slcno1)/(float)(p0slcno2-p0slcno1)+slice_cfoffset_filtered[p0slcindex1];

                if (rtb0_debug)
                {
                    fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d %d %d %d\n", 
                            pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                            slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                            slice_cfstddev[slcindex], slice_cfresidual[slcindex], 
                            slcno, p0slcno1, p0slcno2, 
                            p0slcindex1, p0slcindex2);
                }
            }	
        }
    } /* End sorting of filered CF data */
}

/*MF B0 correction weighted fit*/
void printCFResult(int slcindex_num)
{    
    fprintf(fp_cfdata, "Pass Slice-Index Slice-Loc \
                        Fid-Mean Measure-CF Filtered-CF \
                        CF-stddev CF-residual \
                        Slc-No p0Slc1 p0Slc2 \
                        p0SlcInd1 p0SlcInd2\n");

    int slcindex = 0, pass2 = 0;

    for(slcindex = 0; slcindex < slcindex_num; slcindex++)
    {
        fprintf(fp_cfdata, "0 %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f\n", 
                slcindex, rsp_info[slcindex].rsptloc,
                slice_fidmean[slcindex], slice_cfoffset[slcindex], slice_cfoffset_filtered[slcindex], 
                slice_cfstddev[slcindex], slice_cfresidual[slcindex]);
    }

    for(pass2 = 1; pass2 < rspacq; pass2++)
    {
        int p0slcno1 = 0, p0slcindex1 = 0;
        int p0slcno2 = 0, p0slcindex2 = 0;
        int the_slcindex = 0;
        int slcno        = 0;

        for(slcindex = 0; slcindex < slc_in_acq[pass2]; slcindex++)
        {
            the_slcindex = (acq_ptr[pass2] + slcindex)%opslquant;
            slcno = sltime2slloc[the_slcindex];

            p0slcno1 = slcno/rspacq*rspacq;
            p0slcindex1 = slloc2sltime[p0slcno1];
            if(p0slcindex1 >= slc_in_acq[0]-1)
            {
                fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d * %d *\n", 
                        pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                        slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                        slice_cfstddev[slcindex], slice_cfresidual[slcindex],
                        slcno, p0slcno1, p0slcindex1);
                continue;
            }

            p0slcno2 = p0slcno1+rspacq;
            p0slcindex2 = slloc2sltime[p0slcno2];

            fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d %d %d %d\n", 
                    pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                    slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex],
                    slice_cfstddev[slcindex], slice_cfresidual[slcindex],
                    slcno, p0slcno1, p0slcno2,
                    p0slcindex1, p0slcindex2);
        }
    }

}


void interpolatePass(void)
{
    int pass2 = 0, slcindex = 0;

    for (pass2 = 1; pass2 < rspacq; pass2++)
    {
        int p0slcno1 = 0, p0slcindex1 = 0;
        int p0slcno2 = 0, p0slcindex2 = 0;
        int the_slcindex = 0;
        int slcno        = 0;

        for (slcindex = 0; slcindex < slc_in_acq[pass2]; slcindex++)
        {
            the_slcindex = (acq_ptr[pass2] + slcindex)%opslquant;
            slcno = sltime2slloc[the_slcindex];

            p0slcno1 = slcno/rspacq*rspacq;
            p0slcindex1 = slloc2sltime[p0slcno1];
            if(p0slcindex1 >= slc_in_acq[0]-1)
            {
                slice_cfoffset_filtered[the_slcindex] = slice_cfoffset_filtered[p0slcindex1];
                if (rtb0_debug)
                {
                    fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d * %d *\n", 
                            pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                            slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                            slice_cfstddev[slcindex], slice_cfresidual[slcindex], 
                            slcno, p0slcno1, p0slcindex1);
                }
                continue;
            }

            p0slcno2 = p0slcno1+rspacq;
            p0slcindex2 = slloc2sltime[p0slcno2];
            slice_cfoffset_filtered[the_slcindex]
                = (slice_cfoffset_filtered[p0slcindex2]-slice_cfoffset_filtered[p0slcindex1])*
                  (slcno-p0slcno1)/(p0slcno2-p0slcno1)+slice_cfoffset_filtered[p0slcindex1];
    	
            if (rtb0_debug)
            {
                 fprintf(fp_cfdata, "%d %d %8.2f %8.2f %7.2f %7.2f %8.2f %8.2f %d %d %d %d %d\n", 
                         pass2, the_slcindex, rsp_info[the_slcindex].rsptloc,
                         slice_fidmean[p0slcindex1], slice_cfoffset[p0slcindex1], slice_cfoffset_filtered[the_slcindex], 
                         slice_cfstddev[slcindex], slice_cfresidual[slcindex],
                         slcno, p0slcno1, p0slcno2, 
                         p0slcindex1, p0slcindex2);
            }
        }
    }

}

/*sort cfoffset by either location (dir =0) or time (dir = 1)*/
void reorder_cfoffset(float *cfoffset_reorder, float *cfoffset, int slquant, int *loc2time, int dir)
{
    int i = 0;

    if (dir==0) /*convert sort by time to sort by loc*/
    {
        for (i = 0; i < slquant; i++)
        {
            cfoffset_reorder[i]=cfoffset[loc2time[i]];
        }
    }
    else /*convert sort by loc back to sort by time*/
    {
        for (i = 0; i < slquant; i++)
        {
            cfoffset_reorder[loc2time[i]]=cfoffset[i];
        }
    }
}

#if defined(MGD_TGT) && defined(PSD_HW)
/**
 * This function is not used in product, but is useful function for debug
 * Min and Max RTB0 roundtrip time will be logged
 */
void computeRTB0TimingStats()
{
    char rtb0filepath[170] = "/export/home/service/log/RTB0Stat_";
    struct timespec nCurrTimeRtb0;
    char timestampRtb0[20];
    struct tm *Rtb0timePtr;
    FILE *fp_rtb0Stat;
    long rtb0timingidx = 0;

    mgd_clock_gettime (HOST_TIME_OF_DAY, &nCurrTimeRtb0);
    Rtb0timePtr  = localtime(&nCurrTimeRtb0.tv_sec);

    strftime(timestampRtb0,20,"_%m%d%Y%H_%M_%S",Rtb0timePtr);

    strcat(rtb0filepath,timestampRtb0);

    fp_rtb0Stat=fopen(rtb0filepath, "w");
    if (fp_rtb0Stat == NULL) 
    {
        printf("Failed to open %s\n", rtb0filepath);
        return;
    }
    /* Send Timing Stats to File */

    fprintf(fp_rtb0Stat, "Min RTB0 roundtrip time: %ld \n", min_rtb0_feedback_time);
    fprintf(fp_rtb0Stat, "Max RTB0 roundtrip time: %ld \n", max_rtb0_feedback_time);
    fprintf(fp_rtb0Stat, "RTB0 interslice fitting time: %.6f \n", rtb0_fitting_time);
    for (rtb0timingidx = 0; rtb0timingidx < rtb0_roundtrip_index; rtb0timingidx++)
    {
        fprintf(fp_rtb0Stat, "%ld\n", rtb0_roundtrip_timing_array[rtb0timingidx]);
    }

    fclose(fp_rtb0Stat);

    return;
}
#endif

@rsp RTB0_clock_decl
#if defined(MGD_TGT) && defined(PSD_HW)
    struct timespec tim;
    double t1, t2;
#endif

@rsp RTB0starttimer
#if defined(MGD_TGT) && defined(PSD_HW)
    if (PSD_ON == rtb0_timing_flag)
    {
        rspstarttimer();
    }
#endif

@rsp RTB0readtimer
#if defined(MGD_TGT) && defined(PSD_HW)
    if (PSD_ON == rtb0_timing_flag)
    {
        rtb0_feedback_time = rspreadtimer();
        printf("feedback time =%ld\n", rtb0_feedback_time);

        if(rtb0_roundtrip_index < RTB0_NUM_TIMING_POINTS)
        {
            rtb0_roundtrip_timing_array[rtb0_roundtrip_index] = rtb0_feedback_time;
            rtb0_roundtrip_index++;
        }

        if (max_rtb0_feedback_time < rtb0_feedback_time)
        {
            max_rtb0_feedback_time = rtb0_feedback_time;
        }

        if (min_rtb0_feedback_time > rtb0_feedback_time)
        {
            min_rtb0_feedback_time = rtb0_feedback_time;
        }

        rtb0_num_frames_processed = rtb0_processed_index;
        sum_rtb0_feedback_times = sum_rtb0_feedback_times + rtb0_feedback_time;
     }
#endif

@rsp RTB0startfittingtimer
#if defined(MGD_TGT) && defined(PSD_HW)
    if (PSD_ON == rtb0_timing_flag)
    {
        mgd_clock_gettime(HOST_TIME_OF_DAY, &tim);  
        t1 = tim.tv_sec+(tim.tv_nsec/1000000000.0);
    }
#endif

@rsp RTB0readfittingtimer
#if defined(MGD_TGT) && defined(PSD_HW)
    if (PSD_ON == rtb0_timing_flag)
    {
        mgd_clock_gettime(HOST_TIME_OF_DAY, &tim);  
        t2 = tim.tv_sec+(tim.tv_nsec/1000000000.0);
        rtb0_fitting_time = (t2-t1)*10000; /*0.1ms*/
        printf("fitting time =%.6f [0.1ms]\n", rtb0_fitting_time);
    }
#endif

@rsp RTB0computeTimingStats
#if defined(MGD_TGT) && defined(PSD_HW)
    if (rtb0_timing_flag)
    {
        computeRTB0TimingStats();
    }
#endif

@rsp RTB0applyComp
    if(rtb0_comp_flag)
    {
        int i = 0;
        for (i = 0; i < opslquant; i++)
        {
            slice_cfoffset_TARDIS[i] = (int)(slice_cfoffset_filtered[i]/TARDIS_FREQ_RES);
        }
		    	
        if (rtb0_recvphase_comp_flag && rspent == L_SCAN)/*no need to recalculate phase if it's in ref scan since phase_y_incr is set to 0.0 if ref_mode == 1 */
        {
            /* PWW: Integrated-RPG */
            recv_phase_freq_init();

            if (hoecc_flag == PSD_ON)
            {
                /* update recv_phase array that is used in dabrbaload() call later in core() */
                HoecCalcReceiverPhase();  /* in core(), dabrbaload() actually applies recv_phase that is calculated here */

            } /* end hoecc_flag*/
        }/* end rtb0_recvphase_comp_flag*/
    }/* end rtb0_comp_flag*/

@rsp RTB0intersliceFitting

    int slcindex = 0;

    int rtb0_num_slice = last_rtb0_sliceindex - first_rtb0_sliceindex + 1;

    /* Number of slices should never exceed GE limits or be negative */
    if ((rtb0_num_slice > DATA_ACQ_MAX) || (rtb0_num_slice < 0))
    {
        return FAILURE; 
    }

    /* Switch between confidence methods */
    switch (rtb0_confidence_method)
    {
    case 1: /* Linear fit residual */
        rtb0_confidence_thresh_val = rtb0_cfresidual_threshold;
        for (slcindex = 0; slcindex < rtb0_num_slice; slcindex++)
        {
            slice_cfconfidence[slcindex] = slice_cfresidual[slcindex];
        }
        break;
    case 2: /* Standard deviation across channels */
        rtb0_confidence_thresh_val = rtb0_cfstddev_threshold;
        for (slcindex = 0; slcindex < rtb0_num_slice; slcindex++)
        {
            slice_cfconfidence[slcindex] = slice_cfstddev[slcindex];
        }
        break;
    case 0: /* Do not threshold */
    default:
        /* Turn off confidence thresholding (i.e. all slices are valid) */
        rtb0_confidence_thresh_val  = 0.0;
        for (slcindex = 0; slcindex < rtb0_num_slice; slcindex++)
        {
            slice_cfconfidence[slcindex] = -1.0; /* To ensure all pts are below threshold (i.e. valid) */
        }
    }

    switch (cf_interpolation)
    {
        case 0: /*Median filter*/
            cf_medianfilter_acqinterpolation(rtb0_num_slice, rtb0_median_kernel_size, rtb0_confidence_method, slice_cfconfidence, rtb0_confidence_thresh_val);
            break;
        case 1: /*Weighted 1st order (linear) fit*/
            weighted_polyfit(slice_cfoffset_filtered, cf_coeff, slice_cfoffset,f_sltime2slloc, slice_fidmean, 1, rtb0_num_slice);
            break;
        case 2: /*Weighted 2nd order (quadratic) fit */
            weighted_polyfit(slice_cfoffset_filtered, cf_coeff, slice_cfoffset,f_sltime2slloc, slice_fidmean, 2, rtb0_num_slice);
            break;
        case 3: /*Weighted 3rd order (quadratic) fit */
            weighted_polyfit(slice_cfoffset_filtered, cf_coeff, slice_cfoffset,f_sltime2slloc, slice_fidmean, 3, rtb0_num_slice);
            break;
        case 4: /*Smooth with keep edge*/
            /*Compute maximum kernel size as percent of slice coverage*/
            rtb0_max_kernel_keep_edge = (int)(rtb0_max_kernel_percent / 100.0 * rtb0_num_slice);
            if (rtb0_max_kernel_keep_edge % 2)
            {
                rtb0_max_kernel_keep_edge = rtb0_max_kernel_keep_edge + 1;
            }
            cf_smooth_with_keep_edge(rtb0_num_slice, rtb0_min_kernel_keep_edge, rtb0_max_kernel_keep_edge, rtb0_confidence_method, slice_cfconfidence, rtb0_confidence_thresh_val);
            break;
    }
    /*MF B0 correction*/
    /*Interpolate for pass>1 only if polynomial fit method is used*/
    if (cf_interpolation >=1 && cf_interpolation < 4)
    {
        int pass2 = 0;
        int the_slcindex = 0;

        for (pass2 = 1; pass2 < rspacq; pass2++)
        {
            the_slcindex = acq_ptr[pass2]%opslquant;

            generate_polycurve(&slice_cfoffset_filtered[the_slcindex],&f_sltime2slloc[the_slcindex], cf_coeff, cf_interpolation/*order*/,slc_in_acq[pass2]);
        }
			
        if (rtb0_debug)
            printCFResult(rtb0_num_slice);

    }

    /*MF B0 correction: add manual baseline offset - for testing only*/
    int i = 0;
    for (i=0;i<opslquant;i++)
    {
        slice_cfoffset_filtered[i]=slice_cfoffset_filtered[i];
    }

    /*MF B0 correction: cap the max rtb0 offset*/
    for (i=0;i<opslquant;i++)
    {
        if (fabs(slice_cfoffset_filtered[i])>rtb0_max_range)
        {
            slice_cfoffset_filtered[i]=(slice_cfoffset_filtered[i]>0? 1:-1)*rtb0_max_range;
        }
    }

    /*MF B0 correction: apply smoothing*/
    /*reorder cfoffset so it is sort by slice location when it goes into the generic smooth function*/
    if (rtb0_smooth_cf_flag)
    {
        /*convert sort by time to sort by loc*/
        reorder_cfoffset(slice_cfoffset_bySlice, slice_cfoffset_filtered, opslquant, slloc2sltime, 0); 

        smooth(slice_cfoffset_bySlice, opslquant, rtb0_smooth_kernel_size, 0);

        /*convert sort by loc to sort by slice*/
        reorder_cfoffset(slice_cfoffset_filtered, slice_cfoffset_bySlice, opslquant, slloc2sltime, 1);
    }		

    /*Print out CF offset after smoothing*/
    if (rtb0_debug)
    {
        int i = 0;
        for (i=0; i<opslquant; i++)
        {
            fprintf(fp_cfdata, "%d %8.2f\n", i, slice_cfoffset_filtered[i]);
        }
    }

