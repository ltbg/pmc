/*@Start***********************************************************/
/* GEMSBG Include File
 * Copyright (C) 1995 The General Electric Company
 *
 *      Include File Name:  grad_rf_grass.globals
 *      Developer:              T. Hlaban        Original for 5.5
 *
 * $Source: grad_rf_grass.globals.h $
 * $Revision: 1.0 $  $Date: 4/18/95 15:39:04 $
 */

/*@Synopsis
  This has global #defines for ipg & host
*/

/*@Description

*/

/*@End*********************************************************/

/* only do this once in any given compilation.*/
#ifndef  grad_rf_grass_globals_INCL
#define  grad_rf_grass_globals_INCL

/* baige add RF slots: add tracking RF (rftrk) as slot 1 */
#define RF1_SLOT    0
#define RFTRK_SLOT  1
#define RF_FREE1    2
/* baige add RF slot，Local RF count for this module (may be extended further by included headers) */

#define GX1_SLOT 0
#define GXW2_SLOT 1
#define GX_FREE 2

#define GY1_SLOT 0
#define GY_FREE 1

#define GZRF1_SLOT 0
#define GZ1_SLOT 1
#define GZ_FREE 2
#include "rf_Prescan.globals.h"

#define MAX_RFPULSE RF_FREE
#define MAX_GRADX GX_FREE
#define MAX_GRADY GY_FREE
#define MAX_GRADZ GZ_FREE

#endif /* grad_rf_grass_globals_INCL */
