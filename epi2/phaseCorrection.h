/**
 * @copyright   Copyright (c) 2019 by General Electric Company. All Rights Reserved.
 *
 * @file        phaseCorrection.h
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

#ifndef PHASECORRECTION_H
#define PHASECORRECTION_H

void playPhaseCorrectionDummySeq(void); 

STATUS phaseCorrectionLoop(void);

STATUS PhaseCorrectionPGInit(void);

#endif
