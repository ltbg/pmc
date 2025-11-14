/*
 * -GE CONFIDENTIAL-
 * Type: Source Code
 *
 * Copyright (c) 2022, GE Healthcare
 * All Rights Reserved
 *
 * This unpublished material is proprietary to GE Healthcare. The methods and
 * techniques described herein are considered trade secrets and/or
 * confidential. Reproduction or distribution, in whole or in part, is
 * forbidden except by express written permission of GE Healthcare.
 */

/**
 * \file RtpDemo.e 
 * EPIC inline file implementing a RTP example.
 *
 * The code acquires a RTP data frame and polls for the feedback from
 * the RTP application. The RTP segment is one acquisition window. The
 * RTP processing copies the data frame into a buffer and returns a
 * signed int32 and a float32 to PSD. The size and location of
 * the acquisition window is configurable via CVs. The acquisition
 * will abort if feedback is not received within a specified time or if
 * the feedback does not match the expected results.
 *
 * To use this inline file in a PSD:
 * - Add @inline RtpDemo.e to the end of the PSD
 * - Call rtpDemoPredownload() in predownload()
 * - Call rtpDemoPulsegen() in pulsegen() before buildinstr();
 * - Call rtpDemoRspInit() in psdinit()
 * - Call getRtpDemoFrames(rtpDemoFramesPerCall) in the scan core
 *   at the place where you want to acquire RTP frames. Be sure to
 *   boffset back to the primary scanning segment after this function
 *   call. 
 */

@global RtpDemoGlobal
#include "RtpDemo.h"
#include "RtpDemoIF.h"


@cv RtpDemoCV

int rtpDemo = 0 with {0, 1, 0, VIS, "Enable RTP Demo acquisition",};
int rtpDemoSaveRawData = 0 with {0, 1, 0, VIS, "Save RTP raw data",};
int rtpDemoDebug = 1 with {0, 1, 0, VIS, "RTP Demo debug flag",};
int rtpDemoXres = 256 with {1, , 256, VIS, "Number of readout points",};
float rtpDemoBw = 62.5 with {0, , 62.5, VIS, "receive bandwidth",};
int rtpDemoLeadTime = 300 with {212, , ,VIS,"RTP Demo: Time from start of sequence to start of acquisition window",};
int rtpDemoTr = 3000 with {0, , 3000, VIS, "TR for demo acquisition segment",};
int rtpDemoWaitTr = 1000 with {0, , 1000, VIS, "Feedback polling period",};
int rtpDemoFeedbackMaxWait = 100000 with {0, ,0, VIS, "Stop checking for feedback and stop scan after this time (x 0.1 ms)",};
int rtpDemoFeedbackMaxLast = 10000 with {0, , 0, VIS, "Stop scan if feedback of last packet > than this (x 0.1 ms)",};
int rtpDemoFramesPerCall = 1;

int rtpDemoQueueDepth = 1 with {0, , 1, VIS, "RTP queue depth",};
int rtpDemoQueueOverflowOption = 1 with {0, 1, 1, VIS, "RTP queue overflow option (0:STOP THE SCAN, 1:REMOVE OLDEST MSDG)",};
int rtpDemoQueueReqType = 1 with {1, 2, 1, VIS, "RTP queue request type (1:POP FROM OLD, 2:POP FROM RECENT)",};
int rtpDemoFeedbackSizeInBytes = 12 with {1, RTP_UNPACKED_RESULT_SIZE, 4, VIS, "RTP feedback data size in bytes",};

int rtpDemoDataS32 = 17 with {, , 17, VIS, "RTP feedback data for signed int32",};
int rtpDemoDataS32Expected = 17 with {, , 17, VIS, "RTP expected feedback data for signed int32",};
float rtpDemoDataF32 = 7.9 with {, , 7.9, VIS, "RTP feedback data for float32",};
float rtpDemoDataF32Expected = 7.9 with {, , 7.9, VIS, "RTP expected feedback data for float32",};


@host RtpDemoHost 

/**
 * performs predownload calculations for RTP Demo feature 
 * 
 * @return status of calculations (SUCCESS or FAILURE)
 */
STATUS rtpDemoPredownload()
{
    if( rtpDemo )
    {
        FILTER_INFO rtfilt;

        /* Setup receive filter */
        if( FAILURE == calcfilter(&rtfilt, rtpDemoBw, rtpDemoXres,
                                  OVERWRITE_NONE ) )
        {
            epic_error(use_ermes, "%s failed.", EM_PSD_SUPPORT_FAILURE,
                       EE_ARGS(1), STRING_ARG, "RtpDemo:calcfilter");
            return FAILURE;
        }
        cvoverride(rtpDemoBw, rtfilt.bw, PSD_FIX_OFF, PSD_EXIST_OFF);

        setfilter(&rtfilt, SCAN);
        filter_echo1RtpDemo = rtfilt.fslot;

        /* Calculate minimum TR for reference */
        cvmin(rtpDemoTr, rtpDemoLeadTime + rtfilt.tdaq + time_ssi); 
    }

    return SUCCESS;
}

@pg RtpDemoPulsegen

/**
 * generates RTP demo acquisition and wait segments
 */
void rtpDemoPulsegen()
{
    if( rtpDemo )
    {
        /* Simple data acquisition pulse */
        ACQUIREDATA(echo1RtpDemo, rtpDemoLeadTime, , , DABNORM);
        SEQLENGTH(seqRtpDemo, RUP_GRD(rtpDemoTr - time_ssi), seqRtpDemo);
        attenflagon(&seqRtpDemo, 0);

        /* Wait pulse for RTP Demo feedback feedback */
        SEQLENGTH(seqRtpDemoWait, RUP_GRD(rtpDemoWaitTr - time_ssi), seqRtpDemoWait);
    }

    return;
}

@rsp RtpDemoRsp

#include "RtpPsd.h"
#ifdef PSD_HW
#include "clockApi.h"
#include "rtp_feedback_task.h"
#endif

/**
 * initializes RTP Demo prior to starting scan
 */
void rtpDemoRspInit()
{
    if( rtpDemo )
    {
        RtpDataValuesPkt rtpPkt;

#if defined(MGD_TGT) && defined(PSD_HW)
        RTP_OPCODE_OPTIONS rtpOpt;
        int status = 0;
        int opcode = RTP_RESULT_DEMO_UNPACKED;

        rtpOpt.queueDepth = rtpDemoQueueDepth;
        rtpOpt.queueOverflowOption = rtpDemoQueueOverflowOption;
        status = rtp_register_opcode(opcode, rtpDemoFeedbackSizeInBytes, &rtpOpt);
        if (0 != status)
        {
            psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "rtp_register_opcode failed",
                PSD_ARG_STRING, "rtp_register_opcode:Demo", 0);
        }
#endif 

        /* Populate RTP initialization packet */
        strncpy(rtpPkt.rtpDataVal.path, "/usr/g/bin", sizeof(rtpPkt.rtpDataVal.path));
        strncpy(rtpPkt.rtpDataVal.func, "demoRTP", sizeof(rtpPkt.rtpDataVal.func));
        rtpPkt.rtpDataVal.frameSize = rtpDemoXres;
        rtpPkt.rtpDataVal.dacqType = dacq_data_type;
        rtpPkt.rtpDataVal.numRtpReceivers = 0; 
        rtpPkt.rtpDataVal.hubIndex = coilInfo_tgt[0].hubIndex; 
        rtpPkt.rtpDataVal.bodyCoilCombine = rtp_bodyCoilCombine;
        rtpPkt.rtpDataVal.writeRawData = rtpDemoSaveRawData;
        rtpPkt.rtpDataVal.vreDebug = rtpDemoDebug;

        rtpPkt.rtpDataVal.intVar_1 = rtpDemoFeedbackSizeInBytes;

        rtpPkt.rtpDataVal.intVar_2 = rtpDemoDataS32;
        rtpPkt.rtpDataVal.floatVar_2 = rtpDemoDataF32;

        if( SUCCESS != RtpInit(&rtpPkt) )
        {
            psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "RtpInit failed",
                    PSD_ARG_STRING, "RtpInit:RtpDemo", 0);
        }
        isrtplaunched = 1;
    }

    return;
}

/**
 * check feedback from RTP Demo App.
 *
 * @return 1 if new data available. 0 otherwise
 */
int checkRtpDemoFeedback()
{
    RtpDemoResult rtpResult;
    memset(&rtpResult, 0, sizeof(RtpDemoResult));
    int nBytes = 0;

#if defined(MGD_TGT) && defined(PSD_HW)
    n32 packed = 0;
    int opcode = RTP_RESULT_DEMO_UNPACKED;
    nBytes = rtp_get_feedback_data(&rtpResult, rtpDemoFeedbackSizeInBytes, &packed,
                                   opcode, rtpDemoQueueReqType);
#else
    nBytes = rtpDemoFeedbackSizeInBytes;
    rtpResult.data[0] = 0;
#endif

    if( nBytes > 0 )
    {
        printf("\nReturned Values: nBytes = %d, s32data = %ld, f32data = %f, floatVal = %f\n", nBytes, rtpResult.s32data, rtpResult.f32data, rtpResult.floatVal);
        fflush(NULL);

        /* Results are rtpDemoFeedbackSizeInBytes */
        if( nBytes != rtpDemoFeedbackSizeInBytes )
        {
            printf("\nnBytes (%d) != rtpDemoFeedbackSizeInBytes (%d)\n", nBytes, rtpDemoFeedbackSizeInBytes);
            fflush(NULL);
            RtpEnd();
            psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "Failure in reading results", PSD_ARG_STRING, "checkRtpDemoFeedback", 0);
        }

        if(rtpResult.s32data != rtpDemoDataS32Expected)
        {
            printf("\nValue mismatch: rtpResult.s32data = %ld, rtpDemoDataS32Expected = %d\n", rtpResult.s32data, rtpDemoDataS32Expected);
            fflush(NULL);
            RtpEnd();
            psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "NOT matching the expected results", PSD_ARG_STRING, "getDemoFeedback", 0);
        }

        if( rtpDemoFeedbackSizeInBytes > 4 )
        {
            if(!floatsAlmostEqualEpsilon(rtpResult.f32data, rtpDemoDataF32Expected))
            {
                printf("\nValue mismatch: rtpResult.f32data = %f, rtpDemoDataF32Expected = %f\n", rtpResult.f32data, rtpDemoDataF32Expected);
                fflush(NULL);
                RtpEnd();
                psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "NOT matching the expected results", PSD_ARG_STRING, "getDemoFeedback", 0);
            }
        }

        return 1;
    }
    else
    {
        printf("\nReturned nBytes = %d\n", nBytes);
        fflush(NULL);

        /* No new feedback data */
        return 0;
    }
}

/**
 * acquires specified number of RTP Demo acquisition frames, waiting
 * for feedback from RTP Demo app between each acquisition.  Scan will
 * abort if has not been received by rtpDemoFeedbackMaxWait * 0.1 ms
 * or if the feedback that is received took longer than
 * rtpDemoFeedbackMaxLast * 0.1 ms.
 *
 * @param[in] nFrames - number of RTP Demo acquistion frames to acquire 
 */
void getRtpDemoFrames(int nFrames)
{
    if( rtpDemo )
    {
        s32 feedbackTime = 0;
        int i = 0;
        int foundData = 0;

        /* select filter */
        setrfltrs((int)filter_echo1RtpDemo, &echo1RtpDemo);

        /* Route data to RTP */
        routeDataFrameDab(&echo1RtpDemo, ROUTE_TO_RTP, cfcoilswitchmethod);

        /* CoilSwitchSetCoil can be used to use body-coil to receive RTP data. See SpNav.e for examples. */

        for( i = 0; i < nFrames; i++ )
        {
            /* Acquire data frame */
            boffset(off_seqRtpDemo);
            startseq(0, MAY_PAUSE);

            /* Wait for data from RTP App */
            rspstarttimer();
            boffset(off_seqRtpDemoWait); /* feedback wait pulse */
            do
            {
                /* Check if expected results are received */
                foundData = checkRtpDemoFeedback();
                if( 0 == foundData )
                {
                    /* No feedback available.  Play dummy pulse to prevent
                       EOS errors while waiting for result */
                    startseq(0, MAY_PAUSE);
                } 

                feedbackTime = rspreadtimer();

                if( feedbackTime > rtpDemoFeedbackMaxWait )
                {
                    RtpEnd();
                    psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "Feedback timeout",
                            PSD_ARG_STRING, "getRtpDemoFrames", 0);
                }
            } while( 0 == foundData );

            /*
             * Abort scan if feedback time greater than specified value
             */ 
            if( feedbackTime > rtpDemoFeedbackMaxLast )
            {
                RtpEnd();
                psdexit(EM_PSD_ROUTINE_FAILURE, 0, "", "Feedback too long",
                        PSD_ARG_STRING, "getRtpDemoFrames", 0);
            }
        }
    }
}
