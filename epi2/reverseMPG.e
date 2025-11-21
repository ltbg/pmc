/** 
 * @copyright   Copyright (c) 2019 by General Electric Company. All Rights Reserved.
 *
 * @file        reverseMPG.e
 *
 * @brief       Code to support Reverse the MPG polarity implementation
 *  
 * @author      Ting Zhang, Lei Gao
 *  
 * @since       MR28.0
 * 
 */
 
/* do not edit anything above this line */

/* 
 * Commens:
 *
 * 1 April 2019    Lei Gao 
 * Initial Creation, mpgPolarity is the CV calculated by this .e file. 
 * When you need to modify reverseMPG.e, pls. pay attention to mpgPolarity's infulences in epi2.e RfovFuncs.e HoecCorr.e
 *
 */

@global reverseMPGGlobal
/* 
 * reverseMPGGlobal  inlined from reverseMPG.e 
 * define the max time for MPG polarity update 
 * define temp file path for MPG polarity 
 */
 
#define  POLARITY_UPDATE_TIME   3600*24
#define  MPG_POLARITY_FILE      "/usr/g/service/log/mpgPolarity"
#include "reverseMPG.h" 

bool updateMPGPolarity = false;  

@cv reverseMPGCV
/* 
 * reverseMPGCV  inlined from reverseMPG.e 
 * new CV for reverse MPG polarity support flag and control flag;
 * define and initilize MPG polarity. 
 */
int reverseMPGFlag    = PSD_OFF with { PSD_OFF, PSD_ON, PSD_OFF, VIS, "Reverse the MPG polarity: 0 = OFF, 1 = ON"             , };
int reverseMPGSupport = PSD_OFF with { PSD_OFF, PSD_ON, PSD_OFF, VIS, "Reverse the MPG polarity: 0 = not support, 1 = support", };

@host reverseMPGCVInit
/* 
 * reverseMPGCVInit  inlined from reverseMPG.e 
 * Determine ifreverseMPG feature is supported
 * Currently it is supported in Starter systems
 * DSE and DTI features are not supported 
 */
{
    if(isStarterSystem())
    {
        reverseMPGSupport = PSD_ON;
    }
    else
    {
        reverseMPGSupport = PSD_OFF;
    }

    if((PSD_ON == reverseMPGSupport) && (PSD_OFF == dualspinecho_flag) && (PSD_ON == opdiffuse))
    {
        reverseMPGFlag = PSD_ON;
    }
    else
    {
        reverseMPGFlag = PSD_OFF;
    }
}


@host reverseMPGCvcheck
/* 
 * CV Check for reverse MPG feature
 * Check DSE and DTI compatiblity with reverse MPG feature
 * Check anatomy compatiablity with reverse MPG feature
 */
{
    if(dualspinecho_flag && reverseMPGFlag)
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "reverseMPG", STRING_ARG, "Dual Epin Echo" );
        return FAILURE;
    }

    if(!((MPG_POLARITY_REVERSED == mpgPolarity) || (MPG_POLARITY_STANDARD == mpgPolarity)))
    {
        epic_error( use_ermes, "mpgPolarity must be 1 or -1 for the current prescription.", EM_PSD_MPGPOLARITY_OUT_OF_RANGE, EE_ARGS(0));
        return FAILURE;
    }
}

@host setMPGPolarity
/* 
 * Read MPG polarity infomation from temp file MPG_POLARITY_FILE
 * 
 * MPG polarity will reversed in such condition:
 * 1. Present patient weight differs from the last patient;
 * 2. The prescribed exam stays 1 whole day(24 hours) long; 
 */
 
if(reverseMPGFlag)
{
    float       weightTmp;
    int         timeTmp;
    int         polarityTmp;

    time_t currentTime = time(NULL);
 
    if(!updateMPGPolarity)
    {
        FILE *fp = fopen(MPG_POLARITY_FILE, "r");
        if(fp != NULL)
        { 
            fscanf(fp, "%f  %d  %d\n", &weightTmp, &polarityTmp, &timeTmp);
            fclose(fp);
            if((MPG_POLARITY_REVERSED == polarityTmp) || (MPG_POLARITY_STANDARD == polarityTmp))
            {
                if((floatsAlmostEqualEpsilons(opweight, weightTmp,2)) && (((INT)currentTime - timeTmp) < POLARITY_UPDATE_TIME))
                {
                    mpgPolarity = polarityTmp; 
                }
                else
                {
                    mpgPolarity = -1 * polarityTmp;
                }
            }
            else
            {
                mpgPolarity = MPG_POLARITY_STANDARD;
            }
        }
        writeMPGPolarityFile();
        updateMPGPolarity = TRUE;
    }
}

@host MPGPolarityHostFunctions

void writeMPGPolarityFile(void)
{
    time_t currentTime = time(NULL);
    FILE* fp = fopen(MPG_POLARITY_FILE, "w");
    if(fp != NULL)
    {
        fprintf(fp,"%f  %d  %d\n", opweight, mpgPolarity, INT(currentTime));
        fclose(fp);
    }
    else
    {
        printf("Failed to open %s.\n", MPG_POLARITY_FILE);
    }
}


