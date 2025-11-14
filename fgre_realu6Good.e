/*
 * -GE CONFIDENTIAL-
 * Type: Source Code
 * 
 * Copyright (c) 1991,2023, GE HealthCare 
 * All Rights Reserved 
 * 
 * This unpublished material is proprietary to GE HealthCare. The methods and
 * techniques described herein are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part, is forbidden except by express
 * written permission of GE HealthCare.
 * GE is a trademark of General Electric Company. Used under trademark license.
 *
 * $Source: fgre.e $
 * $Revision: 1.173 $  $Date: 8/26/98 12:26:17 $
 *  
 * Fast Multi-Planar Spoiled Gradient Recalled Database
 *  
 * Language : EPIC+/ANSI C
 * Author   : Yi Sun, Melanie Shaw
 * Date     : 03-Jun-1991
 */
/* do not edit anything above this line */

/*
   Revision Information

   Internal
   Release #  Date	Person  Comments

Release        Date	         Person      Comments
-----------------------------------------------------------------------
10.0           10/03/2001    RJF         LxMGD baseline, performance optimizations.
                                         Prior Revision comments in fgre.revhistory.old

10.0           10/22/2001    ALP         LEO1 merge into MGD baseline, picked up
                                         dualecho fgre, fiesta, and ASSET support.

10.0           03/21/2002    RJF         MRIge70702 - ASSET with multigroup fixes.
                                         MRIge73762 - Flexible XRES across all FGRE seq.
                                         MRIge73549 - unblank time reduction fixes.
                                         modularized nex computations in nexcalc()
                                         calc_xresfn re-designed to support flexible xres.
                                         stdlib.h included to provide abs prototype.

10.0           03/24/2002    RJF         MRIge73815 - improved pass time for RTIA-FGRE.
                                         RTFgre_cveval_init interface changes.

10.0           03/27/2002    RJF         MRIge73868 - improved pos_start calculations
                                         to account for longer tlead times.

10.0           04/05/2002    ALP         MRIge74073 Support for xres < 256 for dualecho.
                                         Locked TEs to fall into expected range for in-phase
                                         and out-of-phase values.

10.0           06/14/2002    AKG         MRIge75280 increased cvmin-max range for opfov to be greater 
                                         than avmin-max range. This prevents unnecessary adv popups
                                         with protocol loads.

10.0           07/26/2002    RJF         MRIge76956 - Replaced loaddabs with fgre_loaddabs to never
                                         turn off filter select for disdaqs.

10.0           08/12/2002    JAH         CARme00449 - moved mpl_predownload()
                                         from predownload to cveval. It only
                                         does calls to powermon() to optimize
                                         SAR calculations for MPL but finishes
                                         with a powermon() call without
                                         optimization to set the monitor limits
                                         This is already done in predownload
                                         by default.

               09/04/2002   GFN         Merged external triggering for FUS from Haifa code under
                                        .../fus/LATEST branch.

11.0           12/06/2002   ALP         Merged 91 and MGD..MGD2 baseline

10GX           12/04/2002   SVR         MRIge79334
                                        Round-off the calculation of rhnframes to the
                                        nearest integer.

11.0           01/17/2003   RJF         Merge of IRIX MGD2 baseline into Linux. 

11.0           02/27/2003   NU          MRIge80365, MRIge74549 -  Calculate a viable
                                        avmaxrbw based on system's maxfov and Gx strength.
                                        Round to nearest oprbw value.

11.0           03/05/2003   AMR         MRIge81284 - Additional argument phorder added to
                                        the prep_setacqparams function call. These changes
                                        are made to support BTK enhancemnets for IR-Prepped FGRE.

11.0           03/05/2003   RS          MRIge81356 - FGRET Perfusion Timestamp
                                        trigger delay Changes.

	       03/17/03     HD		merge_3TC_11.0 

11.0           03/13/2003   RS          MRIge81741 - perf_tdel_id is to be disabled for FGRE cardiac gating

11.0           04/07/2003   RS          MRIge82596 - FGRET TDEL order within pass

11.0           03/21/2003   NU          MRIge81613 - apply rotation matrix in aps2 nad mps2 when 
                                        RTIA scan is performed.
               04/01/2003   HD          MRIge82338 - Selecting two echos gives
	       				rBW error. Added check for field in
					error check. 

11.0           04/17/2003   AP          MRIge82807 - Asset cal fov is fixed for hrbrain coil
                                        MRIge82713 - Lockout 2_BREAST coil with asset

11.0           05/05/2003   PL          MRIge82401 - Use SLICE_FACTOR to increase
                                        the maximum no. of slices to 1024 for FIESTA.

11.0           05/09/2003   RJF         MRIge83750 - minFOV is a function of maxcoilFOV for ASSET.

11.0           05/28/2003   AK          MRIge79640 - TE annotated for fractional NEX cases with FGRE-ET
                                        (real_te) was different from act_te. Now TE annotation is based 
                                        on act_te for all cases.

11.0           05/28/2003   AK          MRIge78396 - Set max of slquant1 to 512 to prevent dwnl. failures
                                        with Seq. Multiphase scans with 512 phases.

11.0           06/02/2003   RS          MRIge81136 - Greyed out Locs B4 Pause when acqs=1. This is a generic
                                        change to take care of fgre related features, such as fiesta, fastcard

11.0           06/04/2003   AK          MRIge73779 - Moved rtca slider initialization code after cveval1()

11.0           06/02/2003   LS          MRIge84881 - to ensure dual-echo gets correct
                                        TEs 1) using MINPH_RF_RTIA RF pulse for all cases
                                            2) change rbw to 125kHz if xres > 300.

11.0           05/05/2003   GFN         MRIge81356, MRIge81678, MRIge81741,
                                        MRIge82596 -
                                        Removed perf_tdel_id definition from
                                        the @rspvar section.  This is already
                                        defined in epic.h and is causing
                                        compiler warnings.  Moved the code
                                        that sets this variable to Echotrain.e
                                        as the functionality is specific to
                                        this module.

11.0           06/11/2003   PL          MRIge85021 - Use SLICE_FACTOR to increase
                                        upper limit of rhnslices to 1024 in all cases

11.0           06/30/2003   RJF/AK      MRIge85105, MRIge85585, MRIge85608, 
                                        MRIge85640 - Initialize Fov, Sl. Thickness & Flip Angle
                                        for RTIA & non-RTIA cases before calcOptimizedPulses().
                                        But set the slider values based on minfov, minslthck 
                                        only after calcOptimizedPulses(). 

11.0           07/11/2003   AMR         MRIge86472 - Increase in the maximum possible slthick
                                        possible with FGRE from 20mm to 100mm. New constant
					FGRE_MAXTHICK will be in effect, rather than MAXTHICK.

11.0           07/22/2003   AK          MRIge86274 - Lock out Asset Cal with non-Axial Planes.
                                        MRIge86251 - Open up pFOV selections in steps of 0.1.

11.0           09/08/2003   RKS         MRIge78873 - Limit NEX < 4 when CCOMP = 1.

11.0           10/08/2003   RS          MRIge89001 - Changed the NEX pull down value for CCOMP
                                        prescription that it does not have odd value.

11.0           10/21/2003   RB          MRIge89250 - Introduced new CV pw_gxwlex to minimize
                                        the ghosting in assetcal scan.

12.0           12/19/2003   AN          MRIge90145 - Added support for continuous IR for RTIA.
                                        Includes ability to use a different phase ordering
                                        method for acquisitions using IR vs. without IR, and
                                        allows lower resolution for PFO imaging.

12.0           01/15/2004   ZL          MRIge90793 - Added support for SPECIAL Fat SAT
                                        in 2D FIESTA.

12.0           01/27/2004   AN          MRIge90954 - Changed calculation of rhhnover to include
                                        asset_factor for FIESTA scans.

12.0	       03/03/2004   HAD         MRIge91445 - Enable Type in TE for 2D FGRE
                                        sequences.

12.0           03/19/2004   RS          MRIge91882 - 3Plane changes 

12.0           03/24/2004   HK/AK       MRIge91352 - SAR/dbdt changes for E3.

12.0           04/02/2004   ZL          MRIge91361 - add combined PURE and ASSET calibration 
                                        scan PSD code for E3. This would be a 2 phases scan, 
                                        first phase is surface coil acquisition, the second 
                                        phase is body coil (or volume coil mode for the phased
                                        array coils that has volume receive capability such as
                                        the T/R PA knee coil) acquistion. The data acquired in
                                        first phase will be used for both ASSET and PURE recon
                                        and data acquired in second phase will be used for PURE
                                        recon.

12.0           04/08/2004   ZL          MRIge92364 - fix scan clock error for fsfiesta2D with
                                                     MPH option
                                        MRIge92365 - negative spacing is not allowed for 
                                                     Fiesta2D if SPECIAL fatsat is not on. 

12.0           04/07/2004   ATV,        MRIge91751 - Corrected minph_iso_delay calculation and 
                            SXZ,        fermi filter settings.  Following modifications are only   
                            HKC         for 3T dual echo: 1) Decreased minimum rBW from 125.0 to 
                                        50.0.  2) Added automatic rBW calculation (indirectly  
                                        depends on opxres) and locked rBW field out on scan screen.   
                                        3) Opened allowed opxres from multiple of 32 to multiple  
                                        of 4 and opyres from multiple of 32 to multiple of 2. 
                                        4) Increased maximum opxres from 320 to 512.  5) xres  
                                        pull-down menu values are now tailored to most often used 
                                        values.  The above changes are merged from G3.  
                                        MRIge92350 - Following are newly introduced for 12.0:  
                                        1) Implemented the automatic rBW calculation for 1.5T dual 
                                        echo with similar algorithm as for 3.0T dual echo.  2) For 
                                        dual echo, 1.5T check is removed from any previous TE and 
                                        TE2 calculation and rBW limitation.  3) Opened opxres and 
                                        opyres to allow multiple of 2 for all FGRE applications.

12.0           04/08/2004   RDP         MRIge91983 - Inclusion of rotatescan to allow arbitrary
                                        scan plane rotation through CVs.

12.0           04/09/2004   AMR         MRIge92386 - Changes for Asset enhancements for Excite-III

12.0           04/24/2004   ZL          MRIge92895 - check dbdt level to insure shorter TR for first 
                                        control level for FIESTA

12.0           04/28/2004   HKC         MRIge92430 - 1) Added a check for a case when TE increases
                                        with rBW to output the rBW with lowest TE in auto-rBW
                                        calculation.  2) Added a condition for setting TE2 to lower 
                                        limit for second out-phase; TE2 should be less than the
                                        lower limit for second out-phase (as well as being greater
                                        than the upper limit for first out-phase) to be set to
                                        the lower limit.  3) Added a flag to check if opfov is 
                                        greater than avminfov only after auto-rBW calculation is 
                                        completed for dual echo.  The above changes are merged from
                                        G3.  These changes fixed download failure with small FOV and
                                        small slice thickness (MRIge92900).  

12.0           05/05/2004   HKC         MRIge92915 - For dual echo, tailored flip angle pull-down menu 
                                        to most often used values.

12.0           05/07/2004   HKC         MRIge92503 - 1) Set an upper limit of rBW range used in auto- 
                                        rBW calculation to depend on FOV prescribed.  2) Added separate
                                        min. FOV error message for 1.5T and 3.0T dual echo. The default
                                        error message asks user to change either FOV or rBW. With the
                                        current dual echo implementation rBW can not be changed by user.
                                        3) Decrease minimum opxres from 256 to 128 for 3.0T dual echo.
                                        4) For dual echo, tailored FOV pull-down menu to most often used
                                        values.  5) Set the minimum FOV displayed to be the minimum with
                                        minimum rBW to get rid of confusion of minimum FOV changing as
                                        user changes FOV (due to change in "best" rBW from auto-rBW).  

12.0           05/10/2004   RS          MRIge93435 - Made explicit description for the receiver bandwidth
                                        for IR-FGRE 3-Plane prescription to take care of some workflow
                                        issues of selecting RBW values for the new series.

12.0           05/12/2004   HAD	        MRIge93256: Fix for Download failures related to improper resolution 
                                        being reset in the rfpulseInfo table. This happened when dbdtlevel_opt
                                        checks called calcoptimized pulses multiple times.

12.0            05/13/2004  RS          MRIge93374, MRIge93375,MRIge93379 - RBW changes for the 3-Plane workflow

12.0            05/21/2004  ZL          MRIge92367: pioverlap is set to 1 for fsfiesta to allow negative spacing.

12.0            05/17/2004  ZL          MRIge93610: changes to make PURE calibraiton scan
                                        work with the US TR Knee PA coil.
12.0            05/17/2004 HKC          MRIge93639: Allowed xres is now multiples of 4.

12.0            05/26/2004  ZL          MRIge93811, MRIge93805:  
                                        initialize_rfpulseInfo() function is moved from
                                        set_slice_select_params() to cveval() so that the prep 
                                        pulse (irprep, deprep), chemsat pulse and prescan pulse
                                        are only scaled once. Only thing remained scaled during 
                                        the iteratio of dbdt optimization is the rf1 pulse. This 
                                        solves the download failure caused by pw and res mismatch
                                        of these prep pulses after multiple stretch.
12.0            06/09/2004  NDG         MRIge78133: Asset cal problem when coil is changed from 8HR to 8NV Array.

12.0            16/06/2004  RS          MRIge93291: Multistation imaging option is disallowed for 3-Plane,
                                        however, the Multistation code base is maintained, in case, if it
                                        is to be patched for any requirement.

12.0            21/06/2004  AMR         MRIhc00484: Lock out multiple NEX
                                        prescriptions with  ASSET
					

12.0            23/06/2004  RS          MRIhc00943: Added 3-Plane specific check (ThreePlaneCheck())
                                        to prevent type-in of imaging options not supported by 3-Plane

12.0            01/07/2004  ZL          MRIhc01113: unlock fov for calib scan
                             
                06/24/2004  AP          MRIhc01063 - Removed slice ASSET lockout since in excite III
                                        phase asset and slice asset can be separated based on Asset.xml

12.0            07/15/2004  ZL          MRIhc01471: removed oppos check for ASSET scan and the 
                                        combined calib scan since it is checked by host.

12.0            27/07/2004  RS          MRIhc01424: FOV pulldown is floored down to prevent the
                                        first decimal value passed to scan

12.0            08/03/2004  HKC         MRIge84855: If zero is typed in slice thickness field, 
                                        exist(opslthick) = FGRE_DEFTHICK and opslthick = 0.  
                                        In this case, use the rf for thinner slice to calculate 
                                        the minimum slice thickness so that the correct advisory 
                                        pop-up value gets displayed. 

12.0            08/20/2004  HKC         MRIhc02807: Only for 3T Whole Mode DualEcho, default SAT 
                                        thickness was 80.  With proper SAT rf stretching, SAT 
                                        thickness of 80 produced ghosting artifact.  Therefore, 
                                        default SAT thickness for 3T Whole Mode DualEcho was reduced
                                        to 40, which is default for all.

12.0            09/03/2004  HKC         MRIhc03165: Minimum slice thickness for 3T ASSET calibration
                                        is set to 5.0 mm to avoid getting fractional echo acquisition.
                                        If we get fractional echo with slice thickness greater than 
                                        or equal to 5.0 mm, display the error message asking user to 
                                        increase the slice thickness (this check is extra safety net). 
                                        
12.0            09/10/2003  LS          MRIhc01446: scan controls the freq-phase encoding direction
                                        now, so remove the piswapfc and opspf checking code for calibration
                                        scan.
12.0		09/10/2004  LS          MRIhc02932: turn off pure filter for tof mode.

                09/10/2004  RDP         MRIge90568  Turning off phase encoding with CV "nope".

12.0            09/21/2004  LS          MRIhc03496 - set default FOV for calibration scans 

12.0            09/22/2004  HKC         MRIhc03566: Minimum slice thickness for 1.5T calibration is set
                                        to 5.0 mm to avoid getting long scan time.  Removed slthick values
                                        < 5.0 mm in pull-down menu.
12.0            10/28/2004  RS          MRIhc00330:Changes for 3-Plane signal overrange

12.0            10/06/2004  LS          MRIhc03943: Remove field strength check for 
                                        PURE calibration scan 
12.0            10/29.2004  RS          MRIhc04425: Derated Fiesta 3-Plane to 80% for FDA and IEC modes to
                                        reduce PNS effect

12.0		11/03/2004  ARI		MRIhc03524: Don't need to play ccsrelaxers after PAUSE. 
					Corrected scantime calculations for concat-sat multi-acqs scan. 
					Removed concat-sat relaxers (if) after a PAUSE.
 
12.0            12/03/2004  ARI  	MRIhc04613: Corrected scantime calculations for multi-acqs scans 
					with SpSat pulses for a special case. When number-of-slices-in-
					last-acq (say 7) divided by "slq_per_spsat" (say 4) is less than 
					"satcount" (say 3), then 1 extra "sp_sattime" is included in "pitscan" 
					calculations but there is no SpSat to play.

12.0            12/13/2004  RS          MRIhc05335: Prescan optimization

Value1.5T       02/21/2005  YI          FIESTA-C Enhancement: Supported OPEN phase cycling(APC and SGS.)
Value1.5T	02/25/2005  MM		YMSmr06515: Number of slice locations expansion.
Value1.5T	03/31/2005  KA		FSFIESTA Enhancement: Supported RTG and multi shot SPECIR.
Value1.5T	04/02/2005  YI		Supported Auto Voice.

14.0		04/06/2005  HAD		MRIge73669: Enable one etl for FGRE-Echotrain

14.0		04/29/2005   LS		MRIhc07150: Code for MERGE feature & feature flag for MERGE. 
Value1.5T	05/11/2005  YI		Supported rect FOV(SqP/phase FOV) with NPW.
Value1.5T	05/16/2005  YI		Added de-rating for FIESTA with HFD-S-lite.

12.0            05/04/2005  SXZ         MRIhc07209: Use the new CFH method 
                                        (non-selective IR-PRESS) only when:
                                        (1) gated; (2) local shim volume exists;
                                        (3) fiesta.

14.0            05/17/05    ZL          MRIhc06773: calscan fov needs to be fixed in clinical mode
14.0            05/17/05    ZL          MRIhc06775: needs more choice for calscan resolution

14.0            05/27/05    ZL          MRIhc07629: cal scan only allows one echo.

14.0            06/14/05    SVR          MRIhc07934: Implement SWIFT reference scan.

14.0            06/15/05    LS          MRIhc07869, 07973: 1) added auto minTR support for MERGE;
                                        2) parameter limits for MERGE; 3) minTR timing correction
                                        for MPL with Sat cases.

14.0            06/16/05    ZL          MRIhc07918: calscan could accept fov of 0 of negative
                                        values. remove the setexist(opfov,PSD_ON) call, so that
                                        when 0 or negative values is entered, scan could catch it.
14.0            06/24/05    LS          MRIhc08165: RBW needs to be >=100kHz for obl Sag or Cor for
                                        2D MERGE at 3T.

14.0            06/27/2005  ZL          MRIhc08223/MRIhc08009: For Multi-Phase Scans do not
                            HAD         play/account for delay time after last acquisition.
                            AP

14.0            06/29/05    LS          MRIhc07869: added max_seqsar in mpl_rfscale;

14.0            07/11/05    LS          MRIhc08474: check for MERGE option key. 

14.0            07/11/05    SVR         SWIFT reference scan modified to use
                                        switchselect instead of pure_coilswitch.
Value1.5T       07/19/05    HK          YMSmr07350: turn off torch1 recon for Value1.5T.

                                        
14.0            07/27/05    LS          MRIhc08933 -- R2* support 

14.0            07/29/05    LS          MRIhc09004 -- R2* bug fix: rhrawsize was calculated 
                                        based on opnecho in loadrheader.
                                        it has to be fixed for r2 feature to use 
                                        rhnecho=opnecho*intte_flag, where intte_flag is # 
                                        of echotrain shots.
14.0            07/27/05    LS          MRIhc08981  ASSET calibration slice minimum quantity should be >= 2.

14.0            08/19/05    LS          MRIhc09416 - increased scansetup_wait temporaryly to avoid EOS error for
                                        calibration scan.
Value1.5T       09/12/05    YI          YMSmr07697: Added initialization for realtime FGRE-ET in mps2 and aps2.


12.0		09/09/2005  AP		MRIhc09984:Increased Crusher area for SPGR when TR greater or
					equal to 100ms and flip greater than or	equal to 50. This was done
					to better crush residual magnitization.    

14.0            09/09/05    ZL, HKC     MRIhc10154 - high resolution calibration scan (64x64) for 3T 8 ch. 
                                        breast coil for better 3T VIBRANT PURE correction; others are 32x32.

14.0            10/12/05    HKC         MRIhc10884 - Removed 32x32 condition for calibration scan fermi filter 
                                        setting.  Now, 64x64 calibration scan will have same rhfermr and rhfermw 
                                        as 32x32 calibration scan.  Removed "GE_HD2 Breast" coil check for high 
                                        resolution calibration flag.  Type-in PSD "cal32" can be used to go back
                                        to 32x32 calibration scan for "GE_HDx Breast" coil.

14.0            12/13/05    LS          MRIhc11552 - Changed min RBW for sagittal MERGE from 100 
                                        to 62.5 kHz.

14.0            02/07/06    CRM         MRIhc13033 - Add SwiFT support for single connector PV Coil using scn
                                        provided biasEnable and switchSelects.

14.2            04/12/06    ARI         MRIhc14923 - Remove GRAM model.

HDv             06/22/06    TS          MRIhc16194: coilInfo related changes

14.2            07/10/06    ARI         MRIhc16496 - Change minseq() function interface.

HDv             07/10/06    TS          MRIhc15304: Changes for HDv to change coil by changing
                                        hubindex using SSP packet

20.0            08/24/06    LS          MRIhc17232 - changes to support multi-echo fgre/fspgr for DVMR.

14.2            09/08/06    ARI         MRIhc18055 - Remove pgen_debug flag.

14.2            09/25/06    HH          MRIhc18402 - Force Normal(cfdtper=80) and Rectangular 
                                        reilly_mode for all 3-Plane acquistions.

20.0            09/26/06    CRM         MRIhc18622 - Updated to use Asset.e

14.2            10/17/06    ALI         MRIhc18780 - Added min_tessp variable in mintefgre function. This 
                                        calculates the minimum time for the execution of SSP packets from 
                                        the mid of rf1 to the center of echo.  

14.0            10/30/06    HKC         MRIhcc18622 - Replaced minimum FOV setting for ASSET scans with 
                                        Asset.e AssetMinFOV section, for consistency; content is essentially
                                        the same.

20.0            11/27/06    LS          MRIhc18518 - check for Multi-Echo Fgre option key (mfgre2d).

14.2            11/23/06    UN          MRIhc15935 - For ASSET CAL at 3T and for weights less than 25kg, use
                                        rfb1opt_flag=1.This is a temporary fix. Will have to revisit this 
                                        once we have B1 derating based on coil and weight

14.2		12/08/06    VAK		MRIhc20775 - Scan time difference observed with multiphase option

14.4            12/13/06    VSN         MRIhc20930 - Added cable,busbar,gpm and min_seqgrad for RTIA.

14.4            01/10/07    ZL          MRIhc20334 - add an interslice crusher for fiesta to remove the 
                                        residual transvers magnitization before next slice acquisition 

20.0            02/06/07    ALI         MRIhc19872 - Updated mpl_powermon and mpl_rfscale
                                        function calls for new arguments.

20.0            01/25/07    VAK         MRIhc16225 - Removing a check from endview fucntion call and 
                                                     making the change in fgre.e

14.0	        01/31/2007  HAD  	MRIhc18659 Added support for PEDiatric SAR model for 3T TRM.

20.0            03/22/07    SWL         MRIhc21901,MRIhc23348, MRIhc23349 - new BAM model supports 
                                        multi phase, dynaplan phase, and requires less input arguments 
                                        in maxslquanttps().
20.0            06/27/07    JH          Added assignment of wg_gxwex to XGRAD/XGRADB depending on bridge 
                                        value. 
                            ALI
                            HKC 
20.0           06/27/2007   LS          MRIhc24436, MRIhc20970: Supports for displaying grayed out fields: 
                                        TE/TR/TI/RBW.

20.0           10/18/2007   ARI         MRIhc27045: Adding rcvn name to entry point table.

20.0           11/21/2007   RKS         MRIhc29155 - Gatted TOF vessel signal can be increased by reducing the
                                        minimum delay. Easiest option is to reduce the DDA from 4 to 2. Volunteer
                                        scans confirm the signal enhancement without any IQ impact

20.0           11//21/2007  RKS         MRIhc29136 - Since spatial sat is not played out during DDA of gated TOF,
                                        fmpvas_cveval() should provide spsattime to calculate delay times correctly.



20.0           11/09/2007   KA          MRIhc28777: Implemented multiple breathhold cal.
                                        Also cal uses the auto min TR feature.

20.0           12/25/2007   KA          MRIhc28777: Locked out multiple breathhold cal in clinical mode.

20.0           12/26/2007   ALI         MRIhc30481 : Corrected FOV_INC calculation for dual echo mode, replaced 
                                        avminfov with temp_fov since this is the min FOV used. 
20.0           01/30/2008   RKS/SW      MRIhc32691 : Before calcOptimizedPulses(), phase encodes should be rescaled
                                        to the maxmum amplitude

20.0           02/13/2008   KA          MRIhc33034: should use opslicecnt instead of slicecnt to know if
                                        user wants scan pause.

15.0           05/20/2008   VSN         MRIhc35847: AutoMinTR with iterative b1opt causes UI slowness for FGRE-CAL.
                                        Disabled AutoMinTR for FGRE-CAL.

15.0           08/12/2008   RKS         MRIhc39371 - enaable ASSET support for fast TOF

15.0           09/27/2008   VAK         MRIhc39805 - Scan time was not correct for MFGRE when Concat Sat is ON

20.1           11/04/2008   XZ          MRIhc38955 update TE min and max value check.

20.1           02/04/2009   XZ          MRIhc41871 increase area_killer in slice and freq direction to remove the artifact

20.1           02/04/2009   XZ          MRIhc41878 Remove the misdisplayed NEX = 1 when NPW is turned on for MFGRE

20.1           02/20/2009   XZ          MRIhc42193 Scale flow encoding gradients in predownload for FastcardPC so
                                        syscheck will give accurate minTR

20.1  	       04/23/2009   RKS         MRIhc43102 2dfiesta violated dB/dt in normal mode. Root Cause - Although the z-gradients
                                        were modified by rfsafetyopt(), pidbdtper reflected dB/dt with the earlier waveforms. Fix is to
                                        ensure that CVs changed flag is set to TRUE before calcOptimziedPules() if the waveforms were
                                        modified by rfsafetyopt()

20.1           05/04/2009   RKS         MRIhc43102 Since rfsafetopt() modifies the derating scale factor between 1.0 and the desired 
                                        derating, there is a sync issue of catching avminslthick.  Because of this, advisory message with
                                        thickness allowed for bw_rf1 = 1 and also with a wider bw_rf1 are presented.  Promote fixes this
                                        conflict with thickness on advisory

21.0           03/31/2009   ZZ          MRIhc44092 Implement MR-Touch feature

SV             06/05/2009   KA          GEHmr01622 - Fat Sat and MinTE support for multi echo FGRE.

SV             07/16/2009   KA          GEHmr01718 - derate gy1 as much as possible to reduce ghost due to eddy
                                        current with MFGRE MinTE. Keep gy1r without derating to avoid impact on minTR.

21.0           08/11/2009   JX          MRIhc44695 Limit asset cal Z coverage

22.0           08/19/2009   VSN         MRIhc44866 - Moved local declaration of fnecho_lim to epic.h       

SV             10/01/2009   Lai         GEHmr02638: Support smart derating in SV to shorten TR when min_seqgrad is dominant.

SV             10/14/2009   Lai         GEHmr02676: Changed smart derating logic to update waveform (run smart_derating())
                                        only once during dbdt optimization.

SV             10/16/2009   MH          GEHmr02859: Enable to include sat pulse in PGOH to get more accurate min_seqgrad

SV             10/22/2009   KA          GEHmr02793: For MFGRE, turned off gradOpt_TE and gradOpt_RF to keep 1st TE as short as possible.
                                        Also set gradOpt_GX2derating_limit to 0.8 to minimize impact on echo spacing. This alleviates
                                        ghosting artifact observed on later echo images.

SV             10/22/2009   MH          GEHmr02868: Added limit check for ogsf* parameters to avoid download fail.

SV             11/06/2009   Lai         GEHmr03238: gradOpt_pwrf1 should be updated each time.

SV             11/10/2009   MH          GEHmr03274: When fgrespt is used, smart derating was set to OFF.
                     
22.0           11/15/2009   RBA         MRIhc42465 - Changes for PIUI

22.0           11/16/2009   ALI         MRIhc46175 Cine IR feature promote

SV             11/16/2009   MH          GEHmr03345: UserCV16 and 17 are set to default value to avoid download fail

SV             11/17/2009   MH          GEHmr03275: Corrected ChemSat start position and pos_start in PGOH 
                                        when SpSat or ChemSat is selected.

SV             11/20/2009   KA          GEHmr01949: Prohibitted MFGRE fractional echo with alternating gradient
                                        until the Functool issue is resolved.

SV             11/20/2009   KK          GEHmr03378: Added ChemSat to PGOH with Gating

22.0           12/31/2009   VSN/VAK     MRIhc46886 SV to DV Apps Sync Up

22.0           12/31/2009   XZ          MRIhc46434 fix cveval error for fgretc

22.0           12/31/2009   XZ          MRIhc46888 enable fatsat and MinTE Option for MFGRE

SV             01/20/2010   MH          GEHmr03608: Set avmaxte for manual input of MFGRE and 
                                                    corrected avmaxte when CV17 is ON.

22.0           01/22/2010   SW          MRIhc47297: Include cssattime and spsattime in min_seqrfamp, 
                                                    max_seqsar for MPL mode

SV             01/28/2010   MH          GEHmr03549: Added to set minimum oprbw2 and maximum oprbw2 to 
                                                    avoid download fail.

SV             02/04/2010   MH          GEHmr03780: Set rhtype correctly for Inh-2DIF with zerofill and MFGRE+MINTE.

22.0           02/17/2010   SW          MRIhc47789: Move opslquant<avmax_asset_slquant check for calibration scan from 
                                                    cveval() into cvcheck().

22.0           03/03/2010   RKS         MRIhc46944  Enusre that ART is disabled for dual echo

22.0           04/05/2010   LS          MRIhc48581  3d gradwarp should be disabled if 1) MPh (not dynaplan); 2) card gating
					and opaphases >1. Set pi3dgradwarpnub to 0 for those cases for host to grayed it out. 

22.0           04/07/2010   ZZ          MRIhc48883  Increased time_ssi based on firmware recommendation

22.0           04/14/2010   XZ          MRIhc49158  LX FGRETC Key on perfusion, fgretc and realcard

22.0           04/15/2010   LS          MRIhc48580  Added control of 3d grad warp checkbox visibility. 

22.0           04/29/2010   AE          MRIhc49539: check current nucleus against coil DB
                                        to prevent switching to MNS coils.

22.0           06/04/2010   ALI         MRIhc49946: Cine IR option key check 

SV             07/09/2010   MH          GEHmr04246: SV supports AC model to improve performance.

SV             07/09/2010   KK          GEHmr04246: Merged MRIhc47297 for FGRE AC model which does not include SAT in PGOH.

SV             07/14/2010   MH          GEHmr04246: set chemsat_killer_target to 2.8[G/sm] for AC model.

SV             08/11/2010   Lai         GEHmr04288: 1) remove a_gxw*a_gxw*pw_gxwd/3.0 from gradOpt_powerTR when bridge is on;
                                                    2) set gradOpt_gxwex to 1 to avoid oscillation of gradOpt_noGxwex.

SV             08/11/2010   Lai         GEHmr04367: gradOpt_pwrf1 is updated only when rfsafetyopt_doneflag is off.

22.0           09/02/2010   XZ          MRIhc52625: Update the Calc of tmin_total for realtime applications

22.0-reli      09/30/2010   SW          MRIhc52980: Turn on the existflag explicitly when Square Pixel is on. 
                                        Clone from MRIhc52845 in 23.0.

SV             10/14/2010   Lai         GEHmr04583: with smart derating and bridge, ensure area_gxwex is bigger than area of gxwd.

SV             10/21/2010   Lai         GEHmr04620: to fix code bug casued by GEHmr04583 modification.

SV             10/26/2010   Lai         GEHmr04636: Disable smart derating when searching oprbw for Dual Echo;
                                                    Limit minimal value of ogsfXwex to 0.1

23.0_Integ     11/19/2010   XZ          MRIhc52421: Implement FGRE Turbo mode to meet Marcket DataSheet Claim

22.0_RELI      12/08/2010   XZ          MRIhc53613  Update FGRE/EFGRE3D/EPI2/FSEMASTER for spec mode

23.0           12/07/2010   UNO         MRIhc53578: ART support for MR750w.

23.0             12/27/2010   ALI         MRIhc54321: Realtime FIESTA enhancement.

23.0           01/06/2011   XZ          MRIhc54399 Increase Crusher area in Z and X direction to remove the zipper artifact

23.0           03/22/2011   XZ          MRIhc55352 Fix autoTI error for fgret timecourse

23.0           03/25/2011   YS          MRIhc54088 Corrected gradient scaling

SV             04/14/2011   Lai         GEHmr04868: - set reilly_mode to 0 and use rectangular model for 2D Fast PC dBdt optimization

23.0           04/15/2011   XZ          MRIhc56128 Fix error in min/max rbw restriction change when switching between different applications

22.1           04/15/2011   ALI         MRIHc56152  ensures opte is in range and same as act_te for opautote = 1, 
                                        Also corrects advisory error for #slices in Cal scan. 

23.0           04/19/2011   SW          MRIhc55738 Use ADVISORY_FAILURE instead of FAILURE for calibration scan to avoid the workflow issue
                                                    - fix code bug to set ia_gy1 and ia_gy1r

23.0_Integ     05/05/2011   MH          MRIhc56786: Support smart derating on CAL, FIESTA, MERGE and MFGRE. 

23.0           05/10/2011   XZ          MRIhc56846: Fix MinTE calculation caused by wrong usage of IMax() for FGRE.

23.0           05/31/2011   XZ          MRIhc57089: Fix a potential bug that causes avmintscan overflow

23.0           06/16/2011   MH          HCSDM00076721: Removed enablfracdec==OFF for xres/yres=512, EDR on and NPW on.

23.0           06/24/2011   MH          HCSDM00077033: opuser16 should not accept fload value.

23.0           07/29/2011   MH          HCSDM00078917: put smart_derating() before graOpt_mode=0 calculation to avoid mis-calculation

23.0           08/04/2011   MH          HCSDM00090513: turned dbdtlevel_opt OFF to reduce calculation time for FIESTA

HD23           07/29/2011   SS          HCSDM00088901,HCSDM00102823.  Change rf unblank time to HD specific CV - rfupacv. Also see HCSDM00102823 for related promote.

HD23           Aug/03/2011  SS          HCSDM00089890 - set flag to call cveval1 again in fgre

HD23           Aug/16/2011  SS          HCSDM00084917 - MR Touch UI changes specific to 1.5T HD systems

HD23           Oct/19/2011  SS          HCSDM00095097 - remove AutoTR for HD ASSET and change crusher areas to HD16 values. See MRIhc35847 for 15.0 promote on this issue.

23.0           09/09/2011   MH          HCSDM00078917: turned gradOpt_RF and gradOpt_TE off and added the code to keep minimum FUll TE
                                                       for 750w system

23.0           10/09/2011   Lai         HCSDM00102521: Update cfxfd_power/temp_limit by modify CVs xfd_power/temp_limit

23.0           10/11/2011   Lai         HCSDM00102590: - Make Smart derating work well with B1 optimization (rfb1opt==2)
                                                       - To support pseudo convergence to avoid oscillation

23.0           10/17/2011   MH          HCSDM00100110: changed rfb1opt_flag to 2 for calibration scan with low weight to avoid memory shortage.

23.0           12/20/2011   Lai         HCSDM00114077  Set big tolerance for pseudo convergence when InPh or OutPh is set.

23.0           02/01/2012   Lai         HCSDM00115164: initial promote to support Smart Burst Mode in 2D FIESTA
                                                       and 2D Fat Sat FIESTA

23.0           03/May/2012  WXC         HCSDM00132376  Do not set big killer area when the protocol is for limit parameter check.

23.0_VO2       01/06/2012   XZ          HCSDM00112806: promote option key check for smart gradient optimization (smart derating) support. Smart  
                                                       Gradient Optimization is support on 450w/750w/GEM system only

23.0_VO2       01/18/2012   ZZ          HCSDM00116092: 1.5T MR-Touch UI and MENC annotation update

23.0_V02       03/01/2012   SW          HCSDM00125756: recon scale factor fix for Cine IR, MDE FGRE Perfusion.
                                                       It is cloned from HCSDM00120762.

24.0           Aug/08/2012  SR          HCSDM00149958: PSMDE feature promote

24.0           Sep/07/2012  SW          HCSDM00157485: Change HARDRF to FERMI124 in FGRETC

24.0           Sep/28/2012  AE          HCSDM00157626: inserted call of PScveval() before
                                        dbdtlevel_and_calcoptimize() to update CFL RF 
                                        pulse prior to pulse stetching

24.0           Oct/11/2012  MK          HCSDM00157147: Set the default value of min/maxTR for In-Range TR

24.0           Oct/26/2012  MK          HCSDM00157418: Fixed avmaxslquant for calibration to be avmax_asset_slquant

23.0           Oct/31/2012  SW          HCSDM00166601: Add userCV20 for fermi_rc setup.  

23.0_SP7       Nov/07/2012  XZ          HCSDM00169098: Type in PSD to enable user option to update flip angle for 2DMerge

24.0           Mar/13/2013  SW          HCSDM00190857: 2DMERGE enhancement (AutoFA and NewRF pulse)

24.0           Mar/19/2013  SW          HCSDM00191946: Opuser19 fix for 2DMERGE

24.0           Apr/02/2013  TAC         HCSDM00186957: Changes for 3D Calibration feature

24.0           Apr/05/2013  SW          HCSDM00195183: Set opuser8 to default value when switch from
                                                       2DMERGE to 2DMFGRE

24.1           Apr/24/2013  XZ          HCSDM00198504: Enhance T1w contrast for fspgr 

24.0           Jun/21/2013  SW          HCSDM00206422: Scale rotation matrix for realtime in fgre.e and unscale it in
                                                       RTIA.e to avoid wrong rotation matrix in first TR

23.0           03/13/2012   BW          HCSDM00126289: MR touch TR time calculation and changed MR touch to AC model

23.0           13/Mar/2012  WXC         HCSDM00126068  Change gradHeatMethod to TRUE for 2DFIESTA RealTime to avoid under voltage issue.
                                                       Limit gradient amplitude for Fiesta RealTime to 2.2 G/cm for 16Beat system.

23.0           01/11/2013   Lai         HCSDM00178991: increase max_area_gxwex and max_area_gzk to 3000 to weaken MERGE's fineline artifact .

24.1           Oct/04/2013  JX          HCSDM00241026: Fix incorrect advisory popup for fgre localizer 

25.0           Sep/18/2013  AS          HCSDM00241267: 2D Dual Echo 3T needs PSD changes to catch 1st out of phase TE

23.0           Nov/18/2013  SR          HCSDM00230167: corrected the issue of split TE decay curve with Starmap

25.0           Nov/26/2013  JM          HCSDM00251643: Syncup from HD23.0

25.0           Nov/6/2013  AS           HCSDM00247289: Update necho-related gradient values in cveval

25.0           Dec/04/2013  ALI         HCSDM00254106: MDE enhancement: Adiabatic tan prep pulse
                                                                        Asset R = 1 with multinex compatibility
25.0           Dec/06/2013 AS           HCSDM00254376: Added EM_PSD_DE_RX_OUT_OF_RANGE

25.0           Jan/2014    ALI/MJ       HCSDM00262316: MDE Plus Feature promote

25.0           Mar/07/2014 ALI          HCSDM00270678: updated location of pitres calculation

25.0           Mar/13/2014 ALI/MJ       HCSDM00273206: Disable 0.5 NEX, minTE for SSHMDE in clinical mode. 
                                                       Enable SSHMDE on 3T in research mode. 

25.0           Mar/28/2014 KK           HCSDM00272946: Rounded up target rise time for smart derating.

25.0           Apr/25/2014 ABS          HCSDM00282845: Adding temporal resolution (pitres) display in UI for
                                                       FastCINE. 

25.0           Apr/28/2014 ALI          HCSDM00279504: Sets coredda to 2 for SSHMDE, changes usercv22 name to 'Enhanced IR Prep'
                                                       fixed #phases issue with research mode in SSHMDE at 3T.

25.0           May/09/2014 ALI          HCSDM00286735: Enable Single Shot FIESTA MDE on 3T. 

25.0           May/21/2014 MJ           HCSDM00289382: Enable Fast SPGR readout for CINE IR, Single Shot SPGR MDE at 3T,
                                                       PSMDE with ARC, ASSET R<=1.5 with multiple NEX MDE

PX25           Apr/22/2014 YT           HCSDM00282488 : Added support for KIZUNA gradient thermal models

PX25           Aug/11/2014 MHI          HCSDM00304469 : Eliminated Realtime feature from the compatibility of spgr_enhance_t1_flag.

PX25           Jul/25/2014 YT           HCSDM00289004 : support APx for breathhold scan
                                                        support sequential acq order in 2DFGRE
                                                        calculate max xres in dual echo for APx

PX25           Sep/05/2014 YT           HCSDM00309738 : In Realtime scan, search rotation matrix with highest duty
                                                        at the final cveval1()

PX25           Oct/01/2014 YT           HCSDM00314405 : force Xres in calc_xresfn to be multiple of 4

25.0           Oct/29/2014 MJ           HCSDM00312332: Corrected maximum trigger delay calculation (avmaxtdel1)
                                                       for 2D MDE

PX25           Dec/04/2014 YT           HCSDM00322828 : Introduced In-flow signal reduction for FSPGR and 2D Dual Echo

PX25           Jan/21/2015 YT           HCSDM00320204 : removed cvoverride of opxres and opyres by avmin/max in cveval()
                                                        to activate advisory error in cvcheck()

PX25           Jan/21/2015 YT           HCSDM00320203 : Removed codes for BW reset in set_rdout_params_te_and_tmin()
                                                        because BW is optimized in setPulseParams() for Dual Echo.
                                                        Also, added condition of 1st echo for BW increment
                                                        because sometimes TE1 becomes shorter with larger BW.

PX25           Mar/04/2015 MHI          HCSDM00337739 : Corrected the argument of setup_geometry_arrays().

PX25           Apr/04/2015 YI           HCSDM00342902 : Added capability for reducing #iterations of smart derating.

PX25           May/07/2015 MHI          HCSDM00327081 : Replaced ceil by ceilf to prevent unwanted increment of rhnframes.

PX25           Jun/30/2015 MHI          HCSDM00359397 : Code fix for smart derating.

PX26           Jul/22/2015 LH           HCSDM00362877  Set K15 smart derating configuration same as SV.

PX25           Aug/26/2015 YT           HCSDM00341147 : Support image cut reduction except for realtime scan

Melody1.1      May/20/2015 MJ           HCSDM00352456: 2D MDE improvements (MDE 3.0)

Melody1.1      Jun/06/2015 MJ           HCSDM00355787: MDE 3.0: Use lower flip angle for PS SSh MDE FIESTA reference readout and
                                                       lock out PS with FIESTA at 3T

PX25           Aug/17/2015 YI           HCSDM00367496 :  Moved check for NPW and NEX to frac_nex_check().

PX25           Oct/30/2015 YI           HCSDM00367265 : Changed default SAT thickness to 30mm to avoid annefact artifact.

26.0           Nov/02/2015 SL           HCSDM00379663: # of phase encodings for endview() calculation was scaled incorrectly
                                                       for fn = 0.75 cases, caused phase direction size error.

PX25           Nov/11/2015 HM           HCSDM00367489 : Reduced #iterations for MERGE with flow compensation

MR26.0         Feb/02/2016 NLS          HCSDM00391218: Disable partial functions on MDE3.0: 
                                                       Disable 3-RR and 4-RR CINE-IR for Kizuna 1.5T and Mulan Plus;
                                                       Disable SSH+MDE+PS for Kizuna 1.5T.
 
26.0           Jan/12/2016 ZW           HCSDM00359636: Fraction NEX should be disabled while MR Touch option is turned on.

26.0           Feb/14/2016 MJ           HCSDM00393057: Display temporal resolution for all cardiac applications and ungated
                                                       sequential multi-phase SPGR and FIESTA.

26.0           Mar/08/2016 NLS          HCSDM00396145: Optimized APx parameters boundary for 1.5T: Auto BW (83.33~125KHz)

26.0           16-Mar-2016 RV           HCSDM00396846 - Enable Pixel Size, RBW/pixel informational display

26.0           Mar/15/2016 ZSW          HCSDM00396138: Locs Before Pause should be determined by acqs when FastCine or FastCard.  

26.0           Mar/19/2016 SW           HCSDM00397833: Increase viewtab size to 2049 in order to avoid array out of range issue.

26.0           Apr/15/2016 ZSW          HCSDM00397211: When ARC and half NEX is on, rhhnover should not be counted again in the view loop.

26.0           Apr/15/2016 ZSW          HCSDM00399928: Turn off k15_system_flag when not using K15T config by using isK15TSystem()instead.

26.0           May/18/2016 MXX          HCSDM00388148: added SV system judgement for MERGE rephaser derating in readout direction.

26.0           May/20/2016 KL           HCSDM00407776: Limit FUS TRIP to DV only.

26.0           Oct/26/2016 MO           HCSDM00426178 Optimized act_echofrac for FIESTA CINE.

26.0           Oct/26/2016 MO           HCSDM00428609 : Support Apodization filter for MERGE and FIESTA.

PX26.1         Jan/07/2017 YI           HCSDM00437118: Changed min BW limit to 41.67 kHz for non Ax/oblAx cases on MERGE.

PX26.1         Jan/10/2017 YI           HCSDM00438233: Do not apply non convergent smart derating mode to 2DMERGE.

27.0           Feb/03/2017 VSN          HCSDM00443183: Remove dependency on eXPGrad option key. Also enable smart derating for Rio. 

27.0           Feb/10/2017 VSN          HCSDM00445737: Sync up of below SPRs from Kizuna to Rio
                                                       HCSDM00442412 : Support C3 recon for MERGE

27.0           15-Feb-2017 HS           HCSDM00445737: Sync up Kizuna SPR HCSDM00415626 to Rio: Enabled the ChemSat UI for FSFIESTA with MPH.

27.0           15-Feb-2017 HS           HCSDM00445737: Sync up Kizuna SPR HCSDM00433163 to Rio: Call et_cvinit() when opET is turned on to avoid 
                                                       segmentation fault in switching sequence between FGRE to FGRE-ET.

27.0           16-Feb-2017 HS           HCSDM00445737: Sync up Kizuna SPR HCSDM00426178 to Rio: Optimized act_echofrac for FIESTA CINE

27.0           16-Feb-2017 HS           HCSDM00445737: Sync up Kizuna SPR HCSDM00436475 to Rio: Calculated true_slquant1 for Inflow signal reduction to avoid blank image

27.0           20-Mar-2017 GW           HCSDM00431477: Rio gradient spec (80/200) PSD

27.0           02-May-2017 VSN          HCSDM00457010: Revert back the expGrad changes

PX26.1         25-May-2017 MHI          HCSDM00442547: Forbade the combination of Cardiac Compensation and In-flow signal reduction(CV6).

27.0           17-Jul-2017 VSN          HCSDM00465634: Spherical gradient optimization

27.0           25-Jul-2017 MJ           HCSDM00466507: Increase maximum number of phases to 2048 for ungated multi-phase 2D FIESTA

PX26.1         Mar/30/2017 YI           HCSDM00453302 : Added Flexible NPW support changes.

PX26.1         Apr/25/2017 YI           HCSDM00456194 :  Forbade odd NEX NPW on FTOF.

PX26.1         Jul/26/2017 MO           HCSDM00470514 : Added return FAILURE for avepepowscale().

27.0           27-Jul-2017 MJ           HCSDM00467442: Make compatible FGRE-TC with low SAR mode and SAR>=1.0W/kg

27.0           28-Jul-2017 VSN          HCSDM00471707: Acoustic Noise Prediction model feature promote

27.0           31-Jul-2017 HS           HCSDM00471892: disable CV6 (in-flow signal reduction) for Rio and DV system

27.0           15-Aug-2017 NLS          HCSDM00467723: Open new features for voyager 2017 (enable Cardiac T1 Mapping and MDE3.0). 
                                        HCSDM00471167: Enabled 2D/3D merge with C3 recon for voyager 2017. 

27.0           24-Aug-2017 VSN          HCSDM00474598: Merging changes from HCSDM00417345

PX26.1         Sep/07/2017 YI           HCSDM00477775: Changed error check against non-integer NEX.

27.0           10-Oct-2017 VSN          HCSDM00482057: For acousti minseq() calculation pass act_tr instead of tmin

27.0           18-Oct-2017 YI           HCSDM00480759: Changed ps2_dda from 16 to 64 on FIESTA.

27.0           18-Oct-2017 YI           HCSDM00483567: Fixed scan time problem with multiple NEX on TC sequences.

27.0           18/APR/2017 WHB          HCSDM00455295: For performance ICE, data type is 32bits float data, to enable EDR for all applications and disable non-EDR error message.

27.0           14/Feb/2018 RKS          HCSDM00498749: Leverage 40/170 gradient spec to shorten TR on 2D Fiesta applications on Premier only

27.0           19/JUN/2018 NLS          HCSDM00515642: Close gradOpt_TE, gradOpt_RF and aTEopt_flag from Smart derating in Dual Echo.

27.0           13/AUG/2018 VSN          HCSDM00523003: Increase type-in TE range for single echo GRE/SPGR sequence

27.0           18/Sep/2018 KL           HCSDM00525593: Update logic for MINPH_RF_SINC1 for T2STAR

27.0           07/Dec/2018 NLS          HCSDM00535630: FIESTA TE/TR/scan time different between the HD28 and HD23.

HD28.0         27/Dec/2018 WPS          HCSDM00532644: fix 2D cal scan time and recon issue

HD28.0         17/Jan/2018 GJ           HCSDM00544518:  Turn on smart derating only for lava, lava-flex, tricks, 2Dfiesta, and fse-flex with heavy gradient load.

27.0           23/Jan/2019 AF           HCSDM00541389: Cardiac time course workflow improvements

26.2           21-Nov-2018 GJ           HCSDM00535489: Fiesta-TC download fail.

29.0           17-Seq-2020 GL           HSCDM00627480: Dual Echo Image Distortion on Voyager

29.1           02/Nov/2020 VAK          HCSDM00633197 - Disable burst mode outside head and neck for 750.

29.1           15-Jan-2021 ZZ           HCSDM00642123: FIESTA PSD download failure when acceleration factor changed after slices dropped on GRx

29.2           17-Sep-2021 KL           HCSDM00671180: Enable 40/170 gradient mode for TC on Premier

30.0           18-Mar-2022 ZT           HCSDM00691503: Update the HOPE 3-plane dbdt limit to 80 to align with other system

30.0           23-Mar-2022 ZT           HCSDM00692073  Un-bridge Dualecho when CV6=1 for 1.5T to avoid current distortion issue on Mulan system

30.1           01-Nov-2022 DY           HCSDM00716935: Turn on interslice crusher for ungated 2D Fiesta to remove ghost artifacts

30.1           10-Feb-2023 KL           HCSDM00726293: Wireless gating TR lockout

30.1           04-APR-2023 KL           HCSDM00731894: Update wireless gating TR lockout to act_tr instead to ensure the actual playout is locked out
*/

/*
 * Standard include file for PSDs.
 * This line should be the first line of code of every PSD.
 */
@inline epic.h

/* JAP ET */
@inline et_waveforms.eh


@global 
/*********************************************************************
 *                      FGRE.E GLOBAL SECTION                        *
 *                                                                   *
 * Common code shared between the Host and Tgt PSD processes.  This  *
 * section contains all the #define's, global variables and function *
 * declarations (prototypes).                                        *
 *********************************************************************/

/* System includes */
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

/* Local includes */
#include "stddef_ep.h"
#include "epicconf.h"

#include "acousticResponse.h" /* Should move to a common header file */
#include "acousticLockout.h"
#include "feature_flag_defs.h"
#include "Prescan.h"
#include "psd_proto.h"
#include "psdnumerics.h"
#include "pulse_defs.h"
#include "pulsegen.h"
#include "RTIA_defs.h"

/*
 * Enable ChemSat in CFH
 */
#define PSD_CFH_CHEMSAT 1

/*
 * Local Global Definitions
 */
#define RESP_TABLE_SIZE 0x20000
#define PSD_IPG_DEBUG
/* redefine TR_SLOP_GR for gradient echo sequence */
#define TR_SLOP_GR 1ms

/* Higher Recon definitions */
#define HIRES_OFF 0
#define HIRES_512 1
#define HIRES_1024 2

#define PRESLQUANT       6  /* The number of slices to be prescanned */
#define MAX_PRESLQUANT   30

/* MRIge86472 */
#define FGRE_MAXTHICK 480

/* MRIge84855 */
#define FGRE_DEFTHICK 10.0

/* VAL15 02/21/2005 YI */
#define PC_APC 0
#define PC_SGS 1
#define PC_BASIC 2

#define MERGE_TE_1HT 15.0 
#define MERGE_TE_3T 12.0

/* SWIFT */
#define SWIFT_LEFT 0
#define SWIFT_RIGHT 1
#define SWIFT_COIL_OVERRIDE_NONE 0
#define SWIFT_COIL_OVERRIDE_CVS 1
#define SWIFT_COIL_OVERRIDE_PV_DUAL_CONN_A_B 2
#define SWIFT_COIL_OVERRIDE_PV_SINGLE_CONN_B 3

/* ASSET Calibration slquant limit */
#define ASSET_MAX_ZFOV 500.0
#define ASSET_MAX_SLQUANT 64

/* GEHmr04246 : define derate limitation for chemsat killer gradients */
#define CSK_TARGET 2.8

@inline ARC.e ARCGlobal

/* SVBranch HCSDM00115164: support SBM for FIESTA */
#define SBM_MAX_NEX_PHASE 3
#define SBM_MIN_MPS2_NUM 300

#define RIO_GRADSPEC_MAX_ZAMP 0.603 /* G/cm */
#define RIO_GRADSPEC_MAX_XFLAT 1300 /* us */

#define HRMB_GRADSPEC_MAX_ZAMP 1.05 /* G/cm */
#define HRMB_GRADSPEC_MAX_XFLAT 1300 /* us */

#define MINTE_T2STAR 8000
#define MAXTE 100000


/* MRIge91684 */
@inline RFb1opt+.e RFb1optglobal

@inline loadrheader.e rheaderglobal

/*
 * External Global Variables
 */
extern int opaphases;      /* number of acquired phases (from Fastcard.e) */
extern FLOAT satgapzpos;
extern FLOAT satgapzneg;
extern _cvfloat _satgapzpos;
extern _cvfloat _satgapzneg;
extern int RF1FC_SLOT;

/* GEHmr02859: Add Chem Sat and SpSat in PGOH */
extern int slq_per_sat;
extern float spsat_derate_scale;    /* CV from SpSat+.e */
extern float chemsat_killer_target; /* CV from ChemSat+.e */

/*  SVBranch HCSDM00115164: support SBM for FIESTA */
extern int number_linear_down; /* CV from Fiesta2D.e */
extern int number_linear_alpha; /* CV from Fiesta2D.e */
extern int viewspershot; /* CV from Fiesta2D.e */

/* This CV decides whether we have to turn chemsat on for 
   Prescan CFH entry point. */
extern int PScs_sat;
/* Defined in Prescan+.e */
extern int pre_slice;

extern int presscfh; 

/* End RTIA */

/* from Echotrain.e */
extern int gss_debug; /*gss*/
extern int phenc_offset;

/*from Fiesta2D.e MRIge92364*/
extern int debug_fsfiesta;
extern int number_linear_alpha;

/* cineir */ 
extern int cineir_flag;
extern int cineir_dda;
extern int de_option_key_status; 
extern int mdeplus_option_key_status;

extern int perfusion_flag;
extern int hard90_sat_flag;
extern int mde_flag;
extern int psmde_flag;
extern int fsmde_support;   /* from Fastcard.e */
extern int sshmde_flag;     /* from Fastcard.e */
extern int sshmdespgr_flag; /* from Fastcard.e */
extern int cine_kt_flag;
extern int mpl_discard_flag; /* from Mpl.e */

/*
 * Shared Global Variables
 */
STATUS new_view;
STATUS first_scan;
STATUS first_prepscan;
SHORT isibit;	/* bit set for isi routine */
/* changed type of dabOnOffFlag from SHORT to INT - ??? */
INT dabOnOffFlag;
/* changed types of startisi, look_for_trig, and isi_done
   from SHORT to INT */
INT startisi;
INT look_for_trig;
volatile INT isi_done;
LONG triggerState;
LONG oldTriggerState;
INT trigger_detected;    /* flag to indicate trigger detected. */
INT trigger_count;       /* number of triggers detected */
INT arrhythmiaCount;     /* current count of arrhythmias in a pass */
INT arrhythmiaOccurred;  /* flag to indicate that an arrhythmia occured */
INT arrhythmiaTotal;     /* total number of arrhythmias that have occured */



/* Begin RTIA */
static WF_PROCESSOR temp_wave_gen = XGRAD;
/* End RTIA */
/* Global definitions and structures for Exorcist - LX2 */
@inline Exorcist.e ExorcistGlobal
@inline Asset.e AssetGlobal
int pgen_for_dbdt_opt = 0;
int whilecounter =0;

typedef enum WAVE_OVERLAP {
    ONE_AXIS = 0,
    TWO_AXIS = 1,
    THREE_AXIS = 2
}WAVE_OVERLAP_E;


@ipgexport
/*********************************************************************
 *                   FGRE.E IPGEXPORT SECTION                        *
 *                                                                   *
 * Standard C variables of _any_ type common for both the Host and   *
 * Tgt PSD processes. Declare here all the complex type, e.g.,       *
 * structures, arrays, files, etc.                                   *
 *                                                                   *
 * NOTE FOR Lx:                                                      *
 * Since the architectures between the Host and the Tgt sides are    *
 * different, the memory alignment for certain types varies. Hence,  *
 * the following types are "forbidden": short, char, and double.     *
 *********************************************************************/
/* MRIhc08159: Added initialization */
RF_PULSE_INFO rfpulseInfo[MAX_NUM_PULSES_PER_BOARD] = { {0,0} };
int presliceorder[MAX_PRESLQUANT];

@inline ARC.e ARCIpgexport

@inline RTIA.e realtime_ipgexport

@inline T1Map.e T1MapIpgexport

@cv
/*********************************************************************
 *                       FGRE.E CV SECTION                           *
 *                                                                   *
 * Standard C variables of _limited_ types common for both the Host  *
 * and Tgt PSD processes. Declare here all the simple types, e.g,    *
 * int, float, and C structures containing the min and max values,   *
 * and ID description, etc.                                          *
 *                                                                   *
 * NOTE FOR Lx:                                                      *
 * Since the architectures between the Host and the Tgt sides are    *
 * different, the memory alignment for certain types varies. Hence,  *
 * the following types are "forbidden": short, char, and double.     *
 *********************************************************************/
@inline loadrheader.e rheadercv
/* CVs for Exorcist - LX2 */
@inline Exorcist.e ExorcistCV

int RF1_SLOT;
int RF_FREE;
int GXW_SLOT;
int GXW2_SLOT;			/* DUALECHO modification */
int GX1_SLOT;
int GXFC_SLOT;
int GXWEX_SLOT;
int GX_FREE;
int GYFE1_SLOT;
int GYFE2_SLOT;
int GYK2b_SLOT;
int GY1_SLOT;
int GY1R_SLOT;
int GY_FREE;
int GZRF1_SLOT;
int GZ1_SLOT;
int GZFC_SLOT;
int GZK_SLOT;
int GZINTERSLK_SLOT;  /*MRIhc20334*/
int GZ_FREE;
int GX2_SLOT; 

int GXU_TOUCH_SLOT;
int GXD_TOUCH_SLOT;
int GXF_TOUCH_SLOT;
int GYU_TOUCH_SLOT;
int GYD_TOUCH_SLOT;
int GYF_TOUCH_SLOT;
int GZU_TOUCH_SLOT;
int GZD_TOUCH_SLOT;
int GZF_TOUCH_SLOT;

/* HCSDM00241267: 2D Dual Echo 3T needs PSD changes to catch 1st out of phase TE */
/* "_min" limits for MINTE, "_mf" limits for MINFULLTE @ 3T only */
int dualecho3t_llimtein1_min = 2.264ms;  /* Lower Limit for 3T Dual Echo First In-Phase TE */
int dualecho3t_ulimtein1_min = 2.64ms;   /* Upper Limit for 3T Dual Echo First In-Phase TE */
int dualecho3t_llimteout1_min = 1.072ms; /* Lower Limit for 3T Dual Echo First Out-Phase TE - optimal first out-phase TE */
int dualecho3t_ulimteout1_min = 1.34ms;  /* Upper Limit for 3T Dual Echo First Out-Phase TE */
int dualecho3t_llimtein2_min = 4.7ms;    /* Lower Limit for 3T Dual Echo Second Out-Phase TE
                                            - better than (dualecho3t_ulimteout1 + 0.1ms) */

/* HCSDM00241267: 2D Dual Echo 3T needs PSD changes to catch 1st out of phase TE */
/* "_mf" limits for MINFULLTE (de2d) @ 3T only */
int dualecho3t_llimtein1_mf = 2.0ms;     /* Lower Limit for 3T Dual Echo First In-Phase TE */
int dualecho3t_ulimtein1_mf = 2.5ms;     /* Upper Limit for 3T Dual Echo First In-Phase TE */
int dualecho3t_llimteout1_mf = 3.6ms;    /* Lower Limit for 3T Dual Echo First Out-Phase TE - optimal first out-phase TE */
int dualecho3t_ulimteout1_mf = 3.8ms;    /* Upper Limit for 3T Dual Echo First Out-Phase TE */
int dualecho3t_llimteout2_mf = 5.8ms;    /* Lower Limit for 3T Dual Echo Second Out-Phase TE
                                            - better than (dualecho3t_ulimteout1 + 0.1ms) */

/* MRIge92350 - 1.5T Dual Echo TE limits - (determined experimentally and consistent with theory) */
int dualecho1p5t_llimtein1 = 4.2ms;     /* Lower Limit for 1.5T Dual Echo First In-Phase TE */
int dualecho1p5t_ulimtein1 = 5.0ms;     /* was 6.0; Upper Limit for 1.5T Dual Echo First In-Phase TE */
int dualecho1p5t_llimteout1 = 2.0ms;    /* was 1.8; Lower Limit for 1.5T Dual Echo First Out-Phase TE */
int dualecho1p5t_ulimteout1 = 2.8ms;    /* Upper Limit for 1.5T Dual Echo First Out-Phase TE */

/* HCSDM00241267: Dual Echo rBW Limits */
/* "_min" limits for MINTE, "_mf" limits for MINFULLTE @ 3T only */
float dualecho_llimrbw = 50.0;
float dualecho_llimrbw_min = 166.67;
float dualecho_llimrbw_mf = 50.0;
float dualecho_ulimrbw = 166.67;
float dualecho_ulimrbw_min = 250.0;
float dualecho_ulimrbw_mf = 166.67;

/* HCSDM00241267: 2D Dual Echo 3T needs PSD changes to catch 1st out of phase TE */
int dualecho_minTE = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, " limit 1st echo to OOP for 3T", };
int dualecho_TEcheck_flag = PSD_ON with {PSD_OFF, PSD_ON, PSD_ON, VIS, " Check for TE limits for dual echo minTE", };
int dualecho_TE_error = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "Flag error for dual echo OOP/IP check", };
int dualecho_max_xres = 1024 with {128, 1024, 1024, INVIS, "maximum xres to satisfy dual echo OOP/IP condition",};

int dualecho_inflow_reduce = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, " Dual Echo with inflow signal reduction enable", };

/* MRIge92430 - Minimum FOV Check Flag */
int minfovcheck_flag = PSD_ON;

/* HCSDM00397211: When ARC and half NEX is on, rhhnover should be replaced by temp_rhhnover in view loop. */
int temp_rhhnover = 0 with {0, 128, 0, VIS, "temporary variable for half nex over scanned",};

/*dbdtopt opt*/
int dbdtlevel_opt = 0 with {0, 1, 0, VIS, "optimize which dbdt level to use to get the better performance", };
int debug_dbdt = 0 with {0, 1, 1, VIS, "print out debug statement for dbdtlevel opt",};

int debug_rfamp = 0 with { 0,1,0, VIS, "Debug flag for RF amp conf",};
int debug_mintefgre = 0 with { 0,1,0, VIS, "Debug flag to print out variables from mintefgre",};
/* MEGE/R2: cvs */
int mege_eff_te;
/* R2 */
int r2_flag = 0 with { 0, 1, 0, VIS, "flag for R2* feature", };
int intte_flag = 1 with {1,4,1,VIS,"Number of interleaving echo trains (1-4)",};
int intte_delay = 4us;
int posinttexr, posintteyr, posinttezr, posinttesr, posintterr, posintteor;

int effectiveAcqTime = 0ms with {0,,0,VIS,"Time Resolution",};

int crusher_flag = 1 with {
    0, 1, 1, VIS, "flag to turn on z crusher, 0=off, 1=on", 
};

/*
 * Extra readout period
 */
int pw_gxwlex = 0 with {
    0, , , INVIS, "Width of extra readout period to set data acquisition window.",
};
int gxwex_on = 1 with {
    0, 1, 0, VIS, "switch to turn on extra readout period", 
};

int gxwextime;
float gxwex_target;
int gxwex_2axis_3axis_flag = 0; /* 0 - 1axis, 1- 2axis, 2 - 3xais */
float gxwex_rise_time_scale_fac = 1.0;

int isInh2DTOF = 0 with {0,1,0,INVIS,"Inhance 2DTOF flag, 0:OFF, 1:ON",};
int zerofill_flag = 0 with {0,1,0,INVIS,"zero filling instead of homodyn, 0:OFF, 1:ON",};

/* MRIge90793 */
int explicit_shot_delay = 0 with {
    0, , 0, VIS, "Requested delay time between shots for 2D FIESTA Fat SAT",
};

/* MRIge91361 cvs added for PURE calibration scan*/
int pure_ref = 0 with {0,1,0,VIS, "run pure reference scan or not, 1 yes 0 no",};
int pass_reps = 1 with {1,2,1,VIS, "reps for pure ref scan ",};
int run_setrcvportimm = 1 with {0,1,1,VIS,"run setrcvport code or not, 0 no, 1 yes",};
int run_setcoil = 1 with {0,1,0,VIS,"run setcoil functionat at all or not, 0, no,1,yes",};

/* For swift cal scan */
int swift_cal = 0;
int swift_cal_debug = 0;

int feature_flag = 0 with {
    0, , 0, INVIS, "Feature Flag Bit Mask", 
};

/* temporal (view sharing) interpolation CV's */
int frame_control = 1 with {
    0, 1, 1, INVIS, "copy control word", 
};
int copyframes = 1 with {
    0, , 1, INVIS, "copy control word", 
};
int copydelay = 54us with {
    0, 1s, 1ms, INVIS, "Delay after dab packet to copy packet.", 
};
int copystart = 0 with {
    0, 1s, , INVIS, "Delay of start of copy packet", 
};
int copy2start = 20us with {
    0, 1s, 20us, INVIS, "Delay of start of standalone copy packet", 
};
int copyit = 1 with {
    0, 1, 0, INVIS, "Turn on copy frame SSP packet", 
};
int copydabwait = 5ms with {
    0, 1s, , INVIS, "Wait after separate copy packet entry", 
};

int rfconf = 141;

int act_te = 0 with {
    0, , , INVIS, "actual te", 
};
/* DUALECHO - added support for second echo */
int act_te2 = 0 with {
    0, , , INVIS, "actual te2", 
};
/* DUALECHO - time difference between first and second echo */
int echo_spacing = 0;

/* MFGRE - average echo spacing for fractional echo. */
int average_esp = 0 with {
    0, , , INVIS,"average echo spacing for fractional echo"};

/* xtr offset for dualecho replaces XTRSETLNG */
int fast_xtr_setlng = 50;

float area_gzk = 0.0 with {
    , , 0.0, INVIS, "area of gzk pulse",
};
float area_gxwex = 0.0 with {
    , , 0.0, INVIS, "area of gxwex pulse",
};
float max_area_gxwex = 400.0 with {
    0.0, , 400.0, INVIS, "max area of gxwex pulse",
};
float max_area_gzk = 400.0 with {
    0.0, , 400.0, INVIS, "max area of gxk pulse",
};
float min_area_gzk = 100.0 with {
    0.0, , 100.0, INVIS, "min area of gxk pulse",
};
float area_gzrf1 = 200.0 with {
    -5000.0, , 200.0, INVIS, "area of gzrf1 pulse",
};
float a_gx1_frac = 0.0 with {
    , , 0.0, INVIS, "amplitude of gx1 pulse for frac. echo.",
};
float a_gx1_full = 0.0 with {
    , , 0.0, INVIS, "amplitude of gx1 pulse for full echo.",
};
float a_gxfc_frac = 0.0 with {
    , , 0.0, INVIS, "amplitude of gxfc pulse for frac. echo.",
};
float a_gxfc_full = 0.0 with {
    , , 0.0, INVIS, "amplitude of gxfc pulse for full echo.", 
};
int dda = 4 with {
    0, , 4, VIS, "Number of disdaqs in scan", 
};
int debug = 0 with {
    0, 1, 0, INVIS, "1 if debug is ON.", 
};
int debug_viewtab = 0 with {
    0, 1, 0, INVIS, "1 if debug viewtab is ON.", 
};
int viewtab_on = 0 with {
    0, 1, 0, INVIS, "1 if viewtab file dump desired ", 
};
int dex = 0 with {
    , , 0, INVIS, "num of discarded excitations", 
};
int gating = 0 with {
    0, , 0, INVIS, "gating - TRIG_INTERN, TRIG_LINE, etc.", 
};
/* EXT TRIGGER, legacy FUS */
int ext_trig = 0 with {
    0, 1, 0, INVIS, "Externally Triggered Scan (1=ON, 0=OFF)",
};

int fus_phase1_track = 1 with {0,1, 1,INVIS,"Run first phase tracking(1=ON, 0=OFF)",};

int fus_scan_dda = 0 with {0, , 0, INVIS, "number of disdaqs in FSU tracking scan", ""};

/*for external feature, such as MRgFUS tracking*/
float maxB1_scan, maxB1Seq_scan;

int ipg_trigtest = 1 with {
    0, 1, 0, INVIS, "if 0 use internal trig always", 
};
float echo1bw = 16 with {
    , , , INVIS, "Echo1 filter bw. in KHz", 
};
float echo2bw = 16 with {
    , , , INVIS, "Echo2 filter bw. in KHz", 
};
int isidelay = 800us with {
    0, , , INVIS, "delay time between start of isi and readout gradient in us",
};
int locktime = 0 with {
    0, , , INVIS, "scan lock out time in us", 
};
int min_tefe = 0 with {
    , , 0, INVIS, "minimum echo time w/ frac. echo", 
};
int min_tenfe = 0 with {
    , , 0, INVIS, "minimum echo time w/ full echo", 
};
int pre_pass = 0 with {
    0, , 0, INVIS, "prescan slice pass number", 
};
int nreps = 0 with {
    0, , 0, INVIS, "number of sequences played out", 
};
int gxktime = 0 with {
    0, , , INVIS, "X Killer Time.", 
};
int gzktime = 0 with {
    0, , , INVIS, "Z Killer Time.", 
};
int pos_start = 0 with {
    0, , , INVIS, "Start time for sequence. ", 
};
int post_echo_time = 0 with {
    0, , , INVIS, "time from te to end of seq", 
};
int ps2_dda = 0 with {
    0, , , INVIS, "Number of disdaq in 2nd pass prescan.", 
};
int ps2_nex = 2 with {
    0, , , INVIS, "Number of excitation in 2nd pass prescan.", 
};
int pw_gx1_frac = 0 with {
    0, , , INVIS, "Width of gx1 pulse for frac. echo.", 
};
int pw_gx1a_frac = 0 with {
    0, , , INVIS, "Attact width of gx1 pulse for frac. echo.", 
};
int pw_gx1d_frac = 0 with {
    0, , , INVIS, "Decay width of gx1 pulse for frac. echo.", 
};
int pw_gx1_full = 0 with {
    0, , , INVIS, "Width of gx1 pulse for full echo.", 
};
int pw_gx1a_full = 0 with {
    0, , , INVIS, "Attact width of gx1 pulse for full echo.", 
};
int pw_gx1d_full = 0 with {
    0, , , INVIS, "Decay width of gx1 pulse for full echo.", 
};
int pw_gxfc_frac = 0 with {
    0, , , INVIS, "Width of gxfc pulse for frac. echo.", 
};
int pw_gxfca_frac = 0 with {
    0, , , INVIS, "Attact width of gxfc pulse for frac. echo.", 
};
int pw_gxfcd_frac = 0 with {
    0, , , INVIS, "Decay width of gxfc pulse for frac. echo.", 
};
int pw_gxw_frac = 0 with {
    0, , , INVIS, "Width of gxw pulse for frac. echo.", 
};
int pw_gxwa_frac = 0 with {
    0, , , INVIS, "Width of gxw attact pulse for frac. echo.", 
};
int pw_gxwd_frac = 0 with {
    0, , , INVIS, "Width of gxw decay pulse for frac. echo.", 
};
int pw_gxfc_full = 0 with {
    0, , , INVIS, "Width of gxfc pulse for full echo.", 
};
int pw_gxfca_full = 0 with {
    0, , , INVIS, "Attact width of gxfc pulse for full echo.", 
};
int pw_gxfcd_full = 0 with {
    0, , , INVIS, "Decay width of gxfc pulse for full echo.", 
};
int pw_gxw_full = 0 with {
    0, , , INVIS, "Width of 1st full echo if not truncated.", 
};
int pw_gxwa_full = 0 with {
    0, , , INVIS, "Width of gxw attact pulse for full echo.", 
};
int pw_gxwd_full = 0 with {
    0, , , INVIS, "Width of gxw decay pulse for full echo.", 
};
/* JAP ET */
int pw_gxlwr = 0 with {
    0, , , INVIS, "total readout duration including left and right wings",
};

int flag_3t = PSD_OFF; /* Accomodate 3T related changes on hw side. */
float p__opfov = 0.0;
float p__oprbw = 0.0;
float p__opslthick = 0.0;
int p__opxres = 0;

int slquant_per_trig = 1 with {
    0, , 1, INVIS, "slices in first pass or slices in first R-R for XRR scans",
};

int single_slice_flag = 1 with {
    0, 1, 1, INVIS, "Flag for 1 slice per TR sequences",
}; /* CARme00449 */

int slq_per_tr = 1 with {
    0, , 1, INVIS, "Number of slices per TR period",
}; /* CARme00449 */

int sldeltime = 0 with {
    0, , 0, INVIS, "actual wait time", 
};

int td0 = 4us with {
    0, , 1, INVIS, "Init deadtime", 
};
int t_exa = 0 with {
    0, , 0, INVIS, "time from start of 90 to mid 90",
};
int t_exb = 0 with {
    0, , 0, INVIS, "time from mid of 90 to end 90",
}; 
int t_rd1a = 0 with {
    0, , 0, INVIS, "time from start of readout to echo peak",
};
int t_rd1a_frac = 0 with {
    0, , 0, INVIS, "time from start of readout to echo peak for frac. echo",
};
int t_rd1a_full = 0 with {
    0, , 0, INVIS, "time from start of readout to echo peak for full echo",
};
int t_rdb = 0 with {
    0, , 0, INVIS, "time from echo peak to end of readout",
};
int t_rdb_frac = 0 with {
    0, , 0, INVIS, "time from echo peak to end of readout for frac. echo",
};
int t_rdb_full = 0 with {
    0, , 0, INVIS, "time from echo peak to end of readout for full echo",
};
int te_time = 0 with {
    0, , 0, INVIS, "te * opnecho", 
};
int tr_time = 0 with {
    0, , 0, INVIS, "min TR time",
};

int tfe_extra = 0 with {
    0, , 0, INVIS, "savings for fract echo ", 
};
int time_ssi = 200us with {
    0, , 250ms, VIS, "time from eos to ssi in intern trig", 
};
int tlead = 12us with {
    0, , 24us, INVIS, "Init deadtime", 
};
int tlead_cssat = 300us with {
    0, , 0, INVIS, "Init deadtime for the chem sat section", 
};
int tlead_spsat = 300us with {
    0, , 0, INVIS, "Init deadtime for the spatial sat section", 
};
int rspqueue_size = 128 with {
    64, , , INVIS, "rsp queue size", 
};
/* CV's for 2dtf26.rho */
int minph_iso_delay = 1280us with {
    0, , , INVIS, "min phase pulse iso-delay", 
};
float minph_limit = 6.0 with {
    0.0, , , VIS, "lower limit to invoke minph pulse. 6 mm for 1 gcm", 
};
int minph_pulse_flag = 0 with {
    0, , 0, INVIS, "on(=1) minph pulse is used.", 
};
float overlap = 0.0 with {
    0, , 2.0, INVIS, "slice overlap in mm", 
};

int never_mind = 0; /* switch to override oppseq check */

/* additional time for phase encode if phase contrast flow encoding is used */
int yfe_time = 0 with {
    0, , 0, INVIS, "Additional time for y flow encoding gradients.",
};

int trig_prescan = TRIG_LINE with {
    0, , TRIG_LINE, INVIS, "prescan trigger", 
};
int read_truncate = 1 with {
    0, , 1, INVIS, "Truncate extra readout on fract echo", 
};
int tmin_satoff = 0 with {
    0, , 0, INVIS, "Min time determined by waveforms when sat is off", 
};
int use_myscan = 0 with {
    0, , 0, INVIS, "On(=1) to use my scan setup", 
};
int debug_scan = 0 with {
    0, , 0, INVIS, "On(=1) to print scan & rsp info tables", 
};
int isi_flag = 1 with {0, , 1, INVIS, "on(=1) flag for isi interrupt routine", };

int cine_flag = 0 with {
    0, , 0, INVIS, "on(=1) if cine mode", 
};
int spgr_flag = 0 with {
    0, , 0, INVIS, "on(=1) if spoiled grass", 
};

int rewinder_flag = 0 with {
    0, 1, 0, INVIS, "on when PSD_CINE, opexor or !mpgr_flag", 
};

int show_rtfilts = 0 with {
    0, 1, 0, INVIS, "Print real time filter specs(=1)", 
};

int vrg_sat = 2 with {
    0, 3, 2, INVIS, "VRG SAT code", 
};

int sshmde_support = 0 with {
    0, 1, 0, INVIS, "ON if Single Shot FIESTA mode is supported on the current scanner configuration",
};

int sshmdespgr_support = 0 with {
    0, 1, 0, INVIS, "ON if Single Shot SPGR mode is supported on the current scanner configuration",
};

int cineirspgr_support = 0 with {
    0, 1, 0, INVIS, "ON if CINE IR with SPGR readout is supported on the current scanner configuration",
};

int cineirhrep_support = 0 with {
    0, 1, 0, INVIS, "ON if CINE IR with 3-RR or 4-RR is supported on the current scanner configuration",
};

int cine_kt_support = 0 with {
    0, 1, 0, INVIS, "ON if CINE kt is supported on the current scanner configuration",
};

int psmdehrep_support = 0 with {
    0, 1, 0, INVIS, "ON if PSMDE with 3-RR or 4-RR is supported on the current scanner configuration",
};

int sshpsmde_support = 0 with {
    0, 1, 0, INVIS, "ON if Single Shot PSMDE is supported on the current scanner configuration",
};

int rcphase_chop = 1 with {0, 1, 1, VIS, "Receiver Phase Chop: 0=OFF, 1=ON",};

/* view acquisition order control variables */
int phorder = 0 with {
    0, 5, 0, VIS, "phase/view ordering: 0=normal, 1=centric, 2=segmented interleaved, 3=reverse centric, 4=odd-even interleaved, 5=reverse sequential",
};

/* CV used here to facilitate multiple phase ordering option support later. AN */
int phorder_IR = 1 with { 
    1, 1, 1, INVIS, "phase/view ordering for RTIA IR acquisitions: only 1=centric supported", };

int viewoffs = 0 with {
    0, 512, 0, VIS, "Number of views to offset in centric mode", 
};
int offset_inter = 1 with {
    0, 1, 0, VIS, "offset for segmented acquisition.  0=off, 1=on", 
};

/* sequential slice order for multiple acquisitions */
int seq_sl_order_flag = 0 with {
    0, 1, 0, VIS, "sequential slice order for multiple acquisitions: 0=off, 1=on",
};

/* obloptimize */
int obl_debug = 0 with {
    0, 1, 0, INVIS, "On(=1) to print messages for obloptimize", 
};
int obl_method = 1 with {
    0, 1, 1, INVIS, "On(=1) to optimize the targets based on actual "
                    "rotation matrices", 
};

int seed = 21001 with {
    0, , 21001, INVIS, "Spoiled Grass seed value", 
};
int seeddef = 21001 with {
    0, , 21001, INVIS, "Default SPGR seed value", 
};

float myrloc = 5.0 with {
    , , , INVIS, "Value for scan_info[0].oprloc", 
}; /* nonzero default value*/
/* from efgre3d.e */
float myphase_off = 10.0 with {0,,10.0,INVIS,"Phase offset for scan debug in mm",};

int xres = 256 with {
    0, 1024, 256, VIS, "No. of points to recon",
};

/* RF Unblank Reduction CVs */
int rfupacv= 50 with {,250,50,VIS,"RF unblank time",};
int dummyrf_time = 5ms with {0,100ms,5ms,VIS,"Initial RF Unblank Check Sequence Time",};
int dummyrf_ssitime = 1ms with {0,2ms,1ms,VIS,"RF Unblank Check Sequence SSI Time",};
int minimize_RFunblank_time = PSD_ON with {PSD_OFF,PSD_ON,PSD_OFF,VIS,"Flag to minimize RF Unblank",};

float area_gxw;                 /* readout pulse area of constant portion */
float area_readramp;            /* area of left readout ramp */
float area_gz1; 
float area_gx2 = -1000.0;

int avail_pwgx1;		/* avail time for gx1 pulse */
int avail_pwgy1;		/* avail time for gy1 pulse */
int avail_pwgz1;		/* avail time for gz1 pulse */
int avail_image_time;		/* act_tr for norm scans, */
				/* R_R avail time for cardiac */ 
/* creating rf waveform directly, so need to declare these */
int bw_rf1;			/* bandwidth of rf pulse */
int pw_rf1;			/* pulse width of rf pulse */
int off_rf1;
int ia_rf1;
float cyc_rf1;
float a_rf1;
float alpha_rf1;
float gscale_rf1;
float rf1_scale = 1.0;
int res_rf1;                    /* resolution of truncated sinc rf1 pulse */
int res_rf1_full;		/* resolution of a full sinc rf1 pulse */
float flip_rf1;
int wg_rf1 = TYPRHO1 with {0, WF_MAX_PROCESSORS*2-1, TYPRHO1, VIS, , };

/* fractional RF vars */
int frac_rf;      /* true if slice thickness < 1.01mm */
int post_lobes = 0 with {
    0, , 0, VISONLY, "number of lobes before center lobe", 
};
int pre_lobes = 0 with {
    0, , 0, VISONLY, "number of lobes after center lobe", 
};
int cutpostlobes = 0 with {
    0, , 0, VISONLY, "number of lobes cut after center lobe (frac RF)", 
};
int pw1_eff;     /* pulse width of a single lobe */
int pw_rf1_full;  /* pulse width of standard rf pulse (3.2ms) */

float fecho_factor;		/* percentage of the echo acquired */
int flow_comp_type;		/* on if flow comp */
int fullte_flag = PSD_OFF;	/* flag for full echo */
int max_bamslice;		/* max slices that can fit into bam */
int avmax_asset_slquant;  /* max slices for ASSET and PURE calibration scan */

/* min sequence times based on coil heating */
int min_tegz, min_tegy, min_tegx;  /* for min te calcs */
int max_seqsar;                 /* max time for sar for max av 
				    panel routines */
int max_slicesar;                /* max slices based on sar */
int min_seq1, min_seq3; /* advisory panel */

int other_slice_limit;		/* temp av panel value */
int non_tetime;			/* time outside te time */
/* JAP ET */
int attenlength = ATTEN_UNLOCK_LENGTH;            /* length for attenuator. */
int tns_length = 4;
/* Minimum seqlength statement is 8 usec */
int seq_length = 8;

int slice_size;			/* bytes per slice */
float std_amp;			/* std amp of 1ms rect pulse */

float xmtaddScan;
float extraScale;

int slicecnt;			/* slices B4 pause */
int scptrg = 1 with {
    0, 1, 0, , "SCOPE TRIGGER TYPE", 
};
int dither_on = 0;		 /* 1 means turn dither on  */
int dither_value = 6 with {
    0, 15, 6, VIS, "Value for dither", 
};

/* testing the taps and queuing for filters */
int tmp_taps, tmp_prefill;

/* Cine CVs */
int choplet = 0 with {
    0, 1, 0, INVIS, "On chopper, scan lets pcm do chopping", 
};

int test_getecg = 1; 
int premid_rf90 = 0 with {
    0, , 0, INVIS, "Time from beg. of seq. to mid 90", 
};

/* fat, water in/out-of phase cvs */
int llimte1;
int llimte2;
int llimte3;
int ulimte1;
int ulimte2;
int ulimte3;

int intsldelay;  /* Inter-nex delay */ /* ??? */
int avminsldelaydef = 50ms;
int pi_sldelnub;
 
/* total pulse width times for phase encode and rewinder */
int pw_gy1_tot;       /* temp time accumulation */
int pw_gy1r_tot;       /* temp time accumulation */

@inline FlexibleNPW.e fNPWcvs

/* VAL15 02/21/2005 YI */
int pcfiesta_flag = 0 with {0, 1, 0, INVIS, "Phase Cycled FIESTA Mode (0=off, 1=on)",};
int phase_cycles;
int pc_mode = PC_BASIC with {PC_APC, PC_BASIC, PC_BASIC, INVIS, "Phase Cycle Mode (0:APC 1:SGS 2:Basic)",};
int nex_save;

/*MRIhc20334 support for slice crusher for fiesta */
int fiesta_intersl_crusher = 0 with {0,,0,VIS, "inter slice crusher for fiesta, 0 = 0ff, >1, multiple of 2pi",};
float area_fiesta_intersl_crusher = 100.0;  
int total_intersl_crusher_time = 0; 
int delay_intersl_crusher = 4 with {4,,4, VIS, "delay for playing out the inter slice crusher in us",};
/* CV for obloptimize */
int initnewgeo;

int total_images; /* total number of images */

/* scale factors for killers - if sr17, killers are 70% max amplitude
   or gradient heating will lengthen your TR                          */ 
float zkilltarget;
float dutycycle_scale;

int zrtime;
int endview_iamp; /* last instruction phase amp */
float endview_scale; /* ratio of last instruction amp to maximum value */
float endview_scale_tem; /* ratio of last instruction amp to maximum value */
float rampscale;

/* ChemSatFGRE */
int cs_sat;
int cs_tune;
int cs_satstart;
int cs_sattime;
int ccsrelaxtime;   /* Time per scan to add for relaxers */

/* SpSatFGRE */
int sp_sattime = 0 with {
    0, , 0, INVIS, "Total time needed for spatial sat", 
};
int sp_satstart = 0 with {
    0, , 0, INVIS, "Start time for spatial presat", 
};
int SatRelaxers;

int true_acqs;   /* Number of acqs used to calculate ccsrelaxtime (MRI03524) */

/* Dual Echo option key flag */   
int decho_option_key_status = PSD_OFF with {
    PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Dual Echo option key flag.",
};
int merge2d_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "2d MERGE option key flag.",
};
int mfgre2d_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "2d Multi-Echo FGRE option key flag.",
};
/* PSMDE option key flag */   
int psmde_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "PSMDE option key flag.",
};
int touch2d_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "MR-Touch option key flag.",
};
int fgretc_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "LX FGRETC option key flag.",
};
int mxfgretc_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "MX FGRETC option key flag.",
};
int perf_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "FGRET Perfusion option key flag.",
};
int cineir_option_key_status = PSD_OFF with {
    PSD_OFF, PSD_ON, PSD_OFF, INVIS, "CINEIR Option Key Flag.",
};
int mde3d_option_key_status = PSD_OFF with { 
    PSD_OFF, PSD_ON, PSD_OFF, INVIS, "3D MDE Option Key Flag.",
};
int smartDer_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Smart Derating Option Key Flag.",
};
int cardt1map_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Cardiac T1 Mapping option key flag.",
};

int grad80_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Grad80 option key flag.",
};

int dlspdcine_option_key_status = PSD_OFF with {
        PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Sonic DL option key flag.",
};

int gradspec_flag = PSD_OFF with {
            PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Gradient Spec Mode: 0-off, 1-on.",
};

int grad_alt_flag = PSD_OFF with {
            PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Rio Gradient 40/170 Extreme Mode: 0-off, 1-on.",
};

int preslquant; /* Number of slices for 3-Plane prescan */

@inline vmx.e SysCVs /* vmx - 26/Dec/94 - YI */

/* begin ENH - 13/Aug/1997 - JAP/GFN */
float gamm = 0;  /* rotation about z (applied 3rd) */
float alpha = 0;  /* rotation about x (applied first) */
float beta = 0;   /* rotation about y (applied 2nd) */

int read_shift = 0 with {
    0, 1, 0, VIS, "shift pulses so read only overlaps with y",
};

float gxwtarget;
int gxwramp;

/* CVs for position  of gradient used in minseqseg()*/
int pos_gzrf1;
int pos_gz1;
int pos_gzfc;
int pos_gzk;
int pos_gzinterslk;   /*MRIhc20334*/
int pos_gxfc;
int pos_gx1;
int pos_gxw;
int pos_gxwex;
int pos_gyfe1;
int pos_gyfe2;
int pos_gy1;
int pos_gy1r;
int pos_gx2;

int pos_gxtouchu;
int pos_gxtouchd;                          
int pos_gxtouchf;                          
int pos_gytouchu;                          
int pos_gytouchd;                          
int pos_gytouchf;
int pos_gztouchu;
int pos_gztouchd;
int pos_gztouchf;                          

/* Values used for gradient heating since a_gy1ra/a_gy1rb are both positive */
float a_gy1ram;
float a_gy1rbm;
int tex2rd = 0 with {
     0, , 0, INVIS, "time from start of gzrf1 to gxw",
};
/* end ENH */

/* JAP ET */
/*********** Echo train **************/
int xtr_offset = -30;
int etl = 1;

/* Additional SSP time for Echotrain */
int et_ssp_time = 0;

int dt = 0us with {,,,VIS, "dacq start time tuning adjustment tweak",};

int rs_offset = 0us with {
    , , 0us, VIS, "Offset for ramp-sampling (us)", 
};

int grdrs_offset = 0us with {
    , , 0us, VIS, "Gradient offset for ramp-sampling (us)", 
};

float tsp = 8.0 with {
    0.05, 1000.0, 8, VIS, "Sampling period (us).", 
};

int short_rf = 0 with {
    0, 1, 0, VIS, "0=1500 usec, 1=800 usec rf.", 
};

int fast_pass = 0 with {
    0, 1, 9, VIS, "0= standard pass, 1= fast pass.",
};

int phaseres = 128 with {
    1, 2048, 128, VIS, "Number of points in the view table.",
};

int minisi_delay = 0 with { 
    0, 1s, 0, VIS, "Additional delay needed to complete updates",
};


/**** 512, 1024 zip ******/
int hires_recon = 0 with {0,2,0,VIS,"Use ZIP reconstruction (0=OFF, 1=512, 2=1024).",};
/* ETA */
int eta_tr = 1ms with {
    0,, 1s, VIS, "Pause for ET alignment calculation",
};

float n_vus_frac = 0.5; /* from the end of the n_vus'th echo */

/* Begin RTIA change */
/* RTIA also needs the bore temp monitor CVs. */
@inline RT.e BTcvs
/* end RTIA change */

/* Begin RTIA CVs */
float minph_rtia_limit = 4.3 with {
    0, , , VIS,"Upper limit to invoke RTIA RF in realtime.",
};

int minph_pulse_index = 1 with {
    1, 6, 1, INVIS, "1:2DTF26 2:RTIA 3:SINC1 4:TBW2 5:FERMI24 6:TBW6",
};
/* RTCA related valuables for worst case condideration */
int psd_fov = 480 with {
    FOV_MIN,,480,VIS, "Field of view used by PSD to set the sequence",
};

/* MRIge86472 */
float psd_slthick = FGRE_MAXTHICK with {
    MINTHICK, FGRE_MAXTHICK, FGRE_MAXTHICK, VIS, "Slice Thickness used by PSD to set the sequence",
};

int psd_flip = 90 with {
    0, 180, 90, VIS, "Flip Angle used by PSD to set the sequence",
};
/* End of RTCA  */

int bridge = 1 with { 
    0, 1, 1, VIS, "gwx and gxwex pulses will be bridged if 1.", 
};

int act_te_fc;
int act_tr_fc; 
int hard180_time = 0; 
int rtia_dummy_sequence_TR = 0;
int shorter_rf_unlocked;
/* MRIge53904 (GB Project 9484) - Initialize DDA prior to the first
   actual readout.  Allow it to be changed after download. */
int IRdda = 4 with { 4, 100, 4, VIS, "disdaqs after IR pulse in iDrive", };
/* End RTIA CVs */

/* RTCA required CVS */
float rtca_min_fov;
float rtca_max_fov;
int rtca_insteps_fov;
float rtca_min_slthick;
float rtca_max_slthick;
float rtca_insteps_slthick;
float rtca_min_flip;
float rtca_max_flip;
int rtca_insteps_flip;
/* End of RTCA */

/* FIESTA2D - New CVs */
/*
 * There are two RF pulses available for the FIESTA 2D technique: a Half
 * SINC (Gaussian) pulse and a Time BandWidth (TBW) pulse.  The selection
 * is determined by the fiesta_rf_flag CV.  By default, it is turned OFF
 * indicating that the SINC pulse is the one to use.  When the flag is
 * ON, the TBW pulse will be used.
 */
int fiesta_rf_flag = 0 with {
    0, 0, 0, VIS, "Set RF Pulse for FIESTA (0=Half SINC (Gaussian), 1=Time BandWidth (TBW))",
};

int vstrte_flag = 0 with {
    0,1,0,VIS,"VSTRTE flag",
};

int gz1_spacer = 0 with {
    0, 10ms, 0, VIS, "Time to move gz1 out for flow comp at start of seq",
};
int gzk_b4_gzrf1 = 0 with {
    0, 1, 0, VIS, "Flag to position Z killer before/after the slice select gradient (1=Before, 0=After)",
};
int symmetric_te = 0 with {
    0, 1, 0, VIS, "Flag to make TE=nonTE time",
};
int higher_dbdt_flag = 0 with {
    0, 0, 0, VIS, "Higher dB/dt limit (0=off, 1=on)",
};

/* FIESTA derating  05/13/2005 YI */
float derate_gx_G_cm; /* Gauss/cm */
float derate_gy_G_cm; /* Gauss/cm */
float derate_gz_G_cm; /* Gauss/cm */
float derate_gx_factor;      /* derating ratio */
float derate_gy_factor;      /* derating ratio */
float derate_gz_factor;      /* derating ratio */
float loggrd_ty_temp;        /* derated target_amp rounded by view step */
float acgd_lite_target = 1.5 with {
    0.5,,1.5, INVIS, "Target amp(G/cm) for ACGD-lite duty optimization", 
};
float derate_gxwex_factor;      /* derating ratio *//* YMSmr07885  10/12/2005 YI */

int derate_gy1_flag = 0 with {
    0, 1, 0, INVIS, "flag to derate gy1 as much as possible",
};
float extra_derate_gy1 = 1.0 with {
    0.0, 1.0, 1.0,INVIS, "derating factor of gy1",
};

int pw_gy1_no_derate;
int pw_gy1a_no_derate;
int pw_gy1d_no_derate;
float a_gy1a_no_derate;
float a_gy1b_no_derate;

@inline Asset.e AssetCVs

float yfov_aspect = 1.0 with {
    0, , ,INVIS, "acquired Y FOV aspect ratio to X",
};
float opfovpctovl = 0.10;
int firstSeriesFlag = TRUE;

/* MRIge91882*/
int threeplane_debug=0 with {
    0, 1, 0, VIS, "1 if debug is ON.",
};

int num_scanlocs = 1 with {
    1, , 1, INVIS, "=opslquant for use in prep_pulsegen", 
};

/*MRIge91882*/
int threeplane_dda =1 with {
    1, , 1, VIS, "DDA between planes for fgre 3-Plane",
};

/* MRIge91983 - RDP - scan plane rotation CVs */
float my_alpha = 0.0 with {-360.0, 360.0, 0.0, VIS, "Rotation around X-axis", };
float my_beta = 0.0 with {-360.0, 360.0, 0.0, VIS, "Rotation around Y-axis", };
float my_gamma = 0.0 with {-360.0, 360.0, 0.0, VIS, "Rotation around Z-axis", };
int pos_read, rewindertime;

int tmin_fgre_limits;

/* YMSmr08456  02/16/2006 YI */
int minfov_error = 0;

@inline T1Map.e T1MapCV

@inline ARC.e ARCCV

/* MRIge91684 */
@inline RFb1opt+.e RFb1optCVs

/* MR-Touch CVs*/
int   touch_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "flag to turn on MR-Touch",};
float touch_target = 2.2 with {0, 20.0, 2.2, INVIS, "common derated target",}; 
int   touch_rt = 4 with {4, 1000, 4, INVIS, "common derated rise time",};
int   touch_time = 0 with {0, 25000000, 0, VIS, "Total Duration of the MEG",};
int   touch_gnum = 1 with {0, 100, 1, VIS, "Number of MEG",};
int   touch_period = 0 with {0, 50000, 0, VIS, "1/freq in us",};
int   touch_lobe = 0 with {0, 25000, 0, VIS, "Half Period",};
int   touch_delta = 0 with {0, 25000, 0, VIS, "Time Between Offsets",};
float touch_act_freq =60.0 with {0.0, 5050.6, 60.0, VIS, "actual freq used based on gradient resolution",};
int   touch_pwcon = 0 with {0, 25000, 0, VIS, "Width of Flat Top for MEG",};
int   touch_pwramp =  0 with {0, 25000, 0, VIS, "Ramp Time for MEG",};
float touch_gdrate = 1.0 with {0.0, 1.0, 1.0, VIS, "scale down from max amp of encoding gradients",};
float touch_gamp = 1.76 with {0.0, 20.0, 1.76, VIS, "Amplitude of MEG in g/cm",};
float touch_gamp2 = -1 with {-1, 0, -1, VIS, "0 for 1-sided encoding; -1 for 2-sided encoding ",}; 
int   touch_xdir = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "MEG in X Direction",};	
int   touch_ydir = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "MEG in Y Direction",};
int   touch_zdir = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "MEG in Z Direction",};
int   touch_burst_count = 3 with {1, 500, 3, VIS, "Resoundant Cycles per Trigger",};
int   touch_ndir = 2 with {2, 2, 2, INVIS, "Number of MEG Polarities: 2 for bi-polar",};
int   touch_sync_pw=50 with {0, 200, 50, VIS, "Trigger Width in us",};
int   touch_fcomp=2 with {0, 2, 2, VIS, "Flow Comp MEG Pulses. 1: Bipolar Pulse, 2: 1-2-1 Pulse",};
float touch_menc = 0 with {0, 50000, 0, VIS, "Phase to Displacement Conversion Factor",};
int   touch_tr_time = 0 with {0, 30000000, 0, VIS, "Default TR for MR-Touch",};
int   touch_driver_amp = 30 with {0, 100, 30, VIS, "Resoundant Driver Amplitude",};
int   watchdogcount = 15 with{1,15,15,INVIS,"Pulsegen execution time (x5sec) before timeout",};

/* RF Safety Optimization */
int rfsafetyopt_doneflag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "RF Safety Optimization done flag",};
int rfsafetyopt_timeflag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, VIS, "RF Safety Optimization time calculation flag",};
int timecountB = 0 with {0, , 0, INVIS, "Counter B",};
int timecountE = 0 with {0, , 0, INVIS, "Counter E",};

/* GEHmr02638: CVs for smart derating */
int gradOpt_flag = PSD_OFF    with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Flag to turn on/off Smart derating: 0=OFF, 1=ON",};
/* SVBranch HCSDM00102590 */
int gradOpt_run_flag = 0      with {0, 1, 0, INVIS, "Flag to identify smart derating is running", };
int gradOpt_TE = PSD_OFF      with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Smart derating: 1=allow to longer TE, 0=don't allow",};
int gradOpt_RF = PSD_OFF      with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Smart derating: 1=allow to derate gzrf1, 0=don't allow",};
int gradOpt_GX2 = PSD_OFF     with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Smart derating: 1=allow to derate gx2, 0=don't allow",};
int gradOpt_mode = 1          with {0, 1, 1, INVIS, "Smart derating: 1=optimization based on Power; 0=don't optimize",};
int gradOpt_gxwex = 1         with {0, 2, 1, INVIS,
                                    "Fixed gxwex: 0:no further derating; 1:further derating except for FIESTA; 2: further derating for all",};
int ss_rewinder_flag = PSD_ON with {PSD_OFF, PSD_ON, PSD_ON, INVIS, "Same shape rewinder flag: 0=OFF, 1=ON",};

int gradOpt_TE_bak = PSD_OFF  with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Backup of gradOpt_TE",};
int gradOpt_RF_bak = PSD_OFF  with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Backup of gradOpt_RF",};
int gradOpt_GX2_bak = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Backup of gradOpt_GX2",};
int gradOpt_mode_bak = 1      with {0, 1, 1, INVIS, "Backup of gradOpt_mode",};
int gradOpt_gxwex_bak = 0     with {0, 2, 0, INVIS, "Backup of gradOpt_gxwex",};
int gradOpt_init = 0;             /* Smart derating: 1 - reset all derating factor to initial value */

int gradOpt_iter_count = 30       with {1, 30, 30, INVIS, "The maximum iterative count", };
int gradOpt_amp2_iter_count = 30  with {1, 30, 30, INVIS, "The maximum iterative count for amp2", };
int gradOpt_ratio_iter_num = 1    with {1, 30, 1, INVIS, "The maximum iterative count for power optimization", };
float gradOpt_tor = 0.005         with {0.0, 1.0, 0.005, INVIS, "allowed tolerance for difference between tmin and min_seqgrad", };
float gradOpt_aTETR_tor = 0.02    with {0.0, 1.0, 0.02, INVIS, "allowed tolerance for ogsf? calculation", };
float gradOpt_weight = 0.9        with {0.0, 1.0, 0.9, INVIS, "weighting used in gradOpt_scale iteration", };
float gradOpt_errToZero = 0.00001 with {0.0, 1.0, 0.00001, INVIS, "one small value witch is close to zero", };

/* HCSDM00342902 */
int gradOpt_iter_reduce_flag = 0 with {0, 1, 0, INVIS, "Flag for reducing number of iterations on smart derating", };
int gradOpt_iter_count_save = 30  with {1, 30, 30, INVIS, "The maximum iterative count for save", };
int gradOpt_iter_count_changed_flag = 0  with {0, 1, 0, INVIS, "Flag for iterative count change", };
int gradOpt_iter_count_act = 0    with {0, 30, 0, INVIS, "Actual iterative count", };

/* HCSDM00438233 */
int gradOpt_iter_nonconv_threshold = 3 with {0, 30, 3, INVIS, "Upper iteration limit not to apply non convergent mode", };

float gradOpt_scale = 1.0         with {0.05, , 1.0, INVIS, "general derating factor", };
float gradOpt_old_scale = 1.0     with {0.05, , 1.0, INVIS, "backup of gradOpt_scale", };
float gradOpt_scale_Min = 0.05    with {0.0, 1.0, 0.05, INVIS, "minimum allowed general derating factor", };
float gradOpt_scale_Max = 1.0     with {0.0, 1.0, 1.0, INVIS, "maximum allowed general derating factor", };
float gradOpt_GX2factor = 1.0     with {0.05, , 1.0, INVIS, "gradOpt_scale*gradOpt_GX2factor is used to derate gx2", };
float gradOpt_RFfactor = 1.0      with {0.05, , 1.0, INVIS, "gradOpt_scale*gradOpt_RFfactor is used to derate gzrf1", };
float gradOpt_TRfactor = 1.0      with {0.0, , 1.0, INVIS, "gradOpt_scale*gradOpt_TRfactor*ogsf? is used to derate TR group pulses (gxwex,gy1r,gzk)", };
float gradOpt_TEfactor = 1.0      with {0.0, , 1.0, INVIS, "gradOpt_scale*gradOpt_TEfactor*ogsf? is used to derate TE group pulses (gx1,gy1,gz1 etc.)", };
float gradOpt_rfb1opt_scale = 1.0 with {0.0, , 1.0, INVIS, "derating ratio caused by rfb1opt=2", };
/* SVBranch HCSDM00102590 */
float gradOpt_pwgzrf1_scale = 1.0       with {0.0, , 1.0, INVIS, "derating ratio caused by duration of gzrf1", };
float gradOpt_rfb1opt_limit = 0.01      with {0.0, , 0.01, INVIS, "tolerance allowed between tmin and max_seqsar or min_seqrfamp ", };
float gradOpt_rfb1opt_range = 1.3       with {0.0, , 1.3, INVIS, "search range with smart derating and rfb1opt=2 ", };
int gradOpt_convergence_flag = 1        with {0, 1, 1, INVIS, "Flag for convergence", };
float gradOpt_nonconv_tor = 0.01        with {0.0, , 0.01, INVIS, "allowed tolerance when convergence fails", };
float gradOpt_nonconv_tor_limit = 0.05  with {0.0, , 0.05, INVIS, "maximal allowed tolerance when convergence fails", };

float gradOpt_powerTE = 1.0       with {0.0, , 1.0, INVIS, "power of TE group pulses (gx1,gy1,gz1 etc.)", };
float gradOpt_powerTR = 1.0       with {0.0, , 1.0, INVIS, "power of TR group pulses (gxwex,gy1r,gzk)", };
float gradOpt_powerRF = 1.0       with {0.0, , 1.0, INVIS, "power of gzrf1", };
float gradOpt_powerGX2 = 1.0      with {0.0, , 1.0, INVIS, "power of gx2", };
int gradOpt_pwrf1 = 1000          with {1, , 1000, INVIS, "To save initial pulse width of gzrf1", };
int gradOpt_first = 0             with { 0, 1, 0, INVIS, "0: setPulseParams() is never called, 1: setPulseParams() was called at least 1 time", };
int gradOpt_noGxwex = PSD_OFF     with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "1: gxwex is fixed and can not be optimized, 0: gxwex can be optimized", };
int gradOpt_pgenDBDT = PSD_OFF    with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "1: update waveform for dbdt optimization, 0: not update", };

float gradOpt_TEderating_limit = 0.5  with {0.0, 1.0, 0.5, INVIS, "minimum allowed derating factor for TE group pulses (gx1,gy1,gz1 etc.)", };
float gradOpt_TRderating_limit = 0.05 with {0.0, 1.0, 0.05, INVIS, "minimum allowed derating factor for TR group pulses (gxwex,gy1r,gzk)", };
float gradOpt_RFderating_limit = 0.5  with {0.0, 1.0, 0.5, INVIS, "minimum allowed derating factor for gzrf1", };
float gradOpt_GX2derating_limit = 0.5 with {0.0, 1.0, 0.5, INVIS, "minimum allowed derating factor for gx2", };

float ogsf_limit_Min_RF_GX2 = 0.05 with {0.05, 1.0, 0.05,INVIS, "minimum allowed ogsfRF and ogsfGX2 scaling factor", };
float ogsf_limit_Min_Gxwex = 0.1   with {0.1, 1.0, 0.1, INVIS, "minimum allowed ogsfGxwex scaling factor", };
float ogsf_limit_Min = 0.003       with {0.003, 1.0, 0.003, INVIS, "minimum allowed ogsf* scaling factor except for ogsfRF, ogsfXwex and ogsfGX2", };
float ogsf_limit_Max = 1.0         with {0.0, 1.0, 1.0, INVIS, "maximum allowed ogsf* scaling factor", };
float ogsfMin = 0.1  with { 0.1, 1.0, 0.1, INVIS, "Minimum gradient scaling factor", };
float ogsfX1 = 1.0   with { 0.003, 1.0, 1.0, INVIS, "X1 gradient scaling factor", };
float ogsfXwex = 1.0 with { 0.003, 1.0, 1.0, INVIS, "Xwex gradient scaling factor", };
float ogsfY = 1.0    with { 0.003, 1.0, 1.0, INVIS, "Y gradient scaling factor", };
float ogsfYk = 1.0   with { 0.003, 1.0, 1.0, INVIS, "Y rewinder gradient scaling factor", };
float ogsfZ = 1.0    with { 0.003, 1.0, 1.0, INVIS, "Z gradient scaling factor", };
float ogsfZk = 1.0   with { 0.003, 1.0, 1.0, INVIS, "Z killer gradient scaling factor", };
float ogsfRF = 1.0   with { 0.003, 1.0, 1.0, INVIS, "RF1 scaling factor", };
float ogsfGX2 = 1.0  with { 0.003, 1.0, 1.0, INVIS, "GX2 gradient scaling factor", };
int aTEopt_flag = PSD_OFF  with { PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Adaptive TE optimization flag: 0=OFF, 1=ON", };
int aTRopt_flag = PSD_OFF  with { PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Adaptive TR optimization flag: 0=OFF, 1=ON", };

int xrmw_3t_flag = 0 with { 0, 1, 0, INVIS, "3.0T XRMW flag : 0 = other system, 1 = 750w", };
int force_fullte_flag = 0 with { 0, 1, 0, INVIS, "Force Full TE flag for 3.0T calibration : 0 = Off, 1 = On", };
int HD_ASSET_flag = PSD_OFF with { PSD_OFF, PSD_ON, PSD_OFF, INVIS, "ASSET cal on HD", };

/* SVBranch HCSDM00102521 */
float xfd_power_limit = 8.5 with { 2.0, 15.0, 8.5, INVIS, "XFD PS limitation", };
float xfd_temp_limit = 8.5  with { 2.0, 15.0, 8.5, INVIS, "XFA temperature power limitation", };

/* SVBranch HCSDM00115164: CVs for SBM */
int sbm_flag = 0                          with {0, 1, 0, INVIS, "Flag to turn on/off SBM: 0=OFF, 1=ON",};
int sbm_gx_cool = 1                       with {0, 1, 0, INVIS, "Flag to turn on/off gradient pulses in X axis",};
int sbm_gy_cool = 1                       with {0, 1, 0, INVIS, "Flag to turn on/off gradient pulses in Y axis",};
int sbm_dda_cool = 1                      with {0, 1, 0, INVIS, "Flag to turn on/off gradient pulses in X/Y axis during dda",};
int sbm_waiting_time = 0                  with {0,  , 0, INVIS, "Total waiting time",};
int sbm_mps2_num = 0                      with {0,  , 0, INVIS, "Amount of imaging TRs between two waiting period for Scan TR",};
int sbm_min_period  = 1000                with {0,  , 1000, INVIS, "Minimal period for waiting sequence",};
int sbm_time_ssi  = 0                     with {0,  , 0, INVIS, "Time from eos to ssi in intern trig",};
int sbm_seqgrad_xy  = 0                   with {0,  , 0, INVIS, "Min seqgrad when turn off X/Y gradient pulses",};
int sbm_seqgrad_y  = 0                    with {0,  , 0, INVIS, "Min seqgrad when turn off Y gradient pulses",};
float sbm_smartderating_factor = 1.35     with {1.0, 5.0, 1.35, INVIS, "The target ration between min_seqgrad and tmin",};
float sbm_time_limit = 1.0                with {0.0, , 1.0, INVIS, "Additional time needed to sink heat. Unit: s",};
float sbm_gx1_scale = 1.0                 with {, , 1.0, INVIS, "Gx1 scale for heating calculation ",};
float sbm_gxw_scale = 1.0                 with {, , 1.0, INVIS, "Gxw scale for heating calculation ",};
float sbm_gxwex_scale = 1.0               with {, , 1.0, INVIS, "Gxwex scale for heating calculation ",};
float sbm_gy1_scale = 1.0                 with {, , 1.0, INVIS, "Gy1 scale for heating calculation ",};
float sbm_gy1r_scale = 1.0                with {, , 1.0, INVIS, "Gy1r scale for heating calculation ",};
float sbm_gz1_scale = 1.0                 with {, , 1.0, INVIS, "Gz1 scale for heating calculation ",};
float sbm_gzk_scale = 1.0                 with {, , 1.0, INVIS, "Gzk scale for heating calculation ",};

int spgr_enhance_t1_flag = PSD_OFF with {PSD_OFF, PSD_ON, PSD_OFF, INVIS, "Enable an option to enhance SPGR T1w contrast",};

float ave_grady_gy1_scale = 1.0 with {-1.0,1.0,1.0,VIS,"average gradient scale for gradient thermal calc",};

float act_echofrac = 0.6 with {0.5, 1.0, 0.6, INVIS, "Echo fraction for min TE",};

int channel_combine_mode = 1 with {0,1,1,VIS,"Channel combine method for MERGE. 0=SOS, 1=C3",};

int perfusion_train = 0;

/* liyuan */
/* realtime update*/

int realu_debug = 0 with {0, 1, 0, VIS, "realtime udpate debug (1=ON, 1=OFF)", };
int realu_flag = 1 with {0, 1, 0, VIS, "for realtime updating imaging plane  (1=ON, 1=OFF)", };
float xtheta = 0.0 with {-180.0, 180.0, 0.0, VIS, "rotated angle along the x direction (degrees)", };
float ytheta = 0.0 with {-180.0, 180.0, 0.0, VIS, "rotated angle along the y direction (degrees)", };
float ztheta = 0.0 with {-180.0, 180.0, 0.0, VIS, "rotated angle along the z direction (degrees)", };


float transx = 0.0 with {-300.0, 300.0, 0.0, VIS, "translation along the x direction (mm)", };
float transy = 0.0 with {-300.0, 300.0, 0.0, VIS, "translation along the y direction (mm)", };
float transz = 0.0 with {-300.0, 300.0, 0.0, VIS, "translation along the z direction (mm)", };
/* liyuan end */

@host
/*********************************************************************
 *                       FGRE.E HOST SECTION                         *
 *                                                                   *
 * Write here the code unique to the Host PSD process. The following *
 * functions must be declared here: cvinit(), cveval(), cvcheck(),   *
 * and predownload().                                                *
 *********************************************************************/
/* System includes */
#include <values.h>
#include <sys/time.h>

/* Local includes */
#include "epic_error.h"
#include "epic_iopt_util.h"
#include "em_psd_ermes.in"
#include "feature_decl.host.h"
#include "fgre.host.h"
#include "filter_defs.h"
#include "printDebug.h"
#include "psd_receive_chain.h"
#include "pulse_structs.h"
#include "pulses.h"
#include "rfsspsummary.h"
#include "sar_burst_api.h"
#include "sar_display_api.h"
#include "sar_limit_api.h"
#include "sar_pm.h"
#include "sokPortable.h"
#include "support_func.host.h"
#include "support_func.tgt.h"
#include "TrackPlus.host.h"
#include "TrackPlus.tgt.h"

/* fec : Field strength dependency library */
#include "sysDep.h"
#include "sysDepSupport.h"      /* FEC : fieldStrength dependency libraries */

#include "psd.h"
#include "psdIF.h"
#include "psdopt.h"
#include "setPulseParams.h"

/* VAL15 02/21/2005 YI */
@inline vmx.e HostDef
@inline loadrheader.e rheaderhost

/* Private functions */
static void set_image_rh( void );
static void pause_button_calc( void );
static STATUS dbdtlevel_and_calcoptimize ( void );
static STATUS fgre_cveval_rfinit( void );
static STATUS nexcalc( void );
static STATUS calc_xresfn( INT *Xres, FLOAT *Fnecholim, INT OPxres );
static STATUS pulse_params_init( void );
static STATUS set_slice_select_params( void );
static STATUS set_phase_encode_and_rewinder_params( void );
static STATUS set_zkiller_params( void );
static STATUS set_rdout_params_te_and_tmin( void );
static STATUS derate_gy1( void );
static STATUS vstrte_init( void );
static STATUS frac_nex_check( void );

/* GEHmr02638: Private functions for smart derating */
static STATUS smart_derating( void );

static INT
calcDuration( const FLOAT targetArea,
              const FLOAT slewRate,
              const INT bridge_flag,
              const FLOAT startAmp,
              const FLOAT endAmp,
              const FLOAT targetAmp );

static FLOAT
calcTargetAmp( const FLOAT targetArea,
               const FLOAT slewRate,
               const INT targetDuration,
               const FLOAT targetAmpMin,
               const FLOAT targetAmpMax,
               const FLOAT startAmp,
               const FLOAT endAmp,
               const INT bridge_flag );

static FLOAT
calcTargetAmp2( const FLOAT targetArea1,
                const FLOAT targetArea2,
                const FLOAT targetArea3,
                const FLOAT slewRate1,
                const FLOAT slewRate2,
                const FLOAT slewRate3,
                const INT targetDuration,
                const FLOAT targetAmpMin,
                const FLOAT targetAmpMax );

static FLOAT
calcPower( const FLOAT targetArea,
           const FLOAT slewRate,
           const INT bridge_flag,
           const FLOAT startAmp,
           const FLOAT endAmp,
           const FLOAT targetAmp );

#ifdef EMULATE_HW
#define checkOptionKey( x ) 0
#endif

/*
 * Local definitions for the Host code
 */

#define Present 1
#define Absent 0 

/* Auto Protocol Optimization Option Key Flag */
int apx_option_key_status = PSD_OFF;

/*
 * Local variables for the Host code
 */
/* Temp placement for advisory panel return values */
static INT av_temp_int;

/* Temp placement for advisory panel return values */
static FLOAT av_temp_float;

/* These will point to a structure defining parameters of the filter
   used for the 1st echo and 2nd through N echos */
static FILTER_INFO *echo1_filt;

/* For Fgre use real time filters, so allocate space for them instead of
   trying to point to an infinite number of structures in filter.h. */
static FILTER_INFO echo1_rtfilt;
static FILTER_INFO echo1_rtfilt_frac;

/* Peak B1 amplitudes */
static FLOAT maxB1[MAX_ENTRY_POINTS];
static FLOAT maxB1Seq;

/* SAR variables */
double ave_sar;    /* average SAR over the entire body */
double cave_sar;   /* average coil SAR, based on transmit coil */
double peak_sar;   /* peak SAR, both head and body */
double b1rms;

/* Loop counters */
static INT entry;

/* RF pulse structures */
static RF_PULSE rfpulse_list[MAX_NUM_PULSES_PER_BOARD];
static RF_PULSE *rf1_pulse;

/* Gradient pulse structures */
static GRAD_PULSE gradx_list[MAX_NUM_PULSES_PER_BOARD];
static GRAD_PULSE *gxfc_pulse;
static GRAD_PULSE *gx1_pulse;
static GRAD_PULSE *gxw_pulse;
static GRAD_PULSE *gxw2_pulse;			/* DUALECHO modification */
static GRAD_PULSE *gxwex_pulse;
static GRAD_PULSE grady_list[MAX_NUM_PULSES_PER_BOARD];
static GRAD_PULSE *gy1_pulse;
static GRAD_PULSE *gy1r_pulse;
static GRAD_PULSE *gyfe1_pulse;
static GRAD_PULSE *gyfe2_pulse;
static GRAD_PULSE gradz_list[MAX_NUM_PULSES_PER_BOARD];
static GRAD_PULSE *gz1_pulse;
static GRAD_PULSE *gzrf1_pulse;
static GRAD_PULSE *gzfc_pulse;
static GRAD_PULSE *gzk_pulse;
static GRAD_PULSE *gx2_pulse;
static GRAD_PULSE *gzinterslk_pulse;  /*MRIhc20334*/

static GRAD_PULSE *gxtouchu_pulse;
static GRAD_PULSE *gxtouchd_pulse;                
static GRAD_PULSE *gxtouchf_pulse;
static GRAD_PULSE *gytouchu_pulse;
static GRAD_PULSE *gytouchd_pulse;
static GRAD_PULSE *gytouchf_pulse;
static GRAD_PULSE *gztouchu_pulse;
static GRAD_PULSE *gztouchd_pulse;                                     
static GRAD_PULSE *gztouchf_pulse;

static PULSE_TABLE pulse_table = {
    NULL, NULL, 0, 
    NULL, NULL, 0, 
    NULL, NULL, 0, 
    NULL, NULL, 0
};

/* Begin RTIA */
static RTIA_SAFE_TIMES safe_times[8];
static RTIA_POWERMON_VALUES rtia_pwrmon_values[8];
static RTIA_POWERMON_VALUES rtia_prescan_pwrmon_values;
static float gzrf1target;
static int plane_type;
static float rtia_pwrmon_avesar;
static float rtia_pwrmon_cavesar;
static float rtia_pwrmon_peaksar;

const CHAR supfailfmt[] = "Support routine %s failed.";
/* End RTIA */

/* Defined in SpSat+.e */
extern int spsatxkill;



/* MRIge54970 */
float maxhwrbw = PSD_MGD_BW1;

int optr_overrided = FALSE;

/* Begin dBdt Insert - RJF */
static int xrt = 0; 
static int yrt = 0;
static int zrt = 0;
/* End dBdt Insert */

/* This structure is used to save the rise/fall ramp times */
struct ramp_s {
   int xrt;
   int yrt;
   int zrt;

   int xft;
   int yft;
   int zft;
} tmp_ramp;

static STATUS status;   /* return code from host functions */

static short num_stations_flag = FALSE;

float old_ph_stride = 1.0;

/** CODE **/

@inline fgre_iopts.e AllSupportedIopts
@inline fgre_iopts.e ImagingOptionFunctions

/*
 * Load up PSD header 
 */
psdname( "FGRE" );
abstract( "Fast GR/SPGR Database" );

/* GEHmr02638: Private functions for smart derating */
extern float z_derate_factor;
extern float targ_dr_all;

/* HCSDM00445737 */
static bool et_initialized = false;

/*  calcTargetAmp()
 *  Description:
 *    Compute gradient amplitute that would yield
 *    trapezoidal or triangular shape with duration close to
 *    the desired duration.
 *  Parameters:
 *  (I: for input parameters, O: for output parameters)
 *
 *  (I) const FLOAT targetArea - desired gradient area (G*us/cm)
 *  (I) const FLOAT slewRate - desired slew rate (G/cm*us)
 *  (I) const INT targetDuration - desired pulse duration (us)
 *  (I) const FLOAT targetAmpMin - minimum gradient amplitude (G/cm)
 *  (I) const FLOAT targetAmpMax - maximum gradient amplitude (G/cm)
 *  (I) const FLOAT startAmp -  amplitude of start point (G/cm)
 *  (I) const FLOAT endAmp - amplitude of end point (G/cm)
 *  (I) const INT bridge_flag - flag to identify bridge pulse: 1-bridge pulse, 0-trapezoid pulses
 *  (O) FLOAT targetAmp - desired gradient amplitude (G/cm)
 *
 */

static FLOAT
calcTargetAmp( const FLOAT targetArea,
               const FLOAT slewRate,
               const INT targetDuration,
               const FLOAT targetAmpMin,
               const FLOAT targetAmpMax,
               const FLOAT startAmp,
               const FLOAT endAmp,
               const INT bridge_flag )
{
    FLOAT a, b, c, d, e, delta, targetAmp, ta, biggerAmp, smallerAmp;

    if (bridge_flag) /* to amplitude for Bridge pulse */
    {
        ta = fabs(startAmp-endAmp)/slewRate; /* ramp time from startAmp to endAmp */
        d = ta*(startAmp+endAmp)*0.5; /* area of trapezoid */
        biggerAmp = (startAmp > endAmp) ? startAmp : endAmp;
        smallerAmp = (startAmp > endAmp) ? endAmp : startAmp;

        e = d+(targetDuration-ta)*biggerAmp; /* area @ amplitude = biggerAmp */

        if (targetArea <= e) /* solution @ amplitude <= bigggerAmp */
        {
            if (targetArea < (d+(targetDuration-ta)*smallerAmp))
            {
                /* This situation should not happen. If happened, return minimum Amplitude. */
                targetAmp = targetAmpMin;
            }
            else
            {
                targetAmp = (targetArea-d)/(targetDuration-ta);
            }
        }
        else /* solution @ amplitude > biggerAmp */
        {
            a = 1.0/slewRate;
            b = ta-targetDuration;
            c = targetArea-e;
            delta = b*b-4.0*a*c;

            if (delta < 0.0)
            {
                targetAmp = targetAmpMax;
            }
            else
            {
                targetAmp = biggerAmp + (-b - sqrt(delta))/(2.0*a);
            }
        }
    }
    else /* same as original algorithm: to get amplitude for Trapezoid and Triangular pulses */
    {
        a = -1.0/slewRate;
        b = 1.0*targetDuration;
        c = -targetArea;
        delta = (b*b-4.0*a*c);

        if (delta < 0.0)
        {
            if ( targetArea <= (targetAmpMax*targetAmpMax/slewRate) )
            {
                /* Triangular solution */
                targetAmp = sqrt(targetArea*slewRate);
            }
            else
            {
                targetAmp = targetAmpMax;
            }
        }
        else
        {
            targetAmp = (-b + sqrt(delta))/(2.0*a);
        }

    }

    targetAmp = FMax (2, targetAmp, targetAmpMin);
    targetAmp = FMin (2, targetAmp, targetAmpMax);

    return targetAmp;
}

/*  calcTargetAmp2()
 *  Description:
 *    Compute gradient amplitute that would yield two
 *    trapezoidal or triangular shapes with duration close to
 *    the desired duration.
 *  Parameters:
 *  (I: for input parameters, O: for output parameters)
 *
 *  (I) const FLOAT targetArea1 - desired gradient area1 (G*us/cm)
 *  (I) const FLOAT targetArea2 - desired gradient area2 (G*us/cm)
 *  (I) const FLOAT targetArea3 - desired gradient area3 (G*us/cm)
 *  (I) const FLOAT slewRate1 - desired slew rate (G/cm*us)
 *  (I) const FLOAT slewRate2 - desired slew rate (G/cm*us)
 *  (I) const FLOAT slewRate3 - desired slew rate (G/cm*us)
 *  (I) const INT targetDuration - desired pulse duration (us)
 *  (I) const FLOAT targetAmpMin - minimum gradient amplitude (G/cm)
 *  (I) const FLOAT targetAmpMax - maximum gradient amplitude (G/cm)
 *  (O) FLOAT targetAmp - desired gradient amplitude (G/cm)
 *
 */

static FLOAT
calcTargetAmp2( const FLOAT targetArea1,
                const FLOAT targetArea2,
                const FLOAT targetArea3,
                const FLOAT slewRate1,
                const FLOAT slewRate2,
                const FLOAT slewRate3,
                const INT targetDuration,
                const FLOAT targetAmpMin,
                const FLOAT targetAmpMax )
{
    int i, tmpDuration;
    float targetAmp, tmpAmpMin, tmpAmpMax;

    tmpAmpMin = targetAmpMin;
    tmpAmpMax = targetAmpMax;
    targetAmp = targetAmpMax;

    if( (targetArea2 < gradOpt_errToZero) && (targetArea3 < gradOpt_errToZero) )
    {
        targetAmp = calcTargetAmp(targetArea1, slewRate1, targetDuration, targetAmpMin, targetAmpMax, 0.0,0.0,0);

        return targetAmp;
    }

    /* initial tmpDuration to ensure it can enter for{} */
    tmpDuration = targetDuration + 8;

    for( i=0; (i<gradOpt_amp2_iter_count) && (fabs(tmpDuration - targetDuration)>=4); i++ )
    {
        targetAmp = (tmpAmpMin + tmpAmpMax)*0.5;

        if( targetArea3 < gradOpt_errToZero )
        {
            tmpDuration = calcDuration(targetArea1,slewRate1,0,0.0,0.0,targetAmp) +
                          calcDuration(targetArea2,slewRate2,0,0.0,0.0,targetAmp);
        }
        else
        {
            tmpDuration = calcDuration(targetArea1,slewRate1,0,0.0,0.0,targetAmp) +
                          calcDuration(targetArea2,slewRate2,0,0.0,0.0,targetAmp) +
                          calcDuration(targetArea3,slewRate3,0,0.0,0.0,targetAmp);
        }

        if( tmpDuration < targetDuration )
        {
            tmpAmpMax = targetAmp;
        }
        else
        {
            tmpAmpMin = targetAmp;
        }
    }

    return targetAmp;
}

/*  calcDuration()
 *  Description:
 *    Compute duration that would yield
 *    trapezoidal or triangular shape or bridge trapezoidal
 *  Parameters:
 *  (I: for input parameters, O: for output parameters)
 *
 *  (I) const FLOAT targetArea - desired gradient area (G*us/cm)
 *  (I) const FLOAT slewRate - desired slew rate (G/cm*us)
 *  (I) const INT bridge_flag  - flag to identify if bridge trapezoidal is used
 *  (I) const FLOAT startAmp - gradient amplitude of start point (G/cm)
 *  (I) const FLOAT endAmp -  gradient amplitude of end point (G/cm)
 *  (I) const FLOAT targetAmp - maximum gradient amplitude (G/cm)
 *  (O) INT targetDuration - desired pulse duration (us)
 *
 */

static INT
calcDuration( const FLOAT targetArea,
              const FLOAT slewRate,
              const INT bridge_flag,
              const FLOAT startAmp,
              const FLOAT endAmp,
              const FLOAT targetAmp )
{
    FLOAT a,b,c,biggerAmp,ta,tb,tmpArea;
    INT targetDuration;

    if (bridge_flag) /* solution to get duration for bridge pulse */
    {
        ta = fabs(startAmp-endAmp)/slewRate;
        a = ta*(startAmp+endAmp)*0.5; /* minimum legal area */

        biggerAmp = (startAmp > endAmp) ? startAmp : endAmp;

        if (targetAmp > biggerAmp)
        {
            c = (targetAmp-biggerAmp)/slewRate; /* ramp time from biggerAmp to targetAmp */
            b = a+(targetAmp+biggerAmp)*c; /* minimum area @ amplitude = targetAmp */
        }
        else /* if targetAmp <= biggerAmp, only one situation will happen; so set b = a */
        {
            c = 0.0;
            b = a;
        }

        if (targetArea < a)
        {
            /* this situation should not happen. Reture 0 when it happen. */
            targetDuration = 0;
        }
        else if (targetArea < b) /* solution for "part of triangle pulse" */
        {
            tmpArea = targetArea-a;
            tb = (sqrt(tmpArea*slewRate+biggerAmp*biggerAmp)-biggerAmp)/slewRate;
            targetDuration = (int)(ta+2*tb);
        }
        else /* solution for "part of trapezoid pulse" */
        {
            tmpArea = targetArea-b;
            targetDuration = (int)(ta+2*c+tmpArea/targetAmp);
        }
    }
    else /* solution for triangle and trapezoid pulses */
    {
        a = targetAmp * targetAmp / slewRate; /* maximum area for triangle case */

        if (targetArea < a) /* triangle case */
        {
            targetDuration = (int)(2*targetAmp/slewRate*sqrt(targetArea/a));
        }
        else /* trapezoid case */
        {
            targetDuration = (int)(targetArea/targetAmp + targetAmp/slewRate);
        }
    }

    return targetDuration;
}

/*  calcPower()
 *  Description:
 *    Compute power that would yield
 *    trapezoidal or triangular shape or bridge trapezoidal
 *  Parameters:
 *  (I: for input parameters, O: for output parameters)
 *
 *  (I) const FLOAT targetArea - desired gradient area (G*us/cm)
 *  (I) const FLOAT slewRate - desired slew rate (G/cm*us)
 *  (I) const INT bridge_flag  - flag to identify if bridge trapezoidal is used
 *  (I) const FLOAT startAmp - gradient amplitude of start point (G/cm)
 *  (I) const FLOAT endAmp -  gradient amplitude of end point (G/cm)
 *  (I) const FLOAT targetAmp - maximum gradient amplitude (G/cm)
 *  (O) FLOAT outputPower - power generated
 *
 */

static FLOAT
calcPower( const FLOAT targetArea,
           const FLOAT slewRate,
           const INT bridge_flag,
           const FLOAT startAmp,
           const FLOAT endAmp,
           const FLOAT targetAmp )
{
    FLOAT a,b,c,d,e,f,biggerAmp,ta,tb,tmpArea,outputPower,smallerAmp;
    INT targetDuration;

    if (bridge_flag) /* solution to get duration for bridge pulse */
    {
        ta = fabs(startAmp-endAmp)/slewRate; /* ramp time from startAmp to endAmp */
        a = ta*(startAmp+endAmp)*0.5; /* minimum legal area */

        biggerAmp = (startAmp > endAmp) ? startAmp : endAmp;
        smallerAmp = (startAmp < endAmp) ? startAmp : endAmp;

        if (targetAmp > biggerAmp)
        {
            c = (targetAmp-biggerAmp)/slewRate; /* ramp time from biggerAmp to targetAmp */
            b = a+(targetAmp+biggerAmp)*c; /* minimum area @ amplitude = targetAmp */
        }
        else /* if targetAmp <= biggerAmp, only one situation will happen; so set b = a */
        {
            c = 0.0;
            b = a;
        }

        e = smallerAmp/slewRate; /* ramp time from zero to smallerAmp */
        f = e+ta; /* ramp time from zero to biggerAmp */

        if (targetArea < a)
        {
            /* this situation should not happen. Reture 0 when it happen. */
            outputPower = 0;
        }
        else if (targetArea < b) /* solution for "part of triangle pulse" */
        {
            tmpArea = targetArea-a;
            tb = (sqrt(tmpArea*slewRate+biggerAmp*biggerAmp)-biggerAmp)/slewRate;
            d = tb+ta+e;
            outputPower = 1.0/3.0*((d*slewRate)*(d*slewRate)*d*2.0 - (e*slewRate)*(e*slewRate)*e - (f*slewRate)*(f*slewRate)*f);
        }
        else /* solution for "part of trapezoid pulse" */
        {
            tmpArea = targetArea-b;

            if (targetAmp < biggerAmp)
            {
                outputPower = tmpArea*targetAmp + 1.0/3.0*biggerAmp*biggerAmp*f - 1.0/3.0*smallerAmp*smallerAmp*e;
            }
            else
            {
                outputPower = tmpArea*targetAmp + 1.0/3.0*(targetAmp*targetAmp*(c+f)*2.0 - biggerAmp*biggerAmp*f - smallerAmp*smallerAmp*e);
            }
        }
    }
    else /* solution for triangle and trapezoid pulses */
    {
        a = targetAmp * targetAmp / slewRate; /* maximum area for triangle case */

        if (targetArea < a) /* triangle */
        {
            targetDuration = (int)(2*targetAmp/slewRate*sqrt(targetArea/a));
            outputPower = (1.0/12.0)*slewRate*slewRate*targetDuration*targetDuration*targetDuration;
        }
        else /* trapezoid */
        {
            targetDuration = (int)(targetArea/targetAmp + targetAmp/slewRate);
            outputPower = (targetAmp*targetAmp)*(targetDuration - 4.0/3.0*targetAmp/slewRate);
        }
    }

    return outputPower;
}

/*  smart_derating()
 *  Description:
 *    Compute optimal scaling factor to limit the
 *    maximum available gradient amplitute per axis.
 *    The maximum gradident amplitude is determined
 *    by the required encoding area and the available
 *    encoding time per axis. The maximum availale
 *    encoding time is based on the required encoding
 *    time of the most demanding axis for given protocol.
 *  Parameters: no input parameters.
 *
 */

static STATUS
smart_derating( void )
{
    float areaGx1, areaGxfc, areaGxwex, areaGzfc, areaGz1, areaGzk, areaGy1, areaGyfe1, areaGyfe2, areaGy1r;
    float xTargetAmp, yTargetAmp, zTargetAmp, tmp_scale;
    int durationRead, durationPhase, durationSlice, durationMax, durationTemp;
    int durationReadTrue, durationPhaseTrue, durationSliceTrue;

    /* GEHmr02676: turn off gradOpt_pgenDBDT to ensure smart_derating() is called only one time
                   during dbdt optimization */
    gradOpt_pgenDBDT = PSD_OFF;

    if( (existcv(opfcomp) && exist(opfcomp)) || (feature_flag & FASTCARD_PC) )
    {
        flow_comp_type = TYPFC;
    }
    else
    {
        flow_comp_type = TYPNFC;
    }

    areaGx1 = fabs(a_gx1)*(0.5*pw_gx1a + pw_gx1 + 0.5*pw_gx1d);

    if( (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98)) )
    {
        areaGxfc = fabs(a_gxfc)*(0.5*pw_gxfca + pw_gxfc + 0.5*pw_gxfcd);
        areaGzfc = fabs(a_gzfc)*(0.5*pw_gzfca + pw_gzfc + 0.5*pw_gzfcd);
    }
    else
    {
        areaGxfc = 0.0;
        areaGzfc = 0.0;
    }

    if( PSD_PC == exist(oppseq) )
    {
        areaGyfe1 = fabs(a_gyfe1)*(0.5*pw_gyfe1a + pw_gyfe1 + 0.5*pw_gyfe1d);
        areaGyfe2 = fabs(a_gyfe2)*(0.5*pw_gyfe2a + pw_gyfe2 + 0.5*pw_gyfe2d);
    }
    else
    {
        areaGyfe1 = 0.0;
        areaGyfe2 = 0.0;
    }

    if( bridge )
    {
        areaGxwex = fabs(a_gxwex+a_gxw)*pw_gxwexa*0.5 + fabs(a_gxwex)*(pw_gxwex + pw_gxwexd*0.5);
    }
    else
    {
        areaGxwex = fabs(a_gxwex)*(pw_gxwex+0.5*pw_gxwexa+0.5*pw_gxwexd);
    }

    areaGy1     = fabs(a_gy1a)*0.5*pw_gy1a + fabs(a_gy1b)*0.5*pw_gy1d + (fabs(a_gy1a) + fabs(a_gy1b))*0.5*pw_gy1;
    areaGy1r    = fabs(a_gy1ra)*0.5*pw_gy1ra + fabs(a_gy1rb)*0.5*pw_gy1rd + (fabs(a_gy1ra) + fabs(a_gy1rb))*0.5*pw_gy1r;

    areaGz1     = fabs(a_gz1)*(0.5*pw_gz1a + pw_gz1 + 0.5*pw_gz1d);
    areaGzk     = fabs(a_gzk)*(0.5*pw_gzka + pw_gzk + 0.5*pw_gzkd);

    if( aTEopt_flag )
    {
        float tmpPower, srx, sry, srz;
        int tmpPWgzrf1d;

        tmp_scale = gradOpt_scale*gradOpt_TEfactor;
        tmp_scale = FMin(2, tmp_scale, gradOpt_scale_Max);
        tmp_scale = FMax(2, tmp_scale, gradOpt_scale_Min);

        xTargetAmp = loggrd.tx_xyz * tmp_scale;
        yTargetAmp = loggrd.ty_xyz * tmp_scale;
        zTargetAmp = loggrd.tz_xyz * tmp_scale;

        if( PSD_PC == exist(oppseq) )
        {
            srx = loggrd.tx_xyz / RUP_GRD(ceil(xrt * loggrd.scale_3axis_risetime)) / targ_dr_all;
            sry = loggrd.ty_xyz / RUP_GRD(ceil(yrt * loggrd.scale_3axis_risetime)) / targ_dr_all;
            srz = loggrd.tz_xyz / RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime)) / targ_dr_all / z_derate_factor;
        }
        else
        {
            srx = loggrd.tx_xyz / RUP_GRD(ceil(xrt * loggrd.scale_3axis_risetime));
            sry = loggrd.ty_xyz / RUP_GRD(ceil(yrt * loggrd.scale_3axis_risetime));
            srz = loggrd.tz_xyz / RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime));
        }

        /* smart_derating() is called before setPulseParam(), pw_gzrf1d with derating needs update temporally */
        /* SVBranch HCSDM00102590 */
        if( gradOpt_flag )
        {
            float tmpPW, tmpA, tmpSR;
            tmpSR = loggrd.tz_xyz/RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime));
            tmpPW = gradOpt_pwrf1 / ogsfRF;
            tmpA = fabs((float)pw_gzrf1 * a_gzrf1/tmpPW);
            tmpPWgzrf1d = (int)(tmpA/tmpSR);
        }
        else
        {
            tmpPWgzrf1d = pw_gzrf1d;
        }

        /* get duration of each axis */
        if( (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98)) )
        {
            durationRead = calcDuration(areaGx1,srx,0,0.0,0.0,xTargetAmp) +
                           calcDuration(areaGxfc,srx,0,0.0,0.0,xTargetAmp) + pw_gxwa;
        }
        else
        {
            durationRead = calcDuration(areaGx1,srx,0,0.0,0.0,xTargetAmp) + pw_gxwa;
        }

        if( PSD_PC == exist(oppseq) )
        {
            durationPhase = calcDuration(areaGy1,sry*targ_dr_all,0,0.0,0.0,yTargetAmp) +
                            calcDuration(areaGyfe1,sry,0,0.0,0.0,yTargetAmp) +
                            calcDuration(areaGyfe2,sry,0,0.0,0.0,yTargetAmp);
        }
        else
        {
            durationPhase = calcDuration(areaGy1,sry,0,0.0,0.0,yTargetAmp);
        }

        if( (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98)) )
        {
            durationSlice = calcDuration(areaGz1,srz,0,0.0,0.0,zTargetAmp) + tmpPWgzrf1d +
                            calcDuration(areaGzfc,srz,0,0.0,0.0,zTargetAmp);
        }
        else
        {
            durationSlice = calcDuration(areaGz1,srz,0,0.0,0.0,zTargetAmp) + tmpPWgzrf1d;
        }

        /* optimize ogsfX1, ogsfY, ogsfZ */
        durationMax = IMax(3, durationRead, durationPhase, durationSlice);

        if( !(durationMax == durationRead) ) /* to get optimal ogsfX1 */
        {
            int tmpFC;

            tmpFC = (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98));

            durationReadTrue = pw_gx1a + pw_gx1 + pw_gx1d + tmpFC*(pw_gxfca + pw_gxfc + pw_gxfcd) + pw_gxwa;

            if( fabs((float)durationMax/(float)durationReadTrue - 1.0) > gradOpt_aTETR_tor )
            {
                durationTemp = durationMax - pw_gxwa;
                ogsfX1 = calcTargetAmp2(areaGx1, (tmpFC*areaGxfc), 0.0, srx, srx, srx, durationTemp,
                                        ogsfMin*xTargetAmp, xTargetAmp) / xTargetAmp;
            }
            else
            {
                ogsfX1 = ogsfX1 / (gradOpt_scale * gradOpt_TEfactor);
            }
        }
        else
        {
            ogsfX1 = 1.0;
        }

        if( !(durationMax == durationPhase) ) /* to get optimal ogsfY */
        {
            int tmpPC;

            tmpPC = (PSD_PC == exist(oppseq));

            durationPhaseTrue = pw_gy1a + pw_gy1 + pw_gy1d + tmpPC*(pw_gyfe1a + pw_gyfe1 + pw_gyfe1d + pw_gyfe2a + pw_gyfe2 + pw_gyfe2d);

            if( fabs((float)durationMax/(float)durationPhaseTrue - 1.0) > gradOpt_aTETR_tor )
            {
                ogsfY = calcTargetAmp2(areaGy1, (tmpPC*areaGyfe1), (tmpPC*areaGyfe2), (sry* ((tmpPC) ? targ_dr_all : 1.0)), sry, sry, durationMax,
                                       ogsfMin*yTargetAmp, yTargetAmp) / yTargetAmp;
            }
            else
            {
                ogsfY = ogsfY / (gradOpt_scale * gradOpt_TEfactor);
            }
        }
        else
        {
            ogsfY = 1.0;
        }

        if( !(durationMax == durationSlice) ) /* to get optimal ogsfZ */
        {
            int tmpFC;

            tmpFC = (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98));

            durationSliceTrue = pw_gz1a + pw_gz1 + pw_gz1d + tmpFC*(pw_gzfca + pw_gzfc + pw_gzfcd) + tmpPWgzrf1d;

            if( fabs((float)durationMax/(float)durationSliceTrue - 1.0) > gradOpt_aTETR_tor )
            {
                durationTemp = durationMax - tmpPWgzrf1d;

                ogsfZ = calcTargetAmp2(areaGz1, (tmpFC*areaGzfc), 0.0, srz, srz, srz, durationTemp,
                                       ogsfMin*zTargetAmp, zTargetAmp) / zTargetAmp;
            }
            else
            {
                ogsfZ = ogsfZ / (gradOpt_scale * gradOpt_TEfactor);
            }
        }
        else
        {
            ogsfZ = 1.0;
        }

        /* to calculate gradOpt_powerTE */
        if( gradOpt_TE )
        {
            float tmpPW, tmpA, tmpSR;

            tmpSR = loggrd.tz_xyz/RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime));
            tmpPW = gradOpt_pwrf1 / ogsfRF;
            tmpA = fabs((float)pw_gzrf1 * a_gzrf1/tmpPW);
            tmpPower = a_gxw*a_gxw*pw_gxwa/3.0 + tmpA*tmpA*(tmpA/tmpSR)/3.0;

            if( (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98)) )
            {
                if( PSD_PC == exist(oppseq) )
                {
                    gradOpt_powerTE =
                       (calcPower(areaGx1,srx,0,0.0,0.0,xTargetAmp*ogsfX1) +
                        calcPower(areaGxfc,srx,0,0.0,0.0,xTargetAmp*ogsfX1) + tmpPower +
                        calcPower(areaGy1,sry*targ_dr_all,0,0.0,0.0,yTargetAmp*ogsfY) +
                        calcPower(areaGyfe1,sry,0,0.0,0.0,yTargetAmp*ogsfY) +
                        calcPower(areaGyfe2,sry,0,0.0,0.0,yTargetAmp*ogsfY) +
                        calcPower(areaGz1,srz,0,0.0,0.0,zTargetAmp*ogsfZ) +
                        calcPower(areaGzfc,srz,0,0.0,0.0,zTargetAmp*ogsfZ)) / durationMax;
                }
                else
                {
                    gradOpt_powerTE =
                       (calcPower(areaGx1,srx,0,0.0,0.0,xTargetAmp*ogsfX1) +
                        calcPower(areaGxfc,srx,0,0.0,0.0,xTargetAmp*ogsfX1) + tmpPower +
                        calcPower(areaGy1,sry,0,0.0,0.0,yTargetAmp*ogsfY) +
                        calcPower(areaGz1,srz,0,0.0,0.0,zTargetAmp*ogsfZ) +
                        calcPower(areaGzfc,srz,0,0.0,0.0,zTargetAmp*ogsfZ)) / durationMax;
                }
            }
            else
            {
                gradOpt_powerTE =
                   (calcPower(areaGx1,srx,0,0.0,0.0,xTargetAmp*ogsfX1) +
                    calcPower(areaGy1,sry,0,0.0,0.0,yTargetAmp*ogsfY) + tmpPower +
                    calcPower(areaGz1,srz,0,0.0,0.0,zTargetAmp*ogsfZ)) / durationMax;
            }
        }
        else
        {
            gradOpt_powerTE = 0.0;
        }
    }
    else
    {
        ogsfX1 = 1.0;
        ogsfY = 1.0;
        ogsfZ = 1.0;
    }

    if( aTRopt_flag )
    {
        float tmpPower, srx, sry, srz;

        xTargetAmp = gxwex_target * gradOpt_scale * gradOpt_TRfactor;
        yTargetAmp = loggrd.ty_xyz * gradOpt_scale * gradOpt_TRfactor;
        zTargetAmp = loggrd.tz_xyz * gradOpt_scale * gradOpt_TRfactor;

        srx = gxwex_target  / RUP_GRD(ceil(xrt * gxwex_rise_time_scale_fac));
        sry = loggrd.ty_xyz / RUP_GRD(ceil(yrt * loggrd.scale_3axis_risetime));
        srz = loggrd.tz_xyz / RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime));

        /* get duration of each axis */
        if( gradOpt_noGxwex )
        {
            durationRead = pw_gxwexa+pw_gxwexd+pw_gxwex+((bridge==0) ? pw_gxwd : 0);
        }
        else
        {
            durationRead = calcDuration(areaGxwex,srx,bridge,fabs(a_gxw),0.0,xTargetAmp) + ((bridge==0) ? pw_gxwd : 0);
        }

        durationPhase = calcDuration(areaGy1r,sry,0,0.0,0.0,yTargetAmp);

        durationSlice = calcDuration(areaGzk,srz,0,0.0,0.0,zTargetAmp);

        /* to optimize ogsfXwex, ogsfYk, ogsfZk */
        durationMax = IMax(3, durationRead, durationPhase, durationSlice);

        if( (!(durationMax == durationRead)) && (gradOpt_noGxwex==PSD_OFF) ) /* to get optimal ogsfXwex */
        {
            durationReadTrue = pw_gxwexa + pw_gxwex + pw_gxwexd + (!bridge)*(pw_gxwd);

            if( fabs((float)durationMax/(float)durationReadTrue - 1.0) > gradOpt_aTETR_tor )
            {
                durationTemp = durationMax - (!bridge)*(pw_gxwd);
                ogsfXwex = calcTargetAmp(areaGxwex, srx, durationTemp,
                                         ogsfMin*xTargetAmp, xTargetAmp, fabs(a_gxw), 0.0, bridge) / xTargetAmp;
            }
            else
            {
                ogsfXwex = ogsfXwex / (gradOpt_scale * gradOpt_TRfactor);
            }
        }
        else
        {
            ogsfXwex = 1.0;
        }

        if( !(durationMax == durationPhase) ) /* to get optimal ogsfYk */
        {
            durationPhaseTrue = pw_gy1ra + pw_gy1r + pw_gy1rd;

            if( fabs((float)durationMax/(float)durationPhaseTrue - 1.0) > gradOpt_aTETR_tor )
            {
                ogsfYk = calcTargetAmp2(areaGy1r, 0.0, 0.0, sry, sry, sry, durationMax,
                                        ogsfMin*yTargetAmp, yTargetAmp) / yTargetAmp;
            }
            else
            {
                ogsfYk = ogsfYk / (gradOpt_scale * gradOpt_TRfactor);
            }
        }
        else
        {
            ogsfYk = 1.0;
        }

        if( !(durationMax == durationSlice) ) /* to get optimal ogsfZk */
        {
            durationSliceTrue = pw_gzka + pw_gzk + pw_gzkd;

            if( fabs((float)durationMax/(float)durationSliceTrue - 1.0) > gradOpt_aTETR_tor )
            {
                ogsfZk = calcTargetAmp2(areaGzk, 0.0, 0.0, srz, srz, srz, durationMax,
                                        ogsfMin*zTargetAmp, zTargetAmp) / zTargetAmp;
            }
            else
            {
                ogsfZk = ogsfZk / (gradOpt_scale * gradOpt_TRfactor);
            }
        }
        else
        {
            ogsfZk = 1.0;
        }

        /* to calculate gradOpt_powerTR */
        if( gradOpt_noGxwex )
        {
            if( bridge )
            {
                tmpPower = a_gxw*a_gxw*(pw_gxwexa+pw_gxwex+1.0/3.0*pw_gxwd);
            }
            else
            {
                tmpPower = a_gxwex*a_gxwex*(1.0/3.0*pw_gxwexa+pw_gxwex+1.0/3.0*pw_gxwd) +
                           a_gxw*a_gxw*pw_gxwd/3.0;
            }
        }
        else
        {
            tmpPower = calcPower(areaGxwex,srx,bridge,fabs(a_gxw),0.0,xTargetAmp*ogsfXwex) +
                       ((bridge == 1) ? 0 : a_gxw*a_gxw*pw_gxwd/3.0);
        }

        gradOpt_powerTR = (tmpPower +
                    calcPower(areaGy1r,sry,0,0.0,0.0,yTargetAmp*ogsfYk) +
                    calcPower(areaGzk,srz,0,0.0,0.0,zTargetAmp*ogsfZk)) / durationMax;
    }
    else
    {
        ogsfXwex = 1.0;
        ogsfYk = 1.0;
        ogsfZk = 1.0;
    }

    /* to calculate gradOpt_powerGX2 */
    if( gradOpt_GX2 )
    {
        float tmpSR, tmpA, tmpArea;
        tmpSR = fabs(a_gx2 / pw_gx2a);
        tmpArea =  fabs(a_gx2)*(pw_gx2+0.5*pw_gx2a+0.5*pw_gx2d);
        gettarget(&tmpA, XGRAD,&loggrd);
        tmpA = tmpA * ogsfGX2;

        gradOpt_powerGX2 = calcPower(tmpArea,tmpSR,0,0.0,0.0,tmpA) / calcDuration(tmpArea,tmpSR,0,0.0,0.0,tmpA);
    }
    else
    {
        gradOpt_powerGX2 = 0.0;
    }

    /* to calculate gradOpt_powerRF */
    if( gradOpt_RF )
    {
        float tmpPW, tmpA, tmpSR;
        tmpSR = loggrd.tz_xyz/RUP_GRD(ceil(zrt * loggrd.scale_3axis_risetime));
        tmpPW = gradOpt_pwrf1 / ogsfRF;
        tmpA = fabs((float)pw_gzrf1 * a_gzrf1/tmpPW);

        gradOpt_powerRF = tmpA*tmpA*(tmpPW+tmpA/tmpSR*0.333333) / (tmpPW+tmpA/tmpSR);
    }
    else
    {
        gradOpt_powerRF = 0.0;
    }

    return SUCCESS;
}

/*
 * set_image_rh
 * 
 * Type: Private Function
 * 
 * Description:
 *   This function sets raw header variables that are needed in several
 *   functions to prevent code duplication.  An example is the use of
 *   rhdaxres, rhdayres and rhimsize.  They are needed in cveval() for the
 *   maxslquanttps() function and then later in predownload() they need
 *   to be re-calculated because the rheaderinit section in loadrheader.e
 *   resets them to other values.
 */
static void
set_image_rh( void )
{
    extern INT arc_fullbam_flag;

    /* Set Points per Frame collected */
    rhdaxres = echo1_filt->outputs;

    /* Set Frames per Echo collected */
    if ((PSD_ON == arc_ph_flag) && (PSD_ON == arc_fullbam_flag)){
        rhdayres = arc_ph_spanned + 1;
    } else {
        rhdayres = rhnframes + rhhnover + 1;
    }

    /* Set Image size */
    setResRhCVs();

    /* Adjust Image size for ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) {
        rhimsize = exist(opxres);
        if( rhimsize < 64 ) {
            rhimsize = 64;
        }
    }

    rhrcyres = rhimsize * noptmp;
    rhrcyres = rhrcyres + rhrcyres % 2;

    return;
}

/*
 * pause_button_calc
 * 
 * Type: Private Function
 * 
 * Description:
 *   This function sets the pipaunub (pause buttons) depending on the acquisitions
 *   and for special cases
 *
 * */

static void
pause_button_calc(void )
{
    /* fixed SPR 13608, so that 4 pause buttons are shown for 3
       acquisitions, etc. */
    if ( acqs > 5 ) {
        pipaunub = 6;
    } else if ( acqs > 3 ) {
        pipaunub = 5;
    } else if ( acqs > 2 ) {
        pipaunub = 4;
    } else if ( acqs > 1 ) {
        pipaunub = 3;
    } else {
        pipaunub = 0;
    }
    
    /* MRIge58383 - Need to grayout no of locs before pause for ET MPH */
    if(( (feature_flag & ECHOTRAIN) && (PSD_ON == exist(opmph))) || perfusion_flag ) {
        pipaunub = 0;
    }
   
    /* For Multi-Phase case when Inter-sequence delay is not minimum do not
     * allow */
    /* YMSmr08895  02/23/2006 YI  Fixed the pause control problem with auto voice.
    end YMSmr08895 */

    if ((touch_flag || (feature_flag & MPH)) && (existcv(opsldelay) && (exist(opsldelay) !=avminsldelay)))
    {
        pipaunub = 0;
        cvoverride(opslicecnt,0,PSD_FIX_ON,PSD_EXIST_ON); 
    }
    
    /* MRIge81136 */
    if( acqs == 1 ) 
    {
        pipaunub = 0;
    }
    
    if(2 == rfb1opt_flag) /*HCSDM00095097*/
    {
        if ( ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || 
              (PSD_ON == pure_ref)) && (exist(opnex) > 1.0) ) 
        {
            pipaunub = 3;
            avminslicecnt = 0;
            avmaxslicecnt = 1;
        }
    }    

    pipauval2 = 0;
    pipauval3 = 1;
    pipauval4 = 2;
    pipauval5 = 3;
    pipauval6 = 4;

    /* Allow only 1 loc before pause; otherwise, scan will crash 
       because output file is still being written when next slice starts.
    */
    if( cardt1map_flag && (acqs > 1) )
    {
        pipaunub = 2;
        pipauval2 = 1;
    }

    return;
}   /* end check acqs before pause () */


/*
 * dbdtlevel_and_calcoptimize
 * 
 * Type: Private Function
 * 
 * Description:
 *   This function Perform Gradient and Coil heating calculations using the
 *   optimized waveforms 
 *
 * */

static STATUS
dbdtlevel_and_calcoptimize(void )
{
    if(gradspec_flag && (PSD_ON == exist(opresearch)))
    {
        cfdbdtper = 1000.0;
    }
    else if((2 == rfb1opt_flag) || ((1 == rfb1opt_flag) && isHOPESystem())) /*HCSDM00095097*/
    {
        /* MRIhc04425 */
        /* MRIhc18402 - XRMB PNS stimulation fix - For all 3 PLANE, make normal level and
           rectangular mode */
        if( (PSD_3PLANE == opplane) || ((PSD_PC == exist(oppseq)) && isValueSystem()) )
        {
            cfdbdtper = 80.0;
            reilly_mode = 0;
            cvoverride(reilly_mode,0, PSD_FIX_ON, PSD_EXIST_ON);
        }
        else
        {   /* GEHmr04434 */
            _reilly_mode.fixedflag = PSD_OFF; /* calcOptimizedPulses() will assign right value to reilly_mode */
        }
    }
    else
    {
        if( ((opplane == PSD_3PLANE) && (feature_flag & FIESTA)) &&
            ((FDA1_BODY == cfgovbody) || (FDA2_BODY==cfgovbody) || (IEC_BODY==cfgovbody)) ) 
        {
            cfdbdtper = 80.0;
        }
    }

    /* Restore original rise/fall ramp times */
    loggrd.opt.xrt = tmp_ramp.xrt;
    loggrd.opt.yrt = tmp_ramp.yrt;
    loggrd.opt.zrt = tmp_ramp.zrt;
    loggrd.opt.xft = tmp_ramp.xft;
    loggrd.opt.yft = tmp_ramp.yft;
    loggrd.opt.zft = tmp_ramp.zft;

    /*
     * Perform dBdt optimization on the prescribed values
     */

    gy1_pulse->scale = 1;
    gy1r_pulse->scale = 1;

    /* GEHmr02676: enable to update waveform (run smart_derating()) at first calcOptimizedPulses() call.
                   gradOpt_pgenDBDT will be turned off in smart_derating(). */
    gradOpt_pgenDBDT = PSD_ON;

    if( (status = calcOptimizedPulses( &loggrd, &pidbdtper, &srderate,
                                       cfdbdtper, seqEntryIndex,
                                       dbdt_debug, use_ermes,
                                       higher_dbdt_flag )) != SUCCESS ) {
        /* Allow error message from the lower level routines to show up */
        return status;
    }

    /* SVBranch HCSDM00115164 */
    if ( (PSD_ON == dbdtlevel_opt) && (PSD_OFF == sbm_flag) ) {
        int tmp_minseqcoil_t;
        int tmp_min_seqgrad;
        float tmp_srderate;
        int tmp_tmin = tmin;

        /*
         * Perform Gradient and Coil heating calculations using
         * optimized waveforms
         */

        /* Scale pulses for heating calculations */
        int num_overscans = 0;
        num_overscans = rhnframes - phaseres / 2 + rhhnover;
        if ((status = avepepowscale(&ave_grady_gy1_scale, phaseres, num_overscans)) != SUCCESS)
        {
            return status;
        }

        gy1_pulse->scale = ave_grady_gy1_scale;
        gy1r_pulse->scale = ave_grady_gy1_scale;

        /* Populate the RF and GRAD linked lists */
        form_rf_pulse_list( pulse_table, rfpulse_list, &RF_FREE );
        form_grad_pulse_list( pulse_table, XBOARD, gradx_list, &GX_FREE );
        form_grad_pulse_list( pulse_table, YBOARD, grady_list, &GY_FREE );
        form_grad_pulse_list( pulse_table, ZBOARD, gradz_list, &GZ_FREE );

        /* Calculate min TR values for GRD DRV, GPM and COIL */
        if ( FAILURE == minseq( &min_seqgrad,
                                gradx_list, GX_FREE,
                                grady_list, GY_FREE,
                                gradz_list, GZ_FREE,
                                &loggrd, seqEntryIndex, tsamp, tmin,
                                use_ermes, seg_debug ) ) {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "minseq" );
            return FAILURE;
        }
	
        /* Save current min TR for coil heating and SR derate values */
        tmp_minseqcoil_t = minseqcoil_t;
        tmp_min_seqgrad = min_seqgrad;
        tmp_srderate = srderate;
        tmp_tmin = tmin;

        if (debug_dbdt) 
        {
            printf("pos1: minseq=%d, tmin=%d, pidbdtper=%f\n min_seqgrad=%d ", minseqcoil_t, tmin, pidbdtper, min_seqgrad);
        }

        /*
         * Check coil heating effect in TR for 100% dB/dt.  If min TR
         * for coil heating is worse than the minimum sequence time,
         * recalculate everything with 80% dB/dt and use the better
         * values.
         */
        if( (cfdbdtper >cfdbdtper_norm) && (min_seqgrad > tmin) ) 
        {
            /* Reset to full scale for dB/dt optimization */
            gy1_pulse->scale = 1;
            gy1r_pulse->scale = 1;

            /* Restore original rise/fall ramp times */
            loggrd.opt.xrt = tmp_ramp.xrt;
            loggrd.opt.yrt = tmp_ramp.yrt;
            loggrd.opt.zrt = tmp_ramp.zrt;

            loggrd.opt.xft = tmp_ramp.xft;
            loggrd.opt.yft = tmp_ramp.yft;
            loggrd.opt.zft = tmp_ramp.zft;

            /* Force the dB/dt optimization to run again */
            /* set_cvs_changed_flag( TRUE ); */
            enforce_minseqseg = PSD_ON;

            /* Perform dB/dt optimization for 80% */
            if( (status = calcOptimizedPulses( &loggrd, &pidbdtper, &srderate,
                                               cfdbdtper_norm, seqEntryIndex,
                                               dbdt_debug, use_ermes,
                                               higher_dbdt_flag )) != SUCCESS ) {
                return status;
            }

            /* Scale pulses for heating calculations */
            gy1_pulse->scale = ave_grady_gy1_scale;
            gy1r_pulse->scale = ave_grady_gy1_scale;

            /* Populate the RF and GRAD linked lists */
            form_rf_pulse_list( pulse_table, rfpulse_list, &RF_FREE );
            form_grad_pulse_list( pulse_table, XBOARD, gradx_list, &GX_FREE );
            form_grad_pulse_list( pulse_table, YBOARD, grady_list, &GY_FREE );
            form_grad_pulse_list( pulse_table, ZBOARD, gradz_list, &GZ_FREE );

            /* Re-calculate min TR values for GRD DRV, GPM and COIL */
            if ( FAILURE == minseq( &min_seqgrad,
                                    gradx_list, GX_FREE,
                                    grady_list, GY_FREE,
                                    gradz_list, GZ_FREE,
                                    &loggrd, seqEntryIndex, tsamp, tmin,
                                    use_ermes, seg_debug ) ) {
                epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                            EE_ARGS(1), STRING_ARG, "minseq" );
                return FAILURE;
            }
           
            if (debug_dbdt) 
            {
                printf("pos2: minseq=%d, tmin=%d, pidbdtper=%f\n min_seqgrad=%d ", minseqcoil_t, tmin, pidbdtper, min_seqgrad);
            }

            /*
             * Compare the min TR for coil heating between 80% and 100%
             * dB/dt.  If the 80% values are worse than the 100% values,
             * then recover the original rise/fall ramp times and SR
             * derate values and re-perform dB/dt optimization and
             * Gradient/Coil heating calculations to reset everything
             * back to the prescribed case.
             */
            if((min_seqgrad > tmp_min_seqgrad) || (tmin > tmp_min_seqgrad)) 
            {
                /* Recover SR derate value */
                srderate     = tmp_srderate;
                tmin         = tmp_tmin;
                min_seqgrad  = tmp_min_seqgrad;
                minseqcoil_t = tmp_minseqcoil_t;

                /* Restore original rise/fall ramp times */
                loggrd.opt.xrt = tmp_ramp.xrt;
                loggrd.opt.yrt = tmp_ramp.yrt;
                loggrd.opt.zrt = tmp_ramp.zrt;

                loggrd.opt.xft = tmp_ramp.xft;
                loggrd.opt.yft = tmp_ramp.yft;
                loggrd.opt.zft = tmp_ramp.zft;

                /* Reset to full scale for dB/dt optimization */
                gy1_pulse->scale = 1;
                gy1r_pulse->scale = 1;

                /* Force the dB/dt optimization to run again */
                /* set_cvs_changed_flag( TRUE ); */
                enforce_minseqseg = PSD_ON;

                /* Perform dBdt optimization on the prescribed values */
                if( (status = calcOptimizedPulses( &loggrd, &pidbdtper, &srderate,
                                                   cfdbdtper, seqEntryIndex,
                                                   dbdt_debug, use_ermes,
                                                   higher_dbdt_flag )) != SUCCESS ) {
                    return status;
                }
    
                if (debug_dbdt) {
                    printf("pos3: minseq=%d, tmin=%d, pidbdtper=%f\n min_seqgrad=%d ", minseqcoil_t, tmin, pidbdtper, min_seqgrad);
                }
            }
        }
    }

    return SUCCESS;
} /* end dbdtlevel_and_calcoptimize */

/*
 *  myscan
 *
 *  Type: Function
 *
 *  Description:
 *    myscan() sets up the scan_info table for a hypothetical
 *    scan. It is controlled by the CV's opslquant, opslthick, 
 *    and opfov. 
 */
void  
myscan( void )
{
    INT i, j;
    INT num_slice;
    FLOAT z_delta;
    FLOAT r_delta;
    /* ENH - 19/Sep/1997 - JAP/GFN */
    /* Variables used for the calculation of oblique rotation */
    FLOAT rot;        /* resulting rotation matrix value */
  
    num_slice = exist(opslquant);

    r_delta = exist(opfov) / num_slice;
    z_delta = exist(opslthick) + exist(opslspace);

    scan_info[0].optloc = 0.5 * z_delta * (num_slice-1);
    scan_info[0].oprloc = myrloc;

    scan_info[0].opphasoff = myphase_off;

    /* begin ENH - 19/Sep/1997 - JAP/GFN */
    rot = cos(gamm) * cos(beta);
    scan_info[0].oprot[0] = rot;

    rot = cos(gamm) * sin(beta) * sin(alpha) -
                                 sin(gamm) * cos(alpha);
    scan_info[0].oprot[1] = rot;

    rot = cos(gamm) * sin(beta)*cos(alpha) +
                                 sin(gamm) * sin(alpha);
    scan_info[0].oprot[2] = rot;

    rot = sin(gamm) * cos(beta);
    scan_info[0].oprot[3] = rot;

    rot = sin(gamm) * sin(beta) * sin(alpha) +
                                 cos(gamm) * cos(alpha);
    scan_info[0].oprot[4] = rot;

    rot = sin(gamm) * sin(beta) * cos(alpha) -
                                 cos(gamm) * sin(alpha);
    scan_info[0].oprot[5] = rot;

    rot = -sin(beta);
    scan_info[0].oprot[6] = rot;

    rot = cos(beta) * sin(alpha);
    scan_info[0].oprot[7] = rot;

    rot = cos(beta) * cos(alpha);
    scan_info[0].oprot[8] = rot;
    /* end ENH */

#ifdef SIM
    rsp_info[0].rsptloc = scan_info[0].optloc;
    rsp_info[0].rspphasoff = scan_info[0].opphasoff;
#endif

    for ( i=1 ; i<num_slice ; i++ ) {
        scan_info[i].optloc = scan_info[i-1].optloc - z_delta;
        scan_info[i].oprloc = i * r_delta;

#ifdef SIM
        rsp_info[i].rsptloc = scan_info[i].optloc;
        rsp_info[i].rspphasoff = scan_info[i].opphasoff;
#endif /* SIM */

        for ( j=0 ; j<9 ; j++ ) {
            scan_info[i].oprot[j] = scan_info[0].oprot[j];
        }
    }
    return;
}

/* ****************************************
   RotateScan

    MRIge91983 - RDP - this is based on MyScan from SpectroCommon.e
   ************************************** */
STATUS
#ifdef __STDC__ 
rotatescan( void )
#else  /* !__STDC__ */
    rotatescan()
#endif /* __STDC__ */
{

    int i, j;
    int num_slice;
    double alpha_rad = 0.0;
    double beta_rad = 0.0;
    double gamma_rad = 0.0;
    float z_delta;		/* change in z_loc between slices */

    alpha_rad = my_alpha * PI / 180.0;  /*around X*/
    beta_rad = my_beta * PI / 180.0;    /*around Y*/
    gamma_rad = my_gamma * PI / 180.0;  /*around Z*/

    num_slice = exist(opslquant) * exist(opvquant);

    z_delta = exist(opslthick)+exist(opslspace);


    short oblpln = PSD_AXIAL;

    if (PSD_OBL == exist(opplane)) 
    {
       setexist(oprlcsiis, PSD_ON);
       setexist(opapcsiis, PSD_ON);
       setexist(opsicsiis, PSD_ON);

       scan_info[0].optloc = 0.5*z_delta*(num_slice-1);

       scan_info[0].oprot[0] = cos(gamma_rad) * cos(beta_rad);
       scan_info[0].oprot[1] = cos(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 - sin(gamma_rad) * cos(alpha_rad);
       scan_info[0].oprot[2] = cos(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 + sin(gamma_rad) * sin(alpha_rad);
       scan_info[0].oprot[3] = sin(gamma_rad) * cos(beta_rad);
       scan_info[0].oprot[4] = sin(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 + cos(gamma_rad) * cos(alpha_rad);
       scan_info[0].oprot[5] = sin(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 - cos(gamma_rad) * sin(alpha_rad);
       scan_info[0].oprot[6] = -sin(beta_rad);
       scan_info[0].oprot[7] = cos(beta_rad) * sin(alpha_rad);
       scan_info[0].oprot[8] = cos(beta_rad) * cos(alpha_rad);

       if( (abs(scan_info[0].oprot[0])
            >= abs(scan_info[0].oprot[1]))
           &&  (abs(scan_info[0].oprot[0])
                >= abs(scan_info[0].oprot[2]))) 
       {
                oblpln = PSD_AXIAL;
       }
       else if( (abs(scan_info[0].oprot[1])
                 > abs(scan_info[0].oprot[0]))
                &&  (abs(scan_info[0].oprot[1])
                     >= abs(scan_info[0].oprot[2]))) 
       {
           oblpln = PSD_SAG;
       }
       else if( (abs(scan_info[0].oprot[2])
                 > abs(scan_info[0].oprot[0]))
                &&  (abs(scan_info[0].oprot[2])
                     > abs(scan_info[0].oprot[1]))) 
       {
           oblpln = PSD_COR;
       }
       opobplane = oblpln;
       switch (exist(opobplane)) {
       case PSD_AXIAL:
           if(!opspf) {   
               opapcsiis = 2;
               oprlcsiis = 1;
           } else {
               opapcsiis = 1;
               oprlcsiis = 2;
           }  

           opsicsiis = 3;
           break;
       case PSD_SAG:
           if(!opspf) {
               opapcsiis = 2;
               opsicsiis = 1;
           } else {
               opapcsiis = 1;
               opsicsiis = 2;
           } 
            
           oprlcsiis = 3;
           break;
       case PSD_COR:
           if(!opspf) {
               oprlcsiis = 2;
               opsicsiis = 1;
           } else {
               opapcsiis = 1;
               opsicsiis = 2;
           } 
  
           opapcsiis = 3;
           break;
       }
           
    
       for(i=1;i<num_slice;i++) {
            scan_info[i].optloc = scan_info[i-1].optloc - z_delta;
            for(j=0;j<9;j++) {
                scan_info[i].oprot[j] = scan_info[0].oprot[j];
            }
       }
    }
    return SUCCESS;
} /* end rotatescan() */


/*
 *  psd_dump_slice_info
 *
 *  Type: Function
 *
 *  Description:
 *    This routine prints a copy of the slice acquisition order.
 */
STATUS
psd_dump_slice_info( void )
{
    INT i;
    INT num_slice;
  

    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases since it creates redundant slices */
    /* MRIge91361 add pass_reps for PURE_cal scan*/
    num_slice = exist(opslquant) * pass_reps * t1map_numTI;

    fprintf( stdout, "\nPSD-> Dump of slice info\n" );

    for ( i=0 ; i<opslquant ; i++ ) { /*gss added*/
        fprintf( stdout, "Slice-> %d scan_info[%d].optloc=%.1f\n", i, i,
                 scan_info[i].optloc );
    }
    fprintf( stdout, "\n" );

    for ( i=0 ; i<num_slice ; i++ ) {
        fprintf( stdout, 
                 "Slice-> %d : slpass=  %d  ; sltime= %d ; slloc = %d  \n",
                 i, data_acq_order[i].slpass, data_acq_order[i].sltime, 
                 data_acq_order[i].slloc );
        /* gss - replaced rsp_info[i].rsptloc w/ 
           data_acq_order[i].slloc which corresponds to the index into 
           scan_info table */
    }

    fprintf( stdout, "\n...\n" );
    fflush(stdout); /*gss*/

    return SUCCESS;
}   /* end psd_dump_slice_info() */


/*
 * Host function for Exorcist - LX2
 */
@inline Exorcist.e ExorcistHost


/*
 *  dump_filter
 *
 *  Type: Function
 *
 *  Description:
 *    Prints out the filter parameters.
 */
STATUS
dump_filter( PSD_FILTER_GEN *spec )
{
    INT i;

    for ( i=0 ; i<4 ; i++ ) {
        if (spec[i].filter_slot==0) {
            fprintf( stdout, "Filter spec %d empty\n", i );
        } else {
            fprintf( stdout, "Filter spec %d:\n", i );

            fprintf( stdout, "Parameter Specifications for slot %ld\n", 
                     spec[i].filter_slot );
      
            fprintf( stdout, "Number of taps = " );
            if (spec[i].taps == 0) {
                fprintf( stdout, "1\n" );
            } else {
                fprintf( stdout, "%ld\n", spec[i].taps );
            }
            fprintf( stdout, "Number of outputs = %ld\n", 
                     spec[i].outputs );
            fprintf( stdout, "Number of taps to prefill = %ld\n", 
                     spec[i].prefills );
      
            fprintf( stdout, "\n Coefficient Specifications\n" );
      
            fprintf( stdout, "Frequency = +/- %f\n", spec[i].filfrq );
        }   /* if slot!=0 */
        fflush(stdout);
    }   /* for i*/

    return SUCCESS;
}   /* end dump_filter() */


/*
 *  create_fgre_pulse
 *
 *  Type: Function
 *
 *  Description:
 *    This is invoked in CVINIT to initialize the 
 *    grad_rf pulse structures.  This sets up a linked
 *    list which precludes the use of a grad_rf.h
 *    file.
 */
STATUS
create_fgre_pulses( PULSE_TABLE *pulse_table )
{
    /* Begin RTIA change */
    FLOAT *temp1_p; 
    FLOAT temp1 = (FLOAT)0.0;
    /* End RTIA change */

    /*
     * rf pulses
     */
    if ( insert_rf_pulse(0, pulse_table, &RF1_SLOT, &pw_rf1, &a_rf1, 
                         SAR_ABS_SINC1, SAR_PSINC1, 
                         SAR_ASINC1, SAR_DTYCYC_SINC1, SAR_MAXPW_SINC1, 1, 
                         MAX_B1_SINC1_90, 
                         MAX_INT_B1_SQ_SINC1_90, MAX_RMS_B1_SINC1_90, 
                         90.0, &flip_rf1, 3200.0, 1250.0, 
                         PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON, 
                         0, 0, 1.0, &res_rf1, 0, &wg_rf1, 1) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.", 
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"rf1");
        return FAILURE;
    }

    find_rf_pulse_by_index(&rf1_pulse, pulse_table, RF1_SLOT);

    /* 
     * x gradient pulses
     */
    /* ENH - Use pos_gxfc in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXFC_SLOT, G_TRAP, 
                            &pw_gxfca, &pw_gxfcd, &pw_gxfc, NULL, &a_gxfc, 
                            NULL, NULL, 0.0, 1, 1.0, &pos_gxfc, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxfc");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gxfc_pulse, pulse_table, GXFC_SLOT, XBOARD);

    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXU_TOUCH_SLOT, G_TRAP,
                            &pw_gxtouchua, &pw_gxtouchud, &pw_gxtouchu, NULL, &a_gxtouchu,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gxtouchu, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxtouchu");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gxtouchu_pulse, pulse_table, GXU_TOUCH_SLOT, XBOARD);
                                                              
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXD_TOUCH_SLOT, G_TRAP,
                            &pw_gxtouchda, &pw_gxtouchdd, &pw_gxtouchd, NULL, &a_gxtouchd,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gxtouchd, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxtouchd");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gxtouchd_pulse, pulse_table, GXD_TOUCH_SLOT, XBOARD);

    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXF_TOUCH_SLOT, G_TRAP,
                            &pw_gxtouchfa, &pw_gxtouchfd, &pw_gxtouchf, NULL, &a_gxtouchf,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gxtouchf, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxtouchf");
        return FAILURE;                                       
    }                                                         
                                                              
    find_grad_pulse_by_index(&gxtouchf_pulse, pulse_table, GXF_TOUCH_SLOT, XBOARD);
     
    /* ENH - Use pos_gx1 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GX1_SLOT, G_TRAP, 
                            &pw_gx1a, &pw_gx1d, &pw_gx1, NULL, &a_gx1, 
                            NULL, NULL, 0.0, 1, 1.0, &pos_gx1, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gx1");
        return FAILURE;
    }

   find_grad_pulse_by_index( &gx1_pulse, pulse_table, GX1_SLOT, XBOARD );

    /* gx2 for positive echo flow comp */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GX2_SLOT, G_TRAP,
                            &pw_gx2a, &pw_gx2d, &pw_gx2, NULL, &a_gx2,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gx2, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gx2");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gx2_pulse, pulse_table, GX2_SLOT, XBOARD );


    /* Begin RTIA change - for unbridging Readout and X killer */ 
    if (!bridge) {
        temp1_p = &temp1;
    } else {
        temp1_p = &a_gxw;
    }
    /* ENH - Use pos_gxw in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXW_SLOT, G_TRAP, 
                            &pw_gxwa, &pw_gxwd, &pw_gxlwr, NULL, &a_gxw, 
                            &a_gxw, temp1_p, 0.0, 1, 1.0, &pos_gxw, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, bridge , 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxw");
        return FAILURE;
    }
    /* End RTIA change */

    find_grad_pulse_by_index( &gxw_pulse, pulse_table, GXW_SLOT, XBOARD );

    /* If multi-echo, gxw2 and gxwex are always bridged. RTIA not supported
       with 2 echoes, DUALECHO modification */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXW2_SLOT, G_TRAP,
                            &pw_gxw2a, &pw_gxw2d, &pw_gxw2, NULL, &a_gxw2,
                            &a_gxw2, &a_gxw2, 0.0, 1, 1.0, &pos_gxw, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxw2");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gxw2_pulse, pulse_table, GXW2_SLOT, XBOARD );

    /* Begin RTIA change */
    if (!bridge) {
        temp1_p = &temp1; 
    } else {
        temp1_p = &a_gxw ;
    }
    /* ENH - Use pos_gxwex in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( XBOARD, 0, pulse_table, &GXWEX_SLOT, G_TRAP, 
                            &pw_gxwexa, &pw_gxwexd, &pw_gxwex, temp1_p, 
                            &a_gxwex, &a_gxwex, NULL, 0.0, 1, 1.0, &pos_gxwex, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, bridge, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxwex");
        return FAILURE;
    }
    /* End RTIA change */
    
    find_grad_pulse_by_index( &gxwex_pulse, pulse_table, GXWEX_SLOT, XBOARD );

    /* 
     * y gradient pulses
     */
    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GYU_TOUCH_SLOT, G_TRAP,
                            &pw_gytouchua, &pw_gytouchud, &pw_gytouchu, NULL, &a_gytouchu,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gytouchu, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gytouchu");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gytouchu_pulse, pulse_table, GYU_TOUCH_SLOT, YBOARD);

    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GYD_TOUCH_SLOT, G_TRAP,
                            &pw_gytouchda, &pw_gytouchdd, &pw_gytouchd, NULL, &a_gytouchd,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gytouchd, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gytouchd");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gytouchd_pulse, pulse_table, GYD_TOUCH_SLOT, YBOARD);

    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GYF_TOUCH_SLOT, G_TRAP,
                            &pw_gytouchfa, &pw_gytouchfd, &pw_gytouchf, NULL, &a_gytouchf,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gytouchf, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gytouchf");
        return FAILURE;
    }

    find_grad_pulse_by_index(&gytouchf_pulse, pulse_table, GYF_TOUCH_SLOT, YBOARD);
    
    /* ENH - Use pos_gy1 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GY1_SLOT, G_ARBTRAP, 
                            &pw_gy1a, &pw_gy1d, &pw_gy1, NULL, &a_gy1a, 
                            &a_gy1b, NULL, 0.0, 1, 1.0, &pos_gy1, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gy1");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gy1_pulse, pulse_table, GY1_SLOT, YBOARD );

    /* ENH - Use pos_gy1r in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GY1R_SLOT, G_ARBTRAP, 
                            &pw_gy1ra, &pw_gy1rd, &pw_gy1r, NULL, &a_gy1ram, 
                            &a_gy1rbm, NULL, 0.0, 1, 1.0, &pos_gy1r, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gy1r");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gy1r_pulse, pulse_table, GY1R_SLOT, YBOARD );

    /* ENH - Use pos_gyfe1 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GYFE1_SLOT, G_TRAP, 
                            &pw_gyfe1a, &pw_gyfe1d, &pw_gyfe1, NULL, 
                            &a_gyfe1, NULL, NULL, 0.0, 1, 1.0, &pos_gyfe1, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gyfe1");
        return FAILURE;
    }
    
    find_grad_pulse_by_index( &gyfe1_pulse, pulse_table, GYFE1_SLOT, YBOARD );

    /* ENH - Use pos_gyfe2 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( YBOARD, 0, pulse_table, &GYFE2_SLOT, G_TRAP, 
                            &pw_gyfe2a, &pw_gyfe2d, &pw_gyfe2, NULL, 
                            &a_gyfe2, NULL, NULL, 0.0, 1, 1.0, &pos_gyfe2, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gyfe2");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gyfe2_pulse, pulse_table, GYFE2_SLOT, YBOARD );


    /* 
     * z gradient pulses
     */
    /* ENH - Use pos_gzrf1 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZRF1_SLOT, G_TRAP, 
                            &pw_gzrf1a, &pw_gzrf1d, &pw_gzrf1, NULL, 
                            &a_gzrf1, NULL, NULL, 0.0, 1, 1.0, &pos_gzrf1, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gzrf1");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gzrf1_pulse, pulse_table, GZRF1_SLOT, ZBOARD );

    /* ENH - Use pos_gz1 in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZ1_SLOT, G_TRAP, 
                            &pw_gz1a, &pw_gz1d, &pw_gz1, NULL, &a_gz1, 
                            NULL, NULL, 0.0, 1, 1.0, &pos_gz1, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gz1");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gz1_pulse, pulse_table, GZ1_SLOT, ZBOARD );

    /* ENH - Use pos_gzfc in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZFC_SLOT, G_TRAP, 
                            &pw_gzfca, &pw_gzfcd, &pw_gzfc, NULL, &a_gzfc, 
                            NULL, NULL, 0.0, 1, 1.0, &pos_gzfc, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gzfc");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gzfc_pulse, pulse_table, GZFC_SLOT, ZBOARD );

    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZU_TOUCH_SLOT, G_TRAP,
                            &pw_gztouchua, &pw_gztouchud, &pw_gztouchu, NULL, &a_gztouchu,      
                            NULL, NULL, 0.0, 1, 1.0, &pos_gztouchu, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gxtouchu");
        return FAILURE;
    }
    
    find_grad_pulse_by_index(&gztouchu_pulse, pulse_table, GZU_TOUCH_SLOT, ZBOARD);
                            
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZD_TOUCH_SLOT, G_TRAP,
                            &pw_gztouchda, &pw_gztouchdd, &pw_gztouchd, NULL, &a_gztouchd,                          
                            NULL, NULL, 0.0, 1, 1.0, &pos_gztouchd, 0,
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",       
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gztouchd");
        return FAILURE;                                       
    }                                                         
                                                              
    find_grad_pulse_by_index(&gztouchd_pulse, pulse_table, GZD_TOUCH_SLOT, ZBOARD);
                                                              
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZF_TOUCH_SLOT, G_TRAP,  
                            &pw_gztouchfa, &pw_gztouchfd, &pw_gztouchf, NULL, &a_gztouchf,
                            NULL, NULL, 0.0, 1, 1.0, &pos_gztouchf, 0,        
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",       
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gztouchf");
        return FAILURE;                                       
    }                                                         
                                                              
    find_grad_pulse_by_index(&gztouchf_pulse, pulse_table, GZF_TOUCH_SLOT, ZBOARD);

    /* ENH - Use pos_gzk in the grad struct - JAP/GFN - 13/Aug/1997 */
    if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZK_SLOT, G_TRAP, 
                            &pw_gzka, &pw_gzkd, &pw_gzk, NULL, &a_gzk, 
                            NULL, NULL, 0.0, 1, 1.0, &pos_gzk, 0, 
                            0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
        epic_error(use_ermes,"insert %s pulse failed.",
                   EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gzk");
        return FAILURE;
    }

    find_grad_pulse_by_index( &gzk_pulse, pulse_table, GZK_SLOT, ZBOARD );

    /*MRIhc20334*/
    if ((feature_flag & FIESTA) && (PSD_OFF != fiesta_intersl_crusher)) {
        if ( insert_grad_pulse( ZBOARD, 0, pulse_table, &GZINTERSLK_SLOT, G_TRAP,
                                &pw_gzinterslka, &pw_gzinterslkd, &pw_gzinterslk, NULL, &a_gzinterslk,
                                NULL, NULL, 0.0, 1, 1.0, &pos_gzinterslk, 0,
                                0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1.0 ) == FAILURE ) {
            epic_error(use_ermes,"insert %s pulse failed.",
                       EM_PSD_INSERT_PULSE_FAILURE,EE_ARGS(1),STRING_ARG,"gzinterslk");
            return FAILURE;
        }

        find_grad_pulse_by_index( &gzinterslk_pulse, pulse_table, GZINTERSLK_SLOT, ZBOARD );
    }
    return SUCCESS;
}   /* end create_fgre_pulses() */

@inline ARC.e ARCsetup


/**
 * Returns non-zero if the additional scan pulldown menu should ignore the system's ability to process
 * top-of-head information for SAR computations. This allows the top-of-head scout scan activation menu
 * to be shown
 *
 * @return    non-zero if the additional scan pulldown menu should be
 *     allowed based on configuration settings.
 */
static int topOfHeadDataCollectionMode(void)
{
    return usablePositionDependentConfigAtMass(opweight);
}

/**
 * Activates and deactivates the Head Scout operation UI element. Will activate
 * if (a) told that automatic addition of the scout is a possibility, (b) the
 * sequence is operating in 3-Plane mode, and (c) the position dependent
 * library detects a proper configuration for analyzing head SAR.
 */
void scoutscanButtonActivation(void)
{
    piaddscannub = ADD_SCAN_HIDE;
    piaddscantype = ADD_SCAN_TYPE_NONE;
    autoadvtoscn = FALSE;
    if( (PSD_3PLANE == exist(opplane)) && topOfHeadDataCollectionMode() )
    {
        piaddscannub = ADD_SCAN_SHOW | ADD_SCAN_AUTO_BUTTON | ADD_SCAN_ON_BUTTON | ADD_SCAN_OFF_BUTTON;
        piaddscantype = ADD_SCAN_HEADLOC_SCOUT;
        autoadvtoscn = cfscoutscanact ? TRUE : FALSE;
    }
}

/*
 *  cvinit
 *
 *  Type: Function
 *
 *  Description:
 *    cvinit() is invoked once and only once when
 *    the psd host process is started up.  Place
 *    code here that is independent of any OPIO
 *    button operation. 
 */
STATUS
cvinit( void )
{

#ifdef ERMES_DEBUG
    use_ermes = 0;
#else /* !ERMES_DEBUG */
    use_ermes = 1;
#endif /* ERMES_DEBUG */

    /* Dual Echo and ASSET option key check */
#ifdef PSD_HW
    decho_option_key_status = !checkOptionKey( SOK_T1BHOLD );
    merge2d_option_key_status = !checkOptionKey( SOK_MERGE2D );
    mfgre2d_option_key_status = !checkOptionKey( SOK_MFGRE2D );
    fgretc_option_key_status =  !checkOptionKey( SOK_FGRETC );
    touch2d_option_key_status = !checkOptionKey( SOK_TOUCH2D );
    mxfgretc_option_key_status =  !checkOptionKey( SOK_REALCARD );
    perf_option_key_status = !checkOptionKey( SOK_PERFUSION );
    cineir_option_key_status = !checkOptionKey( SOK_CINEIR );
    mde3d_option_key_status = !checkOptionKey( SOK_DELENHMT3D );  
    de_option_key_status = !checkOptionKey( SOK_DELENHMT);
    psmde_option_key_status = !checkOptionKey( SOK_PSMDE );
    mdeplus_option_key_status = !checkOptionKey( SOK_MDEPLUS );
    smartDer_option_key_status = !checkOptionKey( SOK_EXPGRAD );
    apx_option_key_status = !checkOptionKey( SOK_APX );
    cardt1map_option_key_status = !checkOptionKey( SOK_CARDT1MAP );
    grad80_option_key_status = !checkOptionKey( SOK_GRAD80 );
    dlspdcine_option_key_status = !checkOptionKey( SOK_DLSPDCINE );
#else /* !PSD_HW */
    decho_option_key_status = PSD_ON;
    merge2d_option_key_status = PSD_ON;
    mfgre2d_option_key_status = PSD_ON;
    fgretc_option_key_status = PSD_ON;
    mxfgretc_option_key_status = PSD_ON;
    perf_option_key_status = PSD_ON;
    touch2d_option_key_status = PSD_ON;
    cineir_option_key_status = PSD_ON;
    mde3d_option_key_status = PSD_ON;
    de_option_key_status = PSD_ON;
    psmde_option_key_status = PSD_ON;
    mdeplus_option_key_status = PSD_ON;
    smartDer_option_key_status = PSD_ON;
    apx_option_key_status = PSD_ON;
    cardt1map_option_key_status = PSD_ON;
    grad80_option_key_status = PSD_ON;
    dlspdcine_option_key_status = PSD_ON;
#endif /* PSD_HW */

     if ((isRioSystem() || isHRMbSystem()) && (!strcmp("fgre_gradspec", get_psd_name())))
     {
         gradspec_flag = PSD_ON;
     }
     else
     {
         gradspec_flag = PSD_OFF;
     }

    if ( (PSD_ON == perfusion_flag) && (PSD_OFF == fgretc_option_key_status) 
        && (PSD_OFF == mxfgretc_option_key_status) && (PSD_OFF == perf_option_key_status) ) 
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "LX FGRE Time Course" );
        return FAILURE;
    }

    if ( (PSD_ON == cineir_flag) && (PSD_OFF == cineir_option_key_status)
            && (PSD_OFF == mde3d_option_key_status) && (PSD_OFF == de_option_key_status) ) 
    {
        epic_error( use_ermes,
                "%s is not available without the option key.",
                EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                STRING_ARG, "Cine IR" );
        return FAILURE;
    }

    if( (sshmde_flag || sshmdespgr_flag) &&
        ((PSD_OFF == mdeplus_option_key_status) || (PSD_OFF == de_option_key_status)) )
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "Single Shot MDE" );
        return FAILURE;
    }

    if( cardt1map_flag && (PSD_OFF == cardt1map_option_key_status) )
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "Cardiac T1 Mapping" );
        return FAILURE;
    }

    if ( (PSD_ON == exist(opairspeed)) && (PSD_OFF == dlspdcine_option_key_status))
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "Sonic DL" );
        return FAILURE;
    }

    cvmax(psd_fov,cfsystemmaxfov);
    cvdef(psd_fov,cfsystemmaxfov);
    
    psd_fov = cfsystemmaxfov;
    
    if ( (PSD_ON == exist(optouch)) && (PSD_OFF == touch2d_option_key_status) )
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "MR-Touch" );
        return FAILURE;
    }

    /* Tracking application*/
    if (!strncasecmp( "fgre_track", get_psd_name(), 10) )
    {
        cvdef(track_flag, PSD_ON); 
        track_flag = PSD_ON;

        if(( existcv(track_flag) && ((exist(track_flag) > 1) || (exist(track_flag) < 0))))
        {
            epic_error(0, "Invalid psd_track entry - select again...", 0, EE_ARGS(0));
            return FAILURE;
        }
    }
    else
    {
        track_flag = PSD_OFF;
    } 
    /*  END - Tracking application */

    /* ***************************************************************
     *                                                               *
     * Supported Imaging Options Where EPIC.h Maximum is Zero        *
     *                                                               *
     *************************************************************** */

    /* Enable SAR burst for 2D FIESTA */
    if( (PSD_SSFP == exist(oppseq)) && (isRioSystem() || isHRMbSystem() || ((isDVSystem() || isKizunaSystem()) && (B0_30000 == cffield) && !is750System())) )
    {
        enableSarBurstMode();
    }
    else
    {
        disableSarBurstMode();
    }

    /*** Phase Sensitive ***/
    cvmax( opphsen, PSD_ON );

     /* PSMDE option key check */
    if( (PSD_ON == exist(opphsen)) && (PSD_OFF == psmde_option_key_status) ) {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "PSMDE" );
        return FAILURE;
    }

    if ( (PSD_ON == exist(optouch)) && existcv(optouch) ) 
    {
        touch_flag = PSD_ON;
    }
    else 
    {
        touch_flag = PSD_OFF;
    }

    /* MERGE option key check */
    if( (PSD_ON == exist(opmer2)) && (PSD_OFF == mfgre2d_option_key_status) ) 
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "2D Multi-Echo FGRE" );
        return FAILURE;
    }

    opautote = PSD_OFF;
    opautotr = PSD_OFF;
    opautorbw = PSD_OFF;

    /* R2* */
    if(PSD_ON == exist(opmer2))
    {
        r2_flag = PSD_ON;
    } else {
        r2_flag = PSD_OFF;
    }

    /* PSMDE */
    if(PSD_ON == exist(opphsen))
    {
        psmde_flag = PSD_ON;
    }
    else
    {
        psmde_flag = PSD_OFF;
    }

    vstrte_init();

    /* By default, enable B1 optimization; deactivate it
       on a per-feature basis. */

    if(PSD_ON == minseqrf_cal)
    {
        cvdef(rfb1opt_flag, 2); /* Default: 2: Use the non-Iterative B1 Opt Method.
                                        1: is the Iterative methods */
    }
    else
    {
        cvdef(rfb1opt_flag,1);
    }

    b1derate_flag = 1; /* Set the b1derate_flag to 1 to use System B1
			    erating + 10% Safety margin. This is currently is
			    supported for 3T ONLY in sysepsupport.c  */

    rfsafetyopt_doneflag = PSD_OFF;
     
    dbdt_disable = 0; /* Start with default value */
    
    /* Multigroup is allowed by default */
    pimultigroup = PSD_ON;

    if(B0_30000 == cffield) {
        p__opfov = 0.0; 
        p__oprbw = 0.0; 
        p__opslthick = 0.0;
        p__opxres = 0;
    }

    /* HD merge_3TC_11.0  */
    if( (cffield >= B0_30000) && !strcmp( "fgre_lp", get_psd_name() ) ){
        lp_mode = 1;
    } else  {
        lp_mode = 0;
    }

    /* Perfusion */
    if ((PSD_ON==exist(opcgate)) && (PSD_ON==exist(opmph)) && (PSD_ON==exist(opsrprep)) &&
    (PSD_OFF==exist(opET)) && (1==exist(opnecho)) && ((PSD_GE==exist(oppseq)) || (PSD_SSFP==exist(oppseq) ) || (PSD_SPGR==exist(oppseq))))
    {
        perfusion_flag=PSD_ON;
    } else {
        perfusion_flag=PSD_OFF;
    }

    if ( perfusion_flag && isLowSarEnabled() && (B0_30000==cffield) &&
         ((discretionaryave<1.00) || (discretionaryhave<1.00)) )
    {
        epic_error(use_ermes, "%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "FGRE Time Course", STRING_ARG, "SAR limit less than 1.0 W/kg");
        return FAILURE;
    }

    /* MERGE option key check */
    if((PSD_ON == exist(opmerge)) && (PSD_OFF == merge2d_option_key_status)) 
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "2D MERGE" );
        return FAILURE;
    }

    /* ME option key check */
    if( (PSD_ON == exist(opmer2)) && (PSD_OFF == mfgre2d_option_key_status) ) 
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "2D Multi-Echo" );
        return FAILURE;
    }

@inline Asset.e AssetCalCVInit
@inline Asset.e AssetCVInit  /* Updated inline for PIUI - RBA , MRIhc42465 */
@inline Asset.e AssetCalCheck
@inline Asset.e AssetCheck
@inline ARC.e ARCInit

    if ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (exist(oppurecal)))
    {
        cvoverride(oppseq, PSD_GE, PSD_FIX_ON, PSD_EXIST_ON);
    }

    /* SWIFT cal is supported only surface receive-only coils */
    if ( ((TX_COIL_BODY == getTxCoilType()) && (RX_COIL_LOCAL == getRxCoilType()))
         && (opncoils > 1)
         && ( (ASSET_CAL == opasset) || (ASSET_REG_CAL == exist(opasset)) ) 
         && !(exist(oppurecal)) )
    {
        swift_cal = PSD_ON;
    }
    else
    {
        swift_cal = PSD_OFF;
    }

    /*MRIge91361*/
    if (exist(oppurecal)) 
    {
        /* Check for invalid imaging options */                          
        if( exist(opfcomp) || (exist(opnpwfactor) > 1.0) ||
            exist(oppomp) || ((exist(opptsize) == 4) && (DATA_ACQ_TYPE_FLOAT != dacq_data_type)) || exist(opsquare) || 
            exist(opscic) || exist(opexor) || exist(opblim) || exist(opmt) || 
            exist(opirmode) || exist(opcgate) || exist(oprtcgate) ||     
            exist(optlrdrf) || exist(opirprep) || exist(opsrprep) || exist(opdeprep) || exist(opmph) || 
            exist(opfulltrain) || exist(opcmon) || exist(opzip1024) || exist(opzip512) ||
            exist(opsmartprep) || exist(opbsp) || exist(opmultistation) || 
            exist(oprealtime) || exist(opt2prep) || exist(opssrf) ||     
            exist(opphsen) || exist(opfluorotrigger) || exist(opassetscan) ) 
        {
            epic_error( use_ermes,                                       
                        "PURE reference scan is not compatible with other imaging options (except Fast )",
                        EM_PSD_ASSET_CAL_OPTIONS_INCOMPATIBLE, EE_ARGS(0) );
            return FAILURE;                                              
        } 
        /* MRIge91361 - Make sure multigroup is OFF for pure cal*/
        pimultigroup = PSD_OFF;                      
    }              

    /*MRIge91361 set pure_ref if use select PURE_CAL in UI*/
    pure_ref = PSD_OFF;
    if (exist(oppurecal)) 
    {
        pure_ref = PSD_ON;
    } 

    /* Begin RTIA change - RJF */
    /* All necessary imaging option CV ranges should be reset here. - RJF */
    cvmax(opcmon, 1);
    cvmax(oprealtime, 1);
    /* MRIge49690 - Changed the default of oprealtime to 0. */
    cvdef(oprealtime, 0);

    /*
     * opplane default needs to be initialized because 
     * this gets changed in realtime init 
     */
    cvdef (opphysplane, 1);
    /* End RTIA change */

    /* these cvs are disabled/altered in et_cvinit for MRIge51748 */
    cvmax(opzip512,1); /* enable zip512 option  DUALECHO BWL */
    cvmax(opptsize,4);
    cvmax(oppomp,1);
    cvmax(opdeprep,1);
    cvmax(oprtcgate,1);
    cvmax(oppseq,17);
    cvmin(oppseq,1);
    cvmax(opirmode,1); 
    cvdef(opirmode,0);
    cvmax(opmultistation, 0);
    cvmin(opflip, 1.0);
    cvmax(opflip, 120.0);
    cvdef(opflip, 30.0);     /* maximum flip angle for truncated sinc */

    /*
     * MRIge68880 - Turn OFF vascular screen setup.  It will be activated
     * in Fmpvas or FastcardPC.
     */
    pivascop  = 0; /* turn off vascular screen */
    piprojnub = 0; /* turn off projection buttons */
    piflanub  = 0; /* turn off flow axis buttons */
    piaddinub = 0; /* turn off additional image buttons */
    piflrcnub = 0; /* turn off flow recon types */
    pivelnub  = 0; /* turn off velocity encoding */

    /* Initialization for Echotrain */
    cvmax(opET, 1);
    cvdef(opET, 0);
    pietlnub = 0; /* turn off etl field. Will be turned ON for Echotrain */
    /* This function has to be called before any feature related calls
       and has to be repeated in cveval() to support "partial evals" */
    et_set_state();
    rhhniter = 0;

    /* For number of Breath Hold on APx window */
    pinbhnub = 1;
    pidefnbh = 1;

    if ( PSD_ON == exist(oprtcgate) )
    {
        piautovoice = 0;
    }
    else
    {
        piautovoice = 1;
    }

    /* Set the feature selection bitmask */
    if(FAILURE == setseqparams(&feature_flag, &seq_type)) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "setseqparams" );
        return FAILURE;
    }

    /* Begin RTIA */
    /* HCSDM00247289 : bridge values reset in cveval based on opnecho */
    if(FAILURE == RTIA_cvinit(feature_flag, &obl_method, &bridge, &cont_flag, &rfb1opt_flag))
    { 
        return FAILURE;
    }

    /* FIESTA2D - Unbridge Readout and X killer */
    /* HCSDM00241267 */
    if( (feature_flag & FIESTA) || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag || dualecho_minTE || (PSD_ON == dualecho_inflow_reduce))
    {
        bridge = 0;
    }

    /* turn on presscfh for cardiac 2D fiesta */
    if( (feature_flag & FIESTA) 
        && (exist(opcoax) != 0)
        && (existcv(opcgate) && (PSD_ON == exist(opcgate)))
        && (existcv(oppscvquant) && (1 == exist(oppscvquant))) )
    {
        presscfh = 1;
    }
    else
    {
        presscfh = 0;
    }

    /* Turn on interslice crusher for ungated 2D fiesta */
    /* HCSDM00716935 */
    if( (feature_flag & FIESTA) && (PSD_3PLANE != opplane)
        && (PSD_OFF == exist(opcgate))
        && (PSD_OFF == exist(opmph))
        && ((PSD_OFF == exist(opsat)) && (PSD_OFF == exist(opspecir))) )
    {   
        /* Tests show 8 dephase cycles in slice dir is enough for 1.5T and 3.0T */
        fiesta_intersl_crusher = 8; 
    }
    else
    {
        fiesta_intersl_crusher = 0;
    }

    /* VAL15tmp YI */
    if(!strcmp("fiestac2d", get_psd_name()))
    {
        cvoverride(opphasecycle, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);
    }

    /* VAL15 02/21/2005 YI */
    cvmax( rhfiesta,1024);
    if(PSD_ON == exist(opphasecycle))
    {
        /* Turn FIESTA-C ON */
        cvoverride(pcfiesta_flag, PSD_ON, PSD_OFF, PSD_OFF);
    }
    else 
    {
        /* Turn FIESTA-C OFF */
        cvoverride(pcfiesta_flag, PSD_OFF, PSD_OFF, PSD_OFF);
    }

    /* Begin RTIA */
    /*
     * Set the gradient calc mode here for selecting the right gradsafety
     * calc technique.
     * Turn OFF linear segment gradient heating method if real-time or RTIA is
     * enabled.
     * For SSSD, linear segment method is used for 3 different rotation matrices
     *
     * NOTE: The gradHeatMethod CV is used in minseq() to decide whether to call
     *       minseqseg() (gradHeatMethod = TRUE -> Linear Segment Method) or
     *       minseqgrad() (gradHeatMethod = FALSE -> Traditional Method).
     */
    if(5550 == cfgradamp)
    {
        gradHeatMethod = PSD_ON;
    }
    else
    {
        gradHeatMethod = (PSD_OFF == exist(oprealtime));
    }

    /* SVBranch HCSDM00126068 Change gradHeatMethod to TRUE for 2D FIESTA RealTime to avoid under voltage issue.
       This is SV specific issue, since XFD heating model is not used when gradHeatMethod is FALSE.
       Changing gradHeatMethod to TRUE will cause UI response time become longer, because calculation in minseq()
       will be performed everytime it is called. However, it is still within acceptable range. */
    if( isSVSystem() && ((PSD_ON == exist(oprealtime)) && (PSD_SSFP == exist(oppseq))))
    {
        gradHeatMethod = PSD_ON;
    }

    /* End RTIA change */

    /* Begin RTIA */
    if(FAILURE == inittargets(&loggrd, &phygrd)) 
    {
        return FAILURE;
    }

    /* Save configurable variables after conversion by setupConfig() */ /* VAL15 02/21/2005 YI */
    if(FAILURE == set_grad_spec(CONFIG_SAVE,glimit,srate,PSD_ON,debug_grad_spec))
    {
        epic_error(use_ermes,"Support routine set_grad_spec failed",
            EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"set_grad_spec");
        return FAILURE;
    }

    /* Flowcomp realtime sequence uses a different pulse table. 
       However use of multiple pulse tables are not supported by modules.
       This is because, the modules set the SLOT values assuming that
       there's only one pulsetable in use. This handicap is overcome by 
       calling the init for FlowComp pulse table here, and assigning the 
       slot values from the modules into other global variables inside the
       function. */ 
    if ( FAILURE == RTIAFlowCompPulseTableInit()) 
    { 
        epic_error( use_ermes, "%s failed.",
                    EM_PSD_ROUTINE_FAILURE, EE_ARGS(1), STRING_ARG,
                    "RTIAFlowCompPulseTableInit" );
        return FAILURE;
    } 
    /* End RTIA */

    if (FAILURE == initialize_pulse_table(&pulse_table))
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "initialize_pulse_table" );
        return FAILURE;
    }

@inline vmx.e SysParmInit  /* vmx - 26/Dec/94 - YI */
@inline vmx.e AcrxScanVolumeInit

    if (FAILURE == SpSatInit(&pulse_table, vrg_sat))
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1),
                    STRING_ARG, "SpSatInit" );
        return FAILURE;
    } 

    if (FAILURE == ChemSat_Init(&pulse_table))
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1),
                    STRING_ARG, "ChemSat_Init" );
        return FAILURE;
    }

    if (FAILURE == prescan_cvinit(&pulse_table, feature_flag))
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "Prescan_cvinit()" );
        return FAILURE;
    }

    /* Include the code generated by the preprocessor */
#include "fgre.cvinit.in"

    /* initialize configurable variables */
    /* MRIhc18005 */

    EpicConf();

    /* If minimize_RFunblank_time, then set rfupa to the default   */
    /* value of rfupacv (50 us).  This will shorten the RF unblank */
    /* time of the sequence.  If this flag is  not enabled, then   */
    /* use the default RF unblank time cfrfupa */
    if( PSD_ON != minimize_RFunblank_time ) {
        rfupacv = -cfrfupa;
    } else {
        rfupacv = 50; 
    }
    
    /* BJM - MRIge54970 check for cerdbw */
    /* RJF - Replaced with the direct call to get_max_hw_rbw()
       New for MGD */
    maxhwrbw = maxHwHalfBwKhz();
        
    
    /* MRIhc18005 */
    if (FAILURE == create_fgre_pulses(&pulse_table)) 
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "create_fgre_pulses");
        return FAILURE;
    }

    if (rotateflag == PSD_ON) {
        rotatescan();
    }
    else if ( exist(use_myscan) == 1 ) {
        myscan();
    }
  
    /* Always force obloptimize execution in cvinit due to scan bug */
    initnewgeo = 1;

    /* Assume restrictive oblique to calculate targets if realtime-RJF*/
    if ( exist(oprealtime) == PSD_ON ) {  
        plane_type = PSD_OBL;
    } else { 
        plane_type = opphysplane; 
    }
    /* End RTIA */

    if ( obloptimize(&loggrd, &phygrd, scan_info, exist(opslquant), 
                     plane_type, exist(opcoax), obl_method, obl_debug, 
                     &initnewgeo, cfsrmode)==FAILURE ) {
        epic_error(use_ermes, "%s failed in %s",
                   EM_PSD_FUNCTION_FAILURE, EE_ARGS(2),
                   STRING_ARG, "obloptimize", STRING_ARG, "cvinit()");
        return FAILURE;
    }

    /*********************
     *  RF1  parameters  *
     *********************/
    a_rf1      = 1.0;
    gscale_rf1 = 1.0;      
    cyc_rf1    = 1.0;    /* No. of  sinc cycles. Note that in 4.x code, 
                            cyc_rf1 was defined as (number of sinc cycles)*4 */
    rf1_pulse->abswidth = SAR_ABS_TRUNC1;
    rf1_pulse->area     = SAR_ATRUNC1;
    rf1_pulse->effwidth = SAR_PTRUNC1;
    rf1_pulse->dtycyc   = SAR_DTYCYC_TRUNC1;
    rf1_pulse->maxpw    = SAR_MAXPW_TRUNC1;
    rf1_pulse->max_b1   = MAX_B1_TRUNC1_24_90;
    rf1_pulse->nom_fa   = 90.0;
    rf1_pulse->act_fa   = &flip_rf1;
    rf1_pulse->nom_pw   = 3.2ms;
    rf1_pulse->nom_bw   = 1250.0;
    rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;

    off90          = 40;   /* offset to where real 90 occurs */
    off_rf1        = 0;
    pw_rf1         = 3.2ms;
    pw_rf1_full    = 3.2ms;
    res_rf1_full   = (int)(pw_rf1_full / RF_UPDATE_TIME);
    alpha_rf1      = 0.46; 
    bw_rf1         = (int)(4.0f * cyc_rf1 / ((float)pw_rf1 / (float)1.0s));
    rf1_pulse->num = 1;
    premid_rf90    = 0;  /* init */
    wg_rf1         = TYPRHO1;
  
    /***************************
     *  Other initializations  *
     ***************************/

    /* For testing multi-slice in evaltool */
    if (rotateflag == PSD_ON) {
        rotatescan();
    }
    else if ( exist(use_myscan) == 1 ) {
        myscan();
    }

    /* option flags */ 
    isi_flag = 1;  /* default isi on */

    /* init for oddnex flags*/
    isNonIntNexGreaterThanOne  = 0;
    isOddNexGreaterThanOne     = 0;
    truenex     = 0;
    
    /* Initializations for advisory panel */
    acq_type       = TYPGRAD;
    flow_comp_type = TYPNFC;
    avminslquant   = 1;
    if((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) avminslquant = 2;
    avminnecho     = 1;
    avminrbw       = 2.0;

    if (opnecho == 2)
    {
        avmaxrbw = (dualecho_minTE) ? maxhwrbw : 125.0; /* HCSDM00241267 */
    }
    else
    {
        avmaxrbw = maxhwrbw;
    }

    avmaxrbw2      = avmaxrbw;
    avmaxfov       = cfsystemmaxfov;
    psd_fov        = avmaxfov;
    avminsldelay   = 50ms;
  
    locktime = 0;

    /* Initialize gating to internal */
    gating = TRIG_INTERN;
  

    /************** CMON initialization - LX2 ***************/
    if (existcv(opcmon) && (exist(opcmon) == PSD_ON)) {
        cmon_flag = PSD_ON;
        cmon_fgre = PSD_ON;   /* initialize cmon_fgre flag on */
    } else {
        cmon_flag = PSD_OFF;
        cmon_fgre = PSD_OFF;      
    }


    /***********************************************
     *  CV Min, CV Max, and CV Error Modification  *
     ***********************************************/
    /* This is a FAST sequence */
    cvmax(opfast, 1);
    cvdef(opfast, 1);
    opfast = 1;
    /* Sequence Type: default to Gradient Recalled Echo */
    cvdef(oppseq, 2);
    opnecho = 1;
    /* MRIge91445: type-in TE value is allowed for all cases */
    cvdef(opautote, PSD_OFF);
    cvmin(opte, TE_MIN);
    cvdef(opte, 10ms);   
    /* TE2: DUALECHO modification */
    cvmin(opte2, 1ms);
    cvdef(opte2, 1ms);
    cvdef(opnecho, 1);          
    /* TR */
    cvdef(optr, 100ms);   
    optr = 100ms;
    /* Nbr of Echos */
    if( feature_flag & MERGE )
    {
        /* TR */
        cvdef(optr, 800ms);  
        optr = 800ms;
        cvmin(opnecho, 3);
        cvmax(opnecho, 16);          
        avminnecho = 3;
        avmaxnecho = 16;
        /* MERGE init eff_te */
        if(cffield <= B0_15000)
            mege_eff_te = MERGE_TE_1HT;
        else if (cffield >= B0_30000)
            mege_eff_te = MERGE_TE_3T;
        pos_read = PSD_ON;  /* acquire positive echoes only */
    } else if ( (feature_flag & MFGRE) || r2_flag ) {
        cvmax(opnecho, 16);
        cvmin(opnecho, 3);
        cvdef(opnecho, 8);
        opnecho = _opnecho.defval;
        avminnecho = 3;
        avmaxnecho = 16;
    } else if (decho_option_key_status) {
        cvmax(opnecho, 2);          
        cvmin(opnecho, 1);
        avminnecho = 1;
        avmaxnecho = 2;
        pos_read = PSD_OFF;
    } else {
        cvmax(opnecho, 1);    
        cvmin(opnecho, 1);
        avminnecho = 1;
        avmaxnecho = 1;
        pos_read = PSD_OFF;
    }

    /* Field Of View (FOV) */
    cvmin(opfov, FOV_MIN);
    cvmax(opfov, 999);
    cvdef(opfov, 310.0);
    /* Slice Thickness */
    cvdef(opslthick, FGRE_DEFTHICK);       /* for shortest minte */
    cvmin(opslthick, MINTHICK);   /* set nominal min thickness here
                                     set actual min in cveval*/
    /* MRIge86472 */
    cvmax(opslthick, FGRE_MAXTHICK);   /* set nominal max thickness here
                                          set actual min in cveval*/
    /* Receiver BandWidth (RBW): default to 31.25Khz */ 
    cvdef(oprbw, 31.25);

    /* Nbr of Slices */
    cvdef(opslquant, 1);          /* set default opslquant to 1 */
    cvmax(slquant1, PHASES_MAX);  /* set max of slquant1 to 512 */

    cvmax(pidmode, 3);        /* Fastcard has a new value for Cardiac/Pause */

    /* MRIge45369 - For high X res values, e.g., 512, the value of 
       cerd_out_points will be more than the upper limit for rhdaxres */
    cvmax( rhdaxres, 1024 );

    /* MRIge85021 - Increase upper slice limit to 1024 */
    cvmod(rhnslices, 0, DATA_ACQ_MAX, 1,
          "opslquant*opphases.",0," ");

    if(perfusion_flag)
    {
        opacqo = PSD_SEQMODE_OFF;
    } else {
        opacqo = PSD_SEQMODE_ON;
    }
    cvdef(opfphases, PHASES_MIN);

    opsldelay = 50ms;

    /*
     * Scan Screen Control Initialization
     * Standard initializations are listed in epic.h
     * Screen values which don't match with epic.h 
     * should be listed here.  Screen values that 
     * are dependent on a operator input CV value
     * should be listed in cveval. 
     * pi<param>val1 is always reserved for the "other"
     * button.
     */

    /* Number of echoes */
    /* MRIge63033 */
    piechdefval = 1;
    if (exist(opmerge)) {
        piechnub  = 0;
    } else if (r2_flag) {
        piechnub = 1+2+4+8;
        piechdefval = 8;
        piechval2 = 4;
        piechval3 = 8;
        piechval4 = 16;
    }
    else if ( decho_option_key_status &&
        (((exist(oppseq) == PSD_GE) || (exist(oppseq) == PSD_SPGR)) &&
         !(exist(opcgate) || exist(opfcomp) || exist(opexor) ||
           exist(oprtcgate) || exist(opcmon) || exist(oprealtime) ||
           exist(opirmode) || exist(opmph) || exist(opET))) ) {
        piechnub  = 2+4;  /* Dual echo modification, DUALECHO */
        piechval2 = 1;
        piechval3 = 2;
    } else {
        piechnub  = 0;
        cvoverride(opnecho,1,PSD_FIX_ON,PSD_EXIST_ON);
    }

    tfe_extra = 0;   /* init to 0 -- full echo case */

    /*MRIhc07629 cal scan only allows for one echo*/
    if (ASSET_CAL == exist(opasset) || (ASSET_REG_CAL == exist(opasset)) || exist(oppurecal)) {
        piechnub = 0;
        cvoverride(opnecho,1,PSD_FIX_ON,PSD_EXIST_ON);

        /* GS - For 7T do not fix the flip and TR. Enable the ui */
        if (B0_70000 == cffield)
        {
            pifanub = 6;
            pifaval2 = 10;
            pifaval3 = 20;
            pifaval4 = 30;
            pifaval5 = 40;
            pifaval6 = 50;

            pitrnub = 6;
            pitrval2 = 300ms;
            pitrval3 = 500ms;
            pitrval4 = 800ms;
            pitrval5 = 1000ms;
            pitrval6 = 2000ms;
        }
    }

    /* Set TE buttons */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ||  (exist(opnecho) == 2) ) {
        pite1nub = 0;
     
        /* MRIhc48258 - ART support for ASSET calibration */ 
        if (PSD_OFF == exist(opsilent))
        {
            if( (cffield == B0_30000) && ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)))
            {
                cvoverride(opautote, PSD_FWINPHS, PSD_FIX_ON, PSD_EXIST_ON);
            }
            else
            {
                /* HCSDM00241267 */
                if (dualecho_minTE)
                {
                    cvoverride(opautote, PSD_MINTE, PSD_FIX_ON, PSD_EXIST_ON);
                }
                else
                {
                    cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
                }
            }
        } 
        else
        {
            /* Minfull TE happens close to out-of-phase TE with ART at 1.5T */
            if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) 
            {
                if( cffield == B0_30000 )
                {
                    cvoverride(opautote, PSD_FWINPHS, PSD_FIX_ON, PSD_EXIST_ON);
                }
                else
                {
                    cvoverride(opautote, PSD_OFF, PSD_FIX_ON, PSD_EXIST_ON);
                }
            }
        }  
    } else if (touch_flag) {
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    } else if (perfusion_flag) {
        pite1nub = 6;
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        cvdef(opautote,PSD_MINTEFULL);
        opautote = PSD_MINTE;
    } else if ( (feature_flag & MFGRE) || r2_flag ) {
        pite1nub = 7;
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        cvdef(opautote,PSD_MINTEFULL);
        opautote = PSD_MINTEFULL;
    } else if (psmde_flag) {
        pite1nub  = 0;
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    } else if ( sshmde_flag || sshmdespgr_flag || cardt1map_flag ) {
        pite1nub  = 0;
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    }  else {
        pite1nub  = 31;   /* MRIge91445 - allow type-in values for TE. */
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        pite1val4 = PSD_FWINPHASETE;
        pite1val5 = PSD_FWOUTPHASETE;
    }

    if ( touch_flag ) 
    {
        pitouch = 1;

        pitouchtphases = 1;
        pitouchfreq = 1;
        pitouchcyc = 1;
        pitouchamp = 1;
        pitouchaxnub = 15;
        pitouchmegfreqnub = 0;
            
        setexist(optouchtphases, PSD_EXIST_ON);
        pideftouchtphases = 4;
        setexist(optouchfreq, PSD_EXIST_ON);
        pideftouchfreq=60;
        setexist(optouchmegfreq, PSD_EXIST_ON);
        pideftouchmegfreq=60;
        setexist(optouchcyc, PSD_EXIST_ON);
        pideftouchcyc=3;
        setexist(optouchamp, PSD_EXIST_ON);
        pideftouchamp = 30;
        setexist(optouchax, PSD_EXIST_ON);
        pideftouchax = 4;
    }  

    if( cffield == B0_30000 ) {
        flag_3t = PSD_ON;
    } else {
        flag_3t = PSD_OFF;
    }

    /* FOV is coil dependent - Handle values in cveval */  
    /* Slice Thickness - Use defaults in epic.h */

    /* Slice Skips - Use defaults in epic.h 
       Interleaving is available */

    /* Slice Locations - Defaulted to 0 in epic.h */

    /* Acquistion Timing */
    pipautype = PSD_LABEL_PAU_ACQ;   /* use "Acq B/4 Pause" as annotation */

    /* Begin RTIA move */
    /* RTIA moved nex pulldown values to cveval */
    /* End RTIA move */

    /*  User CVs for R2 */
    if((feature_flag & MFGRE) || r2_flag)
    {
        pititle = 1;
        cvdesc(pititle, "Options Page");
        piuset |= (use16 | use17);  /* initialize user CV mask */
        if ( PSD_MINTE == exist(opautote) ){
           piuset &= ~use16;
           cvoverride(opuser16, _opuser16.defval, PSD_FIX_ON, PSD_EXIST_ON);
        }
        opuser16 = 1.0;
        cvmod(opuser16, 0.0, 1.0, 1.0, "Readout lobe polarity (0=alternating, 1=positive)",0,"");

        opuser17 = 1.0;
        cvmod(opuser17, 1.0, 4.0, 1.0, "Number of interleaving echo trains (1-4)",0,"");

        pos_read = (int)exist(opuser16);
    }

    if( value_system_flag && ((feature_flag & MFGRE) || r2_flag) && (PSD_OFF == aTEopt_flag) )
    {
        derate_gy1_flag = 1; /* derate_gy1_flag can't be used aTEopt_flag at the same time. */
    }
    else
    {
        derate_gy1_flag = 0;
    }
    extra_derate_gy1 = 1.0;
    pw_gy1_no_derate = 0;
    pw_gy1a_no_derate = 0;
    pw_gy1d_no_derate = 0;
    a_gy1a_no_derate = 0.0;
    a_gy1b_no_derate = 0.0;

    /*
     * Advisory Panel 
     *
     * If piadvise is 1, the advisory panel is supported.
     * piadvmax and piadvmin are bitmaps that describe which
     * advisory panel routines are supported by the psd.
     * Scan Rx will activate cardiac gating advisory panel
     * values if gating is chosen from the gating screen onward.
     * Scan Rx will display the minte2 and maxte2 values 
     * if 2 echos are chosen.
     *
     * Constants for the bitmaps are defined in epic.h
     */
    piadvise = 1; /* Advisory Panel Supported */

    /* bit mask for minimum adv. panel values.*/
    /* add rbw for first echo */
    piadvmin = (1<<PSD_ADVECHO) +
        (1<<PSD_ADVTE) + (1<<PSD_ADVTR) + (1<<PSD_ADVFOV) +
        (1<<PSD_ADVRCVBW);
    piadvmax = (1<<PSD_ADVECHO) +
        (1<<PSD_ADVTE) + (1<<PSD_ADVTR) + (1<<PSD_ADVFOV) +
        (1<<PSD_ADVRCVBW);

    if(aspir_flag)
    {
        piadvmin |= (1<<PSD_ADVTI);
        piadvmax |= (1<<PSD_ADVTI);
    }

    /* bit mask for cardiac adv. panel values */
    piadvcard = (1<<PSD_ADVISEQDELAY) +
        (1<<PSD_ADVMAXPHASES) + (1<<PSD_ADVEFFTR) + 
        (1<<PSD_ADVMAXSCANLOCS) + (1<<PSD_ADVAVAILIMGTIME);
    
    /* bit mask for scan time adv. panel values */
    piadvtime = (1<<PSD_ADVMINTSCAN) + (1<<PSD_ADVMAXLOCSPERACQ) +
        (1<<PSD_ADVMINACQS) + (1<<PSD_ADVMAXYRES);
    

    if (SDL_CheckValidFieldStrength(SD_PSD_FGRE,cffield,use_ermes)==FAILURE) {
        return FAILURE;
    }

    /* Initialize phase/view acquisition order */
    phorder = 0;    /* phase/view ordering: 0=normal, 1=centric */
    viewoffs = 0;   /* nomver of views to offset in centric mode */

    dda = 4;
    ps2_dda = 16;
    ps2_nex = 2;    /* initialize nex loop for ps2 */

    never_mind = PSD_OFF;
  
    /* cvinit for separate features */
    /* These cvinit calls for the separate features are generic
       as they initialize some screens. No logic is needed. */
    if ( prep_cvinit( &pulse_table, feature_flag ) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "prep_cvinit" );
        return FAILURE;
    }

    if ( mpl_cvinit() == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "mpl_cvinit" );
        return FAILURE;
    }

    /* Set min/maxTR for In-Range TR */ 
    if ( feature_flag & MERGE )
    {
        piinrangetrmin = 400ms;
        piinrangetrmax = 1200ms;
    }
    else
    {
        piinrangetrmin = 120ms;
        piinrangetrmax = 250ms;
    }

    if ( mph_cvinit() == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "mph_cvinit" );
        return FAILURE;
    }

    if ( fastcard_cvinit( &pulse_table, feature_flag ) == FAILURE ) {
        epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fastcard_cvinit" );
        return FAILURE;
    } 

    if ( fastcardPC_cvinit(&pulse_table, feature_flag) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fastcardPC_cvinit" );
        return FAILURE;
    } 

    if ( fmpvas_cvinit( &pulse_table, feature_flag ) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fmpvas_cvinit" );
        return FAILURE;
    } 

    /* Fast CINE - Check for option key - 10/Jul/98 - GFN */
    if ( FAILURE == fcine_cvinit() ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fcine_cvinit" );
        return FAILURE;
    }

    /* FIESTA2D - Check for option key - 14/Nov/2000 - AKG */
    if ( FAILURE == fiesta2d_cvinit( use_ermes, feature_flag ) ) {
        return FAILURE;
    }

    /* Tagging - 02/Jun/97 - GFN */
    if ( FAILURE == tagging_cvinit( &pulse_table, use_ermes ) ) {
        return FAILURE;
    }

    /* JAP ET */
    if( et_cvinit(&pw_gxwl, &pw_gxwr, &pw_gyba, &pw_gybd, &pw_gyb, &a_gyb, gxw_pulse, &pulse_table, feature_flag) == FAILURE)
    {
        return FAILURE;
    }
   

    /* HCSDM00445737 */
    if(feature_flag & ECHOTRAIN)
    {
        et_initialized = true;
    }
    else
    {
        et_initialized = false;
    }

    if( PSD_ON == track_flag )
    {
        if( FAILURE == track_cvinit() )
        {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1), STRING_ARG, "track_cvinit");
            return FAILURE;
        }
    }

    /* Begin RTIA */
    if( FAILURE == Hard180_cvinit(&pulse_table) )
    {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1), STRING_ARG, "Hard180_cvinit");
        return FAILURE;
    }
    
    cvmax(psd_slthick, _opslthick.maxval); 
    /* max for opslthick changes in fastcardPC_cvinit() MRIge59599*/
    /* End RTIA */

    /* Setsysparms sets the psd_grd_wait and psd_rf_wait
       parameters for the particular system. */
 

       if ( setsysparms() == FAILURE ) {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                   EE_ARGS(1), STRING_ARG, "setsysparms");
        return FAILURE;
       }

    if (vstrte_flag) {
       psd_grd_wait = 60;
       if (PSD_XRMW_COIL == cfgcoiltype || PSD_IRMW_COIL == cfgcoiltype)
       {
           psd_rf_wait = 112;
       }
       if(isRioSystem() || isHRMbSystem())
       {
           /*HCSDM00453021*/
           psd_rf_wait = 94;
       }
    }



    /* MRIge91882*/ 
    if((((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC))&&(exist(opplane)==PSD_3PLANE))&&
       (!(feature_flag&IRPREP)&& !(feature_flag & FIESTA)))
    {
        cvmax(opmultistation,0);
        cvmax(opirprep,0);
        cvmax(opsrprep,0);
        pite1nub=0;
        cvoverride(opautote, PSD_MINTE, PSD_FIX_ON, PSD_EXIST_ON);
        opflip = 30.0;
        cvmin(opflip,30.0);
        cvmax(opflip,30.0);
        oprbw =31.25;
        oprbw2=31.25;
        cvmin(oprbw,31.25);
        cvmax(oprbw,31.25);
        cvmin(oprbw2,31.25);
        cvmax(oprbw2,31.25);
        _opfast.fixedflag = 0;
        opfast =1;
        _opfast.fixedflag =1;
        _opfast.existflag =1;

#ifdef PSD_HW
        pimultistation =(!checkOptionKey(SOK_SPREP99) &&!checkOptionKey(SOK_SMARTPREP));
#else /* !PSD_HW */
        pimultistation = PSD_ON;
#endif /* PSD_HW */      

        if ( PSD_ON == pimultistation ){
            cvmax( opmultistation, 0 );
        } 
    } else {
        cvmax(opmultistation,0);
        cvdef(opmultistation,0);
        cvoverride(opmultistation,PSD_OFF,PSD_FIX_OFF,PSD_EXIST_ON);
        /* GEHmr03549 : To avoid range out of oprbw2 */
        cvmin(oprbw2, 0.0);
        cvmax(oprbw2, cfmaxbw);
    }

    timecountB = 0;
    timecountE = 0;
    
    if( (PSD_OFF == pircbnub) && (PSD_OFF == exist(opautorbw)) )
    {
        opautorbw = PSD_ON;
    }

    if( (cineir_flag) || (perfusion_flag) || (mde_flag) )
    { 
        rh2dscale = 3.0; 
    }
    else 
    { 
        rh2dscale = 1.0; 
    } 

    /* Set flags for scan volume shift */
    if(!strncasecmp("cal2d", get_psd_name(), 5))
    {
        if( isKizunaSystem() || isRioSystem() || is3TeslaWideSystem() )
        {
            vol_shift_type = VOL_SHIFT_FREQ_DIR_ALLOWED | VOL_SHIFT_PHASE_DIR_ALLOWED | VOL_SHIFT_SLICE_DIR_ALLOWED;
            vol_shift_constraint_type = VOL_SHIFT_CONSTRAINT_UNIQUE_VALUE;
        }
        else
        {
            vol_shift_type = VOL_SHIFT_SLICE_DIR_ALLOWED;
            vol_shift_constraint_type = VOL_SHIFT_CONSTRAINT_UNIQUE_VALUE;
        }
    }

    /* Set flags for scan volume scale */
    if(PSD_ON == exist(oprealtime))
    {
        vol_scale_type = VOL_SCALE_NOT_ALLOWED;
        vol_scale_constraint_type = VOL_SCALE_CONSTRAINT_NONE;
    }
    else
    {
        set_vol_scale_cvs(cfgcoiltype,
                          VOL_SCALE_FREQ_DIR_ALLOWED | VOL_SCALE_PHASE_DIR_ALLOWED,
                          VOL_SCALE_CONSTRAINT_NONE,
                          &vol_scale_type,
                          &vol_scale_constraint_type);
    }

    return SUCCESS;
}   /* end cvinit() */


/* 4/21/96 RJL: Init all new Advisory CV's */
@inline InitAdvisories.e InitAdvPnlCVs

@inline T1Map.e T1MapEval

/*
 *  cveval
 *
 *  Type: Function
 *
 *  Description:
 *    cveval() is called upon every OPIO button push
 *    which has a corresponding CV (95% of the buttons).
 *    Place only that code that has an effect on 
 *    advisory panel results to save on button to
 *    button time.  Other code can be placed in cvinit
 *    or predownload.
 *
 *    VBW is always on for both 1.5T and 0.5T.  First echo
 *    is allowed to have bandwidths other than 16 kHz
 *    along with fractional echo.  Real time filter
 *    generation is also used.
 *    To support V6 1st echo vbw, all cveval() code
 *    has been moved to cveval1() function, which
 *    is called upon entry into cveval().
 *    Additional modifications are made to bw, % frac.
 *    echo, etc.
 */
STATUS
cveval( void )
{
    dbdt_disable = 0; /* Start with default value */

    struct timeval t;
    LONG start_time = 0;
    LONG end_time = 0;

    extern float PSsr_derate_factor;
    extern float PSamp_derate_factor;
    extern float PSassr_derate_factor;
    extern float PSasamp_derate_factor;

    firstecho_dlrecon_weight = PSD_OFF;

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    if(sbm_flag)
    {
        sbm_gx1_scale   = 1.0;
        sbm_gxw_scale   = 1.0;
        sbm_gxwex_scale = 1.0;
        sbm_gy1_scale   = 1.0;
        sbm_gy1r_scale  = 1.0;
        sbm_gz1_scale   = 1.0;
        sbm_gzk_scale   = 1.0;
    }

    scoutscanButtonActivation();

    if( (PSD_XRMW_COIL == cfgcoiltype) && (B0_30000 == cffield) )
    {
        xrmw_3t_flag = PSD_ON;
    }
    else
    {
        xrmw_3t_flag = PSD_OFF;
    }

    /* enable Single Shot MDE FIESTA */
    sshmde_support = PSD_ON;

    /* enable Single Shot MDE SPGR */
    sshmdespgr_support = PSD_ON;

    /* enable CINE IR with 3- and 4-RR triggering */
    cineirhrep_support = PSD_ON;
    cardt1map_support = PSD_ON;

    /* enable PSMDE with 3- and 4-RR triggering */
    psmdehrep_support = PSD_ON;

    if( (PSD_ON == exist(opt1map)) && (PSD_ON == cardt1map_support) ) {
       cardt1map_flag = PSD_ON;
    } else {
       cardt1map_flag = PSD_OFF;
    }

    if( (feature_flag & FASTCARD_MP) &&
        (feature_flag & IRPREP) &&
        (!perfusion_flag) &&
        !(feature_flag & ECHOTRAIN) &&
        (feature_flag & FIESTA) &&
        (PSD_ON == sshmde_support) &&
        (PSD_OFF == cardt1map_flag)  )
    {
        sshmde_flag = PSD_ON;
    }
    else
    {
        sshmde_flag = PSD_OFF;
    }

    /* enable CINE IR with SPGR readout */
    if ( (feature_flag & FASTCARD) &&
         (feature_flag & IRPREP) &&
         (PSD_ON == exist(opirmode)) &&
         (cffield == B0_30000) )
    {
        cineirspgr_support = PSD_ON;
    }
    else
    {
        cineirspgr_support = PSD_OFF;
    }

    if( (feature_flag & FASTCINE) && (PSD_SSFP == exist(oppseq)) 
        && (PSD_ON == dlspdcine_option_key_status) )
    {
        cine_kt_support = PSD_ON;
    }
    else
    {
        cine_kt_support = PSD_OFF;
    }
    

    if( (feature_flag & FASTCARD_MP) &&
        (feature_flag & IRPREP) &&
        (!perfusion_flag) &&
        !(feature_flag & ECHOTRAIN) &&
        (PSD_SPGR == exist(oppseq)) &&
        (PSD_ON == sshmdespgr_support) &&
        (PSD_OFF == cardt1map_flag)  )
    {
        sshmdespgr_flag = PSD_ON;
    }
    else
    {
        sshmdespgr_flag = PSD_OFF;
    }

    if ((feature_flag & FIESTA) && (feature_flag & FASTCINE) && (PSD_ON == cine_kt_support) 
        && (PSD_ON == exist(opairspeed)))
    {
        cine_kt_flag = PSD_ON;
    }
    else
    {
        cine_kt_flag = PSD_OFF;
    }

    if (!strncasecmp( "fgre_track", get_psd_name(), 10 ))
    {
        track_flag = PSD_ON;

        if(( existcv(track_flag) && ((exist(track_flag) > 1) || (exist(track_flag) < 0)))) {
            epic_error(0, "Invalid psd_track entry - select again...", 0, EE_ARGS(0));
            return FAILURE;
        }
    }
    else
    {
        track_flag = PSD_OFF;
    }
    /*  END - Tracking application */

    /* HCSDM00399928 */
    if ( ( (feature_flag & FIESTA) &&
            sshmde_support ) ||
         ( (PSD_SPGR == exist(oppseq)) &&
           sshmdespgr_support ) )
    {
        sshpsmde_support = PSD_ON;
    }
    else
    {
        sshpsmde_support = PSD_OFF;
    }

    if( cardt1map_flag || touch_flag || (feature_flag & ECHOTRAIN) || (exist(opphsen) == PSD_ON) || (exist(opassetscan) == PSD_ON) ||
        (ASSET_REG_CAL == exist(opasset)) || (PURE_CAL == exist(oppure)) )
    {
        npw_flag = NPW_DISABLE;
    }
    else if (cmon_flag == PSD_ON)
    {
        npw_flag = NPW_LIMITED_FACTOR;
    }
    else
    {
        npw_flag = NPW_FLEXIBLE_FACTOR;
    }

    /* RTIA moved this here, because advisory panel
       is based on min values of these CVs - RJF */
    /* Echotrain */
    /* Initialize opxres and opyres default values here, since they
       may change in et_cveval_init() */
    /* The min values for xres and yres are common minimum for all fgre
       modules */

    cvmin(opxres, 64);
    cvmin(opyres, 64);
    cvdef(opxres, 256);
    cvdef(opyres, 128);
    opxres = _opxres.defval;
    opyres = _opyres.defval;
    if (cffield == B0_70000)
    {
        cvmax(opxres, 1024);
        cvmax(opyres, 1024);
    }
    else
    {
        cvmax(opxres, 512);
        cvmax(opyres, 512);
    }
    cvmin(opflip, 1.0);
    cvmax(opflip, 120.0);
    cvdef(opflip, 30.0);     /* maximum flip angle for truncated sinc */
    if( feature_flag & MERGE )
    {
        cvmax(opflip, 50.0);
        cvdef(opflip, 20.0);
    }

    /* 5/21/96 JDM: Init all new Advisory Cvs from InitAdvisories.e */
    InitAdvPnlCVs();

@inline FlexibleNPW.e fNPWeval

    /* HCSDM00342902 */
    gradOpt_iter_reduce_flag = PSD_OFF;

    /* GEHmr02638: smart derating */
    if( (isValueSystem() || (PSD_XRMW_COIL == cfgcoiltype) || PSD_IRMW_COIL == cfgcoiltype || isKizunaSystem() || isRioSystem() || isHRMbSystem() 
        || (isHOPESystem() && ((feature_flag & FIESTA) || perfusion_flag))) && !touch_flag && !vstrte_flag )
    {
        /* GEHmr04246 : support AC model */
        if( isValueSystem() )
        {
            gradCoilMethod = GRADIENT_COIL_METHOD_AC;

            gradOpt_flag = PSD_ON;
            aTEopt_flag  = PSD_ON;
            aTRopt_flag  = PSD_ON;
            gradOpt_TE   = PSD_ON;
            gradOpt_RF   = PSD_ON;
            gradOpt_GX2  = PSD_OFF;
            gradOpt_mode = 1;
            ogsfMin      = 0.1;

            if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) )
            {
                gradOpt_iter_count = 3;
            }
            else
            {
                gradOpt_iter_count = 30;
            }
        }
        /* HCSDM00362877  Set K15 smart derating configuration same as SV */
        else if(isK15TSystem()|| (isHOPESystem() && ((feature_flag & FIESTA) || perfusion_flag)))
        {
            if(isK15TSystem())
            {
                gradCoilMethod = GRADIENT_COIL_METHOD_AC;
            }

            gradOpt_flag = PSD_ON;
            aTEopt_flag  = PSD_ON;
            aTRopt_flag  = PSD_ON;
            gradOpt_TE   = PSD_ON;
            gradOpt_RF   = PSD_ON;
            gradOpt_GX2  = PSD_OFF;
            gradOpt_mode = 1;
            ogsfMin      = 0.1;

            if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) )
            {
                gradOpt_iter_count = 3;
            }
            else
            {
                gradOpt_iter_count = 30;
            }
        }
        else if( (PSD_ON == smartDer_option_key_status) || (B0_15000 == cffield) || (B0_30000 == cffield) || isKizunaSystem() || isRioSystem() || isHRMbSystem() )
        {
            if( ((feature_flag & MERGE) && ((B0_30000 == cffield) || ((int)exist(opuser8)>0))) ||
                (feature_flag & MFGRE) || (feature_flag & FIESTA) )
            {
                gradOpt_flag = PSD_ON;
                aTEopt_flag  = PSD_ON;
                aTRopt_flag  = PSD_ON;
                gradOpt_TE   = PSD_ON;

                /* HCSDM00360457 */
                if( (feature_flag & FIESTA) && (exist(opslthick) > 6.0) )
                {
                    gradOpt_RF = PSD_OFF;
                }
                else
                {
                    gradOpt_RF = PSD_ON;
                }

                gradOpt_GX2  = PSD_OFF;
                gradOpt_mode = 0;
                ogsfMin      = 0.1;

                /* HCSDM00342902 */ /* HCSDM00367489 : removed a condition of flow compensation */
                if(feature_flag & MERGE)
                {
                    gradOpt_iter_reduce_flag = PSD_ON;
                    gradOpt_iter_count = 3;
                }
                else
                {
                    gradOpt_iter_count = 30;
                }
            }
            else if ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) )
            {
                gradOpt_flag = PSD_ON;
                aTEopt_flag  = PSD_ON;
                aTRopt_flag  = PSD_ON;
                if (B0_70000 == cffield)
                    aTRopt_flag = PSD_OFF;
                gradOpt_TE   = PSD_OFF;
                gradOpt_RF   = PSD_OFF;
                gradOpt_GX2  = PSD_OFF;
                gradOpt_mode = 0;
                ogsfMin      = 0.1;
                gradOpt_iter_count = 3;
            }
            else if (perfusion_flag && !(feature_flag & FIESTA) && (isKizuna3TSystem() || (PSD_XRMW_COIL == cfgcoiltype) || (PSD_IRMW_COIL == cfgcoiltype)))
            {
                gradOpt_flag = PSD_ON;
                aTEopt_flag  = PSD_ON;
                aTRopt_flag  = PSD_ON;
                gradOpt_TE   = PSD_ON;
                gradOpt_RF   = PSD_ON;
                gradOpt_GX2  = PSD_OFF;
                gradOpt_mode = 0;
                ogsfMin      = 0.1;
                gradOpt_iter_count = 3;
            }
            else
            {
                gradOpt_flag = PSD_OFF;
                gradOpt_TE   = PSD_OFF;
                gradOpt_RF   = PSD_OFF;
                gradOpt_GX2  = PSD_OFF;
                aTEopt_flag  = PSD_OFF;
                aTRopt_flag  = PSD_OFF;
            }
        }
        else
        {
            gradOpt_flag = PSD_OFF;
            gradOpt_TE   = PSD_OFF;
            gradOpt_RF   = PSD_OFF;
            gradOpt_GX2  = PSD_OFF;
            aTEopt_flag  = PSD_OFF;
            aTRopt_flag  = PSD_OFF;
        } 

        if ((PSD_ON == exist(opmerge)) && (isValueSystem() || (B0_30000 == cffield) || ((int)exist(opuser8)>0)))
        {
            gradOpt_GX2  = PSD_ON;
            gradOpt_mode = 0;
            gradOpt_TEderating_limit  = 0.6;
            gradOpt_RFderating_limit  = 0.6;
            gradOpt_GX2derating_limit = 0.4;
        }
        else if( (2 == exist(opnecho)) && (isValueSystem()) )
        {
            gradOpt_TE   = PSD_OFF;
            gradOpt_RF   = PSD_OFF;
        }
        else if( PSD_PC == exist(oppseq) && (isValueSystem()) )
        {
            aTEopt_flag  = PSD_OFF;
        }
        else if( (feature_flag & MFGRE) || r2_flag )
        {
            gradOpt_GX2  = PSD_ON;
            gradOpt_GX2derating_limit = 0.8;
            gradOpt_mode = 0;
            gradOpt_TE   = PSD_OFF;
            gradOpt_RF   = PSD_OFF;
        }

        /* GEHmr03274 : smart derating OFF for SPT */
        if( PSD_ON == exist(oprealtime) || !strncmp("fgrespt",get_psd_name(),7) )
        {
            gradOpt_flag = PSD_OFF;
            gradOpt_TE   = PSD_OFF;
            gradOpt_RF   = PSD_OFF;
            gradOpt_GX2  = PSD_OFF;
            aTEopt_flag  = PSD_OFF;
            aTRopt_flag  = PSD_OFF;
        }
        
        /* HCSDM00515642: Close gradOpt_TE, gradOpt_RF and aTEopt_flag from Smart derating in Dual Echo */
        if( (2 == exist(opnecho)) && !(feature_flag & MFGRE) && !r2_flag )
        {
            gradOpt_TE   = PSD_OFF;
            gradOpt_RF   = PSD_OFF;
            aTEopt_flag  = PSD_OFF;
            if(B0_15000 == cffield)
            {             
                gradOpt_flag = PSD_OFF; 
                gradOpt_TE   = PSD_OFF;
                gradOpt_RF   = PSD_OFF;
                gradOpt_GX2  = PSD_OFF;
                aTRopt_flag  = PSD_ON;
            }
        }

        /* SVBranch HCSDM00114077: With InP and OutP, the TE may have bigger change.
                          Need bigger tolerance for pseudo convergence */
        if( (PSD_FWINPHS == exist(opautote)) || (PSD_FWOUTPHS == exist(opautote)) )
        {
            gradOpt_nonconv_tor_limit = 0.2;
        }
        else
        {
            gradOpt_nonconv_tor_limit = 0.05;
        }


        /* HCSDM00342902 */
        gradOpt_iter_count_save = gradOpt_iter_count;
    }
    else
    {
        gradOpt_flag = PSD_OFF;
        gradOpt_TE   = PSD_OFF;
        gradOpt_RF   = PSD_OFF;
        gradOpt_GX2  = PSD_OFF;
        aTEopt_flag  = PSD_OFF;
        aTRopt_flag  = PSD_OFF;
        gradOpt_mode = 0;
    }

    if ((PSD_ON == xrmw_3t_flag) || ((PSD_VRMW_COIL == cfgcoiltype) && (B0_30000 == cffield)))
    {
        if( (B0_30000 == cffield) &&
            ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) )
        {
            force_fullte_flag = PSD_ON;
        }
        else
        {
            force_fullte_flag = PSD_OFF;
        }
    }

    if(rfsafetyopt_timeflag)
    {
        timecountB = timecountB + 1;
        gettimeofday(&t, NULL);
        start_time = ((LONG)(t.tv_sec)) * 1000000 + t.tv_usec;   
    }
    /* PI UI MRIhc42465 */
@inline Asset.e AssetEval
    b1derate_flag = 1; /* Set the b1derate_flag to 1 to use System B1
                          derating + 10% Safety margin. This currently is
                          supported for 3T ONLY in sysepsupport.c  */

    if(gradspec_flag)
    {
        cvmax(grad_spec_ctrl, 15);
    }
    else
    {
        cvmax(grad_spec_ctrl, 3);
    }
    /* Prescan gradient derating factor */
    PSsr_derate_factor = 1.0;
    PSamp_derate_factor = 1.0;
    PSassr_derate_factor = 1.0;
    PSasamp_derate_factor = 1.0;

    /* Rio allows 170 T/m/sec upto 4.04 G/cm through extreme gradient
     * spec.  That amplitude does not need spherical model constraint
     * since the three axis composite will be 7.0 G/cm. Use this mode to
     * achieve shorter TR on Fiesta scans and FGRE/FSPGR TimeCourse*/
    if (((feature_flag & FIESTA) || perfusion_flag) && (isRioSystem()))
    {
        grad_alt_flag = PSD_ON;
    }
    else
    {
        grad_alt_flag = PSD_OFF;
    }

    if (grad_alt_flag)
    {
        cvmax(grad_spec_ctrl, 15);
        getRioExtremeGradSpec(PSD_ON, &grad_spec_ctrl, &glimit, &srate);
    }
    else if(gradspec_flag)
    {
        if(isRioSystem()) /* Get Rio gradient spec */
        {
            getRioGradSpec((grad80_option_key_status)?1:2, &grad_spec_ctrl, &glimit, &srate);
        }
        else if(isHRMbSystem()) /* Get HRMB gradient spec */
        {
            getHRMbGradSpec(1, &grad_spec_ctrl, &glimit, &srate);
        }
    }
    else if(!strncmp("fgre_silent",get_psd_name(),11))
    {
        /* VAL15 02/21/2005 YI */
        /* Get gradient spec for silent mode *//* VAL15  04/04/2005 YI */ 
        getSilentSpec(PSD_ON, &grad_spec_ctrl, &glimit, &srate);    
        /* ensure that only slew rate is changed for silent mode */
        grad_spec_ctrl = grad_spec_ctrl & ~GMAX_CHANGE; 
    }
    else
    {
        getSilentSpec(exist(opsilent), &grad_spec_ctrl, &glimit, &srate); 
    }

    /* SVBranch HCSDM00126068. Change glimit to 2.2 for Fiesta RealTime to improve performance.*/
    if( (isSVSystem())
         &&((PSD_ON == exist(oprealtime)) && (PSD_SSFP == exist(oppseq))))
    {
        glimit = 2.2;
        grad_spec_ctrl |= GMAX_CHANGE;
    }
  
    /* Update configurable variables */
    if(set_grad_spec(grad_spec_ctrl,glimit,srate,PSD_ON,debug_grad_spec) == FAILURE)
    {
      epic_error(use_ermes,"Support routine set_grad_spec failed",
        EM_PSD_SUPPORT_FAILURE,1, STRING_ARG,"set_grad_spec");
        return FAILURE;
    }
    /* Skip setupConfig() if grad_spec_ctrl is turned on */
    if(grad_spec_change_flag) { /* YMSmr06931  07/10/2005 YI */
        if(grad_spec_ctrl)config_update_mode = CONFIG_UPDATE_TYPE_SKIP;
        else              config_update_mode = CONFIG_UPDATE_TYPE_ACGD_PLUS;
        inittargets(&loggrd, &phygrd);
    }

    /* PURE Mix */
    model_parameters.gre2d.minph_pulse_index = minph_pulse_index;
    model_parameters.gre2d.spgr_flag = spgr_flag;
    model_parameters.gre2d.t1map_flag = exist(opt1map);
    model_parameters.gre2d.dualecho = (2 == exist(opnecho));
    model_parameters.gre2d.fiesta_flag = feature_flag & FIESTA;
    model_parameters.gre2d.merge_flag = exist(opmerge);
    model_parameters.gre2d.mde_flag = mde_flag;
    model_parameters.gre2d.cine_kt_flag = cine_kt_flag;

@inline vmx.e SysParmEval  /* vmx - 12/26/94 - YI */
@inline vmx.e AcrxScanVolumeEval
@inline FlexibleNPW.e fNPWcheck1

@inline ARC.e ARCEval
@inline loadrheader.e rheaderpredownload

    if (feature_flag & FASTCARD_PC)
    {
        pipure = 0;
    }
    
    /* MRIge90548 - RDP - turning off phase encoding */
    if (nope == 2) {
       autolock = 1;
       rawmode = 1;
    }

    /* By default, enable B1 optimization; deactivate it
       on a per-feature basis. */
    if(PSD_ON == minseqrf_cal)
    {
        cvdef(rfb1opt_flag, 2); /* Default: 2: Use the non-Iterative B1 Opt Method.
                                        1: is the Iterative methods */
    }
    else
    {
        cvdef(rfb1opt_flag,1);
    }

    rfsafetyopt_doneflag = PSD_OFF;

    vstrte_init();
 
    /* Multigroup is allowed by default */
    pimultigroup = PSD_ON;

    if (perfusion_flag && (PSD_OFF==hard90_sat_flag))
    {
        pimultigroup = PSD_OFF;
    }
    /* Views Per Segment (VPS) is OFF by default */
    piviewseg = 0;

    if(PSD_OFF == track_flag)
    {
        pititle = 0;  /* initialize user CV page */
        piuset = 0;   /* initialize user CV mask */
    }
    pitouch = 0;  /* intialize MR-Touch Tab */

@inline T1Map.e T1MapEval1

    /* VAL15 02/21/2005 YI */
    pc_mode = PC_BASIC;
    if( pcfiesta_flag == PSD_ON ) {
        piuset |= use9;
        cvmod( opuser9,0.0,1.0,0.0, "Processing 0:APC 1:SGS",0," " );
        opuser9 = 0;
        pc_mode = (int)opuser9;
    } else {
        if(PSD_OFF == track_flag)
        {
            piuset &= ~use9;
            cvmod( opuser9, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable  9", 0, "" );
            cvoverride(opuser9, _opuser9.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }
    }
    phase_cycles = 1;

    if ((feature_flag & MERGE) || (PSD_ON == cineir_flag))
    {
        piautofa = 1;
    }
    else
    {
        piautofa = 0;
    }

    if ( (feature_flag & MPL) && (PSD_ON == spgr_flag) &&
         (1 == exist(opnecho)) && (PSD_OFF == opdynaplan) &&
         !(feature_flag & RTIA98) )
    {
       spgr_enhance_t1_flag = PSD_ON;
    } else {
       spgr_enhance_t1_flag = PSD_OFF;
    }

    /*  User CVs for R2 */
    if((feature_flag & MFGRE) || r2_flag)
    {
        cvdesc(pititle, "Options Page");
        piuset |= (use16 | use17);  /* initialize user CV mask */
        if ( PSD_MINTE == exist(opautote)  ) {
            piuset &= ~use16 ;
        }
        opuser16 = 1.0;
        cvmod(opuser16, 0.0, 1.0, 1.0, "Readout lobe polarity (0=alternating, 1=positive)",0,"");

        opuser17 = 1.0;
        cvmod(opuser17, 1.0, 4.0, 1.0, "Number of interleaving echo trains (1-4)",0,"");

        pos_read = (int)exist(opuser16);
        intte_flag = (int)exist(opuser17);

        piuset &= ((~use8) & (~use19));
        cvmod( opuser8, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 8", 0, "" );
        cvoverride(opuser8, _opuser8.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        cvmod( opuser19, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 19", 0, "" );
        cvoverride(opuser19, _opuser19.defval, PSD_FIX_OFF, PSD_EXIST_OFF);

        if ( ((intte_flag*exist(opnecho) > avmaxnecho) || (exist(opnecho)%2!=0 && !pos_read)) 
                       && existcv(opnecho) ) 
        {
            int temp_necho;

            if ( (intte_flag*exist(opnecho) > avmaxnecho) )
                temp_necho = (int)(avmaxnecho/intte_flag);
            else
                temp_necho = opnecho;

            temp_necho = IMax(2, temp_necho, avminnecho);

            if(!pos_read) 
            {
                temp_necho = (int)(temp_necho/2)*2; /* even # of echoes for alternating readout */
                if(temp_necho < avminnecho) 
                {
                    temp_necho = ceil((float)avminnecho/2.0)*2;

                    epic_error( use_ermes, "Minimum number of echos is %-d",
                                EM_PSD_MIN_NECHO_OUT_OF_RANGE, 1, INT_ARG, temp_necho);
                    return FAILURE;
                }
            } 

            epic_error( use_ermes, "Maximum number of echos is %-d",
                        EM_PSD_NECHO_OUT_OF_RANGE, 1, INT_ARG, temp_necho);
            return FAILURE;

        }
    } else if ( (feature_flag & MERGE) || (PSD_ON == spgr_enhance_t1_flag) ) {
        if(!track_flag)
        {
            piuset |= use8;
            cvmod(opuser8, 0.0, 1.0, 0.0, "RF1 Type, 0:Legacy 1:New", 0, "");
            opuser8 = _opuser8.defval;
            if (feature_flag & MERGE) {
                piuset |= use19;
                cvmod(opuser19, 0.0, 2.0, 1.0, "Spatial Sat. Level, 0: Light, 1: Medium, 2: Strong",0,"");
                opuser9 = _opuser9.defval;
            } else {
                piuset &= (~use19);
                cvmod( opuser19, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 19", 0, "" );
                cvoverride(opuser19, _opuser19.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            }
        }
    } else {
        intte_flag = 1;
        if(PSD_OFF == track_flag) 
        {
            if(cardt1map_flag) {
                piuset &= ~use17;
            } else {
            piuset &= ((~use17) & (~use8) & (~use19));
            }
            cvmod( opuser8, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 8", 0, "" );
            cvoverride(opuser8, _opuser8.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            cvmod( opuser17, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 17", 0, "" );
            cvoverride(opuser17, _opuser17.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            if(!cardt1map_flag) {
            cvmod(opuser19, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 19", 0, "" );
            cvoverride(opuser19, _opuser19.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            }
            if(!perfusion_flag)
            {
                piuset &= ~use16;
                cvmod( opuser16, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 16", 0, "" );
                cvoverride(opuser16, _opuser16.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            }
        }
    }

    if((PSD_OFF == track_flag) && (PSD_OFF == cardt1map_flag))
    {
        if ( cineirspgr_support && cineir_flag && (PSD_ON == mdeplus_option_key_status) && (PSD_ON == de_option_key_status) )
        {
            piuset |= use23;
            opuser23 = 0;
            cvmod(opuser23,0,1,0,"SPGR mode (0 = OFF, 1 = ON)",0,"opuser23 value out of range");
        }
        else if ( !value_system_flag )
        {
            piuset &= ~use23;
            cvmod( opuser23, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 23", 0, "" );
            cvoverride(opuser23, _opuser23.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }
    }

    if ( cineirspgr_support && cineir_flag &&
         ((PSD_GE == exist(oppseq)) || (PSD_SPGR == exist(oppseq))) )
    {
        if (floatsAlmostEqualEpsilons(exist(opuser23), 1.0, 2) )
        {
            cvoverride(oppseq, PSD_SPGR, PSD_FIX_ON, PSD_EXIST_ON);
        }
        else
        {
            cvoverride(oppseq, PSD_GE, PSD_FIX_ON, PSD_EXIST_ON);
        }
    }

    if (PSD_OFF == track_flag)
    {
        if( !(existcv(opnumgroups) && (1 < exist(opnumgroups))) &&
            !(existcv(opcoax) && (0 == exist(opcoax))) &&
            (PSD_3PLANE != exist(opplane)) &&
            (PSD_OFF == exist(oprtcgate)) && (PSD_OFF == exist(opnav)) && (PSD_OFF == exist(opcgate)) && (PSD_OFF == exist(opcmon)) &&
            (PSD_OFF == exist(oprealtime)) && (strncmp("cal2d", get_psd_name(), 5)) &&
            ( (feature_flag & MPL) && !(feature_flag & MERGE) && !(feature_flag & ECHOTRAIN) && !(feature_flag & MFGRE) ) )
        {
            piuset |= use6;
            cvmod( opuser6,0,1,0, "In-flow signal reduction: OFF=0, ON=1",0,"must be 0 or 1.");
            opuser6 = 0;
        }
        else
        {
            piuset &= ~use6;
            cvmod( opuser6, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable  6", 0, "" );
            cvoverride(opuser6, _opuser6.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }

        if(PSD_ON == (int)exist(opuser6))
        {
	    if ((PSD_ON == exist(opccsat)) || (PSD_ON == exist(opfat)) || (PSD_ON == exist(opwater)))
            {
                seq_sl_order_flag = PSD_OFF;
                mpl_discard_flag = PSD_OFF;                                                                             
            }
            else
            {
                seq_sl_order_flag = PSD_ON;
                mpl_discard_flag = PSD_ON;
            }
        }
        else
        {
            seq_sl_order_flag = PSD_OFF;
            mpl_discard_flag = PSD_OFF;
        }

        pititle = (piuset !=0);
    }

    /* Fermi filer optimization */
    if (PSD_OFF == track_flag)
    {
        if (strncasecmp("cal2d", get_psd_name(), 5) && (exist(opairecon) == DL_RECON_MODE_OFF) && (PSD_OFF == cine_kt_flag))
        {
            piuset |= use20;
            cvmod( opuser20, 0.0, 2.0, 1.0, "Apodization Level: 0=Weak, 1=Medium, 2=Strong", 0, "" );
            opuser20 = _opuser20.fixedflag ? opuser20 : _opuser20.defval;
            if( existcv(opuser20) && ((exist(opuser20) < _opuser20.minval) || (exist(opuser20) > _opuser20.maxval)) )
            {
                epic_error(use_ermes,"%s is out of range",EM_PSD_CV_OUT_OF_RANGE,
                           EE_ARGS(1),STRING_ARG,"UserCV20");
                return FAILURE;
            }
            apodize_level_flag = (int)exist(opuser20);
        }
        else
        {
            piuset &= ~use20;
            cvmod( opuser20, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 20", 0, "" );
            cvoverride(opuser20, _opuser20.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            apodize_level_flag = APODIZE_WEAK;
        }
    }

    /* C3 recon for MERGE */
    /* use CV27 to turn on ASSET_COMBINE_NO_TWMENPO on 3T for MERGE */
    char attribute_result[ATTRIBUTE_RESULT_SIZE] = "";
    getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CATEGORY, attribute_result);
    int mergeC3_enable_anatomy = PSD_OFF;
    if ((strstr(attribute_result, "Spine")) || (strstr(attribute_result, "LowerExtremities")))
    {
        mergeC3_enable_anatomy = PSD_ON;
    }
    else
    {
        mergeC3_enable_anatomy = PSD_OFF;
    }

    char attribute_codeMeaning[ATTRIBUTE_RESULT_SIZE] = "";
    getAnatomyAttributeCached(exist(opanatomy), ATTRIBUTE_CODE_MEANING, attribute_codeMeaning);

    if ( ((B0_70000 == cffield) || (B0_30000 == cffield) || (B0_15000 == cffield)) && (RX_COIL_BODY != getRxCoilType() || isDstMode(coilInfo))
        && ((int)getRxNumChannels() > 1)
        && !((PSD_3PLANE == opplane) || (PSD_ON == oprealtime) || (PSD_ON == touch_flag) || (PSD_ON == track_flag) || (feature_flag & FASTCARD)
             || (feature_flag & ECHOTRAIN) || (feature_flag & FASTCARD_PC) || (feature_flag & TAGGING) || (feature_flag & FASTCINE)
             || (PSD_PC == exist(oppseq)) || (PSD_ON == cineir_flag) || opasset) )
    {
        cal_based_optimal_recon_enabled = PSD_ON;
    }
    else if((opairecon > DL_RECON_MODE_OFF) && !opasset && ((int)getRxNumChannels() > 1))
    {
        cal_based_optimal_recon_enabled = PSD_ON;
    }
    else
    {
        cal_based_optimal_recon_enabled = PSD_OFF;
    }

    if ((exist(opmerge) == PSD_ON) && (floatsAlmostEqualEpsilons(fn, 1.0, 2)) && (mergeC3_enable_anatomy == PSD_ON) && (cal_based_optimal_recon_enabled == PSD_OFF))
    {
        piuset |= use27;

        if (strstr(attribute_result, "Spine"))
        {
            cvmod( opuser27, 0.0, 1.0, 1.0, "Background suppression: 0=Off, 1=On", 0, "" );
        }
        else
        {
            cvmod( opuser27, 0.0, 1.0, 0.0, "Background suppression: 0=Off, 1=On", 0, "" );
        }

        opuser27 = _opuser27.fixedflag ? opuser27 : _opuser27.defval;

        if( existcv(opuser27) && ((exist(opuser27) < _opuser27.minval) || (exist(opuser27) > _opuser27.maxval)) )
        {
            epic_error(use_ermes,"%s is out of range",EM_PSD_CV_OUT_OF_RANGE,
                       EE_ARGS(1),STRING_ARG,"UserCV27");
            return FAILURE;
        }                                                                                                          
        channel_combine_mode = (int)exist(opuser27);
    }
    else
    {
        piuset &= ~use27;
        cvmod( opuser27, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 27", 0, "" );
        cvoverride(opuser27, _opuser27.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        channel_combine_mode = PSD_OFF;
    } 

    if( cal_based_optimal_recon_enabled == PSD_ON )
    {
        rhchannel_combine_method = RHCCM_ASSET_COMBINE_NO_TWMENPO;
    }
    else if( psmde_flag )
    {
        ihte2 = act_te;
        if( PSD_OFF == exist(opassetscan) )
        {
            rhchannel_combine_method = RHCCM_C3_RECON_FOR_PHASE_I_Q_IMAGES;
        }
        else
        {
            rhchannel_combine_method = RHCCM_SUM_OF_SQUARES;
        }
    }
    else if( channel_combine_mode == 1 )
    {
        rhchannel_combine_method = RHCCM_C3_RECON_FOR_MAG_PHASE_I_Q_IMAGES;
        rhchannel_combine_filter_type = RHCHANNEL_COMBINE_FILTER_TYPE_BESSEL;
        rhchannel_combine_filter_beta = 2.0f;
        if( isK15TSystem() || isValueSystem() )
        {
            rhchannel_combine_filter_width = 0.2f;
        }
        else
        {
            rhchannel_combine_filter_width = 0.1f;
        }
    }
    else
    {
        rhchannel_combine_method = RHCCM_SUM_OF_SQUARES;
        rhchannel_combine_filter_type = RHCHANNEL_COMBINE_FILTER_TYPE_NONE;
        rhchannel_combine_filter_beta = 2.0f;
        rhchannel_combine_filter_width = 0.3f;
    }


    intte_flag = IMax(2, intte_flag, 1);

    if (feature_flag & MERGE)
    { 
        if (!strncmp("2dmerge_classic",get_psd_name(),15))
        {
            vrg_sat = 2;
        } else {
            vrg_sat = 3;
        }
        rhfiesta = 1;
    } else {
        rhfiesta = 0;
        vrg_sat = 2;
    }

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    if( (feature_flag & FIESTA) && ((feature_flag & FGRE) || (feature_flag & MPH)) && gradOpt_flag &&
        isSVSystem() )
    {
        pititle = 1;
        cvmod( opuser24, 0, 1.0, 0.0, "Smart Burst Mode: 0- Off, 1-On ", 0, "" );
        opuser24 = _opuser24.defval;
        piuset |= use24;
        if ( (_opuser24.minval > exist(opuser24)) ||
             (_opuser24.maxval < exist(opuser24)) )
        {
            if(exist(opuser24) < _opuser24.minval)
            {
                cvoverride(opuser24, _opuser24.minval, PSD_FIX_ON, PSD_EXIST_ON);
            }
            if(exist(opuser24) > _opuser24.maxval)
            {
                cvoverride(opuser24, _opuser24.maxval, PSD_FIX_ON, PSD_EXIST_ON);
            }
            epic_error( use_ermes, "%s must be set to 0-1.",
                        EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, "Smart burst mode" );
            return FAILURE;
        }

        if(existcv(opuser24) && !floatsAlmostEqualEpsilons(exist(opuser24), 0.0, 2))
        {
            /* In order to keep scan time for one slice/shot is small enough */
            if(((exist(opnex)*exist(opfphases)) <= SBM_MAX_NEX_PHASE))
            {
                sbm_flag = PSD_ON;
            }
            else
            {
                char tmp_str[100];
                sprintf(tmp_str,"%s %d","NEX*PHASE >",SBM_MAX_NEX_PHASE);
                epic_error( use_ermes, "%s is incompatible with %s.",
                            EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                            STRING_ARG, "Smart Burst Mode",
                            STRING_ARG, tmp_str);
                return FAILURE;
            }
        }
        else
        {
            sbm_flag = PSD_OFF;
        }

        if(sbm_flag)
        {
            cvmod( opuser22, 1.0, 2.0, 1.35, "Effect of TR reduction ", 0, "" );
            opuser22 = _opuser22.defval;
            piuset |= use22;
            if ( (_opuser22.minval > exist(opuser22)) ||
                 (_opuser22.maxval < exist(opuser22)) )
            {
                cvoverride(opuser22, _opuser22.defval, PSD_FIX_ON, PSD_EXIST_ON);
                epic_error( use_ermes ,"%s is out of range.",
                            EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1), STRING_ARG, "Effect of TR reduction" );
                return FAILURE;

            }
            sbm_smartderating_factor = exist(opuser22);
            avecrushpepowscale_for_SBM_XFD = 1;
        }
        else
        {
            if( (PSD_OFF == track_flag) && (cardt1map_flag == PSD_OFF) )
            {
                piuset &= ~use22;
                cvmod( opuser22, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 22", 0, "" );
                cvoverride(opuser22, _opuser22.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            }
            avecrushpepowscale_for_SBM_XFD = 0;
        }
    }
    else
    {
        sbm_flag = 0;
        if( (PSD_OFF == track_flag) && (PSD_OFF == cardt1map_flag) )
        {
            piuset &= ~use24;
            cvmod( opuser24, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 24", 0, "" );
            cvoverride(opuser24, _opuser24.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
            piuset &= ~use22;
            cvmod( opuser22, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable 22", 0, "" );
            cvoverride(opuser22, _opuser22.defval, PSD_FIX_OFF, PSD_EXIST_OFF);
        }
    }

    /* Begin ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        /* limit the asset calibration scan Z FOV */
        int asset_zfov_max_slquant = ceil(ASSET_MAX_ZFOV/(exist(opslthick)+exist(opslspace)));

        avmax_asset_slquant = IMin(2, ASSET_MAX_SLQUANT, asset_zfov_max_slquant);
      
        if( exist(opplane) != PSD_AXIAL ) {
            epic_error( use_ermes, "%s plane must be selected for %s.",
                        EM_PSD_PLANE_SELECTION, EE_ARGS(2), STRING_ARG, "Axial", 
                        STRING_ARG, "Asset or PURE Calibration");
            return FAILURE;
        }

        /* MRIge70702 - Make sure multigroup is OFF for ASSET Calibration */
        pimultigroup = PSD_OFF;

        /* MRIge89250 - Push out the ASSET Cal data acquisition window */
        pw_gxwlex = 240;
    } else {
        /* Make sure default is zero for all other cases */
        pw_gxwlex = 0;
    }
    /* End ASSET */

    /* Set slice spacing to positive by default */
    pi_neg_sp = 0;
    /*MRIge92367*/
    pioverlap = 0;

    /* Turn on extra readout period by default for all FGRE-based scans.
       This can be reset by the individuals cveval_init() calls of the
       feature modules. */
    gxwex_on = 1;

    /* Set default for additional SSP time for non-Echotrain scans.
       This will be reset by et_cveval(). */
    et_ssp_time = 0;

    /* Set isi time for interrupt to complete here only for gated scans  */
    if( existcv(opcgate) && (PSD_OFF != exist(opcgate)) ) {
        minisi_delay = 200;
    }
    
    /* Set default for X killer time for non-Echotrain scans.
       This will be reset by et_cveval(). */
    gxktime = 0;

    /* RTIA moved this here, because advisory panel 
       is based on min values of these CVs - RJF */

    /* Begin RTIA */
    /* Initialize the maximum value of the Imaging option CVs changed 
       by RTIA_cveval_init calls here. */
    cvmax (opfulltrain,0);
    cvmax (optlrdrf,0);
    cvmax(opbsp,0);
    cvmax(opsmartprep,0);
    cvmax(opzip1024, 1);
    cvmax(opzip512,1); /* enable zip512 option DUALECHO BWL */
    /* End RTIA */

    /* Begin ET- realtime - RJF */
    if( exist(oprealtime) == PSD_ON ) { 
        cvmax(rhexecctrl, 65535);
    }
    /* End ET_realtime */

    /* Initializations for advisory panel */
    acq_type       = TYPGRAD;
    flow_comp_type = TYPNFC;
    avminslquant   = 1;
    if((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) avminslquant = 2;
    avminte        = 1ms;
    avmaxte        = 1000ms;
    avminte2       = 1ms;
    avmaxte2       = 1000ms;
    avmintr        = 1ms;
    avmaxtr        = 6000ms;

    avmaxfov       = cfsystemmaxfov;
    if( maxfov(&avmaxfov) == FAILURE ) {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                   EE_ARGS(1), STRING_ARG, "maxfov" );
        return FAILURE;
    }
    psd_fov = avmaxfov;

    avminsldelay   = 50ms;
    avminflip = 1.0;

    /* Number of echoes */
    /* MRIge63033 */
    piechdefval = 1; 
    if (exist(opmerge)) {
        piechnub  = 0;
    } else if (r2_flag) {
        piechnub = 1+2+4+8; /* bit mask */
        piechdefval = 8; 
        piechval2 = 4;
        piechval3 = 8;
        piechval4 = 16;
    } else if ( decho_option_key_status &&
                (((exist(oppseq) == PSD_GE) || (exist(oppseq) == PSD_SPGR)) &&
                 !(exist(opcgate) || exist(opfcomp) || exist(opexor) ||
                   exist(oprtcgate) || exist(opcmon) || exist(oprealtime) ||
                   exist(opirmode) || exist(opmph) || exist(opET))) ) {
        piechnub  = 2+4;  /* Dual echo modification, DUALECHO */
        piechval2 = 1;
        piechval3 = 2;
    } else {
        piechnub  = 0;
        cvoverride(opnecho,1,PSD_FIX_ON,PSD_EXIST_ON);
    }


    /*MRIhc07629 cal scan only allows for one echo*/
    if (ASSET_CAL == exist(opasset) || (ASSET_REG_CAL == exist(opasset)) || exist(oppurecal)) {
        piechnub = 0;
        cvoverride(opnecho,1,PSD_FIX_ON,PSD_EXIST_ON);
    }

    if (cffield == B0_70000)
    {
        cvdesc(pititle, "Options Page");

        if ((feature_flag & FASTCARD) ||
            (feature_flag & FASTCARD_PC) ||
            (feature_flag & FASTCARD_MP) ||
            (feature_flag & TAGGING) ||
            (feature_flag & ECHOTRAIN) ||
            (feature_flag & FASTCINE) ||
            (feature_flag & RTIA98) ||
            (feature_flag & FIESTA) ||
            (feature_flag & MERGE) ||
            (feature_flag & MFGRE) ||
            (feature_flag & TOUCH) ||
            (exist(oprealtime) == PSD_ON) ||
            (exist(opasset) == ASSET_CAL) ||
            (exist(opasset) == ASSET_REG_CAL) ||
            (pure_ref == PSD_ON) )
        {
            avmaxxres = 512;
            cvmax(opxres, 512);
            avmaxyres = 512;
            cvmax(opyres, 512);
        }
        else
        {
            avmaxxres = 1024;
            cvmax(opxres, 1024);
            avmaxyres = 1024;
            cvmax(opyres, 1024);
        }
    }

    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        cvdef(oprbw, 31.25);
        cvoverride(oprbw, 31.25, PSD_FIX_ON,PSD_EXIST_ON);
        avminrbw = 31.25;
        avmaxrbw = 31.25;
    } else if( opnecho == 2 && !(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag ) {  /* DUALECHO BWL */

        /* HCSDM00241267 : always MINTE so always Full Nex */
        avminnex = (dualecho_minTE) ? 1.0 : 0.0;
        avmaxnex = (dualecho_minTE) ? 2.0 : 1.0;

        /* MRIge92350 - 1.5T Dual Echo - oprbw will no longer be forced to be 62.5 or 125.0. 
           It will be calculated inside setPulseParams. */
        if( (exist(opxres) < 300) && (existcv(opxres) == PSD_ON) && (cffield < B0_15000) ) 
        {
            cvdef(oprbw, 62.5);
            cvoverride(oprbw, 62.5, (existcv(oprbw)), PSD_EXIST_ON);
            avminrbw = 62.5;
            avmaxrbw = 62.5;
        } else if( cffield == B0_30000 ) {
            pidefrbw = 125.0;
            cvdef(oprbw, pidefrbw);
            oprbw = pidefrbw;

            /* MRIge91751 - opened up the allowed rBW; avminrbw used to be 125.0 and is now 50.0 */
            /* rBW is locked out for now; user can not type in from scan screen.                 */
            avminrbw = (dualecho_minTE) ? dualecho_llimrbw_min : dualecho_llimrbw_mf;
            avmaxrbw = (dualecho_minTE) ? dualecho_ulimrbw_min : dualecho_ulimrbw_mf;

            pircbnub = 0;

            /* MRIge91751 - increased the allowed maximum opxres from 320 to 512. */
            /* MRIge92503 - decreased the allowed minimum opxres from 256 to 128. */ 
            avminxres = 128;
            avmaxxres = 512;
            cvmin(opxres, 64);
            cvmax(opxres, 512);
        } else if( cffield == B0_15000 ) {
        /* MRIge92350 - 1.5T Dual Echo */
            pidefrbw = 62.5;
            cvdef(oprbw, pidefrbw);
            oprbw = pidefrbw;
            avminrbw = 50.0;
            avmaxrbw = 166.67;

            pircbnub = 0;
	
            avminxres = 128;
            avmaxxres = 512;
            cvmin(opxres, 128);
            cvmax(opxres, 512);
        } else {
            cvdef(oprbw, 125.0);
            cvoverride(oprbw, 125.0, (existcv(oprbw)), PSD_EXIST_ON);
            avminrbw = 125.0;
            avmaxrbw = 125.0;
       }

    } else {
        cvdef(oprbw, 31.25); /* Reset default value of oprbw to 31.25,
                                since this can be changed in et_cveval_init */
        oprbw = 31.25;

        if(feature_flag & MERGE)
        {
            avminxres = 256;
            avmaxxres = 512;
            cvmin(opxres, 256);
            cvmax(opxres, 512);

            avminrbw = 15.63;
            avmaxrbw = 125;
            if(cffield == B0_30000)
            {
                cvdef(oprbw, 41.67); /* set default for 3T MERGE */ 
                oprbw = 41.67;
            }
        } else {
            avminrbw = 2.0;
            avmaxrbw = maxhwrbw;
        }
    }

    /* MRIhc02807: For 3T whole mode dualecho, default SAT thickness was 80.
       Removed this special treatment.  With satthick = 80, ghosting artifact
       was observed. */

    pisatthickz = 40; /* Displayed default SAT thickness */
    pisatthickx = 40; 
    pisatthicky = 40;
    opdfsathick1 = 40.0; /* Default SAT thickness */
    opdfsathick2 = 40.0;
    opdfsathick3 = 40.0;
    opdfsathick4 = 40.0;
    opdfsathick5 = 40.0;
    opdfsathick6 = 40.0;

    avmaxrbw2 = avmaxrbw;

    act_te = 0;
    act_tr = 0;
    
    locktime = 0;

    /*
     * Initialization for Echotrain.  This function has to be called
     * before any feature related calls and, although it was already
     * called in cvinit(), it has to be repeated in cveval() to support
     * "partial evals"
     */
    et_set_state();

    short_rf = 0;
    fast_pass = 0;
    TR_PASS = 20ms;

   /* MRIhc29155 - rreduce the DDA for gated tof to enhance vessel signal (shorter minimum delay) */
    if ( (feature_flag & GATEDTOF) && !(feature_flag & IRPREP))
       dda = 2; 
     else
       dda = 4;

    rspqueue_size = 128;

    if ( maxtr(&avmaxtr) == FAILURE ) {
        epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                   EE_ARGS(1), STRING_ARG, "maxtr");
        return FAILURE;
    }

   /* moved pisatnub and pichemsatopt setting to later due to use of fsmde_support cv */

    pisupnub = 1;
    if( exist(opsat) == PSD_ON ) {
        piccsatnub = PSD_ON; /* set default value Since
                                These can be changed in et_cveval_init */
    } else {
        piccsatnub = PSD_OFF; 
    }
   
    /* Simulate rotation matrix for obloptimize() */
    if (rotateflag == PSD_ON) {
        rotatescan();
    }
    else if (exist(use_myscan) == 1) {
        myscan();
    }

    /* Begin RTIA */
    if ( exist(oprealtime) == PSD_ON ) { 
        plane_type = PSD_OBL;
    } else { 
        plane_type = opphysplane;
    } 
    /* End RTIA */

    /* Always force obloptimize in cveval. Needed for correct calculation
       of db/dt optimized ramp times  - RJF. */ 
    opnewgeo = 1;

    if ( obloptimize(&loggrd, &phygrd, scan_info, 
                     ((existcv(opslquant)>0)?opslquant:1), 
                     plane_type, exist(opcoax), obl_method, 
                     obl_debug,&opnewgeo, cfsrmode)==FAILURE )  {
        psd_dump_scan_info();
        epic_error(use_ermes,"%s failed in %s",EM_PSD_FUNCTION_FAILURE,
                   EE_ARGS(2),STRING_ARG,"obloptimize",STRING_ARG,"cveval()");
        return FAILURE; 
    }

    /* Save the current rise/fall ramp times */
    tmp_ramp.xrt = loggrd.opt.xrt;
    tmp_ramp.yrt = loggrd.opt.yrt;
    tmp_ramp.zrt = loggrd.opt.zrt;
    tmp_ramp.xft = loggrd.opt.xft;
    tmp_ramp.yft = loggrd.opt.yft;
    tmp_ramp.zft = loggrd.opt.zft;

    /* Set the feature selection bitmask.  This second call is needed to
       account for the fact that the feature activation depends on variables
       set during prescription time, e.g., opfcine. */
    if ( setseqparams( &feature_flag, &seq_type ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "setseqparams" );
        return FAILURE;
    }

    /* Begin RTIA change/move */
    /* RTIA moved these from cveval1() to here because this is changed
       by RTIA feature cveval_init() */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        pixresnub = 0;
    } else {    
        pixresnub = 63;   
        /*
         * Allow Flexible XRES in steps of 32. Note that this will be 
         * applicable to all FGRE features unless the feature modules 
         * decide to override these in the respective cveval_init() calls 
         * - RJF, MRIge73762 
         */
        pixresval2 = 128;
        pixresval3 = 192;
        pixresval4 = 256;
        pixresval5 = 384;
        pixresval6 = 512;

        /* MRIge91751 - pull-down menu for xres tailored for 3T dual echo. */
        if( (feature_flag & MERGE) || (cffield == B0_30000 && exist(opnecho) >= 2) ){
            pixresnub = 63;   
            pixresval2 = 256;
            pixresval3 = 288;
            pixresval4 = 320;
            pixresval5 = 352;
            pixresval6 = 384;
	}
    }

    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        piyresnub = 0;  
    } else {
        piyresnub = 63;
        piyresval2 = 128;
        piyresval3 = 192;
        piyresval4 = 224;
        piyresval5 = 256;
        piyresval6 = 512;
    }

    /* MRIhc03566: Minimum slthick for calibration scan is 5.0 mm; 
       thus, remove < 5.0 mm values from the pull-down menu. */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        pistnub = 4;
        pistval2 = 5.0;
        pistval3 = 7.0;
        pistval4 = 10.0;  
    } else if (perfusion_flag) {
        pistnub = 5;
        pistval2 = 7.0;
        pistval3 = 8.0;
        pistval4 = 9.0;
        pistval5 = 10.0;
    } else {
        pistnub = 6;
        pistval2 = 3.0;
        pistval3 = 4.0;
        pistval4 = 5.0;
        pistval5 = 7.0;
        pistval6 = 10.0;
    }

    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        piisnub = 0;
        cvoverride(opslspace,0.0,PSD_FIX_ON,PSD_EXIST_ON);
    } else {
        piisnub = 6; /*MRIge83954*/
        piisval2 = 0.0;
        piisval3 = 1.5;
        piisval4 = 2.5;
        piisval5 = 5.0;
        piisval6 = 10.0;
        /* Interleave option should not be available if the prescription
           is single slice */
        if( existcv(opslquant) && (1 == exist(opslquant)) ) {
            piisil = 0;
        } else {
            piisil = 1;
        }
    }
    
    if (isSVSystem())
    {
        /* SVBranch GEHmr01830: Set power limit for XFD power supply to 5kW(Obl) and 5.5kW */
        /* SVBranch GEHmr04246: Set power limit for XFD power supply to 8.5kW when AC model is used */
        if ((cfgradamp == 8919) && (gradCoilMethod == 0))
        {
            if( exist(opplane) == PSD_OBL )
                cfxfd_power_limit = 5.0;
            else
                cfxfd_power_limit = 5.5;
        }
        else
        {
            cfxfd_power_limit = 8.5;
        }

        /* SVBranch HCSDM00126068, limit xfd_power_limit to 7.5 for fiesta realtime to avoil undervoltage issue.
           Gradient heating calculation does not cover other oblique conditions besides the precribed one.
           Here some margin is needed. The value of 7.5KW is based on protocol scan in 16Beat Bays. */
        if( (PSD_ON == exist(oprealtime)) && (PSD_SSFP == exist(oppseq)) )
        {
            cfxfd_power_limit = 7.5;
        }

        /* SVBranch GEHmr04492 : Set power limit for XFA heatsink */
        if(cfgradamp == 8919)
        {
            if ((opsilent == PSD_ON) && (opsilentlevel == 1))
            {
                if ((feature_flag & MFGRE) || (feature_flag & MERGE) || (feature_flag & FASTCARD) || (feature_flag & FASTCINE))
                {
                    if(feature_flag & FIESTA)
                    {
                        cfxfd_temp_limit = 8.5;
                    }
                    else
                    {
                        cfxfd_temp_limit = 2.5;
                    }
                }
                else
                {
                    cfxfd_temp_limit = 8.5;
                }
            }
            else if ((opsilent == PSD_ON) && (opsilentlevel == 2))
            {
                if ((feature_flag & FASTCARD) || (feature_flag & FASTCINE))
                {
                    if (feature_flag & FIESTA)
                    {
                        cfxfd_temp_limit = 2.2;
                    }
                    else
                    {
                        cfxfd_temp_limit = 2.4;
                    }
                }
                else if ((feature_flag & MFGRE) || (feature_flag & MERGE))
                {
                    cfxfd_temp_limit = 2.3;
                }
                else if ((feature_flag & GATEDTOF) || (feature_flag & UNGATEDTOF))
                {
                    cfxfd_temp_limit = 2.0;
                }
                else if ((feature_flag & MPL) || (feature_flag & FIESTA))
                {
                    cfxfd_temp_limit = 2.5;
                }
                else
                {
                    cfxfd_temp_limit = 8.5;
                }
            }
            else
            {
                cfxfd_temp_limit = 8.5;
            }
        }
        else
        {
            cfxfd_temp_limit = 8.5;
        }

        /* SVBranch HCSDM00102521 */
        /* xfd_power/temp_limit has fix flag, but cfxfd_power/temp_limit has no.
           below code can let cfxfd_power/temp_limit has pseudo fix flag.
           cfxfd_power/temp_limit can be updated by modifying xfd_power/temp_limit*/
        xfd_power_limit = cfxfd_power_limit;
        xfd_temp_limit  = cfxfd_temp_limit;
        cfxfd_power_limit = xfd_power_limit;
        cfxfd_temp_limit  = xfd_temp_limit;
    }


    /*MRIhc20334 add support for inter slice crusher for fiesta*/
    if ((feature_flag & FIESTA) && (PSD_OFF != fiesta_intersl_crusher)) {
        area_fiesta_intersl_crusher = (float)fiesta_intersl_crusher/(GAM*opslthick*0.1)*1.0e6;
        float target;
        int rtime, ftime;
       
        gettarget(&target, ZGRAD, &loggrd);
        getramptime(&rtime, &ftime, ZGRAD, &loggrd);
        
        if (amppwgrad((float)(area_fiesta_intersl_crusher),target, 0.0, 0.0, rtime*loggrd.scale_3axis_risetime,
                      MIN_PLATEAU_TIME,
                      &a_gzinterslk, &pw_gzinterslk, &pw_gzinterslk, &pw_gzinterslk) == FAILURE)
            return FAILURE;
        ia_gzinterslk = (a_gzinterslk/target)*MAX_PG_IAMP; 

    }
    else {
        area_fiesta_intersl_crusher = 100.0;
    }

    /* HCSDM00241267: at 3T, dual echo is defaulted to PSD_MINTE    */
    /*                dualecho legacy mode invoked if psdname: de2d */
    if ( (exist(opnecho) == 2) && (cffield==B0_30000) )
    {
        if (!strcmp("de2d", get_psd_name()))
        {
            dualecho_minTE = PSD_OFF;
        }
        else
        {
            dualecho_minTE = PSD_ON;
        }
    }
    else
    {
        dualecho_minTE = PSD_OFF;
    }

    /* For 1.5T, set dualecho_inflow_reduce to PSD_ON when DualEcho with CV6 ON to enable special setting for this kind of case */ 
    if((exist(opnecho) == 2) && !(feature_flag & MFGRE) && !r2_flag && is15TSystemType() && (PSD_ON == (int)exist(opuser6))) 
    { 
        dualecho_inflow_reduce = PSD_ON; 
    } 
    else 
    { 
        dualecho_inflow_reduce = PSD_OFF; 
    } 

    /* No extra readout period*/
    if(gradspec_flag) gxwex_on = 0;

    /* setting for max NEX */
    if ( (feature_flag & FASTCARD) || (feature_flag & FASTCARD_PC) || (feature_flag & FASTCINE )) 
    {
        if(cine_kt_flag)
        {
            cvmin(opnex, 1.0);
            cvmax(opnex, 1.0);
            cvdef(opnex, 1.0);
        }
        else
        {
            cvmax(opnex, MAX_CINE_NEX);
        }
    }
    else
    {
        cvmax(opnex, MAX_NEX);
    }

    /* Set NEX pull down menu */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
    {
        if(2 == rfb1opt_flag)/*HCSDM00095097*/
        {
            if( (PSD_ON == exist(opresearch)) && (!strncmp("mnexcal",get_psd_name(),7)) ) {
                pinexnub = 2 + 4;
                pinexval2 = 1.0;
                pinexval3 = 2.0;
                avminnex = 1.0;
                avmaxnex = 4.0;
            } else {
                pinexnub = 0;
                avminnex = 1.0;
                avmaxnex = 1.0;
                cvoverride(opnex,1.0,PSD_FIX_OFF,PSD_EXIST_ON);
            }
        }
        else
        {
            pinexnub = 0;
            avminnex = 1.0;
            avmaxnex = 1.0;
            cvoverride(opnex,1.0,PSD_FIX_OFF,PSD_EXIST_ON);
        }
    } else if( exist(opnecho) == 2 || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag ) { /* DUALECHO or MERGE */
        if((feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag)
        {
            pinexnub = 2 + 4;
            pinexval2 = 1.0;
            pinexval3 = 2.0;
        } else {
            /* HCSDM00241267 : always MIN TE so always full NEX */
            if (dualecho_minTE)
            {
                pinexnub = 0;
                cvoverride(opnex, 1.0, PSD_FIX_ON, PSD_EXIST_ON);
            }
            else
            {
                pinexnub = 2 + 4 + 8;
                pinexval2 = 0.5;
                pinexval3 = 0.75;
                pinexval4 = 1.0;
            }
        }
    } else {
        INT allowFracNex = PSD_ON;

        if( (PSD_PC == exist(oppseq)) ||
            ((PSD_OFF == fullte_flag) && (!perfusion_flag))  
            || (PSD_ON == touch_flag) 
            || (PSD_ON == cine_kt_flag) ) 
        {
            allowFracNex = PSD_OFF;
        }

        if( PSD_OFF == allowFracNex ) {
            if( PSD_ON == cmon_flag ) {
                pinexval2 = 1.0;
                pinexval3 = 2.0;
                if (exist(opnpwfactor) > 1.0)
                {
                    pinexnub = 1 + 2 + 4;
                }
                else
                {
                    pinexnub = 1 + 2;
                }
            }
            else if ( PSD_ON ==  cineir_flag )
            {
                pinexnub = 1 + 2;
                pinexval2 = 1.0;
            }
            else if ( sshmde_flag || sshmdespgr_flag || cardt1map_flag )
            {
                pinexnub = 1 + 2;
                pinexval2 = 1.0;
            }
            else if (PSD_ON == cine_kt_flag)
            {
                pinexnub = 1+2;
                pinexval2 = 1.0;
                avminnex = 1.0;
                avmaxnex = 1.0;
            } else {
                pinexnub = 1 + 2 + 4 + 8 + 16 + 32;
                pinexval2 = 1.0;
                pinexval3 = 2.0;
                pinexval4 = 3.0;
                pinexval5 = 4.0;
                pinexval6 = 5.0;
            }
        } else {
            if( feature_flag & ECHOTRAIN ) {
                /* ET supports only NEX <= 1.0 */
                pinexnub = 1 + 2 + 4 + 8;
                pinexval2 = 0.5;
                pinexval3 = 0.75;
                pinexval4 = 1.0;
            } else if (perfusion_flag) {
                if (PSD_MINTE==exist(opautote))
                {
                    pinexnub = 1 + 2 + 4;
                    pinexval2 = 0.75;
                    pinexval3 = 1.0;
                } else {
                    pinexnub = 1 + 2 + 4 + 8;
                    pinexval2 = 0.5;
                    pinexval3 = 0.75;
                    pinexval4 = 1.0;
                }
            } else if ( PSD_ON == cineir_flag )
            {
                pinexnub = 1 + 2 + 4 + 8;
                pinexval2 = 0.5;
                pinexval3 = 0.75;
                pinexval4 = 1.0;
            } else {
                if( PSD_ON == cmon_flag ) {
                    pinexnub = 1 + 2 + 4 + 8 + 16;
                    pinexval2 = 0.5;
                    pinexval3 = 0.75;
                    pinexval4 = 1.0;
                    pinexval5 = 2.0;
                    if (exist(opnpwfactor) > 1.0)
                    {
                        pinexnub = 1 + 2 + 4 + 8 + 16;
                    }
                    else
                    {
                        pinexnub = 1 + 2 + 4 + 8;
                    }
                } else {
                    if( PSD_ON == psmde_flag ) {
                        if ( sshmde_flag || sshmdespgr_flag ) {
                            pinexnub = 1 + 2 + 4;
                            pinexval2 = 0.75;
                            pinexval3 = 1.0;
                        } else {
                            pinexnub = 1 + 2 + 4 + 8 + 16 + 32;
                            pinexval2 = 0.75;
                            pinexval3 = 1.0;
                            pinexval4 = 1.5;
                            pinexval5 = 2.0;
                            pinexval6 = 3.0;
                        }
                    } else if ( sshmde_flag || sshmdespgr_flag || cardt1map_flag ) {
                        pinexnub = 1 + 2 + 4;
                        pinexval2 = 0.75;
                        pinexval3 = 1.0;
                        cvdef(opnex, 1.0);
                    } else {
                        if( PSD_ON == oprealtime )
                        {
                            pinexnub= 1 + 2 + 4 + 8 ;
                            pinexval2 = 0.5;
                            pinexval3 = 1.0;
                            pinexval4 = 2.0;
                        }
                        else {
                            pinexnub= 1 + 2 + 4 + 8 + 16 + 32;
                            pinexval2 = 0.5;
                            pinexval3 = 0.75;
                            pinexval4 = 1.0;
                            pinexval5 = 1.5;
                            pinexval6 = 2.0;
                        }
                    }
                }
            }
        }
    }
    /* End RTIA */
    
    /* FIESTA-C */ /* VAL15 04/08/2005 YI */
    if( (feature_flag & FIESTA) && pcfiesta_flag ) {
        pinexnub = 1 + 2 + 4 + 8; 
        if(pc_mode == PC_APC) { /* APC */
            pinexval2 = 2.0;
            pinexval3 = 3.0;
            pinexval4 = 4.0;
        } else {                /* SGS */
            pinexval2 = 4.0;
            pinexval3 = 6.0;
            pinexval4 = 8.0;
        }
    }
    /* Begin RTIA move */
    /* RTIA moved the Screen control settings of Fov, 
       Flip angle and RBW to here so that the features 
       may modify them but are re-initialized to the 
       default values. */

    /* Flip angle buttons */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) )
    {
        pifanub = 0;
        if(cffield < B0_30000)
        {
            cvoverride(opflip,70,PSD_FIX_ON,PSD_EXIST_ON);
        } else {
            /* GS - For 7T do not fix the flip. Enable the ui */
            if (B0_70000 == cffield)
            {
                pifanub = 6;
                pifaval2 = 10;
                pifaval3 = 20;
                pifaval4 = 30;
                pifaval5 = 40;
                pifaval6 = 50;
            }
            else
            {
                /* For 3T, reduce flip angle to 50 deg. */
                /* MRIge87570 */
                cvoverride(opflip,50,PSD_FIX_ON,PSD_EXIST_ON);
            }
        }
    }
    else
    {
        if(feature_flag & MERGE)
        {
            pifanub = 6;
            pifaval2 = 20;
            pifaval3 = 25;
            pifaval4 = 30;
            pifaval5 = 35;
            pifaval6 = 40;
            avmaxflip = 50;

            if(existcv(optr) || existcv(optracq))
            {
                float auto_flip;
                if(tr_time < 400ms)
                {
                    auto_flip = 15.0;
                }
                else if (tr_time >= 400ms && tr_time <= 900ms)
                {
                    auto_flip = 20.0;
                }
                else if (tr_time > 900ms && tr_time <= 1100ms)
                {
                    auto_flip = 25.0;
                }
                else
                {
                    auto_flip = 30.0;
                }
                pifaval2 = auto_flip;
                if (PSD_ON == exist(opautoflip))
                {
                    cvoverride(opflip,auto_flip,PSD_FIX_ON,PSD_EXIST_ON);
                }
            }
        }
        else if ( opnecho == 2 && !(feature_flag & MFGRE) && !r2_flag )
        {   /* MRIge92915 -- dual echo */
            pifanub  = 6;
            pifaval2 = 60;
            pifaval3 = 70;
            pifaval4 = 75;
            pifaval5 = 80;
            pifaval6 = 90;
        }
        else
        {
            pifanub  = 6;
            pifaval2 = 10;
            pifaval3 = 20;
            pifaval4 = 30;
            pifaval5 = 60;
            pifaval6 = 90;
        }
    }

    pifovnub = ((cffield == B0_7000) &&
                (RX_COIL_LOCAL == getRxCoilType()) ? 5 : 6);

    if ( RX_COIL_LOCAL == getRxCoilType() ) {
        pifovval2 = 200;
        pifovval3 = 240;
        pifovval4 = 320;
        pifovval5 = 360;
        pifovval6 = 400;
        if ( (cfgradcoil == GCOIL_HGC)||(cfgradcoil == GCOIL_VECTRA) ) {
            pifovval6 = 450;  /* vmx - 02/May/95 - KS */
        }
    } else {
        /* Currently same FOV buttons used for heads and surface coils */
        pifovval2 = 80;
        pifovval3 = 120;
        pifovval4 = 160;
        pifovval5 = 200;
        pifovval6 = 240;
    }

    /* Set TE buttons */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) || (exist(opnecho) == 2) || psmde_flag) {
        pite1nub = 0;
       
        /* MRIhc48258 - ART support for ASSET. Dual echo which does not support ART is handled separately  */ 
        if( (cffield == B0_15000) && 
            ((PSD_ON == exist(opsilent)) && ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref))) ) 
        {
            /* Minfull TE sets TE close to out-of-phase TE. Since the TE with the extreme protocol (small FOV and thinnest slice) is
               only about 2.9ms, setting TE to 3.2ms which is in between in-phase and out-of-phase TE.  Although there were some concerns
               about susceptibilty induced signal loss, feasibility results were promising and hence retain 3.2 ms for ART calibration */ 
            int artCalTE;
            artCalTE  = IMax(2, min_tenfe, 3200);
            cvoverride(opte, artCalTE, PSD_FIX_ON,PSD_EXIST_ON); 
        }
        else
        {
            /* HCSDM00241267 */
            if (dualecho_minTE)
            {
                cvoverride(opautote, PSD_MINTE, PSD_FIX_ON, PSD_EXIST_ON);
            }
            else
            {
                cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
            }
        }
    } else if (perfusion_flag) {
        pite1nub  = 6;
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        cvdef(opautote,PSD_MINTEFULL);
        opautote = PSD_MINTE;  
    } else if ( (feature_flag & MFGRE) || r2_flag ) {
        pite1nub = 7;
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        cvdef(opautote,PSD_MINTEFULL);
        opautote = PSD_MINTEFULL;
    } else if (psmde_flag ) {
        pite1nub  = 0;
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    } else if ( sshmde_flag || sshmdespgr_flag || cardt1map_flag ) {
        pite1nub  = 0;
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    } else {
        pite1nub  = 31;   /* MRIge91445 - allow type-in values for TE. */
        pite1val2 = PSD_MINIMUMTE;
        pite1val3 = PSD_MINFULLTE;
        pite1val4 = PSD_FWINPHASETE;
        pite1val5 = PSD_FWOUTPHASETE;
    }

    /* MEGE changes */
    if(feature_flag & MERGE){
        pite1nub = 0;
        cvoverride(opautote,PSD_MINTEFULL,PSD_FIX_ON,PSD_EXIST_ON);
        pisupnub = 0;
        
    }

    /* Set RBW buttons */
    pirbwpage = 1;   /* always place rbw parameters on scan set-up screen */
    pircb2nub = 0;   /* no extra button */

    /* Set RBW Parameters */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        pircbnub = 0;
        pidefrbw = 31.25;
        avmaxrbw = 31.25;
        avminrbw = 31.25;
    } else if( opnecho == 2 && !(feature_flag & MFGRE) && !r2_flag ) { /* DUALECHO BWL */
        pircbnub = 0;

        pidefrbw = 125.0;
        avmaxrbw = 125.0;
        avminrbw = 125.0;

        /* HCSDM00241267 : set limits for RBW if TE = MINIMUM */
        if (dualecho_minTE)
        {
            dualecho_ulimrbw = dualecho_ulimrbw_min;
            dualecho_llimrbw = dualecho_llimrbw_min;
        }
        else
        {
            dualecho_ulimrbw = dualecho_ulimrbw_mf;
            dualecho_llimrbw = dualecho_llimrbw_mf;
        }

        if( (exist(opxres) < 300) && (existcv(opxres) == PSD_ON) &&
            (cffield < B0_15000) ) {
            pircbval2 = 62.5;
            pidefrbw = 62.5;
            avmaxrbw = 62.5;
            avminrbw = 62.5;
        /* MRIge92350 - 1.5T and 3T Dual Echo - opened up rBW for automatic rBW calculation. 
           Still user won't be able to type in rBW from scan screen.  
           Possible rBW for 1.5T dual echo is no longer just 62.5 and 125.0. */
        } else if( cffield == B0_30000 || cffield ==B0_15000 ) {
            pidefrbw = 125.0;
            cvdef(oprbw, pidefrbw);
            oprbw = pidefrbw;  

            /* MRIge91751 - for 3T dual echo, decreased avminrbw from 125.0 to 50.0. */
            /* rBW is locked out for now; user can not type in from scan screen.     */
            /* HCSDM00241267 : set limits for RBW if TE = MINIMUM */
            avminrbw = (dualecho_minTE) ? dualecho_llimrbw_min : dualecho_llimrbw_mf;
            avmaxrbw = (dualecho_minTE) ? dualecho_ulimrbw_min : dualecho_ulimrbw_mf;
            pircbnub = 0;
        }
    } else {
        pircbnub  = 6;   /* six bandwidth buttons for other, 125, 83.33, 62,5,
                            31.25, 15.63 KHz */
        /* Added more values for fractional decimation - GFN - 27/Jan/1998 */
        pircbval2 = 125.0;
        /* Check for FastCard PC. Fractional Decimation is not compatible. */
        if( exist(oppseq) != PSD_PC ) {
            pircbval3 = 83.33;
            pircbval4 = 62.5;
            pircbval5 = 31.25;
            pircbval6 = 15.63;
        } else {
            if (PSD_ON == psmde_flag) {
                pircbval2 = 15.63;
                pircbval3 = 31.25;
                pircbval4 = 41.67;
                pircbval5 = 50.0;
                pircbval6 = 62.5;
            } else {
                pircbnub  = 5;
                pircbval3 = 62.5;
                pircbval4 = 31.25;
                pircbval5 = 15.63;
            }
        }
        pidefrbw  = 31.25;   /* default to 31.25kHz */

        if( (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag )
        {
            if (feature_flag & MERGE) 
            {
                avminrbw = 15.63;
            }
            else
            {
                avminrbw = 31.25;
            }
            avmaxrbw = 125;

            pircbnub  = 5;
            pircbval2 = 31.25;
            pircbval3 = 41.67;
            pircbval4 = 50.0;
            pircbval5 = 62.5;
            if(cffield == B0_30000) pidefrbw = 41.67;
            /* HCSDM00437118 */
            if( (exist(opobplane) != PSD_AXIAL || exist(opplane) == PSD_SAG
                 || exist(opplane) == PSD_COR) && cffield == B0_30000 && (feature_flag & MERGE) )
            {
                pircbnub  = 4;
                pircbval2 = 41.67;
                pircbval3 = 50.0;
                pircbval4 = 62.5;
            }
        }
    }
    /* End RTIA move */

    phorder = 0; /* initialize phase acquisition order */
  
    /* Initialize the phase contrast flow encoding 
       trapezoid gradients to zero */
    pw_gyfe1a = GRAD_UPDATE_TIME;
    pw_gyfe1  = GRAD_UPDATE_TIME; 
    pw_gyfe1d = GRAD_UPDATE_TIME;
    pw_gyfe2a = GRAD_UPDATE_TIME; 
    pw_gyfe2  = GRAD_UPDATE_TIME; 
    pw_gyfe2d = GRAD_UPDATE_TIME; 
  
    a_gyfe1 = 0.;
    a_gyfe2 = 0.;

    yfe_time = 0;

    /* Make sure that time_ssi has been set properly */
    time_ssi = 200us;
    /* increase time_ssi to 220 for mfgre on DV plateform*/
    if(PSD_ON == exist(opmer2))
    {
        time_ssi = 220;
    }
    else if (PSD_ON == perfusion_flag)
    {
        time_ssi = 120;
    }

    /* Turn on y flow encoding gradients */
    if ( (feature_flag & FASTCARD_PC) && (opflaxy != 0) ) {
        gyfe1_pulse->num = 1;  
        gyfe2_pulse->num = 1;
    } else {  
        gyfe1_pulse->num = 0;  
        gyfe2_pulse->num = 0;
    }

    /* Initialize x killer to off in spatial sat */
    spsatxkill = 0;
 
    /********************
     *  ISI parameters  *
     ********************/
    /* time between beginning of isi and gxw */
    /* These values were determined from the 
       fastcard prototype. Since the same 
       code will be used for fgre, maintain these values. */
    /* JAP ET */
    isidelay = 0us;

    if (vstrte_flag) {
        pw_isi6 = GRAD_UPDATE_TIME;    
    } else {
        pw_isi6 = 200us; 
    }

    /* 
     * Reset all rf pulse resolutions to 0 for pulse stretching 
     * correct operation
     */
     
    /* HD merge_3TC_11.0 START */
    if (lp_mode == 1) {
        if ( FAILURE == reset_rfpulses_lp( &pulse_table ) ) {
            epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "reset_rfpulses_lp" );
            return FAILURE;
        }
    } else {
        if ( FAILURE == reset_rfpulses( &pulse_table ) ) {
            epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "reset_rfpulses" );
            return FAILURE;
        }
    }
    /* HD merge_3TC_11.0 END */

    
    /**********************************************************
     *  Set rf activity field here before scale_rfpulse call  *
     **********************************************************/
    /* need chemsat setparams here */
    if ( ChemSat_set_params(&cs_sat, feature_flag) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "ChemSat_set_params");
        return FAILURE;
    } 


    if ( prep_cveval_rfinit(feature_flag) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "prep_cveval_rfinit");
        return FAILURE;
    }

    if ( ChemSat_rfinit(cs_sat, feature_flag) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "ChemSat_rfinit");
        return FAILURE;
    }

    /* Tagging - 02/Jun/97 - GFN */
    if ( tagging_cveval_rfinit(feature_flag) == FAILURE ) {
        return FAILURE;
    }

    if ( FAILURE == Hard180_rfinit(feature_flag) )
    {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "Hard180_rfinit");
        return FAILURE;
    }

    /* init for each feature */
    if ( mpl_cveval_init(feature_flag, &isidelay, &dda) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "mpl_cveval_init");
        return FAILURE;
    }
    /* JAP ET  - Modify mpl_cveval_init to do this */
    isidelay = 0;
    if ( prep_cveval_init( &avminti, &avmaxti, &phorder, &viewoffs, &intsldelay,
                           &seeddef, &ps2_nex, feature_flag ) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "prep_cveval_init");
        return FAILURE;
    }

    if ( mph_cveval_init( feature_flag ) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "mph_cveval_init");
        return FAILURE;
    }

    if ( fastcard_cveval_init( &avmintdel1, &avmaxtdel1, &gating, &phorder,
                               feature_flag ) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "fastcard_cveval_init");
        return FAILURE;
    }

    if ( fastcardPC_cveval_init( &never_mind, feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "fastcardPC_cveval_init");
        return FAILURE;
    }

    /* Fast CINE - GFN - 26/Jan/1998 */
    if ( FAILURE == fcine_cveval_init( feature_flag ) ) {
        epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fcine_cveval_init" );
        return FAILURE;
    }

    if ((feature_flag & FIESTA) && (PSD_OFF != fiesta_intersl_crusher)) {
        total_intersl_crusher_time = delay_intersl_crusher + pw_gzinterslk + pw_gzinterslka + pw_gzinterslkd;
    }
    else {
        total_intersl_crusher_time = 0;
    }
        
    /* FIESTA2D */
    if ( FAILURE == fiesta2d_cveval_init( &time_ssi, &TR_PASS, &gating, feature_flag, 
                                          total_intersl_crusher_time, fiesta_intersl_crusher ) ) {
        epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fiesta2d_cveval_init" );
        return FAILURE;
    }

    /* Tagging - GFN - 19/Mar/1998 */
    if ( FAILURE == tagging_cveval_init() ) {
        return FAILURE;
    }
 
    /* Respiratory Gating - GFN - 26/Jan/1998 */
    if ( FAILURE == respgate_cveval_init() ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "respgate_cveval_init");
        return FAILURE;
    }
 
    if ( fmpvas_cveval_init( &gating, &seeddef, &spsatxkill, 
                             &isInh2DTOF, feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "fmpvas_cveval_init");
        return FAILURE;
    }

    /* HCSDM00445737 */
    if(feature_flag & ECHOTRAIN)
    {
        if(!et_initialized) 
        {
            if( et_cvinit(&pw_gxwl, &pw_gxwr, &pw_gyba, &pw_gybd, &pw_gyb, &a_gyb, gxw_pulse, &pulse_table, feature_flag) == FAILURE)
            {
                return FAILURE;
            }
            et_initialized = true;
        }
    }
    else
    {
        et_initialized = false;
    }

    /* For non-ET scans don't shift readout */
    read_shift = 0;

    /* Shift readout */
    if(gradspec_flag) read_shift = 1;

    /* JAP ET */
    if( (status = et_cveval_init( &etl, &dda, &gxwex_on, &fast_pass,
                                  &short_rf, &read_shift, &dt,
                                  feature_flag )) != SUCCESS ) {
        return status;
    }

    if (vstrte_flag) {
        if (B0_15000 == cffield) {
            if(isArtistSystem())
            {
              time_ssi = 72;
            }
            else if(isStarterSystem())
            {
              time_ssi = 56;
            }
            else
            {
              time_ssi = 88;
            }
        } else {
            if(PSD_XRMW_COIL == cfgcoiltype)
            {
                time_ssi = 72;
            }
            else
            {
                time_ssi = 80;
            }
        }
        cvmin(opxres, 64);
        cvmin(opyres, 64);
    }

    if(feature_flag & MERGE)
    {
        piinrangetrmin = 400ms;
        piinrangetrmax = 1200ms;
    }
    else
    {
        piinrangetrmin = 120ms;
        piinrangetrmax = 250ms;
    }

    if (touch_flag) 
    {
        pitrnub = 0;
        opautotr = PSD_ON; 
        
        cvdef(opautote, 1);
        cvmax(opirmode, 1);
        cvdef(opirmode, 1);

        pisupnub = 0;

        pitouch = 1;

        pitouchtphases = 1;
        pitouchfreq = 1;
        pitouchcyc = 1;
        pitouchamp = 1;
        pitouchaxnub = 15;
        pitouchmegfreqnub = 0;

        setexist(optouchtphases, PSD_EXIST_ON);
        pideftouchtphases = 4;
        setexist(optouchfreq, PSD_EXIST_ON);
        pideftouchfreq=60;
        setexist(optouchmegfreq, PSD_EXIST_ON);
        pideftouchmegfreq=60;
        setexist(optouchcyc, PSD_EXIST_ON);
        pideftouchcyc=3;
        setexist(optouchamp, PSD_EXIST_ON);
        pideftouchamp = 30;
        setexist(optouchax, PSD_EXIST_ON);
        pideftouchax = 4;
 
        setfix(opfphases, PSD_FIX_OFF);
        setexist(opfphases, PSD_EXIST_ON);
        opfphases = optouchtphases;

        pinecho = 1;
        piechnub = 0;

        piacqnub = 0;
        cvdef(opacqo, 1); 
        opacqo = 1;

        TR_PASS = 50ms;
        cvmin(opsldelay, TR_PASS);
        cvdef(opsldelay, TR_PASS);
        opsldelay = TR_PASS;
        pisldelnub = 0;

        opflip = 30;

        pidefrbw  = 32.25;

        cvmin(opyres, 64);
        piyresnub = 15;
        piyresval2 = 64;
        piyresval3 = 128;
        piyresval4 = 256;

        cvoverride(opfcomp, PSD_ON, PSD_FIX_ON, PSD_EXIST_ON);

        pite1nub = 0;
        cvoverride(opautote,PSD_MINTEFULL,PSD_FIX_ON,PSD_EXIST_ON);

        cvoverride(optouchmegfreq,optouchfreq , PSD_FIX_ON,PSD_EXIST_ON);
	pitouchmegfreqnub = 0;
    } /* end touch_flag */

    /* Doesn't allow to edit TE and only allows min full TE */
    if(gradspec_flag)
    {
        pite1nub  = 0;
        cvoverride(opautote, PSD_MINTEFULL, PSD_FIX_ON, PSD_EXIST_ON);
    }

    pi_sldelnub = pisldelnub; /* Auto Voice */

    /* Turn OFF X killer for multi echo - RJF, DUALECHO */
    if( (exist(opnecho) > 1 && !(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag) || (vstrte_flag && !(feature_flag & FIESTA)) ) {
        gxwex_on = 0;
    }

    /* HCSDM00241267: turn on killers for dual echo */
    /* Turn on X direction killer for 1.5T DualEcho with inflow signal reduce ON */ 

    if (dualecho_minTE || (PSD_ON == dualecho_inflow_reduce)) 
    {
        gxwex_on = 1;
    }

    {
        /* HCSDM00247289 : reset grad_pulse based on opnecho */
        /* replicate code from cvinit to set bridge only     */
        INT temp_int1, temp_int2, temp_int3;
        FLOAT *temp1_p;
        FLOAT temp1 = (FLOAT)0.0;

        temp_int1 = obl_method;
        temp_int2 = cont_flag;
        temp_int3 = rfb1opt_flag;

        if(FAILURE == RTIA_cvinit(feature_flag, &temp_int1, &bridge, &temp_int2, &temp_int3))
        {
            return FAILURE;
        }

        /* FIESTA2D - Unbridge Readout and X killer */
        /* HCSDM00241267 */
        if( (feature_flag & FIESTA) || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag || dualecho_minTE || (PSD_ON == dualecho_inflow_reduce))
        {
            bridge = 0;
        }

        if (!bridge)
        {
            temp1_p = &temp1;
        }
        else
        {
            temp1_p = &a_gxw;
        }

        /* update grad pulse structure based on updated bridge value */
        gxw_pulse->bridge = bridge;
        gxw_pulse->ampe = temp1_p;

        gxwex_pulse->bridge = bridge;
        gxwex_pulse->amps = temp1_p;
    }

    /*** addition for 512 & 1024 ZIP ***/

    if ( (exist(opzip1024) == PSD_ON) ||  ((opxres > 512) || (opyres > 512)) )
    {
        hires_recon = HIRES_1024;
    }
    else if ( (exist(opzip512) == PSD_ON) || ((opxres > 256) || (opyres > 256)) )
    {
        hires_recon = HIRES_512;
    }
    else
    {
        hires_recon = HIRES_OFF;
    }
    
    /* ASSET - Turn off TR menu for cal mode since it is set in mpl_cveval_init() */
    /* Cal uses auto min TR feature */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
    {
        if (cffield == B0_70000)
        {
            pitrnub = 0;
            cvoverride(optracq,1,PSD_FIX_ON,PSD_EXIST_ON);
        }
        else
        {
            pitrnub = 0;
            if(2 == rfb1opt_flag)/*HCSDM00095097*/
            {
                cvoverride(optracq,1,PSD_FIX_ON,PSD_EXIST_ON);
            }
            else
            {
                cvoverride(optr,150ms,PSD_FIX_ON,PSD_EXIST_ON);
            }
        }
    }

    /* MRIhc15935- This is a temporary fix. Will have to revisit this once we have B1 derating based on coil and weight- UN */ 
    else if( (PSD_OFF == xrmw_3t_flag) && (PSD_VRMW_COIL != cfgcoiltype) &&
        (((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) && (B0_30000 == cffield) && (opweight <= 25)) )
    {
        rfb1opt_flag = 1;
    }
    else if(PSD_ON == minseqrf_cal)
    {
        rfb1opt_flag = 2;
    }
    else
    {
        rfb1opt_flag = 1;
    }
    
    /* MRIge91361 -- two passes, one for surface coil, one for body*/
    if ( (PSD_ON == pure_ref) || (swift_cal == PSD_ON) ) {
        pass_reps = 2;
    }
    else {
        pass_reps = 1;
    }  

    /* Begin RTIA - RJF */
    if( RTIA_cveval_init( feature_flag, 
                          &psd_fov, 
                          &dda, 
                          &phorder, 
                          &TR_PASS,
                          &rfb1opt_flag ) == FAILURE ) { 
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "RTIA_cveval_init" );
        return FAILURE;
    }/* end RTIA*/

    if (feature_flag & RTIA98) { 
        /* Don't use Chemsat pulse in prescan entry point. */
        PScs_sat = 0;
    }
    /* End RTIA */
   

    /* Increase tlead for CMON - LX2 */
    if( cmon_flag == PSD_ON ) {
        tlead = 2500us;
    } else {
        tlead = 12us;
    }
    tlead = RUP_GRD(tlead);


    /* Variable FOV buttons on or off depending on square pixels */
    /* ASSET */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        piphasfovnub = 0;
        piphasfovnub2 = 0;
        cvoverride(opphasefov,1.0,PSD_FIX_ON,PSD_EXIST_ON);
    } else if( exist(opsquare) == PSD_ON ) {
        piphasfovnub = 0;
        piphasfovnub2 = 0;
    } else {
        piphasfovnub = 0;
        piphasfovnub2 = 63;
        piphasfovval2 = 1.0;
        piphasfovval3 = 0.9;
        piphasfovval4 = 0.8;
        piphasfovval5 = 0.7;
        piphasfovval6 = 0.6;
    }
  

    /****  Asymmetric Fov  ****/
    /* handling for phase (y) resolution and recon scale factor.*/ /* rectFOV&NPW  05/11/2005 YI */
@inline FlexibleNPW.e fNPWeval1
 
    if (vstrte_flag) {
        eg_phaseres = IMin (2, eg_phaseres, 40);
    }
 
    /*
     * Set up the nex related intermediate variables before
     * optimized pulse timings are calculated since this may affect
     * echo fractions used.  - RJF, LxMGD
     */
    if( SUCCESS != (status = nexcalc()) ) {
        /* Allow error from nexcalc() to show up */
        return status;
    }

    /*
     * The TE will be set now as part of dB/dt optimization.  Hence, turn
     * OFF existence flag for TE before entering calcOptimizedPulses().
     * The fixed flag and such will be set on return from calcOptimizedPulses().
     */
    if( existcv(opautote) && (PSD_OFF == exist(opautote)) ) {
        if( !existcv(opte) ) {
            setfix(opte,PSD_FIX_OFF);
        }
    } else {
        setexist(opte,PSD_EXIST_OFF);
        setfix(opte,PSD_FIX_OFF);
        opte = _opte.defval;
        /* DUALECHO - Added resetting for second echo */
        setexist(opte2,PSD_EXIST_OFF);
        setfix(opte2,PSD_FIX_OFF);
        opte2 = _opte2.defval;
    }
    /* By default, use prescription values : MRIge85640 */
    psd_fov = exist(opfov);
    psd_slthick = exist(opslthick);
    psd_flip = exist(opflip);

    /* Begin of RTCA */
    /* MRIge73779: rtca_min_fov should be set only after avminfov is set :AK */
    /* Set the slider boundary : FOV  */
    rtca_min_fov  = exist(opfov) * 0.5;
    rtca_max_fov = 1.5 * exist(opfov);
    rtca_max_slthick = 1.5 * exist(opslthick);

    if ( (PSD_ON == exist(oprealtime) && (feature_flag & FIESTA) ) )
    {
        rtca_min_fov  = exist(opfov);
        rtca_min_slthick = exist(opslthick);
        rtca_min_flip = exist(opflip);
        rtca_max_flip = exist(opflip);
    }
    else
    {
        rtca_min_fov  = 0.5 * exist(opfov);
        rtca_min_slthick = 0.5 * exist(opslthick);
        rtca_min_flip = exist(opflip) * 0.5;
        rtca_max_flip = 1.5 * exist(opflip);
    }

    /* Verify if RT on-the-fly parameters are allowed */
    /* FOV is allowed on RT FGRE and not in RT ET
       RT FIESTA allows increase of FOV and slice thickness to 1.5 times Rx value
       Flip Angle and Slice thickness are allowed in RT FGRE and RT ET.
       Flip Angle is fixed in RT FIESTA. */
    {
        const short rt_fov_flag = ( (PSD_ON == exist(oprealtime)) &&
                                    !(feature_flag & ECHOTRAIN) );

        const short rt_flip_slthick_flag = ( ( (PSD_ON == exist(oprealtime)) &&
                                               (PSD_OFF == exist(opstress))) ||
                                             ( (PSD_ON == exist(opstress)) &&
                                               (PSD_OFF == exist(opcgate)) ) );

        if( rt_fov_flag ) {
            psd_fov = rtca_min_fov;
        }

        if( rt_flip_slthick_flag ) {
            psd_slthick = rtca_min_slthick;
            psd_flip = rtca_max_flip;
        }
    }
    /* End RTCA */

    /*MRIge93811, MRIge93805*/
    initialize_rfpulseInfo( pulse_table.rfnum, rfpulseInfo );

    /* MRIhc16264 */
    /* Initialize .powscale fields of grad pulses for grad safety */
    init_powscale( cfsrmode, opphysplane, &pulse_table, &loggrd );

    /*
      Set the pulse parameter CVs for the imaging sequence. This 
      employs dB/dt optimization algorithms, which uses a linear 
      segment model of the sequence obtained by calling a subset of 
      pulsegen() from the host.  This will calculate the optimal
      echo time and sequence time.
      
      The subset is marked by the global variable pgen_for_dbdt_opt. 
      Since this is a global variable which is not downloaded, the Tgt 
      will see only the initialized value at the definition, and 
      not the modified value on the host.

      Conditional compilation using #ifdef Tgt wouldn't work since
      this is used for gradient heating, which requires a different subset 
      of pulsegen() from that needed for dBdt Optimization.

      - RJF, 8/Nov/99
    */
    pgen_for_dbdt_opt = 1;
 
    if (PSDCERD==psd_board_type) {
       /* Turn on dbdt level opt for non-realtime Fiesta */
       if ( (feature_flag & FIESTA) && (PSD_OFF == exist(oprealtime)))
       {
           dbdtlevel_opt = 1;
       }
       else {
           dbdtlevel_opt = 0;
       }
    } 

    /* MRIge63197 -- must use full scale for dB/dt optimization */
    gy1_pulse->scale = 1;
    gy1r_pulse->scale = 1;
 
    /* HCSDM00157626: update CFL RF pulse prior to pulse stetching in
       dbdtlevel_and_calcoptimize(): */  
    if ( (status = PScveval()) != SUCCESS )
    {
        return status;
    }

    /* Limit to SSSD for now. Need to update minseqseg.c to support other gradamp */
    if ((5550 == cfgradamp) && (PSD_ON == exist(oprealtime)))
    {
        set_realtime_rotmat = PSD_ON;
        skip_rotmat_search = PSD_ON;
    }
    else
    {
        set_realtime_rotmat = PSD_OFF;
    }

    /* Perform optimizations for main sequence (idx_seqcore) only */
    seqEntryIndex = idx_seqcore;
    {
       	if ( (status = dbdtlevel_and_calcoptimize()) != SUCCESS ) {
	          return status;
       	}
    }

    if (rtca_max_fov > avmaxfov) {
        rtca_max_fov = avmaxfov;
    }
    if (rtca_min_fov < avminfov) {
        rtca_min_fov = avminfov;
    }
    rtca_insteps_fov = 10;

    /* Set the slider boundary : Flip Angle */
    if (rtca_max_flip > avmaxflip) {
        rtca_max_flip = avmaxflip;
    }
    if (rtca_min_flip < avminflip) {
        rtca_min_flip = avminflip;
    }
    rtca_insteps_flip = 1;

    /* Set the slider boundary : Slice Thickness */
    if (rtca_max_slthick > avmaxslthick) {
        rtca_max_slthick = avmaxslthick;
    }
    if (rtca_min_slthick < avminslthick) {
        rtca_min_slthick = avminslthick;
    }
    rtca_insteps_slthick = 0.1;

    /* Activate TE exist/fix flags */
    setexist(opte,PSD_EXIST_ON);
    setfix(opte,PSD_FIX_ON);
    /* DUALECHO - Activate TE/TE2 exist/fix flags */
    setexist(opte2,PSD_EXIST_ON);
    setfix(opte2,PSD_FIX_ON);

    /* HCSDM00367265  */
    if( (PSD_VRMW_COIL == cfgcoiltype) && ((feature_flag & UNGATEDTOF) || (feature_flag & GATEDTOF) || (feature_flag & FASTCARD_PC)) )
    {
        pisatthickz = 30;
        pisatthickx = 30;
        pisatthicky = 30;
        opdfsathick1 = 30.0;
        opdfsathick2 = 30.0;
        opdfsathick3 = 30.0;
        opdfsathick4 = 30.0;
        opdfsathick5 = 30.0;
        opdfsathick6 = 30.0;
    }

    /* Calculate preparation sequence parameters, patient safety,
       gradient safety, slice ordering, scan timing, ... */
    if( (status = cveval1()) != SUCCESS ) {
        return status;
    }

    /* 
     * Need to re-run cveval1() if optr override in cveval1. SAR related 
     * calculation is performed before optr evaluation. Thus, whenever optr is 
     * overrided, need to run cveval1 again to make SAR calculation right.
     */ 
    if( optr_overrided ) {
        if( (status = cveval1()) != SUCCESS ) {
            return status;
        }
    }

    /* re-run optimization to update TR if phase acceleration factor changed for FIESTA*/
    if( (FIESTA & feature_flag) && !floatsAlmostEqualEpsilons(old_ph_stride, exist(opaccel_ph_stride), 2) )
    {
        old_ph_stride = exist(opaccel_ph_stride);
        
        seqEntryIndex = idx_seqcore;
        /* Force the dB/dt optimization to run again */
        /* set_cvs_changed_flag( TRUE ); */
        enforce_minseqseg = PSD_ON;
        if ( (status = dbdtlevel_and_calcoptimize()) != SUCCESS )
        {
            return status;
        }
    }

    /* SVBranch HCSDM00102590 */
    /* when smart derating is on, B1 optimization runs when one of below conditions is met:
       a. min_seqrfamp > tmin *(1+tolerance)
       b. max_seqsar > tmin *(1+tolerance)
       c. B1 optimization is run and min_seqrfamp/max_seqsar is dominant.
          At the same time, the difference between tmin and max_seqsar/min_seqrfamp is out of tolerance.
          ( in case, parameter in UI is changed)
    ***************************************************/

    if( (2 == rfb1opt_flag) &&
        ( (((float)min_seqrfamp/tmin - 1.0) > gradOpt_rfb1opt_limit) || (((float)max_seqsar/tmin - 1.0) > gradOpt_rfb1opt_limit) ||
          ( floatsAlmostEqualEpsilons(ogsfRF, gradOpt_rfb1opt_scale, 2) &&  /* B1 optimization is run and min_seqrfamp/max_seqsar is dominant. */
            (ogsfRF < gradOpt_pwgzrf1_scale) &&
            (((float)max_seqsar/tmin-1.0) < -gradOpt_rfb1opt_limit) &&  /*  the difference is out of tolerance */
            (((float)min_seqrfamp/tmin-1.0) < -gradOpt_rfb1opt_limit)) ||
          (PSD_OFF == gradOpt_flag) ) ) /* GEHmr02638 */
    {
        int   rfscale_flag       = 0;
        float orig_rfscale       = 1.0;
        float limit_scale_seed   = 1.0;
        float opt_deratingfactor = 1.0;
        /* SVBranch HCSDM00102590 */
        float tmpfactor          = FMin(2, gradOpt_rfb1opt_range, 1.0/ogsfRF);
        int  pw_rf1_bak          = pw_rf1;
        int  bak_pw_rf1_tot      = pw_rf1 + pw_gzrf1a + pw_gzrf1d;

        /* Due to smart derating, before B1 optimization, pw_rf1 is already scaled. Recover it in certain range */
        /* In rfsafetyopt(), width of gzrf1 can not be recovered. So recover it before rfsafetyopt() */
        if(gradOpt_flag)
        {
            *rfpulse_list[RF1_SLOT].pw = RUP_GRD(ceil((*rfpulse_list[RF1_SLOT].pw) / tmpfactor));
            pw_gzrf1a                  = RUP_GRD(ceil(pw_gzrf1a * tmpfactor));
            pw_gzrf1d                  = RUP_GRD(ceil(pw_gzrf1d * tmpfactor));
            orig_rfscale = 1.0/tmpfactor;   /* orig_rfscale is used by rfsafetyopt() to recover min_seqrfamp and max_seqsar etc. */

            if(*rfpulse_list[RF1_SLOT].pw < gradOpt_pwrf1)
            {
                *rfpulse_list[RF1_SLOT].pw = gradOpt_pwrf1;
            }
            tmin_satoff -= (bak_pw_rf1_tot - pw_rf1 - pw_gzrf1a - pw_gzrf1d);
        }

        rfsafetyopt_doneflag = PSD_ON;
        whilecounter             = 0;

        do
        {
       
	      if( SUCCESS != rfsafetyopt( &opt_deratingfactor, rfscale_flag, &orig_rfscale, &limit_scale_seed,
                                        RF1_SLOT, rfpulse_list, rfpulseInfo) ){
                epic_error(use_ermes, "%s failed", EM_PSD_SUPPORT_FAILURE,
                           EE_ARGS(1),STRING_ARG,"rfsafetyopt");
                return FAILURE;                    
              }
 

          /* SVBranch HCSDM00102590 */
          /* Update gradOpt_rfb1opt_scale just after rf scale to make smart derating work well */
          if( gradOpt_flag )
          {
              gradOpt_rfb1opt_scale = (float)gradOpt_pwrf1 / ((float)pw_rf1_bak*orig_rfscale/opt_deratingfactor);
              ogsfRF = FMin(3, gradOpt_scale*gradOpt_RFfactor, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
              rfsafetyopt_doneflag = PSD_OFF;
          }

	      /* Perform optimizations for main sequence (idx_seqcore) only */
	      seqEntryIndex = idx_seqcore;
	      {
		   /* MRIhc43102 - Enusre that CVs changed flag is set to TRUE before calcOptimziedPulses() to ensure that
                   the dB/dt optimization will be done on the rfsafetyopt() modified waveforms */
                   if ( fabs( opt_deratingfactor - 1.0) > 0.00001 )
                   { 
                       /* Force the dB/dt optimization to run again */
                       /* set_cvs_changed_flag( TRUE ); */
                       enforce_minseqseg = PSD_ON;
                   } 
                   if ( (status = dbdtlevel_and_calcoptimize()) != SUCCESS ) {
		                 return status;
                   }
	      }
		
	      if( (status = cveval1()) != SUCCESS ){
	             	return status;
	      }

	      if (psddebugcode) 
	      {
             FILE *fp;
#ifdef PSD_HW
    fp = fopen("/usr/g/service/log/rfsafetyopt_result.log","a");
#else
    fp = fopen("rfsafetyopt_result.log","a");
#endif
                fprintf(fp,"\n-------------------------------------\n");
                fprintf(fp,"whilecounter            = %d\n", whilecounter);
                fprintf(fp,"deratingfactor          = %f\n", opt_deratingfactor);
                fprintf(fp,"pw_rf1                  = %d\n", pw_rf1);
                fprintf(fp,"pw_gzrf1a               = %d\n", pw_gzrf1a);
                fprintf(fp,"a_gzrf1                 = %f\n", a_gzrf1);
                fprintf(fp,"tmin                    = %d\n", tmin);
                fprintf(fp,"max_seqsar              = %d\n", max_seqsar);
                fprintf(fp,"min_rfavgpow            = %d\n", min_rfavgpow);
                fprintf(fp,"min_rfrmsb1             = %d\n", min_rfrmsb1);
                fprintf(fp,"min_rfampcpblty         = %d\n", min_rfampcpblty);
	              	fprintf(fp,"min_seqgrad             = %d\n", min_seqgrad);
	              	fprintf(fp,"minseqcable_t           = %d\n", minseqcable_t);
	              	fprintf(fp,"minseqchoke_t            = %d\n", minseqchoke_t);
	              	fprintf(fp,"minseqcoil_t            = %d\n", minseqcoil_t);
                fprintf(fp,"minseqgrddrv_t          = %d\n", minseqgrddrv_t);
                fprintf(fp,"minseqgpm_t             = %d\n\n", minseqgpm_t);
	              	fprintf(fp,"tmin_satoff             = %d\n", tmin_satoff);
                fprintf(fp,"max_seqsar_prepoff      = %d\n", max_seqsar_prepoff);
                fprintf(fp,"min_rfavgpow_prepoff    = %d\n", min_rfavgpow_prepoff);
                fprintf(fp,"min_rfrmsb1_prepoff     = %d\n", min_rfrmsb1_prepoff);
                fprintf(fp,"min_rfampcpblty_prepoff = %d\n", min_rfampcpblty_prepoff);
                fprintf(fp,"\n-------------------------------------\n");
                fprintf(fp,"dbdtlevel_opt           = %d\n", dbdtlevel_opt);
	              	fprintf(fp,"pidbdtper               = %f\n",pidbdtper);
	              	fprintf(fp,"srderate                = %f\n",srderate);
	              	fprintf(fp,"higher_dbdt_flag        = %d\n",higher_dbdt_flag);
		              fprintf(fp,"\n-------------------------------------\n");
                fclose(fp);
            }           
            whilecounter++;
            
        /* SVBranch HCSDM00102590 */
        /* when smart derating is on, B1 optimization runs only one time.
           Combine iteration of B1 optimization with that of Smart Derating */
        }while( (opt_deratingfactor < 0.95) && (whilecounter < 3) && (PSD_OFF == gradOpt_flag));
        
    }  /* End of rfsafetyopt */
 
    /* SVBranch HCSDM00102590 */
    rfsafetyopt_doneflag = PSD_OFF;

    /* GEHmr02638: smart derating */
    if( gradOpt_flag )
    {
        int tmp_con=0;
        float tmp_weight;

        /* SVBranch HCSDM00102590 */
        float tmp_pwgzrf1a, tmp_pwgzrf1;
        float bak_pwgzrf1_scale;
        float min_tor = 0.0;
        float min_tor_scale = 0.0;
        float tmp_tor = 0.0;

        min_tor = 1000000.0; /* set big value to ensure tmp_tor is smaller than it */

        /* To optimization pw_gzrf1, pw_gzrf1a and pw_gzrf1d, make sum of them minimal
           Similar function is done in rfsafetyopt() by iteration. */
        bak_pwgzrf1_scale     = gradOpt_pwgzrf1_scale;
        tmp_pwgzrf1a          = pw_gzrf1a / ogsfRF;
        tmp_pwgzrf1           = pw_gzrf1 * ogsfRF;
        gradOpt_pwgzrf1_scale = sqrt(tmp_pwgzrf1 * 0.5 / tmp_pwgzrf1a);

        if(gradOpt_pwgzrf1_scale > 1.0)
        {
            gradOpt_pwgzrf1_scale = 1.0;
        }

        /* when scale changes is small, do not change scale to make smart derating faster */
        if(fabs(bak_pwgzrf1_scale - gradOpt_pwgzrf1_scale) < 0.05)
        {
            gradOpt_pwgzrf1_scale = bak_pwgzrf1_scale;
        }

        /* if status of gradOpt_TE, gradOpt_RF, gradOpt_GX2, gradOpt_mode change, initial all factors */
        if( gradOpt_TE != gradOpt_TE_bak )
        {
            gradOpt_init = 1;
            gradOpt_TE_bak = gradOpt_TE;
        }

        if( gradOpt_RF != gradOpt_RF_bak )
        {
            gradOpt_init = 1;
            gradOpt_RF_bak = gradOpt_RF;
        }

        if( gradOpt_GX2 != gradOpt_GX2_bak )
        {
            gradOpt_init = 1;
            gradOpt_GX2_bak = gradOpt_GX2;
        }

        if( gradOpt_mode != gradOpt_mode_bak )
        {
            gradOpt_init = 1;
            gradOpt_mode_bak = gradOpt_mode;
        }

        if( gradOpt_gxwex != gradOpt_gxwex_bak )
        {
            gradOpt_init = 1;
            gradOpt_gxwex_bak = gradOpt_gxwex;
        }

        if( gradOpt_init )
        {
            gradOpt_init      = 0;
            gradOpt_scale     = 1.0;
            gradOpt_TRfactor  = 1.0;
            gradOpt_TEfactor  = 1.0;
            gradOpt_GX2factor = 1.0;
            /* GEHmr04246 : set target amp for chemsat killer gradient */
            if( isSVSystem())
            {
                chemsat_killer_target = CSK_TARGET;
            }
            else
            {
                chemsat_killer_target = cfxfs;
            }
            spsat_derate_scale    = 1.0;
            ogsfX1     = 1.0;
            ogsfY      = 1.0;
            ogsfZ      = 1.0;
            ogsfXwex   = 1.0;
            ogsfYk     = 1.0;
            ogsfZk     = 1.0;
            /* SVBranch HCSDM00102590 */
            ogsfRF     = FMin(3, 1.0, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
            ogsfGX2    = 1.0;
            /* SVBranch HCSDM00102590 remove update for gradOpt_RFfactor here */
        }

        /* tmp_weight can be optimized to converge quickly and avoid oscillating */
        if( gradOpt_TE )
        {
            tmp_weight = gradOpt_weight;
        }
        else
        {
            tmp_weight = gradOpt_weight * 2;
            tmp_weight = FMin(2,tmp_weight,1.0);
        }

        /* HCSDM00342902 */
        if((PSD_ON == get_cvs_changed_flag()) || (PSD_OFF == gradOpt_iter_reduce_flag))
        {
            gradOpt_iter_count_changed_flag = PSD_OFF;
            gradOpt_iter_count = gradOpt_iter_count_save;
        }
        else if((gradOpt_iter_count_act == gradOpt_iter_count_save) || (PSD_ON == gradOpt_iter_count_changed_flag))
        {
            gradOpt_iter_count = 1;
            gradOpt_iter_count_changed_flag = PSD_ON;
        }
        gradOpt_iter_count_act = 0;

        do
        {
            /* SVBranch HCSDM00115164 */
            int bak_min_seqgrad = 0;
            gradOpt_old_scale = gradOpt_scale;

            if(sbm_flag)
            {
                bak_min_seqgrad = min_seqgrad;
                min_seqgrad  = (int)(min_seqgrad / sbm_smartderating_factor);
            }

            /* SVBranch HCSDM00102590 */
            /* If derate of RF1 (ogsfRF) by smart derating is less than that of B1 optimization.
               Scale RF  and run smart derating */
            /* In order to avoid oscillation issue, after iterating by maximal allowed amount,
               set bigger tolerance to gradOpt_nonconv_tor to quit iteration */
            if( (ogsfRF > gradOpt_rfb1opt_scale) ||
                ((fabs((float)tmin_satoff/(float)min_seqgrad - 1.0) > gradOpt_tor) && (gradOpt_convergence_flag)) ||
                ((fabs((float)tmin_satoff/(float)min_seqgrad - 1.0) > gradOpt_nonconv_tor) &&
                 (PSD_OFF == gradOpt_convergence_flag)) )
            {
                float rf_scale, te_scale, tr_scale, gx2_scale, min_scale;

                /* SVBranch HCSDM00102590 */
                gradOpt_convergence_flag = PSD_ON;  /* set convergence flag to 1 first */
                te_scale = gradOpt_scale * gradOpt_TEfactor;
                tr_scale = gradOpt_scale * gradOpt_TRfactor;
                gx2_scale = gradOpt_scale * gradOpt_GX2factor;
                /* SVBranch HCSDM00102590 */
                rf_scale = gradOpt_scale * gradOpt_RFfactor;
                min_scale = FMin(4, rf_scale, te_scale, tr_scale, gx2_scale);

                if( ((tmin_satoff >= min_seqgrad) && (min_scale >= (gradOpt_scale_Max - gradOpt_tor))) ||
                    ((min_seqgrad >= tmin_satoff) && (gradOpt_scale <= (gradOpt_scale_Min + gradOpt_tor))) )
                {

                    /* SVBranch HCSDM00115164 */
                    if(sbm_flag)
                    {
                        min_seqgrad = bak_min_seqgrad;
                    }

                    break;
                }
                else
                {
                    gradOpt_scale = gradOpt_scale * (((float)tmin_satoff/(float)min_seqgrad-1.0)*tmp_weight+1.0);
                    gradOpt_scale = FMin(2, gradOpt_scale, gradOpt_scale_Max);
                    gradOpt_scale = FMax(2, gradOpt_scale, gradOpt_scale_Min);
                }

                /* Perform optimizations for main sequence (idx_seqcore) only */
                seqEntryIndex = idx_seqcore;
                /* set_cvs_changed_flag( TRUE ); */
                enforce_minseqseg = PSD_ON;

                /* SVBranch HCSDM00102590 */
                /* set gradOpt_run_flag=PSD_ON to update gradOpt_TEfactor, gradOpt_TRfactor etc. */
                gradOpt_run_flag = PSD_ON;

                if ( (status = dbdtlevel_and_calcoptimize()) != SUCCESS )
                {
                    return status;
                }

                if ( (status = cveval1()) != SUCCESS )
                {
                    return status;
                }

                /* SVBranch HCSDM00102590 */
                gradOpt_run_flag = PSD_OFF;

                /* backup best gradOpt_scale to offer minimal TR */
                tmp_tor = FMax(2, (float)tmin_satoff/1000000.0, (float)min_seqgrad/1000000.0);
                if( tmp_tor < min_tor )
                {
                    min_tor = tmp_tor;
                    min_tor_scale = gradOpt_scale;
                }
            }
            else
            {

                /* SVBranch HCSDM00115164 */
                if(sbm_flag)
                {
                    min_seqgrad = bak_min_seqgrad;
                }

                break;
            }

            tmp_con++;

            /* HCSDM00342902 */
            gradOpt_iter_count_act = tmp_con;

        } while( tmp_con < gradOpt_iter_count );

        /* SVBranch HCSDM00102590 */
        /* when tmp_con == gradOpt_iter_count, convergence failed
           set gradOpt_scale to best value*/
        /* HCSDM00438233  Do not apply non convergent mode to MERGE */
        if( (tmp_con == gradOpt_iter_count) && (gradOpt_iter_count > gradOpt_iter_nonconv_threshold) )
        {
            gradOpt_convergence_flag = PSD_OFF;
            gradOpt_scale = min_tor_scale;
            /* Perform optimizations for main sequence (idx_seqcore) only */
            seqEntryIndex = idx_seqcore;
            set_cvs_changed_flag( TRUE );

            /* set gradOpt_run_flag=PSD_ON to update gradOpt_TEfactor, gradOpt_TRfactor etc. */
            gradOpt_run_flag = PSD_ON;

            if ( (status = dbdtlevel_and_calcoptimize()) != SUCCESS )
            {
                return status;
            }

            if ( (status = cveval1()) != SUCCESS )
            {
                return status;
            }

            gradOpt_run_flag = PSD_OFF;

            gradOpt_nonconv_tor = fabs((float)tmin_satoff/(float)min_seqgrad - 1.0) * 1.000001;
            /* when tolerance is too big, run smart derating again to get better result*/
            if(gradOpt_nonconv_tor > gradOpt_nonconv_tor_limit)
            {
                gradOpt_nonconv_tor = gradOpt_nonconv_tor_limit;
            }
        }

    }
    else
    {
        gradOpt_scale     = 1.0;
        gradOpt_TEfactor  = 1.0;
        gradOpt_TRfactor  = 1.0;
        gradOpt_RFfactor  = 1.0;
        gradOpt_GX2factor = 1.0;
        /* GEHmr04246 : set target amp for chemsat killer gradient */
        if( isSVSystem() )
        {
            chemsat_killer_target = CSK_TARGET;
        }
        else
        {
            chemsat_killer_target = cfxfs;
        }
        spsat_derate_scale    = 1.0;
        ogsfX1     = 1.0;
        ogsfY      = 1.0;
        ogsfZ      = 1.0;
        ogsfXwex   = 1.0;
        ogsfYk     = 1.0;
        ogsfZk     = 1.0;
        ogsfRF     = 1.0;
        ogsfGX2    = 1.0;
        /* SVBranch HCSDM00102590 remove "rfsafetyopt_doneflag = PSD_OFF" */
        
        
    }

    if (PSD_ON == exist(oprealtime))
    {
        skip_rotmat_search = PSD_OFF;
        skip_waveform_rotmat_check = PSD_ON;

        if ( (status = cveval1()) != SUCCESS )
        {
            return status;
        }

        skip_waveform_rotmat_check = PSD_OFF;
    }

    /* calculate phorder and viewoffs */
    if( SUCCESS != (status = fmpvas_cveval( &avmintdel1, &phorder, &viewoffs,
                                            &dda, act_tr, exist(opvps),
                                            sp_sattime, feature_flag )) ) {
        return status;
    }

    /*
     * MRIge43472 - Limit the maximum overlap to 80% of the slice
     * thickness used.  Though the use of the advisory pop-up would be
     * better in this case, it's not used to avoid 'continous pop-up
     * problems' which might occur with graphic Rx!
     * MRIge72312 - This check was originally in fmpvas_cvcheck() but
     * was moved to fmpvas_cveval() to avoid menu chase problems.
     * MRIge90793 - Moved the check from fmpvas_cveval() so that it is a
     * generic check based on pi_neg_sp.  This allows the error to be
     * thrown with other features like 2D FIESTA Fat SAT.
     */
    /*
     * MRIge92367 for fsfiesta, pioverlap is 1, also this check only
     * applies for negative spacing, when spacing is
     * positive, the spacing could be larger than the slice thickness
     */
    if( (PSD_ON == pi_neg_sp || PSD_ON == pioverlap ) &&
        (exist(opslspace)<0) && existcv(opslthick) &&
        (fabs( exist(opslspace) ) > (exist(opslthick) * 0.8)) ) {
        epic_error( use_ermes, "Overlap should be less than 80%% of the "
                    "prescribed slice thickness.",
                    EM_PSD_SLICE_OVERLAP_EXCEEDED, EE_ARGS(0) );
        return FAILURE;
    }

    /* HD merge_3TC_11.0 START */
    if ((PSD_ON == single_slice_flag) || (exist(opcgate)==PSD_ON) 
        || (feature_flag & ECHOTRAIN) || (exist(opmph) == PSD_ON)) {
        /*
          When doing hybrid interleaving, slquant1 may not be slices
          per TR. We know that we can't interleave slices into something
          less than the minimum TR so this gives us a mode to detect
          and correct that. But should it always be 1?
        */
        slq_per_tr = 1;
    } else {
        slq_per_tr = slquant1;
    }
    /* HD merge_3TC_11.0 END */

    /* Meng: put this into cveval() from predownload because peak sar
       and average sar are not updated until download */

    /* Begin RTIA comment */
    /* For RTIA, ave_sar and peak_sar will be set in cveval1() */
    /* MRIge75651 */

    if ( !(feature_flag & RTIA98) ) {
        strcpy(entry_point_table[L_SCAN].epname, "scan");
        if( peakAveSars( &ave_sar, &cave_sar, &peak_sar, &b1rms, (int)RF_FREE,
                         rfpulse_list, L_SCAN, (int)(act_tr / slq_per_tr) ) == FAILURE )
        {
            epic_error(use_ermes, "%s failed", EM_PSD_SUPPORT_FAILURE,
                       EE_ARGS(1),STRING_ARG, "peakAveSars");
            return FAILURE;
        }

        /* This does a powermon optimized for MPL */
        /* MRIge75651 - added coil average SAR argument */
        if ( mpl_powermon( feature_flag, maxB1,
                           &ave_sar, &cave_sar, &peak_sar, &b1rms,
                           act_tr, slq_per_tr, 
                           cs_sattime, sp_sattime,
                           RF_FREE, rfpulse_list ) == FAILURE)
        {
            /* Allow lower level error messages to be reported */
            return FAILURE;
        }
    }

    /* Meng: moved to cveval() from predownload() */ 
    piasar = ave_sar;   /* average SAR report to UI */
    picasar = cave_sar; /* average coil SAR report to UI */
    pipsar = peak_sar;  /* peak SAR report to UI */
    pib1rms = (float)b1rms; /* Report predicted b1rms value on the UI */    

    /* SNR monitor */
    _pifractecho.fixedflag = 0;
    pifractecho = fecho_factor;
    setexist(pifractecho,_opte.existflag);
    _pifractecho.fixedflag = _opte.fixedflag;

    /*MRIge91882*/
    if((((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC))&&(exist(opplane)==PSD_3PLANE))&&
       (!(feature_flag&IRPREP)&&!(feature_flag & FIESTA)))
    {
        opflip = 30.0;
        cvmin(opflip,30.0);
        cvmax(opflip,30.0);
        cvmax(opmultistation,0);
        cvmax(opirprep,0);
        cvmax(opsrprep,0);
        cvmax(opmph,0);
        cvmax(opdeprep,0);
        cvmax(oprealtime,0);
        cvmax(opET,0);
        cvmax(opmt,0);
        oprbw =31.25;
        oprbw2=31.25;
        cvmin(oprbw,31.25);
        cvmax(oprbw,31.25);
        cvmin(oprbw2,31.25);
        cvmax(oprbw2,31.25);

        avminflip =30.0;
        avmaxflip = 30.0;
        avminti =0;
        avmaxti =0;
        avminrbw=31.25;
        avmaxrbw = 31.25;
        avmaxrbw2 = avmaxrbw;
        avminbspti=0;
        avmaxbspti=0;

        pitrnub =0;
        pite1nub=0;
        pite2nub=0;
        piechnub = 0;
        pitinub = 0 ;
        pirbwpage = 0;
        pircbnub = 0;
        pircb2nub = 0 ;
        pifanub = 0;
        pidefrbw= 31.25;
        piccsatnub = 0;
        pisatnub= 0;
        pisupnub = 0;
        piisil = 0 ;
        pipaunub = 0;
        piadvcard =0;
        pisatnub = 0;
        pichemsatopt = 0;


        threeplane_dda = (int) (1s/act_tr);
        if ( firstSeriesFlag && exist(opmultistation) == PSD_OFF ) {
            _opuser0.fixedflag = 0;
            _opuser0.existflag = 0;
            opuser0 = 0.0;
            cvmod( opuser0, -MAXFLOAT, MAXFLOAT, 0.0, "User CV variable  0", 0, "" );
        }

        num_stations_flag = ( pimultistation &&
                              existcv(opmultistation) &&
                              (exist(opmultistation) == PSD_ON) &&
                              (exist(opstation) == 1));
        if ( num_stations_flag &&
             (oploadprotocol == PSD_OFF) &&
             firstSeriesFlag) {
            pititle = 1;
            piuset |= use0;
            opuser0 = 1.0;
            cvmod( opuser0, 1.0, 4.0, 1.0, "Number of Stations (1..4)", 0, "" );
            opnostations = (int)exist(opuser0);
        } else {
            piuset &= ~use0;
        }

        if ((oploadprotocol == PSD_ON) && (exist(opmultistation) == PSD_ON)) {
            opnostations = (int)exist(opuser0);
            cvmin(opuser0, (float) opnostations);
            cvmax(opuser0, (float) opnostations);
            _opnostations.fixedflag = 1;
            _opnostations.existflag = 1;
        }
    } else {
        cvmax(opmultistation,0);
        cvoverride(opmultistation,PSD_OFF,PSD_FIX_OFF,PSD_EXIST_ON);
        /* GEHmr03549 : To avoid range out of oprbw2 */
        cvmin(oprbw2, 0.0);
        cvmax(oprbw2, cfmaxbw);
    }

    /* Gray out the # of echoes field, no User CVs */
    if(gradspec_flag)
    {
        piechnub = 0;
        piuset = 0;
    }
    /*MRIge93435*/ 
    if (PSD_3PLANE == exist(opplane)){
        if(feature_flag & IRPREP) {
            avminrbw = 2.0;
            pircbnub=6;
            pidefrbw = 31.25;
            cvdef(oprbw,pidefrbw);
            cvmax(oprbw,avmaxrbw);
            cvmin(oprbw,avminrbw);
            pircbval2 = 125.0;
            pircbval3 = 83.33;
            pircbval4 = 62.50;
            pircbval5 = 31.25;
            pircbval6 = 15.63;
 	    pisatnub = 0;
	    pichemsatopt = 0;
        } 
        if(feature_flag & FIESTA) {
	    avminrbw =62.5;
            pidefrbw = 125.0;
            cvdef( oprbw, pidefrbw );
            cvmax(oprbw,avmaxrbw);
            cvmin(oprbw,avminrbw);
            pircbnub = 5;
            pircbval2 = 100.0;
            pircbval3 = 125.0;
            pircbval4 = 166.6;
            pircbval5 = 200.0;
            cvmax(opmph,0);
       	    cvmax(opdeprep,0);
	    cvmax(opirprep,0);
	    cvmax(opsrprep,0);
	    cvmax(oprealtime,0);
	    cvmax(opET,0);
	    cvmax(opmt,0);
	    pisatnub = 0;
            pichemsatopt = 0;
        } 
    } else {
        cvmin(oprbw,0.0);
        cvmax(oprbw,cfmaxbw);
    }

    /* Limit rbw to make sure avmaxxres not too small */
    if(gradspec_flag)
    {
        avminrbw = 31.25;
        pircbnub  = 5;
        pircbval2 = 125.0;
        pircbval3 = 83.33;
        pircbval4 = 62.5;
        pircbval5 = 31.25;

        cvdef(oprbw, 125.0);
        pidefrbw = 125.0;
        if( oprbw < avminrbw )
        {
            cvoverride(oprbw, avminrbw, PSD_FIX_ON, existcv(oprbw));
        }
    }

    if(((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC)||(feature_flag & FIESTA)||
        (feature_flag&IRPREP)) && (exist(opplane)==PSD_3PLANE)){
        opirmode =1;
        cvoverride(opirmode, 1, PSD_FIX_OFF, PSD_EXIST_ON);
    }
    
    if(perfusion_flag)
    {
        opirmode = 0;
        cvoverride(opirmode, 0, PSD_FIX_OFF, PSD_EXIST_ON);
    }    
    
    if ( (exist(opirprep)==PSD_ON) || (exist(opdeprep)==PSD_ON) || (exist(opmph)==PSD_ON) ) 
    {
	/* HCSDM00445737 : Enabled the ChemSat UI for FSFIESTA with MPH */    
	if ( ((fsmde_support) && (PSD_ON == mdeplus_option_key_status)) ||
             ((feature_flag & FIESTA) && (PSD_OFF == exist(opcgate))) )
        {
            pisatnub = 1;
            pichemsatopt = 2;
        }
        else
        {
            pisatnub = 0;
        }
    } else {
        pisatnub = 1;
    }

    /* Disable ChemSat and SpSat selection */
    if(gradspec_flag)
    {
        pisupnub = 0;
        pisatnub = 0;
    }

    /* HCSDM00367496 */
    if( (epic_findputcvnum("opnpwfactor") == TRUE) || (epic_findputcvnum("opnex") == TRUE) )
    {
        int rtnval;
        rtnval = frac_nex_check();
        if(rtnval != SUCCESS)
        {
            return rtnval;
        }
    }

    /* Begin Debug */
    {
        if (debug_rfamp == 1){
            FILE *fpp;
            char ti_fn[BUFSIZ];
#ifdef PSD_HW
            const char *ti_dn = "/usr/g/service/log";
#else /* !PSD_HW */
            const char *ti_dn = ".";
#endif /* PSD_HW */

            sprintf( ti_fn, "%s/rfampconfig.info", ti_dn );
            fpp = fopen( ti_fn, "w" );
            if( NULL != fpp ) {
		fprintf( fpp, "##################### START #############################\n" );
		fprintf( fpp, " rfupa                	= %d\n", rfupa );
		fprintf( fpp, " rfupd            	= %d\n", rfupd );
		fprintf( fpp, " cfrfminblank        	= %d\n", cfrfminblank );
		fprintf( fpp, " cfrfminunblk         	= %d\n", cfrfminunblk);
		fprintf( fpp, " cfrfminblanktorcv    	= %d\n", cfrfminblanktorcv);
		fprintf( fpp, " cfrfampftconst		= %f\n", cfrfampftconst );
		fprintf( fpp, " cfrfampftlinear		= %f\n", cfrfampftlinear );
                fprintf( fpp, " cfrfampftquadratic      = %f\n", cfrfampftquadratic );
		fprintf( fpp, "##################### END #############################\n" );
		fclose( fpp );
            }else {
                fprintf( stderr, "ERROR: Unable to open %s.\n", ti_fn );
            }
        }
    }
/* End Debug */

    if(rfsafetyopt_timeflag)
    {  
int diff;
FILE *fp;
#ifdef PSD_HW
        fp = fopen("/usr/g/service/log/rfsafetyopt_time.log","a");
#else
        fp = fopen("rfsafetyopt_time.log","a");
#endif

        timecountE = timecountE + 1;
        gettimeofday(&t, NULL);
        end_time = ((LONG)(t.tv_sec)) * 1000000 + t.tv_usec;
        diff = end_time - start_time;        
        if(timecountE == timecountB)
            fprintf(fp,"%d\t\t\%10d\n",timecountE, diff);
        
        fclose(fp);
    }

    if( (PSD_OFF == pircbnub) && (PSD_OFF == exist(opautorbw)) )
    {
        opautorbw = PSD_ON;
    }

    /* Control access to the 3D Grad Warp checkbox (MRIhc48580) */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) ||
        (PSD_ON == pure_ref) || (PSD_3PLANE == exist(opplane)) )
    {
        /* 3-Plane and ASSET/PURE Cal primary modes are never compatible 
         * with 3D grad warp.  Disable and hide 3D grad warp controls */
        opauto3dgradwarp = PSD_OFF;
        pi3dgradwarpnub = 0;
    }
    else if( ((PSD_OFF == opdynaplan) && (PSD_ON == exist(opmph))) || 
        ((PSD_ON == exist(opcgate)) && (opaphases > 1 )) || cardt1map_flag )
    {
        /* MRIhc48581 3D Grad warp not compatible with regular multi-phase
         * or  cardiac multi-phase.  Always show control, but enable/disable
         * access to the checkbox based on options chosen */ 
        opauto3dgradwarp = _opauto3dgradwarp.defval;
        pi3dgradwarpnub = 0;
    }
    else
    {
        /* default */
        opauto3dgradwarp = _opauto3dgradwarp.defval;
        pi3dgradwarpnub = _pi3dgradwarpnub.defval;
    }

    info_fields_display(&piinplaneres,&pirbwperpix,&piesp,&ihinplanexres,
                        &ihinplaneyres,&ihrbwperpix,&ihesp,
                        DISP_INPLANERES|DISP_RBWPERPIX,
                        NO_ESP_DEFAULT_VALUE,
                        NOSCALE_INPLANEYRES_SQP);

    if( PSD_ON == track_flag )
    {
        if( FAILURE == track_cveval() )
        {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE, EE_ARGS(1), STRING_ARG, "Track+_eval");
            return FAILURE;
        }
    }

    /* set flag for AutoCoil to bypass selectable reg position check */
    if(PSD_3PLANE == exist(opplane))
    {
        psd_annefact_level = -1;
    }
    else
    {
        psd_annefact_level = 0; /* default */
    }
    /* set header CV */
    rhpsd_annefact_level = psd_annefact_level;

    return SUCCESS;
}   /* end cveval() */


/*
 *  set_fgre_targets
 *
 *  Type: Function
 *
 *  Description:
 *    Set target fields for all gradient pulses.
 */
STATUS
set_fgre_targets( PULSE_TABLE *pulse_table, 
                  const LOG_GRAD *p_loggrd, 
                  INT flag )
{
    /* Begin RTIA change - casting gxwtarget to DOUBLE to match prototype */
    if ( set_pulse_target( pulse_table, GXW_SLOT, (DOUBLE)gxwtarget, 
                           XBOARD ) == FAILURE ) {
        /* End, RTIA */
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "set_pulse_target" );
        return FAILURE;
    }

    /* Dual echo - RJF, DUALECHO */
    if ( set_pulse_target( pulse_table, GXW2_SLOT, (DOUBLE)gxwtarget,
                           XBOARD ) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "set_pulse_target" );
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GX1_SLOT, p_loggrd->tx_xyz, 
                           XBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GXFC_SLOT, p_loggrd->tx_xyz, 
                           XBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GX2_SLOT, p_loggrd->tx_xyz,
                           XBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GYFE1_SLOT, p_loggrd->ty_xyz, 
                           YBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GYFE2_SLOT, p_loggrd->ty_xyz, 
                           YBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GYK2b_SLOT, p_loggrd->ty_xyz, 
                           YBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GY1_SLOT, p_loggrd->ty_xyz, 
                           YBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GZRF1_SLOT, p_loggrd->tz_xyz, 
                           ZBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GZ1_SLOT, p_loggrd->tz_xyz, 
                           ZBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GZFC_SLOT, p_loggrd->tz_xyz, 
                           ZBOARD ) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ( set_pulse_target( pulse_table, GZK_SLOT, p_loggrd->tz_xyz, 
                           ZBOARD ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_pulse_target");
        return FAILURE;
    }

    if ((feature_flag & FIESTA) && (PSD_OFF != fiesta_intersl_crusher)) {
        if ( set_pulse_target( pulse_table, GZINTERSLK_SLOT, p_loggrd->tz_xyz,
                               ZBOARD ) == FAILURE ) {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_pulse_target");
            return FAILURE;
        }
    }

    if ( ( flag & FASTCARD ) || (flag & FASTCARD_PC ) || 
         (flag & GATEDTOF) || (flag & UNGATEDTOF) ) {
        if ( set_fastcard_targets(pulse_table, p_loggrd, use_ermes) == FAILURE ) {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_fastcard_targets");
            return FAILURE;
        }
    }

    if ( (flag & IRPREP) || (flag & DEPREP) ) {
        if ( set_prep_targets( pulse_table, p_loggrd ) == FAILURE ) {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_prep_targets");
            return FAILURE;
        }
    }

    if ( (flag & (FASTCARD | ECHOTRAIN) ) && (flag & CHEMSAT) ) {
        if ( FAILURE == set_chemsat_fastcard_targets( pulse_table, p_loggrd,
                                                      use_ermes ) ) {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "set_chemsat_fastcard_targets" );
            return FAILURE;
        }
    } else if ( flag & CHEMSAT ) {
        if ( set_chemsat_targets( pulse_table, p_loggrd, use_ermes ) == FAILURE ) {
            epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_chemsat_targets");
            return FAILURE;
        }
    }

    if (flag & SPSAT) {
        if (set_spsat_targets(pulse_table) == FAILURE) {
            epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_spsat_targets");
            return FAILURE;
        } 
    }

    /* Tagging - 03/Jun/97 - GFN */
    if ( flag & TAGGING ) {
        if ( set_tagging_targets( pulse_table, p_loggrd, use_ermes ) == FAILURE ) {
            epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_tagging_targets");
            return FAILURE;
        }
    }

    /* ET */
    if ( flag & ECHOTRAIN) {
        if ( set_echotrain_targets( pulse_table, p_loggrd, gxwtarget ) == FAILURE ) {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "set_echotrain_targets");
            return FAILURE;
        }
    }

    return SUCCESS;
}   /* end set_fgre_targets() */


/*
 *  cveval1
 *
 *  Type: Function
 *
 *  Description:
 *    This function should contain all the generic code for the engine.
 *    All code that is generic should be declared first, followed
 *    by code defined by the modules. The last section of cveval1()
 *    should be code that is feature dependent, e.g., rf scaling, 
 *    sar, etc.
 */
STATUS
cveval1( void )
{
    INT nframes[7];     /* number of TR reps for each scan time button */

    FLOAT use_tr;		      /* Use the proper tr value for pisctimx.
                                         Value is determine if psd is 2dfast, 
                                         fgre, or cardiac gated. */
    FLOAT extra_time;                 /* extra time per scan, dependent
                                         on nex */
    FLOAT extra_Acqtime;              /* extra time per acquisition, 
                                         independent of nex */
    FLOAT extra_delay;
    FLOAT num_times;                  /* number of times TR has to be
                                         repeated to complete scan */

    /* Begin RTIA */
    INT minte_flowcomp;
    INT mintr_flowcomp;
    INT index;
    INT active_sequences = 0;
    INT sar_time ; 
    /* End RTIA */

    /*MRgFUS tracking timing*/
    extern float formulaA, formulaB;

    INT ir_prep_time;   /* prep seq time calculated in Prep.e (tseq_prep) */

    const CHAR funcName[] = "cveval1";

    /* SSHMDE */
    INT prep_dda = 0;
    INT extra_minseqgrad = 0;

    /* Fiesta-TC */
    extern int coredda;

    /*
     * SECTION A: Feature independent code. 
     *
     * Place code here that does not depend on 
     * changes made by features.  There may
     * be exceptions.
     */


    /* Begin RTIA move */
    /* RTIA moved RBW and FOV UI settings to before the 
       feature init calls in cveval. Each cveval_init may 
       change these as needed */
    /* End RTIA move */

    /* Begin RTIA delete */
    /* RTIA deletes the setting of nex buttons because 
       this has been taken care of before the feature init calls */
    /* End - RTIA delete */

    /* There is no MSMA limitation anymore.  Radial prescriptions are
       always on for all FGRE prescriptions */
    pizmult = PSD_ON;

    /* Begin RTIA */
    /* RTIA moved screencontrol for xres,yres, spacing to cveval 
       before feature inits */
    /* End RTIA */

    /* Begin RTIA */
    /* For RTIA, allow this to be caught in rtia_Cvcheck */
    if ( exist(opmt) == PSD_ON && existcv(opmt) == PSD_ON &&
         (!(feature_flag & RTIA98)) && 
         (!((feature_flag & ECHOTRAIN) && (exist(oprealtime) == PSD_ON)))) {
        /* End RTIA */
        epic_error( use_ermes, "MT not Supported", EM_PSD_MT_INCOMPATIBLE, 0 );
        return FAILURE;
    }

  
    /***** feature eval *********************/
    if ( ChemSat_Eval( &cs_sattime, cs_sat, fiesta2d_sat_getspecir_delay(), 
                       bd_index, use_ermes, feature_flag ) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "ChemSat_Eval" );
        return FAILURE;
    }  
  
    if ( SpSatEval( &sp_sattime, vrg_sat, bd_index, 
                    feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "SpSatEval");
        return FAILURE;
    }
  
    /* Begin RTIA */
    if ( FAILURE == Hard180_eval( &hard180_time, feature_flag ) ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "Hard180_eval" );
        return FAILURE;
    }

    if ( FAILURE == RTIA_dummy_sequence_eval( feature_flag, time_ssi,
                                              &rtia_dummy_sequence_TR ) ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "RTIA_dummy_sequence_eval" );
        return FAILURE;
    }
    /* End RTIA */


    /***** end feature eval *********************/
  
  
    if ( ((exist(opsat) == PSD_ON) && 
          ((opsatx) || (opsaty) || (opsatz) || (opexsatmask))) ||
         (feature_flag & RTIA98)) {
        /* where the 20us is the length of the seqsat_fgre pulse  */
        sp_sattime += (tlead_spsat + 20us + time_ssi);
        /* Make sure that this is aligned properly - RTIA, RJF */
        sp_sattime = RUP_GRD( sp_sattime );
    }
  
    /* BJM: MRIge57110 - this is placed here as A TEMPORARY KLUDGE!!!  */
    /* there exists a discrepancy between the hardware RF unblank duty */
    /* cycle and what actually exists in the PSD model.  This causes a */
    /* duty cycle trip when fat-sat is toggled on/off in realtime.     */
    /* Hardware eng. has been contacted and the PSD model will be      */
    /* corrected so this stupid kludge can be removed.....             */

    if ( (exist(oprealtime) == PSD_ON) && (exist(oppseq)!=PSD_SSFP))
    {
        /*  add 1000us to the length of the chem sat time  */
        cs_sattime += 1000us;
        cs_sattime = RUP_GRD( cs_sattime );
    }
  
    /**************************
     *  Starting point logic  *
     **************************/


    td0 = GRAD_UPDATE_TIME;

    psd_card_hdwr_delay = 10ms;
    sp_satcard_loc      = 0;
  
    choplet = 0;

    rhptsize = opptsize;

    rhfrsize = echo1_filt->outputs;
    
    rhdab0s = cfrecvst;  /* start receiver for DAB to poll */
    rhdab0e = (int)getRxNumChannels() - 1;  /* end receiver for DAB to poll */
    
    if( (feature_flag & MFGRE) || r2_flag ) rhnecho = exist(opnecho)*intte_flag;
    if ( rawdata ) {
        slice_size = (1 + baseline + rhnframes + rhhnover) *
            (INT)((FLOAT)(2 * rhptsize * rhfrsize * rhnecho) *
                  truenex);
    } else {
        slice_size = (1 + rhnframes + rhhnover) *
            2 * rhptsize * rhfrsize * rhnecho;
    }
  
  
    rhcphases = 1;
    rhctr     = 1;
    rhcrrtime = 1;

    sldeltime = 0;   /* inter sequence delay is 0 unless changed otherwise. */

    /*
     * Set avmaxyres. The rest of the av{min|max}{x|y}res values have already
     * been set in InitAdvPnlCVs() based in the _op{x|y}res.{min|max}val values.
     */
    /* RTIA changes exist(opfov) to  psd_fov */  /* ASSET */
    /* FIESTA derating  05/16/2005 YI
    if ( maxyres( &avmaxyres, loggrd.ty_xyz, yrt, avail_pwgy1,
    */ 
    if ( maxyres( &avmaxyres, derate_gy_G_cm*ogsfY,
                  RUP_GRD((ceil)(yrt * derate_gy_factor * ogsfY)), avail_pwgy1,
                  (float) nop * psd_fov * exist(opphasefov) * asset_factor,
                  gy1_pulse, PHASESTEP32 ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "maxyres" );
        return FAILURE;
    }

    /* MRIhc49539: check current nucleus against coil DB: */
    if((n32)specnuc != coilInfo[0].rxNucleus)
    {
        epic_error(use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "This PSD", STRING_ARG, "the selected coil");
        return FAILURE; 
    }

    if ( FAILURE == prescan_cveval() ) {
        epic_error( use_ermes, "%s failed: %f ", EM_PSD_ROUTINE_FAILURE1,
                    EE_ARGS(2), STRING_ARG, "prescan_cveval()",
                    FLOAT_ARG, phygrd.zrt );
        return FAILURE;
    }

    if ( set_fgre_targets( &pulse_table, &loggrd, feature_flag) == FAILURE ) {
        /* Don't put an error string here since it is passed up from
           function already */
        return FAILURE;
    }

    /* Tagging - 04/Jun/97 - GFN */
    if ( FAILURE == tagging_cveval( &phorder,
                                    seq_length,
                                    bd_index,
                                    feature_flag,
                                    use_ermes,
                                    time_ssi,
                                    rfpulseInfo ) ) {
        return FAILURE;
    }


    /* call spsat eval again to make sure that the powerscale
       values are set correctly */
    if ( SpSatEval( &sp_sattime, vrg_sat, bd_index,
                    feature_flag ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "Spatial Sat Eval" );
        return FAILURE;
    }
  
    if ( set_fmpvas_ccsat(feature_flag) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_fmpvas_ccsat");
        return FAILURE;
    }

    /* RTIA begin change */
    if ( ((exist(opsat) == PSD_ON) && 
          ((opsatx) || (opsaty) || (opsatz) || (opexsatmask))) ||
         (feature_flag & RTIA98) ) {
        /* were the 20us is the length of the seqsat_fgre pulse  */
        sp_sattime += (tlead_spsat + 20us + time_ssi);
        sp_sattime = RUP_GRD (sp_sattime);
    }
    /* End RTIA */

    /**************
     *  Chem Sat  *
     **************/
    tlead_cssat = RUP_GRD(rfFrequencyPacketLength() + sq_sync_length[bd_index] + 1us);
    cs_satstart = RUP_GRD(tlead_cssat - rfupa);

    /* Begin RTIA */
    if ( FAILURE == CalcFlowCompMinTimes( t_exb, a_gxw, non_tetime,
                                          fecho_factor, pw_gxw_frac,
                                          pw_gxw_full, cs_sattime,
                                          sp_sattime, hard180_time,
                                          &mintr_flowcomp, &minte_flowcomp,
                                          feature_flag) ) {
        return FAILURE;
    }

    RTIA_set_avminte( &avminte, &avmaxte, minte_flowcomp, feature_flag );
    /* End RTIA */


    /*
     * end cveval1() SECTION A
     */


    /*
     * SECTION B: Feature dependent code. 
     *
     * Place code here that requires some
     * determination by feature calls.
     */

    if ( mph_params(&sldeltime, feature_flag) == FAILURE ) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "mph_params" );
        return FAILURE;
    }

    /* spgr variables */
    spgr_flag = ((exist(oppseq)==PSD_SPGR) ||
                 (exist(oppseq)== PSD_TOFSP) || 
                 ((feature_flag & RTIA98) ? PSD_ON : PSD_OFF)); 

    seed = seeddef * spgr_flag;	/* random seed for phase spoiling */

    /* Set rhdaxres, rhdayres and rhimsize */
    set_image_rh();

    /* maxslquanttps returns maximum bamsize and enables piautopause.
       Divides bamsize by slice_size * num. of reconstructed phases */

    if ( maxslquanttps( &max_bamslice, rhimsize, slice_size, exist(opfphases), NULL ) == FAILURE ) {
        epic_error( use_ermes, "Not enough memory for scan size "
                    "(cftpssize=%d). Reduce scan size.",
                    EM_PSD_SCAN_SIZE, EE_ARGS(1), INT_ARG, cftpssize );
        return FAILURE;
    }

    /* Gradient coil heating calculations */
    int num_overscans = 0;
    num_overscans = rhnframes - phaseres / 2 + rhhnover;
    if ((status = avepepowscale(&ave_grady_gy1_scale, phaseres, num_overscans)) != SUCCESS)
    {
        return status;
    }

    gy1_pulse->scale = ave_grady_gy1_scale;
    gy1r_pulse->scale = ave_grady_gy1_scale;

    if( et_grad_calc( feature_flag, etl, exist(opfcomp), tex2rd,
                      read_shift, grdrs_offset, gzrf1_pulse, 
                      gzfc_pulse, gz1_pulse, gx1_pulse, 
                      gxfc_pulse, gxw_pulse, gy1_pulse, gy1r_pulse,
                      gzk_pulse) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "et_grad_calc" );
        return FAILURE;
    }
       
    /**
     * WE MAY REMOVE THE form_grad_pulse_list() CALL FROM HERE BECAUSE
     * THIS WAS ALREADY DONE BEFORE DURING dB/dt OPTIMIZATION.
     */
    form_rf_pulse_list( pulse_table, rfpulse_list, &RF_FREE );
    form_grad_pulse_list( pulse_table, XBOARD, gradx_list, &GX_FREE );
    form_grad_pulse_list( pulse_table, YBOARD, grady_list, &GY_FREE );
    form_grad_pulse_list( pulse_table, ZBOARD, gradz_list, &GZ_FREE );

    /* Begin RTIA addition */
    if (feature_flag & RTIA98) {
        deactivate_chemsat_in_prescan(rfpulse_list);
        deactivate_spsat_in_prescan(rfpulse_list);
        /* For RTIA, second pass prescan will use the same Transmit attenuation 
           as scan entry point. The RF pulse and the core sequence  for scan will
           be reused for mps2/aps2. The alpha pulse will not be scaled to
           bring up the amplitude to 1. This is ok since we have only one RF pulse 
           in the sequence. This way, the additonal transmit attenuation calculated 
           for scan can be reused for prescan entry points. Taking out the 
           mps2 aps2 activity flags doesn't do anything due to this. RJF 23 Dec 98. */
    }
    /* End RTIA addition */

    if ( mpl_sat_scale(feature_flag) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "mpl_sat_scale");
        return FAILURE;
    }

    /* Tagging - 04/Jun/97 - GFN */
    if ( tagging_grad_scale( feature_flag ) == FAILURE) {
        epic_error( use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "tagging_grad_scale" );
        return FAILURE;
    }

    /* ENH - 13/Aug/1997 - GFN */
    /* Scale flow encoding gradients for gradient heating */
    if (fastcardPC_scale_flow_grads(feature_flag, &a_gx1, &a_gxfc, 
                                    &a_gz1, &a_gzfc, a_gy1a, a_gyfe1) ==
        FAILURE) {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fastcardPC_scale_flow_grads" );
        return FAILURE;
    }

    /* Begin RTIA comment */
    /* Scale the RF amplitudes assuming the worst case
       sequence combination in realtime. */
    /* For nonrealtime case, placing the code here doesn't affect anything. */
    /* End RTIA comment */

    /*
     * RF Scaling
     * Scale SAT Pulses to the area of the 90 pulse.
     */

    /* First, find the peak B1 for the whole sequence. */
    if (findMaxB1Seq(&maxB1Seq, maxB1, MAX_ENTRY_POINTS, rfpulse_list, RF_FREE) == FAILURE)
    {
        epic_error(use_ermes,supfailfmt,EM_PSD_SUPPORT_FAILURE,EE_ARGS(1),STRING_ARG,"findMaxB1Seq");
        return FAILURE;
    }

    /*For MRgFus tracking*/
    if(track_flag)
    {
        extern float maxB1_trk_scan;
        extern float maxB1Seq_trk;

        maxB1[L_SCAN] = FMax (2,  maxB1[L_SCAN], maxB1_trk_scan);
        maxB1_scan = maxB1[L_SCAN];
        maxB1Seq = FMax (2, maxB1Seq, maxB1Seq_trk);
        maxB1Seq_scan = maxB1Seq;
    }

    /* Begin RTIA */
    /* We have 3 separate sequences which are mutually compatible to 
       each other. So, there are 8 combinations in realtime. For all 
       these combinations, we need to calculate gradient and RF safe 
       times when they are played with the base fgre sequence */

    /* Run through the gradient and RF safety routines multiple times, 
       each time taking a different set of pulses, corresponding to the 
       sequence combination under consideration. The minimum safe sequence
       time possible in each case will be obtained, and will be stored in  
       an array of structures for later use. */

    /* The last pass will give values for the base fgre sequence */
    if (feature_flag & RTIA98) { 
        active_sequences = ACTIVATE_SPSAT + ACTIVATE_CHEMSAT + ACTIVATE_IR;
    } else {
        active_sequences = 0;
    }

    /* The active_sequences = 0 case gives the params for the 
       non-realtime fgre sequence depending on all the options 
       selected. For non-realtime mode, the rf and grad lists 
       are set up correctly for the options selected. So we'll get 
       the right times if we do this loop once for non realtime*/
    for ( index = active_sequences ; index >= 0 ; index-- ) {

        RTIA_get_tmin( index, &tmin, tmin_satoff, 
                       cs_sattime, sp_sattime, hard180_time, 
                       feature_flag );

        RTIA_modify_pulselists( feature_flag, index, gradx_list, 
                                grady_list, gradz_list, rfpulse_list, 0 );
        /* The hard180 pulse has been added to the list. But we should 
           understand that this pulse gets played only once in every pass.
           Or, for purposes of SAR, and RF energy related calculations, 
           we could consider that the RF pulse is evenly distributed 
           across all rhnframes. So, we should scale the num field of 
           the HARD180 slot with 1/rhnframes. But this field is an integer. 
           A similar effect can be achieved by dividing the actual flip angle 
           by rhnframes, as it reduces the b1 of the pulse calculated by 
           the sar routines. Reset the pulse width after all calculations
           are done.*/
        if ( index & ACTIVATE_IR ) { 
            RTIA_scale_hard180B1( rfpulse_list, (float)rhnframes );
        } 

        /* Perform grad safety checks for main sequence (idx_seqcore) */
        seqEntryIndex = idx_seqcore;
        if ( FAILURE == minseq( &min_seqgrad,
                                gradx_list, GX_FREE,
                                grady_list, GY_FREE,
                                gradz_list, GZ_FREE,
                                &loggrd, seqEntryIndex, tsamp, tmin,
                                use_ermes, seg_debug ) ) 
        {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "minseq" );
            return FAILURE;
        }
        
        /* Under voltage prediction for SSSD */
        if(5550 == cfgradamp && vol_ratio_est_req < 1.0)
        {
            epic_error(use_ermes,
                       "Too much Gradient Power is required.",
                       EM_PSD_GRADPOWER_FOV_BW_PHASE, EE_ARGS(0));
            return FAILURE;
        }

        /* SVBranch HCSDM00115164 */
        if(sbm_flag)
        {
            /* HCSDM00115164: calculate min_seqgrad when turn off X and Y gradient pulses */
            sbm_gx1_scale   = 0.0;
            sbm_gxw_scale   = 0.0;
            sbm_gxwex_scale = 0.0;
            sbm_gy1_scale   = 0.0;
            sbm_gy1r_scale  = 0.0;

            if(sbm_gx_cool)
            {
                if ( FAILURE == minseq( &sbm_seqgrad_xy,
                                        gradx_list, GX_FREE,
                                        grady_list, GY_FREE,
                                        gradz_list, GZ_FREE,
                                        &loggrd, seqEntryIndex, tsamp, tmin,
                                        use_ermes, seg_debug ) )
                {
                    epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                                EE_ARGS(1), STRING_ARG, "minseq" );
                    return FAILURE;
                }
            }
            else
            {
                sbm_seqgrad_xy = min_seqgrad;
            }

            /* HCSDM00115164: calculate min_seqgrad when turn off Y gradient pulses */
            sbm_gx1_scale   = 1.0;
            sbm_gxw_scale   = 1.0;
            sbm_gxwex_scale = 1.0;
            if ( FAILURE == minseq( &sbm_seqgrad_y,
                                    gradx_list, GX_FREE,
                                    grady_list, GY_FREE,
                                    gradz_list, GZ_FREE,
                                    &loggrd, seqEntryIndex, tsamp, tmin,
                                    use_ermes, seg_debug ) )
            {
                epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                            EE_ARGS(1), STRING_ARG, "minseq" );
                return FAILURE;
            }

            /* HCSDM00115164: turn on X and Y gradient pulses */
            sbm_gy1_scale   = 1.0;
            sbm_gy1r_scale  = 1.0;
        }

        extra_minseqgrad = 0;

        if ((PSD_ON == gradHeatMethod) && ((feature_flag & MPL) || (feature_flag & FGRE) || (feature_flag & TOUCH)) && (opsat))
        {
            float avesat_per_slq_scale;

            if (1==slquant1)
            {   /* min_seqgrad only counts the heating from FGRE gradients except SV. This will less 
                 * estimate the gradient heating especially in the case of 1Sat+1FGRE. Therefore, we 
                 * will set extra_minseqgrad to cs_sattime/sp_sattime. This may over estimate the 
                 * gradient heating. Once we have a good solution to count both the SAT and FGRE heating,
                 * this if condition should be removed and the logical in the following else should be 
                 * used. */
                avesat_per_slq_scale = 1.0;
            } else {
                avesat_per_slq_scale = 1.0-1.0/(float)(IMin(2, slq_per_sat, slquant1));
            }

            if (opfat || opwater)
            {
                extra_minseqgrad = (INT)(cs_sattime*avesat_per_slq_scale);
            }
            if (opsatx || opsaty || opsatz || opexsatmask)
            {
                extra_minseqgrad = (INT)(sp_sattime*avesat_per_slq_scale);
            }
        }
        
        if (debug_dbdt)
        {
            printf("pos4: minseq=%d, tmin=%d, pidbdtper=%f\n min_seqgrad=%d ", minseqcoil_t, tmin, pidbdtper, min_seqgrad);
        }

        /* ENH - 13/Aug/1997 - GFN */
        /* Restore flow encoding gradient amplitudes */
        if (fastcardPC_resetscale(feature_flag, &a_gx1, &a_gxfc, &a_gz1,
                                  &a_gzfc) == FAILURE) {
            epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "fastcardPC_resetscale");
            return FAILURE;
        }

        /* RF amp, SAR, and system limitations on seq time */

        /* ****************************************************** */
        /* insert procedure calls here to reduce effect of prep
           pulses on RF amp, SAR limitations */
        ChemSat_FC_setpulsenum(rfpulse_list, tmin_satoff, &tmin, feature_flag);

        /* Tagging - 13/Feb/1998 - GFN */
        if ( FAILURE == tagging_setpulsenum( rfpulse_list, feature_flag ) ) {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "tagging_setpulsenum" );
            return FAILURE;
        }

        /* ******************************************************* */

        if ( minseqrfamp( &min_seqrfamp, RF_FREE, rfpulse_list, 
                          L_SCAN ) == FAILURE) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "minseqrfamp" );
            return FAILURE;
        }

        if ( maxseqslicesar( &max_seqsar, &max_slicesar, (INT)RF_FREE, rfpulse_list,
                             L_SCAN ) == FAILURE ) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "maxseqslicesar" );
            return FAILURE;  
        }

        if ( mpl_rfscale( feature_flag, &min_seqrfamp,
                          &max_slicesar, &max_seqsar,
                          cs_sattime, sp_sattime,
                          RF_FREE, rfpulse_list ) == FAILURE ) {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "mpl_rfscale" );
            return FAILURE;
        }

        /* MRIge91684 */
@inline RFb1opt+.e RFb1opteval

        /* Calculate minimum sequence time based on Gradient, RF, SAR and playout */
        tmin_total = IMax( 4,
                           /* SVBranch HCSDM00115164 */
                           ((sbm_flag) ? 0 : (min_seqgrad + extra_minseqgrad)),
                           min_seqrfamp,
                           max_seqsar,
                           tmin );

        if((feature_flag & FIESTA) && ((PSD_HRMW_COIL == cfgcoiltype) || isSigna7T()))
        {
            tmin_total = limitByAcousticResonanceBands(tmin_total);
            if(tmin_total == 0)
            {
                return FAILURE;
            }
        }

        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqcoil_t = %d\n", minseqcoil_t );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqgrddrv_t = %d\n", minseqgrddrv_t );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "minseqgpm_t = %d\n", minseqgpm_t );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "min_seqrfamp = %d\n", min_seqrfamp );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "max_seqsar = %d\n", max_seqsar );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "tmin = %d\n", tmin );
        printDebug( DBLEVEL1, (dbLevel_t)seg_debug, funcName, "tmin_total = %d\n", tmin_total );
        
        tmin_fgre_limits =  IMax( 3, 
                                   /* SVBranch HCSDM00115164 */
                                   ((sbm_flag) ? 0 : (min_seqgrad + extra_minseqgrad)),
                                   min_seqrfamp,
                                   max_seqsar);
        
        if (((feature_flag & MPL) || (feature_flag & FGRE) || (feature_flag & TOUCH)) && (opsat))
        {
            if (opfat || opwater)
            {
                tmin_fgre_limits -= cs_sattime;
            }
            if (opsatx || opsaty || opsatz || opexsatmask)
            {
                tmin_fgre_limits -= sp_sattime;
            }
        }

        if( existcv(opautotr) && (PSD_ON == exist(opautotr)) ) { 
            sar_time = tmin_total;
        } else { 
            sar_time = (exist(optr));
        }

        if( FAILURE == RTIA_calc_powermon_values( L_SCAN, RF_FREE,
                                                  rfpulse_list, 
                                                  sar_time,
                                                  &rtia_pwrmon_values[index] ) ) {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "RTIA_calc_powermon_values" );
            return FAILURE;
        }
        /* MRIhc20930 - VSN */
        /* Store the values now - RTIA*/
        safe_times[index].tmin           = tmin;
        safe_times[index].tmin_total     = tmin_total;
        safe_times[index].min_seqrfamp   = min_seqrfamp;
        safe_times[index].minseqgrddrv_t = minseqgrddrv_t;
        safe_times[index].minseqcoil_t   = minseqcoil_t;
        safe_times[index].minseqcable_t  = minseqcable_t;
        safe_times[index].minseqbusbar_t = minseqbusbar_t;
        safe_times[index].minseqgpm_t    = minseqgpm_t;
        safe_times[index].min_seqgrad    = min_seqgrad;
        safe_times[index].max_seqsar     = max_seqsar;
        safe_times[index].max_slicesar   = max_slicesar;
       
        /* Reset the flip angle  of the hard180 pulse */ 
        if ( index & ACTIVATE_IR ) { 
            RTIA_scale_hard180B1( rfpulse_list, (float) (1.0 / (float) rhnframes )) ; 
        } 

        
        /* After every pass through the Loop, we need to reset the 
           numbers and activity so that every pass is independant of 
           the previous. Also ..
           We should set the Pulse fields to the case where we have 
           every feature turned on, to get the right powermon values.
           Let's do that here . */
        RTIA_modify_pulselists( feature_flag,
                                (ACTIVATE_CHEMSAT + ACTIVATE_SPSAT +
                                 ACTIVATE_IR) , 
                                gradx_list, 
                                grady_list, 
                                gradz_list, 
                                rfpulse_list, 
                                0 );

    }   /* end for index */
   
    /* MRIge75651 */ /* MRIhc20930 - VSN */
    if ( FAILURE == RTIA_select_safe_params( &tmin,
                                             &tmin_total,
                                             &min_seqrfamp, 
                                             &minseqgrddrv_t,
                                             &minseqcoil_t,
                                             &minseqcable_t,
                                             &minseqbusbar_t,
                                             &minseqgpm_t,
                                             &min_seqgrad,
                                             &max_seqsar,
                                             &max_slicesar,
                                             &rtia_pwrmon_avesar,
                                             &rtia_pwrmon_cavesar,
                                             &rtia_pwrmon_peaksar,
                                             rtia_pwrmon_values,
                                             safe_times,
                                             feature_flag ) ) {
        epic_error ( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                     EE_ARGS(1), STRING_ARG, "RTIA_select_safe_params" );
        return FAILURE;
    }
    ave_sar = rtia_pwrmon_avesar;
    cave_sar = rtia_pwrmon_cavesar;
    peak_sar  = rtia_pwrmon_peaksar;

    /* MRIhc20930 */
    if (feature_flag & RTIA98) {

        if( (opautotr) == PSD_ON) {        
            psd_tol_value = (safe_times[active_sequences].min_seqgrad - min_seqgrad );
        }
        else {
            psd_tol_value = 0;
        }
    }
    else {

        psd_tol_value = 0;
    }

    /* Begin RTIA move */
    /* RTIA moves RF scaling/setscale to the top of the loop */
    /* to calculate the right sar limited slice and seqtimes. */
    /* for each of the sequence combinations. */ 
    /* End RTIA move */

    /* Used for cardiac intersequence time.  Round up to integer
       number of ms but report to scan in us. */
    avmintseq   = tmin_total;
    avmintseq  *= 10;   /* roundup to 1/10 of ms */
    advroundup(&avmintseq);
    avmintseq  /= 10;
    avmaxphases = 1;
    avminphases = 1;

    other_slice_limit = IMin(2, max_slicesar, max_bamslice);
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
    {
        other_slice_limit = IMin(2, other_slice_limit, avmax_asset_slquant);
    }

    /* Begin RTIA move*/
    /* RTIA moves maxseqsar to above to put it in loop for various 
       sequences. */
    /* End RTIA move */ 

    /*
     * now calculate avmintr
     */
    avround = 0;   /* do not roundup in mintr call */
    /* set slquant_per_trig as 1 because we want the true min. TR */
    if ( mintr( &avmintr, seq_type, tmin_total, 
                /* slquant_per_trig */ 1, gating ) == FAILURE ) {
        /* catch errors in cvcheck() with avmintr */
    }

    avround = 1;   /* restore avround for subsequent calls  */
  
    avmintr = IMax(2, avmintr, tmin_total);

    if(PSD_ON == mpl_discard_flag)
    {
        int tmintot_4slice = 4 * IMax(2, tmin_fgre_limits, tmin_satoff);
        int sattime_4slice = (sp_sattime + cs_sattime) * (int)ceilf(4.0 / (float)slq_per_sat);
        avmintr = IMax(2, avmintr, tmintot_4slice + sattime_4slice);
    }

    /* Round avmintr only if advisory checks are active */ /* YMSmr08034  11/15/2005 YI */
    if(((existcv(opautotr) && (PSD_OFF == exist(opautotr))) || (value_system_flag && !(feature_flag & FIESTA))) &&
       (!(vstrte_flag && isStarterSystem()))) 
    {
        /* Multiply by 10 so avroundup will round to 10th of ms */
        avmintr *= 10;
        advroundup(&avmintr);
        /* Divide by 10 to restore avmintr to ms */
        avmintr /= 10;
    }

    if (feature_flag & MERGE)
    {
        avmintr = IMax(2, 300ms, avmintr);  /* limit minTR to 300 ms for MERGE */
    }

    if (((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)))
    {
        avmintr = IMax(2, 150ms, avmintr);  /* limit minTR to 150 ms for Cal */
    }

    /*
     * now calculate act_tr
     */
    {
        t_slq_per_tr_type slq_per_tr_type;

        setoptr( &tr_time, &avail_image_time, &slq_per_tr_type,
                 avmintr, feature_flag );
        single_slice_flag = (SINGLE_SLICE_PER_TR == slq_per_tr_type);
    }
    
    /* Calculate avail_image_time for cardiac applications as it may be used in prep_setacqparams() */
    fastcard_cal_avail_image_time(&avail_image_time, feature_flag);

    optr_overrided = FALSE;
    mpl_auto_mintr(tmin_fgre_limits, cs_sattime, sp_sattime, tmin_satoff, 
                   other_slice_limit, gating, &avail_image_time, &tr_time,
		   &optr_overrided, feature_flag, rfb1opt_flag); 

    /*MRIge91882*/
    if((((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC))&&(exist(opplane)==PSD_3PLANE)&&
        !(feature_flag&IRPREP)) && !(feature_flag & FIESTA))
    {
        tr_time = avmintr;
        act_tr = avmintr;
        avmaxtr = avmintr;
    }

    /* If the symmetric TE option (research mode) has been selected for
       FIESTA 2D, re-calculate tr_time to accomodate the request.  This
       will be used to re-calculate act_te.  Note that act_te was
       already calculated as part of the dB/dt optimization using the
       calcOptimizedPulses() function, which gets called before
       cveval1().  The optimization code calls the setPulseParams()
       function, which finally calls the set_rdout_params_te_and_tmin()
       function that calculates act_te. */
    if( (feature_flag & FIESTA) && (symmetric_te) ) {
        int fiesta_tr = 0;

        fiesta_tr = IMax(3, 2 * te_time, 2 * non_tetime, (tr_time - 5us));
        /* Multiply by 10 so avroundup will round to 10th of ms */
        fiesta_tr *= 10;
        advroundup(&fiesta_tr);
        /* Divide by 10 to restore avmintr to ms */
        fiesta_tr /= 10;

        tr_time = RUP_GRD(fiesta_tr);
        act_te = RUP_GRD(tr_time / 2);
    }

    act_tr = tr_time;

    if ( PSD_OFF != exist(opcgate) ) 
    {
        effectiveAcqTime = opvps * act_tr;
        pitresnub = 1; /* display pitres on UI */
        if ( PSD_PC == exist(oppseq) )
        {
            pitres = effectiveAcqTime * (2+2*(exist(opflaxall)));
        }
        else
        {
            pitres = effectiveAcqTime;
        }
    }
    else if ( (PSD_ON==exist(opmph)) && 
              (PSD_OFF==exist(opET)) &&
              (1==exist(opnecho)) && 
              ( (feature_flag & FIESTA) || (PSD_SPGR == exist(oppseq)) ) )
        /* ungated multi-phase FIESTA/SPGR */
    {
        effectiveAcqTime = (rhnframes + temp_rhhnover) * act_tr;
        pitresnub = 1; /* display pitres on UI */
        pitres = effectiveAcqTime;
    }
    else
    {
        pitresnub = 0;
    }

    if (touch_flag)
    {
       /* SVBranch HCSDM00126289 */
       if( !isSVSystem() ) 
       {
           avmintr = IMax(3, act_tr, touch_tr_time, avmintr);
           if (touch_tr_time < avmintr)
           {
               touch_tr_time = (int)ceil((float)avmintr/(float)touch_period) * touch_period;
               act_tr = touch_tr_time;
               avmintr = touch_tr_time;
               touch_burst_count = act_tr/touch_period;
               if(!isSVSystem())
               {
                   cvoverride(optouchcyc, touch_burst_count, PSD_FIX_ON, PSD_EXIST_ON);
               } 
               epic_error(use_ermes,
                   "Please increase Driver Cycle per Trigger to %d.",
                   EM_PSD_TOUCH_CYCLE, 1, INT_ARG, touch_burst_count);
               return FAILURE;
           }
           else
           {
               act_tr = avmintr;
           }
       }
       else
       {
           /* In clinical mode, the user has no access to optouchcyc, thus update TR according the smallest TR needed */  
           avmintr = IMax(2, act_tr, avmintr); 
           touch_tr_time = (int)ceil((float)avmintr/(float)touch_period) * touch_period;
           act_tr = touch_tr_time;
           avmintr = touch_tr_time;
           touch_burst_count = act_tr/touch_period;
           cvoverride(optouchcyc, touch_burst_count, PSD_FIX_ON, PSD_EXIST_ON);
        } 

        cvoverride(optr, avmintr, PSD_FIX_ON, PSD_EXIST_ON);
    }

    /*Wireless gating ECG TR lockout*/
    if ( (PSD_ON == exist(opcgate)) && (1 == exist(opcgatetype)) 
         && (cfpactype == PSD_PAC_WIRELESS) )
    {
        wg_trlockout_flag = PSD_ON;
    }
    else
    {
        wg_trlockout_flag = PSD_OFF;
    }

    if (PSD_ON == wg_trlockout_flag)
    {
        act_tr = limitByWirelessGatingBands(act_tr);
    }

    /* YMSmr07278, YMSmr07017  08/03/2005 YI */
    /*HCSDM00535489: Fiesta-TC download fail. Don't use more dda when fiesta-TC to avoid a very long TI*/
    if( isSVSystem() && (exist(opspecir) == PSD_OFF) && (feature_flag & FIESTA) && (!perfusion_flag)  ) {
        dda = IMax(2, 32,(int)(500000.0/(1.0*optr)) - rhnframes / 2);
    }
    
    /* FIESTA-C  YMSmr06786  05/26/2005 YI */
    if(pcfiesta_flag)
    {
        ps2_dda =  (int) (1000000.0/(1.0*optr));
        dda = IMax(2, 40, ps2_dda*2 - rhnframes / 2);
    }
    else if(feature_flag & FIESTA)
    {
        ps2_dda = 64;
    }

    /* MRIge90793 */
    if( FAILURE == fiesta2d_sat_cveval( act_tr, dda, fn, &explicit_shot_delay, feature_flag ) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fiesta2d_sat_cveval" );
        return FAILURE;
    }

    /*
     * Slice ordering section
     *
     * We will assume that if the sequential button is
     * selected, then we are not doing an interleaved
     * acquisition.
     */
  
    /* initialize to 1 acq per slice */
    avmaxslquant = 1;

    if ( maxpass( &acqs, seq_type, exist(opslquant), 
                  avmaxslquant ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "maxpass" );
        return FAILURE;
    }

    rhinitpass = 1;   /* Restore to original 4.x */
    
    if ( slicein1( &slquant_per_trig, acqs, seq_type) == FAILURE ) {
        slquant_per_trig = 1;   /* just try to get out of eval to catch
                                   the problem in cvcheck */
    }

    /********************************
     *  Feature based calculations  *
     ********************************/

    if (touch_flag)
    {
        slquant_per_trig = optouchtphases;
        slquant1 = slquant_per_trig;
    }
    
    if ( mpl_setacqparams( tmin_total, tmin_fgre_limits, cs_sattime, sp_sattime,
                           tmin_satoff, other_slice_limit, 
                           &slquant_per_trig, &slquant1, 
                           avail_image_time, &avmaxslquant, &acqs, 
                           feature_flag ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "mpl_setacqparams" );
        return FAILURE;
    }

    if(PSD_ON == mpl_discard_flag)
    {
        avminslquant = 2;
    }

    /* Fixed avmaxslquant for calibration to be avmax_asset_slquant */
    if( ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset))
    || (PSD_ON == pure_ref) ) && (piautotrmode != PSD_AUTO_TR_MODE_MANUAL_TR) ) 
    {
        avmaxslquant = avmax_asset_slquant;
    }

    /* MRIge90793: Set the shot TR */
    if ( fiesta2d_sat_setacqparams( &avminti, &avmaxti, act_tr, cs_sattime,
                                    cs_sat, dda, time_ssi, explicit_shot_delay,
                                    feature_flag ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fiesta2d_sat_setacqparams" );
        return FAILURE;
    }

    if ( slquant_per_trig == 0 ) {
        epic_error( use_ermes, "slquant_per_trig is 0", EM_PSD_SLQUANT_ZERO, 
                    EE_ARGS(0) );
        return FAILURE;
    }
      
    /* let's calculate slquant1 before we use it */
    slquant1 = slquant_per_trig;

    if (acqs > MAX_PASSES)
    {
        epic_error(use_ermes,
                   "Maximum of %d acqs exceeded.  Increase locations/acq or decrease number of slices.",
                   EM_PSD_MAX_ACQS, 1, INT_ARG, MAX_PASSES);
        return FAILURE;
    }
    if (slquant1 > MAX_SLICES_PER_PASS)
    {
        epic_error(use_ermes,
                   "The no. of locations/acquisition cannot exceed the max no. of per acq = %d.",
                   EM_PSD_LOC_PER_ACQS_EXCEEDED_MAX_SL_PER_ACQ, 1, INT_ARG, MAX_SLICES_PER_PASS);
        return FAILURE;
    }

    /*********************************
     *  Locations/Acqs before pause  *
     *********************************/
    /* Display scan clock in seconds unless pause */

    /* MRIge35337 */
    if ( exist(opslicecnt)==0 ) {
        pidmode = PSD_CLOCK_NORM;
    } else {
        pidmode = PSD_CLOCK_PAUSE;
    }

    /* Fast CINE - 29/Jan/1998 - GFN */
    if ( FAILURE == fcine_retrospective_init( &copyit, feature_flag ) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fcine_retrospective_init" );
        return FAILURE;
    }
    
    /* Set Prep advisory values and sequence time */
    /* AMR - FOR BTK - additional argument for phase encode order - phorder
       added */ 

    if (cineir_flag)
    {
        prep_dda = cineir_dda;
    }
    else if ( sshmde_flag || (cardt1map_flag && (PSD_SSFP == oppseq)) )
    {
        prep_dda = number_linear_alpha;
    }
    else
    {
        prep_dda = dda;
    }

    if( SUCCESS != (status = prep_setacqparams( &avminti,
                                                &avmaxti,
                                                &avmintdel1,
                                                &ir_prep_time,
                                                time_ssi,
                                                act_tr,
                                                prep_dda,
                                                t_exa,
                                                phorder,
                                                avmaxtdel1,
                                                exist(opvps),
                                                feature_flag )) ) {
        return status;
    }

    if ( fastcard_setacqparams( &acqs,
                                &avail_image_time, 
                                &avmaxphases,
                                &avmaxslquant,
                                &avminslquant,
                                &avmaxtdel1,
                                &slquant_per_trig, 
                                &slquant1,
                                &copyit,
                                &pidmode,
                                dda,
                                time_ssi,
                                act_tr, 
                                exist(opvps),
                                exist(opetl),
                                avmintdel1,
                                other_slice_limit,
                                cs_sat,
                                cs_sattime,
                                ir_prep_time,
                                feature_flag,
                                use_ermes ) == FAILURE ) {  
        return FAILURE;
    }

    /* MRIge90769: Why are we re-executing prep_setacqparams?
       Well, avmaxti is set according to avmaxtdel1 to allow the 
       operator greater freedom in prescribing TI; however, 
       initially avmaxtdel1 has not been calculated (this takes 
       place in fastcard_setacqparams()). avmintdel1 is set in 
       prep_setacqparams() based on the prescribed TI.
       fastcard_setacqparams() checks avmintdel1 against the 
       prescribed TDEL, increases TDEL if the prescribed TI does 
       not fit within the prescribed TDEL (this is effectively 
       TI-priority prescription), and calculates avmaxtdel1. 
       prep_setacqparams() is re-run to recalculate avmaxti 
       given avmaxtdel1.
    */

    if( SUCCESS != (status = prep_setacqparams( &avminti,
                                                &avmaxti,
                                                &avmintdel1,
                                                &ir_prep_time,
                                                time_ssi,
                                                act_tr,
                                                prep_dda,
                                                t_exa,
                                                phorder,
                                                avmaxtdel1,
                                                exist(opvps),
                                                feature_flag )) ) {
        return status;
    }

    /* Fast CINE - Set the number of acquired and reconstructed phases
       accordingly - 24/Mar/1998 - GFN */
    if ( FAILURE == fcine_setacqparams( &avmaxphases, feature_flag ) ) {
        return FAILURE;
    }

    if ( FAILURE == fmpvas_setacqparams( &acqs, &avail_image_time,
                                         &avmaxphases, &slquant_per_trig,
                                         &slquant1, &pidmode,
                                         feature_flag, use_ermes ) ) {
        return FAILURE;
    }
  
    /* ALP moved initialization of avmaxacqs here (it was done after
       mpl_setacqparams() call) for MRIge63684 DE feature Fiesta release */
    /* calculate Max #acqs for advisory panel */ 
    avmaxacqs = acqs;

    /* Echotrain overrides avmaxacqs */
    if ( FAILURE == et_setacqparams( &acqs, &slquant_per_trig, &slquant1,
                                     &avmaxacqs, &avmaxslquant, max_bamslice,
                                     feature_flag, use_ermes ) ) {
        return FAILURE;
    }
 
    /* MRIge35337 */
    if ( exist(opslicecnt)==0 ) {
        slicecnt = acqs;
    } else {
        slicecnt = exist(opslicecnt);
    }

    /************************
     *  Exorcist CVs - LX2  *
     ************************/
    if (cmon_flag == PSD_ON) {
        if (exorcist_cveval() == FAILURE) {
            return FAILURE;
        }
    }

    /* set ddisdacq views only if we're not doing multi phase */
    if ((touch_flag) || (feature_flag & MPH) || (cmon_flag != 1)) {
        ss_view = 0;
    } else {
        ss_view = 32;
    }


    /* RTIA doesn't employ relaxer sequence */
    if ( ((opsatx) || (opsaty) || (opsatz)) &&
         (!(feature_flag & RTIA98)) ) { 
	/* 
	 * MRIhc03524: Don't need to play ccsrelaxers after pause. 
	 * Changed 1st parameter of SatCatRelaxtime() call from "acqs"
	 */
        true_acqs = acqs+1 - ceil( (FLOAT)acqs/(FLOAT)slicecnt );
        ccsrelaxtime = SatCatRelaxtime( true_acqs, (act_tr/slquant1), 
                                        seq_type, &SatRelaxers );
    }

  
    /****************
     *  Scan Clock  *
     ****************/
    /* Changed opexor for cmon_flag - LX2 */
    /* made passtime conditional on fast_pass - 84 */
    /* YMSmr07539  08/15/2005 YI */
    if( fast_pass == PSD_OFF ) {
        passtime = (acqs * TR_PASS +
                    (acqs - 1) * TR_PASS * ((cmon_flag == PSD_ON) ? 1 : 0) +
                    (acqs - 1) * sldeltime * ((exist(opslicecnt) == 0) ? 1 : 0) );
    } else {
        passtime = 0;
    }

    /*for MRgFUS tracking, we use fus_scan_dda*/
    if(PSD_ON == track_flag)
    {
        nreps = acqs * ((fus_scan_dda + baseline) +
                            (INT)((truenex + (FLOAT)dex) *
                                  (FLOAT)(rhnframes + temp_rhhnover))/(exist(opetl)));
    }
    else
    {
        nreps = acqs * ((dda + baseline) +
                        (INT)((truenex + (FLOAT)dex) * 
                              (FLOAT)(rhnframes + temp_rhhnover))/(exist(opetl)));
    }

    /* FIESTA-C  YMSmr06786  05/26/2005 YI */
    if(pcfiesta_flag) {
        nreps = acqs * ((dda*(truenex + dex) + baseline) +
                    (INT)((truenex + (FLOAT)dex) * 
                          (FLOAT)(rhnframes + temp_rhhnover))/(exist(opetl)));
    }

    /*MRIge91882*/ 
    if(((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC)||(oppseq==PSD_SSFP))&&(exist(opplane)==PSD_3PLANE)){ 
        nreps = (2*threeplane_dda)+ (acqs * ((dda +baseline) +
                                             (INT)((truenex + (FLOAT)dex) *
                                                   (FLOAT)(rhnframes + temp_rhhnover))/(exist(opetl))));
    }		    
 
    /**  other initialized times **/
    num_times     = (FLOAT)acqs;
    extra_time    = 0.0;
    extra_Acqtime = 0.0;
    extra_delay   = 0.0;
    use_tr        = (FLOAT)act_tr;

    /* RTIA, RJF */
    if( FAILURE == set_RTIA_times( &use_tr, &act_tr_fc, &act_te_fc,&IRdda,
                                   mintr_flowcomp, minte_flowcomp,
                                   act_tr, hard180_time, feature_flag ) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "RTIA_set_times" );
        return FAILURE;                   
    }

    /* Update avmintr for RTIA, if necessary */
    RTIA_set_avmintr( &avmintr, &avail_image_time, mintr_flowcomp, feature_flag );
    /* End, RTIA */

    /* FIESTA2D */
    set_fiesta2d_times( &extra_Acqtime, tmin_total, use_tr, nreps,
                        num_times, feature_flag );

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* calculate additional heating for imaging sequence */
    /* With SBM, X or/and Y gradient pulses are turn off */
    /* during preparation (such as dda, ramp up/down etc)*/
    if( sbm_flag && (PSD_OFF == get_cvs_changed_flag()) )
    {
        sbm_time_ssi = time_ssi;
        if(((feature_flag & FGRE) || (feature_flag & MPH)) && (feature_flag & FIESTA))
        {
            int tmp_minseqgrad = 0;
            int tmp_minseqgrad_dda = 0;

            if(sbm_gx_cool)
            {
                tmp_minseqgrad = sbm_seqgrad_xy;
                if(sbm_dda_cool)
                {
                    tmp_minseqgrad_dda = sbm_seqgrad_xy;
                }
                else
                {
                    tmp_minseqgrad_dda = min_seqgrad;
                }
            }
            else
            {
                tmp_minseqgrad = sbm_seqgrad_y;
            }

            if(feature_flag & SPECIR)
            {
                sbm_waiting_time = (min_seqgrad - tmin_total) * viewspershot;
                sbm_waiting_time -= ((number_linear_alpha + number_linear_down) * (tmin_total - tmp_minseqgrad));
                sbm_waiting_time -= (dda * (tmin_total - tmp_minseqgrad_dda));
            }
            else
            {
                sbm_waiting_time = (min_seqgrad - tmin_total) * (nreps/acqs - dda) * ((feature_flag & MPH) ? opfphases : 1);
                sbm_waiting_time -= (number_linear_alpha * (tmin_total - tmp_minseqgrad));
                sbm_waiting_time -= (dda * (tmin_total - tmp_minseqgrad_dda));
            }
        }
        else
        {
            sbm_waiting_time = 0;
        }
        if(sbm_waiting_time <= 0)
        {
            sbm_waiting_time = 0;
        }

        /* SVBranch HCSDM00115164: support SBM for FIESTA */
        /* Calculate available amount of TRs for */
        /* MPS2                                  */
        sbm_mps2_num = (int)((float)(sbm_time_limit * 1000000.0) / IMax(2,1,(sbm_seqgrad_y - tmin_total)));

        if((sbm_waiting_time > (sbm_time_limit*1000000)) || sbm_mps2_num < SBM_MIN_MPS2_NUM)
        {
            epic_error( use_ermes, "%s is incompatible with %s.",
                        EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                        STRING_ARG, "Smart Burst Mode",
                        STRING_ARG, "current prescription.");
            return FAILURE;
        }

    }

    avmintscan = (use_tr * nreps + passtime + ccsrelaxtime + extra_time +
                  extra_Acqtime + (INT)((FLOAT)acqs * truenex *
                                        (FLOAT)(cs_sattime + sp_sattime)));

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* update avmintscan for FIESTA */
    if(sbm_flag && (feature_flag & FIESTA) && !(feature_flag & SPECIR))
    {
        avmintscan += ( ((sbm_waiting_time-TR_PASS)>0 ? IMax(2,sbm_min_period+sbm_time_ssi,sbm_waiting_time-TR_PASS) : 0)*acqs );
    }

    pitslice = avmintscan / acqs;


    /* 
     * MRIhc04613: For multi-acqs MPL scans with SpSat, make sure clock time is set correctly.
     */
    if ( set_mpl_times( use_tr, nreps, passtime, ccsrelaxtime, 
                        extra_time, acqs, truenex, 
                        sp_sattime, &avmintscan, 
                        &pitslice, &num_times, feature_flag ) == FAILURE) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_mpl_times");

        return FAILURE;
    }

    if ( set_mph_times( &extra_time, &num_times, &nreps, 
                        &avmintscan, &pitslice, act_tr, 
                        sldeltime, number_linear_alpha, dda, dex, feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.",EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_mph_times");
        return FAILURE;
    }

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* update avmintscan for FIESTA & MPH */
    if(sbm_flag && (feature_flag & FIESTA) && (feature_flag & MPH) && !(feature_flag & SPECIR))
    {
        avmintscan += ((((sbm_waiting_time-TR_PASS) > 0) ? IMax(2, sbm_min_period+sbm_time_ssi, sbm_waiting_time-TR_PASS) : 0)*acqs);
    }

    if ( set_prep_times( &extra_time, &num_times, &nreps, &avmintscan,
                         &pitslice, &extra_delay, act_tr, dda, dex,
                         intsldelay, exist(opetl), feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_prep_times");
        return FAILURE;
    }
   
    if ( set_echotrain_times( &pitslice, opslquant, 
                              act_tr, &nreps, dda, dex, baseline,
                              passtime, ccsrelaxtime, 
                              extra_time, acqs, truenex, 
                              (cs_sattime + sp_sattime), ir_prep_time, 
                              exist(opetl), &avmintscan, 
                              feature_flag) == FAILURE) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_Echotrain_times");
        return FAILURE;
    }

    if ( set_fastcard_times( &extra_time, &num_times, &avmintscan,
                             &pitslice, &extra_Acqtime, &piviews, dex,
                             exist(opvps), feature_flag ) == FAILURE ) {
        epic_error(use_ermes,"%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_fastcard_times");
        return FAILURE;
    }

    if ( set_respgate_times( &avmintscan, pitslice ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "respgate_time");
        return FAILURE;
    }

    if ( set_fmpvas_times( &extra_time, &num_times, act_tr, 
                           &avmintscan, &pitslice, nframes,
                           (INT)7 /* nframe entries */, truenex, dex,
                           opvps, &piviews, passtime, &extra_Acqtime,
                           ir_prep_time, feature_flag ) == FAILURE ) {

        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "set_fmpvas_times");
        return FAILURE;
    }

    if (((feature_flag & MFGRE) || r2_flag) && (opcgate == PSD_OFF)) 
    {
        if(exist(opccsat) == PSD_OFF)
        {
            avmintscan *= intte_flag; /* # of echo trains */
        }
        else 
        {
            avmintscan = (avmintscan - ccsrelaxtime) * intte_flag + ccsrelaxtime; 
            /* MRIhc39805 - ccsrelaxtime is played between acqs and this should not be multipled by intte_flag for avmintscan calculation.*/
        }   
    }

    if ( touch_flag ) 
    {
        nreps = (acqs * slquant1 * ((dda + baseline) + rhoscans + 
                 touch_ndir * (INT)((truenex + (FLOAT)dex) * (FLOAT)(rhnframes + temp_rhhnover))));
        avmintscan = ((FLOAT)act_tr * (FLOAT)nreps +
                      (FLOAT)acqs * (FLOAT)TR_PASS +
                      (FLOAT)(acqs-1) * (FLOAT)sldeltime * ((opslicecnt == 0) ? 1 : 0));
        pitslice = act_tr * (nreps/acqs) + TR_PASS;
    }

    /* MRIge90793:  Set total scan time for 2D FIESTA Fat SAT */
    /* MRIge92364: fix scan clock error for fsfiesta with MPH */
    if (PSD_ON == debug_fsfiesta) {
        printf("slquant_per_trig is %d, acqs is %d, truenex is %f, passtime is%d, feature_flag is %d\n", slquant_per_trig, acqs, truenex, passtime, feature_flag); 
        printf("in set_fiesta2d_sat_times\n");
    }

    /* SVBranch HCSDM00115164 */
    if( (status =  set_fiesta2d_sat_times( &avmintscan, slquant_per_trig, acqs, truenex, nex, passtime, feature_flag)) != SUCCESS )
    {
        return status;
    }

    /* MRIge91361 add coil switch waiting time to total scan time for 
     * PURE or ASSET calibration scans
     * In case of Pure, there might be cases where setrcvportimm is 
     * not really needed as the recieve coil port is the same. For those
     * cases we might be causing an extra 100 ms delay which is not 
     * very significant in this case. */
    if (PSD_ON == pure_ref ) {
        avmintscan = avmintscan*pass_reps + CoilSwitchGetTR(run_setrcvportimm);
    }
    else if (PSD_ON == swift_cal) {
        avmintscan = avmintscan*pass_reps + CoilSwitchGetTR(0);
    }

    pitslice = avmintscan / acqs;

    if(perfusion_flag)
    {
        /* HCSDM00483567 */
        avmintscan= (float)(coredda+opfphases*nex)*(60.0s/ophrate)*(ophrep);
        piviews=opfphases*nex+coredda;
        pitslice = avmintscan / opfphases;
    } else {    
        pitslice = avmintscan / acqs;
    }

    /* algorithm for calculating MENC for MR Touch*/
    if ( touch_flag ) 
    {
        float sc_fact, gamma, N, F, G, T, delta_rt, tmp1, tmp2;
        int m_max, ms;
        int fc;


        sc_fact = 0; /* MEG sensitivity (rad/um) */
        gamma = GAM * 2 * PI; /* gyromagnetic ratio (rad/(s*G)) */
	N = touch_gnum; /* number of gradient pairs in single MEG train */
	F = touch_act_freq; /* MEG frequency (Hz) */
	G = touch_gamp; /* MEG amplitude (G/cm) */
	T = touch_period * (1e-6); /* period of MEG train (s) */
	fc = touch_fcomp; /* flow-compensation type (0=none, 1=type-1 (long MEG), 2=type-2 (short MEG)) */
	delta_rt = touch_pwramp * (1e-6); /* rise time from 0 to G (sec) */
	if( fc == 2 )
	{
	    delta_rt = delta_rt / 2.0; /* need rise time of FC lobes for calculations involving this flow comp'ed MEG */
	}

	if( fc == 0 )
	{ /* MEG is not flow compensated */
	    N = 2 * N; /*  N is the # of half gradient lobes in this expression since single MEG lobes are supported now */
	    sc_fact = (1e-4) * gamma * N * T * T * G * sin(2.0 * PI * delta_rt / T) / (2 * PI * PI * delta_rt);
	}
	else if( fc == 1 )
	{ /*  type-1 flow compensation */
	    sc_fact = (1e-4) * gamma * N * T * T * G * sin(2.0 * PI * delta_rt / T) / (PI * PI * delta_rt);
	}
	else if( fc == 2 )
	{ /* type-2 flow compensation */
	    m_max = 31;
	    tmp1 = 0;
	    for( ms = -m_max; ms <= m_max; ms += 2 )
	    {
		tmp1 += (sin(PI * 4.0 * ms * delta_rt * F) / (PI * 4.0 * ms * delta_rt * F)) / (2.0 * PI * ms * (ms / 2.0 - 0.25));
	    }
	    tmp2 = (2.0 * N - 1.0) * sin(PI * 4.0 * delta_rt * F) / (PI * 4.0 * delta_rt * F) + tmp1;
	    sc_fact = (1e-4) * gamma * T * G * tmp2 / PI;
	}

	/* Assuming +/- phase subtraction with equal-amplitude MEGs, the motion sensitivity will be double what we just calculated, so we need an additional factor of 2. */
	sc_fact = sc_fact * 2 ;
	if( sc_fact > 0 )
	{
	    touch_menc = PI / sc_fact; /* MENC definition: touch_menc microns of motion results in PI radians of phase in the phase difference images*/
	}
	else
	{
	    touch_menc = 0;
	}

	pitouchmenc = touch_menc;
	
    }/* end algorithm for calculating MENC for MR Touch*/

    if(2 == rfb1opt_flag)/*HCSDM00095097*/
    {
        if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
        {
            pitslice = avmintscan / (exist(opnex)*(1+pure_ref));
        }
    }
    
    /* algorithm for calculating MENC for MR Touch*/
    if ( touch_flag ) 
    {
        float sc_fact, gamma, N, F, G, T, delta_rt, tmp1, tmp2;
        int m_max, ms;
        int fc;

        sc_fact = 0; /* MEG sensitivity (rad/um) */
        gamma = GAM * 2 * PI; /* gyromagnetic ratio (rad/(s*G)) */
        N = touch_gnum; /* number of gradient pairs in single MEG train */
        F = touch_act_freq; /* MEG frequency (Hz) */
        G = touch_gamp; /* MEG amplitude (G/cm) */
        T = touch_period * (1e-6); /* period of MEG train (s) */
        fc = touch_fcomp; /* flow-compensation type (0=none, 1=type-1 (long MEG), 2=type-2 (short MEG)) */
        delta_rt = touch_pwramp * (1e-6); /* rise time from 0 to G (sec) */
        if( fc == 2 )
        {
            delta_rt = delta_rt / 2.0; /* need rise time of FC lobes for calculations involving this flow comp'ed MEG */
        }

        if( fc == 0 )
        { /* MEG is not flow compensated */
            N = 2 * N; /*  N is the # of half gradient lobes in this expression since single MEG lobes are supported now */
            sc_fact = (1e-4) * gamma * N * T * T * G * sin(2.0 * PI * delta_rt / T) / (2 * PI * PI * delta_rt);
        }
        else if( fc == 1 )
        { /*  type-1 flow compensation */
            sc_fact = (1e-4) * gamma * N * T * T * G * sin(2.0 * PI * delta_rt / T) / (PI * PI * delta_rt);
        }
        else if( fc == 2 )
        { /* type-2 flow compensation */
            m_max = 31;
            tmp1 = 0;
            for( ms = -m_max; ms <= m_max; ms += 2 )
            {
                tmp1 += (sin(PI * 4.0 * ms * delta_rt * F) / (PI * 4.0 * ms * delta_rt * F)) / (2.0 * PI * ms * (ms / 2.0 - 0.25));
            }
            tmp2 = (2.0 * N - 1.0) * sin(PI * 4.0 * delta_rt * F) / (PI * 4.0 * delta_rt * F) + tmp1;
            sc_fact = (1e-4) * gamma * T * G * tmp2 / PI;
        }

        /* Assuming +/- phase subtraction with equal-amplitude MEGs, the motion sensitivity will be double what we just calculated, so we need an additional factor of 2. */
        sc_fact = sc_fact * 2 ;
        if( sc_fact > 0 )
        {
            touch_menc = PI / sc_fact; /* MENC definition: touch_menc microns of motion results in PI radians of phase in the phase difference images*/
        }
        else
        {
            touch_menc = 0;
        }

        pitouchmenc = touch_menc;

    }/* end algorithm for calculating MENC for MR Touch*/

    if (FAILURE == fcine_kt_set_times())
    {
        return FAILURE;
    }

    pitscan  = avmintscan;

    if (PSD_ON == track_flag)
    {
        if((PSD_ON == exist(oprealtime)))
        {
            formulaA = avmintscan - fus_scan_dda*use_tr;
            formulaB = use_tr;
        }
        else
        {
            formulaA = pitslice /opslquant;
            formulaB = use_tr;
        }
    }
    /* Begin RTIA move */
    /* RTIA moves the nex pull down settings before feature cveval_init */
    /* End RTIA move */
    
    pause_button_calc();
    
    /* APx activation */
    if(PSD_ON == apx_option_key_status)
    {
        float temp_tscan = pitscan;
        int anatomy_apx_bh_enable = PSD_OFF;

#ifndef SIM
        anatomy_apx_bh_enable = isApplicationAllowedForAnatomy(opanatomy, ATTRIBUTE_APX_BH);
#else
        anatomy_apx_bh_enable = PSD_ON;
#endif

        if(PSD_ON == exist(opmph))
        {
            temp_tscan = (temp_tscan - passtime) / (float)exist(opfphases);
        }

        if(exist(opslicecnt) > 0)
        {
            temp_tscan = temp_tscan * (float)exist(opslicecnt) / (float)acqs;
        }

        if( (1 == exist(opnumgroups)) && (0 != exist(opcoax)) && (PSD_3PLANE != exist(opplane)) &&
            (PSD_OFF == exist(oprtcgate)) && (PSD_OFF == exist(opnav)) && (PSD_OFF == exist(opcgate)) &&
            (PSD_OFF == exist(oprealtime)) && (strncmp("cal2d", get_psd_name(), 5)) &&
            ( (feature_flag & FIESTA) ||
              ( (feature_flag & MPL) && !(feature_flag & MERGE) &&
                !(feature_flag & ECHOTRAIN) && !(feature_flag & MFGRE) ) ) &&
            (PSD_ON == anatomy_apx_bh_enable) &&
            (APX_T_MIN_BH < temp_tscan + 500ms) && (temp_tscan - 500ms < APX_T_MAX_BH) )
        {
            piapx = PSD_ON;
        }
        else
        {
            piapx = PSD_OFF;
        }

        /* APx preference window setting */
        piapxprfstepnub = 2;
        piapxprfres = PSD_ON;
        piapxprfacc = PSD_ON;
    }
    else
    {
        piapx = PSD_OFF;

        piapxprfstepnub = 0;
        piapxprfres = PSD_OFF;
        piapxprfacc = PSD_OFF;
    }

    return SUCCESS;
}   /* end cveval1() */


/**
 * To optimize the slew-rate based on actual dB/dt, a pulse sequence model is 
 * generated on the host iterating over different slew rates. To achieve
 * this, all pulse sequence timing calculations are done in setPulseParams, which
 * is functionally split into sliceSelect, phaseEncode and Readout related calcs.
 * setPulseParams is used as the PSD interface for dB/dt optimized slew-rate computation
 * as used by calcOptimizedPulses(). 
 * 
 * pulse_params_init() initializes certain general pulse parameters which may be applicable
 * to a variety of pulses in the sequences. 
 * 
 * @see also setPulseParams()
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
static STATUS 
pulse_params_init( void )
{
    if ( use_dbdt_opt == PSD_OFF ) { 
        xrt = loggrd.xrt;
        yrt = loggrd.yrt; 
        zrt = loggrd.zrt; 
    } else { 
        xrt = loggrd.opt.xrt; 
        yrt = loggrd.opt.yrt; 
        zrt = loggrd.opt.zrt; 
    }

    /* set max amplitude of killers to 70% if sr17 mode to reduce min
       seqcoil time and get more slices.  Also, if sr17, dutycycle limit
       is 20% larger for fgre as per 5.4  */

    if (cfsrmode == PSD_SR17) {
        /* sr17 mode */
        zkilltarget=.7 * loggrd.tz_xyz;
        dutycycle_scale = 1.2;
        zrtime = (70*loggrd.zrt)/100;
    } else {
        zkilltarget=loggrd.tz_xyz;
        dutycycle_scale = 1.0;
        zrtime = zrt*loggrd.scale_3axis_risetime;
    }
    
    gxwramp = xrt; 

    if (read_shift == PSD_ON) 
    {
        gxwtarget = loggrd.tx_xy;
        gxwramp = RUP_GRD(ceil(xrt*loggrd.scale_2axis_risetime)); 
        gxwex_2axis_3axis_flag = TWO_AXIS;
    } 
    else 
    {
        gxwtarget = loggrd.tx_xyz;
        gxwramp = RUP_GRD(ceil(xrt*loggrd.scale_3axis_risetime)); 
        gxwex_2axis_3axis_flag = THREE_AXIS;
    }

    if(gradspec_flag)
    {
        gxwtarget = loggrd.tx;
        gxwramp = RUP_GRD(ceil(xrt * derate_gx_factor));
        gxwex_2axis_3axis_flag = ONE_AXIS;
    }

    /*
     * Check out some flags governing what type 
     * of scan we are doing
     */
    /* MRIge38985 */
    if ( (existcv(opfcomp) && exist(opfcomp)) || (feature_flag & FASTCARD_PC) ) {
        flow_comp_type = TYPFC;
    } else {
        flow_comp_type = TYPNFC;
    }

    if (vstrte_flag && !(feature_flag & FIESTA) ) { 
       rewinder_flag = PSD_OFF;
    } else {
       rewinder_flag = PSD_ON;
    }

    return SUCCESS;
}   /* end pulse_params_init() */


static STATUS
fgre_cveval_rfinit( void )
{
    /* moved the code here from set_slice_select_params() to deal 
       with rf pulse initialization  at cveval begining -AKG*/
    /*************
     *  RF1 CVs  *
     *************/

    gscale_rf1 = 1.0;
    /* MRIge53987 - Now that RTIA RF pulse is being used for the
       entire fgre family, minph_rtia_limit cannot be based on the
       hardcoded value of loggrd.tz! */

    /* RTIA doesn't allow any pulse to overlap with the
       Slice select decay. This is to bringdown the minimum
       Slice thickness limit to 4.3 for the RTIA RF pulse.
       at the expense of microseconds in TE. */

    if ( (exist(oprealtime) == PSD_ON) || gradspec_flag) {
        gzrf1target = loggrd.tz;
    } else {
        gzrf1target = loggrd.tz_xyz;
    }
    /* End RTIA */

    minph_rtia_limit = (float)ceil((double)((10.0 * NOM_BW_RTIA/(GAM * gzrf1target))* 10.0) ) / 10.0;
    /* End RTIA */

    /***********************************************
     *  feature dependent setting for minph_limit  *
     ***********************************************/
    /* MRIge66555 - removed hard-coded minph_limit calculation for Fastcard.
       The calculation is done later based on gzrf1target only for 
       ECHOTRAIN use. */
    set_fmpvas_minph_limit( &minph_limit, &overlap, feature_flag );

    /*MRIge92365 add SPECIR to this check*/
    cvunlock( piisvaldef );
    if( (feature_flag & GATEDTOF) ||
        (feature_flag & UNGATEDTOF) ||
        (feature_flag & SPECIR) ) {
        piisvaldef = overlap;
    } else {
        piisvaldef = 0.0;
    }
    cvlock( piisvaldef );

    /* If the overlap has been modified then update value based on
       opslspace */
    if (existcv(opslspace) && (exist(opslspace) < 0.0)) {
        overlap = -exist(opslspace);
        if (PSD_ON == debug_fsfiesta) {
            printf("overlap is %f, opslspace is %f \n", overlap, opslspace);
        }
    }

    /* Should be done outside if-then-else below - MRIge30667 */
    flip_rf1 = psd_flip;

    /* shorter_rf was unlocked only for RTIA before.
       We also had an eval version where shorter_rf_unlocked
       was controlled through userCV2. Now after eval, core team
       suggests that we should keep shorter_rf unlocked even for
       non RTIA scans.  Hence removing all the conditional setting
       of shorter_rf_unlocked here. I'm not removing the conditional
       code based on shorter_rf_unlocked, so that we can
       set it to 0 anytime, and we should go back to the previous
       FGRE RF pulses.  Note that for Echotrain we do not want min
       phase pulse */

    if( feature_flag & ECHOTRAIN ) {
        shorter_rf_unlocked = 0;
    } else {
        shorter_rf_unlocked = 1;
    }
    
    /* For Field Strength < 1.0T MINPH_RF_2DTF26 has to be used
       irrespective of opslthick. MRIge56876 jabbar@mr*/
    /* MRIge84855: If zero is typed in slice thickness field, exist(opslthick) = FGRE_DEFTHICK 
       and opslthick = 0.  In this case, use the rf for thinner slice to calculate the minimum 
       slice thickness. */
    if( shorter_rf_unlocked )
    {
        if (vstrte_flag)
        {
            minph_pulse_flag = 1;
            minph_pulse_index = HARD_RF_24;
            if (feature_flag & FIESTA) {
               cvmax(fiesta_rf_flag, PSD_ON);
               fiesta_rf_flag = PSD_ON;
            }
        }
        else if (perfusion_flag)
        {
            minph_pulse_flag = 1;
            minph_pulse_index = MINPH_RF_TBW2;
        }
        else if ((PSD_ON == spgr_enhance_t1_flag) && (PSD_ON == (int)exist(opuser8)) && (!track_flag))
        {
            minph_pulse_flag = 1;
            minph_pulse_index = LPH_RF_TBW6;
        }
        else if( existcv(opnecho) && (exist(opnecho) == 1) && existcv(opte) && (exist(opte) >= MINTE_T2STAR) && !(feature_flag & RTIA98) 
        && !track_flag && (existcv(oppseq) && ((exist(oppseq) == PSD_GE) || (exist(oppseq) == PSD_SPGR))) && !touch_flag)
        {
            minph_pulse_flag = 1;
            minph_pulse_index = MINPH_RF_SINC1; /* regular 3.2us SINC1 pulse */
        }
        else if(((psd_slthick > minph_rtia_limit) && ( cffield >= B0_10000 ) &&
                 (!(floatsAlmostEqualEpsilons(opslthick, 0.0, 2) && floatsAlmostEqualEpsilons(exist(opslthick), FGRE_DEFTHICK, 2)))) ||
                  (exist(opnecho) >= 2) || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag )
        {
            minph_pulse_flag = 1;

            if (0 == (int)exist(opuser8))
            {
                minph_pulse_index = MINPH_RF_RTIA;
            }
            else
            {
                minph_pulse_index = LPH_RF_TBW6;
            }
        } 
        else if (touch_flag) 
        {
            minph_pulse_flag = 1;
            minph_pulse_index = MINPH_RF_SINC1; /* regular 3.2us SINC1 pulse */
        }
        else 
        {
            minph_pulse_flag = 1;
            minph_pulse_index = MINPH_RF_2DTF26;
        }

        /*Use same pulse for all slice thickness for tracking*/
        if (PSD_ON == track_flag) {
               minph_pulse_flag = 1;
               minph_pulse_index = MINPH_RF_2DTF26;
        }

    } else {
        /* MRIge66555 - ECHOTRAIN uses truncated sinc1 (pw_rf1_full=800us) for
           thick slices */
        minph_limit = (float)ceil( (10.0 *
                                    (4.0 * (double)cyc_rf1 * 1.0s / 800.0) /
                                    ((double)GAM * (double)gzrf1target)) *
                                   10.0 ) / 10.0;

        /* MRIge63408, MRIge63413, MRIge66555 - ECHOTRAIN small slice
           thickness case */ 
        /* MRIge84855: If zero is typed in slice thickness field, exist(opslthick) = FGRE_DEFTHICK 
           and opslthick = 0.  In this case, use the rf for thinner slice to calculate the minimum 
           slice thickness. */
        if( ((psd_slthick < minph_limit) || 
             (floatsAlmostEqualEpsilons(opslthick, 0.0, 2) && floatsAlmostEqualEpsilons(exist(opslthick), FGRE_DEFTHICK, 2))) 
            && (cffield >= B0_10000) ) {
            minph_pulse_flag = 1;
            minph_pulse_index = MINPH_RF_2DTF26;
        } else if( cffield < B0_10000 ) { /* jabbar's MRIge56876 fix */
            minph_pulse_flag = 1 ;
            minph_pulse_index = MINPH_RF_2DTF26;
        } else {
            minph_pulse_flag = 0; /* regular ECHOTRAIN mode */
        }
    }

    /* FIESTA2D - Set RF pulse for FIESTA first */
    if( feature_flag & FIESTA ) {

        /* Make sure flag is reset to 0 */
        minph_pulse_flag = 0;

        if( PSD_OFF == fiesta_rf_flag ) {

            /*
             * This is a 3.5ms half SINC pulse (no side lobes) with a 90
             * degree nominal flip angle, a nominal bandwidth of 571 Hz,
             * and a max B1 of 0.0398.  The initial pulse width is set
             * to 480us to achieve the shorter TRs.  This is the default
             * RF pulse for the FIESTA 2D technique.
             */
            rf1_pulse->abswidth = SAR_ABS_SINC05;
            rf1_pulse->area     = SAR_ASINC05;
            rf1_pulse->effwidth = SAR_PSINC05;
            rf1_pulse->dtycyc   = SAR_DTYCYC_SINC05;
            rf1_pulse->maxpw    = SAR_MAXPW_SINC05;
            rf1_pulse->max_b1   = SAR_MAXB1_SINC05;
            rf1_pulse->max_int_b1_sq = SAR_MAX_INT_B1_SQ_SINC05;
            rf1_pulse->max_rms_b1 = SAR_MAX_RMS_B1_SINC05; 
            rf1_pulse->nom_pw   = 3.5ms;
            rf1_pulse->nom_bw   = 571.0;
            rf1_pulse->nom_fa   = 90.0;
            rf1_pulse->act_fa   = &flip_rf1;
            rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
            rf1_pulse->num = 1;

            pw_rf1_full = 480us;
            pw_rf1 = 480us;

        } else {

            /*
             * This alternate RF pulse is a 500us Time BandWidth (TBW)
             * pulse with truncated tails, a 90 degree nominal flip
             * angle, a nominal bandwidth of 4 KHz, and a max B1 of
             * 0.197458.
             */
            rf1_pulse->abswidth = 0.5947;
            rf1_pulse->area     = 0.5947;
            rf1_pulse->effwidth = 0.4440;
            rf1_pulse->dtycyc   = 1.0;
            rf1_pulse->maxpw    = 1.0;
            rf1_pulse->max_b1   = 0.197458;
            rf1_pulse->max_int_b1_sq = 0.00865607;
            rf1_pulse->max_rms_b1 = 0.131576; 
            rf1_pulse->nom_pw   = 500us;
            rf1_pulse->nom_bw   = 4000.0;
            rf1_pulse->nom_fa   = 90.0;
            rf1_pulse->act_fa   = &flip_rf1;
            rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
            rf1_pulse->num = 1;

            pw_rf1_full = 500us;
            pw_rf1 = 500us;

        }

        gscale_rf1 = 1.00; /* Don't Widen the pulse */
        cyc_rf1 = 0.5;     /* No. of sinc cycles for RF1 */

        pw1_eff = pw_rf1 / (int)(4.0f * cyc_rf1);

        res_rf1 = (int)(pw_rf1 / RF_UPDATE_TIME);
        res_rf1_full = (int)(pw_rf1_full / RF_UPDATE_TIME);

        cutpostlobes = 0;
        pre_lobes = 0;
        post_lobes = 0;

        /* offset to where real 90 occurs */
        off90 = 0;
        t_exb = pw1_eff;
        /* bandwidth of rf1 */
        bw_rf1 = (int)(4.0f * cyc_rf1 / ((float)pw_rf1_full / (float)1.0s));

        if (vstrte_flag && fiesta_rf_flag) {
            rf1_pulse->abswidth = 0.6445;
            rf1_pulse->area     = 0.6445;
            rf1_pulse->effwidth = 0.6001;
            rf1_pulse->dtycyc   = 1.00;
            rf1_pulse->maxpw    = 1.00;
            rf1_pulse->max_b1   = 0.210914;
            rf1_pulse->nom_fa   = 1.0;
            rf1_pulse->act_fa   = &flip_rf1;
            rf1_pulse->nom_bw   = 100.0;
            rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
            rf1_pulse->nom_pw   = 24us;
            rf1_pulse->num = 1;

            gscale_rf1 = 1.00;

            pw_rf1 = 24us;
            res_rf1 = pw_rf1 / RF_UPDATE_TIME;
            pw_rf1_full = 24us;
            res_rf1_full = pw_rf1 / RF_UPDATE_TIME;
            minph_iso_delay = 0;
            bw_rf1 = 100.0;
            pw1_eff = 0;
            t_exb = 0;
        }

    } else {

        /* Check if Minimum Phase Pulse is selected */
        if( minph_pulse_flag ) {

            switch( minph_pulse_index ) {
            case MINPH_RF_2DTF26:
                pw_rf1 = 2.6ms;   /* minph 2dtf26 slr pulse */
                res_rf1 = RES_RF2DTF26;
                /* Reset pulse attributes in rfpulse struct. */
                /* Note that this pulse is ONLY copied into the
                   scan instance of RF1. */
                rf1_pulse->effwidth = SAR_P2DTF26;
                rf1_pulse->abswidth = SAR_ABS_2DTF26;
                rf1_pulse->area     = SAR_A2DTF26;
                rf1_pulse->dtycyc   = SAR_DTYCYC_2DTF26;
                rf1_pulse->maxpw    = SAR_MAXPW_2DTF26;
                rf1_pulse->max_b1   = SAR_MAXB1_2DTF26;
                rf1_pulse->nom_fa   = NOM_FA_2DTF26;
                rf1_pulse->nom_pw   = NOM_PW_2DTF26;
                rf1_pulse->nom_bw   = NOM_BW_2DTF26;
                rf1_pulse->activity = PSD_SCAN_ON + PSD_APS2_ON + PSD_MPS2_ON;
                gscale_rf1 = 1.00; /* Don't widen the pulse*/
                /* To be within the slice profile spec. */
                /* MRIge91751 - corrected minph_iso_delay calculation; now it's rounded to an integer as the last step. */
                minph_iso_delay  = (int)( (float)ISO_2DTF26 * pw_rf1 /
                                         rf1_pulse->nom_pw );      
                break;

            case MINPH_RF_RTIA:
                pw_rf1 = NOM_PW_RTIA;
                /* HD merge_3TC_11.0 START */
                if (lp_mode == 1) pw_rf1 = lp_stretch*pw_rf1; 
                /* HD merge_3TC_11.0 END */
                res_rf1 = RES_RTIA;

                rf1_scale = 1.0;

               /* MRIge84855: If zero is typed in slice thickness field, 
                  exist(opslthick) = FGRE_DEFTHICK and opslthick = 0.  
                  In this case, use the rf for thinner slice to calculate 
                  the minimum slice thickness. */
                if( ((exist(opslthick) < minph_rtia_limit) || 
                     (floatsAlmostEqualEpsilons(opslthick, 0.0, 2) && floatsAlmostEqualEpsilons(exist(opslthick), FGRE_DEFTHICK, 2))) && 
                    (exist(opnecho) >= 2 || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag) && 
                    (cffield <= B0_15000) ) 
                {
                    rf1_scale = 1.2; /* strech the rf1 for thin slices */
                    pw_rf1 = rf1_scale*NOM_PW_RTIA;
                    rfpulseInfo[RF1_SLOT].change = PSD_ON;
                    rfpulseInfo[RF1_SLOT].newres = rf1_scale*res_rf1;
                } 
                /* Reset pulse attributes in rfpulse struct. */
                /* Note that this pulse is ONLY copied into the
                   scan instance of RF1. */
                rf1_pulse->effwidth = SAR_PRTIA;
                rf1_pulse->abswidth = SAR_ABS_RTIA;
                rf1_pulse->area = SAR_ARTIA;
                rf1_pulse->dtycyc = SAR_DTYCYC_RTIA;
                rf1_pulse->maxpw = SAR_MAXPW_RTIA;
                rf1_pulse->max_b1 = MAX_B1_RTIA_08_30;
                rf1_pulse->nom_fa = NOM_FA_RTIA;
                rf1_pulse->nom_pw = NOM_PW_RTIA;
                rf1_pulse->nom_bw = NOM_BW_RTIA;
                rf1_pulse->activity = PSD_SCAN_ON + PSD_APS2_ON + PSD_MPS2_ON;
                gscale_rf1 = 0.8; /* Widen the pulse slightly - per Joe Debbins */
                /* To be within the slice profile spec. */
                /* MRIge91751 - corrected minph_iso_delay calculation; now it's rounded to an integer as the last step. */
                minph_iso_delay  = (int)( (float)ISO_RTIA * pw_rf1
                                          / rf1_pulse->nom_pw );
                break;

            case MINPH_RF_TBW2: 
                if((PSD_TRM_COIL==cfgcoiltype) && (existcv(opgradmode)) && (TRM_BODY_COIL == exist(opgradmode)))
                { /* Whole Mode */
                    pw_rf1 = 320 /*320*/; 
                } 
                else if (PSD_60_CM_COIL==cfgcoiltype) 
                { /* BRM */
                    pw_rf1 = 240 /*240*/; 
                } 
                else 
                { /* ZOOM Mode, CRM, XRMB */
                    pw_rf1 = 200; 
                }
                res_rf1 = RES_TBW2;
                /* Reset pulse attributes in rfpulse struct. */
                /* Note that this pulse is ONLY copied into the
                   scan instance of RF1. */
                rf1_pulse->effwidth = SAR_TBW2_EFF_WIDTH;
                rf1_pulse->abswidth = SAR_ABS_TBW2;
                rf1_pulse->area     = SAR_A_TBW2;
                rf1_pulse->dtycyc   = SAR_DTYCYC_TBW2;
                rf1_pulse->maxpw    = SAR_MAXPW_TBW2;
                rf1_pulse->max_b1   = MAX_B1_TBW2;
                rf1_pulse->nom_fa   = NOM_FA_TBW2;
                rf1_pulse->nom_pw   = NOM_PW_TBW2;
                rf1_pulse->nom_bw   = NOM_BW_TBW2;
                rf1_pulse->activity = PSD_SCAN_ON + PSD_APS2_ON + PSD_MPS2_ON;
                gscale_rf1 = 1.00; /* Don't widen the pulse*/
                /* To be within the slice profile spec. */
                /* MRIge91751 - corrected minph_iso_delay calculation; now it's rounded to an integer as the last step. */
                minph_iso_delay  = (int)((float)pw_rf1 /2.0);      
                break;
            
            case MINPH_RF_SINC1:
                /*use full SINC pulse similar to 2DFAST for MR-Touch*/
                rf1_pulse->abswidth = SAR_ABS_SINC1;
                rf1_pulse->area     = SAR_ASINC1;
                rf1_pulse->effwidth = SAR_PSINC1;
                rf1_pulse->dtycyc   = SAR_DTYCYC_SINC1;
                rf1_pulse->maxpw    = SAR_MAXPW_SINC1;
                rf1_pulse->max_b1   = MAX_B1_SINC1_90;
                rf1_pulse->nom_fa   = 90.0;
                rf1_pulse->act_fa   = &flip_rf1;   /* MRIge30667 */
                rf1_pulse->nom_bw   = NOM_BW_SINC1_90;
                rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
                rf1_pulse->nom_pw   = 3.2ms;

                gscale_rf1 = 1.00; /* Don't Widen the pulse*/

                pw_rf1 = 3200us;
                res_rf1 = pw_rf1_full / RF_UPDATE_TIME;
                minph_iso_delay = RUP_GRD( pw_rf1/2 + off90 );

                break;

            case HARD_RF_24:
                rf1_pulse->abswidth = 0.6445;
                rf1_pulse->area     = 0.6445;
                rf1_pulse->effwidth = 0.6001;
                rf1_pulse->dtycyc   = 1.00;
                rf1_pulse->maxpw    = 1.00;
                rf1_pulse->max_b1   = 0.210914;
                rf1_pulse->nom_fa   = 1.0;
                rf1_pulse->act_fa   = &flip_rf1;  
                rf1_pulse->nom_bw   = 100.0;
                rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
                rf1_pulse->nom_pw   = 24us; 
   
                gscale_rf1 = 1.00;

                pw_rf1 = 24us;
                res_rf1 = pw_rf1 / RF_UPDATE_TIME;
                minph_iso_delay = 0;

                break;
 
            case LPH_RF_TBW6:
                rf1_pulse->abswidth = SAR_ABS_TBW6;
                rf1_pulse->area     = SAR_A_TBW6;
                rf1_pulse->effwidth = SAR_TBW6_EFF_WIDTH;
                rf1_pulse->dtycyc   = SAR_DTYCYC_TBW6;
                rf1_pulse->maxpw    = SAR_MAXPW_TBW6;
                rf1_pulse->max_b1   = MAX_B1_TBW6;
                rf1_pulse->nom_fa   = NOM_FA_TBW6;
                rf1_pulse->act_fa   = &flip_rf1;
                rf1_pulse->nom_bw   = NOM_BW_TBW6;
                rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
                rf1_pulse->nom_pw   = NOM_PW_TBW6;

                gscale_rf1 = 1.00;

                /* Set rf pulse width to 1600us for 3mm slice thickness */
                pw_rf1 = 1800us;
                res_rf1 = RES_TBW6;
                minph_iso_delay = RUP_GRD(pw_rf1/2);
                break;

            default:   /* This should never happen */
                break;
            }  /* End of switch */

            pw_rf1_full = pw_rf1;
            res_rf1_full = (int)(pw_rf1_full / RF_UPDATE_TIME);

            off_rf1 = 0;
            if (minph_pulse_index == MINPH_RF_SINC1) {
                off90 = 80;
            } else {
                off90 = 0;
            }
            t_exb = minph_iso_delay;
            bw_rf1 = (int)(rf1_pulse->nom_bw * (rf1_pulse->nom_pw / (float)pw_rf1));
        }  else  {

            /* Make sure flag is reset to 0 */
            minph_pulse_flag = 0;

            rf1_pulse->abswidth = SAR_ABS_TRUNC1;
            rf1_pulse->area     = SAR_ATRUNC1;
            rf1_pulse->effwidth = SAR_PTRUNC1;
            rf1_pulse->dtycyc   = SAR_DTYCYC_TRUNC1;
            rf1_pulse->maxpw    = SAR_MAXPW_TRUNC1;
            rf1_pulse->max_b1   = MAX_B1_TRUNC1_24_90;
            rf1_pulse->nom_fa   = 90.0;
            rf1_pulse->act_fa   = &flip_rf1;   /* MRIge30667 */
            rf1_pulse->nom_bw   = 1250.0;
            rf1_pulse->activity = PSD_APS2_ON + PSD_MPS2_ON + PSD_SCAN_ON;
            rf1_pulse->nom_pw   = 2.4ms; /* MRIge66555 */

            gscale_rf1 = 1.00; /* Don't Widen the pulse*/
            cyc_rf1 = 1.0;     /* No. of sinc cycles for RF1 */
            frac_rf = 1;       /* always use frac. rf */

            /* MRIge66555 - only for ECHOTRAIN with opslthick > minph_limit
               since RTIA pulses are now used for regular fgre so that
               truncated sinc1 of 1.5ms is no longer valid */        
            pw_rf1_full = 800us;
            res_rf1_full = pw_rf1_full / RF_UPDATE_TIME;

            cutpostlobes = frac_rf;
            pre_lobes = (int)(2.0 * cyc_rf1) - 1;
            post_lobes = ((int)(2.0 * cyc_rf1) - 1) - cutpostlobes;

            pw1_eff = pw_rf1_full / (int)(4.0f * cyc_rf1);
            t_exb = (post_lobes + 1) * pw1_eff;
            bw_rf1 = (int)(4.0f * cyc_rf1 / ((float)pw_rf1_full / (float)1.0s));

            /* Redefine pulse width and resolution of RF based on fract.
               RF calcs */
            pw_rf1 = pw_rf1_full - (cutpostlobes * pw1_eff);
            res_rf1 = pw_rf1 / RF_UPDATE_TIME;

        } /* If not minimum phase pulse */

    }  /* if not FIESTA */

    /* reform list if changes were made */
    form_rf_pulse_list(pulse_table, rfpulse_list, &RF_FREE);
   
    return SUCCESS;   

} /* end of fgre_cveval_rfinit() */

/* 
 * set_slice_select_params () calculates and sets the slice select gradient,
 * RF pulse, rephaser, and Z flow compensation pulses (if used), in the FGRE sequence.
 * 
 * @see also setPulseParams()
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
static STATUS 
set_slice_select_params( void )
{
    if ( rfsafetyopt_doneflag == PSD_OFF ) 
    {
        if( fgre_cveval_rfinit() == FAILURE )
        {
            epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "fgre_cveval_rfinit" );
            return FAILURE;
        }

        /* The following is required to ensure RF pulses get stretched every time
           during the dB/dt interation. --RJF 2/29/2000 */
        /*MRIge93811, MRIge93805 only rescale rf1 pulse*/
        rfpulseInfo[RF1_SLOT].change = PSD_OFF;
        rfpulseInfo[RF1_SLOT].newres = 0;
    }    

    /* Disable the Tagging RF pulses to prevent them from being stretched */
    if( tagging_cveval_rf_disable( rfpulse_list ) == FAILURE ) {
        return FAILURE;
    }
 
    /* MRIge91684 */ 
    for ( entry = 0 ; entry < MAX_ENTRY_POINTS ; entry ++ ) 
    {
@inline RFb1opt+.e RFb1optscalerf
        else
        {
            scalerfpulses( opweight, cfgcoiltype, pulse_table.rfnum, rfpulse_list, entry, rfpulseInfo );
        }
    }

#ifdef REMOVE 
    /* scale for pulse stretching puposes */
    if( scale_rfpulses( MAX_ENTRY_POINTS, &pulse_table, rfpulse_list,
                        opweight, cfgcoiltype, rfpulseInfo ) != SUCCESS ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "scale_rfpulses" );
        return FAILURE;
    }
#endif
    
    /* Reactivate the Tagging RF pulses */
    if( tagging_cveval_rf_enable( rfpulse_list, feature_flag ) == FAILURE ) {
        return FAILURE;
    }

    /* GEHmr03238: gradOpt_pwrf1 should be updated each time.
       Because it will be used by smart_derating() to calculate gradOpt_powerRF. */
    /* SVBranch GEHmr04367: gradOpt_pwrf1 should not be updated when B1 optimization is doing
                   (rfsafetyopt_doneflag == PSD_OFF).  */
    if ( gradOpt_flag && (PSD_OFF == rfsafetyopt_doneflag) )
    {
        gradOpt_pwrf1 = pw_rf1;
    }

    /* GEHmr02638: smart derating */
    /* SVBranch HCSDM00102590 */
    if( (PSD_OFF == rfsafetyopt_doneflag) && gradOpt_flag && (fabs(ogsfRF-1.0) > 0.01) )
    {
        int newpw_rf1;
        INT txIndex[MAX_TX_COIL_SETS];
        INT exciterIndex[MAX_TX_COIL_SETS];
        INT exciterUsed[MAX_TX_COIL_SETS];
        INT numTxIndexUsed = 0;

        /* scale RF pulse. Same code as deratePulseWidth() defined in rfsafetyopt.c */
        getTxAndExciter(txIndex, exciterIndex, exciterUsed, &numTxIndexUsed,
                        coilInfo, opncoils);

        rfpulseInfo[RF1_SLOT].change = PSD_OFF;
        newpw_rf1 = RUP_GRD((ceil)((float)gradOpt_pwrf1 /ogsfRF));

        if( scalerfpulsescalc( gradOpt_pwrf1, newpw_rf1, GRAD_UPDATE_TIME, &rfpulse_list[RF1_SLOT], L_SCAN, RF1_SLOT,
                               &rfpulseInfo[RF1_SLOT], exciterUsed[0]) != SUCCESS )
        {
            epic_error( use_ermes, "Support routine %s failed.", EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "scalerfpulsescalc" );
            return FAILURE;
        }
    }

    /* Update RF pulse parameters based on the pulse stretch */
    /* MRIge91751 - corrected minph_iso_delay calculation; now it's rounded to an integer as the last step. */
    if( minph_pulse_flag ) {
        switch ( minph_pulse_index ) {
            case MINPH_RF_2DTF26:
                minph_iso_delay  = (int)( (float) ISO_2DTF26 * pw_rf1 /
                                          rf1_pulse->nom_pw );
                break;
            case MINPH_RF_RTIA:
                minph_iso_delay  = (int)( (float) ISO_RTIA * pw_rf1 /
                                         rf1_pulse->nom_pw );
                break;
            case MINPH_RF_TBW2:
                minph_iso_delay  = (int)((float)(pw_rf1/2.0));
                break;
            case MINPH_RF_SINC1:
                minph_iso_delay = RUP_GRD( pw_rf1/2 + off90 );
                break;
            case HARD_RF_24:
                minph_iso_delay = 0;
                break;
            case LPH_RF_TBW6:
                minph_iso_delay = RUP_GRD( pw_rf1/2 );
                break;
            default:
                break;                
        }
        pw_rf1_full = pw_rf1;
        t_exb = minph_iso_delay;
        bw_rf1 = (int)(rf1_pulse->nom_bw * (rf1_pulse->nom_pw / (float)pw_rf1));
    } else {
        if (!vstrte_flag) {
            /* Calculate and round up pw_rf1_full from the scaled value */
            pw_rf1_full = (int)((double)pw_rf1 / (1.0 - ((double)cutpostlobes /
                                                     (4.0 * (double)cyc_rf1))));
            pw_rf1_full = RUP_RF(pw_rf1_full);
            pw1_eff = (int)((float)pw_rf1_full / (4.0f * cyc_rf1));
            t_exb = (post_lobes + 1) * pw1_eff;
            bw_rf1 = (int)(4.0f * cyc_rf1 / ((float)pw_rf1_full / (float)1.0s));

            /* Reset resolutions of full and fractional based on new pulse widths */
            res_rf1_full = (int)(pw_rf1_full / RF_UPDATE_TIME);
            res_rf1 = (int)(pw_rf1 / RF_UPDATE_TIME);
        }
    }

    /* Begin RTIA addition */
    if( (feature_flag & RTIA98) &&
        (exist(opautote) != PSD_FWINPHS) &&
        (exist(opautote) != PSD_FWOUTPHS) ) {
        /* Now that rf1 is set up, copy it to rf1fc! */
        if( CopyToFlowCompRFPulse( rf1_pulse )  == FAILURE ) {
            epic_error( use_ermes, "fgre: %s failed.", EM_PSD_ROUTINE_FAILURE,
                        EE_ARGS(1), STRING_ARG, "CopytoFlowCompRFpulse" );
            return FAILURE;
        }

        /* MRIge62019, SK */ 
        rfpulseInfo[RF1FC_SLOT].change = rfpulseInfo[RF1_SLOT].change;
        rfpulseInfo[RF1FC_SLOT].newres = rfpulseInfo[RF1_SLOT].newres;
    }
    /* End RTIA addition */

    /*********************
     *  Z Board          *
     *  Slice Selection  *
     *********************/
    /* MRIge56926 - Calculation of avminslthick - TAA */
    minslicethick( &av_temp_float, bw_rf1, gzrf1target, gscale_rf1, TYPDEF );
    av_temp_float = ceil( av_temp_float * 10.0) / 10.0;
    avminslthick = av_temp_float;
    if(perfusion_flag) avminslthick=FMax(2,avminslthick,7.0);

     /* MRIhc03165 and MRIhc03566: Set minimum slice thickness for calibration to 5.0 mm. */
     if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) )
         avminslthick = FMax(2, avminslthick, 5.0);

    if(gradspec_flag)
    {
        if(isRioSystem())
        {
            avminslthick = ceil(100.0*bw_rf1/(GAM*RIO_GRADSPEC_MAX_ZAMP))/10.0;
        }
        else if(isHRMbSystem())
        {
            avminslthick = ceil(100.0*gscale_rf1*bw_rf1/(GAM*HRMB_GRADSPEC_MAX_ZAMP))/10.0;
        }
    }

    /* MRIge56926 -Removed calculation for avminslthick */
    /* MRIge84855: If zero is typed in slice thickness field, psd_slthick = exist(opslthick) 
       = FGRE_DEFTHICK and it may not be less than avminslthick.  But, we still need 
       advisory pop-up.  Additional condition for advisory pop-up added. */
    if( PSD_ON == exist(oprealtime) ) 
    {
        if( (existcv(opslthick) && (psd_slthick < avminslthick)) || 
            (floatsAlmostEqualEpsilons(opslthick, 0.0, 2) && floatsAlmostEqualEpsilons(exist(opslthick), FGRE_DEFTHICK, 2)) ) {
            /* MRIge60539 */
                /*
                * Here factor 2.0 is due to slthick zoom factor of 50%.  Because
                * psd_slthick is 50% of opslthick, to increase psd_slthick to a
                * certain value we need to require opslthick to go to twice as
                * much.
                */
                avminslthick *= 2.0; /* MRIge62974 - to use advisory popup with
                                        corrected value for RTIA */
            
            /* YMSmr08456  02/16/2006 YI  Moved returning ADVISORY_FAILURE to cvcheck.
            This code was removed as part of MRIhc43102 since conflicting advisory slice thickenss messages
            popped up.  Since derating factor is changed between 1.0 and the desired dearating factor during
            rfsafetyopt(), conflicts arose. Instead of throwing the error at cvcheck(), modified to throw
            advisory error below.  Confired that the resolution of YMSmr08456 is still ok  */
            epic_error( use_ermes, "Increase the slice thickness to %.1f", 
                        EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avminslthick );
            return ADVISORY_FAILURE;
        }
    }

    pw_gzrf1 = RUP_GRD(pw_rf1);

    if ( ampslice( &a_gzrf1, bw_rf1, psd_slthick, gscale_rf1,
                   TYPDEF ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "ampslice (for gzrf1)" );
        return FAILURE;
    }

   if ( (exist(oprealtime) == PSD_ON) || gradspec_flag) 
   {
       if ( optramp( &pw_gzrf1a, a_gzrf1, gzrf1target, zrt, TYPDEF ) == FAILURE ) {
           return FAILURE;
       }

   }
   else
   {
       if ( optramp( &pw_gzrf1a, a_gzrf1, gzrf1target, zrt*loggrd.scale_3axis_risetime, TYPDEF ) == FAILURE ) {
           return FAILURE;
       }
   }
  
   
    pw_gzrf1d = pw_gzrf1a;
    gzrf1_pulse->num = 1;

    std_amp = .818;   /* standard amplitude of 1 sinc pulse */

    if( minph_pulse_flag || (fiesta_rf_flag && vstrte_flag) )  {
        t_exa = pw_gzrf1a + (pw_gzrf1 - minph_iso_delay);
    } else {
        t_exa = pw_gzrf1a + (pre_lobes + 1) * pw1_eff;
    }

    /* Since this is used in the non_tetime calculation round up
       to 4 usec boundaries */
    t_exa = RUP_GRD(t_exa);

    /******************************
     *  Z rephaser and flow comp  *
     ******************************/

    gz1_pulse->num   = 1;

    /* bypass this check */
    avail_pwgz1 = TR_MAX;

    /* FIESTA derating  05/16/2005 YI */
    if( ((cfgradamp == 8919) || (cfgradamp == 5551) ||(cfgradamp == 8905)||(cfgradamp == 8907)||((int)(10000 * cfxfs / cfrmp2xfs)<70)) && 
        (feature_flag & FIESTA) ) {
       derate_gz_G_cm = FMin(2, acgd_lite_target, loggrd.tz_xyz);
       derate_gz_factor = derate_gz_G_cm / loggrd.tz_xyz;
       if(plane_type == PSD_OBL)
           derate_gz_factor = 1.0;
    } else {
       derate_gz_G_cm = loggrd.tz_xyz;
       derate_gz_factor = 1.0;
    }

    /* GEHmr02638: smart derating */
    /* SVBranch: let aTEopt_flag and aTRopt_flag work */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
       derate_gz_G_cm   = loggrd.tz_xyz;
       derate_gz_factor = 1.0;
    }

    if(gradspec_flag)
    {
        derate_gz_G_cm = FMin(2, a_gzrf1, loggrd.tz_xyz);
        derate_gz_factor = 2.0*derate_gz_G_cm / loggrd.tz_xyz;
    }

    /* MRIge38985 */
    /* RTIA, RJF */
    if ( (flow_comp_type==TYPFC) && (! (feature_flag & RTIA98) )  ) {
        /* End RTIA */
        if ( amppwgzfcmin(a_gzrf1, pw_gzrf1a, pw_gzrf1, pw_gzrf1d,
                          avail_pwgz1, (t_exb - pw_gzrf1 / 2),
                          loggrd.tz_xyz*ogsfZ,
                          RUP_GRD((ceil)(zrt*loggrd.scale_3axis_risetime*ogsfZ)), loggrd.zbeta,
                          &a_gz1, &pw_gz1a, &pw_gz1, &pw_gz1d,
                          &a_gzfc, &pw_gzfca, &pw_gzfc, &pw_gzfcd) == FAILURE ) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "amppwgzfcmin" );
            return FAILURE;
        }

        gzfc_pulse->num = 1;
        gxfc_pulse->num = 1; /* also set for GXFC here, pulse width and amp
                                of gxfc will be calculated in a subroutine*/
    } else {
        /* area needed for rephaser */
        /* different area needed if the minimum phase slr pulse is used. */
        if( minph_pulse_flag == 0 ) {
            area_gz1 = a_gzrf1 * (0.5 * (FLOAT)pw_gzrf1d +
                                  (FLOAT)(off90 + t_exb) );
        } else {
            area_gz1 = (minph_iso_delay + (pw_gzrf1d / 2.0)) * a_gzrf1;
        }

        if ( amppwgz1( &a_gz1, &pw_gz1, &pw_gz1a, &pw_gz1d,
                       area_gz1, avail_pwgz1, MIN_PLATEAU_TIME,
                       RUP_GRD((ceil)(zrt*loggrd.scale_3axis_risetime * derate_gz_factor * ogsfZ)),
                       derate_gz_G_cm * ogsfZ) == FAILURE ) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "amppwgz1:gz1" );
            return FAILURE;
        }
        gzfc_pulse->num = 0;
        gxfc_pulse->num = 0;
    }

    return SUCCESS;
}   /* end set_slice_select_params() */


/*
 * set_phase_encode_and_rewinder_params() calculates and sets the ,
 * Phase Encode and Rewinder pulse attributes, in the FGRE sequence.
 * Returns FAILURE/ADVISORY_FAILURE if calculations fail with appropriate
 * error structures filled in.
 *
 * @see also setPulseParams()
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
static STATUS
set_phase_encode_and_rewinder_params( void )
{
    /*****************************************
     * Y Board - Dephaser and Rewinder       *
     *                                       *
     * Calculate Y Phase encode amp and pw.  *
     *****************************************/
     float round_factor = 2.0; /* MRIhc16225 */

    /* find min time for gy1 (same for exor and non-exor case)
       phase encode can play out during ramps so add it in */
    avail_pwgx1 = 1s;   /* use a large number, because minte is always used
                           and user never selects opte value */
    /* change for dBdt Opt - RJF */
    avail_pwgy1 = avail_pwgx1 + xrt;
    /* End dBdtOpt change */

    /* MRIge86251
     * Opening up fractional pFOV for asset scans. Take MRIge84868 fix for
     * rhnframes calculation. Round up rhnframes to ensure that rhnframes
     * and rhnframes / fn are even for all cases. Recon doesn't like odd 
     * number of frames & endview() doesn't like odd values of rhnframes/fn.
     */

    if ( existcv(opasset) && (ASSET_SCAN_PHASE == exist(opasset)) )
    {
         asset_factor = FMin(2, 1.0, 1/(perfusion_flag?opaccel_ph_stride:(exist(opaccel_ph_stride))));
    }
    else
    {
         asset_factor = 1.0;
    }

    yfov_aspect = nop * exist(opphasefov);
    {
        round_factor = (floatsAlmostEqualEpsilons(fn, 0.75, 2)) ? 6.0 : 2.0;

        if (arc_ph_flag) 
        {
            rhnframes = arc_ph_acquired;
            phaseres =  arc_ph_fullencode;
        } 
        else 
        {
            rhnframes = (int)(ceilf( eg_phaseres * fn * yfov_aspect * asset_factor /
                                    round_factor ) * round_factor);
            phaseres = (int)(rhnframes/fn);
        }
    }
    /* Calculate actual ASSET factor, based on rounded value for rhnframes. */
    if( exist(opasset) == ASSET_SCAN) {
        asset_factor = FMin(2, 1.0, rhnframes / ( eg_phaseres * yfov_aspect * fn ));
    } else {
        asset_factor = 1.0;
    }

    /* MRIhc16225: Introducing round_factor for rounding rhnframes & endview() call argument
                   to nearest even number */
    round_factor = (floatsAlmostEqualEpsilons(fn, 0.75, 2)) ? 6.0 : 2.0;

    /* MRIge73669: Calculate rhnframes and rhhnover for FGRE-ET (ETL != 1) */
    et_set_fracnex_rhvars( feature_flag );

    /* Opened up opyres to allow multiples of 2 for all applications. */
    /* (MRIge91751) */
    if ( ( exist(opyres) % 2 != 0 ) )  {
        if ( ((exist(opyres) & 0x1) >= 1 ) ) {
            /* clear one bit and add 2*/
            avminyres = ( ( (exist(opyres) >> 1) << 1 ) + 2 );
            return ADVISORY_FAILURE ;
        }

        /* round it down to the next multiple of 2.
           At this point we're sure that opyres is greater
           than 2 anyway, because there's a range check
           before. */
        if ( (exist(opyres) & 0x1) < 1 )  {
            avmaxyres =   ( (exist(opyres) >> 1 ) << 1 ) ;
            return ADVISORY_FAILURE ;
        }
    }

    /* MRIge93639 - Allow multiples of 4 for opxres. */
    if ( ( exist(opxres) % 4 != 0 ) )  {
        if ( ((exist(opxres) & 0x3) >= 2) ) {
            /* clear all the two bits and add 4*/
            avminxres = ( ((exist(opxres) >> 2) << 2) + 4 ) ;
            return ADVISORY_FAILURE ;
        }

        if ( (exist(opxres) & 0x3) < 2 )  {
            avmaxxres =   ( (exist(opxres) >> 2) << 2 ) ;
            return ADVISORY_FAILURE ;
        }
    }

    if(gradspec_flag)
    {
        if(existcv(oprbw) && existcv(opxres))
        {
            if(isRioSystem())
            {
                avmaxxres = RIO_GRADSPEC_MAX_XFLAT*2*exist(oprbw)*1.0e-3;
            }
            else if(isHRMbSystem())
            {
                avmaxxres = HRMB_GRADSPEC_MAX_XFLAT*2*exist(oprbw)*1.0e-3;
            }
            avmaxxres = (avmaxxres >> 2) << 2;
        }
    }

    /* Scale the waveform amps for the phase encodes
       so each phase instruction jump is an integer step */
    if ( endview( phaseres, &endview_iamp) == FAILURE ) {
        epic_error( use_ermes, (char *)supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "endview" );
        return FAILURE;
    }

    endview_scale = (FLOAT)max_pg_iamp / (FLOAT)endview_iamp;

    /* FIESTA derating  05/16/2005 YI 
    endview_scale_tem = FMin(2, (FLOAT)loggrd.ty_xyz,
                             (FLOAT)((FLOAT)loggrd.ty_xyz /
                                     (FLOAT)endview_scale));
    */
    if(derate_gy1_flag)
    { 
       /* extra_derate_gy1 is initialized to 1.0 in cvinit(), then changed in derate_gy1()
          in setPulseParams() */
       derate_gy_G_cm = loggrd.ty_xyz * extra_derate_gy1;
       derate_gy_factor = extra_derate_gy1;
    } else if( ((cfgradamp == 8919) || (5551 == cfgradamp)  ||(cfgradamp == 8905)||(cfgradamp == 8907) ||((int)(10000 * cfxfs / cfrmp2xfs)<70)) && 
        (feature_flag & FIESTA) ) {
       derate_gy_G_cm = FMin(2, acgd_lite_target, loggrd.ty_xyz);
       derate_gy_factor = derate_gy_G_cm / loggrd.ty_xyz;
       if(plane_type == PSD_OBL)
           derate_gy_factor = 1.0;
    } else {
       derate_gy_G_cm = loggrd.ty_xyz;
       derate_gy_factor = 1.0;
    }

    /* GEHmr02638: smart derating */
    /* SVBranch: let aTEopt_flag and aTRopt_flag work */
    if( (gradOpt_flag || aTEopt_flag || aTRopt_flag) && !derate_gy1_flag)
    {
       derate_gy_G_cm   = loggrd.ty_xyz;
       derate_gy_factor = 1.0;
    }

    if (gradspec_flag)
    {
        derate_gy_factor = 3.0;
    }

    endview_scale_tem = FMin(2, derate_gy_G_cm,
                             (FLOAT)((FLOAT)derate_gy_G_cm /
                                     (FLOAT)endview_scale));

    /** trapezoidal phase encoding gradient lobe specified by
        default -- TKF  **/


    /* MRIge45339 */
    /* RTIA changes exist(opfov) to  psd_fov */  /* ASSET */ /* FIESTA derating  05/16/2005 YI */
    if (amppwencode(gy1_pulse, &pw_gy1_tot,
                    (endview_scale_tem * ogsfY),
                    /*yrt*/ RUP_GRD((ceil)(yrt * derate_gy_factor * ogsfY*loggrd.scale_3axis_risetime)),
                    (float) nop * psd_fov * exist(opphasefov) * asset_factor,
                    phaseres, 0.0 /* offset area */) == FAILURE) {
        epic_error(use_ermes,(char *)supfailfmt,EM_PSD_SUPPORT_FAILURE,
                   EE_ARGS(1),STRING_ARG,"amppwencode:gy1");
    }

    /* GEHmr02638: smart derating */
    ss_rewinder_flag = ((gradOpt_flag * fabs(ogsfY - ogsfYk)) > 0.001)? 0 : 1;

    if( PSD_OFF == ss_rewinder_flag )
    {
        if (amppwencode(gy1r_pulse, &pw_gy1r_tot,
                    (endview_scale_tem * ogsfYk),
                    /*yrt*/ RUP_GRD((ceil)(yrt * derate_gy_factor * ogsfYk*loggrd.scale_3axis_risetime)),
                    (float) nop * psd_fov * exist(opphasefov) * asset_factor,
                    phaseres, 0.0 /* offset area */) == FAILURE)
        {
            epic_error(use_ermes,(char *)supfailfmt,EM_PSD_SUPPORT_FAILURE,
                   EE_ARGS(1),STRING_ARG,"amppwencode:gy1r");
        }
    }

    /*
     * Added this section (for TOP_DOWN k-space ordering and Full NEX only)
     * to scale the max available gradient for systems with 2.2 G/cm (or
     * lower) gradient strength. This was necessary due to non-symmetric
     * gy and gyr gradients with the addition of the phase encoding shift
     * (phenc_offset) in top-down trajectory in Echotrain.  Note that max
     * gradient will not be scaled down for high end systems and will be
     * scaled down in lower grad. strength systems for demanding protocols
     * The min_area calculation code is taken from amppwtpe.c.
     * - MRIge67556 Azim Celik
     */
    if( (phenc_offset > 0) && (feature_flag & ECHOTRAIN) ) {
        FLOAT target_area;
        FLOAT target_area_gy;
        FLOAT min_area;
        FLOAT fs_rat;
        FLOAT ramp_factor;

        ramp_factor = (FLOAT)loggrd.yrt / endview_scale_tem;

        /* The following is the ratio between full scale and
           full scale minus the least significant 6 bits.
           (max_pg_wamp - 2^7) / max_pg_wamp = 1 - 64 / max_pg_wamp) */
        fs_rat = 1.0 - (64.0 / (FLOAT)max_pg_wamp);

        /*
          Calculate the minimum area of a trapezoid with a "flattop"
          of width MINPW_MIDDLE.  The amplitude of the decay side is
          endview_scale_tem.  The amplitude of the attack side is
          fs_rat*endview_scale_tem.
          The pulse width of the attack and decay are ramp_factor
          time the respective amplitudes.  Therefore the total area is
          equal to:
          attack: 0.5*endview_scale_tem*fs_rat*endview_scale_tem*fs_rat*ramp_factor +
          middle: 0.5*(endview_scale_tem + endview_scale_tem*fs_rat)*MINPW_MIDDLE +
          decay : 0.5*endview_scale_tem*endview_scale_tem*ramp_factor,
          which reduces to...
        */
        min_area = (0.5 * endview_scale_tem *
                    (endview_scale_tem * ramp_factor *
                     (fs_rat * fs_rat + 1.0) + (FLOAT)MINPW_MIDDLE *
                     (1.0 + fs_rat)));

        target_area = ((0.5 * (phaseres - 1) + phenc_offset) /
                       (get_act_phase_fov() * GAM) * 1e7);

        target_area_gy = ((0.5 * (phaseres - 1)) /
                          (get_act_phase_fov() * GAM ) * 1e7);

        /* Make sure area is correct to prevent elongation */
        if( target_area_gy > min_area ) {
            if( amppwtpe( gy1_pulse->amp, gy1_pulse->ampd, gy1_pulse->pw,
                          gy1_pulse->attack, gy1_pulse->decay, 
                          (endview_scale_tem*target_area_gy/target_area),
                          loggrd.yrt, target_area_gy ) == FAILURE ) {
                return FAILURE;
            }
        }
    }

    if (derate_gy1_flag)
    {
        if(extra_derate_gy1>=0.999){
            /* save gy1 parameters without derating to apply them to gy1r */
            pw_gy1_no_derate  = pw_gy1;
            pw_gy1a_no_derate = pw_gy1a;
            pw_gy1d_no_derate = pw_gy1d;
            a_gy1a_no_derate  = a_gy1a;
            a_gy1b_no_derate  = a_gy1b;
        }
    }

    /* core phase encode gradient values */
    a_gy1 = a_gy1a;
    if (rewinder_flag == PSD_ON) 
    {
        if(derate_gy1_flag)
        {   /* do not derate gy1r */
            a_gy1r = -a_gy1a_no_derate;
        } else {
            /* GEHmr02638: smart derating */
            if( ss_rewinder_flag )
            {
                a_gy1r = -a_gy1a;
            }
            else
            {
                a_gy1r = -a_gy1ram;
                a_gy1ra = a_gy1ram;
                a_gy1rb = a_gy1rbm;
            }
        }
    }

    gy1_pulse->num = 1;

    if ( rewinder_flag == PSD_ON ) 
    {
        if(derate_gy1_flag)
        {   /* do not derate gy1r */
            pw_gy1r  = pw_gy1_no_derate;
            pw_gy1ra = pw_gy1a_no_derate;
            pw_gy1rd = pw_gy1d_no_derate;
            a_gy1ra  = a_gy1a_no_derate;
            a_gy1rb  = a_gy1b_no_derate;
        } 

        /* GEHmr02638 */
        if( ss_rewinder_flag )
        {
            pw_gy1r  = pw_gy1;
            pw_gy1ra = pw_gy1a;
            pw_gy1rd = pw_gy1d;
            a_gy1ra  = a_gy1a;
            a_gy1rb  = a_gy1b;
        }

        a_gy1ram = -a_gy1ra;
        a_gy1rbm = -a_gy1rb;
        
        pw_gy1r_tot     = pw_gy1ra + pw_gy1r + pw_gy1rd;
        gy1r_pulse->num = 1;
    } else {
        pw_gy1r  = GRAD_UPDATE_TIME;
        pw_gy1ra = GRAD_UPDATE_TIME;
        pw_gy1rd = GRAD_UPDATE_TIME;
        a_gy1ra  = 0;
        a_gy1rb  = 0;
        a_gy1ram = 0;
        a_gy1rbm = 0;
        pw_gy1r_tot = pw_gy1r+pw_gy1ra+pw_gy1rd;

    }

    /* now calculate the combined pulse values  */
    pw_gy1_tot = pw_gy1a + pw_gy1 + pw_gy1d + yfe_time;

    if( (phenc_offset > 0) && (feature_flag & ECHOTRAIN) ) { /*gss*/
        float target_area;

        /*use for TOP_DOWN only*/
        target_area = ( 0.5*(phaseres-1) + phenc_offset )/ 
            ( get_act_phase_fov()*GAM )*1e7;
        if(gss_debug & 1) {
            printf("target_area=%.3f\n",target_area);
            fflush(stdout);
        }
        if(amppwtpe(gy1r_pulse->amp, gy1r_pulse->ampd, gy1r_pulse->pw,
                    gy1r_pulse->attack, gy1r_pulse->decay, endview_scale_tem,
                    loggrd.yrt, target_area) == FAILURE) {
            return FAILURE;
        }

        pw_gy1r_tot = *gy1r_pulse->attack + *gy1r_pulse->pw + *gy1r_pulse->decay;

        a_gy1ra  = a_gy1ram;
        a_gy1rb  = a_gy1rbm;
        a_gy1r   = -a_gy1ra;
    }

    return SUCCESS;
}   /* end set_phase_encode_and_rewinder_params() */


/*
 * set_zkiller_params() calculates and sets the  Z Killer pulse (gzk) attributes.
 * Returns FAILURE/ADVISORY_FAILURE if calculations fail with appropriate
 * error structures filled in.
 *
 * @see also setPulseParams()
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
static STATUS
set_zkiller_params( void )
{
    /****************
     *  Killer CVs  *
     ****************/
 
    /* area to be covered by the killer pulse, same as 4.7 version */

    if ((vstrte_flag) || (gradspec_flag)) crusher_flag = 0;

    /* Make sure the crusher is always ON with FIESTA 2D */
    if( feature_flag & FIESTA ) {
        crusher_flag = 1;
    }

    gzk_pulse->num   = 1;
    if( crusher_flag == 1 ) {
        if( feature_flag & FIESTA ) {
            /* FIESTA2D - calc rewinder for slice select; note that
               t_exa includes pw_gzrf1a */
            area_gzk = -1.0 * (float)(t_exa - pw_gzrf1a / 2) * a_gzrf1;

            /* FIESTA derating 07/09 2005 YI
            if( amppwgradmethod( gzk_pulse, area_gzk, zkilltarget,
                                 0.0, 0.0, zrtime, MIN_PLATEAU_TIME ) == FAILURE ) {
            */
            if( amppwgradmethod( gzk_pulse, area_gzk, derate_gz_G_cm * ogsfZk,
                                 0.0, 0.0, RUP_GRD((ceil)(zrtime * derate_gz_factor * ogsfZk)),
                                 MIN_PLATEAU_TIME ) == FAILURE ) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                            EE_ARGS(1), STRING_ARG, "amppwgradmethod:gzk" );
                return FAILURE;
            }
        } else {
            /* SVBranch HCSDM00178991: increase max_area_gzk to 3000 to weaken MERGE's fineline artifact */
            if( (isValueSystem()) &&
                (feature_flag & MERGE) )
            {
                max_area_gzk = 3000.0;
            }
            else if( (isValueSystem() || isKizunaSystem() ) && (feature_flag & GATEDTOF) && (feature_flag & SPSAT) )
            {
                max_area_gzk = 1000.0;
            }
            else
            {
                max_area_gzk = 400.0;
            }

            /* change this so that we get at least 2 times 2pi phase dispersion
               across the slice, t_exa includes pw_gzrf1a */
            area_gzk = FMin(2, max_area_gzk,
                            FMax(2, min_area_gzk,
                                 4.0 / (FLOAT)(GAM * 1.0e-6 * (psd_slthick / 10.0)) -
                                 (FLOAT)(t_exa - pw_gzrf1a/2) * fabs(a_gzrf1)));

            /* MRIhc09984: Increased Crusher area for SPGR when TR greater or
             * equal to 100ms and flip greater than or equal to 50. This was done
             * to better crush residual magnitization. */
            /* HCSDM00241267 : dual echo requires increased spoiling for residual magnetization */
            /* For 1.5T dualecho_inflow_reduce required increased spoiling for residual magnetization */
            if( (( existcv(oppseq) && exist(oppseq) == PSD_SPGR ) &&
                (existcv(optr) && exist(optr) >= 100ms) && (existcv(opflip) && exist(opflip) >= 50.0)) ||
                (PSD_ON == exist(opfat)) || (dualecho_minTE)  || (PSD_ON == dualecho_inflow_reduce))
            {
                area_gzk = 4 * area_gzk;
            }

	    /*HCSDM00095097 : retain HD16 crusher areas for HD ASSET*/
	    if ( ( (cfgcoiltype == PSD_60_CM_COIL) || (cfgcoiltype == PSD_TRM_COIL) ) 
		&& (!value_system_flag) 
		&& ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) )
	    {
		HD_ASSET_flag = PSD_ON;
	    }
	    else
	    {
		HD_ASSET_flag = PSD_OFF;
	    }
	    
	    
            /* MRIhc54399 Increase Crusher in Z and X direction to remove the zipper artifact. This change only impact
               Base FGRE, SPGR and EchoTrain */
            /* SVBranch HCSDM00132376. For 16Beat system, do not set area_gzk to 1600 if the protocol is for limit parameter check.*/
            /* IF opslthick >= 100mm and opfov >= 48cm, the protocol is deemed to be for limit parameter check. */
            if( (feature_flag & MPL) && (1 == exist(opnecho)) &&
                existcv(oppseq) && ( (PSD_GE == exist(oppseq)) || (PSD_SPGR == exist(oppseq)) ) &&
                (PSD_OFF == exist(opcgate)) && (PSD_OFF == exist(oprealtime)) &&
		(PSD_OFF == HD_ASSET_flag))
            {
                if( (!isValueSystem()) || /*DV products*/ 
                    ((100>exist(opslthick)) || (480>exist(opfov))) ) /* Value product && it is not protocol for limit parameters check. */
                {
                    area_gzk = 1600;
                }
            }
	    else if (PSD_ON == HD_ASSET_flag) 
	    {
                area_gzk = 800;
	    }

            if ((feature_flag & MERGE) && ((int)exist(opuser8)>0))
            {
                area_gzk = 800;
            }
 
            if( amppwgradmethod( gzk_pulse, area_gzk, zkilltarget * ogsfZk,
                                 0.0, 0.0, RUP_GRD((ceil)(zrtime * derate_gz_factor * ogsfZk)),
                                 MIN_PLATEAU_TIME ) == FAILURE ) {
                epic_error( use_ermes, (char *)supfailfmt, EM_PSD_SUPPORT_FAILURE,
                            EE_ARGS(1), STRING_ARG, "amppwgradmethod:gzk" );
                return FAILURE;
            }
        }
    } else {
        a_gzk   = 0.0001;
        ia_gzk  = 0;
        pw_gzka = GRAD_UPDATE_TIME;
        pw_gzk  = GRAD_UPDATE_TIME;
        pw_gzkd = GRAD_UPDATE_TIME;
    }

    gzktime = pw_gzka + pw_gzk + pw_gzkd;
    return SUCCESS;
}   /* end set_zkiller_params() */


/*
 * set_rdout_params_te_and_tmin () calculates and sets the pulse attributes:
 * of the  Readout, Freq. Prephaser and X flow Compensation pulses (if used).
 * This also calculates and sets the min. sequence time as limited by the waveforms
 * handles TE selections (min/full/inphase/outofphase), fractional Echo, fractional decimation
 * and settings of filter structures appropriately. Also calculates and sets the pulse
 * attributes for the gxwex pulse.
 *
 * Returns FAILURE/ADVISORY_FAILURE if calculations fail with appropriate
 * error structures filled in.
 *
 * @see also setPulseParams()
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
static STATUS
set_rdout_params_te_and_tmin( void ) 
{
    FLOAT minfovcm;
    INT tmp_rupgrd;     /* temp var used for RUP_GRD calls */
    INT xres_frac;      /* changed SHORT to INT - vinod */
    FLOAT fnecho_lim_frac; 
    float valid_rbw;
    float valid_max_rbw;
    float valid_decimation;   /* MRIge80365, MRIge74549 */

    /* GEHMr02638: smart derating */
    float backup_loggrd_tx_xyz = 0; /* backup of loggrd.tx_xyz */
    float backup_loggrd_ty_xyz = 0; /* backup of loggrd.ty_xyz */
    float backup_loggrd_tz_xyz = 0; /* backup of loggrd.tz_xyz */
    int backup_loggrd_opt_xrt = 0;  /* backup of loggrd.opt.xrt */
    int backup_loggrd_opt_yrt = 0;  /* backup of loggrd.opt.yrt */
    int backup_loggrd_opt_zrt = 0;  /* backup of loggrd.opt.zrt */

    /*
      Calculate the earliest time when the slice select attack 
      ramp can be started. Allow at least 48us in the beginning.
      The other factor affecting the start time is the time taken 
      by all the SSP packets which are to be played out before the 
      RF can start.  Given below are the timing components.

      tlead : researcher controllable parameter to change the gradient start time.
      1us   : scope trigger SSP control packet length
      sq_sync_length : Sync packet length (8us)
      GRAD_UPDATE_TIME : Time to play out SSP td0 time.
      rffrequency_length : Length of SSP packet to set transmit Freq/Phase 
      rfupa : RF amplifier unblank delay time
      psd_rf_wait : place gradient this much before RF to acct for sys RF/Grad delay diff.
       
      - RJF, LxMGD 
    */
    { 
        int lead_deadtime;    /* Lead time upfront */
        int min_lead2rfstart; /* minimum delay between end of lead time to when rf can be started. */ 
        int gz_start_temp;    /* time when slice select grad flat top can start without WARP delays */ 
        int z_td0_time;       /* pw of the td0 delay pulse on z axis */

        lead_deadtime    = IMax(2, (1us + sq_sync_length[bd_index]), tlead );
        min_lead2rfstart = (GRAD_UPDATE_TIME                           /* ssp_td0 time */
                            + (!(feature_flag & ECHOTRAIN) ? 
                               DAB_length[bd_index] : HSDAB_length )   /* DAB packet length */
                            + rfFrequencyPacketLength()                /* RF freq packet length */
                            + rfupacv);                                /* RF amplifier unblank delay time (note rfupa is negative)*/
                                                                       /* Changing it back to rfupacv for HDxt */
                                                                   

        /* place gradient psd_rf_wait before RF to acct for sys RF/Grad delay diff. */
        /* Note that gz_start_temp is the time when the flat top of gzrf1 can start, and 
           not when the attack ramp can start.  MRIge73868, RJF */

        /* pw_z_td0 may get set only in predownload */
        z_td0_time = IMax(2, GRAD_UPDATE_TIME, pw_z_td0);

        gz_start_temp = (lead_deadtime + IMax( 2, 
                                               (min_lead2rfstart - psd_rf_wait), 
                                               (pw_gzrf1a + z_td0_time) ));

        /* Now consider the delays required by WARP and find when gzrf1a can start */
        pos_start = (int)(IMax( 2, !vstrte_flag*(48us + pw_gzrf1a), gz_start_temp ) - pw_gzrf1a);
      
        if(vstrte_flag && isIceHardware() && (is3TSystemType() || is15TSystemType()))
        {
            pos_start =  lead_deadtime + z_td0_time +
                RUP_GRD((INT)IMax(2,pw_gzrf1a,
                            rfFrequencyPacketLength() +
                            rfupacv - psd_rf_wait) - pw_gzrf1a);

        }
        if (vstrte_flag && (PSD_XRMW_COIL == cfgcoiltype) && (!is15TSystemType()))
        {
            pos_start =  lead_deadtime + z_td0_time + rfFrequencyPacketLength()+8;

        }
    }

    /* FIESTA2D - Determine location of Z killer */
    if( feature_flag & FIESTA ) {
        if( gzk_b4_gzrf1 ) {
            /* Place Z killer before the slice select gradient */
            pos_start += gzktime;
        }
        /* For killer at end put a gz1 spacer to make the z grad symmetric */
        gz1_spacer = 0;
    } else {
        gz1_spacer = 0;
    }

    /* Round-up pos_start after using it for gz1_spacer */
    pos_start = RUP_GRD(pos_start);

    if ( touch_flag ) 
    {
        touch_xdir = ((optouchax & 1)!=0);
	touch_ydir = ((optouchax & 2)!=0); 
	touch_zdir = ((optouchax & 4)!=0); 
         
	/* derate to lowest gradient parameters so all gradients have same response */
	touch_target = FMin(3, loggrd.tx, loggrd.ty, loggrd.tz);
	touch_rt = IMin(3, loggrd.opt.xrt, loggrd.opt.yrt, loggrd.opt.zrt);

	/****************************
		get touch values
	*****************************/
	touch_fcomp = (0==opfcomp) ? 0 : 2;
	touch_gnum = 1;
        /* ZZ, hard-coded MEG amplitude*/
        /* derating gradient strength to reduce artifacts in phase image */
	touch_gamp = 1.76;
	touch_gdrate = touch_gamp/touch_target;
	touch_pwramp = IMax(2, GRAD_UPDATE_TIME, RUP_GRD((int)(touch_rt*touch_gdrate)));
	if (2==touch_fcomp)
        {
            touch_pwramp = 2*touch_pwramp;
        }
	touch_period = RUP_GRD((int)(1.0s/optouchfreq));
	if (2==touch_fcomp) 
        {
            touch_period = 4*GRAD_UPDATE_TIME*(touch_period/(4*GRAD_UPDATE_TIME));
	}
        else
        {
            touch_period = 2*GRAD_UPDATE_TIME*(touch_period/(2*GRAD_UPDATE_TIME));
	}
	touch_delta = touch_period/optouchtphases;
	touch_pwcon = (touch_period/2)-2*touch_pwramp;
	if ( touch_pwcon<2*GRAD_UPDATE_TIME ) 
        {
            /* for high frequencies, find max amplitude */
            int high_rise;
            high_rise = touch_rt;
            touch_pwramp = RDN_GRD((touch_period - 2*GRAD_UPDATE_TIME)/4);
            if (touch_fcomp==2)
            {
                touch_pwramp = 2*touch_pwramp;
            }
            touch_gamp = touch_pwramp*1./high_rise;
            touch_pwcon = 2*GRAD_UPDATE_TIME;
	}
	touch_period = 2*(touch_pwcon + 2*touch_pwramp);
	touch_act_freq = 1.0s/touch_period;
	touch_lobe = touch_period/2;
	touch_ndir = 2;

        touch_burst_count = exist(optouchcyc);
        touch_tr_time = RUP_GRD(touch_burst_count*touch_period);

        touch_driver_amp = optouchamp; /*Resoundant driver amp in percentage, max amp is 2.5V peak-peak*/

	time_ssi = 500;

	touch_time = 2*touch_gnum*touch_lobe;
	if (1==touch_fcomp)
        {
            touch_time += touch_lobe;
        }

	pw_ssp_touch_sync = 2*GRAD_UPDATE_TIME + (optouchtphases-1.)*touch_delta;
    }  

    /******************************************************************
     *  Minimum sequence time calculation based on Y and Z gradients  *
     ******************************************************************/
    /* Calculate minimum time from mid 90 to end of refocus based on slice
       select axis */
    /* t_exb accounts for fract rf */
    /* MRIge38985 */
    /* RTIA, RJF */
    if ( (flow_comp_type == TYPFC) && (!(feature_flag & RTIA98 ))  ) {
        /* End, RTIA */
        min_seq1 = t_exb + pw_gzrf1d + pw_gz1a + pw_gz1 + pw_gz1d + pw_gzfca +
            pw_gzfc + pw_gzfcd + read_shift * pw_gxwa;
    } else {
        min_seq1 = t_exb + pw_gzrf1d +  gz1_spacer + pw_gz1a + pw_gz1 +
            pw_gz1d + read_shift * pw_gxwa;
    }

     if(gradspec_flag) min_seq1 += (pw_gx1a + pw_gx1 + pw_gx1d);

    /* Calculate minimum time from mid 90 to end of gy1 on phase
       encoding axis */
    /* t_exb accounts for fract rf */
    min_seq3 = RUP_GRD(t_exb + pw_gy1_tot) + grdrs_offset;

    if(gradspec_flag) min_seq3 += (pw_gzrf1d + pw_gz1a + pw_gz1 + pw_gz1d);


    /***************************************************************
     *  Determine full or fractional echo                          *
     *  also determine readout gradient amplitude and pulse width  *
     ***************************************************************/

    /* first calculate the timing for full echo case */
    xres = exist(opxres);
    fnecho_lim   = 1;
    fecho_factor = 1;

    /*
     * LxMGD - New filter calculation module. 
     * Refer to LxMGD Filter and Dacq Initialization and set up SDD 
     * for details - RJF 7/2/2001
     */
    if( calcfilter( &echo1_rtfilt, (DOUBLE)(exist(oprbw)),
                    perfusion_flag?opxres:exist(opxres), OVERWRITE_NONE ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 1,
                    STRING_ARG, "calcfilter" );
        return FAILURE;
    }

    echo1_filt = &echo1_rtfilt;

    /* JAP ET */
    /* pw_gxw_full does not include wings, pw_gxwl and pw_gxwr */
    tmp_rupgrd = echo1_filt->tdaq;
    pw_gxw_full = RUP_GRD(tmp_rupgrd);
    pw_gxw = pw_gxw_full;
    pw_gxlwr = pw_gxw_full;    /* pw_gxlwr does not include the wings at this point */

    /* record the bandwidth in CV for RSP */
    echo1bw = echo1_filt->bw;
    /* Add for second echo DUALECHO ALP */
    echo2bw = echo1bw;

    /* if 64Khz rbw, increase fov and chop off */
@inline loadrheader.e rheadereval

    if(vstrte_flag && isStarterSystem())
    {
        rhfreqscale = 1.15;
    }

    /* RTIA changes exist(opfov) to psd_fov */
    if ( ampfov(&a_gxw, echo1bw, (float) rhfreqscale*psd_fov) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "ampfov" );
        return FAILURE;
    }

    tsp = echo1_filt->tsp;

    /* ASSET */
    if( et_cveval( nop * exist(opphasefov) * psd_fov * asset_factor,
                   &(echo1_filt->outputs),
                   rhnframes + temp_rhhnover, etl, 
                   gxw_pulse, tsp,
                   read_shift, &xtr_offset, &pw_gxwl,
                   &pw_gxwr, &pw_gxwad, &gxktime,
                   &rspqueue_size, &et_ssp_time, &rs_offset,
                   feature_flag ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "et_cveval" );
        return FAILURE;
    }

    /* MRIge89250 - Update data acquition location */
    pw_gxwl += RDN_GRD(pw_gxwlex);

    /* For ramp-sampling pw_gxw is set in et_cveval. Makes sure that
       pw_gxw_full reflects this change. */
    if (feature_flag & ECHOTRAIN) {
        pw_gxwa_full = pw_gxwa;
        pw_gxwd_full = pw_gxwd;
        pw_gxw_full = *(gxw_pulse->pw); /* pw_gxw; MRIge55778 rampsamp timing correction */
        pw_gxwa_frac = pw_gxwa;
        pw_gxwd_frac = pw_gxwd;
        pw_gxw_frac = pw_gxw;
    }
    if (rs_offset > 0) {
        grdrs_offset = RUP_GRD(rs_offset);
    }
         
    gx1_pulse->num = 1;
    gxw_pulse->num = 1;

    /* Dual echo, DUALECHO ALP */
    /* MRIge68828 - missing code after 852 merge */ 
    gxw2_pulse->num = opnecho - 1;
    /* HCSDM00247289 : set gx2 based on pos_read */
    gx2_pulse->num = (pos_read) ? (opnecho - 1) : 0;
    
    if (touch_flag) 
    {
        gating = TRIG_INTERN;

        a_gxtouchu = touch_gamp;
        pw_gxtouchu  = touch_pwcon;
        pw_gxtouchud = touch_pwramp;
        pw_gxtouchua = touch_pwramp;

        a_gytouchu = touch_gamp;
        pw_gytouchu  = touch_pwcon;
        pw_gytouchud = touch_pwramp;
        pw_gytouchua = touch_pwramp;

        a_gztouchu = touch_gamp;
        pw_gztouchu  = touch_pwcon;
        pw_gztouchud = touch_pwramp;
        pw_gztouchua = touch_pwramp;

        a_gxtouchd = -touch_gamp;
        pw_gxtouchd  = touch_pwcon;
        pw_gxtouchdd = touch_pwramp;
        pw_gxtouchda = touch_pwramp;

        a_gytouchd = -touch_gamp;
        pw_gytouchd  = touch_pwcon;
        pw_gytouchdd = touch_pwramp;
        pw_gytouchda = touch_pwramp;

        a_gztouchd = -touch_gamp;
        pw_gztouchd  = touch_pwcon;
        pw_gztouchdd = touch_pwramp;
        pw_gztouchda = touch_pwramp;

        gxtouchu_pulse->num = (touch_xdir)?touch_gnum:0;
        gxtouchd_pulse->num = (touch_xdir)?touch_gnum:0;
        gytouchu_pulse->num = (touch_ydir)?touch_gnum:0;
        gytouchd_pulse->num = (touch_ydir)?touch_gnum:0;
        gztouchu_pulse->num = (touch_zdir)?touch_gnum:0;
        gztouchd_pulse->num = (touch_zdir)?touch_gnum:0;        

        if (1==touch_fcomp)
        {
            a_gxtouchf = touch_gamp/2;
            pw_gxtouchf  = touch_pwcon;
            pw_gxtouchfd = touch_pwramp;
            pw_gxtouchfa = touch_pwramp;
            gxtouchf_pulse->num = (touch_xdir)?touch_gnum:0;

            a_gytouchf = touch_gamp/2;
            pw_gytouchf  = touch_pwcon;
            pw_gytouchfd = touch_pwramp;
            pw_gytouchfa = touch_pwramp;
            gytouchf_pulse->num = (touch_ydir)?touch_gnum:0;

            a_gztouchf = touch_gamp/2;
            pw_gztouchf  = touch_pwcon;
            pw_gztouchfd = touch_pwramp;
            pw_gztouchfa = touch_pwramp;
            gytouchf_pulse->num = (touch_zdir)?touch_gnum:0;
        }
        else if (2==touch_fcomp)
        {
            a_gxtouchf = touch_gamp;
            pw_gxtouchf  = touch_pwcon/2;
            pw_gxtouchfd = touch_pwramp/2;
            pw_gxtouchfa = touch_pwramp/2;
            gxtouchf_pulse->num = (touch_xdir)?(2*touch_gnum):0;

            a_gytouchf = touch_gamp;
            pw_gytouchf  = touch_pwcon/2;
            pw_gytouchfd = touch_pwramp/2;
            pw_gytouchfa = touch_pwramp/2;
            gytouchf_pulse->num = (touch_ydir)?(2*touch_gnum):0;

            a_gztouchf = touch_gamp;
            pw_gztouchf  = touch_pwcon/2;
            pw_gztouchfd = touch_pwramp/2;
            pw_gztouchfa = touch_pwramp/2;
            gztouchf_pulse->num = (touch_zdir)?(2*touch_gnum):0;
        }
    }

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        backup_loggrd_tx_xyz  = loggrd.tx_xyz;
        backup_loggrd_ty_xyz  = loggrd.ty_xyz;
        backup_loggrd_tz_xyz  = loggrd.tz_xyz;
        backup_loggrd_opt_xrt = xrt;
        backup_loggrd_opt_yrt = yrt;
        backup_loggrd_opt_zrt = zrt;

        loggrd.tx_xyz = backup_loggrd_tx_xyz * ogsfX1;
        loggrd.ty_xyz = backup_loggrd_ty_xyz * ogsfY;
        loggrd.tz_xyz = backup_loggrd_tz_xyz * ogsfZ;
        xrt           = RUP_GRD((ceil)(backup_loggrd_opt_xrt * ogsfX1));
        yrt           = RUP_GRD((ceil)(backup_loggrd_opt_yrt * ogsfY));
        zrt           = RUP_GRD((ceil)(backup_loggrd_opt_zrt * ogsfZ));
    }
    
    /* RTIA changes flowcomp flag */
    mintefgre( &min_tenfe,
               &t_rd1a_full, &t_rdb_full, &tfe_extra,
               &pw_gxwa_full, &pw_gxwd_full,
               &a_gx1_full, &pw_gx1a_full, &pw_gx1_full, &pw_gx1d_full,
               &a_gxfc_full, &pw_gxfca_full, &pw_gxfc_full, &pw_gxfcd_full,
               fecho_factor, pw_gxwl, pw_gxw_full, pw_gxwr,
               a_gxw, t_exb, (flow_comp_type && (!(feature_flag & RTIA98))),
               min_seq1, min_seq3 );

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        loggrd.tx_xyz = backup_loggrd_tx_xyz;
        loggrd.ty_xyz = backup_loggrd_ty_xyz;
        loggrd.tz_xyz = backup_loggrd_tz_xyz;
        xrt           = backup_loggrd_opt_xrt;
        yrt           = backup_loggrd_opt_yrt;
        zrt           = backup_loggrd_opt_zrt;
    }

    /* End RTIA */
    /* now calculate the timing for fractional echo case */
    /* changed SHORT to INT - Vinod */
    calc_xresfn(&xres_frac, &fnecho_lim_frac, perfusion_flag?(INT)(opxres):(INT)(exist(opxres)));

    /************************************
     *  FastcardPC feature              *
     *                                  *
     *  overrides fractional echo xres  *
     ************************************/
    /* changed SHORT to INT - Vinod */
    calc_pc_fecho(&xres_frac, &fnecho_lim_frac, opxres, oppseq, feature_flag);

    fecho_factor = fnecho_lim_frac;

    if( calcfilter( &echo1_rtfilt_frac, (DOUBLE)(exist(oprbw)), xres_frac,
                    OVERWRITE_OPRBW ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 1,
                    STRING_ARG, "calcfilter" );
        return FAILURE;
    }

    echo1_filt = &echo1_rtfilt_frac;
    /* JAP ET */
    /* pw_gxw_frac does not include wings, pw_gxwl and pw_gxwr */
    tmp_rupgrd = echo1_filt->tdaq;
    pw_gxw_frac = RUP_GRD(tmp_rupgrd);

    /* Override RBW if it is out of range */
    if( oprbw < avminrbw ) {
        cvoverride(oprbw, avminrbw, existcv(oprbw), PSD_FIX_ON);
    }
    if( oprbw > avmaxrbw ) {
        cvoverride(oprbw, avmaxrbw, existcv(oprbw), PSD_FIX_ON);
    }

    /* min, max rbw use advisory panel popup */
    if( (existcv(oprbw)) && (exist(oprbw) < avminrbw) ) {
        epic_error( use_ermes, "The minimum bandwidth is %4.2f KHz.",
                    EM_PSD_MIN_RBW, 1, FLOAT_ARG, avminrbw );
        return ADVISORY_FAILURE;
    }

    /* avmaxrbw is changed in RTIA_cveval_init() for RTIA
       RTIA restricts RBW to 62.5. This is because, with the 
       worst case oblique assumptions, we wouldn't be able to 
       get to a reasonable FOV with a higher bw - RJF */
    if ( existcv(oprbw) && (exist(oprbw) > avmaxrbw) ) {
        epic_error( use_ermes, "The maximum bandwidth is %4.2f KHz.",
                    EM_PSD_MAX_RBW, 1, FLOAT_ARG, avmaxrbw );
        return ADVISORY_FAILURE;
    }

    /* Fixed MRIge44291 */
    /* Calculate minimum FOV based on relationship FOV = 2 oprbw / (GAM
       Gx). The scaling factor of 2000 converts kHz to Hz and Nyquist
       frequency to sampling frequency. The final scaling by 10.0
       converts the units for fov from cm to mm */

    /* Begin RTIA */
    minfovcm = (2000.0 * exist(oprbw)) / (GAM * gxwtarget) ;
    if (feature_flag & RTIA98) {
        minfovcm /= RTIA_FOV_ZOOM_FACTOR;
    }
    avminfov =  10.0 * ceil(minfovcm);
    /* MRIge92503 - For Dual echo, minimum FOV will be set to the be proportional to the minimum
       rBW rather than oprbw. */
    if( (exist(opnecho) == 2) && !(feature_flag & MFGRE) && !r2_flag && ((cffield == B0_30000) || (cffield == B0_15000)) ) {
       avminfov = 10.0 * ceil((2000.0 * dualecho_llimrbw) / (GAM * gxwtarget));
    }

     if(gradspec_flag)
     {   /* round to mm */
          avminfov =  ceil(minfovcm*10.0);
     }

    /* As per RTIA SRS, FOV's less than 12 cm attainable
       with low bandwidths are not very useful clinically.
       Lock them out. RJF, MRIge51643*/

    if ( (feature_flag & RTIA98 ) && avminfov < 120 ) {
        avminfov = 120;
    }
    /* End RTIA */

    /* Rounded up to the nearest 10mm. */
    avminfov = FMax(2, avminfov, (FLOAT)FOV_MIN);
    /* ASSET */ /*MRIhc01451*/
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        if(value_system_flag) { /* YMSmr07308  07/19/2005 YI */
            avminfov = FMax(2, avminfov, 
                            (FLOAT)(coilInfo[0].assetCalMaxFov/4));
        } else {
            avminfov = coilInfo[0].assetCalMaxFov;
        }
        avmaxfov = coilInfo[0].assetCalMaxFov;
        cvdef(opfov, coilInfo[0].assetCalMaxFov); 
        opfov = coilInfo[0].assetCalMaxFov;
    } 

    /* MRIhc18622 Round avminfov to the nearest 10 mm (in inline file) */
@inline Asset.e AssetMinFOV

    /* MRIge80365, MRIge74549 */
    av_temp_float = (20000.0 *  avmaxrbw) / (GAM * gxwtarget);
    av_temp_int = 0;
    while(av_temp_float > avmaxfov){
        avmaxrbw = (maxhwrbw/(1.0+0.25*av_temp_int));
        if (SUCCESS != calcvalidrbw(avmaxrbw, &valid_rbw, &valid_max_rbw, &valid_decimation,OVERWRITE_NONE, 0)) {
            return FAILURE;
        }
        avmaxrbw = valid_rbw;
        av_temp_float =  (20000.0 *  avmaxrbw) / (GAM * gxwtarget);
        av_temp_int++;
    }
    avmaxrbw2 = avmaxrbw;

    if( oprbw > avmaxrbw ) {
        cvoverride(oprbw, avmaxrbw, existcv(oprbw), PSD_FIX_ON);
    }

    if ((exist(oprbw) > avmaxrbw) && existcv(oprbw)) {
        epic_error(use_ermes,"The maximum bandwidth is %4.2f KHz.",
                   EM_PSD_MAX_RBW,EE_ARGS(1),FLOAT_ARG,avmaxrbw);
        return ADVISORY_FAILURE;
    }

    /* Set meaningful values for the FOV pulldown menu */
    {
        const float FOV_INC = (floor((avmaxfov - avminfov) / 50))*10;
        pifovval2 = avminfov;
        pifovval3 = pifovval2 + FOV_INC;
        pifovval4 = pifovval3 + FOV_INC;
        pifovval5 = pifovval4 + FOV_INC;
        pifovval6 = avmaxfov;
    }

    /* MRIge92503 - tailored FOV pull-down menu to most often used FOV for dual echo */
    if( (exist(opnecho) == 2) && !(feature_flag & MFGRE) && !r2_flag && ((cffield == B0_30000) || (cffield == B0_15000)) ) {
        float temp_fov;
        if (avmaxfov < 260.0) {
           temp_fov = avminfov;
        } else {
           temp_fov = FMax(2, avminfov, 260.0);
        }
	const float FOV_INC = (floor((avmaxfov - temp_fov) / 50))*10;
        pifovval2 = temp_fov;
        pifovval3 = pifovval2 + FOV_INC;
        pifovval4 = pifovval3 + FOV_INC;
        pifovval5 = pifovval4 + FOV_INC;
        pifovval6 = avmaxfov;
    }
    
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        pifovnub = 2;
        pifovval2 = coilInfo[0].assetCalMaxFov; 
    }

    minfov_error = 0;  /* YMSmr08456  02/16/2006 YI */
    /* MRIge59754 Copy this from cvcheck to here to avoid
       pulsegen failure */
    /* fov < minimum uses advisory panel popup - JDM */  
    /* MRIge92430: Do not check for min. FOV in auto-rBW calculation; do so only after the
       calculation loop. */
    /* MRIge92503: Added separate error message for 1.5T and 3.0T dual echo since rBW can not
       be changed by user. */
    if( existcv(opfov) && (exist(opfov) < avminfov) && (minfovcheck_flag == PSD_ON) ) {
        minfov_error = 1;  /* YMSmr08456  02/16/2006 YI   Moved returning ADVISORY_FAILURE to cvcheck. */
    }
  
    /* fov > maximum uses advisory panel popup - JDM */
    /* Aug. 9, 2001 (DG):
       check is done for any gradient in Gemini - if not service protocol */
    if( ( (cfgcoiltype == PSD_TRM_COIL) && (existcv(opgradmode)) && strcmp(get_psd_name(),"fgrespt") ) ||
        (existcv(opgradmode) == 0) ) {
        if( existcv(opfov) && (exist(opfov) > avmaxfov) ) {
            /* ASSET */
            if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
                epic_error( use_ermes, "The only valid FOV with this prescription is %3.1f cm.", 
                            EM_PSD_EPI_FOV_ERROR_TEXT, EE_ARGS(1), FLOAT_ARG, avmaxfov / 10.0 );
            } else {
                epic_error( use_ermes, "Maximum FOV is %-f",  EM_PSD_FOV_OUT_OF_RANGE2,
                            EE_ARGS(1), FLOAT_ARG, avmaxfov / 10.0 );
            }
            return ADVISORY_FAILURE;
        }
    }

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        backup_loggrd_tx_xyz  = loggrd.tx_xyz;
        backup_loggrd_ty_xyz  = loggrd.ty_xyz;
        backup_loggrd_tz_xyz  = loggrd.tz_xyz;
        backup_loggrd_opt_xrt = xrt;
        backup_loggrd_opt_yrt = yrt;
        backup_loggrd_opt_zrt = zrt;

        loggrd.tx_xyz = backup_loggrd_tx_xyz * ogsfX1;
        loggrd.ty_xyz = backup_loggrd_ty_xyz * ogsfY;
        loggrd.tz_xyz = backup_loggrd_tz_xyz * ogsfZ;
        xrt           = RUP_GRD((ceil)(backup_loggrd_opt_xrt * ogsfX1));
        yrt           = RUP_GRD((ceil)(backup_loggrd_opt_yrt * ogsfY));
        zrt           = RUP_GRD((ceil)(backup_loggrd_opt_zrt * ogsfZ));
    }

    /* RTIA changes flowcomp flag */
    mintefgre( &min_tefe, &t_rd1a_frac, &t_rdb_frac, &tfe_extra, &pw_gxwa_frac,
               &pw_gxwd_frac, &a_gx1_frac, &pw_gx1a_frac, &pw_gx1_frac,
               &pw_gx1d_frac, &a_gxfc_frac, &pw_gxfca_frac, &pw_gxfc_frac,
               &pw_gxfcd_frac, fecho_factor, pw_gxwl, pw_gxw_frac, pw_gxwr,
               a_gxw, t_exb, (flow_comp_type && (! (feature_flag & RTIA98)  )),
               min_seq1, min_seq3 );
    /* End, RTIA */

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        loggrd.tx_xyz = backup_loggrd_tx_xyz;
        loggrd.ty_xyz = backup_loggrd_ty_xyz;
        loggrd.tz_xyz = backup_loggrd_tz_xyz;
        xrt           = backup_loggrd_opt_xrt;
        yrt           = backup_loggrd_opt_yrt;
        zrt           = backup_loggrd_opt_zrt;
    }

    /*  For ET calculate TE based on the acquisition order. */
    if ( feature_flag & ECHOTRAIN ) {
        extern int ky_dir;
        extern int n_vus;
        extern int eshift;
        extern int esp;

        if ( ky_dir == PSD_TOP_DOWN ) {
            min_tenfe = min_tenfe + (n_vus - 1) * esp;
            if ( eshift == PSD_ON ) {
                min_tenfe += pw_gxwl + pw_gxw / 2;
            }
        }
    }

    /********************************
     *  Water, fat in/out-of phase  *
     *********************************/
    fullte_flag = PSD_OFF;   /* always start with frac. echo */
    switch ( exist(opautote) ) {
    case PSD_FWINPHS:
    case PSD_FWOUTPHS:
        /* System Dependency library (FEC) */
        SDL_SetLimTE( SD_PSD_FGRE, cffield, exist(opautote),
                      &llimte1, &llimte2, &llimte3,        
                      &ulimte1, &ulimte2, &ulimte3 );
        fwphase( &act_te, &fullte_flag, min_tefe, min_tenfe,
                 llimte1, llimte2, llimte3, ulimte1, ulimte2, ulimte3 );
        break;

    case PSD_MINTE:
        /* min fractional te */
        fullte_flag = PSD_OFF;   /* frac. echo */
        act_te = min_tefe;
        break;

    case PSD_MINTEFULL:
        /* min full te */
        fullte_flag = PSD_ON;   /* full echo */
        act_te = min_tenfe;
        break;

    default:
        /* MRIge34216 - For popup, if opautote passed as 0 and act_te
           is still 0 then opte becomes zero. Since opautote msg is
           first caught in cveval, and oweing to the fact that the
           popup cannot compute a solution, we must ensure that we
           don't generate any other errors. This is a problem because
           for opautote scan always sends a value of 0. This, at present,
           is merely a workaround and scan should fix the true underlying
           problem. */
        /* Initialize act_te to something meaningful other than zero */
        act_te = _opte.defval;
        break;
    }

    /* MRIge57023 - If user enters a TE value make sure to set the TE
       flags correctly */
    if( existcv(opautote) && (PSD_OFF == exist(opautote)) && existcv(opte) ) {
        if( (exist(opte) > min_tefe) && (exist(opte) < min_tenfe) ) {
            fullte_flag = PSD_OFF;
        } else {
            fullte_flag = PSD_ON;   /* full echo */
        }
    }
    

    /*********************************************
     *  Determine xres and frac echo parameters  *
     *********************************************/
    if ( fullte_flag == PSD_ON ) {
        /* full echo */
        t_rdb   = t_rdb_full;
        t_rd1a  = t_rd1a_full;
        pw_gx1  = pw_gx1_full;
        pw_gx1a = pw_gx1a_full;
        pw_gx1d = pw_gx1d_full;
        a_gx1   = a_gx1_full;
        /* RTIA, RJF */
        if ( (flow_comp_type==TYPFC) && (! (feature_flag & RTIA98) )) {
            /* End, RTIA */
            pw_gxfc  = pw_gxfc_full;
            pw_gxfca = pw_gxfca_full;
            pw_gxfcd = pw_gxfcd_full;
            a_gxfc   = a_gxfc_full;
        }
        xres         = exist(opxres);
        fnecho_lim   = 1;
        fecho_factor = 1;
        tfe_extra    = 0;
        pw_gxw       = pw_gxw_full;
        /* JAP ET */
        pw_gxlwr     = pw_gxwl + pw_gxw_full + pw_gxwr; /* pw_gxlwr now includes the wings */
        pw_gxwa      = pw_gxwa_full;
        pw_gxwd      = pw_gxwd_full;

        echo1_filt   = &echo1_rtfilt;
    } else {
        /* fractional echo */
        t_rdb   = t_rdb_frac; 
        t_rd1a  = t_rd1a_frac;
        pw_gx1  = pw_gx1_frac;
        pw_gx1a = pw_gx1a_frac;
        pw_gx1d = pw_gx1d_frac;
        a_gx1   = a_gx1_frac;
        /* RTIA, RJF */
        if ( (flow_comp_type==TYPFC) && (!(feature_flag & RTIA98))) {
            /* End RTIA */
            pw_gxfc  = pw_gxfc_frac;
            pw_gxfca = pw_gxfca_frac;
            pw_gxfcd = pw_gxfcd_frac;
            a_gxfc   = a_gxfc_frac;
        }
        pw_gxw       = pw_gxw_frac;
        /* JAP ET */
        pw_gxlwr     = pw_gxwl + pw_gxw_frac + pw_gxwr;  /* pw_gxlwr now includes the wings */
        pw_gxwa      = pw_gxwa_frac;
        pw_gxwd      = pw_gxwd_frac;
        xres         = xres_frac;
        fnecho_lim   = fnecho_lim_frac;
        if(vstrte_flag && isStarterSystem())
        {
            cvoverride(fecho_factor, 0.5, PSD_FIX_ON, PSD_EXIST_ON);
        }
        else
        {
            fecho_factor = fnecho_lim;
        }
        echo1_filt   = &echo1_rtfilt_frac;
    }

    /* Divide by 0 protection */

    if ((echo1_filt->tdaq == 0) || floatsAlmostEqualEpsilons(echo1_filt->decimation, 0.0, 2)) 
    {
        epic_error( use_ermes, "echo1 tdaq or decimation = 0",
                    EM_PSD_BAD_FILTER, EE_ARGS(0) );
        return FAILURE;
    }


    /**********************************
     *  Set default number of echoes  *
     **********************************/
    /*************************************************************
     *  Setup minimum TE calculation for Phase Contrast Feature  *
     *************************************************************/
    /* Check for the return value - LX2 */

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        backup_loggrd_tx_xyz  = loggrd.tx_xyz;
        backup_loggrd_ty_xyz  = loggrd.ty_xyz;
        backup_loggrd_tz_xyz  = loggrd.tz_xyz;
        backup_loggrd_opt_xrt = loggrd.opt.xrt;
        backup_loggrd_opt_yrt = loggrd.opt.yrt;
        backup_loggrd_opt_zrt = loggrd.opt.zrt;

        loggrd.tx_xyz  = backup_loggrd_tx_xyz * ogsfX1;
        loggrd.ty_xyz  = backup_loggrd_ty_xyz * ogsfY;
        loggrd.tz_xyz  = backup_loggrd_tz_xyz * ogsfZ;
        loggrd.opt.xrt = RUP_GRD((ceil)(backup_loggrd_opt_xrt * ogsfX1));
        loggrd.opt.yrt = RUP_GRD((ceil)(backup_loggrd_opt_yrt * ogsfY));
        loggrd.opt.zrt = RUP_GRD((ceil)(backup_loggrd_opt_zrt * ogsfZ));
    }

    if (mintefgrePC( &act_te, &t_rd1a, &t_rdb, &tfe_extra, fullte_flag,
                     pw_gxwa, pw_gxwd, &a_gx1, &pw_gx1a, &pw_gx1, &pw_gx1d,
                     &a_gxfc, &pw_gxfca, &pw_gxfc, &pw_gxfcd,
                     pw_gxwl, pw_gxw, pw_gxwr, a_gxw,
                     &pw_gyfe1, &pw_gyfe1a, &pw_gyfe1d,
                     &pw_gyfe2, &pw_gyfe2a, &pw_gyfe2d,
                     &a_gyfe1, &a_gyfe2,
                     &pw_gz1, &pw_gz1a, &pw_gz1d,
                     &pw_gzfc, &pw_gzfca, &pw_gzfcd,
                     &a_gz1, &a_gzfc, pw_gzrf1d, a_gzrf1, t_exb,
                     &pw_gy1_tot, &yfe_time,
                     pw_gy1, pw_gy1a, pw_gy1d,
                     oppseq, exist(opfcomp), feature_flag) == FAILURE) {
        /* Don't fill in the error structure here, to allow the error
           message from the lower routine show up on the screen. - RJF */
        return FAILURE;
    }

    /* GEHmr02638: smart derating */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
        loggrd.tx_xyz  = backup_loggrd_tx_xyz;
        loggrd.ty_xyz  = backup_loggrd_ty_xyz;
        loggrd.tz_xyz  = backup_loggrd_tz_xyz;
        loggrd.opt.xrt = backup_loggrd_opt_xrt;
        loggrd.opt.yrt = backup_loggrd_opt_yrt;
        loggrd.opt.zrt = backup_loggrd_opt_zrt;
    }

    pitfeextra = tfe_extra;

    /****** extra x crusher time to dephase s- signal ***/

    /* limit maximum area of xkiller */
    if( feature_flag & FIESTA ) {
        if( PSD_ON == fullte_flag ) {
            area_gxwex = -1.0 * ((FLOAT)(pw_gxwd / 2) + (FLOAT)t_rdb) * a_gxw;
        } else {
            float area_fiesta_fnecho_gxwL;
            float area_fiesta_total_gxw;

            area_fiesta_total_gxw = (float)(pw_gxwa + pw_gxw) * a_gxw;
            area_fiesta_fnecho_gxwL = (float)(pw_gx1a + pw_gx1) * a_gx1;
            area_gxwex = -(area_fiesta_total_gxw + area_fiesta_fnecho_gxwL);
        }
    } else {
        /* SVBranch HCSDM00178991: increase max_area_gxwex to 3000 to weaken MERGE's fineline artifact */
        if( (isValueSystem()) &&
            (feature_flag & MERGE) )
        {
            max_area_gxwex = 3000.0;
        }
        else
        {
            max_area_gxwex = 400.0;
        }

        area_gxwex = FMin( 2,
                           max_area_gxwex,
                           (FLOAT)(pw_gxwa / 2 + t_rd1a) * fabs(a_gxw) );
        /* MRIhc09984: Increased Crusher area for SPGR when TR greater or
         * equal to 100ms and flip greater than or equal to 50. This was done
         * to better crush residual magnitization. */
        /* HCSDM00241267 : dual echo requires increased spoiling for residual magnetization */
        /* For 1.5T dualecho_inflow_reduce required increased spoiling for residual magnetization */
         if( ((existcv(oppseq) && exist(oppseq) == PSD_SPGR ) &&
             (existcv(optr) && exist(optr) >= 100ms) && 
             (existcv(opflip) && exist(opflip) >= 50.0)) ||
             (dualecho_minTE) || (PSD_ON == dualecho_inflow_reduce) )
         {
             area_gxwex = 4 * area_gxwex;
         }

        /*HCSDM00095097 : retain HD16 crusher areas for HD ASSET*/	 
        if ( ( (cfgcoiltype == PSD_60_CM_COIL) || (cfgcoiltype == PSD_TRM_COIL) ) 
		&& (!value_system_flag) 
		&& ( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) )
	{
	    HD_ASSET_flag = PSD_ON;
	}
	else
	{
	    HD_ASSET_flag = PSD_OFF;
	}

         /* MRIhc54399 Increase Crusher in Z and X direction to remove the zipper artifact. This change only impact
            Base FGRE, SPGR and EchoTrain */
         /* SVBranch HCSDM00132376. For 16Beat system, do not set area_gxwex to 1600 if the protocol is for limit parameter check.
            if opslthick >= 100mm and opfov >= 48cm, the protocol is deemed to be for limit parameter check. */
        if( (feature_flag & MPL) && (1 == exist(opnecho)) &&
             existcv(oppseq) && ( (PSD_GE == exist(oppseq) ) || (PSD_SPGR == exist(oppseq)) )&&
             (PSD_OFF == exist(opcgate)) && (PSD_OFF == exist(oprealtime)) &&
	     (PSD_OFF == HD_ASSET_flag) )
        {
             if( (!isValueSystem()) || /*DV products*/ 
                 ((100>exist(opslthick)) || (480>exist(opfov))) ) /* Value product && it is not protocol for limit parameters check. */
             {
                 area_gxwex = 1600;
             }
        }
	else if (PSD_ON == HD_ASSET_flag) 
	{
            area_gxwex = 800;
	}

        if ((feature_flag & MERGE) && ((int)exist(opuser8)>0))
        {
            area_gxwex = 800;
        }
    }

    /* Set the target amplitude for the X crusher */
    if( feature_flag & FIESTA ) 
    {
        if( gzk_b4_gzrf1 )  
        {
            gxwex_target = loggrd.tx_xy;
            gxwex_2axis_3axis_flag = TWO_AXIS;
        }
        else        
        {
            gxwex_target = loggrd.tx_xyz;
            gxwex_2axis_3axis_flag = THREE_AXIS;
        }
    }
    else    
    {
        /* gxwex_2axis_3axis_flag is set where gxwtarget is set*/
        gxwex_target = 0.95 * gxwtarget;
    }

    /* YMSmr07885  10/12/2005 YI */
    if( (cfgradamp == 8919) || ( 5551 == cfgradamp) || (cfgradamp == 8905) || (cfgradamp == 8907) || ((int)(10000 * cfxfs / cfrmp2xfs)<70) ) {
        if( (feature_flag & FIESTA) && (exist(opplane) != PSD_OBL) ) {
            gxwex_target = FMin(2, acgd_lite_target, loggrd.tx_xy);
            derate_gxwex_factor = gxwex_target / loggrd.tx_xy;
            gxwex_2axis_3axis_flag = TWO_AXIS;
        } else {
            derate_gxwex_factor = 1.0;
        }
    } else {
        derate_gxwex_factor = 1.0;
    }

    /* SVBranch: let aTEopt_flag and aTRopt_flag work */
    if(gradOpt_flag || aTEopt_flag || aTRopt_flag)
    {
        gxwex_target = loggrd.tx_xyz;
        gxwex_2axis_3axis_flag = THREE_AXIS;
        derate_gxwex_factor = 1.0;
    }

    if(ONE_AXIS == gxwex_2axis_3axis_flag) 
    {
        gxwex_rise_time_scale_fac = 1.0;
    }
    else if(TWO_AXIS == gxwex_2axis_3axis_flag) 
    {
        gxwex_rise_time_scale_fac = loggrd.scale_2axis_risetime;
    }
    else if(THREE_AXIS == gxwex_2axis_3axis_flag) 
    {
        gxwex_rise_time_scale_fac = loggrd.scale_3axis_risetime;
    }

    /* Check if area required is greater than that available by
       stretching the readout gradient */
    if( bridge ) {


        if( area_gxwex <= (a_gxw * ((FLOAT)pw_gxwd / 2.0 +
                                    (FLOAT)(2 * GRAD_UPDATE_TIME))) ) {
            /*** MROR ***/
            /* MRIge30825 - Check if area of gxwd already is enough for
               area_gxwex. */
            a_gxwex   = a_gxw;
            pw_gxwexd = pw_gxwd;
            pw_gxwex  = GRAD_UPDATE_TIME;
            pw_gxwexa = GRAD_UPDATE_TIME;

            /* GEHmr02638: smart derating */
            gradOpt_noGxwex = PSD_ON;

            if( gradOpt_flag && (0 < gradOpt_gxwex) )
            {
                float tmp_area_gxwex, tmp_sr_gxwex;
                gradOpt_noGxwex = PSD_OFF;
                area_gxwex = (float)(pw_gxwex+pw_gxwexa+0.5*pw_gxwexd)*a_gxwex;
                tmp_sr_gxwex = (gxwex_target*ogsfXwex) / (RUP_GRD((ceil)(xrt * gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)));
                tmp_area_gxwex = (RUP_GRD((ceil)(a_gxw / tmp_sr_gxwex))) * 0.5 * a_gxw + gxwex_target * ogsfXwex * (MIN_PLATEAU_TIME+4);
                                               /* 4us is for margin */
                if(tmp_area_gxwex > area_gxwex)
                {
                    area_gxwex = tmp_area_gxwex;
                }
                if( FAILURE == amppwgradmethod( gxwex_pulse, area_gxwex,
                                                gxwex_target * ogsfXwex,
                                                a_gxw, 0.0,
                                                RUP_GRD((ceil)(xrt* gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)),
                                                MIN_PLATEAU_TIME ) )
                {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                                EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxwex");
                    return FAILURE;
                }
            }

            /*** End MROR ***/
        } else if( (area_gxwex < ((FLOAT)(IMax(2, pw_gy1r_tot, gzktime) - pw_gxwd) * a_gxw)) ||
                   floatsAlmostEqualEpsilons(a_gxw, gxwex_target, 2) ) 
        {
            INT rup_grd_tmp;

            a_gxwex   = a_gxw;
            pw_gxwexd = pw_gxwd;
            /* MRIge41294 - Don't allow values less than 4 usec for pw_gxwex
               - LX2 */
            rup_grd_tmp = (INT)((area_gxwex / a_gxwex) - (FLOAT)(pw_gxwexd / 2));
            pw_gxwex = IMax(2, 4, RUP_GRD(rup_grd_tmp));
            pw_gxwexa = GRAD_UPDATE_TIME;

            /* GEHmr02638: smart derating */
            gradOpt_noGxwex = PSD_ON;

            if( gradOpt_flag && (0 < gradOpt_gxwex) )
            {
                float tmp_area_gxwex, tmp_sr_gxwex;
                gradOpt_noGxwex = PSD_OFF;
                area_gxwex = (float)(pw_gxwex+pw_gxwexa+0.5*pw_gxwexd)*a_gxwex;
                tmp_sr_gxwex = (gxwex_target*ogsfXwex) / (RUP_GRD((ceil)(xrt * gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)));
                tmp_area_gxwex = (RUP_GRD((ceil)(a_gxw / tmp_sr_gxwex))) * 0.5 * a_gxw + gxwex_target * ogsfXwex * (MIN_PLATEAU_TIME+4);
                                               /* 4us is for margin */
                if(tmp_area_gxwex > area_gxwex)
                {
                    area_gxwex = tmp_area_gxwex;
                }
                if( FAILURE == amppwgradmethod( gxwex_pulse, area_gxwex,
                                                gxwex_target * ogsfXwex,
                                                a_gxw, 0.0,
                                                RUP_GRD((ceil)(xrt * gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)),
                                                MIN_PLATEAU_TIME ) )
                {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                                EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxwex");
                    return FAILURE;
                }
            }
        } else {
            float tmp_area_gxwex, tmp_sr_gxwex;
            /* GEHmr02638: smart derating */
            if(gradOpt_gxwex > 0)
            {
                gradOpt_noGxwex = PSD_OFF;
            }
            else
            {
                gradOpt_noGxwex = PSD_ON;
            }
            tmp_sr_gxwex = (gxwex_target*ogsfXwex) / (RUP_GRD((ceil)(xrt * gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)));
            tmp_area_gxwex = (RUP_GRD((ceil)(a_gxw / tmp_sr_gxwex))) * 0.5 * a_gxw + gxwex_target * ogsfXwex * (MIN_PLATEAU_TIME+4);
                                            /* 4us is for margin */
            if(tmp_area_gxwex > area_gxwex)
            {
                area_gxwex = tmp_area_gxwex;
            }

            if( FAILURE == amppwgradmethod( gxwex_pulse, area_gxwex,
                                            gxwex_target * ogsfXwex,
                                            a_gxw, 0.0,
                                            RUP_GRD((ceil)(xrt* gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)),
                                            MIN_PLATEAU_TIME ) )
            {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                            EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxwex");
                return FAILURE;
            }
        }
    } else {
        /* FIESTA2D - Make the refocus (gx1) and rewinder (gxwex)
           pulses symmetric for full echo cases */
        if( (feature_flag & FIESTA) && (PSD_ON == fullte_flag) ) {
            a_gxwex   = a_gx1;
            pw_gxwexd = pw_gx1d;
            pw_gxwex  = pw_gx1;
            pw_gxwexa = pw_gx1a;

            /* GEHmr02638: smart derating */
            gradOpt_noGxwex = PSD_ON;

            if( gradOpt_flag && (2 == gradOpt_gxwex) )
            {
                gradOpt_noGxwex = PSD_OFF;
                area_gxwex = (float)(0.5*pw_gxwexa+pw_gxwex+0.5*pw_gxwexd)*a_gxwex;
                if( FAILURE == amppwgradmethod( gxwex_pulse, area_gxwex,
                                                gxwex_target * ogsfXwex,
                                                a_gxw, 0.0,
                                                RUP_GRD((ceil)(xrt * gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)),
                                                MIN_PLATEAU_TIME ) )
                {
                    epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                                EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxwex");
                    return FAILURE;
                }
            }

        } else {
            /* GEHmr02638: smart derating */
            if(gradOpt_gxwex > 0)
            {
                gradOpt_noGxwex = PSD_OFF;
            }
            else
            {
                gradOpt_noGxwex = PSD_ON;
            }

            if( FAILURE == amppwgradmethod( gxwex_pulse, area_gxwex,
                                            gxwex_target * ogsfXwex,
                                            /* YMSmr07885  10/12/2005 YI
                                            0.0, 0.0, xrt,
                                            */
                                            0.0, 0.0,
                                            RUP_GRD((ceil)(xrt* gxwex_rise_time_scale_fac * ogsfXwex * derate_gxwex_factor)),
                                            MIN_PLATEAU_TIME ) ) {
                epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                            EE_ARGS(1), STRING_ARG, "amppwgradmethod:gxwex" );
                return FAILURE;
            }
        }
    }

    /* JAP ET */
    if( gxwex_on == PSD_OFF) {
        pw_gxwexa = GRAD_UPDATE_TIME;
        pw_gxwex  = GRAD_UPDATE_TIME;
        a_gxwex   = a_gxw;
        pw_gxwexd = pw_gxwd;
        pw_gxwd = pw_gxwa;
        gxwextime = 0;
        gxwex_pulse->num = 0;
    } else {
        if( bridge ) {
            pw_gxwd = pw_gxwexa;
            wg_gxwex = XGRADB;
        } else {
            if( feature_flag & FIESTA ) {
                pw_gxwd = pw_gxwa;
            }
            wg_gxwex = XGRAD;
        }
        gxwextime = pw_gxwexa + pw_gxwex + pw_gxwexd;
        gxwex_pulse->num = 1;
    }

    /********************************************/

    /* JAP ET */
    /* JAP Additional et_ssp_time is needed beyond minimum sequence
       time for echo shifting */
    {
        int temp_ntetime;
        int temp_max;
        int temp_gzktime;
        int unbridge_penalty;

        /* FIESTA2D - Check for location of Z killer gradient */
        if( feature_flag & FIESTA ) {
            if( gzk_b4_gzrf1 ) {
                temp_gzktime = 0;
            } else {
                temp_gzktime = gzktime;
            }
        } else {
            temp_gzktime = gzktime;
        }

        /* Set extra time if gxwex is NOT bridged, e.g., RTIA, FIESTA 2D */ 
        if( bridge ) {
            unbridge_penalty = 0;
        } else {
            unbridge_penalty = pw_gxwd;
        }
        
        /* Add psd_grd_wait to gradient timing. This ensures that the
           WARP reset that occurs at EOS does not cause the gradient
           amplifier to trip. It is subtracted from isi delay because
           it is added in again in the temp_ntetime.  */
        temp_max = IMax( 6, pw_gy1r_tot + grdrs_offset,
                         temp_gzktime + read_shift * pw_gxwd,
                         gxwextime + unbridge_penalty,
                         pw_gxwd + gxktime,
                         attenlength + tns_length + psd_grd_wait,
                         minisi_delay + isidelay - pw_gxw - psd_grd_wait);

        /* need to include pos_start here as the start of rf1 is at pos_start
           and not just td0 + tlead. Spatial and chem sat will be added as
           boffsets into separate modules so no need to consider it here */
        temp_ntetime = (pos_start + t_exa + t_rdb +
                        (etl - 1) * (pw_gxwa + pw_gxlwr + pw_gxwd) +
                        /* Additional time required for SSP */
                        seq_length + et_ssp_time + temp_max +
                        !(vstrte_flag || perfusion_flag)*psd_grd_wait + time_ssi);

        non_tetime = temp_ntetime;

        /* Begin RTIA */
        /* RTIA might want to know post_echo_time for annotating TI */
        post_echo_time = t_rdb + seq_length + temp_max + time_ssi;
        /* End RTIA */
    }

    /* DUALECHO - Calculate minimum TE */
    if( exist(opnecho) == 2 && !(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag ) {
        /* MRIge74073 - Force optimal fat/water out-of-phase TE for all
           cases of xres and field strengths */
        /* Choose lower TE (~2.1 ms) to get maximum slices although 
           TE may not be optimal */
        /* MRIge92350 - Removed 1.5T Dual Echo from the following check.  Similar check is added 
           a few lines down with "1.5T Dual Echo" label. */ 
        if( cffield < B0_15000 ) {
            int tmp_time = (int)((1000000.0 * (float)B0_15000 / (440.0 * cffield) ) + 0.5) - 100;

            if( tmp_time > act_te ) {
                act_te = tmp_time;
            }
        }
        /* MRIge91751 - For TE less than lower limit for first in-phase TE, 
           set it to the lower limit. */ 
        if( cffield == B0_30000 )
        {
            /* HCSDM00241267: TE1 limits for 1st out-of-phase echo */
            if (dualecho_minTE)
            {
                if (act_te < dualecho3t_llimteout1_min)
                    act_te = dualecho3t_llimteout1_min;
            }
            else
            {
                if (act_te < dualecho3t_llimtein1_mf)
                    act_te = dualecho3t_llimtein1_mf;
            }
        }
        /* MRIge92350 - 1.5T Dual Echo */
        if( cffield == B0_15000 ) {
            if (act_te < dualecho1p5t_llimteout1)
                act_te = dualecho1p5t_llimteout1;
        }
    }

    /* MRIge57023 - If user enters a TE value make sure to override any
       previously calculated act_te. */
    if( existcv(opautote) && (PSD_OFF == exist(opautote)) && existcv(opte) ) {
        act_te = exist(opte);
    }

    /* Don't round up te_time */
    te_time = act_te;
        
    /* DUALECHO - Calculate TE2 value assuming equal receiver bandwidth. */ 
    if( exist(opnecho) >= 2 || (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag ) {
        pw_gxw2 = pw_gxw;
        pw_gxw2a = pw_gxwa;
        pw_gxw2d = pw_gxwd;
        /* Set waveform amp to +ve - Instruction will be negated. */
        a_gxw2 = a_gxw;

        if(pos_read)
        {
            float target;

            area_gx2 = -a_gxw * ((pw_gxwa/2) + pw_gxw + (pw_gxwd/2));

            gettarget(&target, XGRAD,&loggrd);
            
            if (amppwgrad((float)(area_gx2),target*ogsfGX2, 0.0, 0.0, 
                              RUP_GRD((ceil)(xrt*ogsfGX2)), MIN_PLATEAU_TIME,
                              &a_gx2, &pw_gx2a, &pw_gx2, &pw_gx2d) == FAILURE)
            {
                return FAILURE;
            }
            ia_gx2  = (a_gx2/(target*ogsfGX2))*MAX_PG_IAMP;
            rewindertime = pw_gx2a + pw_gx2 + pw_gx2d; /* 0 or gx2 total */
        } else {
            rewindertime = 0;
        }

        /* Add a 50 us (fast_xtr_setlng) to account for the xtr offset 
           from rba (instead of default 130). Also make sure offset 
           set in Acquiredata call for 2nd echo MRIge72594 */
        act_te2 = act_te + t_rdb + IMax (2,  pw_gxwd + pw_gxw2a + rewindertime, 
                                         attenlength + tns_length + 
                                         XTR_length[bd_index] + 
                                         RBA_length[bd_index] + 
                                         DAB_length[bd_index] +
                                         fast_xtr_setlng +
                                         psd_grd_wait) + (pos_read ? t_rd1a : t_rdb);

        if(!(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag)
        {
            /* Force optimal fat/water in-phase TE for all cases of xres and
               field strengths */
            /* For in-phase, choose lower TE (~4.2 ms) to get maximum slices
               although TE may not be optimal */
            /* MRIge92350 - Removed 1.5T Dual Echo from the following check.  Similar check is 
               added later with "1.5T Dual Echo" label. */ 
            if( cffield < B0_15000 ) {
                int tmp_time = (int)((1000000.0 * (float)B0_15000 / (220.0 * cffield)) + 0.5) - 300;

                if( tmp_time > act_te2 ) {
                    act_te2 = tmp_time;
                }
            }

            /* MRIge91751 - For TE2 less than lower limit for first out-phase TE, 
               set it to the lower limit.  For TE2 greater than upper limit for 
               first out-phase TE,set it to lower limit of second out-phase TE. */ 
            /* MRIge92430 - For TE2 greater than lower limit for second out-phase,
               TE2 should not be set to the lower limit.                        */             
            if (cffield == B0_30000)
            {
                /* HCSDM00241267: TE2 limits for 1st in-phase echo */
                if (dualecho_minTE)
                {
                    if (act_te2 <= dualecho3t_llimtein1_min)
                        act_te2 = dualecho3t_llimtein1_min;
                }
                else
                {
                    if (act_te2 < dualecho3t_llimteout1_mf)
                        act_te2 = dualecho3t_llimteout1_mf;
                    else if ( (act_te2 > dualecho3t_ulimteout1_mf) && (act_te2 < dualecho3t_llimteout2_mf) )
                        act_te2 = dualecho3t_llimteout2_mf;
                }
            }
            /* MRIge92350 - 1.5T Dual Echo */	
            if (cffield == B0_15000) {
                if (act_te2 < dualecho1p5t_llimtein1)
                    act_te2 = dualecho1p5t_llimtein1;
            }
        }

        /* Calculate dual echo spacing */
        echo_spacing = intte_flag*RUP_GRD((int)((act_te2 - act_te)/intte_flag));
        if(pos_read) {
            average_esp = echo_spacing;
        } else {
            average_esp = t_rdb + IMax (2,  pw_gxwd + pw_gxw2a + rewindertime,
                                         attenlength + tns_length +
                                         XTR_length[bd_index] +
                                         RBA_length[bd_index] +
                                         DAB_length[bd_index] +
                                         fast_xtr_setlng +
                                         psd_grd_wait) + t_rd1a;
            average_esp = intte_flag*RUP_GRD((int)((average_esp)/intte_flag));
        }

        act_te2 = act_te + echo_spacing;
    } else {
        echo_spacing = 0;
        average_esp = 0;
        act_te2 = opte2;
    }

    /* MEGE: auto calc the echo number */
    if( feature_flag & MERGE ){
        int echonum = (INT)((float)((mege_eff_te*1000-act_te)*2.0)/echo_spacing + 0.5)+1;
        if(echonum < 3) echonum = 3;
        else if (echonum > 16) echonum = 16;
        cvoverride(opnecho, echonum, PSD_FIX_ON, PSD_EXIST_ON);
    }

    dualecho_max_xres = avmaxxres;

    /* HCSDM00241267: Set error for TE1 > 1st-out-of-phase TE or TE2 > 1st-in-phase TE */
    if ( (dualecho_minTE) && (dualecho_TEcheck_flag) &&
         ((act_te > dualecho3t_ulimteout1_min) || (act_te2 > dualecho3t_ulimtein1_min)) )
    {
        int delta_time = 0;
        int dualecho_max_xres1 = dualecho_max_xres;
        int dualecho_max_xres2 = dualecho_max_xres;
        const int XRES_BUFFER = 12;

        if (act_te > dualecho3t_ulimteout1_min) 
        {
            delta_time = act_te - dualecho3t_ulimteout1_min;
            dualecho_max_xres1 = exist(opxres) - (int)ceilf(2.0 * exist(oprbw) * delta_time / (fecho_factor - 0.5) * 1.0e-3 / 4.0) * 4; 
        }

        if (act_te2 > dualecho3t_ulimtein1_min)
        {
            delta_time = act_te2 - dualecho3t_ulimtein1_min;
            dualecho_max_xres2 = exist(opxres) - (int)ceilf(2.0 * exist(oprbw) * delta_time / (fecho_factor + 0.5) * 1.0e-3 / 4.0) * 4; 
        }

        dualecho_max_xres = IMin(2, dualecho_max_xres1, dualecho_max_xres2) - XRES_BUFFER;
        dualecho_TE_error = PSD_ON;
    }
    else
    {
        dualecho_TE_error = PSD_OFF;
    }

    /**********************************
     *  Set default number of echoes  *
     **********************************/
    if(rhfiesta == 0)
        pinecho = exist(opnecho)*intte_flag;
    else
        pinecho = 1; /* this fixes the image annotation bug */

    /* No pw_gxwd because killer and rewinder start after pw_gxw  */
    /* Added echo_spacing for DUALECHO */
    tmin_satoff = te_time + (opnecho-1)*average_esp
                + (intte_flag-1)*average_esp/intte_flag
                + non_tetime; /* does not include sat time */
    /* minimum time for single slice acq with sat */
    tmin = tmin_satoff + sp_sattime;
    /* add cs time, when applicable */
    if( !((feature_flag & FIESTA) && (feature_flag & SPECIR)) ) {
        /* MRIge90793: 2D FIESTA Fat SAT plays the SpecIR pulse once at
           the beginning of slice; hence, it does not affect TR */
        tmin += cs_sattime;
    }

    /* RTIA addition */
    /* Allow for Hard180 sequence time */
    tmin += hard180_time;
    /* End RTIA */


    /*
     * Advisory Panel Calculations
     *
     * All rfpulse and gradient bookkeeping structures should be
     * up-to-date by this point.  Advisory panel routines automatically
     * set corresponding advisory panel export variables.
     */

    /* MRIge57023 - If the user enters a TE value. */
    if( existcv(opautote) && (PSD_OFF == exist(opautote)) && existcv(opte) ) {
        if( (exist(opte) > min_tefe) && (exist(opte) < min_tenfe) ) {
            avminte = min_tefe;
        } else {
            avminte = min_tenfe;
        }
        if (vstrte_flag) {
           avminte = (int) 10.0*floor(act_te/10.0);
        } else {
           /* Multiply by 10 so avroundup will round to 10th of ms */
           avminte *= 10;
           advroundup(&avminte);
           /* Divide by 10 to restore avmaxte to ms */
           avminte /= 10;
        }
        /* Set maximum TE to 100ms to support T2* single echo acquisition */
        avmaxte = MAXTE;
    } else {
        if (PSD_OFF == exist(opautote) && (opte < avminte) ) {
            /*MRIhc38955*/
            epic_error( use_ermes, "The selected TE must be increased to %3.1f ms for the current prescription.",
                        EM_PSD_FLOAT_MINTE_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, (avminte/1ms) );
            return ADVISORY_FAILURE;
        }
        else if (PSD_OFF == exist(opautote) &&  (opte > avmaxte) ) {
            /*MRIhc38955*/
            epic_error( use_ermes, "The selected TE must be decreased to %3.1f ms for the current prescription.",
                        EM_PSD_FLOAT_MAXTE_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, (avmaxte/1ms) );
            return ADVISORY_FAILURE;
        } else {
            /* Set minimum TE */
            avminte = act_te; /* avminte is set to the unrounded minimum  */
            /* Set opte value equal to minimum */
            setfix(opte,PSD_FIX_OFF); 
            opte = avminte;
            setfix(opte,PSD_FIX_ON);
            /* MRIge62980 - Set maximum TE equal to minimum if type-in
               values are no allowed */
            avmaxte = avminte;
        }
    }

    /* GEHmr01770 - Set maximum TE equal to last echo time for MFGRE.
       last echo time is important to decide a echo number.*/
    /* GEHmr03608 - added intte_flag for avmaxte calculation */
    if((feature_flag & MFGRE) || r2_flag)
    {
        if( fullte_flag == PSD_ON || pos_read == PSD_ON ){
            avmaxte = act_te + (opnecho * intte_flag - 1) * echo_spacing / intte_flag;
        } else {
            /* for fractional echo - Note: intte_flag > 1 not supported */
            if( opnecho % 2 == 1 ){
                avmaxte = act_te + (opnecho * intte_flag - 1)  * average_esp;
            } else {
                avmaxte = act_te2 + (opnecho * intte_flag - 2)  * average_esp;
            }
        }                
    }

    /* DUALECHO - Calculate TE2 value assuming equal receiver bandwidth. */
    if( exist(opnecho) >= 2 )
    {
        /* Set minimum TE2 */
        avminte2 = act_te2;
        /* Set opte2 value equal to minimum and activate exist/fix flags */
        setfix(opte2, PSD_FIX_OFF);
        opte2 = avminte2;
        setfix(opte2, PSD_FIX_ON);
    }

    /* MRIge62980 - Set maximum TE2 equal to minimum */
    avmaxte2 = avminte2;

    return SUCCESS;
}   /* end set_rdout_params_te_and_tmin() */ 


/*
 * setPulseParams() is the PSD interface for dB/dt optimization used in pulse sequences.
 * This is used by calcOptimizedPulses() to set the pulse sequence timing based on the current
 * slew-rate set by the dB/dt computation engine. When called, this sets all pulse parameters 
 * including instruction amplitudes and inter-pulse timings so that pulsegen() can be then called
 * on the host to generate a linear segment model of the pulse sequence for futher analysis (like dB/dt).
 *
 * Returns FAILURE/ADVISORY_FAILURE if calculations fail with appropriate
 * error structures filled in.
 *
 * @see also calcOptimizedPulses()
 * @author Roshy J. Francis
 */
STATUS
setPulseParams( void )
{ 
    STATUS status;

    /* GEHmr02638: smart derating */
    if( gradOpt_flag && gradOpt_first && (fabs(gradOpt_scale-gradOpt_old_scale) > gradOpt_errToZero) && gradOpt_pgenDBDT )
    {
        int ratio_num;
        float maxPower, tmpfactor;
        ratio_num = 0;

        do
        {
            if ( smart_derating() == FAILURE )
            {
                return FAILURE;
            }

            /* SVBranch HCSDM00102590: when smart derating does not update gradOpt_scale, does not update gradOpt_TEfactor etc. */
            if(!gradOpt_run_flag)
            {
                break;
            }

            if( 0 == gradOpt_mode )
            {
                gradOpt_TRfactor  = 1.0;
                gradOpt_TEfactor  = 1.0;
                gradOpt_RFfactor  = 1.0;
                gradOpt_GX2factor = 1.0;

                if( gradOpt_TRfactor * gradOpt_scale < gradOpt_TRderating_limit )
                {
                    gradOpt_TRfactor = gradOpt_TRderating_limit / gradOpt_scale;
                }

                if( gradOpt_TEfactor * gradOpt_scale < gradOpt_TEderating_limit )
                {
                    gradOpt_TEfactor = gradOpt_TEderating_limit / gradOpt_scale;
                }

                if( gradOpt_RFfactor * gradOpt_scale < gradOpt_RFderating_limit )
                {
                    gradOpt_RFfactor = gradOpt_RFderating_limit / gradOpt_scale;
                }

                if( gradOpt_GX2factor * gradOpt_scale < gradOpt_GX2derating_limit )
                {
                    gradOpt_GX2factor = gradOpt_GX2derating_limit / gradOpt_scale;
                }

                if( PSD_OFF == gradOpt_TE )
                {
                    gradOpt_TEfactor = 1.0 / gradOpt_scale;
                }

                if( PSD_OFF == gradOpt_RF )
                {
                    gradOpt_RFfactor = 1.0 / gradOpt_scale;
                }

                if( PSD_OFF == gradOpt_GX2 )
                {
                    gradOpt_GX2factor = 1.0 / gradOpt_scale;
                }

                if (isSVSystem())
                {
                    /* GEHmr04246 : set target amp for chemsat killer gradient */
                    chemsat_killer_target = CSK_TARGET;
                }
                else
                {
                    chemsat_killer_target = cfxfs;
                }
                /* SVBranch HCSDM00102590 remove update for gradOpt_RFfactor here */
                ogsfRF  = FMax(2, gradOpt_scale * gradOpt_RFfactor, ogsf_limit_Min_RF_GX2);
                ogsfRF  = FMin(2, ogsfRF, ogsf_limit_Max);
                ogsfRF  = FMin(3, ogsfRF, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
                ogsfGX2 = FMax(2, gradOpt_scale * gradOpt_GX2factor, ogsf_limit_Min_RF_GX2);
                ogsfGX2 = FMin(2, ogsfGX2, ogsf_limit_Max);
            }

            if( 1 == gradOpt_mode )
            {
                maxPower = FMax(4, gradOpt_powerTE, gradOpt_powerTR, gradOpt_powerRF, gradOpt_powerGX2);

                gradOpt_TRfactor = gradOpt_TRfactor * sqrt(maxPower/gradOpt_powerTR);

                if( (gradOpt_TRfactor * gradOpt_scale) > 1.0 )
                {
                    gradOpt_TRfactor = 1.0 / gradOpt_scale;
                }

                if( gradOpt_TE )
                {
                    gradOpt_TEfactor = gradOpt_TEfactor*sqrt(maxPower/gradOpt_powerTE);

                    if( (gradOpt_TEfactor * gradOpt_scale) > 1.0 )
                    {
                        gradOpt_TEfactor = 1.0 / gradOpt_scale;
                    }
                }
                else
                {
                    gradOpt_TEfactor = 1.0 / gradOpt_scale;
                }

                if( gradOpt_GX2 )
                {
                    gradOpt_GX2factor = gradOpt_GX2factor*sqrt(maxPower/gradOpt_powerGX2);

                    if( (gradOpt_GX2factor * gradOpt_scale) > 1.0 )
                    {
                        gradOpt_GX2factor = 1.0 / gradOpt_scale;
                    }
                }
                else
                {
                    gradOpt_GX2factor = 1.0/gradOpt_scale;
                }

                if( gradOpt_RF )
                {
                    gradOpt_RFfactor = gradOpt_RFfactor*sqrt(maxPower/gradOpt_powerRF);

                    if( (gradOpt_RFfactor * gradOpt_scale) > 1.0 )
                    {
                        gradOpt_RFfactor = 1.0 / gradOpt_scale;
                    }
                    /* SVBranch HCSDM00102590: remove update for "gradOpt_RFfactor" */
                }
                else
                {
                    gradOpt_RFfactor = 1.0/gradOpt_scale;
                }

                tmpfactor = FMin(4, gradOpt_TRfactor, gradOpt_TEfactor, gradOpt_RFfactor, gradOpt_GX2factor);

                gradOpt_TRfactor  = gradOpt_TRfactor / tmpfactor;
                gradOpt_TEfactor  = gradOpt_TEfactor / tmpfactor;
                gradOpt_RFfactor  = gradOpt_RFfactor / tmpfactor;
                gradOpt_GX2factor = gradOpt_GX2factor / tmpfactor;
                gradOpt_scale     = FMax(2, gradOpt_scale * tmpfactor, gradOpt_scale_Min);
                gradOpt_scale     = FMin(2, gradOpt_scale, gradOpt_scale_Max);

                ogsfRF  = FMax(2, gradOpt_scale * gradOpt_RFfactor, ogsf_limit_Min_RF_GX2);
                ogsfRF  = FMin(2, ogsfRF, ogsf_limit_Max);
                /* SVBranch HCSDM00102590 */
                ogsfRF  = FMin(3, ogsfRF, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
                ogsfGX2 = FMax(2, gradOpt_scale * gradOpt_GX2factor, ogsf_limit_Min_RF_GX2);
                ogsfGX2 = FMin(2, ogsfGX2, ogsf_limit_Max);
            }

            ratio_num++;

        } while( ratio_num < gradOpt_ratio_iter_num );

        ogsfX1    = FMax(2, ogsfX1 * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfX1    = FMin(2, ogsfX1, ogsf_limit_Max);
        ogsfY     = FMax(2, ogsfY * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfY     = FMin(2, ogsfY, ogsf_limit_Max);
        ogsfZ     = FMax(2, ogsfZ * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfZ     = FMin(2, ogsfZ, ogsf_limit_Max);
        ogsfXwex  = FMax(2, ogsfXwex * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min_Gxwex);
        ogsfXwex  = FMin(2, ogsfXwex, ogsf_limit_Max);
        ogsfYk    = FMax(2, ogsfYk * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min);
        ogsfYk    = FMin(2, ogsfYk, ogsf_limit_Max);
        ogsfZk    = FMax(2, ogsfZk * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min);
        ogsfZk    = FMin(2, ogsfZk, ogsf_limit_Max);
        gradOpt_old_scale = gradOpt_scale;
    }
    else if( (PSD_OFF == gradOpt_flag || get_cvs_changed_flag() || PSD_ON == enforce_minseqseg) &&
             gradOpt_first && gradOpt_pgenDBDT )
    {
        if ( smart_derating() == FAILURE )
        {
            return FAILURE;
        }

        ogsfX1    = FMax(2, ogsfX1 * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfX1    = FMin(2, ogsfX1, ogsf_limit_Max);
        ogsfY     = FMax(2, ogsfY * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfY     = FMin(2, ogsfY, ogsf_limit_Max);
        ogsfZ     = FMax(2, ogsfZ * gradOpt_scale * gradOpt_TEfactor, ogsf_limit_Min);
        ogsfZ     = FMin(2, ogsfZ, ogsf_limit_Max);
        ogsfXwex  = FMax(2, ogsfXwex * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min_Gxwex);
        ogsfXwex  = FMin(2, ogsfXwex, ogsf_limit_Max);
        ogsfYk    = FMax(2, ogsfYk * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min);
        ogsfYk    = FMin(2, ogsfYk, ogsf_limit_Max);
        ogsfZk    = FMax(2, ogsfZk * gradOpt_scale * gradOpt_TRfactor, ogsf_limit_Min);
        ogsfZk    = FMin(2, ogsfZk, ogsf_limit_Max);
        /* SVBranch HCSDM00102590 */
        ogsfRF    = FMax(2, gradOpt_scale * gradOpt_RFfactor, ogsf_limit_Min_RF_GX2);
        ogsfRF    = FMin(2, ogsfRF, ogsf_limit_Max);
        ogsfRF    = FMin(3, ogsfRF, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
        ogsfGX2   = FMax(2, gradOpt_scale * gradOpt_GX2factor, ogsf_limit_Min_RF_GX2);
        ogsfGX2   = FMin(2, ogsfGX2, ogsf_limit_Max);
    }

    gradOpt_first = 1;

    if ( (status = pulse_params_init()) != SUCCESS ) { 
        return status;
    }

    if ( (status = set_slice_select_params()) != SUCCESS ) { 
        return status;
    }

    if ( (status = set_phase_encode_and_rewinder_params()) != SUCCESS ) { 
        return status;
    }

    if ( (status = set_zkiller_params()) != SUCCESS ) { 
        return status;
    }

    /* MRIge91751 - For TE greater than dualecho3t_ulimtein1,calculate the lowest 
       valid rBW that will lower the TE to dualecho3t_ulimtein1. */ 

    if ( (exist(opnecho)==2) && ((cffield == B0_30000) || (cffield == B0_15000)) 
         && !(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag ){  
       float valid_rbw,valid_max_rbw, valid_decimation, new_rbw;
       int skipnum;
       int temp_te;
       float temp_rbw = dualecho_llimrbw;
       float temp_maxrbw = dualecho_ulimrbw;
       float bakX1 = 0.0;
       float bakY = 0.0;
       float bakZ = 0.0;
       float bakRF = 0.0;
       float bakXwex = 0.0;
       float bakYk = 0.0;
       float bakZk = 0.0;
 
       /* MRIge92430 - Turn off minfovcheck_flag while in auto-rBW calculation loop. */
       minfovcheck_flag = PSD_OFF;
       dualecho_TEcheck_flag = PSD_OFF;

       new_rbw = dualecho_llimrbw;
       avminrbw = new_rbw;
       avmaxrbw = dualecho_ulimrbw;

       /* GEHmr04636: disable smart derating to let oprbw searching for Dual Echo work well */
       if(gradOpt_flag)
       {
           bakX1    = ogsfX1;
           bakY     = ogsfY;
           bakZ     = ogsfZ;
           bakRF    = ogsfRF;
           bakXwex  = ogsfXwex;
           bakYk    = ogsfYk;
           bakZk    = ogsfZk;

           ogsfX1   = 1.0;
           ogsfY    = 1.0;
           ogsfZ    = 1.0;
           /* SVBranch HCSDM00102590 */
           ogsfRF   = FMin(3, 1.0, gradOpt_rfb1opt_scale, gradOpt_pwgzrf1_scale);
           ogsfXwex = 1.0;
           ogsfYk   = 1.0;
           ogsfZk   = 1.0;

           if ( (status = pulse_params_init()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_slice_select_params()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_phase_encode_and_rewinder_params()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_zkiller_params()) != SUCCESS ) {
               return status;
           }
       }

       /* MRIge92503 - If FOV is set by user, calculate maximum rBW with the input value. */ 
       if (existcv(opfov) && (_opfov.fixedflag == PSD_ON)) {
           temp_maxrbw = GAM * gxwtarget * exist(opfov)/20000.0;
           if (temp_maxrbw > dualecho_ulimrbw) {
               temp_maxrbw = dualecho_ulimrbw;
           }
           skipnum = 0;
           while (temp_maxrbw < dualecho_ulimrbw){
               skipnum ++;
           if (SUCCESS != calcvalidrbw(temp_maxrbw-(skipnum-1)*5.0, &valid_rbw, 
                                       &valid_max_rbw, &valid_decimation,OVERWRITE_NONE, 0)) {
               return FAILURE;
           }
           
           if(valid_rbw > temp_maxrbw){
               continue;
           }else{
               temp_maxrbw = valid_rbw;
               break;
           }
       }
           if (temp_maxrbw < avminrbw) {
               temp_maxrbw = avminrbw;
           }
           avmaxrbw = temp_maxrbw;
       }
	   
       cvoverride(oprbw, new_rbw, existcv(oprbw), PSD_EXIST_ON);
       skipnum = 0;

       if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
           return status;
       }

       if (cffield == B0_30000)
       {
           /* HCSDM00241267: RBW will be set by t_rdb so set RBW based on TE2 or spacing between TE1 and TE2 */
           if (dualecho_minTE)
           {
               temp_te = act_te2;
               while ((act_te > dualecho3t_ulimteout1_min) || (act_te2 > dualecho3t_ulimtein1_min))
               {
                   skipnum ++;
                   if (SUCCESS != calcvalidrbw(new_rbw+(skipnum-1)*5.0, &valid_rbw,
                                               &valid_max_rbw, &valid_decimation, OVERWRITE_NONE, 0)) {
                       return FAILURE;
                   }

                   if ( (valid_rbw > avmaxrbw) || 
                        (floatsAlmostEqualEpsilons(valid_rbw, new_rbw, 2) && 
                         floatsAlmostEqualEpsilons(valid_rbw, avmaxrbw, 2)) ) {
                       new_rbw = avmaxrbw;
                       cvoverride(oprbw, avmaxrbw, existcv(oprbw), PSD_EXIST_ON);
                       if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                           return status;
                       }
                       break;
                   }

                   if (valid_rbw <= new_rbw) {
                       continue;
                   } else {
                       skipnum = 0;
                   }

                   new_rbw = valid_rbw;

                   if (temp_te > act_te2) temp_rbw = oprbw;
                   temp_te = act_te2;
                   cvoverride(oprbw, new_rbw, existcv(oprbw), PSD_EXIST_ON);

                   if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                       return status;
                   }

                   if (act_te2 > temp_te) {
                       cvoverride(oprbw, temp_rbw, existcv(oprbw), PSD_EXIST_ON);
                       if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                           return status;
                       }
                       break;
                   }
               }
           }
           else
           {
               temp_te = act_te;
               while (act_te > dualecho3t_ulimtein1_mf)  {
                   skipnum ++;
                   if (SUCCESS != calcvalidrbw(new_rbw+(skipnum-1)*5.0, &valid_rbw, 
                                               &valid_max_rbw, &valid_decimation,OVERWRITE_NONE, 0)) {
                       return FAILURE;
                   }

                   if(valid_rbw <= new_rbw){
                       continue;
                   }else{
                       skipnum = 0;
                   }

                   new_rbw = valid_rbw; 
                   if (new_rbw > avmaxrbw) {
                       new_rbw = avmaxrbw;
                       cvoverride(oprbw,avmaxrbw,existcv(oprbw), PSD_EXIST_ON);
                       if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                           return status;
                       }
                       break;
                   }

                   if (temp_te > act_te) temp_rbw = oprbw;
                   temp_te = act_te;
                   cvoverride(oprbw,new_rbw, existcv(oprbw), PSD_EXIST_ON);

                   if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                       return status;
                   }

                   if (act_te > temp_te) {
                       cvoverride(oprbw,temp_rbw,existcv(oprbw), PSD_EXIST_ON);
                       if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                           return status;
                       }
                       break;
                   }
               }
           }
       }
       /* MRIge92350 - 1.5T Dual Echo - For TE2 greater than dualecho1p5t_ulimtein1,calculate the lowest 
          valid rBW that will lower the TE2 to dualecho1p5t_ulimtein1. */ 
       else if (cffield == B0_15000)
       {
           temp_te = act_te2;
           while (act_te2 > dualecho1p5t_ulimtein1)  {
               skipnum ++;
               if (SUCCESS != calcvalidrbw(new_rbw+(skipnum-1)*5.0, &valid_rbw, 
                                           &valid_max_rbw, &valid_decimation,OVERWRITE_NONE, 0)) {
                   return FAILURE;
               }

               if(valid_rbw <= new_rbw){
                   continue;
               }else{
                   skipnum = 0;
               }

               new_rbw = valid_rbw; 
               if (new_rbw > avmaxrbw) {
                   new_rbw = avmaxrbw;
                   cvoverride(oprbw,avmaxrbw,existcv(oprbw), PSD_EXIST_ON);
                   if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                       return status;
                   }
                   break;
               }

               if (temp_te > act_te2) temp_rbw = oprbw;
               temp_te = act_te2;
               cvoverride(oprbw,new_rbw, existcv(oprbw), PSD_EXIST_ON);

               if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                   return status;
               }

               if (act_te2 > temp_te) {
                   cvoverride(oprbw,temp_rbw,existcv(oprbw), PSD_EXIST_ON);
                   if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
                       return status;
                   }
                   break;
               }

           }
       }       
       avminrbw = oprbw;
       avmaxrbw = oprbw;

       /* GEHmr04636: recorver original ogsf* to make smart derating work */
       if(gradOpt_flag)
       {
           ogsfX1   = bakX1;
           ogsfY    = bakY;
           ogsfZ    = bakZ;
           ogsfRF   = bakRF;
           ogsfXwex = bakXwex;
           ogsfYk   = bakYk;
           ogsfZk   = bakZk;

           if ( (status = pulse_params_init()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_slice_select_params()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_phase_encode_and_rewinder_params()) != SUCCESS ) {
               return status;
           }

           if ( (status = set_zkiller_params()) != SUCCESS ) {
               return status;
           }
       }
    }
    /* MRIge92430 - Turn on minfovcheck_flag since auto-rBW calculation is completed. */
    minfovcheck_flag = PSD_ON;
    dualecho_TEcheck_flag = PSD_ON;
    if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS ) {
        return status;
    }

    if ( (status = derate_gy1()) != SUCCESS) 
    {
        return status;
    }

    if ( calcPulseParams(AVERAGE_POWER) == FAILURE ) { 
        return FAILURE;
    }

    return SUCCESS;
}   /* end setPulseParams() */


/*************************************************************************

 Type      : Function 
 Arguments : none
 Scope     : Local
 Author    : Original from fgre.e, module : RJF

 Purpose   :  This function does the nex bookkeeping.
 The function sets up a few CVs based on the nex value selected
 and other prescription parameters. The CVs set here are used 
 in fgre and other modules. 
 
 Some important CVs which are set here include  fn, isNonIntNexGreaterThanOne, isOddNexGreaterThanOne,
 nex, truenex, nop and half nex overscans ( rhhnover)  
 
****************************************************************************/
static STATUS
nexcalc( void ) 
{
    int nextmp = (int)(exist(opnex));
    setResRhCVs();
    rhhnover = 0; /* init */

    /* HCSDM00477775
       Return FAILURE to avoid advisory error on #slices. */
    if( (nextmp != 0) &&
        !floatsAlmostEqualAbsolute((exist(opnex) - (float)nextmp), 0.5, FLT_EPSILON) &&
        !floatsAlmostEqualAbsolute(exist(opnex), (float)nextmp, FLT_EPSILON) )
    {
        epic_error( use_ermes,
                    "The selected number of excitations is not valid for the current prescription.",
                    EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
        return FAILURE;
    }

    if ( (status = setnexctrl(&nex, &fn, &truenex, &isOddNexGreaterThanOne, &isNonIntNexGreaterThanOne)) != SUCCESS)
    {
        return status;
    }

    if( !(feature_flag & ECHOTRAIN) ) {
        /* This number was already calculated in
         * set_phase_encode_and_rewinder_params() for ET */
        rhhnover = 0;   /* init */
    }

    if (existcv(opnex) && !floatIsInteger(exist(opnex)))
    {
        if (touch_flag)
        {
            epic_error( use_ermes, "%s is incompatible with %s",
                        EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                        STRING_ARG, "Fractional NEX",
                        STRING_ARG, "MR Touch" );
            return FAILURE;
        }
    }

    if (floatsAlmostEqualEpsilons(0.5, exist(opnex), 2))
    {
        /* HCSDM00367496 Moved NPW check to frac_nex_check(). */

        if (psmde_flag)
        {
            epic_error( use_ermes, "%s is incompatible with %s",
                        EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                        STRING_ARG, "0.5 NEX",
                        STRING_ARG, "PSMDE" );
            return FAILURE;
        } 
    }

    /* Begin RTIA change */
    if ( floatsAlmostEqualEpsilons(fn, 0.5, 2) ) {
        if (feature_flag & RTIA98 ) {
            rhhnover = IMax(2, (int)(8 * nop * asset_factor) , (int)(2*rhntran + 2));
            rhhnover = rhhnover + rhhnover % 2;
        } else if (feature_flag & FIESTA) {        /* MRIge90954 */
            rhhnover = IMax(2, (int)(16 * nop * asset_factor), (int)(2*rhntran + 2)); 
            rhhnover = rhhnover + rhhnover % 2;
        } else {
            /* MRIge73669: Calculate rhhnover for FGRE-ET (ETL = 1) and for non Echotrain cases */
            et_halfnexcalc( feature_flag, asset_factor );
        }
    } else  {
        rhhnover = 0;
    }
    /* End RTIA change */

    /* HCSDM00397211 */
    if ((PSD_ON == arc_ph_flag) && floatsAlmostEqualEpsilons(0.5, exist(opnex), 2)) {
       temp_rhhnover = 0;
    } else {
       temp_rhhnover = rhhnover;
    } /* End HCSDM00397211 */

    /* cmon with a nex = 1.5 or above is a nop = 2 case.
       - RJF, MRIge41709 - LX2 */

    if ( floatsAlmostEqualEpsilons(opnex, 0.0, 2) ) {   /** guard against zero nex **** AKG ***/
        epic_error( use_ermes, "Improper NEX selected",
                    EM_PSD_NEX_OUT_OF_RANGE, 0 );
        return FAILURE;
    }

    /* Begin RTIA */
    /* For RTIA, allow this to be caught in rtia_Cvcheck */
    if ( exist(opmt) == PSD_ON && existcv(opmt) == PSD_ON &&
         (!(feature_flag & RTIA98)) && 
         (!((feature_flag & ECHOTRAIN) && (oprealtime == PSD_ON)))) {
        /* End RTIA */
        epic_error( use_ermes, "MT not Supported", EM_PSD_MT_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    if(pc_mode < PC_BASIC)nex_save = nex; /* VAL15 02/21/2005 YI */

    return SUCCESS;
}   /* end nexcalc() */


/*
 *  calc_xresfn
 *
 *  Type: Function
 *
 *
 *  This routine returns the relative echo fraction, Fnecholim and the
 *  number of acquired data points, Xres. 
 *  Note that the relative echo fraction (Fnecholim) is the echo fraction relative to
 *  the *fractional* readout gradient duration. This can be calculated explicity from
 *  the echo fraction relative to the *full* readout gradient duration
 *  (Act_Echofrac). 
 * 
 *  This is a new implementation in fgre, but the same as that in efgre3d.
 *  - RJF, LxMGD
 */
static STATUS
calc_xresfn( INT *Xres, 
             FLOAT *Fnecholim, 
             INT OPxres )
{
    short xrestmp;
    float fnecholimtmp;
    short xadd;

    /* for 1/2 or 3/4 NEX we increase echo fraction to ~80%*/

    /* HCSDM00445737: Sync up Kizuna SPR HCSDM00426178 to Rio: Optimized act_echofrac */
    if (floatsAlmostEqualEpsilons(fn, 0.5, 2) || floatsAlmostEqualEpsilons(fn, 0.75, 2))
    {
        act_echofrac = 0.80;                                                                                      
    }
    else if (feature_flag & FIESTA)
    {
        act_echofrac = 0.72;
    }
    else if ((feature_flag & MFGRE) || r2_flag)
    {
        act_echofrac = 0.70;
    }
    else if (isInh2DTOF && zerofill_flag)
    {
        act_echofrac = 0.63;
    }
    else
    {
        act_echofrac = (dualecho_minTE) ? 0.65 : 0.60; /* HCSDM00241267 */
    }

    xrestmp = (int)(act_echofrac * OPxres + 4); /* Acquire at least 4
                                                   additional points just in case*/

    /* Round up to the nearest xres divisible by 4 (see TKF) */
    xrestmp = (int)(4*ceil((float)xrestmp/4));

    xadd = (int)(xrestmp - OPxres * act_echofrac ); /* Additional points beyond kxmax */

    if (vstrte_flag && (fn>=1.0) && (exist(opxres) >= 64) && !(feature_flag & FIESTA))
    {
        act_echofrac = 0.505;
        xrestmp = 2 * (int) ((0.25-!(cfsrmode>=PSD_SR200)*0.01)*OPxres);
        xrestmp = (int)(4*ceil((float)xrestmp/4));
        xadd = 0;
    }

    /* Relative fnecho_lim can be calculated from the act_echofrac and the total readout gradient duration */
    fnecholimtmp = ( act_echofrac - 0.5 ) / ( act_echofrac + (float) xadd / OPxres ) + 0.5;

    *Xres = xrestmp;

    *Fnecholim = fnecholimtmp;

    return SUCCESS;

}   /* end calc_xresfn() */


/*
 *  fwphase
 *
 *  Description:
 *    The following code calculates the Fat/Water in or
 *    out-of Phase TE values.
 *
 *  Type and Call:
 *  -------------
 *
 *  STATUS fwphase( &actte, &fullteflag, mintefe, mintenfe, 
 *                  llimte1, llimte2, llimte3, 
 *                  ulimte1, ulimte2, ulimte3 )
 *
 *  Parameters Passed:
 *  -----------------
 *  (I: for input parameter, O: for output parameter)
 *
 *  (O) INT actte: actural TE calculated for F/W in/out-of phase
 *
 *  (O) INT fullteflag: flag for full echo case. 1=full echo, 
 *                      0=frac echo
 *                     
 *  (I) INT mintefe: minimum TE for fractional echo
 *
 *  (I) INT mintenfe: minimum TE for full echo
 *
 *  (I) INT llimte1: lower limit for first F/W in/out-of phase range
 *
 *  (I) INT llimte2: lower limit for second F/W in/out-of phase range
 *
 *  (I) INT llimte3: lower limit for third F/W in/out-of phase range
 *
 *  (I) INT ulimte1: upper limit for first F/W in/out-of phase range
 *
 *  (I) INT ulimte2: upper limit for first F/W in/out-of phase range
 *
 *  (I) INT ulimte3: upper limit for first F/W in/out-of phase range
 */
STATUS
fwphase( INT *actte, 
         INT *fullteflag, 
         INT mintefe, 
         INT mintenfe, 
         INT llimte1, 
         INT llimte2, 
         INT llimte3, 
         INT ulimte1, 
         INT ulimte2, 
         INT ulimte3 )
{
    INT range1, range2, range3;
    INT te1, te2, te3;
    INT fullte1, fullte2, fullte3;
    INT minfrac1, minfrac2, minfrac3;

    /* The following CVs are used to flag which FW 
       in/out-of phase range will be used */
    range1 = (SHORT)( (min_tefe <= ulimte1) ? 1 : 0 );
    range2 = ( ((ulimte1 <= min_tefe) &&
                (min_tefe <= ulimte2)) ? 1 : 0 );
    range3 = ( (ulimte2 <= min_tefe) ? 1 : 0 );

    /* The following CVs are used to flag whether a
       full echo can be used*/
    fullte1 = ( (min_tenfe <= llimte1) ? 1 : 0 ) * range1;
    fullte2 = ( (min_tenfe <= llimte2) ? 1 : 0 ) * range2;
    fullte3 = ( (min_tenfe <= llimte3) ? 1 : 0 ) * range3;
    
    /* flag to determine whether full echo is allowed for
       F/W in/out-of phase */
    *fullteflag = fullte1 + fullte2 + fullte3;

    /* The minimum fractional echo te, limited by the lower
       limits of the F/W in phase range, is: */
    minfrac1 = ( (min_tefe <= llimte1 )? llimte1 : min_tefe ) *
        range1;
    minfrac2 = ( (min_tefe <= llimte2 )? llimte2 : min_tefe ) *
        range2;
    minfrac3 = ( (min_tefe <= llimte3 )? llimte3 : min_tefe ) *
        range3;

    /* The te can then be set using: */
    te1 = fullte1*llimte1 + (1.0 - fullte1)*minfrac1;
    te2 = fullte2*llimte2 + (1.0 - fullte2)*minfrac2;
    te3 = fullte3*llimte3 + (1.0 - fullte3)*minfrac3;

    *actte = te1 + te2 + te3;

    if ((PSD_ON == xrmw_3t_flag) || ((PSD_VRMW_COIL == cfgcoiltype) && (B0_30000 == cffield)))
    {
        if( PSD_ON == force_fullte_flag )
        {
            *fullteflag = PSD_ON;

            if( llimte1 < min_tenfe )
            {
                *actte = min_tenfe;
            }
            else
            {
                *actte = llimte1;
            }
        }
    }

    return SUCCESS;
}   /* end fwphase() */


/*
 *  mintefgre
 *
 *  Description:
 *    ???
 *
 *  Type and Call:
 *  --------------
 *  STATUS mintefgre( &Minte, &Rd1a, &Rd1b, &tfeextra, &a_pwgxw, &d_pwgxw, 
 *                    &ampgx1, &a_pwgx1, &c_pwgx1, &d_pwgx1, 
 *                    &ampgxfc, &a_pwgxfc, &c_pwgxfc, &d_pwgxfc, 
 *                    fecho_factor, c_pwgxwl, c_pwgxw, c_pwgxwr, 
 *                    ampgxw, Trf1b, fctype, minseq1, minseq3 )
 */
STATUS
mintefgre( INT *Minte, 
           INT *Rd1a, 
           INT *Rd1b, 
           INT *tfeextra, 
           INT *a_pwgxw, 
           INT *d_pwgxw, 
           FLOAT *ampgx1, 
           INT *a_pwgx1, 
           INT *c_pwgx1, 
           INT *d_pwgx1, 
           FLOAT *ampgxfc, 
           INT *a_pwgxfc, 
           INT *c_pwgxfc, 
           INT *d_pwgxfc, 
           DOUBLE fecho_factor, 
           INT c_pwgxwl, 
           INT c_pwgxw, 
           INT c_pwgxwr, 
           DOUBLE ampgxw, 
           INT Trf1b, 
           INT fctype, 
           INT minseq1, 
           INT minseq3 )
{
    INT min_tetmp;
    INT rd1atmp;
    INT rdbtmp;
    INT a_pwgxfctmp;
    INT c_pwgxfctmp;
    INT d_pwgxfctmp;
    INT a_pwgx1tmp;
    INT c_pwgx1tmp;
    INT d_pwgx1tmp;
    FLOAT ampgxfctmp;
    FLOAT ampgx1tmp;
    INT a_pwgxwtmp;
    INT d_pwgxwtmp;
    INT c_pwgxwfull;
    INT min_tessp;

    c_pwgxwfull = c_pwgxw;
    acq_type    = TYPGRAD;   /* fgre is always a grad. echo sequence */
    *tfeextra   = RUP_GRD((INT)((1 - fecho_factor) *
                                c_pwgxwfull));

    /* Time to center of echo from start of readout */
    rd1atmp = c_pwgxwl + (INT)((fecho_factor - 0.5) *
                               c_pwgxwfull);

    /* Round up to lie on gradient boundaries */
    rd1atmp = RUP_GRD(rd1atmp);

    /* Time from center of echo to end of readout */
    rdbtmp = c_pwgxw + c_pwgxwr + c_pwgxwl - rd1atmp;

    /* For Echotrain, ramps are calculated in et_cveval */
    if (!(feature_flag & ECHOTRAIN)) {
        if ( optramp( &a_pwgxwtmp, ampgxw, gxwtarget, gxwramp, 
                      TYPDEF ) == FAILURE ) {
            return FAILURE;
        } 
        d_pwgxwtmp = a_pwgxwtmp;
    } else {
        a_pwgxwtmp = *a_pwgxw;
        d_pwgxwtmp = *d_pwgxw;
    }

    avround = 0;   /* get exact, non rounded TE*/

    /*
      Since the min TE is always used, we set avmaxyres to 512.  
      avminte simply floats along with the prescription, then.  Therefore, 
      avail_pwgx1 and avail_pwgy1 can be set to very large values, and the
      rest of the pulse widths and advisory panel values will be calculated
      accordingly.  avail_pwgy1 is based on avail_pwgxy, so we only have
      to set avail_pwgx1.
    */
    avail_pwgx1 = 1s;

    /* FIESTA derating  05/16/2005 YI */
    if( (PSD_OFF == gradOpt_flag) && /* GEHmr02638 */
        ( ((cfgradamp == 8919) || (5551 == cfgradamp) ||(cfgradamp == 8905)||(cfgradamp == 8907)||((int)(10000 * cfxfs / cfrmp2xfs)<70)) && 
          (feature_flag & FIESTA) ) ) {
       derate_gx_G_cm = FMin(2, acgd_lite_target, loggrd.tx_xyz);
       derate_gx_factor = derate_gx_G_cm / loggrd.tx_xyz;
       if(plane_type == PSD_OBL)
          derate_gx_factor = 1.0;
    } else {
       derate_gx_G_cm = loggrd.tx_xyz;
       derate_gx_factor = 1.0;
    }

    /* SVBranch: to make aTEopt_flag and aTRopt_flag work */
    if( gradOpt_flag || aTEopt_flag || aTRopt_flag )
    {
       derate_gx_G_cm = loggrd.tx_xyz;
       derate_gx_factor = 1.0;
    }

    if (gradspec_flag)
    {
         derate_gx_factor = 2.0;
    }

    if ( fctype==TYPFC ) {
        if ( amppwgxfcmin( ampgxw, a_pwgxwtmp, c_pwgxwfull, d_pwgxwtmp, 
                           avail_pwgx1, fecho_factor, 
                           loggrd.tx_xyz, xrt*loggrd.scale_3axis_risetime, loggrd.xbeta, 
                           &ampgx1tmp, &a_pwgx1tmp, &c_pwgx1tmp, 
                           &d_pwgx1tmp, &ampgxfctmp, &a_pwgxfctmp, 
                           &c_pwgxfctmp, &d_pwgxfctmp ) == FAILURE ) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "amppwgxfcmin" );
            return FAILURE;
        }

        min_tegx = RUP_GRD(Trf1b + GRAD_UPDATE_TIME + a_pwgx1tmp +
                           c_pwgx1tmp + d_pwgx1tmp + a_pwgxfctmp + 
                           c_pwgxfctmp+ d_pwgxfctmp + a_pwgxwtmp + rd1atmp);
    } else {
        area_gxw = ampgxw * c_pwgxwfull;
        area_readramp = 0.5*ampgxw*a_pwgxwtmp;

        /* if sr17, scale the rise time for the ramp to get 5.4 parity.
           In 5.4, the ramp to gx1 was optimized to 95% of full scale. */
        if ( psd_getgradmode() == PSD_SR17 ) {
            rampscale = 0.95;
        } else {
            rampscale = (FLOAT)loggrd.tx_xyz;
        }

        if( amppwgx1( &ampgx1tmp, &c_pwgx1tmp, &a_pwgx1tmp, &d_pwgx1tmp, 
                      acq_type, area_gxw, (FLOAT)(area_readramp + ampgxw * pw_gxwl), 
                      (3s + RDN_GRD(pw_gxwlex)), (FLOAT)fecho_factor, MIN_PLATEAU_TIME, 
                      /* FIESTA derating  05/16/2005 YI
                      (INT)((FLOAT)xrt * rampscale / loggrd.tx_xyz), 
                      loggrd.tx_xyz ) == FAILURE ) {
                      */
                      RUP_GRD((ceil)(xrt*loggrd.scale_3axis_risetime* derate_gx_factor * rampscale / loggrd.tx_xyz)), 
                      derate_gx_G_cm ) == FAILURE ) {
            epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                        EE_ARGS(1), STRING_ARG, "amppwgx1" );
            return FAILURE;
        }

        /* when flow comp is off, the gxfc gradient pulse is not generated.
           Therefore, the following gxfc CVs are set to 0. */
        ampgxfctmp = 0;
        a_pwgxfctmp = 0;
        c_pwgxfctmp = 0;
        d_pwgxfctmp = 0;
        min_tegx = RUP_GRD(Trf1b + GRAD_UPDATE_TIME + a_pwgx1tmp +
                           c_pwgx1tmp + d_pwgx1tmp + a_pwgxwtmp + rd1atmp);
    }

    /* Begin RTIA - RJF */
    /* Avoid overlap of any other gradients with slice select 
       decay. This will help to estimate the gzrf1 target as the 
       max graidient strength. This will decrease minimum Slice 
       thickness limit for RTIA from 7 to 4.3 when using RTIA 
       RF pulse. Otherwise selection of 4.4 will cause GZ gradient 
       fault.  */
    /* add gzrf1d to mintegx. pw_gzrf1d will be divisible by 4.
       So no need of Rounding here . */
    /* Do this for all realtime modes : echotrain and RTIA98 - 
       RJF */
    if ( (exist(oprealtime) == PSD_ON)  && !(feature_flag & FIESTA) ) {
        min_tegx += pw_gzrf1d ; 
    }
    /* End RTIA */

    min_tegz = RUP_GRD(minseq1 + rd1atmp);
    min_tegy = RUP_GRD(minseq3 + rd1atmp);

    if(vstrte_flag && is15TSystemType())
    {
        min_tessp = RUP_GRD ( Trf1b + psd_rf_wait + rfupd + RFUNBLANK_LENGTH + RXUBR_TO_COPYDAB + COPYDAB_LENGTH +
                              IMax(2, !vstrte_flag*DABSETUP, DAB_length[bd_index] + XTR_length[bd_index]
                            + !vstrte_flag*XTRSETLNG + RBA_length[bd_index]) - psd_grd_wait + rd1atmp); 
    }
    else
    {
        min_tessp = RUP_GRD ( Trf1b + rfupd + RFUNBLANK_LENGTH + RXUBR_TO_COPYDAB + COPYDAB_LENGTH +
                              IMax(2, !vstrte_flag*DABSETUP, DAB_length[bd_index] + XTR_length[bd_index]
                            + !vstrte_flag*XTRSETLNG + RBA_length[bd_index]) + rd1atmp);
    }
    if (touch_flag)
    {
        /*ZZ, touch MEG apended after gz1 or gzfc pulse
         * thus TE calculation started from minseq1*/
        min_tetmp = minseq1 + touch_time + 
                    IMax(2, minseq3 - grdrs_offset - t_exb, 
                            a_pwgx1tmp+c_pwgx1tmp+d_pwgx1tmp + 
                            a_pwgxfctmp+c_pwgxfctmp+d_pwgxfctmp + a_pwgxwtmp)
                    + rd1atmp;
        min_tetmp = IMax(2, min_tetmp, min_tessp);
    }
    else
    {
        min_tetmp = IMax(4, min_tegx, min_tegy, min_tegz, min_tessp );
    }
    
    *Rd1a     = rd1atmp;
    *Rd1b     = rdbtmp;

    /* For Echotrain, pw_gxwa and pw_gxwd have already been
       calculated, so don't recalculate */
    if (!(feature_flag & ECHOTRAIN)) {
        *a_pwgxw  = a_pwgxwtmp;
        *d_pwgxw  = d_pwgxwtmp;
    }

    *ampgx1   = ampgx1tmp;
    *a_pwgx1  = a_pwgx1tmp;
    *c_pwgx1  = c_pwgx1tmp;
    *d_pwgx1  = d_pwgx1tmp;
    *ampgxfc  = ampgxfctmp;
    *a_pwgxfc = a_pwgxfctmp;
    *c_pwgxfc = c_pwgxfctmp;
    *d_pwgxfc = d_pwgxfctmp;

    *Minte    = RUP_GRD(min_tetmp);  

/* Begin mintefgre Debug */
if (debug_mintefgre==1)  

  {
        FILE *fpp;
        char ti_fn[BUFSIZ];
#ifdef PSD_HW
        const char *ti_dn = "/usr/g/service/log";
#else /* !PSD_HW */
        const char *ti_dn = ".";
#endif /* PSD_HW */
        sprintf( ti_fn, "%s/fgre_mintefgre.info", ti_dn );
        fpp = fopen( ti_fn, "w" );
        if( NULL != fpp ) {
            fprintf( fpp, "##################### START #############################\n" );
            fprintf( fpp, " min_tetmp            = %d\n", min_tetmp );
            fprintf( fpp, " min_tegx             = %d\n", min_tegx );
            fprintf( fpp, " min_tegy             = %d\n", min_tegy );
            fprintf( fpp, " min_tegz             = %d\n", min_tegz );
            fprintf( fpp, " min_tessp            = %d\n", min_tessp );
            fprintf( fpp, " Trf1b                = %d\n", Trf1b);
            fprintf( fpp, " act_te               = %d\n", act_te); 
            fprintf( fpp, " a_pwgx1tmp           = %d\n", a_pwgx1tmp);
            fprintf( fpp, " c_pwgx1tmp           = %d\n", c_pwgx1tmp );
            fprintf( fpp, " d_pwgx1tmp           = %d\n", d_pwgx1tmp );
            fprintf( fpp, " a_pwgxwtmp           = %d\n", a_pwgxwtmp);
            fprintf( fpp, " pw_gxwlex            = %d\n", pw_gxwlex);            
            fprintf( fpp, " rd1atmp              = %d\n", rd1atmp);
            fprintf( fpp, " c_pwgxwl             = %d\n", c_pwgxwl );
            fprintf( fpp, " fecho_factor         = %f\n", fecho_factor );
            fprintf( fpp, " c_pwgxwfull          = %d\n", c_pwgxwfull );
            fprintf( fpp, " pw_gxwa              = %d\n", pw_gxwa );
            fprintf( fpp, " XTR_length[bd_index] = %d\n", XTR_length[bd_index] );
            fprintf( fpp, " RBA_length[bd_index] = %d\n", RBA_length[bd_index] );
            fprintf( fpp, " DAB_length[bd_index] = %d\n", DAB_length[bd_index] );
            fprintf( fpp, " fast_xtr_setlng      = %d\n", fast_xtr_setlng );
            fprintf( fpp, " XTRSETLNG            = %d\n", XTRSETLNG);
            fprintf( fpp, "rfupd                  = %d\n", rfupd );
            fprintf( fpp, " DABSETUP             = %d\n", DABSETUP);
            fprintf( fpp, "##################### END #############################\n" );
            fclose( fpp );
        }else {
            fprintf( stderr, "ERROR: Unable to open %s.\n", ti_fn );
        }
    }
    /* End mintefgre Debug */

    avround   = 1;

    return SUCCESS;
}   /* end mintefgre() */

/* Description:
   For Auto Protocol Optimization, it's necessary to set
   min / max / delta values of optimized parameters.
   Default setting is described in getAPxParamInit() and
   this function can modify those initial values.
*/
void
getAPxParam(optval   *min,
            optval   *max,
            optdelta *delta,
            optfix   *fix,
            float    coverage,
            int      algorithm)
{
    FILE *fp = NULL;
    const char *filename = "/usr/g/service/log/APx_trajectory.log";

    if(feature_flag & FIESTA)
    {
        if((PSD_OFF != exist(opasset)) || (1 == fix->accel) || (1 == fix->slthick))
        {
            delta->xres_min = 8;
            delta->yres_min = 12;
        }
    }

    if(feature_flag & FIESTA)
    {
        min->xres = IMax(2, avminxres, 160);
        max->xres = IMin(2, avmaxxres, 256);

        min->yres = IMax(2, avminyres, 196);
        max->yres = IMin(2, avmaxyres, 384);
    }
    else
    {
        if ( (dualecho_minTE) && (dualecho_TEcheck_flag) && (dualecho_max_xres < avmaxxres) &&
             ((act_te > dualecho3t_ulimteout1_min) || (act_te2 > dualecho3t_ulimtein1_min)) )
        {
            max->xres = dualecho_max_xres;

            if(autoparams_debug & 4)
            {
                fp = fopen(filename, "a");

                if(NULL != fp)
                {
                    fprintf(fp,"\t!!dualecho_max_xres=%d!!\n", dualecho_max_xres);
                    fclose(fp);
                }
            }

            dualecho_max_xres = avmaxxres;
        }
    }

    if(feature_flag & FIESTA)
    {
        min->xy_ratio = 0.5;
        max->xy_ratio = 1.0;

        min->accel_ph = FMin(2, 3.0, cfaccel_ph_maxstride);
        max->accel_ph = FMin(2, 3.0, cfaccel_ph_maxstride);
    }

    if(algorithm & APX_ALG_AUTO_TR)
    {
        min->tr = 120ms;
        max->tr = 250ms;

        if(PSD_ON == exist(opinrangetr))
        {
            min->tr = IMax(2, exist(opinrangetrmin), min->tr);
            max->tr = IMax(2, exist(opinrangetrmax), 2 * min->tr);
        }
    }

    if(algorithm & APX_ALG_AUTO_BW)
    {
        if ( cffield <= B0_15000 ) 
        {
            min->rbw = FMax(2, 83.33, avminrbw);
            max->rbw = FMin(2, 125.0, avmaxrbw);
        }   
        else
        {
            min->rbw = FMax(2, 83.33, avminrbw);
            max->rbw = FMin(2, 142.86, avmaxrbw);
        }
    }
}

/* Description:
   For Auto Protocol Optimization, it's necessary to set
   flags to show which parameters are optimized and
   which algirithms are applied.
   Default setting is described in getAPxAlgorithmInit() and
   this function can modify those initial values.
*/
int getAPxAlgorithm(optparam *optflag, int *algorithm)
{
    if(feature_flag & FIESTA)
    {
        *algorithm &= ~APX_ALG_AUTO_ACCDEC;
    }

    if((feature_flag & FIESTA) && (pircbnub > 0))
    {
        optflag->rbw = 1;
        *algorithm |= APX_ALG_AUTO_BW;
    }

    if(feature_flag & FIESTA)
    {
        optflag->autote = 1;
        optflag->te = 1;
    }
    else
    {
        optflag->user6 = 1;
    }

    return APX_CORE_BH_2D;
}

@inline loadrheader.e setResRhCVs

/*
 *  cvcheck
 *
 *  Description:
 *    This section will be executed every time a 'next page' is 
 *    chosen.  This is to assure that the current prescribed 
 *    protocol is legal.  If it is not, an error message will be
 *    returned to the psd manager.  For now, these messages
 *    will be strings.  But later the messages will be given
 *    by an ermes number.
 */
STATUS
cvcheck( void )
{
    INT status; /* used when a function returns either SUCCESS, FAILURE, or ADVISORY_FAILURE */
    extern int ext_trig_track;

    if (psmde_flag && (((PSD_GE!=exist(oppseq)) && (PSD_SPGR!=exist(oppseq)) &&
                        ((PSD_SSFP!=exist(oppseq)) || (!(sshpsmde_support && sshmde_support)))) ||
                       (PSD_ON==exist(opET)) || (PSD_ON==exist(opmerge))))
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "PSMDE", STRING_ARG, "this mode");
        return FAILURE;
    }

    if ((PSD_ON == psmde_flag) &&
        ((PSD_ON == exist(opspecir)) || (PSD_ON == exist(opfat)) || (PSD_ON == exist(opwater))))
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "PSMDE", STRING_ARG, "Chem SAT");
        return FAILURE;
    }

    if ((PSD_ON == mde_flag) && ((PSD_ON == exist(opfat)) || (PSD_ON == exist(opwater))))
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "MDE", STRING_ARG, "fat or water Chem SAT");
        return FAILURE;
    }

    if ((PSD_ON == mde_flag) && (PSD_ON == exist(opspecir)) && (!fsmde_support))
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "MDE", STRING_ARG, "Chem SAT");
        return FAILURE;
    }

    if ((PSD_ON == mde_flag) && (feature_flag & FIESTA) && (!sshmde_support))
    {
        epic_error(use_ermes,"%s is incompatible with %s.",
                   EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                   STRING_ARG, "MDE", STRING_ARG, "FIESTA");
        return FAILURE;
    }

@inline ZoomGradLimit.e ZoomGradParam

    if ( (PSD_ON == gradOpt_flag) && (PSD_OFF == smartDer_option_key_status) && (PSD_OFF == xrmw_3t_flag) && !isKizunaSystem() && !isRioSystem() && !isHRMbSystem() && !(cffield == B0_15000))
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "Smart Gradient Optimization" );
        return FAILURE;
    }

    if( (PSD_ON == derate_gy1_flag) && (PSD_ON == aTEopt_flag) )
    {
        epic_error( use_ermes, "%s is incompatible with %s.",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "derate_gy1_flag", STRING_ARG, "aTEopt_flag");
        return FAILURE;
    }

    if( (PSD_ON == derate_gy1_flag) && (PSD_ON == ss_rewinder_flag) )
    {
        epic_error( use_ermes, "%s is incompatible with %s.",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2), STRING_ARG, "derate_gy1_flag", STRING_ARG, "ss_rewinder_flag");
        return FAILURE;
    }

    /* HCSDM00241267 : flag error for Dual echo */
    /* HCSDM00254376 - Added EM_PSD_DE_RX_OUT_OF_RANGE */

    if (dualecho_minTE && existcv(opxres) && dualecho_TE_error)
    {
        epic_error( use_ermes,"The entered value is out of range per current prescription parameters; increase FOV, decrease frequency encoding matrix, or decrease flip angle.",
                    EM_PSD_DE_RX_OUT_OF_RANGE, EE_ARGS(0));
        return FAILURE;
    }

    /* YMSmr08456  02/16/2006 YI */
    if(minfov_error)
    {
        /* ASSET */
        if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
        {
            epic_error( use_ermes, "The only valid FOV with this prescription is %3.1f cm.", 
                        EM_PSD_EPI_FOV_ERROR_TEXT, EE_ARGS(1), FLOAT_ARG, avminfov / 10.0 );
            /* MRIge70066: need the advisory failure for cal mode so 
               opassetcal is not discarded on invalid FOV */
            return ADVISORY_FAILURE;
        } 
        else if( ASSET_SCAN == exist(opasset) ) 
        {
            epic_error( use_ermes,
                        "The FOV needs to be increased to %3.1f cm for the current "
                        "prescription, or Phase FOV fraction can be increased.", 
                        EM_PSD_FOV_OUT_OF_RANGE3, EE_ARGS(1), FLOAT_ARG, avminfov / 10.0 );
        } 
        else if( (exist(opnecho) == 2) && ((cffield == B0_30000) || (cffield == B0_15000)) ) 
        {
            epic_error( use_ermes, "The FOV needs to be increased to %-f cm", 
                        EM_PSD_FOV_OUT_OF_RANGE4, EE_ARGS(1), FLOAT_ARG, 
                        avminfov / 10.0  );
        
        } 
        else 
        {
            epic_error( use_ermes, "The FOV needs to be increased to %3.1f cm for the "
                        "current prescription, or receive bandwidth can be decreased.", 
                        EM_PSD_FOV_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, 
                        avminfov / 10.0 );
        }
        return ADVISORY_FAILURE;
    }

    static int sshmde_advisory_TI_flag = FALSE;

    if ( existcv(opti) && (exist(opti) < avminti) )
    {
        if ( (!sshmde_flag && !cardt1map_flag) || (sshmde_advisory_TI_flag) )
        {
            epic_error( use_ermes, "The selected TI must be increased to %d ms for the current prescription.",
                        EM_PSD_TI_OUT_OF_RANGE1, EE_ARGS(1), INT_ARG, (int)((avminti) / 1000) );
            return ADVISORY_FAILURE;
        }


        if (sshmde_flag || cardt1map_flag)
        {
            sshmde_advisory_TI_flag = TRUE;
        }
    }

    if (existcv(opti))  
    {
        extern int min_ti_inc, max_ti_tdel;

        if(cardt1map_flag && ((opti + min_ti_inc) > max_ti_tdel))
        {
            if( avminti == opti )
            {
                if( opti + min_ti_inc < avmaxti )
                {
                epic_error( use_ermes, "The trigger delay must be increased to %d ms for the current prescription.",
                     EM_PSD_TD_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG,
                         (int)((exist(opti) + min_ti_inc + (avmaxtdel1 - avmaxti))/1000) );
                    return FAILURE;
                } else {
                    epic_error( use_ermes, "Insufficient available imaging time. Decrease TR or number of phase encodings.",
                         EM_PSD_AIT_OUT_OF_RANGE5, EE_ARGS(0) );
                    return FAILURE;
                }
            } else {
                epic_error( use_ermes, "The selected TI or TI increment must be decreased for the current prescription.",
                        EM_PSD_TI_INCREMENT_OUT_OF_RANGE, EE_ARGS(0) );
                return FAILURE;
            }
        }
        else if(exist(opti) > avmaxti)
        {
            epic_error( use_ermes, "The selected TI must be decreased to %d ms for the current prescription.",
                    EM_PSD_TI_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, (int)(avmaxti/1000) );
            return ADVISORY_FAILURE;
        }
    }

    /* Disable ART with dual echo */
    if( ((2 == exist(opnecho)) && ((PSD_GE == exist(oppseq)) || (PSD_SPGR == exist(oppseq)))) && (PSD_ON == exist(opsilent)) )
    {
        epic_error( use_ermes, "%s is incompatible with %s.", EM_PSD_INCOMPATIBLE, 2, STRING_ARG, "ART", STRING_ARG, "dual echo" );
        return ADVISORY_FAILURE; 
    } 

    if(oppseq != PSD_3PLANELOC) 
    {
        if ( (exist(opfast) != PSD_ON) && existcv(opfast) ) 
        {
            epic_error( use_ermes, 
                        "The fast option must be selected for this sequence", 
                        EM_PSD_FGRE_SELECTION, 0 );
            return FAILURE;
        }
    }

    /* Respiratory Gating - Only FastCard is compatible with Resp. Gating -
       30/Feb/1998 - GFN */
    /* RTIA delays the check for oprtcgate for unified RTIA error msg. */
    if( (PSD_ON == exist(oprtcgate)) && existcv(oprtcgate) &&
        (!(feature_flag & FASTCARD) && !(feature_flag & FASTCARD_PC) &&
         !(feature_flag & FASTCARD_MP) && !(feature_flag & RTIA98) &&
         !((feature_flag & ECHOTRAIN) && exist(oprealtime) == PSD_ON) &&
         !(feature_flag & FIESTA)) ) 
    {
        epic_error( use_ermes, 
                    "Respiratory triggering is not supported by this sequence",
                    EM_PSD_RESPTRIG_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    if ( (exist(opgrxroi) == PSD_ON) && existcv(opgrxroi) ) 
    {
        epic_error( use_ermes, 
                    "The Graphic ROI Option is not available with "
                    "this sequence", 
                    EM_PSD_OPGRXROI_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    if ( ((exist(opautote) == PSD_FWINPHS) ||
          (exist(opautote) == PSD_FWOUTPHS)) &&
         (exist(opfcomp) == TYPFC) ) 
    {
        epic_error( use_ermes, 
                    "fcomp is not supported with F/W in/out-of phase "
                    "option.", EM_PSD_FCOMP_FWINOUT_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    /* Begin RTIA */
    /* Let this be caught in feature_cvchecks for RTIA98 and Echotrain*/
    if ( existcv(opexor) && (exist(opexor) == PSD_ON) &&
         (!(feature_flag & RTIA98) && 
          !(feature_flag & ECHOTRAIN) &&
          (exist(oprealtime) != PSD_ON)) ) 
    {
        /* End RTIA */
        epic_error( use_ermes, 
                    "The RESP COMP is not supported in "
                    "Fast Gradient Recalled Imaging.", 
                    EM_PSD_RESP_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    /*MRgFUS realtime mode trigger cv check*/
    if (PSD_ON == track_flag)
    {
        if (PSD_ON == ext_trig)
        {
            epic_error(0, "ext_trig can't be used with track_flag ON.", 0, EE_ARGS(0));
            return FAILURE;
        }

        if (feature_flag & MFGRE)
        {
            epic_error(0, "multi-echo fgre is not supported with track_flag ON.", 0, EE_ARGS(0));
            return FAILURE;
        }

        if (feature_flag & ECHOTRAIN)
        {
            epic_error(0, "echotrain fgre is not supported with track_flag ON.", 0, EE_ARGS(0));
            return FAILURE;
        }

        if (feature_flag & FIESTA)
        {
            epic_error(0, "FIESTA fgre is not supported with track_flag ON.", 0, EE_ARGS(0));
            return FAILURE;
        }

        if (feature_flag & MERGE)
        {
            epic_error(0, "MERGE is not supported with track_flag ON.", 0, EE_ARGS(0));
            return FAILURE;
        }

        if(existcv(opmph) && exist(opmph) && existcv(opacqo) && (exist(opacqo)>0) )
        {
            epic_error(0, "For multi-phase FUS tracking, only interleaved mode is supported.", 0, EE_ARGS(0));
            return FAILURE;
        }
    }

    if ( (PSD_ON == ext_trig_track) && (PSD_OFF == track_flag))
    {
        epic_error(0, "ext_trig_track must be used with track_flag ON.", 0, EE_ARGS(0));
        return FAILURE;
    }

    /* CREATIV is not compatible with Square Pixel option */
    if( (PSD_ON == exist(opstress)) && existcv(opstress) &&
        (PSD_ON == exist(opsquare)) && existcv(opsquare) ) 
    {
        epic_error( use_ermes, "%s is incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "The Square Pixel option",
                    STRING_ARG, "CREATIV Feature" );
        return FAILURE;
    }

    /* yres, xres vs. max advisory value uses advisory panel popup - JDM */
    if ( exist(opyres) > avmaxyres ) 
    {
        epic_error( use_ermes,
                    "The phase encoding steps must be decreased "
                    "to %d for the current prescription.",
                    EM_PSD_YRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxyres );
        return ADVISORY_FAILURE;
    }

    if ( exist(opyres) < avminyres ) 
    {
        epic_error( use_ermes,
                    "The phase encoding steps must be increased "
                    "to %d for the current prescription.",
                    EM_PSD_YRES_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, avminyres );
        return ADVISORY_FAILURE;
    }

    if(gradspec_flag)
    {
        if(existcv(opxres) && existcv(oprbw) && (exist(opxres) > avmaxxres))
        {
            epic_error( use_ermes,
                    "The frequency encodings must be decreased "
                    "to %d for the current prescription.",
                    EM_PSD_XRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxxres );
            return FAILURE;
        }
    }
    else
    {
        if ( exist(opxres) > avmaxxres ) 
        {
            epic_error( use_ermes,
                    "The frequency encodings must be decreased "
                    "to %d for the current prescription.", 
                    EM_PSD_XRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxxres );
            return ADVISORY_FAILURE;
        }
    }

    if ( exist(opxres) < avminxres ) 
    {
        epic_error( use_ermes,
                    "The frequency encoding steps must be increased "
                    "to %d for the current prescription.",
                    EM_PSD_XRES_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, avminxres );
        return ADVISORY_FAILURE;
    }

    if( !(feature_flag & FIESTA) && existcv(opxres) && existcv(opyres) &&
        (exist(opyres) > exist(opxres)) && !perfusion_flag )
    {
        /* yres > xres is allowed for FIESTA 2D scans.  For non-FIESTA
           scans, force yres to be xres and use advisory panel popup */
        avmaxyres = exist(opxres);
        epic_error( use_ermes,
                    "The phase encoding steps must be decreased "
                    "to %d for the current prescription.", 
                    EM_PSD_YRES_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, avmaxyres );
        return ADVISORY_FAILURE;
    }

    if ( (!(feature_flag & ECHOTRAIN)) && (!perfusion_flag) &&
         (exist(opcgate) == PSD_ON && exist(opmph) == PSD_ON) ) 
    {
        epic_error( use_ermes, "Cardiac gating and multi-phase are incompatible.",
                    EM_PSD_GATING_FGRE_MPH_INCOMPATIBLE, EE_ARGS(0) );
        return FAILURE;
    }

    /* slquant < minimum uses advisory panel popup - JDM */  
    /* echotrain has it's own check for perfusion mode - AKG */
    if ( (!(feature_flag & ECHOTRAIN)) &&
         (exist(opslquant) < avminslquant) && existcv(opslquant) ) 
    {
        epic_error( use_ermes, "Minimum slice quantity is %-d", 
                    EM_PSD_SLQUANT_OUT_OF_RANGE2, EE_ARGS(1), INT_ARG, 
                    avminslquant);
        return ADVISORY_FAILURE;
    }

    /* flip angle out of range uses advisory panel popup - JDM */  
    if ( (exist(opflip) < avminflip) || (exist(opflip) > avmaxflip) ) 
    {
        epic_error( use_ermes, "The flip angle is out of range", 
                    EM_PSD_OPFLIP_OUT_OF_RANGE, EE_ARGS(0) );
        return ADVISORY_FAILURE;
    }

    /* # locs b4 pause cannot exceed # acqs - 1;
       uses advisory panel popup - JDM */  
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) 
    {
        if ( (exist(opslicecnt) > avmaxslicecnt) && existcv(opslicecnt) && existcv(opslquant) ) 
        {
            epic_error( use_ermes, "Number of ACQ_B4_Pause cannot exceed %-d", 
                        EM_PSD_ACQS_B4_EXCEEDED, EE_ARGS(1), INT_ARG, avmaxslicecnt );
            return ADVISORY_FAILURE;
        }

        if( existcv(opslquant) && (exist(opslquant) > avmax_asset_slquant) ) 
        {
            avmaxslquant = avmax_asset_slquant;
            epic_error( use_ermes, "Maximum number of slices is %d.", 
                        EM_PSD_MAX_SLICE, EE_ARGS(1), INT_ARG, avmaxslquant );
            return FAILURE;
        }
    }
    else if( cardt1map_flag && (acqs > 1) )
    {
        if ( (exist(opslicecnt) != 1) && existcv(opslicecnt)  ) 
        {
            epic_error( use_ermes, "Number of ACQ_B4_Pause cannot exceed %-d", 
                        EM_PSD_ACQS_B4_EXCEEDED, EE_ARGS(1), INT_ARG, 1 );
            avminslicecnt = 1;
            avmaxslicecnt = 1;
            return ADVISORY_FAILURE;
        }
    } else {
        if ( (exist(opslicecnt) > (acqs-1)) && existcv(opslicecnt) &&
             existcv(opslquant)  && (isProtocolOptimizing() == PSD_OFF) ) 
        {
            epic_error( use_ermes, "Number of ACQ_B4_Pause cannot exceed %-d", 
                        EM_PSD_ACQS_B4_EXCEEDED, EE_ARGS(1), INT_ARG, (acqs-1) );
            avminslicecnt = acqs - 1;
            avmaxslicecnt = acqs - 1;
            return ADVISORY_FAILURE;
        }
    }

    /* TE < min or TE > max uses advisory panel popup */
    if( existcv(opautote) && (PSD_OFF == exist(opautote)) ) {
        if( existcv(opte) ) {
            if( exist(opte) < avminte ) {
                epic_error( use_ermes, "The selected TE must be increased "
                            "to %3.1f ms for the current prescription.",
                            EM_PSD_FLOAT_MINTE_OUT_OF_RANGE, EE_ARGS(1),
                            FLOAT_ARG, ((FLOAT)avminte / (FLOAT)1ms) );
                return ADVISORY_FAILURE;
            }

            if( exist(opte) > avmaxte ) {
                epic_error( use_ermes, "The selected TE must be decreased "
                            "to %3.1f ms for the current prescription.",
                            EM_PSD_FLOAT_MAXTE_OUT_OF_RANGE, EE_ARGS(1),
                            FLOAT_ARG, ((FLOAT)avmaxte / (FLOAT)1ms) );
                return ADVISORY_FAILURE;
            }
        }
    }

    /* TR < min or TR > max uses advisory panel popup */
    if( existcv(opautotr) && (PSD_OFF == exist(opautotr)) && existcv(optr) ) 
    {
        if( exist(optr) < avmintr ) 
        {
            epic_error( use_ermes, "The selected TR needs to be increased "
                        "to %3.1f ms for the current prescription.", 
                        EM_PSD_FLOAT_MINTR_OUT_OF_RANGE, EE_ARGS(1),
                        FLOAT_ARG, ((FLOAT)avmintr / (FLOAT)1ms) );
            return ADVISORY_FAILURE;
        }

        if( exist(optr) > avmaxtr ) 
        {
            epic_error( use_ermes, "The selected TR needs to be decreased "
                        "to %3.1f ms for the current prescription.", 
                        EM_PSD_FLOAT_MAXTR_OUT_OF_RANGE, EE_ARGS(1),
                        FLOAT_ARG, ((FLOAT)avmaxtr / (FLOAT)1ms) );
            return ADVISORY_FAILURE;
        }
    }

    /* Begin ASSET */
    if( existcv(opasset) && (ASSET_OFF != exist(opasset)) )
    {
        if( (exist(oppseq) == PSD_PCSP)|| (!(feature_flag & FIESTA) &&
                                           (feature_flag & FASTCARD) && !(cineir_flag)) 
            || (feature_flag & ECHOTRAIN) )
        {
            epic_error( use_ermes,
                        "ASSET option is not compatible with this Pulse Sequence.",
                        EM_PSD_NO_ASSET_SCAN, EE_ARGS(0) );
            return FAILURE;
        }

        if( ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) && (TRM_ZOOM_COIL == exist(opgradmode)) ) {
            epic_error( use_ermes,
                        "ASSET Calibration is not supported with ZOOM gradient mode.",
                        EM_PSD_ASSET_ZOOM_INCOMPATIBLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }

        /*MRIhc01471: patient position check is removed for asset and calib scan
         * since it is checked by host*/

        /* MRIhc00484 */
        if( (ASSET_SCAN == exist(opasset)) && (exist(opnex) > 1) && !pcfiesta_flag && !mde_flag &&
            (!(feature_flag & FASTCARD_PC)))

        {
            epic_error( use_ermes,
                        "%s is incompatible with %s",
                        EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                        STRING_ARG, "ASSET",
                        STRING_ARG, "a multiple NEX prescription" );
            return FAILURE;
        }

        /* HCSDM00254106 enable ASSET R<=1.5 with multiple NEX for MDE */
        if( (ASSET_SCAN == exist(opasset)) && (exist(opnex) > 1) &&
            mde_flag && (1.5 < exist(opaccel_ph_stride)) )
        {
            epic_error(use_ermes, "Phase Acceleration is out of range",
                       EM_PSD_CV_OUT_OF_RANGE,EE_ARGS(1),
                       STRING_ARG,"Phase Acceleration");
            return FAILURE;
        }
    }

    if(PSD_ON == exist (opassetscan) &&  (exist(opaccel_ph_stride) > 2.0) && existcv(opaccel_ph_stride) && value_system_flag ) {
        epic_error(use_ermes, "Phase Acceleration is out of range", 
                   EM_PSD_CV_OUT_OF_RANGE,EE_ARGS(1),STRING_ARG,"Phase Acceleration");
        return FAILURE;
    }        

    /* MRIhc03165: For ASSET calibration, full echo mode is essential (for good IQ). Some 3T prescriptions with small 
       slice thickness turn into fractional echo mode. To ensure the calibration scan is in full echo mode, the
       following check (the user will be asked to increase slice thickness if in fractional echo mode) was added. */
    if( ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref)) && (B0_30000 == cffield) && (act_te < min_tenfe) )  {
        epic_error( 0, "Please increase slice thickness.", 0, EE_ARGS(0) );
        return FAILURE;
    }
    /* End ASSET */

    /* check for DUALECHO ALP */ /* DUALECHO BWL */
    if( exist(opnecho) >= 2 ) 
    {
        if( !(feature_flag & MERGE) && !(feature_flag & MFGRE) && !r2_flag )
        {
            if( (opnex > avmaxnex)  && existcv(opnex) ) {
                epic_error( use_ermes,
                            "fgre dual echo does not support multi-nex scans.",
                            EM_PSD_NEX_OUT_OF_RANGE, 0 );
                avminnex = 0.0;
                avmaxnex = 1.0;
                return ADVISORY_FAILURE;
            }

            if( exist(opfcomp) == PSD_ON ) {
                epic_error( use_ermes,
                            "fcomp is not supported with Fat/Water in/out-of phase option.",
                            EM_PSD_FCOMP_FWINOUT_INCOMPATIBLE, EE_ARGS(0) );
                return ADVISORY_FAILURE;
            }

            /* MRIge82338 added check for BW depending on the field strenght */
            /* MRIge92350 - For 1.5T Dual Echo, allowed rBW is no longer just 62.5 and 125.0. */
            if( cffield < B0_15000 ) {
                if( (existcv(oprbw)) && 
                    ((!floatsAlmostEqualEpsilons(exist(oprbw), 62.5, 2)) && 
                     (!floatsAlmostEqualEpsilons(exist(oprbw), 125.0, 2))) ) {
                    epic_error( use_ermes, "The minimum bandwidth is %4.1f KHz.",
                                EM_PSD_MIN_RBW, EE_ARGS(1), FLOAT_ARG, 62.5 );
                    return ADVISORY_FAILURE;
                }
            }
        } else {
            if( (!floatsAlmostEqualEpsilons(opnex, 1.0, 2) && !floatsAlmostEqualEpsilons(opnex, 2.0, 2))  && 
                existcv(opnex) ) {
                epic_error( use_ermes,
                            "MERGE does not support this nex",
                            EM_PSD_NEX_OUT_OF_RANGE, 0 );
                /* HCSDM00477775 */
                if(opnex < 1.0)
                {
                    avminnex = 1.0;
                    avmaxnex = 1.0;
                }
                else
                {
                    avminnex = 2.0;
                    avmaxnex = 2.0;
                }
                return ADVISORY_FAILURE;
            }

            if(!(feature_flag & MFGRE) && !r2_flag)
            {
                if((exist(opobplane) != PSD_AXIAL || exist(opplane) == PSD_SAG 
                    || exist(opplane) == PSD_COR) && cffield == B0_30000 
                   && exist(oprbw) < 41.66 && existcv(oprbw) == PSD_ON)
                {
                    epic_error( use_ermes, "The minimum bandwidth is %4.2f KHz.",
                                EM_PSD_MIN_RBW, 1, FLOAT_ARG, 41.67 );
                    return FAILURE;

                }
            }
        }

        if( exist(opexor) == PSD_ON ) {
            epic_error( use_ermes,
                        "This database does not support Respiratory Compensation.",
                        EM_PSD_RESP_INCOMPATIBLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }
        if(!(feature_flag & MFGRE) && !r2_flag)
        {
            if( exist(opcgate) == PSD_ON ) {
                epic_error( use_ermes,
                            "Cardiac Gating is not supported by this pulse sequence.",
                            EM_PSD_GATING_INCOMPATIBLE, EE_ARGS(0) );
                return ADVISORY_FAILURE;
            }
        }
        if( exist(opirmode) == PSD_ON ) {
            epic_error( use_ermes, "Sequential option not supported",
                        EM_PSD_ILEAV_SEQ_INCOMPATIBLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }

        if( exist(opmph) == PSD_ON ) {
            epic_error( use_ermes,
                        "The Multi-Phase Option is not available with this pulse sequence.",
                        EM_PSD_OPMPH_INCOMPATIBLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }
        if( PSD_ON == cmon_flag ) {
            epic_error( use_ermes,
                        "Cardiac Compensation is not available with this PSD.",
                        EM_PSD_CMON_PSEQ_INCOMPATIBLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }

        if( exist(oprealtime) == PSD_ON ) {
            epic_error( use_ermes,
                        "Realtime Imaging Option is not available with this Pulse Sequence.",
                        EM_PSD_RTIA_REALTIME_NOT_AVAILABLE, EE_ARGS(0) );
            return ADVISORY_FAILURE;
        }

        if( (feature_flag & MFGRE) || r2_flag ) {
            /*if( (fullte_flag == PSD_OFF) && (intte_flag > 1) && (pos_read == PSD_OFF) ) {
              epic_error( use_ermes, "%s is incompatible with %s",
              EM_PSD_INCOMPATIBLE, EE_ARGS(2),
              STRING_ARG, "Interleaving echo with alternating readout",
              STRING_ARG, "fractional echo" );
              return FAILURE;
              }*/
            /* GEHmr01949: prohibit fractional echo with alternating readout until
               the Functool issue is resolved. */
            if( (fullte_flag == PSD_OFF) && (pos_read == PSD_OFF) ) {
                epic_error( use_ermes, "%s is incompatible with %s",
                            EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                            STRING_ARG, "Alternating readout",
                            STRING_ARG, "fractional echo" );
                return FAILURE;
            }
        }
    }

    if ( (exist(opnecho) > avmaxnecho) && existcv(opnecho) ) {
        epic_error( use_ermes, "Maximum number of echos is %-d", 
                    EM_PSD_NECHO_OUT_OF_RANGE, 1, INT_ARG, avmaxnecho);
        return FAILURE;
    }

    /* check for Exorcist and odd/even nex NPW.. MHN */
    if ( (opexor == PSD_ON) &&
         ((isOddNexGreaterThanOne) || (isNonIntNexGreaterThanOne)) ) {
        epic_error(use_ermes," Odd NEX is not supported with Resp. Comp.",
                   EM_PSD_ODDNEX_WITH_RESPCOMP_INCOMPATIBLE,0);
        return FAILURE;
    }

    if ( existcv(oppseq) && (never_mind == PSD_OFF) &&
         (exist(oppseq) != PSD_GE) && (exist(oppseq) != PSD_SPGR) &&
         (exist(oppseq) != PSD_TOFSP) && (exist(oppseq) != PSD_TOF) &&
         (exist(oppseq) != PSD_SSFP) && (exist(oppseq) != PSD_3PLANELOC) ) {
        epic_error( use_ermes, 
                    "GRASS or SPGR must be selected for "
                    "Fast Gradient Recalled Imaging.", 
                    EM_PSD_FGRE_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    /* Don't allow interleave option with single slice scans */
    if( existcv(opileave) && (PSD_ON == exist(opileave)) &&
        existcv(opslquant) && (1 == exist(opslquant)) ) {
        epic_error( use_ermes, "The interleaved option is not "
                    "supported when 1 slice/location is selected",
                    EM_PSD_FGRE_MPH_INT_SINGLE_INCOMPATABLE, EE_ARGS(0) );
        return FAILURE;
    }

    /* This check disables phase contrast */
    /* Added check for CMON - LX2 */
    if ( (exist(oppseq)  == PSD_PC)  &&
         (exist(opcgate) == PSD_OFF) &&
         (cmon_flag      == PSD_OFF) ) {
        epic_error(use_ermes,"Phase Contrast without "
                   "Cardiac Gating is Incompatible",
                   EM_PSD_FGRE_PCWITHOUTCG_INCOMPATIBLE,0);
        return FAILURE;
    }

    /* Check for 2D image mode */
    if ( ((exist(opimode) != PSD_2D)) && existcv(opimode) ) {
        epic_error( use_ermes, "Invalid image mode selected (2D only).", 
                    EM_PSD_IM_INCOMPATIBLE, 0 );
        return FAILURE;
    }

@inline FlexibleNPW.e fNPWcheck2

    /* another fractional nex check, uses advisory panel popup - JDM */
    if ( (fn<1)&& (nex > 1) && existcv(opnex) ) {
        epic_error( use_ermes, 
                    "fgre does not support multi-nex fractional nex scans.", 
                    EM_PSD_FAST_MNFE_INCOMPATIBLE, 0 );
        avminnex = 1.0;
        avmaxnex = 1.0;
        return ADVISORY_FAILURE;
    }

    /* 0.5 nex is not supported for single-shot MDE acquisition */
    if ( (sshmde_flag || sshmdespgr_flag || cardt1map_flag) && 
         floatsAlmostEqualEpsilons(0.5, exist(opnex), 2) ) {
        epic_error( use_ermes,
                    "The selected number of excitations is not valid for the current prescription.",
                    EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
        return ADVISORY_FAILURE;
    }

    /* HCSDM00367496  Moved Fractional NEX check to frac_neck_check() */

    /* HCSDM00367496 */
    {
        int rtnval;
        rtnval = frac_nex_check();
        if(rtnval != SUCCESS)
        {
            return rtnval;
        }
    }

    /* VAL15 YI 02/21/2005 */
    /* SVBranch to let popup NEX information more correct for FIESTA-C */
    if(pc_mode < PC_BASIC){
        if( ( (exist(opnex) < 2) || (exist(opnex) > 16) ) && existcv(opnex) ){
            epic_error( use_ermes, "The selected number of excitations is not valid for the current prescription.", EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
            avminnex = 2;
            avmaxnex = 16;
            return ADVISORY_FAILURE;
        }
        if( (isNonIntNexGreaterThanOne) && existcv(opnex) ){
            epic_error( use_ermes, "The selected number of excitations is not valid for the current prescription.", EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
            return FAILURE;
        }
    }

    /* HCSDM00367496  Moved check for NPW on MERGE and MGRE to frac_nex_check() */

    if( ((ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref))
        && existcv(opnex) && ((exist(opnex) < avminnex) || (exist(opnex) > avmaxnex)) ) {
        epic_error( use_ermes, "The selected number of excitations is not valid for the current prescription.", EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
        return ADVISORY_FAILURE;
    }

    /* Let these checks be caught in feature cvchecks of 
       Echotrain realtime and RTIA 98 for consistent 
       incompatibility error messages with realtime - RJF */

    if ( (exist(opblim) == PSD_ON) && existcv(opblim) &&
         (!(feature_flag & RTIA98 )) && 
         (!((feature_flag & ECHOTRAIN) && exist(oprealtime)== PSD_ON))) {
        epic_error( use_ermes, 
                    "fgre does not support the Classic option", 
                    EM_PSD_CLASSIC_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    if ( (exist(oppomp) == PSD_ON) && existcv(oppomp) &&
         (!(feature_flag & RTIA98)) && 
         (!((feature_flag & ECHOTRAIN) && exist(oprealtime) == PSD_ON)) ) {
        epic_error( use_ermes, 
                    "fgre does not support the pomp option", 
                    EM_PSD_POMP_INCOMPATIBLE, 0 );
        return FAILURE;
    }

    /******************************
     *  Feature dependent checks  *
     ******************************/

    /* Begin RTIA */
    /* RTIA checks need to come first. */
    if ( SUCCESS != (status = RTIA_cvcheck( feature_flag )) ) {
        return status;
    } 
    /* End RTIA */

    if ( cs_sat ) {
        if ( FAILURE == ChemSat_Check( use_ermes, feature_flag )) {
            return FAILURE;
        }
    }

    if ( FAILURE == SpSatCheck()) {
        return FAILURE;
    }

    if ( FAILURE == mph_cvcheck(feature_flag)) {
        return FAILURE;
    }

    if ( SUCCESS != (status = prep_cvcheck( feature_flag )) ) {
        return status;
    } 

    if ( SUCCESS != (status = fastcard_cvcheck( avmintdel1, avmaxtdel1,
                                                avail_image_time, tmin_total, 
                                                avmaxphases, feature_flag,
                                                use_ermes )) ) {
        return status;
    }

    if ( SUCCESS != (status = fastcardPC_cvcheck( feature_flag, use_ermes )) ) {
        return status;
    }

    if ( fmpvas_cvcheck( avail_image_time, tmin_total, act_tr,
                         avmaxphases, viewoffs, phorder, cmon_flag,
                         use_ermes, feature_flag ) == FAILURE ) {
        return FAILURE;
    } 

    /******************************
     *  CMON feature check - LX2  *
     ******************************/
    if( (PSD_ON == cmon_flag)  &&
        (exist(oppseq) == PSD_TOF || exist(oppseq) == PSD_TOFSP) ) {
        epic_error(use_ermes, "TOF is not compatible with cmon",
                   EM_PSD_CMON_SELECTION, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) && (exist(oppseq) == PSD_PC) ) {
        epic_error(use_ermes, "Phase Contrast is not compatible with cmon",
                   EM_PSD_CMON_SELECTION, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        (existcv(opmph) && exist(opmph) == PSD_ON) ) {
        epic_error(use_ermes, "Multi-phase is not compatible with cmon",
                   EM_PSD_CMON_MPH_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        (existcv(opcgate) && exist(opcgate) == PSD_ON) ) {
        epic_error(use_ermes, "Cardiac gating is not compatible with cmon",
                   EM_PSD_CMON_GATING_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        (existcv(opirprep) && exist(opirprep) == PSD_ON) ) {
        epic_error(use_ermes, "IR Prep is not compatible with cmon",
                   EM_PSD_CMON_IRPREP_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        (existcv(opsrprep) && exist(opsrprep) == PSD_ON) ) {
        epic_error(0*use_ermes, "SR Prep is not compatible with cmon",
                   EM_PSD_CMON_IRPREP_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        (existcv(opdeprep) && exist(opdeprep) == PSD_ON) ) {
        epic_error(use_ermes, "DE Prep is not compatible with cmon",
                   EM_PSD_CMON_DEPREP_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) &&
        ((isOddNexGreaterThanOne) || (isNonIntNexGreaterThanOne)) ) {
        epic_error(use_ermes, "Odd NEX is not supported with CMON.",
                   EM_PSD_CMON_ODDNEX_INCOMPATIBLE, 0);
        return FAILURE;
    }

    if( (PSD_ON == cmon_flag) && existcv(opnex) ) {
        /*  MRIge78873 - NEX should be less than 4 when CCOMP = 1 */
        if( exist(opnex) > 3.0 ) {
            epic_error( use_ermes, "The selected number of excitations is "
                        "not valid for the current prescription.",
                        EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0) );
            return FAILURE;
        }
    }

    /* Fast CINE - 26/Jan/1998 - GFN */
    if ( FAILURE == fcine_cvcheck( feature_flag, use_ermes ) ) {
        return FAILURE;
    }

    /* Respiratory Gating - 08/Oct/1997 - GFN */
    if ( FAILURE == respgate_cvcheck( feature_flag, use_ermes ) ) {
        return FAILURE;
    }

    /* FIESTA2D - 13/Nov/2000 - GFN */
    if ( SUCCESS != (status = fiesta2d_cvcheck( feature_flag, use_ermes )) ) {
        return status;
    }

    /* Tagging - 04/Jun/97 - GFN */
    if ( FAILURE == tagging_cvcheck( feature_flag, use_ermes ) ) {
        return FAILURE;
    }

    /* JAP ET */
    if ( SUCCESS != (status = et_cvcheck( perf_option_key_status, fullte_flag, etl, exist(opnex), 
                                          exist(oppseq), exist(opsat),
                                          rhnframes + temp_rhhnover, exist(opvps), 
                                          feature_flag )) ) {
        return status;
    }

    if ((PSD_ON == mde_flag) && (PSD_ON == exist(opspecir)) && (fsmde_support) && (PSD_OFF == mdeplus_option_key_status))
    {
        epic_error( use_ermes,
                    "%s is not available without the option key.",
                    EM_PSD_FEATURE_OPTION_KEY, EE_ARGS(1),
                    STRING_ARG, "Fat Sat MDE" );
        return FAILURE;
    }

@inline ZoomGradLimit.e ZoomGradPrep

    /* to fix SPR MRIge66282 - running SPT with zoom gradient 
       (Dan Gamliel, May 31, 2001) */
    if( strcmp( "fgrespt", get_psd_name() ) == 0 ) {
        index_limit = -1;
    }
    /*MRIge91882*/
    if(((exist(oppseq)==PSD_GE)||(exist(oppseq)==PSD_3PLANELOC))&&(exist(opplane)==PSD_3PLANE)&&
       !(feature_flag&IRPREP)&& !(feature_flag & FIESTA)){
        if (exist(opmultistation)) {
            if ( (_opuser0.minval > exist(opuser0)) ||
                 (_opuser0.maxval < exist(opuser0)) ) {
                _opuser0.fixedflag = 0;
                opuser0 = (float)opnostations;
                _opuser0.fixedflag = 1;
                epic_error( use_ermes ,"%s is out of range.",
                            EM_PSD_CV_OUT_OF_RANGE, 1,
                            STRING_ARG, "Number of Stations" );
                return FAILURE;		      
            }
        }

        if ( !firstSeriesFlag &&
             pimultistation &&
             (exist(opmultistation) == PSD_OFF) ) {
            epic_error( use_ermes,
                        "MultiStation option should not be changed for this station",
                        EM_PSD_MULTISTATION_FIXED, 0 );
            return FAILURE;
        }


        if ( (pimultistation == PSD_OFF) &&
             ( (exist(opmultistation) == PSD_ON) ||
               (opnostations != 1) ) ) {
            epic_error( use_ermes,
                        "MultiStation is not available without option key",
                        EM_PSD_MULTISTATION_OPTION_KEY, 0 );
            return FAILURE;
        }   

    }

    if( ThreePlaneCheck() == FAILURE ) {
        epic_error( use_ermes, "%s is incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "The selected imaging option",
                    STRING_ARG, "3-Plane prescription" );
        return FAILURE;		
    }

    if( existcv(opuser8) )
    {
        float tmpf;
        tmpf = fabs(exist(opuser8)-(int)exist(opuser8));
        if ((_opuser8.minval > exist(opuser8)) || (_opuser8.maxval < exist(opuser8)) ||
            (1.0E-6<tmpf))
        {
            /* Set "good" default value */
            cvoverride(opuser8, _opuser8.defval, PSD_FIX_ON, PSD_EXIST_ON);

            /* Display an error message */
            epic_error( use_ermes ,"%s is out of range.",
                        EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1),
                        STRING_ARG, "RF1 Type (userCV8)" );
            return FAILURE;
        }
    }

    if( existcv(opuser9) &&
        ((_opuser9.minval > exist(opuser9)) ||
         (_opuser9.maxval < exist(opuser9))) )
    {
        /* Set "good" default value */
        cvoverride(opuser9, _opuser9.defval, PSD_FIX_ON, PSD_EXIST_ON);

        /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, EE_ARGS(1),
                    STRING_ARG, "Processing" );
        return FAILURE;
    }

    if( existcv(opuser16) && ((_opuser16.minval > exist(opuser16)) ||
                              (_opuser16.maxval < exist(opuser16)) || !floatIsInteger(exist(opuser16))) )
    {
        /* Set "good" default value */
        cvoverride(opuser16, _opuser16.defval, PSD_FIX_ON, PSD_EXIST_ON);

        /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "User CV16" );
        return FAILURE;
    }

    if( existcv(opuser17) && ((_opuser17.minval > exist(opuser17)) ||
                              (_opuser17.maxval < exist(opuser17))) )
    {
        /* Set "good" default value */
        cvoverride(opuser17, _opuser17.defval, PSD_FIX_ON, PSD_EXIST_ON);

        /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "Number of interleaving echo trains" );
        return FAILURE;
    }

    if( existcv(opuser18) && ((_opuser18.minval > exist(opuser18)) ||
                              (_opuser18.maxval < exist(opuser18))) )
    {
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "User CV18" );
        return FAILURE;
    }

    if( existcv(opuser19) )
    {
        if( (PSD_ON == cardt1map_flag) && 
            (!floatsAlmostEqualEpsilons(_opuser19.minval, exist(opuser19), 2) && 
             !floatsAlmostEqualEpsilons(_opuser19.maxval, exist(opuser19), 2)) ) 
        {
           epic_error( use_ermes, "%s must be set to either 0 or 1.",
                       EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, "CV19" );
           return FAILURE;
        }
        else if( (_opuser19.minval > exist(opuser19)) ||
                              (_opuser19.maxval < exist(opuser19)) )
    {
        /* Set "good" default value */
        cvoverride(opuser19, _opuser19.defval, PSD_FIX_ON, PSD_EXIST_ON);

        /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "Spatial Sat. Level" );
        return FAILURE;
    }
    }

    if( existcv(opuser22) && ((_opuser22.minval > exist(opuser22)) ||
                              (_opuser22.maxval < exist(opuser22))) )
    {
        /* Set "good" default value */
        cvoverride(opuser22, _opuser22.defval, PSD_FIX_ON, PSD_EXIST_ON);

        /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "CV22" );
        return FAILURE;
    }
    
    if( existcv(opuser23) && ((_opuser23.minval > exist(opuser23)) ||
                              (_opuser23.maxval < exist(opuser23))) )
    {
        /* Set "good" default value */
        cvoverride(opuser23, _opuser23.defval, PSD_FIX_ON, PSD_EXIST_ON);

         /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "CV23" );
        return FAILURE;
    }

    if( existcv(opuser23) && !floatIsInteger(exist(opuser23)) && 
       (PSD_OFF == cardt1map_flag) )
    {
        epic_error( use_ermes, "%s must be set to either 0 or 1.",
                    EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, "User CV23" );
        return FAILURE;
    }

    if( existcv(opuser6) && ((_opuser6.minval > exist(opuser6)) ||
                              (_opuser6.maxval < exist(opuser6))) )
    {
        /* Set "good" default value */
        cvoverride(opuser6, _opuser6.defval, PSD_FIX_ON, PSD_EXIST_ON);

         /* Display an error message */
        epic_error( use_ermes ,"%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "CV6" );
        return FAILURE;
    }

    if( existcv(opuser6) && !floatIsInteger(exist(opuser6)) )
    {
        epic_error( use_ermes, "%s must be set to either 0 or 1.",
                    EM_PSD_CV_0_OR_1, EE_ARGS(1), STRING_ARG, "User CV6" );
        return FAILURE;
    }

    if ( (optouchfreq > avmaxtouchfreq) || (optouchfreq < avmintouchfreq) )
    {
        epic_error( use_ermes, "%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "MR-Touch MEG Frequency" );
        return ADVISORY_FAILURE;
    }

    if ( (optouchamp> avmaxtouchamp) || (optouchamp < avmintouchamp) )
    {
        epic_error( use_ermes, "%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "MR-Touch Driver Amplitude" );
        return ADVISORY_FAILURE;
    }

    if ( (optouchcyc > avmaxtouchcyc) || (optouchcyc < avmintouchcyc) )
    {
        epic_error( use_ermes, "%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "MR-Touch Driver Cycle per Trigger" );
        return ADVISORY_FAILURE;
    }

    if ( (optouchtphases > avmaxtouchtphases) || (optouchtphases < avmintouchtphases) )
    {
        epic_error( use_ermes, "%s is out of range.",
                    EM_PSD_CV_OUT_OF_RANGE, 1,
                    STRING_ARG, "MR-Touch Temporal Phases" );
        return ADVISORY_FAILURE;
    }

    if( (feature_flag & (FASTCARD | FASTCINE | FASTCARD_PC ))  && (PSD_ON == exist(oparc)) )
    {
        epic_error( use_ermes, "%s is incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "ARC",
                    STRING_ARG, "FastCINE or FastCard" );
        return FAILURE;
    }

    if (PSD_ON == track_flag)
    {
        if ( FAILURE  == track_cvcheck() )
        {
            return FAILURE;
        }
    }   

    if(cardt1map_flag) 
    {
        if(t1map_tothb > T1MAP_MAX_HB)
        {
            epic_error( use_ermes, "Maximum number of heartbeats per slice is %d.", 
                        EM_PSD_HB_OUT_OF_RANGE, EE_ARGS(1), INT_ARG, T1MAP_MAX_HB );
            return FAILURE;
        }

        if(exist(opslquant) > T1MAP_MAX_SLICES)
        {
            avmaxslquant = T1MAP_MAX_SLICES;
            epic_error( use_ermes, "Maximum number of slices is %d.", 
                        EM_PSD_MAX_SLICE, EE_ARGS(1), INT_ARG, T1MAP_MAX_SLICES );
            return ADVISORY_FAILURE;
        }
    }

@inline ZoomGradLimit.e ZoomGradCheck
@inline ARC.e ARCCheck

    /* Limit to Sagittal scan plane only */
    if(gradspec_flag)
    {
        if(isHRMbSystem())
        {
            if(PSD_AXIAL != exist(opplane))
            {
                epic_error(use_ermes, "%s plane must be selected for %s.",
                        EM_PSD_PLANE_SELECTION, 2, STRING_ARG, "Axial",
                        STRING_ARG, "PSD fgre_gradspec");
                return FAILURE;
            }

        }
        else
        {
            if(PSD_SAG != exist(opplane))
            {
                epic_error(use_ermes, "%s plane must be selected for %s.",
                        EM_PSD_PLANE_SELECTION, 2, STRING_ARG, "Sagittal",
                        STRING_ARG, "PSD fgre_gradspec");
                return FAILURE;
            }
        }
    }

    if ( PSD_ON == oprealtime && floatsAlmostEqualEpsilons(opnex, 1.5, 2) )
    {
        epic_error( use_ermes, "%s is incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "Realtime",
                    STRING_ARG, "1.5NEX" );
        return ADVISORY_FAILURE;
    }

    if (perfusion_flag)
    {
        if ( existcv(opslquant) && existcv(ophrate) && existcv(opautote) &&
             (exist(opslquant) < avminslquant) )
        {
            epic_error( use_ermes, "The number of scan locations must"
                        " be increased to %-d for the current"
                        " prescription.\n",EM_PSD_SLQUANT_OUT_OF_RANGE,
                        EE_ARGS(1), INT_ARG, avminslquant);
            return ADVISORY_FAILURE;
        }

        if ( existcv(opslthick) && existcv(ophrate) && existcv(opautote) &&
             (exist(opslthick) > avmaxslthick) )
        {
            epic_error( use_ermes, "Reduce the slice thickness to %.1f",
                        EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1), FLOAT_ARG, avmaxslthick );
            return ADVISORY_FAILURE;
        }

        extern int tseq_prep_minimum;
        avmaxslquant =(int)((avail_image_time)
                             / (act_tr * (rhnframes + temp_rhhnover + dda) + tseq_prep_minimum));

        if (avmaxslquant<1)
        {
            epic_error( use_ermes, "Insufficient available time. "
                        "Reduce trigger window or views per seg",
                        EM_PSD_FASTCARD_VPS_OR_TRIGWINDOW_TO_BE_DECREASED,
                        EE_ARGS(0) );
            return FAILURE;
        }
    }

    if(existcv(opslthick) && (exist(opslthick) < avminslthick))
    {
        epic_error( use_ermes, "Increase the slice thickness to %.1f",
                EM_PSD_SLTHICK_OUT_OF_RANGE, EE_ARGS(1),
                FLOAT_ARG, avminslthick );
        return ADVISORY_FAILURE;
    }

    if( (PSD_ON == exist(opairspeed)) && ((PSD_SSFP != exist(oppseq)) || (PSD_OFF == exist(opcgate))) )
    {
        epic_error( use_ermes, "%s is incompatible with %s",
            EM_PSD_INCOMPATIBLE, EE_ARGS(2),
            STRING_ARG, "Sonic DL",
            STRING_ARG, "non FIESTA-CINE mode");
        return FAILURE;
    }

    return SUCCESS;
}   /* end cvcheck() */

/* HCSDM00367496 */
STATUS
frac_nex_check()
{
    /* Fractional nex incompatable with phase contrast as homodyne recon
       removes phase info needed for phase contrast */
    if( (exist(oppseq)  == PSD_PC ) && (fn < 1) ) {
        epic_error( use_ermes,
                    "%s incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "Fractional NEX",
                    STRING_ARG, "Phase Contrast" );
        avminnex = 1.0;
        return ADVISORY_FAILURE;

    }

    /* MRIge90793: Fractional nex incompatible with 2D FIESTA Fat SAT due to bad
       fat suppression effect, further investigation needed to open this up */
    if( (exist(oppseq)  == PSD_SSFP ) && (!sshmde_flag) && (feature_flag & SPECIR) && (fn < 1) ) {
        epic_error( use_ermes,
                    "%s incompatible with %s",
                    EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                    STRING_ARG, "Fractional NEX",
                    STRING_ARG, "2D Fat SAT Fiesta" );
        avminnex = 1.0;
        return ADVISORY_FAILURE;
    }


    if ( (exist(opzip512) == PSD_ON) && ((existcv(opxres) && exist(opxres) > 512) || (existcv(opyres) && exist(opyres) > 512 ) ) )
    {
        epic_error(use_ermes,"%s is incompatible with %s",EM_PSD_INCOMPATIBLE,
                    EE_ARGS(2),STRING_ARG,"512 ZIP",STRING_ARG,"larger than 512 Resolution");
        return FAILURE;
    }

    if ( (exist(opzip1024) == PSD_ON) && ((existcv(opxres) && exist(opxres) > 1024) || (existcv(opyres) && exist(opyres) > 1024 ) ) )
    {
        epic_error(use_ermes,"%s is incompatible with %s",EM_PSD_INCOMPATIBLE,
                    EE_ARGS(2),STRING_ARG,"1024 ZIP",STRING_ARG,"larger than 1024 Resolution");
        return FAILURE;
    }

    /* We should check for the existence of opautote to post error*/
    /* RJF, 30, Nov 98 */
    /* Note that combinations of inphase or out of phase TE's
       can choose fractional Echo with some combinations.
       So, this error message is not valid here .. Throw an
       advisory pop-up for NEX  RJF, 7 Jan 99 */
    if (((PSD_OFF == fullte_flag) && ( existcv(opautote) )) && ( 1 > fn) &&
        (!perfusion_flag) ) {
        /* MRIge50505 - Make sure the minimum is right for NPW */
        avminnex = 1.0;
        return ADVISORY_FAILURE;
    }

    /* SVBranch HCSDM00150916. Forbid prescribing 0.5 NEX with minimum TE for FGRE-TC.*/
    if (((PSD_OFF == fullte_flag) && ( existcv(opautote) )) && ( 0.5 >= fn) &&
        (perfusion_flag) )
    {
        epic_error( use_ermes, "The selected number of excitations is not valid. Increase NEX or select Minfull TE.",
                    EM_PSD_NEX_OUT_OF_RANGE, EE_ARGS(0));
        return ADVISORY_FAILURE;
    }

    if ( (fn < 1.0) && (exist(opnpwfactor) > 1.0) &&
         existcv(opnex) && existcv(opnpwfactor) &&
         ((feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag) ) {
        epic_error( use_ermes,
                    "This Nex is not valid when No Phase Wrap is selected.",
                    EM_PSD_15NEX_INCOMPATIBLE, 0 );

        avminnex = 1.0;           /* MRIge44601 - pop up advisory panel */
        avmaxnex = 1.0;
        return ADVISORY_FAILURE;
    }

    if( ((feature_flag & GATEDTOF) || (feature_flag & UNGATEDTOF) || (feature_flag & ECHOTRAIN)) && (isNonIntNexGreaterThanOne == PSD_ON) )
    {
        epic_error( use_ermes, "Bad fractional NEX selected.",
                    EM_PSD_FNEX_OUT_OF_RANGE, 0 );
        avminnex = exist(opnex) - 0.5;
        avmaxnex = exist(opnex) - 0.5;
        return ADVISORY_FAILURE;
    }

    return SUCCESS;
}

/*
 *  predownload
 * 
 *  Type: Function
 *
 *  Description:
 *    This section will be executed before a download. Its purpose
 *    is to execute all operations that are not needed for the 
 *    advisory panel results. All code created by the pulsegen
 *    macro exspansions for the predownload section will be
 *    executed here. All internal amplitudes, slice ordering, 
 *    prescan slice calculation, sat placement calculation are
 *    done here.
 * 
 *    Setting up the time anchors also for pulsegen will be done here.
 */
STATUS
predownload( void )
{
    INT temp_seqtype;
    INT i, j;                       /* counters */
    INT sloff;                      /*MRIge91361*/ 
    INT cv_statepos = 0;
    INT cv_stateneg = 0;   /* modify cv state for satgapz */
    INT true_slquant1 = 0;

@inline vmx.e PreDownLoad  /* vmx - 26/Dec/94 - YI */

    /* MRIge64038 - Set receiver phase chop ON by default for all FGRE-based
       scans.  This can be reset by the individual predownload() calls in the
       feature modules. */
    rcphase_chop = 1;

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* set scale to 0 to avoid safety check fail */
    if(sbm_flag)
    {
        sbm_gx1_scale   = 0.0;
        sbm_gxw_scale   = 0.0;
        sbm_gxwex_scale = 0.0;
        sbm_gy1_scale   = 0.0;
        sbm_gy1r_scale  = 0.0;
        sbm_gz1_scale   = 0.0;
        sbm_gzk_scale   = 0.0;
    }

    /**********************
     *  Image Header CVs  *
     **********************/
    /* Turn OFF TI annotation by default.  This will be set by
       modules, if needed. */
    setexist(ihti, PSD_OFF);

    num_scanlocs = exist(opslquant);

    /* Set TE annotation */
    if( (feature_flag & MERGE) && rhfiesta !=0)
    {
        int temp_eff_te;
        temp_eff_te = act_te+(exist(opnecho)-1)*average_esp/2;

        ihte1 = temp_eff_te; /* mege_eff_te; */
    }
    else
        ihte1 = act_te;

    if ( vstrte_flag )
    {  
        ihtr = (int) 10.0*floor(ihtr/10.0);
        ihte1 = (int) 10.0*floor(opte/10.0);
    }

    /* Set TE2 annotation - DUALECHO */
    if ( exist(opnecho) >= 2 )
    {
        if ( (feature_flag & MFGRE) &&  (intte_flag > 1 ) && (pos_read == PSD_OFF))
        {
            int i, j, temp_ihte1, iecho;
            for(j = 0; j < intte_flag; j++)
            {
                temp_ihte1 = ihte1 + j*echo_spacing/intte_flag;
                for(i = 1; i <= exist(opnecho); i++)
                {
                    iecho = j*exist(opnecho)+i;
                    if( iecho == 2 )  ihte2  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 3 )  ihte3  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 4 )  ihte4  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 5 )  ihte5  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 6 )  ihte6  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 7 )  ihte7  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 8 )  ihte8  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 9 )  ihte9  = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 10 ) ihte10 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 11 ) ihte11 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 12 ) ihte12 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 13 ) ihte13 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 14 ) ihte14 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 15 ) ihte15 = temp_ihte1 + (i-1)*echo_spacing;
                    if( iecho == 16 ) ihte16 = temp_ihte1 + (i-1)*echo_spacing;
                }
            }
        }
        else if( fullte_flag == PSD_ON || pos_read == PSD_ON )
        {
            ihte2  = ihte1  + 1  * echo_spacing/intte_flag;
            ihte3  = ihte1  + 2  * echo_spacing/intte_flag;
            ihte4  = ihte1  + 3  * echo_spacing/intte_flag;
            ihte5  = ihte1  + 4  * echo_spacing/intte_flag;
            ihte6  = ihte1  + 5  * echo_spacing/intte_flag;
            ihte7  = ihte1  + 6  * echo_spacing/intte_flag;
            ihte8  = ihte1  + 7  * echo_spacing/intte_flag;
            ihte9  = ihte1  + 8  * echo_spacing/intte_flag;
            ihte10 = ihte1  + 9  * echo_spacing/intte_flag;
            ihte11 = ihte1  + 10 * echo_spacing/intte_flag;
            ihte12 = ihte1  + 11 * echo_spacing/intte_flag;
            ihte13 = ihte1  + 12 * echo_spacing/intte_flag;
            ihte14 = ihte1  + 13 * echo_spacing/intte_flag;
            ihte15 = ihte1  + 14 * echo_spacing/intte_flag;
            ihte16 = ihte1  + 15 * echo_spacing/intte_flag;
        }
        else
        {
            ihte2 = act_te2;
            ihte3  = ihte1  + 2  * average_esp;
            ihte4  = ihte2  + 2  * average_esp;
            ihte5  = ihte1  + 4  * average_esp;
            ihte6  = ihte2  + 4  * average_esp;
            ihte7  = ihte1  + 6  * average_esp;
            ihte8  = ihte2  + 6  * average_esp;
            ihte9  = ihte1  + 8  * average_esp;
            ihte10 = ihte2  + 8  * average_esp;
            ihte11 = ihte1  + 10 * average_esp;
            ihte12 = ihte2  + 10 * average_esp;
            ihte13 = ihte1  + 12 * average_esp;
            ihte14 = ihte2  + 12 * average_esp;
            ihte15 = ihte1  + 14 * average_esp;
            ihte16 = ihte2  + 14 * average_esp;
       }
    }

    if ( fn < 1 ) {
        ihnex = fn;
    } else {
        ihnex = truenex;
    }
  
    /* Set RBW annotation */
    ihvbw1 = oprbw;
    /* Set RBW2 annotation - DUALECHO */
    ihvbw2 = oprbw;
    ihvbw3  = oprbw;
    ihvbw4  = oprbw;
    ihvbw5  = oprbw;
    ihvbw6  = oprbw;
    ihvbw7  = oprbw;
    ihvbw8  = oprbw;
    ihvbw9  = oprbw;
    ihvbw10 = oprbw;
    ihvbw11 = oprbw;
    ihvbw12 = oprbw;
    ihvbw13 = oprbw;
    ihvbw14 = oprbw;
    ihvbw15 = oprbw;
    ihvbw16 = oprbw;

    /* Set Flip Angle annotation */
    ihflip = opflip;
    
    if ( gating == TRIG_INTERN ) {
        /* turn on dither for intern gating  */
        dither_on = PSD_ON;
    } else {
        /* turn off dither for intern gating  */
        dither_on = PSD_OFF;
    }

    /*****************************************
     *  Synchronizing gradients, rf and ssp  *
     *****************************************/

    /* Setsysparms sets the psd_grd_wait and psd_rf_wait
       parameters for the particular system. */
       if ( setsysparms() == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "setsysparms" );
        return FAILURE;
       }
    if (vstrte_flag) {
       psd_grd_wait = 60;
       if (PSD_XRMW_COIL == cfgcoiltype || PSD_IRMW_COIL == cfgcoiltype)
       {
           psd_rf_wait = 112;
       }
       if(isRioSystem() || isHRMbSystem())
       {
           /*HCSDM00453021*/
           psd_rf_wait = 94;
       }
    }

    /*********************
     *  Recon variables  *
     **********************/

    /* Added support for zip 512, the fermi radius and width values are
       not changed for product sequence, the change is reflected for ZIP512
       DUALECHO ALP */
    fermi_rc = (float)(1.0 / 2.0);
    fermi_wc = (float)1.0;

    if (PSD_OFF != hires_recon)
    {
        fermi_rc = (float)(9.0 / 16.0);
    }

    if ((feature_flag & MERGE) && ((int)exist(opuser8)>0))
    {
        fermi_rc = 0.5;
    }

    /* Adjust Fermi Radius and Width for ASSET */
    /* MRIhc10884: rhfermr for calibration scan is set to 12 regardless of matrix size */
    if( (ASSET_CAL == exist(opasset)) || (ASSET_REG_CAL == exist(opasset)) || (PSD_ON == pure_ref) ) {
        fermi_rc = (float)(12.0 / exist(opxres));   /* rhfermr = 12 (was 14) */  
        fermi_wc = (float)(2.0 / 10.0);    /* rhfermw = 2 (was 4) */
    }

    /* PURE Mix */
    model_parameters.gre2d.minph_pulse_index = minph_pulse_index;
    model_parameters.gre2d.spgr_flag = spgr_flag;
    model_parameters.gre2d.fiesta_flag = feature_flag & FIESTA;
    model_parameters.gre2d.mde_flag = mde_flag;

@inline loadrheader.e rheaderinit
@inline Asset.e AssetSetRhVars
@inline Genx.e GenxPredownload

    if(PSD_ON == mpl_discard_flag)
    {
        rhrawsize = (n64)(slquant1 - 2) * (n64)opnecho * (n64)rhfrsize * (n64)(2*rhptsize)
            * (n64)ceil((float)(1 + (rhbline * rawdata) + rhnframes + rhhnover)
                        * ((exnex * (float)(1 - rawdata)) + (truenex * (float)rawdata)));
    }

    if((feature_flag & MFGRE) || r2_flag) {
        rhnecho = exist(opnecho) * intte_flag;
        rhrawsize =(int)((float)(slquant1*(1+(rhbline*rawdata)+rhnframes+rhhnover)*2 
                                       *rhnecho*rhfrsize*rhptsize)
                                       *((float)(exnex*(1-rawdata))+(truenex*(float)rawdata))); 
    }

    if( (feature_flag & MERGE) || (feature_flag & MFGRE) || r2_flag )
    {
        eeff = !(pos_read);  /* even echo flip if not postive-only */
    }

    /* Set recon raw header vars for Fast CINE - 04/Jun/97 - GFN */
    if ( FAILURE == fcine_setrawheader( act_tr, feature_flag ) ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fcine_setrawheader" );
        return FAILURE;
    }

    /*MRIge91361*/    
    if (PSD_ON == pure_ref || PSD_ON == swift_cal) {
        rhnpasses = acqs*pass_reps; 
        rhnslices = exist(opslquant)*pass_reps; 
        rhreps = pass_reps; 
    }

    if( PSD_ON == swift_cal )
    {
        rhnumCoilConfigs=opncoils;
        rhswiftenable=3;
        rhnumslabs = 2;
    }
    else
    {
        rhnumCoilConfigs=1;
        rhswiftenable=0;
        rhnumslabs = 1;
    }

    /* MRIhc02932 -- turn off pure filter for tof scans */
    if( (exist(oppseq) == PSD_TOF) || (exist(oppseq) == PSD_TOFSP) || touch_flag ) {
        rhpurefilter = PSD_OFF;
    } else {
        rhpurefilter = PSD_ON;
    }   


    /* make sure the following recon cvs are set for homodyne recon */

    rhtype = rhtype | RHTYPGR;
    /* FIESTA2D - Set receiver chopping bit shifting */
    if( feature_flag & FIESTA ) 
    {
        rhtype |= RHTYPCHP;   /* since we are NOT doing receiver chop,
                                 DO bit shift in recon */
    } else {
        rhtype &= ~RHTYPCHP;   /* since we are doing receiver chop,
                                  don't bit shift in recon */
    }

    if ( ((isInh2DTOF && zerofill_flag) || ((feature_flag & MFGRE) || r2_flag)) && 
         (PSD_OFF == fullte_flag) )
    {
        rhtype &= ~RHTYPFRACTECHO; /* for Inh-2DIF with zerofill_flag or MFGRE+MINTE, 
                                      do zero padding instead of Homodyne */
    }

    /* VAL15 02/21/2005 YI */
    if( !(feature_flag & MERGE) )
    {
        if( PSD_ON == pcfiesta_flag ) {
            rhnecho = truenex;
            if(pc_mode == PC_APC)rhfiesta = 1;
            else if(pc_mode == PC_SGS)rhfiesta = 260;
            else rhfiesta = 3;
            if (exist(opfcine)==PSD_ON) rhfiesta+=512;
            rhrawsize = (int)((float)(slquant1*(1+(rhbline*rawdata)
                                                +rhnframes+rhhnover)*2
                                      *rhnecho*rhfrsize*rhptsize)
                              *((float)(exnex*(1-rawdata))+(truenex*(float)rawdata)));
            eeff = 0;
            eepf = 0;
            oeff = 0;
            oepf = 0;
        } else {
            rhfiesta = 0;
            rhnecho = exist(opnecho) * intte_flag;
        }
    }

    /* 0=standard recon(key the filter size off x_acq_size), 
       1=homodyne recon (key the filter size off fft size) */

    if (xres != exist(opxres))
    {
        rhtype1 |= RHTYP1HOMODYNE;
    }
    else
    {
        rhtype1 &= ~RHTYP1HOMODYNE;
    }

    if ( ((isInh2DTOF && zerofill_flag) || ((feature_flag & MFGRE) || r2_flag)) && 
         (PSD_OFF == fullte_flag) )
	{
        rhtype1 &= ~RHTYP1HOMODYNE;
    }

    /* Set rhdaxres, rhdayres and rhimsize */
    set_image_rh();

    rhscancent = piscancenter;
        
    rhslblank = 0;   /* this is set to 2 (pislblank) in loadrheader.e,
                        but recon uses it in calculation of whether
                        or not they have the last slice.  It should
                        be 0 for non-3d scans. */

    rhyoff = 0;


    if(cardt1map_flag)
    {
        if(MOLLI == cardt1map_mode) {
            rhrc_cardiac_ctrl = 2;
        } else if(SMART1MAP == cardt1map_mode) {
            rhrc_cardiac_ctrl = 1;
        }
        if(PSD_ON == t1map_TIupdate) {
            rhrc_cardiac_ctrl |= 4;
        } else {
            rhrc_cardiac_ctrl &= ~4;
        }
    }
    else if (perfusion_flag) 
    {
        rhrc_cardiac_ctrl = 8;
    }
    else
    {
        rhrc_cardiac_ctrl = 0;
    }

    
    if (PSD_ON == exist(opmoco))
    {
        rhrc_moco_ctrl = 1;

	/*When cardt1map_mode is MOLLI and  ON=T1fittingMoCo_flag,  T1fitting MoCo is enabled */

        if( cardt1map_flag && (MOLLI == cardt1map_mode) && T1fittingMoCo_flag)
        {
            rhrc_moco_ctrl |= 2;
        } 
        else 
        {
            rhrc_moco_ctrl &= ~2;
        }
    }
    else 
    {
        rhrc_moco_ctrl = 0;
    }

    if (rotateflag == PSD_ON) {
        rotatescan();
    }

    /********************
     *  Slice Ordering  *
     ********************/  
    if(((opnecho >= 2) && (exist(opcgate)==PSD_OFF)) || (PSD_ON == seq_sl_order_flag))
    {
        temp_seqtype = TYPCAT;
    }
    else
    {
        temp_seqtype = seq_type;
    }

    if (mpl_discard_flag) 
    {
        true_slquant1 = slquant1 - 2;
    }
    else
    {
        true_slquant1 = slquant1;
    }


    if ( orderslice( temp_seqtype,
                     exist(opslquant), true_slquant1, 
                     gating ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "orderslice");
        return FAILURE;
    }

    /*MRIge91361 fill in the second pass info in the data_acq_order*/
    if (PSD_ON == pure_ref || PSD_ON == swift_cal) {
        if( swift_cal ) j=0;
        else j=1;
        for (; j < pass_reps; j++){ 
            for (i = 0; i < opslquant; i++) {
                sloff = i + j*opslquant;
                data_acq_order[sloff].slloc = data_acq_order[i].slloc;
                data_acq_order[sloff].slpass = data_acq_order[i].slpass+acqs*j;
                data_acq_order[sloff].sltime = data_acq_order[i].sltime;
            }
        }
    } 

    if( prep_slice_order(gating, feature_flag) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "prep_slice_order" );
        return FAILURE;
    }

    /* MRIge90793 */
    if( fiesta2d_sat_slice_order( exist(opslquant), gating,
                                  feature_flag ) == FAILURE ) {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fiesta2d_sat_slice_order");
        return FAILURE;
    }


    /* call scalerotmats() at the end of predownload as some other
       feature call may perform an orderslice.  Hence, we want
       the targets to be correctly scaled. */


    /*************************************************************
     *  Make sure exorcist variables are set up for recon - LX2  *
     *************************************************************/
    if (cmon_flag == PSD_ON) {
        if (exorcist_predownload() == FAILURE) {
            return FAILURE;
        }
    }


    /**************************
     *  Annotation variables  *
     **************************/
    ihtr = (act_tr>=100)?act_tr:TR_MIN + ((gating==TRIG_LINE) ? TR_SLOP_GR : 0);
    ihtdel1 = MIN_TDEL1;
    if ( mph_annotation( act_tr, sldeltime, nreps, 
                         TR_SLOP_GR, gating, feature_flag ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "mph_annotation");
        return FAILURE;
    }

    if (touch_flag) 
    {
        int i, j, ij;

        free(ihtdeltab);
        ihtdeltab = (int *)malloc(optouchtphases*opslquant*sizeof(int));
        if( ihtdeltab == NULL )
        { 
            epic_error( use_ermes, "malloc failed for %s.", EM_MALLOC_ERMES, EE_ARGS(1), STRING_ARG, "ihtdeltab" );
            return FAILURE;
        }
        exportaddr(ihtdeltab, (int)(optouchtphases*opslquant*sizeof(int)));
        ij = 0;
        for (i = 0; i < opslquant; i++)
        {
            for (j = 0; j < optouchtphases; j++)
            {
                ihtdeltab[ij] = touch_delta*j;
                ij++;
            }
        }
    }
    
    /* fastcard_annotation handled in predownload */


    /********************************
     *  Phase contrast predownload  *
     ********************************/
    /* Added new arguments for Maxwell PC correction - LX2 */
    if ( fastcardPC_predownload( (DOUBLE)t_rd1a, (DOUBLE)t_exb, 
                                 pw_gxwa, pw_gzrf1d, pw_gx1, pw_gx1a, 
                                 pw_gx1d, pw_gxfc, pw_gxfca, pw_gxfcd, 
                                 pw_gz1a, pw_gz1, pw_gz1d, pw_gzfca, 
                                 pw_gzfcd, pw_gzfc, pw_gy1a, pw_gy1, 
                                 pw_gy1d, pw_gyfe1a, pw_gyfe1, pw_gyfe1d, 
                                 a_gxw, a_gzrf1, rsprot[0], 
                                 feature_flag, use_ermes ) == FAILURE ) {
        epic_error(use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                   EE_ARGS(1), STRING_ARG, "fastcardPC_predownload");
        return FAILURE;
    }

    if (touch_flag) 
    {
	rhnecho = 2;
	rhhniter = 0;
	rhyoff = 0;
	rhslblank = 0;
	rhvenc = 1000.0;

	read_col = 0;
	phase_col = 0;
	mag_mask = 0;
	extras = 0;
	imagenum = 0; 

	/* vascular collapse memory */
	/* fft'd data memory */
	vas_ovrhd =  2*rhnecho;
	vas_ovrhd = rhimsize*rhimsize*4*vas_ovrhd + 3904;

	maxpc_cor = PSD_OFF;
	phase_cor = PSD_OFF;

	rhvtype = VASCULAR
		+ PHASE_CON
		+ PHASE_1*phase_cor    /* Phase correction, algorithm 1 */
		+ PHASE_2*maxpc_cor
		+ MAGNITUDE*opmagc;

        rhtype1 &= ~0x00001;        /* no homodyne for phase contrast */
        rhmethod &= ~0x00001;       /* no homodyne for phase contrast */
        rhtype &= ~RHTYPFRACTECHO;  /* homodyne is actually controlled by
                                   rhtype */
        rhnwin = 0;
        if ( floatsAlmostEqualEpsilons(fn, 0.5, 2) && (nop > 1) )
        {
             rhntran = 2.0 * nop;
        } 
        else
        {
             rhntran = 2.0;
        }
        eeff = 0;

	/*  The rhvcoefs determine how the "flow echoes" are combined into physical axes */
	rhvcoefxa = 1.0;
	rhvcoefxb = 2.0;
	rhvcoefxc = 2.0;
	rhvcoefxd = 1.0;

	rhvcoefya = 3.0; 
	rhvcoefyb = 1.0;
	rhvcoefyc = 3.0; 
	rhvcoefyd = 1.0;

	rhvcoefza = 4.0;
	rhvcoefzb = 1.0;
	rhvcoefzc = 4.0;
	rhvcoefzd = 1.0;

	/*  The rhvcoefs determine how the "flow echoes" are combined into a magnitude
	image. See the 4.5  Recon Vascular SDD addendum for more details. */
	rhvmcoef1 = 0.5; 
	rhvmcoef2 = 0.5;
	rhvmcoef3 = 0.25;
	rhvmcoef4 = 0.25;

	rhrawsize = slquant1*(1+(rhbline*rawdata)+rhnframes+rhhnover)*2
		*rhptsize*((exnex*(1-rawdata))+(nex*rawdata))*rhnecho*rhfrsize;

    } /* end touch_flag */

    if ((rhfeextra < 2) && vstrte_flag) rhfeextra = 2;

    /* Compute checksum for rhdacqctrl */
    set_echo_flip(&rhdacqctrl, &chksum_rhdacqctrl, eepf, oepf, eeff, oeff);

    /*********************
     *  SAT Positioning  *
     *********************/
    /* Temp solution: This is to get CATSAT to work with FMPVAS */
    if ( (feature_flag & GATEDTOF)||(feature_flag & UNGATEDTOF) ) {
        temp_seqtype = seq_type;
        seq_type     = TYPCAT;
        cv_statepos  = _satgapzpos.fixedflag;
        cv_stateneg  = _satgapzneg.fixedflag;
        _satgapzpos.fixedflag = 1;
        _satgapzneg.fixedflag = 1;
    }

    /* ENH - 13/Aug/1997 - GFN */
    /* Simulate rotation matrix for obloptimize() */
    if (PSD_ON == rotateflag)
    {
        rotatescan();
    }
    else if (1 == exist(use_myscan))
    {
        if (!(feature_flag & ECHOTRAIN)) 
        { /* gss change */
            myscan();
        }
    }

    if ( touch_flag && (1==opacqo) && (1==opccsat) )
    {
        /*KPH: borrow cv's from GATEDTOF and UNGATEDTOF */
        temp_seqtype = seq_type;
        seq_type     = TYPCAT;
        if (1==opslicecnt) 
        {
            cv_statepos  = _satgapzpos.fixedflag;
            cv_stateneg  = _satgapzneg.fixedflag;
            _satgapzpos.fixedflag = 0;                            
            _satgapzneg.fixedflag = 0;                            
            satgapzpos = 45.0-opslthick;                          
            satgapzneg = 45.0-opslthick;                          
            _satgapzpos.fixedflag = 1;                            
            _satgapzneg.fixedflag = 1;                            
        }                                                       
    }                                                         

    if(FAILURE == SatPlacement(acqs, feature_flag))
    {
        epic_error(use_ermes,"%s failed",EM_PSD_SUPPORT_FAILURE,
                   EE_ARGS(1),STRING_ARG,"SatPlacement");
        return FAILURE;
    }

    if ( touch_flag && (1==opacqo) && (1==opccsat) ) 
    {
        /*KPH: borrow cv's from GATEDTOF and UNGATEDTOF */    
        seq_type = temp_seqtype;                              
        if (1==opslicecnt) 
        {                                  
            _satgapzpos.fixedflag = cv_statepos;                  
            _satgapzneg.fixedflag = cv_stateneg;                  
        }                                                       
    }                                                         

    /* Temp solution for FMPVAS: set back to previous seq type */
    if ( (feature_flag & GATEDTOF) || (feature_flag&UNGATEDTOF) )
    {
        seq_type = temp_seqtype;
        _satgapzpos.fixedflag = cv_statepos;
        _satgapzneg.fixedflag = cv_stateneg;
    }


    /*******************************
     *  Auto Prescan Init          *
     *                             *
     *  Inform Auto Prescan about  *
     *  prescan parameters.        *
     *******************************/
    picalmode = 0;
    pislquant = slquant1;   /* Number of slices in 2nd pass prescan */


    /**********************************
     *  Entry Point Table Evaluation  *
     **********************************/

    /* Initialize the entry point table */
    if (FAILURE == entrytabinit(entry_point_table,(INT)ENTRY_POINT_MAX ))
    {
        return FAILURE;
    }

    /* Scan entry point */
    strcpy(entry_point_table[L_SCAN].epname, "scan");

    /* Set xmtaddScan according to maximum B1 and rescale for powermon, 
       adding additional (audio) scaling if xmtaddScan is too big.
       Add in coilatten, too. */
    xmtaddScan = -200*log10(maxB1[L_SCAN]/maxB1Seq) + getCoilAtten();

    if ( xmtaddScan > cfdbmax ) 
    {
        extraScale = (FLOAT) pow(10.0, (cfdbmax - xmtaddScan) / 200.0);
        xmtaddScan = cfdbmax;
    } else {
        extraScale = 1.0;
    }

    if (FAILURE == setScale(L_SCAN, RF_FREE, rfpulse_list, maxB1[L_SCAN], extraScale)) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "setScale" );
        return FAILURE;
    }

    /* Begin RTIA Addition */
    if ( feature_flag & RTIA98 ) 
    {
        if (FAILURE == RTIA_calc_powermon_values(L_MPS2, RF_FREE, rfpulse_list,
                                       safe_times[0].tmin_total,
                                       &rtia_prescan_pwrmon_values))
        {
            return FAILURE;
        }
    }
    /* End RTIA Addition */
            
    entry_point_table[L_SCAN].epxmtadd = (SHORT)rint( (double)xmtaddScan );

    /* Reset the num fields for RF pulses to support
       running the psd predownload section multiple times
       without cveval(). */
    rf1_pulse->num = 1;

    /* Begin RTIA */
    /* powermon for RTIA is handled differently */
    /* MRIge40868, 41188 - JAP - 05/Aug/1997 */
    /* MRIge75651 */
    if( !(feature_flag & RTIA98) ) 
    { 
        if( setupPowerMonitor( &entry_point_table[L_SCAN], (double)piasar )
            != SUCCESS)
        {
            epic_error(use_ermes, "%s failed",
                       EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                       STRING_ARG, "setupPowerMonitor");
            return FAILURE;
        }
    }
    /* End RTIA */ 

    /* IR-Prep and DE-Prep */
    if (FAILURE == prep_predownload(act_tr, feature_flag)) 
    {
        return FAILURE;
    }

    /* Respiratory Gating - 06/Jun/2003 */
    if (FAILURE == respgate_predownload(feature_flag))
    {
        return FAILURE;
    }

    if (FAILURE == fastcard_predownload( act_tr, pitslice, slquant1, truenex, gating, 
                               copyit, cs_sat, (INT)RF_FREE, rfpulse_list,
                               maxB1[L_SCAN], &entry_point_table[L_SCAN], 
                               L_SCAN, &flip_rf1, feature_flag,
                               use_ermes))
    {
        return FAILURE;
    }

    if (FAILURE == ChemSat_FC_predownload( rfpulse_list, &entry_point_table[L_SCAN], 
                                L_SCAN, (INT)RF_FREE, act_tr, maxB1[L_SCAN], 
                                feature_flag))
    {
        return FAILURE;
    }

    if (FAILURE == fmpvas_predownload( act_tr, pitslice, slquant1, truenex, gating, 
                             copyit, cs_sat, (INT)RF_FREE, rfpulse_list, 
                             maxB1[L_SCAN], &entry_point_table[L_SCAN], 
                             L_SCAN, phorder, feature_flag, use_ermes)) 
    {
        return FAILURE;
    }

    /* Fast CINE - 31/Jan/1998 - GFN */
    if (FAILURE == fcine_predownload(feature_flag)) 
    {
        return FAILURE;
    }

    /* FIESTA2D */
    if (FAILURE == fiesta2d_predownload(feature_flag, &rcphase_chop))
    {
        return FAILURE;
    }

    if (FAILURE == fiesta2d_sat_predownload(feature_flag, nex)) 
    {
        return FAILURE;
    }

    /* Tagging - 04/Jun/97 */
    if (FAILURE == tagging_predownload( rfpulse_list, &entry_point_table[L_SCAN], 
                              L_SCAN, (INT)RF_FREE, act_tr, maxB1[L_SCAN], 
                              feature_flag))
    {
        return FAILURE;
    }

    entry_point_table[L_SCAN].epfilter  = (UCHAR)echo1_filt->fslot;
    /* ENH - 13/Aug/1997 - GFN */
    /* Changed xres for rhdaxres */
    entry_point_table[L_SCAN].epprexres = (n16)rhdaxres;

    /* Now copy into APS2 and MPS2 */
    /* The rf pulse and the x resolution used in
       MPS2 and APS2 are identical to those in SCAN */
    entry_point_table[L_APS2] = entry_point_table[L_MPS2] = entry_point_table[L_SCAN];
    entry_point_table[L_MPS2].epfilter = entry_point_table[L_SCAN].epfilter;
    entry_point_table[L_MPS2].epprexres = entry_point_table[L_SCAN].epprexres;

    /* Begin RTIA */
    if ( feature_flag & RTIA98 ) 
    { 
        RTIA_set_powermon( &entry_point_table[L_SCAN],
                           rtia_pwrmon_avesar );
   
        RTIA_set_powermon( &entry_point_table[L_MPS2],
                           rtia_prescan_pwrmon_values.avesar );
           
        entry_point_table[L_APS2] = entry_point_table[L_MPS2];
    }
    /* End RTIA */
    strcpy( entry_point_table[L_MPS2].epname, "mps2" );
    strcpy( entry_point_table[L_APS2].epname, "aps2" );

    /*
     * New filter specification interface. calcfilter fills in the 
     * filter parameters during the evaluation in readout_params()
     * The filter information node obtained can now be passed to 
     * setfilter() to generate the appropriate filter specification
     * node.  LxMGD, RJF 07/02/2001
     */
    initfilter();
    setfilter( echo1_filt, SCAN );
    filter_echo1 = echo1_filt->fslot;
    /* filter_echo2 = echo1_filt->fslot; */
    PSfilter();

    if( PSD_ON == track_flag )
    {
        if( FAILURE == track_filter() )
        {
            return FAILURE;
        }
    }

    /* Begin RTIA */
    /* RTIA needs bore temp monitoring too . Set the flag here */
    if (PSD_ON == exist(oprealtime)) 
    {
        btemp_monitor = 1;
    }
    /* End RTIA */

    if(FAILURE == et_predownload(feature_flag, etl, getTxCoilType(), getRxCoilType(), tsp, 
                             psd_fov, xres, phaseres, rhfrsize, ia_gyb, rsprot, exist(opslquant)))
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, 
                    EE_ARGS(1), STRING_ARG, "et_predownload" );
        return FAILURE;
    }

    if (1 == show_rtfilts) 
    {
        dump_filter(psd_filt_spec);
    }
 
    /* move prescan predownload here as filters are
       reset for fasttg here */
    if (FAILURE == prescan_predownload( rfpulse_list, RF_FREE, maxB1, 
                              maxB1Seq ))
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "prescan_predownload" );
        return FAILURE;
    }


    /*********************************
     *  Scale the rotation matrices  *
     *********************************/
    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    if (FAILURE == scalerotmats(rsprot, &loggrd, &phygrd, opslquant, obl_debug))
    {
        epic_error(use_ermes,"System configuration data integrity violation detected in PSD. \nPlease try again or restart the system.",
                   EM_PSD_PSDCRUCIAL_CONFIG_FAILURE,EE_ARGS(0));
        return FAILURE;
    }

    /*******************************
     *  Prescan slice calculation  *
     *******************************/
    if (FAILURE == prescanslice( &pre_pass, &pre_slice, exist(opslquant))) 
    {
        epic_error( use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE,
                    EE_ARGS(1), STRING_ARG, "prescanslice" );
        return FAILURE;
    }

@inline T1Map.e T1MapPredownload

    if (touch_flag)
    { 
        pre_pass = 0;
        pre_slice = slquant1/2;
    }

    if(PSD_3PLANE == opplane) 
    {
        preslquant = IMin(2,PRESLQUANT, exist(opslquant));
        if (FAILURE == prescanslice1(presliceorder, preslquant, exist(opslquant)))
        {
             epic_error(use_ermes, supfailfmt, EM_PSD_SUPPORT_FAILURE, EE_ARGS(1),
                 STRING_ARG, "prescanslice1");
             return FAILURE;
        }
        pislquant = preslquant; 
    }
    
    psd_dump_scan_info();
    psd_dump_rsp_info();
    psd_dump_slice_info();

    if( PSD_ON == track_flag )
    {
        if( FAILURE == track_predownload() )
        {
            return FAILURE;
        }
    }

    /* Set pulse parameters */
    if( FAILURE == calcPulseParams(AVERAGE_POWER) ) 
    {
        return FAILURE;
    }


    /*MRIhc42193 scale flow encoding gradient here in predownload so syscheck will give accurate minTR*/
    if (FAILURE == fastcardPC_scale_flow_grads(feature_flag, &a_gx1, &a_gxfc,
                                    &a_gz1, &a_gzfc, a_gy1a, a_gyfe1)) 
    {
        epic_error( use_ermes, "%s failed.", EM_PSD_ROUTINE_FAILURE,
                    EE_ARGS(1), STRING_ARG, "fastcardPC_scale_flow_grads" );
        return FAILURE;
    }

    /*MRIge91882*/
    if(((PSD_GE==exist(oppseq)) || (PSD_3PLANELOC==exist(oppseq))) && (PSD_3PLANE==exist(opplane)) &&
       !(feature_flag&IRPREP)&& !(feature_flag & FIESTA))
    {
        if (PSD_ON == exist(opmultistation)) 
        {
            firstSeriesFlag=FALSE;
            pscahead = TRUE;
            autoadvtoscn = TRUE;
        } else {
            pscahead = FALSE;
            /* autoadvtoscn is initialized to off in cveval() */
        }

    }

@inline ARC.e ARCrh
if( arc_ph_flag )
    rhrawsize = rhrawsize / (1 + (rhbline * rawdata) + rhnframes + rhhnover) * ((rhbline * rawdata) + rhdayres);

@inline ARC.e ARCkacq

@inline loadrheader.e rheaderpredownload

    /* Call acoustic model */
    enable_acoustic_model = isAcousticDataAvailable();
    if( enable_acoustic_model && (PSD_OFF == oploadprotocol) )
    {
        int min_acoustic; // Temporary variable, not used in any calculation
        enforce_minseqseg = 1;
        seqEntryIndex = idx_seqcore;
        acoustic_seq_repeat_time = (int)(act_tr / slq_per_tr);

        if( FAILURE == minseq(&min_acoustic, gradx_list, GX_FREE, grady_list, GY_FREE, gradz_list, GZ_FREE, &loggrd,
                              seqEntryIndex, tsamp, acoustic_seq_repeat_time, use_ermes, seg_debug) )
        {
            epic_error(use_ermes, "%s failed.",
            EM_PSD_ROUTINE_FAILURE,
                       EE_ARGS(1), STRING_ARG, "minseq for acoustic");
            enable_acoustic_model = 0;
            enforce_minseqseg = 0;
            return FAILURE;
        }
        enforce_minseqseg = 0;
        enable_acoustic_model = 0;
    }

    /* Air Recon */
    cvmax(rh_airiq_config, 1);
    if((opairecon > DL_RECON_MODE_OFF) && (PSD_ON == perfusion_flag))
    {
        cvmax(rh_airiq_config, 3);
        rh_airiq_config |= RHRESIZE_RINGING_REDUCTION;
        rh_airiq_win_w = 0.15;
        if(floatsAlmostEqualEpsilons(fn, 0.75, 2))
        {
            rhtype &= ~RHTYPFRACTECHO; /* zerofill to reduce banding artifact for DL for fn = 0.75 */ 
        }
    }

    
    return SUCCESS;
} /* end predownload() */


/*
 *  calcPulseParams
 *  
 *  Type: Public Function
 *  
 *  Description:
 *    This function sets pulse widths and instruction amplitudes needed
 *    for pulse generation.
 */
STATUS
calcPulseParams( int encode_mode )
{
    /* Include EPIC-generated code */
#include "fgre.predownload.in"

    if(MAXIMUM_POWER == encode_mode)
    {
        gy1_pulse->scale = 1.0;
        gy1r_pulse->scale = 1.0;
    }
    else
    {
        gy1_pulse->scale = ave_grady_gy1_scale;
        gy1r_pulse->scale = ave_grady_gy1_scale;
    }

    /* Initialize the waits for the cardiac instruction.
       Pulse widths of wait will be set to td0 for first slice
       of an R-R in RSP.  All other slices will be set to
       the GRAD_UPDATE_TIME. */
    pw_x_td0     = GRAD_UPDATE_TIME;
    pw_y_td0     = GRAD_UPDATE_TIME;
    pw_z_td0     = GRAD_UPDATE_TIME;
    pw_rho_td0   = GRAD_UPDATE_TIME;
    pw_ssp_td0   = GRAD_UPDATE_TIME;
    pw_theta_td0 = GRAD_UPDATE_TIME;

    /* Instruction amplitude for the RF pulse */
    ia_rf1 = max_pg_iamp * (*rf1_pulse->amp);

    /* Spatial SAT */
    if ( FAILURE == sp_calcPulseParams() )
    {
        return FAILURE;
    }
    SpSatIAmp();

    /* Phase Contrast */
    if ( FAILURE == fastcardPC_calcPulseParams( &ia_gz1, &ia_gzfc, 
                                                &ia_gx1, &ia_gxfc, 
                                                a_gz1, a_gzfc, a_gx1, a_gxfc, 
                                                feature_flag ) ) 
    {
        return FAILURE;
    }

    /* Hard 180 rectangular Inversion RF pulse */
    if ( FAILURE == Hard180_calcPulseParams( rfpulse_list, feature_flag ) ) 
    {
        return FAILURE;
    }

    /* Chemical SAT */
    ChemSat_IAmp( cs_sat, feature_flag );

    /* Multi-Planar Interleaved */
    if ( FAILURE ==  mpl_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* IR-Prep and DE-Prep */
    if ( FAILURE == prep_calcPulseParams( feature_flag ) ) 
    {
        return FAILURE;
    }

    /* Multi-Phase Interleaved */
    if ( FAILURE == mph_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* Cardiac Gated */
    if ( FAILURE == fastcard_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* Multi-Planar Vascular */
    if ( FAILURE == fmpvas_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* Fast CINE */
    if ( FAILURE == fcine_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* FIESTA2D */
    if ( FAILURE == fiesta2d_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* Tagging */
    if ( FAILURE == tagging_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* EchoTrain */
    if ( FAILURE == et_calcPulseParams() ) 
    {
        return FAILURE;
    }

    /* Realtime Flowcomp */
    if ( FAILURE == RTIA_calcPulseParams() ) 
    { 
        return FAILURE;
    }
  

    /* HD merge_3TC_11.0 START### */
    /*
     * MRIge79372 - AC -- Previously the ia_gy1 and ia_gy1r was modified
     * (see MRIge63197) to resolve an image artifact (MRIge67556). However,
     * scope dB/dt measurements indicated that the previous solution does
     * scale down true phase encoding gradients and cause an underestimation
     * of dB/dt. The following code sets instruction amplitudes to max while
     * taking gradient strength into consideration.
     */
    {
        ia_gy1  = copysign( sqrt(gy1_pulse->scale),  a_gy1 ) * endview_iamp;
        ia_gy1r = copysign( sqrt(gy1_pulse->scale), a_gy1r ) * endview_iamp;
    }
    /* HD merge_3TC_11.0 END### */

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    if(sbm_flag)
    {
        ia_gx1   = (int)(ia_gx1 * sbm_gx1_scale);
        ia_gxw   = (int)(ia_gxw * sbm_gxw_scale);
        ia_gxwex = (int)(ia_gxwex * sbm_gxwex_scale);
        ia_gy1   = (int)(ia_gy1 * sbm_gy1_scale);
        ia_gy1r  = (int)(ia_gy1r * sbm_gy1r_scale);
        ia_gz1   = (int)(ia_gz1 * sbm_gz1_scale);
        ia_gzk   = (int)(ia_gzk * sbm_gzk_scale);
    }

    return SUCCESS;  
}   /* end calcPulseParams() */

STATUS
derate_gy1( void )
{
    STATUS status;
    int start_minte;
    float derate_factor_decrement = 0.01;

    if(derate_gy1_flag)
    {
        start_minte = avminte;

        while((avminte<=start_minte) && (extra_derate_gy1>=0.1))
        {
            extra_derate_gy1 -= derate_factor_decrement;
            if ( (status = set_phase_encode_and_rewinder_params()) != SUCCESS ) 
            {
                return status;
            }
            if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS) 
            {
                return status;
            }
        }
        extra_derate_gy1 += derate_factor_decrement;
        if ( (status = set_phase_encode_and_rewinder_params()) != SUCCESS ) 
        {
            return status;
        }
        if ( (status = set_rdout_params_te_and_tmin()) != SUCCESS) 
        {
            return status;
        }
    }

    return SUCCESS;
}

STATUS
ThreePlaneCheck( void )
{
    if(PSD_3PLANE == exist(opplane))
    {
        /* Check for invalid imaging options */
        if( exist(opfcomp) ||
            exist(oppomp) || ((exist(opptsize) == 4) && (DATA_ACQ_TYPE_FLOAT != dacq_data_type)) || exist(opsquare) ||
            exist(opscic) || exist(opexor) || exist(opblim) || exist(opmt) ||
            exist(opcgate) || exist(oprtcgate) ||
            exist(optlrdrf) || exist(opdeprep) || exist(opmph) || exist(opzip512) ||
            exist(opfulltrain) || exist(opcmon) || exist(opzip1024) ||
            exist(opsmartprep) || exist(opbsp) || exist(opmultistation) ||
            exist(oprealtime) || exist(opt2prep) || exist(opssrf) || 
            exist(opphsen) || exist(opfluorotrigger) || exist(opassetscan) ) 
        {
            epic_error( use_ermes, "%s is incompatible with %s",
                        EM_PSD_INCOMPATIBLE, EE_ARGS(2),
                        STRING_ARG, "The selected imaging option",
                        STRING_ARG, "3-Plane prescription" );
            return FAILURE;
        }   
    }   
    return SUCCESS;
}

STATUS
vstrte_init( void )
{
    if( (exist(opfov) >= 480) && (exist(opflip) <= 1.0) &&
        (exist(opslthick) >= 400.0) && (exist(opetl)==1) && (1 == exist(opfphases)) && 
        (1 == exist(opslquant)) && ((PSD_TOFSP == exist(oppseq)) || 
        (PSD_TOF == exist(oppseq)) || (PSD_SSFP == exist(oppseq))) ) 
    {
        vstrte_flag = 1;
        psd_grd_wait = 60us;
        if (PSD_XRMW_COIL == cfgcoiltype || PSD_IRMW_COIL == cfgcoiltype)
        {
           psd_rf_wait = 112;
        }
        if(isRioSystem() || isHRMbSystem())
        {
            psd_rf_wait = 94us;
        }
        if (feature_flag & FIESTA) 
        {
           config_update_mode = CONFIG_UPDATE_TYPE_VSTRTE_DEFAULT;
        } else {
           config_update_mode = CONFIG_UPDATE_TYPE_VSTRTE_AMP20SR150;
        }
    } else {
        vstrte_flag = 0;
        config_update_mode = CONFIG_UPDATE_TYPE_DVW_DEFAULT;
    }

    if( FAILURE == inittargets(&loggrd, &phygrd) ) 
    {
        return FAILURE;
    }
    if(vstrte_flag && is15TSystemType())
    {
        cvmax(rhacqslthick,400);
        if(isValueSystem())
        {
            cfsystemmaxfov = 500;
        }
        cvoverride(cfrfminunblk, 124, PSD_FIX_ON, PSD_EXIST_ON);
    }

    return SUCCESS;
}  

@rspvar
/*********************************************************************
 *                     FGRE.E RSPVAR SECTION                         *
 *                                                                   *
 * Declare here the real time variables that can be viewed and modi- *
 * fied while the Tgt PSD process is running. Only limited standard  *
 * C types are provided: short, int, long, float, double, and 1D     *
 * arrays of those types.                                            *
 *                                                                   *
 * NOTE: Do not declare all real-time variables here because of the  *
 *       overhead required for viewing and modifying them.           *
 *********************************************************************/

int cont_proceed = 0;

/* Begin RTIA */

@inline RTIA.e realtime_rspvar
@inline RTIA.e rtia98_rspvar
@inline RTIA.e echotrain_rspvar

int cont_trip, cont_trip_phasedda;

/*for MRgFUS, to remembe the previous pass id
 * for updating phase number in Rtp Data file.
 * It's value will be updated after sending each tracking
 * request and then used to calculate phase difference*/
int phaseno_fus, prev_pass_num;

int cm_pass, rsp_cmnpass, pass_cnt, rsp_cmdir, rsp_cmndir;

int rsp_slide;
short cmxuamp[6], cmxdamp[6], cmxfamp[6];
short cmyuamp[6], cmydamp[6], cmyfamp[6];
short cmzuamp[6], cmzdamp[6], cmzfamp[6];

/* End RTIA */
short amp_gy1;
short amp_gy1e;       /* amp of phase encodes */
short amp_gx1;
short amp_gx2;
short amp_gxw;
short amp_gxw2;       /* X grad variables */
short blimfactor;     /* 1 if new memp, -1 if classic */
short ision;          /* 1 if use isi, else not use isi */
short rsp_hrate;      /* cardiac heart rate */
int seqpass_deadtime; /* deadtime in seqpass entry point - MRIhc20775 */

/* RSP Control Variable Definitions. Listed below are
   several variables all with the prefix "rsp".  These variables
   are set in the initial part of each entry point, 
   before CORE is called. They are used in CORE to
   control the excitation and acquisition of data.
   Descriptions of the use of each of these variables is given
   below.  Each of the variables also has a reseach rsp variable
   counterpart.  When rsp variable rmode is set to 1, 
   all "res" variables with the prefix "res" are used for CORE
   control instead of variables with the "rsp" prefix.

   dda = total number of disdaq acquisitions ( NOT in pairs )
   bas = total number of baseline acquisitions ( NOT in pairs )
   vus = total number of views to collect
   gy1 = index of initial amplitude of y dephaser
   -1 = calculate initial amplitude
   nex = total number of excitations
   chp = chopper states:
   0 = chop baselines only
   1 = chop everything
   2 = no chopping
   esl = index number of excited slice
   -1 = excite all slices
   asl = index number of acquired slice
   -1 = acquire all non-disdaq slices
   sct = slice number to turn on scope trigger
   -1 = scope trigger on all slices
   dex = total number of views to discard per
   excitation. This allow a disdaq to be done
   on each view.  Normally = 0
   slq = total number of slices to acquire
   cfm = not used
   ent = entry point

*/
short rspdda, 
    rspbas, 
    rspvus, 
    rspnex, 
    rspchp, 
    rspgy1, 
    rspesl, 
    rspasl, 
    rspech, 
    rspsct, 
    rspdex, 
    rspslq, 
    rsprlx, 
    rmode, 
    resdda, 
    resbas, 
    resvus, 
    resnex, 
    reschp, 
    resdex, 
    resesl, 
    resasl, 
    resech, 
    ressct, 
    resslq, 
    rsplock, 
    rspphs, 
    rspisi, 
    rsptimessi, 
    rspscptrg;
short rsp_preview = 0; /* amplitude of phase encode for
                          prescan entrypoints */
short temp_short;       /* temporary amplitude storage for RF chopping */
short tempamp;         /* temporary amplitude storage */

int echo1dab;             /* Waveform index for the echo1 dab pulse */
int echo1rba_index;             /* Waveform index for the echo1 rba pulse */
int echo1xtrrsp;          /* WF index for echo1 xtr - used for fgre_setiphase */
int rf1frqrsp;            /* WF index for rf1 frq - used for fgre_setiphase */
int echo2dab;             /* Waveform index for the echo1 dab pulse, DUALECHO */
int echo2rba;             /* Waveform index for the echo1 rba pulse, DUALECHO */
int readechodab[16];
int readechorba[16];

int dabecho, 
    dabecho_multi, 
    dabop, 
    dabview;              /*  vars for loaddab */
int isi_dabecho, 
    isi_dabop, 
    isi_dabview, 
    isi_dabslice;         /*  vars for isi loaddab */
int isi_rcphase;
int isi_psdindex;
int debugstate;           
int psd_index, 
    pass, 
    view, 
    excitation, 
    slice, 
    baseviews, 
    disdaqs, 
    acq_sl, 
    lastview;

/* VAL15 02/21/2005 YI */
int sqcount;
int pcfiesta_index;     /* Phase Cycling Index for FIESTA-C */
int chop_exphase;
int ext_phase;

int rsp_card_intern;      /* deadtime when next slice is internally
                             gated in a cardiac scan */
int rsp_card_last;        /* dead time for last temporal slice of a
                             cardiac scan */
int rsp_card_fill;        /* dead time for last slice in a filled
                             R-R interval */
int rsp_card_unfill;      /* dead time for last slice in a unfilled
                             R-R interval */
int seq_count;
int exphase;
int delaytime;
int rcphase;             /* sum of receiver phase */
int rcvr_phase;          /* receiver phase accumulation */
int ipgdabstate;         /* switch to turn on/off dab packet in psdisiupdate */
int rspent;
int sp_sat_index;
int ssp_ctrl;

int passes_left = 0;     /* How many passes remain to be acquired (MRIhc03524) */

float dipinv_ratio;      /* dip ratio of inversion vrg pulse */

/* non-CERD view copy required ssp packet assignments */
/* Bits for DAB pulse */
short copy_dab_pkt_array[23] = {
    SSPDS + DABDC, /* 0 DAB direction */
    SSPOC + DCOPY, /* 1 Opcode */
    SSPD,          /* 2 view copy control */
    SSPD, 
    SSPD,          /* 4 pass number source */
    SSPD, 
    SSPD,          /* 6 slice number source */
    SSPD, 
    SSPD,          /* 8 echo number source */
    SSPD, 
    SSPD,          /* 10 view number source */
    SSPD, 
    SSPD,          /* 12 pass number dest */
    SSPD, 
    SSPD,          /* 14 slice number dest */
    SSPD, 
    SSPD,          /* 16 echo number dest */
    SSPD, 
    SSPD,          /* 18 view number dest */
    SSPD, 
    SSPD,          /* 20 number of frames */
    SSPD, 
    SSPDS
};

/* CERD view copy required ssp packet assignments */
/* changed from 17 to 15*/
/* Bits for DAB pulse */
short copy_dab_pkt_array2[15] = {
    SSPDS + DABDC, /* 0 DAB direction */
    SSPOC + DCOPY, /* 1 Opcode */
    SSPD,          /* 2 view copy control */
    SSPD,          /* 3 nframes*/
    SSPD,          /* 4 pass number source */
    SSPD,          /* 5 pass number dest */
    SSPD,          /* 6 slice number source */
    SSPD,          /* 7 slice number dest */
    SSPD,          /* 8 extra bits */
    SSPD,          /* 9 echo source and destination */
    SSPD,          /* 10 view number source */
    SSPD, 
    SSPD,          /* 12 view number dest */
    SSPD, 
    SSPDS
};

short t1map_pkt_array[8] = {
    SSPDS,         /* 0 */
    SSPOC,         /* 1 Opcode */
    SSPD,          /* 2 slice index high byte */
    SSPD,          /* 3 slice index low byte */
    SSPD,          /* 4 TI index high byte */
    SSPD,          /* 5 TI index low byte */
    SSPD,          /* 6 TI value high */
    SSPD,          /* 7 TI value low */
};

@pg
/*********************************************************************
 *                      FGRE.E PULSEGEN SECTION                      *
 *                                                                   *
 * Write here the functional code that loads hardware sequencer      *
 * memory with data that will allow it to play out the sequence.     *
 * These functions call pulse generation macros previously defined   *
 * with @pulsedef, and must return SUCCESS or FAILURE.               *
 *********************************************************************/
/* System includes */
#include <string.h>
/* Local includes */
#include <features_tgt_includes.h>
#include <feature_decl.tgt.h>
#include <fgre.tgt.h>
#include <support_func.host.h>

#include "TrackPlus.host.h"
#include "TrackPlus.tgt.h"

#ifdef PSD_HW   /* Auto Voice */
#include "broadcast_autovoice_timing.h"
#endif

/* Global variables */
extern PSD_EXIT_ARG psdexitarg;
int sp_satindex;            /* index for multiple calls to spsat routines */
int cs_satindex;            /* index for multiple calls to chemsat routines */
int sp_sat;                 /* MRIge31250: changed type for sp_sat - VB */
short *wave_space;          /* temp waveform space */
WF_PULSE *echo1rba;         /* ET - Points to RBA packet - JAP */
WF_PULSE_ADDR pecho1xtr;
WF_PULSE_ADDR prf1frq;
WF_PULSE_ADDR rec_unblank;

WF_PULSE_ADDR p_echo2rba;   /* DUALECHO modification */
WF_PULSE rf1 = INITPULSE;   /* MRIge58717 RJF/YZ */
long scan_deadtime;         /* deadtime in scan entry point */
/* Begin RTIA */
long rtia_flowcomp_deadtime;  /* deadtime for the RTIA flowcomp core */         
/* End RTIA */
/* MEGE changes */
WF_PULSE * readecho;
WF_PULSE_ADDR * p_readechorba;

short *acq_ptr;             /* first slice in a pass */
short *slc_in_acq;          /* number of slices in each pass */
int *rf1_flip;              /* flip angle sequence for rf1 */
short viewtable[2049];      /* view table */
long rsptrigger_temp[1];    /* temp trigger array for pass packets
                               sequences and other misc */
LONG pass_seqtime;          /* sequence time for pass section*/

/* Spatial sat additions */
long rsprot_orig[DATA_ACQ_MAX][9];

/* liyuan for real-time data update feature */
long **realurot; /* realtrot[slices][rot9]*/
long **rsprot_temp; /* recording 1st rot, the temporal rsp rotation matrix */
RSP_INFO orig_rsp_info[DATA_ACQ_MAX];
RSP_INFO realu_rsp_info[DATA_ACQ_MAX];
/* liyuan end */

/* Frequency offsets */
int *rf1_freq;

int *receive_freq1;
int *receive_freq2;

LONG t1map_pkt_addr;

/* Include pulsegen declarations for Exorcist - LX2 */
@inline Exorcist.e ExorcistPGDecl

INT mphseq_seqtime; /* sequence time for mph sequential */
INT ps2mphseq_seqtime;

FILE *fp;

/** CODE **/


/*
 *  phase_plus_pi
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
phase_plus_pi( INT *phase )
{
    (*phase) = ((INT)((FLOAT)(*phase) +
                      4L * FS_PI) % FS_2PI) - FS_PI;
    return SUCCESS;
}   /* end phase_plus_pi() */


/*
 *  ssiupdates
 *  
 *  Type: Function
 *  
 *  Description:
 *    After executing the ssisat code, this routine checks whether 
 *    the code for CMON shall be executed.
 */
void
ssiupdates( void )
{
#ifdef IPG
    ssisat();
    if (PSD_ON == cmon_flag)
    {
        exorcist_ssi();
    }
#endif /* IPG */

    return;
}   /* end ssiupdates() */


/*
 *  ssisat
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
void
ssisat( void )
{
#ifdef IPG
    INT next_slice;

    /* RTIA begin */
    /* Update the SAT rotation matrices only if cont_SpSat is on 
       for the current pass. */
    if ((feature_flag & RTIA98) && (cont_spSat != PSD_ON)) { 
        return;
    }
    /* End RTIA */
    next_slice = sp_sat_index;
    sp_update_rot_matrix( &(rsprot_orig[next_slice][0]), (long **) sat_rot_matrices,                      
                          get_sat_rot_ex_num(), get_sat_rot_df_num() );
#endif /* IPG */

    return;
}   /* end ssisat() */


/*
 *  set_seqcore_period
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_seqcore_period( INT period, 
                    INT offset )
{
    setperiod( period, &seqcore, offset );

    return SUCCESS;
}   /* end set_seqcore_period() */

/*Define MR-Touch functions */
/*
 *  SlideTouchTrig
 *
 *  Type: Function
 *
 *  Description:
 *  Sliding SSP trigger position w.r.t MEG position
 */
STATUS
SlideTouchTrig(void) 
{
    int	slide;
	
    slide = (opacqo==0) ? pass : slice;
#ifdef SIM
    printf("slice:%d, pass:%d, slide:%d, disdaqs:%d\n",slice, pass, slide, disdaqs);
#endif
    rsp_slide = RDN_GRD((int)((optouchtphases-slide-1)*touch_delta));
    setperiod (GRAD_UPDATE_TIME+rsp_slide, &ssp_touch_wait, 0);
    setperiod (pw_ssp_touch_sync - rsp_slide, &ssp_touch_sync, 0);
    return SUCCESS;
}

/*
 *  NullTouchAmp
 *
 *  Type: Function
 *
 *  Description:
 *  Zero-out the MEG amplitude
 */

STATUS 
NullTouchAmp(void) 
{
    if (touch_gnum>0) 
    {
        if (touch_xdir) 
        {
            if (touch_fcomp) 
            {
                setiampt(0, &gxtouchf, INSTRALL);
                if (touch_gnum>1) 
                {
                    setiampt(0, &gxtouchu, INSTRALL);
                }
            } else 
            {
                setiampt(0, &gxtouchu, INSTRALL);
            }
            setiampt(0, &gxtouchd, INSTRALL);
        }
        if (touch_ydir) 
        {
            if (touch_fcomp) 
            {
                setiampt(0, &gytouchf, INSTRALL);
                if (touch_gnum>1)
                { 
                    setiampt(0, &gytouchu, INSTRALL);
                }
            } else 
            {
                setiampt(0, &gytouchu, INSTRALL);
            }
            setiampt(0, &gytouchd, INSTRALL);
        }
        if (touch_zdir) 
        {
            if (touch_fcomp) 
            {
                setiampt(0, &gztouchf, INSTRALL);
                if (touch_gnum>1)
                {
                    setiampt(0, &gztouchu, INSTRALL);
                }
            } else 
            {
                setiampt(0, &gztouchu, INSTRALL);
            }
            setiampt(0, &gztouchd, INSTRALL);
        }
    }
    return SUCCESS;
}

/*
 *  SetTouchAmpUd
 *
 *  Type: Function
 *
 *  Description:
 *  Set MEG amplitude when FC is off
 */

STATUS
SetTouchAmpUd(int dir) 
{
    if (touch_xdir)
    {
       setiampt(cmxuamp[dir], &gxtouchu, INSTRALL);
    }
    if (touch_ydir)
    {
       setiampt(cmyuamp[dir], &gytouchu, INSTRALL);
    }
    if (touch_zdir)
    {
       setiampt(cmzuamp[dir], &gztouchu, INSTRALL);
    }
    if (touch_xdir)
    { 
       setiampt(cmxdamp[dir], &gxtouchd, INSTRALL);
    }
    if (touch_ydir)
    {
       setiampt(cmydamp[dir], &gytouchd, INSTRALL);
    }
    if (touch_zdir)
    {
       setiampt(cmzdamp[dir], &gztouchd, INSTRALL);
    }
    return SUCCESS;
}

/*
 *  SetTouchAmpUdf
 *
 *  Type: Function
 *
 *  Description:
 *  Set MEG amplitude when FC is on
 */

STATUS
SetTouchAmpUdf(int dir) 
{

    if (touch_gnum>1) 
    {
	if (touch_xdir) 
        {
           setiampt(cmxuamp[dir], &gxtouchu, INSTRALL);
        }
	if (touch_ydir)
        {
           setiampt(cmyuamp[dir], &gytouchu, INSTRALL);
        }
	if (touch_zdir)
        {
            setiampt(cmzuamp[dir], &gztouchu, INSTRALL);
        }
    }
    if (touch_xdir)
    {
        setiampt(cmxdamp[dir], &gxtouchd, INSTRALL);
    }
    if (touch_ydir)
    {
        setiampt(cmydamp[dir], &gytouchd, INSTRALL);
    }
    if (touch_zdir)
    {
        setiampt(cmzdamp[dir], &gztouchd, INSTRALL);
    }
    if (touch_xdir)
    {
        setiampt(cmxfamp[dir], &gxtouchf, INSTRALL);
    }
    if (touch_ydir)
    {
        setiampt(cmyfamp[dir], &gytouchf, INSTRALL);
    }
    if (touch_zdir)
    {
        setiampt(cmzfamp[dir], &gztouchf, INSTRALL);
    }
    return SUCCESS;
}

/*
 *  SetTouchAmp
 *
 *  Type: Function
 *
 *  Description:
 *  Set MEG amplitude
 */

STATUS
SetTouchAmp(int dir) 
{

    if (touch_gnum > 0)
    {
	if (touch_fcomp)
        { 
           SetTouchAmpUdf(dir);
        } else 
        { 
           SetTouchAmpUd(dir);
        }
    }
    return SUCCESS;
}

/*
 *  AddEncodeUp
 *
 *  Type: Function
 *
 *  Description:
 *  Add up-lobe of the MEG
 */

STATUS 
AddEncodeUp(int pos) 
{
    if (touch_xdir) 
    {
        TRAPEZOID(XGRAD, gxtouchu, pos+pw_gxtouchua, 0, TYPNDEF, loggrd);
    }
    if (touch_ydir) 
    {
        TRAPEZOID(YGRAD, gytouchu, pos+pw_gytouchua, 0, TYPNDEF, loggrd);
    }
    if (touch_zdir) 
    {
        TRAPEZOID(ZGRAD, gztouchu, pos+pw_gztouchua, 0, TYPNDEF, loggrd);
    }
    return SUCCESS;
}
/*
 *  AddEncodeDown
 *
 *  Type: Function
 *
 *  Description:
 *  Add down-lobe of the MEG
 */

STATUS
AddEncodeDown(int pos) 
{
    if (touch_xdir) 
    {
        TRAPEZOID(XGRAD, gxtouchd, pos+pw_gxtouchda, 0, TYPNDEF, loggrd);
    }
    if (touch_ydir) 
    {
        TRAPEZOID(YGRAD, gytouchd, pos+pw_gytouchda, 0, TYPNDEF, loggrd);
    }
    if (touch_zdir) 
    {
        TRAPEZOID(ZGRAD, gztouchd, pos+pw_gztouchda, 0, TYPNDEF, loggrd);
    }
    return SUCCESS;
}

/*
 *  AddEncodeFcomp
 *
 *  Type: Function
 *
 *  Description:
 *  Add the FC-lobe of the MEG
 */

STATUS
AddEncodeFcomp(int pos) 
{

    if (touch_xdir) 
    {
        TRAPEZOID(XGRAD, gxtouchf, pos+pw_gxtouchfa, 0, TYPNDEF, loggrd);
    }
    if (touch_ydir) 
    {
        TRAPEZOID(YGRAD, gytouchf, pos+pw_gytouchfa, 0, TYPNDEF, loggrd);
    }
    if (touch_zdir) 
    {
        TRAPEZOID(ZGRAD, gztouchf, pos+pw_gztouchfa, 0, TYPNDEF, loggrd);
    }
    return SUCCESS;
}


/*
 *  pulsegen
 *
 *  Type: Function
 *
 *  Description:
 *    In research and prototype PSDs, a majority of the work can be done 
 *    in the pulsegen section and taken out of the cveval section.  The user
 *    can allow the pulsegen section to define many pulsewidths and 
 *    amplitudes for behind his back.  For product PSDs however, optimization
 *    and absolute knowledge of pulse widths and amplitudes are needed for
 *    the advisory panel.  Thus, cveval will define most pulse widths
 *    and amplitudes for pulsegen in product PSDs.
 */
STATUS
pulsegen( void )
{
    SHORT copy_pkt_length = 0;   /* view copy packet length */
    INT PosPhaseEncode1;
    INT PosPhaseRew1;             /* echo1 y pulse locs */
    INT PosReadoutWindow;         /* Readout window location */
    INT PosDabPkt;                /* DAB packet location */
    INT PosGx1, PosGx2;           /* Readout dephaser location */
    INT PosGxfc;                  /* Readout flow_comp */
    INT PosGz1;                   /* Slice dephaser location */
    INT PosGzfc;                  /* Slice flow_comp */
    INT PosZKiller;               /* Z Killer location */
    INT PosXKiller;               /* X Killer location */
    INT PosPASS;                  /* pass packet location */
    INT PosIsi;                   /* ISI packet location */
    INT PosTNSon;
    INT PosTNSoff;                /* TNSoff packet location */
    INT psd_seqtime;              /* sequence time */
    SHORT slmod_acqs;             /* slices%acqs */
    INT resp_comp_type = TYPNORM; /* low sort, high sort */
    INT copydabtime;
    INT dab_offset;
    INT PosDab2;	       	  /* DUALECHO modification */
    INT PosReadoutEcho2 = 0;	  /* DUALECHO modification */
    SHORT temp_amp;		  /* DUALECHO modification */
    INT PosStart = pos_start;     /* GEHmr03378 */
    INT PosTlead = tlead;         /* GEHmr03378 */
#ifdef IPG
    SHORT t1map_pkt_length = 8us;
#endif

    int i = 0;

    /* liyuan for realtime imaging update */
    int temp1;
    /* liyuan end */

    /* Initialize TGlimit to max system tg: 200 */
    TGlimit = MAX_SYS_TG;

#ifdef IPG
    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* recover ia_gx1 etc. */
    if(sbm_flag)
    {
        ia_gx1 = (int)((a_gx1 / loggrd.tx) * MAX_PG_IAMP);
        ia_gxw = (int)((a_gxw / loggrd.tx) * MAX_PG_IAMP);
        ia_gxwex = (int)((a_gxwex / loggrd.tx) * MAX_PG_IAMP);
        ia_gz1 = (int)((a_gz1 / loggrd.tz) * MAX_PG_IAMP);
        ia_gzk = (int)((a_gzk / loggrd.tz) * MAX_PG_IAMP);
    }
#endif

    sspinit(psd_board_type);
    debugstate = debug;

    if (touch_flag)
    {
        setwatchdogrsp(watchdogcount);  /*First give pulsegen a little extra time */
    }

    /* setup view copy dab packet pointer and length */
    /* copy_dab_pkt_array2 is the right packet for CERD/MGD */
    copy_pkt_length = 15us;

@inline vmx.e VMXpg  /* vmx - 26/Dec/94 - YI */

    /* Initialize psdexitarg */
    psdexitarg.abcode = 0;
    strcpy( psdexitarg.text_arg, "pulsegen" );
    view       = 0;
    slice      = 0;
    excitation = 0;
    psdexitarg.longarg[0] = (long *)&rspent;
    psdexitarg.longarg[1] = (long *)&view;
    psdexitarg.longarg[2] = (long *)&slice;
    psdexitarg.longarg[3] = (long *)&excitation;

    /* Don't generate SpSAT sequence if pulsegen() called
       during dB/dt optimization - RJF */

    if (!pgen_for_dbdt_opt)
    {
        /*****************
         *  Spatial Sat  *
         *****************/
        sp_satindex = 0;
        sp_satstart = RUP_GRD(tlead_spsat - rfupa);

        if ( (opsatx)||(opsaty)||(opsatz)||(opexsatmask)||(feature_flag & RTIA98)) {
            sp_sat = 1;
        } else {
            sp_sat = 0;
        }
        SpSatPG_fgre( vrg_sat, sp_satstart, &sp_satindex,
                      sp_satcard_loc, sp_sattime );
    }

    /* Don't generate ChemSAT sequence if pulsegen() called
       during dB/dt optimization - RJF */

    if (!pgen_for_dbdt_opt)
    {
        /**************
         *  Chem Sat  *
         **************/
        cs_satindex = 0;
        if( cs_sat )
        {
            ChemSat_PG( cs_satstart, cs_sattime, &cs_satindex,
                        &cs_tune, feature_flag );
        }
    }

    /* JAP ET */
    if( FAILURE == et_pulsegen( feature_flag, etl, opslquant, dda, spgr_flag, rsprot ) )
    {
        return FAILURE;
    }

    /*
     * Cardiac Waits
     * Place at beginning to time trigger delays.
     * All slices after first in the R-R will have the
     * period changed to 4us to essentially nullify
     * this wait.
     */
    WAIT(XGRAD, x_td0, PosTlead, pw_x_td0);
    WAIT(YGRAD, y_td0, PosTlead, pw_y_td0);
    WAIT(ZGRAD, z_td0, PosTlead, pw_z_td0);
    WAIT(RHO, rho_td0, PosTlead, pw_rho_td0);
    WAIT(OMEGA, theta_td0, PosTlead, pw_theta_td0);
    WAIT(SSP, ssp_td0, PosTlead, pw_ssp_td0);


    /***********************
     *  90 and 180 pulses  *
     ***********************/
    /*  90 slice sel pulse  */
    /* NOTE: res_rf1_full is res of full pulse, res_rf1 is res of
       fractional rf pulse, pw_rf1 is width of fractional pulse */

    {
        /*
         * MRIge58717 - RJF/YZ - This variable holds the original rf
         * pulse resolution so that it doesn't get changed by sucessive
         * rf pulse stretches during dB/dt optimization which calls
         * pulsegen on the host.  This is an issue only when using an
         * external file.
         */
        int temp_res = res_rf1;

        /* Stretch (re-interpolate) external rf pulse */
        if( (minph_pulse_flag && minph_pulse_index != MINPH_RF_SINC1) || (fiesta_rf_flag) )
        {
            EXTERN_FILENAME ext_filename = "\0";

            if( fiesta_rf_flag )
            {
                if (vstrte_flag)
                {
                   strcpy( ext_filename, "fermi24.rho" );
                } else {
                /* Use FIESTA tbw2_1_01.rho */
                   strcpy( ext_filename, "tbw2_1_01.rho" );
                }
                /* Set new resolution and stretch external pulse */
                stretch_pulse( RF1_SLOT, ext_filename, rfpulseInfo, &temp_res,
                               &wave_space );
                res_rf1_full = temp_res;
            } else if( minph_pulse_flag ) {
                /* Begin RTIA */
                switch( minph_pulse_index ) {
                case MINPH_RF_RTIA:
                    strcpy( ext_filename, "rf_bw4_800us.rho" );
                    break;
                case MINPH_RF_2DTF26:
                    strcpy( ext_filename, "rf2dtf26.rho" );
                    break;
                case MINPH_RF_TBW2:
                    strcpy( ext_filename, "tbw2_200us.rho" );
                    break;
                case HARD_RF_24:
                    strcpy( ext_filename, "fermi24.rho" );
                    break;
                case LPH_RF_TBW6:
                    strcpy( ext_filename, "tbw6_01_01_600.rho" );
                    break;
                default:
                    /* Do nothing */
                    break;
                }
                /* Set new resolution and stretch external pulse */
                stretch_pulse( RF1_SLOT, ext_filename, rfpulseInfo, &temp_res,
                               &wave_space );
                res_rf1_full = temp_res;
                /* End RTIA */
            } else {
                /* HUH!? You should not be here */
            }
        }

        setWaveformPurpose( rf1, EXCITATION_RF );
        /* Set rf pulse name */
        pulsename( &rf1, "rf1" );   /* MRIge58717  RJF/YZ */
        /* Create some RHO waveform space */
        createreserve( &rf1, RHO, temp_res );

        /* BJM: this function is similar to addrfbits in that it sets up  */
        /* the control words for an RF pulse.  This function allows the   */
        /* RF Amp Unblank time to be reduced to 50us and insures that the */
        /* total RF Amp unblank time is >= 260 us to allow the SSM to     */
        /* finish checking errors (faults occur if this is not obeyed...  */
        {
            int rfupa_time = abs( rfupacv ); /* Changed it back to rfupacv(HDxt) from rfupa(DVMR) */

            fastAddrfbits( &rf1, 0, PosStart + pw_gzrf1a + psd_rf_wait, pw_rf1, rfupa_time );
        }

        createinstr( &rf1, PosStart + pw_gzrf1a + psd_rf_wait, pw_rf1, ia_rf1 );

        /* Save instruction number for scan pulse - this is done
           because of the way the rf1mps1 pulse is created in
           MPS1Prescan.e. rf1mps1 is a duplicate of the rf1
           pulse (same waveform memory); they are distinguished
           by their instruction numbers */
        scanrf1_inst = rf1.ninsts - 1;

        if( (minph_pulse_flag && minph_pulse_index != MINPH_RF_SINC1) || fiesta_rf_flag ) {
            /* Read in the external pulse to local memory, and then move
               the local memory to the reserved RHO memory. */
            movewaveimm( wave_space, &rf1, 0L, temp_res, TOHARDWARE );
        } else {
            /* Create rf sinc pulse using full resolution */
            wave_space = (short*)AllocNode( res_rf1_full * sizeof(short) );
            usinc( wave_space, res_rf1_full, (short)max_pg_wamp, cyc_rf1, alpha_rf1 );
            /* Move the local memory to the reserved RHO memory.
               Copy only part of it using the fractional resolution. */
            movewaveimm( wave_space, &rf1, 0L, temp_res, TOHARDWARE );
            setweos( EOS_DEAD, &rf1, temp_res - 1 );
        }
    }

    if( feature_flag & FIESTA ) {
        getssppulse( &prf1frq, &rf1, "frq", scanrf1_inst );
        getwave( &rf1frqrsp, prf1frq );
    }

    /****************************************************************
     *  Z slice select, rephaser, flowcomp and slice encode pulses  *
     ****************************************************************/
    setWaveformPurpose( gzrf1, RF_SELECT_GRAD );
    SINGLE_TRAP( ZGRAD, gzrf1, pbeg( &rf1, "rf1", scanrf1_inst ) -
                 psd_rf_wait, 0, , TYPNDEF, TRAP_ALL, , , loggrd );

    PosGz1 = pendall( &gzrf1, 0 ) + gz1_spacer + pw_gz1a;

    setWaveformPurpose( gz1, WINDER_GRAD );
    SINGLE_TRAP( ZGRAD, gz1, PosGz1, 0, , TYPNDEF, TRAP_ALL, , , loggrd );

    /* MRIge38985 */

    /* RTIA - RJF */
    if (( flow_comp_type == TYPFC ) && ( ! (feature_flag & RTIA98 ) ) ) {
        /* End RTIA - RJF */
        /* don't have to round because pendall */
        /* and pw_gzfc are already rounded */

        PosGzfc = pendall( &gz1, 0 )+ pw_gzfca;
        setWaveformPurpose( gzfc, COMPENSATION_GRAD );
        SINGLE_TRAP( ZGRAD, gzfc, PosGzfc, 0, ,
                     TYPNDEF, TRAP_ALL, , , loggrd );
    }

    /**********************************************
     *  X Readout, Dephaser and Data Acquisition  *
     **********************************************/
    PosReadoutWindow = RUP_GRD(PosStart + t_exa + te_time - t_rd1a);

#ifdef UNDEF
    PosDabPkt = pbegall( &rf1, 0 ) + rfupa -
        rffrequency_length[bd_index] - DAB_length[bd_index];
#endif

    /* BJM: move DAB packet after RF for less upfront deadtime */
    getssppulse(&rec_unblank, &rf1, "ubr", 0);

    /* MRIge73549 - use pendallssp to position dabpkt at the
       end of receiver unblank pulse. - RJF */
    PosDabPkt = pendallssp (rec_unblank, 0);

    /* This is the copy dab packet to enable view sharing. Add
       psd_rf_wait to ensure that all rf bits are played out
       before the copydab packet. */
    /* JAP ET */
    /* copystart = pendall(&rf1, 0) + copydelay; */
    /* BJM: moved to just after dab position */
    /*ZZ: moved to after ssp_touch_sync */

    copystart = PosDabPkt
                + (!(feature_flag & ECHOTRAIN) ? DAB_length[bd_index] : HSDAB_length )
                + ((feature_flag & TOUCH)? (touch_time + touch_sync_pw + 2*GRAD_UPDATE_TIME) :0);


    SSPPACKET( copydab, copystart, copy_pkt_length, copy_dab_pkt_array2, );

    if (vstrte_flag) {
       dab_offset = copystart + copy_pkt_length - (PosReadoutWindow + pw_gxwl + psd_grd_wait + dt - rs_offset);
       xtr_offset = dab_offset + DAB_length[bd_index];

    } else {
       dab_offset = 0;
    }

    EP_TRAIN2(PosReadoutWindow,
              etl,
              0,
              etl,
              STD_REC,
              /* Only create a dab for single echo */
              (!(feature_flag & ECHOTRAIN)),
              (psd_grd_wait + dt - rs_offset),
              dab_offset,
              xtr_offset,
              loggrd);


    /* This is when the rewinder starts so we need to wait a
       little so as not to update the rewinder amplitude with
       our forced isi update starts isi6 interrupt isidelay ms
       after the gy1 rewinder begins playing out */
    /* JAP ET */
    /* Move position of Isi to immediately after the first echo RBA packet */
    /* 4 usec moves isi6 immediately after TNS packet */
    getssppulse(&echo1rba, &echo1, "rba", 0);
    if( feature_flag & FIESTA ) {
        getssppulse(&pecho1xtr, &echo1, "xtr", 0);
        getwave(&echo1xtrrsp, pecho1xtr);
    }

    PosTNSon = pendallssp(echo1rba, 0);
    TNSON(e1entns, PosTNSon);

    PosIsi = pendallssp(&e1entns, 0) + isidelay;
    WAIT(SSP, isi6, PosIsi, pw_isi6);

    attenflagon( &echo1, 0 );

    /* Dual echo modification, DUALECHO */
    if( opnecho >= 2 ) {

        /* MEGE */
        char pulse_name[20];

        readecho = (WF_PULSE *)AllocNode(opnecho*sizeof(WF_PULSE));
        p_readechorba = (WF_PULSE_ADDR *)AllocNode(opnecho*sizeof(WF_PULSE_ADDR));

        area_gx2 = -a_gxw * ((pw_gxwa/2) + pw_gxw + (pw_gxwd/2));

        for( i =0; i<(opnecho-1); i++)
        {

            if (PSD_ON == pos_read)
            {
                setWaveformPurpose( gx2, WINDER_GRAD );
                PosGx2 = pendall( &gxw, 0 ) + pw_gx2a + i*average_esp;
                TRAPEZOID ( XGRAD, gx2, PosGx2, area_gx2, TYPNDEF, loggrd);
            }

            if( flag_3t == PSD_ON || (feature_flag & MFGRE) || r2_flag )
            {
                PosDab2 = pendallssp(&isi6, 0) + psd_grd_wait + i*average_esp;
            } else {
                PosDab2 = pendall(&gxw, 0) - pw_gxwd - t_rdb + psd_grd_wait + i*average_esp;
            }

            /* MRIge92350 -  PosReadoutEcho2 is moved out from if statement above to
            accout for difference between t_rd1a and t_rdb for all field strength. */
            /* GEHmr01622 - the difference between t_rd1a and t_rdb is absorbed in the act_te2 calculation.
            Hence the term is no longer needed. */
            PosReadoutEcho2 = PosReadoutWindow + (i+1)*average_esp /*+ t_rd1a-t_rdb*/;
            setWaveformPurpose( gxw2, READOUT_GRAD );
            TRAPEZOID ( XGRAD, gxw2, PosReadoutEcho2, 0, TYPNDEF, loggrd);

            /* Waveform amps are set +ve. Negate instruction amps */
            if(PSD_OFF == pos_read)
            {
                getiamp(&temp_amp, &gxw2, i);
                setiampt((i%2)?temp_amp:-temp_amp, &gxw2, i);
            }

%ifdef UNDEF

        /* MRIge72594 Changed xtr position reference from default
           to explicit..note 50 us (instead of XTRSETLNG) for
           xtr offset (fast_xtr_setlng) */
        ACQUIREDATA(echo2,
                    PosReadoutEcho2+psd_grd_wait, /* acq position reference */
                    PosDab2,                      /* dab position reference */
                    PosReadoutEcho2+psd_grd_wait-
                    XTR_length[bd_index]-
                    fast_xtr_setlng,              /* xtr position reference */
                    DABNORM );
%endif

        sprintf(pulse_name,"readecho%d",i);
        pulsename(&(readecho[i]),pulse_name);

        acqq(&(readecho[i]), PosReadoutEcho2 + psd_grd_wait, PosDab2, (long)(PosReadoutEcho2+psd_grd_wait-XTR_length[bd_index]-fast_xtr_setlng), filter_echo1, (TYPDAB_PACKETS)DABNORM);


        getssppulse(&(p_readechorba[i]), &(readecho[i]), "rba", 0);


        /* getssppulse(&p_echo2rba, &echo2, "rba", 0); */

        } /* MEGE, end of i */

        TNSOFF(e1distns, PosReadoutEcho2 + pw_gxw2 + psd_grd_wait);

    } else {

        PosTNSoff = IMax( 2, pendallssp(&isi6, 0),
                          pend(&gxw, "gxw", gxw.ninsts - 1) + psd_grd_wait);
        TNSOFF(e1distns, PosTNSoff);

    }

    ATTENUATOR( attenuator_key, pendallssp( &e1distns, 0 ) );

    /* JAP ET */
    if (!(feature_flag & ECHOTRAIN)) {
        getwave( &echo1dab, &echo1 );
        getwave( &echo1rba_index, echo1rba );
    }

    /* Multi Echo */
    if( opnecho >= 2 ) {
        for(i=0;i<(opnecho-1);i++) {
            getwave(&(readechodab[i]), &(readecho[i]));
            getwave(&(readechorba[i]), p_readechorba[i]);
        }
    }

    /* Fast CINE - Create CINE packet to be used during the Fast CINE core
       section - 18/Feb/1998 - GFN */
    if ( FAILURE == fcine_pulsegen( act_tr , feature_flag ) ) {
        return FAILURE;
    }

    /* frequency dephaser */
    PosGx1 = pbeg( &gxwa, "gxwa",  0 ) - (pw_gx1 + pw_gx1d);
    setWaveformPurpose( gx1, WINDER_GRAD );
    SINGLE_TRAP( XGRAD, gx1, PosGx1, 0, , TYPNDEF, TRAP_ALL, , , loggrd );

    /* Insert flow comp pulses */
    /* MRIge38985 */
    /* RTIA - RJF */
    if ((TYPFC == flow_comp_type) && (!(feature_flag & RTIA98)))
    {
        /* End RTIA - RJF */
        /* 1st echo flow comp pulse */
        PosGxfc = pbegall( &gx1, 0 ) - (pw_gxfc + pw_gxfcd);
        SINGLE_TRAP( XGRAD, gxfc, PosGxfc, 0, , TYPNDEF, TRAP_ALL, , , loggrd );
    }

    /* JAP ET */
    /* Begin RTIA change - use XGRAD to unbridge pulses for RTIA */
    if(PSD_ON == gxwex_on)
    {
        if( bridge )
        {
            temp_wave_gen = XGRADB;
            if( opnecho >= 2 ) { /* Dual echo, DUALECHO */
                PosXKiller = pend( &gxw2, "gxw2", gxw2.ninsts - 1 ) + pw_gxwexa;
            } else {
                PosXKiller = pend( &gxw, "gxw", gxw.ninsts - 1 ) + pw_gxwexa;
            }
        } else {
            temp_wave_gen = XGRAD;
            /* RJF, dual echo */
            if( opnecho >= 2 ) {
                PosXKiller = pend( &gxw2, "gxw2", gxw2.ninsts - 1 ) + pw_gxw2d + pw_gxwexa;
            } else {
                PosXKiller = pend( &gxw, "gxw", gxw.ninsts -1 ) + pw_gxwd + pw_gxwexa;
            }
        }

        setWaveformPurpose( gxwex, KILLER_GRAD );
        TRAPEZOID( temp_wave_gen, gxwex, PosXKiller, 0, TYPNDEF, loggrd );

        if ( opnecho >= 2 && !pos_read && (0==opnecho%2) )
        {
            getiamp(&temp_amp, &gxwex, 0);
            setiampt(-temp_amp, &gxwex, 0);
        }

    }
    /* End RTIA change - RJF */

    /*******************************************
     * Y phase encoding and possible rewinder  *
     *******************************************/

    /* account for the extra pulse */
    PosPhaseEncode1 = pbeg( &gxw, "gxw", 0 ) - pw_gy1 - pw_gy1a -
        pw_gy1d - (yfe_time/2) - grdrs_offset;

    setWaveformPurpose( gy1, STEP_ENCODER_GRAD );
    SINGLE_TRAP( YGRAD, gy1, PosPhaseEncode1 + pw_gy1a, ,
                 endview_scale,  TYPNDEF, TRAP_ALL_SLOPED, , , loggrd );

    /* Dual echo, DUALECHO */ /* DUALECHO BWL */
    if( opnecho >= 2 ) {
        PosPhaseRew1 = pend( &gxw2, "gxw2", gxw2.ninsts - 1 ) + grdrs_offset;
    } else {
        PosPhaseRew1 = pend( &gxw, "gxw", gxw.ninsts - 1 ) + grdrs_offset;
    }

    setWaveformPurpose( gy1r, STEP_ENCODER_GRAD );
    SINGLE_TRAP( YGRAD, gy1r, PosPhaseRew1 + pw_gy1ra, ,
                 endview_scale,  TYPNDEF, TRAP_ALL_SLOPED, , , loggrd );

    /* Add trapezoidal flow encoding pulses here.
       These will be enabled in a PC sequence.
       Make sure that you use pbegall() and pendall() so that when
       generated on the Host side the pulses do not overlap. */
    if ( oppseq == PSD_PC ) {
        /* first flow encoding */
        setWaveformPurpose( gyfe1, WINDER_GRAD );
        SINGLE_TRAP( YGRAD, gyfe1, pbegall( &gy1, 0 ) - pw_gyfe1 -
                     pw_gyfe1d, 0, , TYPNDEF, TRAP_ALL, , , loggrd );
        /* 2 second flow encoding */
        setWaveformPurpose( gyfe2, WINDER_GRAD );
        SINGLE_TRAP( YGRAD, gyfe2, pendall( &gy1, 0 ) + pw_gyfe2a,
                     0, , TYPNDEF, TRAP_ALL, , , loggrd );
    }


    /**********************************
     *  Set up exorcist pointer - LX2 *
     **********************************/
    if (opexor || (PSD_ON == cmon_flag))
    {
        exorcist_pulse.rf1_time = pbeg(&rf1, "rf1", scanrf1_inst);
        exorcist_pulse.echo[0].phase_encode_time = pbeg(&gy1, "gy1", 0);
        exorcist_pulse.echo[0].dab_time = pbeg(&gy1, "gy1", 0);
        exorcist_pulse.echo[0].phase_encode_rewinder_time = pbeg(&gy1r,
                                                                 "gy1r", 0);
        exorcist_pulse.rf1_phase = 0;  /* corresponds to half pi */
    }


    /***************
     *  Z Killer   *
     *******************/
    /* Dual echo, DUALECHO */
    if( feature_flag & FIESTA )
    {
        if( gzk_b4_gzrf1 )
        {
            PosZKiller = PosStart - gzktime + pw_gzka;
        }
        else
        {
            PosZKiller = pend(&gxw, "gxw", gxw.ninsts - 1) + pw_gzka + read_shift * pw_gxwd;
        }
    } else if( opnecho >= 2 ) {
        PosZKiller = pend(&gxw2, "gxw2", gxw2.ninsts - 1) + pw_gzka + read_shift * pw_gxwd;
    } else {
        PosZKiller = pend(&gxw, "gxw", gxw.ninsts - 1) + pw_gzka + read_shift * pw_gxwd;
    }

    setWaveformPurpose( gzk, KILLER_GRAD );
    TRAPEZOID( ZGRAD, gzk, PosZKiller, 0, TYPNDEF, loggrd );

    /* R2 */
    if((feature_flag & MFGRE) || r2_flag)
    {
        /* set up waits for intte */
        if (intte_flag >= 2)
        {
            intte_delay = IMax(2, (int)(average_esp/intte_flag), 4us);
        } else {
            intte_delay = GRAD_UPDATE_TIME;
        }

        pw_inttexl = GRAD_UPDATE_TIME;
        pw_intteyl = GRAD_UPDATE_TIME;
        pw_inttezl = GRAD_UPDATE_TIME;
        pw_inttesl = GRAD_UPDATE_TIME;
        pw_intterl = GRAD_UPDATE_TIME;
        pw_intteol = GRAD_UPDATE_TIME;

        WAIT(XGRAD, inttexl,   pbegall( (opfcomp == PSD_ON) ? &gxfc : &gx1, 0 ) - GRAD_UPDATE_TIME,  pw_inttexl);
        WAIT(YGRAD, intteyl,   pbegall( &gy1, 0 ) - GRAD_UPDATE_TIME,  pw_intteyl);
        WAIT(ZGRAD, inttezl,   pendall( (opfcomp == PSD_ON) ? &gzfc : &gz1, 0 ) + GRAD_UPDATE_TIME,  pw_inttezl);
        WAIT(  SSP, inttesl, pbegallssp(&echo1,0) - GRAD_UPDATE_TIME,  pw_inttesl);
        WAIT(  RHO, intterl,   pendall( &rf1, 0 ) + GRAD_UPDATE_TIME,  pw_intterl);
        setrxflag(&intteol, PSD_ON);
        WAIT(OMEGA, intteol,   pendall( &rf1, 0 ) + GRAD_UPDATE_TIME,  pw_intteol);

        if (PSD_ON == gxwex_on)
        {
            posinttexr = pendall(&gxwex, 0);
        } else if (opnecho >= 2) {
            posinttexr = pendall(&gxw2, gxw2.ninsts - 1);
        } else {
            posinttexr = pendall(&gxw, gxw.ninsts - 1);
        }

        if (opnecho >= 2)
        {
            posinttesr = pend(&gxw2, "gxw2", gxw2.ninsts - 1) + psd_grd_wait + 4us;
        } else {
            posinttesr = pend(&gxw, "gxw", gxw.ninsts - 1) + psd_grd_wait + 4us;
        }
        posinttesr = IMax(2, posinttesr, pendallssp( &attenuator_key, 0 ));
        posintteyr = pendall(&gy1r,0);
        posinttezr = pendall(&gzk,0);
        posintterr = IMax(4, posinttexr, posintteyr, posinttezr, posinttesr);
        posintteor = posintterr;

        pw_inttexr = IMax(2, (intte_flag - 1) * intte_delay, 4us);
        pw_intteyr = pw_inttexr;
        pw_inttezr = pw_inttexr;
        pw_inttesr = pw_inttexr;
        pw_intterr = pw_inttexr;
        pw_intteor = pw_inttexr;

        WAIT(XGRAD, inttexr, posinttexr,  pw_inttexr);
        WAIT(YGRAD, intteyr, posintteyr,  pw_intteyr);
        WAIT(ZGRAD, inttezr, posinttezr,  pw_inttezr);
        WAIT(  SSP, inttesr, posinttesr,  pw_inttesr);
        WAIT(  RHO, intterr, posinttesr,  pw_intterr);
        setrxflag(&intteor, PSD_ON);
        WAIT(OMEGA, intteor, posintteor,  pw_intteor);
    }

    /** MRIge51748: changed (flow_comp_type==TYPFC) to ( oppseq == PSD_PC )  **/
    if ( FAILURE == et_pulsegen2( feature_flag, phaseres,
                                  (opfcomp == PSD_ON) ? &gzfc : &gz1,
                                  &rf1, (opfcomp == PSD_ON) ? &gxfc : &gx1,
                                  (oppseq == PSD_PC) ? &gyfe2 : &gy1,
                                  &gxw, &attenuator_key, pw_gxwd, etl,
                                  echotrain ) )
    {
        return FAILURE;
    }

    if (touch_flag)
    {
        int pos_enc, i;
        short dab6on[4];
        short dab6off[4];

        dab6on[0] = SSPDS+EDC;
        dab6on[1] = SSPOC+DREG;
        dab6on[2] = SSPD+DABOUT6;
        dab6on[3] = SSPDS + 0x8000;

        dab6off[0] = SSPDS+EDC;
        dab6off[1] = SSPOC+DREG;
        dab6off[2] = SSPD;
        dab6off[3] = SSPDS + 0x8000;

        /****************************************************************
          Encode gradients
         *****************************************************************/
        if (1==touch_fcomp)
        {
            pos_enc = pendall(&gzfc,0);
            if (touch_gnum)
            {
                AddEncodeFcomp(pos_enc);
                AddEncodeDown(pos_enc+touch_lobe);
                pos_enc += touch_period;
                for (i=1; i<touch_gnum; i++)
                {
                    AddEncodeUp(pos_enc);
                    AddEncodeDown(pos_enc+touch_lobe);
                    pos_enc += touch_period;
                }
                AddEncodeFcomp(pos_enc);
            }
        }
        else if (2==touch_fcomp)
        {
            pos_enc = pendall(&gzfc,0);
            if (touch_gnum)
            {
                AddEncodeFcomp(pos_enc);
                AddEncodeDown(pos_enc+touch_lobe/2);
                pos_enc += 3*touch_lobe/2;
                for (i=1; i<touch_gnum; i++)
                {
                    AddEncodeUp(pos_enc);
                    AddEncodeDown(pos_enc+touch_lobe);
                    pos_enc += touch_period;
                }
                AddEncodeFcomp(pos_enc);
            }
        }
        else
        {
            pos_enc = pend(&gz1,"gz1d",0);
            for (i=0; i<touch_gnum; i++)
            {
                AddEncodeUp(pos_enc);
                AddEncodeDown(pos_enc+touch_lobe);
                pos_enc += touch_period;
            }
        }

        /*********************
          Sync Pulses
         *******************/
        {
            int pos_sync = 0;

            pos_sync = pendallssp(&rf1, 0);
            WAIT(SSP, ssp_touch_wait, pos_sync, GRAD_UPDATE_TIME);
            pos_sync += GRAD_UPDATE_TIME;
            SSPPACKET(sync_on, pos_sync, GRAD_UPDATE_TIME, dab6on,);
            pos_sync += touch_sync_pw;
            SSPPACKET(sync_off, pos_sync, GRAD_UPDATE_TIME, dab6off,);
            pos_sync += GRAD_UPDATE_TIME;
            WAIT(SSP, ssp_touch_sync, pos_sync, pw_ssp_touch_sync);
        }
    }

    /* There is no x gradient killer in FGRE sequence */
    psd_seqtime = RUP_GRD(act_tr - time_ssi);

    SEQLENGTH(seqcore, psd_seqtime, seqcore);

    /* save the scan deadtime */
    getperiod( &scan_deadtime, &seqcore, 0 );

    /* Assert the ESSP flag on the sync packet created by seq length */
    attenflagon( &seqcore, 0 );

    /************************************************************
     *
     ***********************************************************/
    if(FAILURE == mph_long_delay( sldeltime, feature_flag ))
    {
        return FAILURE;
    }

    if(FAILURE == mpl_get_seqtime( act_tr, cs_sattime, sp_sattime,
                          slquant1, scan_deadtime, scan_deadtime,
                          feature_flag ))
    {
        return FAILURE;
    }

    if(FAILURE == fmpvas_get_seqtime( cs_sattime, sp_sattime, scan_deadtime))
    {
        return FAILURE;
    }

    if(touch_flag)
    {
        mphseq_seqtime = RUP_GRD(scan_deadtime - (cs_sattime+sp_sattime));
        ps2mphseq_seqtime = mphseq_seqtime;
    }
    else
    {
        mphseq_seqtime = 0;
        ps2mphseq_seqtime = 0;
    }

    DAB_start = 0;

    /* Don't generate the additional sequences for RTIA98
       when pulsegen is called for dBdt optimization - RJF */

    if ( !pgen_for_dbdt_opt )
    {
        /* Begin RTIA - RJF */
        if (FAILURE == RTFgrePG( pos_start, tlead, act_te_fc, act_tr_fc,
                       minph_pulse_index, &rtia_flowcomp_deadtime, feature_flag ))
        {
            return FAILURE;
        }

        if ( FAILURE == Hard180PG( feature_flag , hard180_time) )
        {
            return FAILURE;
        }

        /* Create a dummy wait sequence of length act_tr */
        if ( FAILURE == rtia_dummy_sequence_PG( rtia_dummy_sequence_TR,
                                            time_ssi, ((feature_flag & RTIA98)==RTIA98)) )
        {
            return FAILURE;
        }

        if ( FAILURE == RTIA_set_seq_deadtime( feature_flag, cs_sattime,
                                               sp_sattime, scan_deadtime,
                                               rtia_flowcomp_deadtime ) )
        {
            return FAILURE;
        }
        /* End RTIA */
    }

#ifdef IPG
    /* MRIge49699 - Removed arguments */
    if(FAILURE == prescan_pulsegen())
    {
        return FAILURE;
    }
#endif /* IPG */

    /**************************
     *  Pass Packet sequence  *
     **************************/
    /* set to default;feature calls will change if needed */
    pass_seqtime = RUP_GRD(TR_PASS);

    mph_passtime( &pass_seqtime, sldeltime, feature_flag );

    /*MRIhc20334 */
    if ((feature_flag & FIESTA) && (PSD_OFF != fiesta_intersl_crusher))
    {
        TRAPEZOID(ZGRAD, gzinterslk, pw_gzinterslka + delay_intersl_crusher,area_fiesta_intersl_crusher,TYPDEF,loggrd);

        if (debugstate != PSD_ON)
        {
            char debugstr[255] = "";
            sprintf(debugstr, "area is %f, pw_slk is %d, pw_slka is %d, pw_slkd is %d, a_slk is %f\n",
                    area_fiesta_intersl_crusher, pw_gzinterslk, pw_gzinterslka, pw_gzinterslkd, a_gzinterslk);
            printdbg(debugstr, debugstate);
        }
    }

    PosPASS = TR_PASS - 1ms;
    PASSPACK( pass_pulse, PosPASS );
    SEQLENGTH( seqpass, pass_seqtime, seqpass );
    getperiod((long*)&seqpass_deadtime, &seqpass, 0); /* MRIhc20775 */

    /* ETA pause sequence for communication with RTP to get dt value */
    SEQLENGTH(eta_seqpause, eta_tr, eta_seqpause);

    /*******************************
     *  Copy view Packet sequence  *
     *******************************/
    /* View copy stuff */
    SSPPACKET( copydab2, copy2start, copy_pkt_length,
               copy_dab_pkt_array2, );
    copydabtime = RUP_GRD( copydelay + copy_pkt_length +
                           copy2start + copydabwait );
    SEQLENGTH( seqcopy, copydabtime, seqcopy );

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    if(sbm_flag)
    {
        SEQLENGTH(seqsbmwait, sbm_min_period, seqsbmwait);
    }

    /**********************************************************
     *  Dummy sequence for pause for CREATIV (stress) feature  *
     **********************************************************/
    SEQLENGTH(seqpause, TR_PASS, seqpause);

@inline T1Map.e T1MapPG

    /* Don't generate any of the feature related sequences
       when pulsegen is called for dB/dt optimizations. - RJF */

    if (!pgen_for_dbdt_opt)
    {
        /*******************
         *  Prep sequence  *
         *******************/
        if (FAILURE == prep_pulsegen(intsldelay, time_ssi, num_scanlocs, feature_flag))
        {
            return FAILURE;
        }

        /********************************
         *  Fastcard pulsegen sequence  *
         ********************************/
        if (FAILURE == fastcard_pulsegen(feature_flag))
        {
            return FAILURE;
        }

        /******************************
         *  Fmpvas pulsegen sequence  *
         ******************************/
        if (FAILURE == fmpvas_pulsegen(phorder, feature_flag))
        {
            return FAILURE;
        }

        /*******************************************
         *  Respiratory Trigger pulsegen sequence  *
         *******************************************/
        if ( FAILURE == respgate_pulsegen( feature_flag ) )
        {
            return FAILURE;
        }

        /*******************************
         *  Tagging pulsegen sequence  *
         *******************************/
        if (FAILURE == tagging_pulsegen(feature_flag, time_ssi))
        {
            return FAILURE;
        }

        /**************************************
         *  Fiesta Fat SAT pulsegen sequence  *
         **************************************/
        if (FAILURE == fiesta2d_sat_pulsegen(time_ssi, tlead, feature_flag))
        {
            return FAILURE;
        }

        if ( SatRelaxers )
        {
            SpSatCatRelaxPG(time_ssi);
        }

    }

    if (FAILURE == buildinstr())
    {
        return FAILURE;
    }

    if ( SatRelaxers )
    {
        SpSatCatRelaxOffsets( off_seqcore );
    }

    if (PSD_ON == touch_flag)
    {
#ifdef IPG
        if((fp=fopen(".SKIP_MRE_DRIVER","r"))==NULL)
        {
            /* Make frequency slightly larger to ensure that the driver
             * completes prior TR */
            if ( FAILURE == setmrtouchdriver(touch_act_freq/0.99,
                                             touch_burst_count,
                                             touch_driver_amp) )
            {
                return FAILURE;
            }
        }
        else
        {
            fclose(fp);
        }
#endif
    }

    /***********************************************************
     * Initialization                                          *
     * This section performs the equivalent of the IPI section *
     * DOWNLOAD in 4.0..                                       *
     ***********************************************************/

    /* Allocate memory for various arrays.
       An extra 2 locations are saved in case the user wants to do
       some tricks. */
    acq_ptr       = (short*)AllocNode(      (acqs + 2) * sizeof(short) );
    slc_in_acq    = (short*)AllocNode(      (acqs + 2) * sizeof(short) );
    rf1_freq      =   (int*)AllocNode( (opslquant + 2) * sizeof(int) );
    receive_freq1 =   (int*)AllocNode( (opslquant + 2) * sizeof(int) );
    receive_freq2 =   (int*)AllocNode( (opslquant + 2) * sizeof(int) );
    rf1_flip      =   (int*)AllocNode(    (opvps + 20) * sizeof(int) );



    /* liyuan realtime imaging update */
    if(realu_flag == PSD_ON){
        int j;
    	realurot = (long **)AllocNode(opslquant*sizeof(long *));
        rsprot_temp = (long **)AllocNode(opslquant*sizeof(long *));

    	for (j=0; j<opslquant; j++){
       	    realurot[j] = (long *)AllocNode(9*sizeof(long));
            rsprot_temp[j] = (long *)AllocNode(9*sizeof(long));
        }
    }

    /* Save copy of scan_info table */
    for(temp1=0; temp1<opslquant; temp1++) {
        orig_rsp_info[temp1].rsptloc = rsp_info[temp1].rsptloc;
        orig_rsp_info[temp1].rsprloc = rsp_info[temp1].rsprloc;
        orig_rsp_info[temp1].rspphasoff = rsp_info[temp1].rspphasoff;
    }
    /* liyuan end */


#ifdef IPG
    /* Swap index */ /* VAL15 02/21/2005 YI */
    if(pc_mode < PC_BASIC){
      phase_cycles = nex_save;
      nex = 1;
    }
#endif

    if (touch_flag)
    {
	cmxuamp[0] = ia_gxtouchu;
        cmxuamp[1] = (short)(touch_gamp2*ia_gxtouchu);
	cmxdamp[0] = ia_gxtouchd;
        cmxdamp[1] = (short)(touch_gamp2*ia_gxtouchd);
	cmxfamp[0] = ia_gxtouchf;
        cmxfamp[1] = (short)(touch_gamp2*ia_gxtouchf);
	cmyuamp[0] = ia_gytouchu;
        cmyuamp[1] = (short)(touch_gamp2*ia_gytouchu);
	cmydamp[0] = ia_gytouchd;
        cmydamp[1] = (short)(touch_gamp2*ia_gytouchd);
	cmyfamp[0] = ia_gytouchf;
        cmyfamp[1] = (short)(touch_gamp2*ia_gytouchf);
	cmzuamp[0] = ia_gztouchu;
        cmzuamp[1] = (short)(touch_gamp2*ia_gztouchu);
	cmzdamp[0] = ia_gztouchd;
        cmzdamp[1] = (short)(touch_gamp2*ia_gztouchd);
	cmzfamp[0] = ia_gztouchf;
        cmzfamp[1] = (short)(touch_gamp2*ia_gztouchf);
	SetTouchAmp(0);
    }

    rspdex = dex;
    rspech = 0;
    rspchp = 1;

    /* research rsp initialization */
    rmode  = 0;
    reschp = 1;
    resdda = dda;
    resbas = baseline;
    resvus = opyres;
    resnex = nex;
    reschp = 1;
    resesl = 0;
    resasl = 0;
    resslq = slquant1;
    ressct = 1;
    resech = 0;
    resdex = dex;

    debugstate = debug;
    if (opblim) {
        blimfactor = 1;
    } else {
        blimfactor = -1;
    }

#ifdef IPG
    /*
     * Execute this only on the IPG side.
     */
    /* RTIA changes exist(opfov) to psd_fov */
    setupslices( rf1_freq, rsp_info, opslquant, a_gzrf1,
                 1.0, (float) (rhfreqscale*psd_fov), (INT)TYPTRANSMIT );
    setupslices( receive_freq1, rsp_info, opslquant,
                 0.0, echo1bw, (float)(rhfreqscale*psd_fov), (INT)TYPREC );
    /* Freq offset for second echo for dual echo DUALECHO ALP */
    if( opnecho >= 2 )
    {
        INT temp_grad;

        if((PSD_ON == pos_read) && opnecho >= 2)
        {
            temp_grad = (INT)TYPREC;
        }
        else
        {
            temp_grad = (INT)TYPRECGRDEVEN;
        }

        setupslices( receive_freq2, rsp_info, opslquant,
                     0.0, echo2bw, (float)(rhfreqscale*psd_fov),
                     temp_grad );
    }

    if(gss_debug & 2) {
        int i;
        int iii;
        for(iii=0;iii<opslquant;iii++) {
            printf("pg rf1_freq[%d]=%d\n",iii,rf1_freq[iii]);
        }
        for(i=0;i<9;i++) {
            printf("rsprot[%d]=%ld\t",i,rsprot[0][i]);
            if((i+1)%3==0) {
                printf(" \n");
            }
        }
        fflush(stdout);
    }

#ifdef SIM_IO
    ipg_trigtest = 0;
#endif

    if ( ipg_trigtest == 0 ) {
        /* Inform the IPG of the trigger array to be used */
        /* Following code is just here to support IPG oversize
           board which only supports internal gating */
        for ( slice = 0 ; slice < opslquant; slice++ ) {
            rsptrigger[slice] = (long)TRIG_INTERN;
        }
        slice = 0;
    }

    /* Inform the IPG of the trigger array to be used */
    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    settriggerarray( (short)opslquant, rsptrigger );


    /* Inform the IPG of the rotation matrix array to be used */
    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    setrotatearray( (short)opslquant, rsprot[0] );


    /* Setup exorcist tables - LX2 */
    if (PSD_ON == cmon_flag)
    {
        exorcist_pg( &resp_comp_type );
    }

    /* update RSP maxTG with min TGlimit value */
    maxTGAtOffset = updateTGLimitAtOffset(TGlimit, sat_TGlimit);

#endif /* IPG */

    setupphasetable( viewtable, resp_comp_type, phaseres );

    /* Set up SlcInAcq and AcqPtr tables for multipass scans.
       SlcInAcq array gives number of slices per array.
       AcqPtr array gives index to the first slice in the
       multislice tables for each pass. */
    psd_index = 0; /* init to 0 */

    slmod_acqs = opslquant % acqs;

    /* default values will be overwritten by feature calls - TKF */
    for( pass = 0 ; pass < acqs ; ++pass ) {
        slc_in_acq[pass] = (short)(opslquant / acqs);
        if ( slmod_acqs > pass ) {
            slc_in_acq[pass] = slc_in_acq[pass] + 1;
        }
        acq_ptr[pass] = (short)(opslquant / acqs) * pass;
        if ( slmod_acqs <= pass ) {
            acq_ptr[pass] = acq_ptr[pass] + slmod_acqs;
        } else {
            acq_ptr[pass] = acq_ptr[pass] + pass;
        }

        mph_pass_ptrs( slc_in_acq, acq_ptr, pass, feature_flag );
        fastcardmp_pass_ptrs( feature_flag, slc_in_acq, acq_ptr, pass );
    }

    rsptrigger_temp[0] = (long)TRIG_INTERN;

    /* Setup right interrupt routine for CMON - LX2 */
    /* Begin RTIA */
    if (opexor || (PSD_ON == cmon_flag))
    {
        ssivector( ssiupdates, (short)FALSE );
    } else if ( ((PSD_ON == opsat) &&
                 ((opsatx) || (opsaty) || (opsatz) || (opexsatmask))) ||
                (feature_flag & RTIA98) ) {
        ssivector( ssisat, (short)FALSE );
    }
    /* End RTIA */

    /* Setup Exorcist pulses - LX2 */
    if (PSD_ON == cmon_flag)
    {
        exorcist_pulse.rf1 = &rf1;
        exorcist_pulse.rf1_amp = ia_rf1;
        exorcist_pulse.rf1_index = scanrf1_inst;
        exorcist_pulse.num_echos = opnecho;
        exorcist_pulse.echo[0].dab = &echo1;
        exorcist_pulse.echo[0].phase_encode = &gy1;
        exorcist_pulse.echo[0].phase_encode_index = 0;
        exorcist_pulse.echo[0].phase_encode_rewinder = &gy1r;
        exorcist_pulse.echo[0].phase_encode_rewinder_index = 0;
    }

    if( PSD_ON == track_flag )
    {
        if( FAILURE == track_pulsegen() )
        {
            return FAILURE;
        }
    }

    return SUCCESS;
}   /* end pulsegen() */

LONG get_pos_isi6( void )
{
    return pbegallssp(&isi6, 0);
}   /* end get_pos_isi6() */

@rsp
/*********************************************************************
 *                       FGRE.E RSP SECTION                          *
 *                                                                   *
 * Write here the functional code for the real time processing (Tgt  *
 * side). You may declare standard C variables, but of limited types *
 * short, int, long, float, double, and 1D arrays of those types.    *
 *********************************************************************/
#include <em_psd_ermes.in>
#include <RT.h>
#include <epic_loadcvs.h>
#include "RtpPsd.h"

@inline RTIA.e realtime_includes
@inline RTIA.e rtia98_includes
@inline RTIA.e echotrain_includes
@inline RTIA.e fiesta_includes

/* Include Exorcists RSP variable declarations - LX2 */
@inline Exorcist.e ExorcistRspDecl

@inline ARC.e ARCGetDabView

/* Local function prototypes */
#ifdef QQQ
static void print_offsets( const SEQUENCE_ENTRIES offset_array, 
                           const char *off_name, const char *func_name );
#endif /* QQQ */
static STATUS fgre_viewrecorder( int record_size );

/* Local public variables */
TYPDAB_PACKETS acq_echo1;     /* flags for data acquisiton */
TYPDAB_PACKETS acq_echo2;     /* flags for data acquisiton */

/* HCSDM00397833: Need to increase viewtab to avoid array out of range
 * issue in FastCINE */
short viewtab[2049];          /* view table for fastcard */
short viewtab_IR[2049];       /* view table for RTIA w/IR on */

short* viewtab_ptr;           /* used in RTIA to switch viewtables on the fly */
short dabstatetab[1025];      /* dab table for fastcard */
short rcphasechop[1025];      /* receiver phase table for chopping*/

int deadtime;                 /* amount of deadtime */
int rcvphase_int;             /* integer phase of rcvfrq */
int xrr_trig_time;            /* trigger time for a filled or unfilled
                                 R-R interval which is not the last
                                 R-R interval */
int slnum;                    /* slice index */
int pre_slnum;                /* slice index */

float rf1phase;               /* phase of rf1 */
float rcvphase;               /* phase of rcvfrq */

TYPDAB_PACKETS dabpkt;        /* for switching between dab and cine pkts */

int c_seqtime;
short maxviews;

#ifdef PSD_IPG_DEBUG
int psdisicnt  = 0;
int psd_isi_on = 1;
long psdctrl   = 0;
#endif /* PSD_IPG_DEBUG */
int psdisivector = 6;    /* using isi6 all the time */

int isrtplaunched = 0;

/* Move this array to ipg export when exports get shipped in the save */
const char *entry_name_list[ENTRY_POINT_MAX] = { "scan",
                                                 "mps2",
                                                 "aps2",
                                                 "cfl",
                                                 "cfh",
                                                 "mps1",
                                                 "aps1",
                                                 "autoshim",
                                                 "fasttg",
                                                 "ref",
                                                 "rcvn",
                                                 "expresstg",
                                                 "RFshim",
                                                 "extcal",
                                                 "Autocoil",
                                                 0 };

/* External public variables */
/* Some variables for exorcist simulation */

/* Begin RTIA - Include RTIA RSP variable declarations */
@inline RTIA.e realtime_rsp
@inline RTIA.e rtia98_rsp
@inline RTIA.e echotrain_rsp
@inline RTIA.e fiesta_rsp

/* End RTIA */

/* Include Exorcist RSP code - LX2 */
@inline Exorcist.e ExorcistRsp

@inline T1Map.e T1MapRsp

/** CODE **/

#ifdef QQQ
/*
 *  print_offsets
 *  
 *  Type: Function
 *  
 *  Description:
 *     Debugging function that prints the contents of a given offsets
 *     vector for all the waveform processors.
 */
static void
print_offsets( const SEQUENCE_ENTRIES offset_array, 
               const char *off_name, 
               const char *func_name )
{
    int i;

    printf( "In function [%s]\n", func_name );
    for ( i = 0; i < WF_MAX_PROCESSORS; i++ ) {
        printf( "%s[%d] = %ld\n", off_name, i, offset_array[i] );
    }
    fflush( stdout );
}
#endif /* QQQ */


/*
 *  psdisupdate
 *
 *  Type: Function
 *
 *  Description:
 *    ISI interrupt callback function. It checks for triggers
 *    detected by the SPU.
 */
void
psdisiupdate( void )
{
    /* Look at triggers for fastcard sequence */
    if (TRUE == look_for_trig) 
    {
        trigger_detected = gettrigoccur();
        if (TRUE == trigger_detected)
        {
            trigger_count++;
        }
    }  /* end look for triggers option */
    isi_done = TRUE;

    return;
}   /* end psdisiupdate() */


/* If cont_proceed <= 0, pause until cont_proceed > 0 */ 
static void
SynchronizedPause(void)
{
    if( cont_proceed <= 0 ) {
        boffset( off_seqpause ); 
        while( (cont_proceed <= 0) && (cont_rtia_stop == 0) ) {
            startseq( (short)0, (short)MAY_PAUSE );
        }
        boffset( off_seqcore );
    }
    cont_proceed--;
    return;
}



/* liyuan get_prop_rotation()*/
STATUS
#ifdef __STDC__
get_prop_rotation( void )
#else /* !__STDC__ */
    get_prop_rotation()
#endif /* __STDC__ */
/*
In psdinit(), copy the present rotating matrix for every slice
from scanner when scan() starting, and then save in rsprot_temp
for calculating new rotating matrix during pass loop associating
with set_realu_rotation()
*/

{
    int i, sl_index; /* counter */
    long saverot[9]; /*rotation matrix from scan*/
    float xfull,yfull,zfull;
    float tx,ty,tz;
    float gx,gy,gz;

    /* for simulation */
    xfull = (float)phygrd.xfull/(float)max_pg_iamp;
    yfull = (float)phygrd.yfull/(float)max_pg_iamp;
    zfull = (float)phygrd.zfull/(float)max_pg_iamp;
    tx = (float)loggrd.tx;
    ty = (float)loggrd.ty;
    tz = (float)loggrd.tz;
    gx = (float)phygrd.xfs;
    gy = (float)phygrd.yfs;
    gz = (float)phygrd.zfs;

#ifdef SIM
    if (realu_debug == 1){
   	printf( "xfull %f = phygrd.xfull %f / max_pg_iamp%f\n", xfull, (float)phygrd.xfull, (float)max_pg_iamp);
	printf( "yfull %f = phygrd.yfull %f / max_pg_iamp%f\n", yfull, (float)phygrd.yfull, (float)max_pg_iamp);
	printf( "zfull %f = phygrd.zfull %f / max_pg_iamp%f\n", zfull, (float)phygrd.zfull, (float)max_pg_iamp);
	/*
	printf( "tx = loggrd.tx %f\n", (float)loggrd.tx);
	printf( "ty = loggrd.ty %f\n", (float)loggrd.ty);
	printf( "tz = loggrd.tz %f\n", (float)loggrd.tz);
	printf( "gx = phygrd.xfs %f\n", (float)phygrd.xfs);
	printf( "gy = phygrd.yfs %f\n", (float)phygrd.yfs);
	printf( "gz = phygrd.zfs %f\n", (float)phygrd.zfs);  */

	printf( "tx = loggrd.tx %f\n", (float)tx);
	printf( "ty = loggrd.ty %f\n", (float)ty);
	printf( "tz = loggrd.tz %f\n", (float)tz);
	printf( "gx = phygrd.xfs %f\n", (float)gx);
	printf( "gy = phygrd.yfs %f\n", (float)gy);
	printf( "gz = phygrd.zfs %f\n", (float)gz);
    }
#endif /* SIM */

    for (sl_index=0; sl_index<opslquant; sl_index++) {
	getrotate(saverot,sl_index);

#ifdef SIM
	if (realu_debug == 1){
	/*	saverot[0] = (int)((float)max_pg_iamp*xfull*tx/gx);
	    saverot[1] = 0;
	    saverot[2] = 0;
	    saverot[3] = 0;
	    saverot[4] = (int)((float)max_pg_iamp*yfull*ty/gy);
	    saverot[5] = 0;
	    saverot[6] = 0;
	    saverot[7] = 0;
	    saverot[8] = (int)((float)max_pg_iamp*zfull*tz/gz);
	    */
	    for(i=0; i<9; i++){
		printf( "saverot[%d] = %ld\n", i, saverot[i]);
            	fflush( stdout );
	    }
	}
#endif /* SIM */

	for(i=0; i<9; i++) rsprot_temp[sl_index][i] = saverot[i];

#ifdef SIM
        printf( "pass copy savort to rsprot_temp\n");
        fflush( stdout );
    	if(realu_debug == 1) {
	    for(i=0; i<9; i++){
		printf( "rsprot_temp[%d][%d] = %ld\n", sl_index, i, rsprot_temp[sl_index][i]);
            	fflush( stdout );
	    }
    	}
#endif /* SIM */

     }/* slice loop */

printdbg("Returning from get_prop_rotation", debugstate);
return SUCCESS;
} /* liyuan end get_prop_rotation() */


/* liyuan: PROP set_realu_rotation() */
STATUS
#ifdef __STDC__
set_realu_rotation( void )
#else /* !__STDC__ */
    set_realu_rotation()
#endif /* __STDC__ */
/* calculates the new rotation matrices
      rot = | 0 1 2 |
            | 3 4 5 |
            | 6 7 8 |
*/

/* rotation around x, y, z
counterclockwise, column vector
please remember: use rot * the following related rotation
x
[ 1     0           0
  0     costheta    -sintheta
  0     sintheta    costheta  ]
y
[ costheta      0           sintheta
  0             1           0
  -sintheta     0           costheta]
z
[ costheta     -sintheta    0
  sintheta      costheta    0
  0             0           1]
*/

{
  int sl_index; /* counter */
  /* float theta;  */  /*should directly be input */
  /* float sintheta,costheta;  */

    double alpha_rad = 0.0;
    double beta_rad = 0.0;
    double gamma_rad = 0.0;

  float a[9];  /*place to hold fp rotation matrix */
  float aa[9];  /*place to hold fp rotation matrix temporally*/  /* liyuan */
/*  float aaa[9];  *//*place to hold fp rotation matrix temporally*/  /* liyuan */

  float mya[9];  /*place to hold fp rotation matrix temporally*/  /* liyuan */

  long b[1][9];
  float xfull,yfull,zfull;
  float tx,ty,tz;
  float gx,gy,gz;


  /* calculate rotation about z-axis */
  xfull = (float)phygrd.xfull/(float)max_pg_iamp;
  yfull = (float)phygrd.yfull/(float)max_pg_iamp;
  zfull = (float)phygrd.zfull/(float)max_pg_iamp;
  tx = (float)loggrd.tx;
  ty = (float)loggrd.ty;
  tz = (float)loggrd.tz;
  gx = (float)phygrd.xfs;
  gy = (float)phygrd.yfs;
  gz = (float)phygrd.zfs;

  #ifdef SIM
    if (realu_debug == 1){
   	printf( "in setrealufunction, xfull %f = phygrd.xfull %f / max_pg_iamp%f\n", xfull, (float)phygrd.xfull, (float)max_pg_iamp);
	printf( "yfull %f = phygrd.yfull %f / max_pg_iamp%f\n", yfull, (float)phygrd.yfull, (float)max_pg_iamp);
	printf( "zfull %f = phygrd.zfull %f / max_pg_iamp%f\n", zfull, (float)phygrd.zfull, (float)max_pg_iamp);

	printf( "tx = loggrd.tx %f\n", (float)tx);
	printf( "ty = loggrd.ty %f\n", (float)ty);
	printf( "tz = loggrd.tz %f\n", (float)tz);
	printf( "gx = phygrd.xfs %f\n", (float)gx);
	printf( "gy = phygrd.yfs %f\n", (float)gy);
	printf( "gz = phygrd.zfs %f\n", (float)gz);

    }
#endif /* SIM */


    alpha_rad = xtheta/180.0*PI;
    beta_rad = ytheta/180.0*PI;
    gamma_rad = ztheta/180.0*PI;

    mya[0] = cos(gamma_rad) * cos(beta_rad);
    mya[1] = cos(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 - sin(gamma_rad) * cos(alpha_rad);
    mya[2] = cos(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 + sin(gamma_rad) * sin(alpha_rad);
    mya[3] = sin(gamma_rad) * cos(beta_rad);
    mya[4] = sin(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 + cos(gamma_rad) * cos(alpha_rad);
    mya[5] = sin(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 - cos(gamma_rad) * sin(alpha_rad);
    mya[6] = -sin(beta_rad);
    mya[7] = cos(beta_rad) * sin(alpha_rad);
    mya[8] = cos(beta_rad) * cos(alpha_rad);


  for (sl_index=0;sl_index<opslquant;sl_index++) {

     /* normalize the rotation matrix */
      a[0] = (float)rsprot_temp[sl_index][0]/xfull/tx*gx;
      a[1] = (float)rsprot_temp[sl_index][1]/xfull/ty*gx;
      a[2] = (float)rsprot_temp[sl_index][2]/xfull/tz*gx;

      a[3] = (float)rsprot_temp[sl_index][3]/yfull/tx*gy;
      a[4] = (float)rsprot_temp[sl_index][4]/yfull/ty*gy;
      a[5] = (float)rsprot_temp[sl_index][5]/yfull/tz*gy;

      a[6] = (float)rsprot_temp[sl_index][6]/zfull/tx*gz;
      a[7] = (float)rsprot_temp[sl_index][7]/zfull/ty*gz;
      a[8] = (float)rsprot_temp[sl_index][8]/zfull/tz*gz;

#ifdef SIM
      if(realu_debug == 1) {
	    /*int i; */  /*liyuan no*/
            printf( "a[], %f, %f, %f, %f, %f, %f, %f, %f, %f\n", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8] );
            	fflush( stdout );
      }
#endif /* SIM */

      aa[0] = ( (a[0]*mya[0] + a[1]*mya[3] + a[2] * mya[6]));
      aa[1] = ( (a[0]*mya[1] + a[1]*mya[4] + a[2] * mya[7]));
      aa[2] = ( (a[0]*mya[2] + a[1]*mya[5] + a[2] * mya[8]));

      aa[3] = ( (a[3]*mya[0] + a[4]*mya[3] + a[5] * mya[6]));
      aa[4] = ( (a[3]*mya[1] + a[4]*mya[4] + a[5] * mya[7]));
      aa[5] = ( (a[3]*mya[2] + a[4]*mya[5] + a[5] * mya[8]));

      aa[6] = ( (a[6]*mya[0] + a[7]*mya[3] + a[8] * mya[6]));
      aa[7] = ( (a[6]*mya[1] + a[7]*mya[4] + a[8] * mya[7]));
      aa[8] = ( (a[6]*mya[2] + a[7]*mya[5] + a[8] * mya[8]));


      /* calculate the matrix after rotation once */
/*    aa[0] = ( (a[0]*costheta + a[1]*sintheta));
      aa[1] = ( (-a[0]*sintheta + a[1]*costheta));
      aa[2] = a[2];
      aa[3] = ( (a[3]*costheta + a[4]*sintheta));
      aa[4] = ( (-a[3]*sintheta + a[4]*costheta));
      aa[5] = a[5];
      aa[6] = ( (a[6]*costheta + a[7]*sintheta));
      aa[7] = ( (-a[6]*sintheta + a[7]*costheta));
      aa[8] = a[8];  */

   /*
      aa[0] = (xfull*tx/gx*(a[0]*costheta + a[1]*sintheta));
      aa[1] = (xfull*ty/gy*(-a[0]*sintheta + a[1]*costheta));
      aa[2] = rsprot_temp[sl_index][2];
      aa[3] = (yfull*tx/gx*(a[3]*costheta + a[4]*sintheta));
      aa[4] = (yfull*ty/gy*(-a[3]*sintheta + a[4]*costheta));
      aa[5] = rsprot_temp[sl_index][5];
      aa[6] = (zfull*tx/gx*(a[6]*costheta + a[7]*sintheta));
      aa[7] = (zfull*ty/gy*(-a[6]*sintheta + a[7]*costheta));
      aa[8] = rsprot_temp[sl_index][8]; */

      /* rotation around x axis  */
    /*  sintheta = sin(xtheta/180*pi);
      costheta = cos(xtheta/180*pi);

      aaa[0] = aa[0];
      aaa[1] = (aa[1]*costheta + aa[2]* sintheta);
      aaa[2] = (-aa[1]*sintheta  + aa[2]*costheta);

      aaa[3] = aa[3];
      aaa[4] = (aa[4]*costheta + aa[5]* sintheta);
      aaa[5] = (-aa[4]*sintheta  + aa[5]*costheta);

      aaa[6] = aa[6];
      aaa[7] = (aa[7]*costheta + aa[8]* sintheta);
      aaa[8] = (-aa[7]*sintheta  + aa[8]*costheta);  */


      /* rotation around y axis  */
/*      sintheta = sin(ytheta/180*pi);
      costheta = cos(ytheta/180*pi);  */

      realurot[sl_index][0] = (xfull*tx/gx*aa[0]);
      realurot[sl_index][1] = (xfull*ty/gx*(aa[1]));
      realurot[sl_index][2] = (xfull*tz/gx*aa[2]);

      realurot[sl_index][3] = (yfull*tx/gy*aa[3]);
      realurot[sl_index][4] = (yfull*ty/gy*aa[4]);
      realurot[sl_index][5] = (yfull*tz/gy*aa[5]);

      realurot[sl_index][6] = (zfull*tx/gz*aa[6]);
      realurot[sl_index][7] = (zfull*ty/gz*(aa[7]));
      realurot[sl_index][8] = (zfull*tz/gz*aa[8]);


#ifdef SIM
      if(realu_debug == 1) {
      /*
            printf( "realurot[%d], %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld\n", sl_index, realurot[sl_index][0], realurot[sl_index][1], */
            /* realurot[sl_index][2], realurot[sl_index][3], realurot[sl_index][4], realurot[sl_index][5], realurot[sl_index][6], realurot[sl_index][7], realurot[sl_index][8] );  */

            printf( "realurot[%d], %ld, %ld, %ld, %ld, %ld\n", sl_index, realurot[sl_index][0], realurot[sl_index][1], realurot[sl_index][2], realurot[sl_index][3], realurot[sl_index][4]);
            fflush( stdout );

              printf( "realurot[%d], %ld,  %ld,  %ld, %ld\n", sl_index,  realurot[sl_index][5], realurot[sl_index][6], realurot[sl_index][7],realurot[sl_index][8]);
            fflush( stdout );

    	}
#endif /* SIM */




        /* scale the rot matrix */
    /* test the scalerotmates is work or not */

	    b[0][0] = realurot[sl_index][0];
	    b[0][1] = realurot[sl_index][1];
	    b[0][2] = realurot[sl_index][2];
	    b[0][3] = realurot[sl_index][3];
	    b[0][4] = realurot[sl_index][4];
	    b[0][5] = realurot[sl_index][5];
	    b[0][6] = realurot[sl_index][6];
	    b[0][7] = realurot[sl_index][7];
	    b[0][8] = realurot[sl_index][8];
        if (realu_flag == PSD_ON)
        {
        scalerotmats( b, &loggrd, &phygrd,
                      opslquant, obl_debug );
        }


	 /*   realurot[sl_index][0] = b[0][0];
	    realurot[sl_index][1] = b[0][1];
	    realurot[sl_index][2] = b[0][2];
	    realurot[sl_index][3] = b[0][3];
	    realurot[sl_index][4] = b[0][4];
	    realurot[sl_index][5] = b[0][5];
	    realurot[sl_index][6] = b[0][6];
	    realurot[sl_index][7] = b[0][7];
	    realurot[sl_index][8] = b[0][8];   */



	   setrotate(realurot[sl_index],(short)sl_index);



#ifdef SIM
  /*    if(realu_debug == 1) {
            printf( "after scalerotmats, realurot[%d], %ld, %ld, %ld, %ld, %ld, %ld\n", sl_index, realurot[sl_index][0], realurot[sl_index][1], realurot[sl_index][2], realurot[sl_index][3], realurot[sl_index][4], realurot[sl_index][5]);
            fflush( stdout );
    	}  */
#endif /* SIM */



    }/* slice loop */

 /*liyuan*/

printdbg("Returning from set_realu_rotation", debugstate);
return SUCCESS;
} /* CC: PROP end set_realu_rotation() */


/* liyuan CC: RPOP off-center acquisition */
/* set_prop_offcenter( ) */
#ifdef __STDC__
STATUS set_prop_offcenter(void)
#else /* !__STDC__ */
    STATUS set_prop_offcenter()
#endif /* __STDC__ */
{
    int i;
    /*float pi = 3.14159265358;  */
    float tmpdx, tmpdy, tmpdz;

    float mya[9];  /* liyuan rotation matrix */

    double alpha_rad = 0.0;
    double beta_rad = 0.0;
    double gamma_rad = 0.0;


   /* tmpangle = (float)(prop_theta * (float)pass); */
   /* tmpsin = sin(pi*ztheta/180.0);
    tmpcos = cos(pi*ztheta/180.0);    */

    alpha_rad = xtheta/180.0*PI;
    beta_rad = ytheta/180.0*PI;
    gamma_rad = ztheta/180.0*PI;


       mya[0] = cos(gamma_rad) * cos(beta_rad);
       mya[1] = cos(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 - sin(gamma_rad) * cos(alpha_rad);
       mya[2] = cos(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 + sin(gamma_rad) * sin(alpha_rad);
       mya[3] = sin(gamma_rad) * cos(beta_rad);
       mya[4] = sin(gamma_rad) * sin(beta_rad) * sin(alpha_rad)
                                 + cos(gamma_rad) * cos(alpha_rad);
       mya[5] = sin(gamma_rad) * sin(beta_rad) * cos(alpha_rad)
                                 - cos(gamma_rad) * sin(alpha_rad);
       mya[6] = -sin(beta_rad);
       mya[7] = cos(beta_rad) * sin(alpha_rad);
       mya[8] = cos(beta_rad) * cos(alpha_rad);



    /* CC: RcPhOffset, calculating the new center offset according the rot-angle*/
    for(i=0; i<opslquant; i++) {



        tmpdx = orig_rsp_info[i].rsprloc;
        tmpdy = orig_rsp_info[i].rspphasoff;
        tmpdz = orig_rsp_info[i].rsptloc;

    #ifdef SIM
        if(realu_debug == 1) {

                printf( "orig_rsp_info[%d], rsprloc(x) %lf, rspphaseoff(y)%lf, rsptloc(z) %lf\n", i, orig_rsp_info[i].rsprloc, orig_rsp_info[i].rspphasoff,orig_rsp_info[i].rsptloc);
                fflush( stdout );

    	}
    #endif /* SIM */



        /* liyuan do the FOV center translation according original scan set coordinate */
        tmpdx = tmpdx + transx;
        tmpdy = tmpdy + transy;
        tmpdz = tmpdz + transz;


    #ifdef SIM
        if(realu_debug == 1) {

                printf( "orig_rsp_info[%d] after translation, rsprloc(x) %lf, rspphaseoff(y)%lf, rsptloc(z) %lf\n", i, tmpdx, tmpdy,tmpdz);
                fflush( stdout );

    	}
    #endif /* SIM */

        realu_rsp_info[i].rsprloc = mya[0]*tmpdx + mya[3]*tmpdy +mya[6]*tmpdz;
        realu_rsp_info[i].rspphasoff = mya[1]*tmpdx + mya[4]*tmpdy +mya[7]*tmpdz;
        realu_rsp_info[i].rsptloc = mya[2]*tmpdx + mya[5]*tmpdy +mya[8]*tmpdz;



/*
        realu_rsp_info[i].rsprloc = tmpcos*tmpdx + tmpsin*tmpdy;
        realu_rsp_info[i].rspphasoff = -tmpsin*tmpdx + tmpcos*tmpdy;
        realu_rsp_info[i].rsptloc = orig_rsp_info[i].rsptloc;           */


	/* calculate y-phase offset */
	/* set_yres_phase -call-> calc_yres_phase --> uses phase_off */
        if ( realu_rsp_info[i].rspphasoff >=0 ) {
            phase_off[i].ysign = -1;
        } else {
            phase_off[i].ysign = 1;
        }

        /* liyuan */
        /* phase offset increment */
        /* RTIA changes exist(opfov) to psd_fov */ /* ASSET */
        if (FAILURE == calcrecphase(&yoffs1, realu_rsp_info[i].rspphasoff, (float)psd_fov, opphasefov, nop, asset_factor))
        {
            return FAILURE;
        }

        /* phase offset increment */
        /* RTIA changes exist(opfov) to psd_fov */ /* ASSET */
       /* yoffs1 = 0.5 + fabs( FS_2PI * realu_rsp_info[i].rspphasoff /
                             (float) (psd_fov * opphasefov * nop * asset_factor) );  */ /*liyuan buyao*/

        /* offset in range */
        phase_off[i].yoffs = (yoffs1 + FS_2PI + FS_PI) %
            FS_2PI - FS_PI;
	/* calculate y-phase offset */



	#ifdef SIM
        if(realu_debug == 1) {

                    printf( "realu_rsp_info[%d], rsprloc(x) %lf, rspphaseoff(y)%lf, rsptloc(z) %lf\n", i, realu_rsp_info[i].rsprloc, realu_rsp_info[i].rspphasoff,realu_rsp_info[i].rsptloc);
                fflush( stdout );

    	}
#endif /* SIM */




    }
    /* CC: calculate the receiver freq for new roation */
    setupslices( receive_freq1, realu_rsp_info, opslquant,
                 0.0, echo1bw, (float)(rhfreqscale*psd_fov), (INT)TYPREC );

    return SUCCESS;

}
/* CC: END of set_prop_offcenter( ) */




/*
 *  psdinit
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
psdinit( void )
{
    INT i;           /* counter */

#ifdef PSD_IPG_DEBUG
    psdisicnt = 0;
#endif /* PSD_IPG_DEBUG */

    /* Set ISI interrupt callback function - 03/Feb/1998 - GFN */
    if ( PSD_OFF == opfcine ) {
        isivector( psdisivector, psdisiupdate, (short)FALSE ); 
    }

    /* Initialize SAT flag for CMON - LX2 */
    sat_flag = 0;

    /* Initialize these status for isi routine */
    first_scan     = YES;
    first_prepscan = YES;
    new_view       = YES;

    /* required for view copy/sharing */
    rspqueueinit( (short)rspqueue_size );

    /* Reset global error handling variable */
    strcpy( psdexitarg.text_arg, "psdinit" );
    view = slice = excitation = 0;

    /* set up phase offset arrays */
    total_images = opslquant;

    for ( i=0 ; i <= total_images - 1 ; i++ ) 
    {
        if ( rsp_info[i].rspphasoff >=0 ) {
            phase_off[i].ysign = -1;
        } else {
            phase_off[i].ysign = 1;
        }
        /* phase offset increment */
        /* RTIA changes exist(opfov) to psd_fov */ /* ASSET */
        if (FAILURE == calcrecphase(&yoffs1, rsp_info[i].rspphasoff, (float)psd_fov, opphasefov, nop, asset_factor))
        {
            return FAILURE;
        }

        /* offset in range */
        phase_off[i].yoffs = (yoffs1 + FS_2PI + FS_PI) %
            FS_2PI - FS_PI;
    }

    sp_sat_index = 0;

    /* Set right interrupt routine for CMON - LX2 */
    /* RTIA change */
    if (PSD_ON == cmon_flag)
    {
        ssivector( ssiupdates, (short)FALSE );
    } else if ( ((PSD_ON == opsat) &&
                 ((opsatx) || (opsaty) || (opsatz) || (opexsatmask))) ||
                (RTIA98 == (feature_flag & RTIA98)))
    {
        ssivector( ssisat, (short)FALSE );
    }
    /* End RTIA */

    /* Set rfconfig */
    setrfconfig( (short)rfconf );
    
    /* set locktime in unit of second */
    rsplock = (short)( locktime / 1.0s );

    /* set initial value for phases of rf1 and rcv */
    rf1phase = 0.0;
    rcvphase = 0.0;
    rcvphase_int = 0;

    /* set dither control */
    setditherrsp( dither_on, dither_value );

    /* reset all the attenuator locks */
    if (L_SCAN == rspent)
    {
        attenlockon(&attenuator_key);
        /* Enable view copy packet */
        setwamp(SSPOC + DCOPY, &copydab, 1);
        setwamp(SSPDS + DABDC, &copydab, 0);
    } else {
        attenlockoff(&attenuator_key);
        /* Disable view copy packet */
        setwamp(SSPOC, &copydab, 1);
        setwamp(SSPDS, &copydab, 0);
    }
  
    /* Reset all the scope triggers */
    if (1 == cs_sat)
    {
        ChemSat_Reset_Scope(feature_flag);
    }
    scopeon( &seqcore );

    /* Reset all the synchronizations  - no need to use one in pass */
    if (1 == cs_sat)
    {
        ChemSat_Sync(feature_flag);
    }
    syncon( &seqcore );
    syncoff( &seqpass );

    /* FUS */
    /*fgre_track will set the trigger in a diffrent place*/
    if(ext_trig && (L_SCAN == rspent))
    {
        /* Set trigger array - first slice to external trigger */
        rsptrigger[0] = TRIG_AUX;
    } else {
        rsptrigger[0] = gating;
    }

    /*
     * In case CINE aborts prematurely, assure that echo1 has the
     * right packet. - 13/Feb/1998 - GFN
     */
    /* fhe fcine-et CHECK THIS */
    if ( (feature_flag & FASTCINE) && !(feature_flag & ECHOTRAIN) ) 
    {
        if(PSD_ON == cine_kt_flag)
        {
            getwave( &echo1dab, &echo1 );
            getwave( &echo1rba_index, echo1rba );
        }
        else
        {
            setwave( echo1dab, &echo1, 0 );
        }
    }

    /* Assure trigger arrays are reset to standard ones */
    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    settriggerarray( (short)opslquant, rsptrigger );

    /* Inform the Tgt of the rotation matrix array to be used.
       For scan and ps2, the sat pulses are played out so the sat
       rotation matrix needs to be used.  Otherwise, the original
       slice rotation matrix is used. */
    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    setrotatearray( (short)opslquant, rsprot[0] );

    /* liyuan get the info here*/
    if ((realu_flag == PSD_ON) && (rspent == L_SCAN))  get_prop_rotation();
    /*liyaun end */

    seq_count = 0;   /* clear the SPGR sequence counter per 
                        pass (actually per slice 1pass=1slice)
                        moved here from scancore MRIge61251*/
    exphase = 0;

    /*****************************
     *  Feature initializations  *
     *****************************/

    /* Begin RTIA */
    /* Don't modify the rotation matrices here for Realtime. 
       This will be done only if SPSat is selected in realtime. */
    if ( !(feature_flag & RTIA98) ) 
    { 
        mpl_satrotate( feature_flag ); 
    }
    /* End RTIA */

    fastcard_psdinit( rf1_flip, ia_rf1, flip_rf1, act_tr, 
                      feature_flag, copyit );
    fastcardPC_psdinit( feature_flag );

    /* Tagging - 05/Jun/97 - GFN */
    tagging_psdinit( feature_flag );

    /* Fast CINE - 02/Jan/1998 - GFN */
    /* Do not do it for Echotrain yet.  ET needs to initialize the hyperdab
       packet instead of echo1 which will be done inside et_psdinit(). */
    if( !(feature_flag & ECHOTRAIN) ) {
        fcine_psdinit( &echo1, feature_flag );
    }

    /* FIESTA2D */
    fiesta_psdinit( feature_flag );

    fmpvas_satrotate( feature_flag );
    fmpvas_psdinit( rf1_flip, ia_rf1, flip_rf1, feature_flag );

    /* JAP ET */
    if(FAILURE == et_psdinit(ia_rf1, opslquant, etl, feature_flag))
    {
        return FAILURE;
    }

    pass = 0;

    if ( rmode ) 
    {
        rspdda = resdda;
        rspbas = resbas;
        rspvus = resvus;
        rspnex = resnex;
        rspchp = reschp;
        rspesl = resesl;
        rspasl = resasl;
        rspech = resech;
        rspslq = resslq;
    }
     
    /* Enable readout, phase encoding, and rho */
    setieos( (INT)EOS_PLAY, &x_td0, 0 );
    setieos( (INT)EOS_PLAY, &y_td0, 0 );
    setieos( (INT)EOS_PLAY, &rho_td0, 0 );
  
    /* For non center frequency entrypoints in cardiac gating, 
       set cardiac delay to grad_update_time. */
    setperiod( (INT)GRAD_UPDATE_TIME, &x_td0, 0 );
    setperiod( (INT)GRAD_UPDATE_TIME, &y_td0, 0 );
    setperiod( (INT)GRAD_UPDATE_TIME, &z_td0, 0 );
    setperiod( (INT)GRAD_UPDATE_TIME, &rho_td0, 0 );
    setperiod( (INT)GRAD_UPDATE_TIME, &theta_td0, 0 );
    setperiod( (INT)GRAD_UPDATE_TIME, &ssp_td0, 0 );
    
    /* Initialize phase amplitudes */
    if ( rspgy1 == 0 ) 
    {
        amp_gy1 = rsp_preview;   /* Normally rsp_preview = 0 */
    } else {
        amp_gy1 = -viewtable[rspgy1];
    }

    if (nope >= 1)
        amp_gy1 = 0;

    setiamp( amp_gy1, &gy1, 0L );
    if (PSD_ON == rewinder_flag) 
    {
        setiamp( amp_gy1, &gy1r, 0L );
    }
    
    exphase    = 0;          /* clear SPGR exciter phase */
    tempamp    = ia_rf1;     /* initialize rf1 amplitude */
    rsptimessi = time_ssi;
    setiamp( tempamp, &rf1, scanrf1_inst );
    
    /* initializations for ECG triggering */
    ipgdabstate   = DABOFF;
    look_for_trig = FALSE;   /* no need to monitor ECG */ 
    dabOnOffFlag  = PSD_OFF;
    
    /* turn on control bit for tgt to service the isi interrupt. */
    getctrl( &psdctrl, &isi6, 0 );
    /* psd bits based on binary representation of the isi vector
       6 = 110;  7 = 111  */
    psdctrl |= ( PSD_ISI1_BIT | PSD_ISI2_BIT );
    setctrl( psdctrl, &isi6, 0 );

    /* Baseviews and disdaqs */
    baseviews = -rspbas + 1;
    disdaqs   = -rspdda;
  
    /* DAB initialization */
    dabop   = 0;   /* Store data */
    dabview = 0;
    dabecho = 0;   /* first dab packet is for echo 0 */
  
    /*
     * CREATIV - Initialize cont_proceed to 0 to pause,
     * if pause if enabled, before 1st pass.
     */
    if( (PSD_ON == oprealtime) && (PSD_ON == opirmode) )  {
        cont_proceed = 0;
    }
  
    CsSatMod( cs_satindex, cs_sat, cs_tune );
    SpSatInitRsp( 1, sp_satcard_loc, 0, rspent );
    
    /* Set ssi time.  This is time from eos to start of sequence interrupt
       in internal triggering.  The minimum time is 50us plus 2us*(number of
       waveform and instruction words modified in the update queue) */

    setssitime( (INT)rsptimessi / HW_GRAD_UPDATE_TIME );

    /* Execute init pass for Exorcist - LX2 */
    if (PSD_ON == cmon_flag)
    {
        exorcist_pass_init();
    }
 
    /* Respiratory Gating - 08/Oct/1997 - GFN */
    if ( FAILURE == respgate_psdinit( feature_flag ) ) 
    {
        return FAILURE;
    }

    /* Begin RTIA - RJF */
    if (FAILURE == rtia98_psdinit(feature_flag) ) 
    { 
        return FAILURE;
    } 

    /* End RTIA */

    /*MRgFUS tracking*/
    if(track_flag)
    {
        cont_trip = 0;
        cont_trip_phasedda = fus_scan_dda;
        phaseno_fus = 0;
        prev_pass_num = 0;
        if( FAILURE == track_psdinit())
        {
            return FAILURE;
        }
    }

    /* Begin Echotrain realtime - RJF */
    if ( FAILURE == echotrain_realtime_psdinit (feature_flag) ) 
    { 
        return FAILURE;
    }

    /* FIESTA RT */
    if( FAILURE == fiesta_realtime_psdinit( feature_flag ) ) 
    {
        return FAILURE;
    }

    if ( debug_scan ) /* This is psd_dump_rsp_info() */
    {
       int i;
       int num_slice;

       if ( opimode==PSD_3D && opvquant > 1 ) {
           num_slice = opvquant;
       } else {
           num_slice = opslquant;
       }

       printf("\nPSD-> Dump of rsp info\t\t\tRotation Matrix\n");

       for(i=0;i<num_slice;i++) {
           printf("PSD->\nPSD->Index %d\t\t\t\t%+6ld, %+6ld, %+6ld\n",i,
                  rsprot[i][0],rsprot[i][1],rsprot[i][2]);
           printf("PSD->rsp_info[%d].rsptloc = % -10.2f\t%+6ld, %+6ld, %+6ld\n",
                  i,rsp_info[i].rsptloc,
                  rsprot[i][3],rsprot[i][4],rsprot[i][5]);
           printf("PSD->rsp_info[%d].rsprloc = % -10.2f\t%+6ld, %+6ld, %+6ld\n",
                  i,rsp_info[i].rsprloc,
                  rsprot[i][6],rsprot[i][7],rsprot[i][8]);
           printf("PSD->rsp_info[%d].rspphasoff = % -10.2f\n",
                  i,rsp_info[i].rspphasoff);
       }
       fflush(stdout);
    }

    return SUCCESS;
}   /* end psdinit() */


/*
 *  mps2
 *
 *  Type: Function
 *
 *  Description:
 *    Sequence Manual Prescan.
 */
STATUS
mps2( void )
{
    printdbg("Greetings from MPS2", debugstate);

    rspent    = L_MPS2;
    /* MRIge90793 - 2D FIESTA Fat SAT uses different disdacqs */
    if( (feature_flag & FIESTA) && (feature_flag & SPECIR) ) {
        rspdda = fiesta2d_sat_getdda( dda );
    } else {
        rspdda = ps2_dda;
    }
    rspbas    = 0;
    rspvus    = 30000;
    rspgy1    = 0;
    rspnex    = ps2_nex;
    rspesl    = -1;
    rspasl    = pre_slice;
    rspslq    = slquant1;  /* rspslq=opslquant for interleave acq, 
                              rspslq=opfphases for sequential acq. */
    if (PSD_3PLANE == opplane)
    {
        rspslq = preslquant;
    } 
    rspsct    = 0;
    rsplock   = 10;
    rspisi    = isi_flag;
    rspscptrg = scptrg;

    cm_pass = 0; 
    pass = 0;
    rsp_cmndir = 1;
        
    if (1 == cs_sat)
    {
        cs_tune = 1;
    }
 
    psdinit();
    strcpy( psdexitarg.text_arg, "mps2" );

    /* Begin RTIA comment */
    /* For RTIA the sequence deadtime is set in rtia_set_seq_deadtime 
       in pulsegen. This should ideally have been done in rtiacore - 
       but we don't want to redo this every pass. But if it's RTIA, don't 
       set the deadtime to scan_deadtime here ! */
    /* End RTIA comment */
    if ( !(feature_flag & RTIA98) ) { 
        /* change deadtime to SCAN  TR */
        setperiod( scan_deadtime, &seqcore, 0 );
    } 
 
    pass = pre_pass;
     
    first_scan     = YES;
    first_prepscan = YES;

    /* Begin RTIA */
    /* ps2 sequence is same as the scan core sequence. */
    /* For RTIA, the sequence downloaded is for 
       FOV = opfov * RTIA_ZOOM_FACTOR. Update the sequence to 
       prescan at the prescribed FOV here. */
    /* RTIAUpdateFOV scales the required pulses with the 
       scale factor passed. */
    if ( feature_flag & RTIA98 ) { 
        float fov_scale_factor;

        fov_scale_factor = opfov / psd_fov;
        slthick_scale_factor = opslthick / psd_slthick; /* RTCA */
        /* The first argument should be 1 if we decide to
           use flowcomp sequence to prescan */
        rtia98_update_fov ( 0,  fov_scale_factor );
        rtca_update_slthick ( 0, slthick_scale_factor );

        /* MRIge81613 */
        /* Now all RSPs hold new valid data.
           Create the Rotmatrix and RSPinfo  */
        setup_geometry_arrays( opfov );

    } else if( (feature_flag & ECHOTRAIN) && oprealtime ) {
        /* YMSmr07697  09/09/2005 YI */
        fill_rsp_info_rsprot();
        slthick_scale_factor = opslthick / psd_slthick;
        rtca_update_slthick_et( 0, slthick_scale_factor );
        flip_scale_factor = opflip / (float)psd_flip;
        rtca_update_flip_et( flip_scale_factor );
        setupslices( rf1_freq, rsp_info, 1, a_gzrf1 / slthick_scale_factor,
                     1.0, rhfreqscale * rspfov, (INT)TYPTRANSMIT );
        et_setup_rf();
        setrotatearray( (SHORT)(1), rsprot[0] );
    }
    /* End RTIA */

    if ( (PSD_3PLANE == opplane) &&
         ( (PSD_3PLANELOC == oppseq) || 
           !(feature_flag & FIESTA) ||
           (feature_flag & IRPREP) ) )
    {
        ps2mplcore( rspvus, rspnex );
    } 
    else if ((PSD_3PLANE == opplane) && (feature_flag & FIESTA))
    {
        ps2fiestacore();
    }
    else 
    {
        ps2core_select( scan_deadtime, rspdda, rspvus, rspnex, feature_flag );
    }

    /* Deallocate the global SPGR phase array allocated in psdinit */
    RTIAExit(feature_flag);

    printdbg( "Normal End of MPS2", debugstate );
    rspexit();

    return SUCCESS;
}   /* end mps2() */


/*
 *  aps2
 *
 *  Type: Function
 *
 *  Description:
 *    Sequence Auto Prescan.
 */
STATUS
aps2( void )
{
    printdbg( "Greetings from APS2", debugstate );

    rspent    = L_APS2;
    /* MRIge90793 - 2D FIESTA Fat SAT uses different disdacqs */
    if( (feature_flag & FIESTA) && (feature_flag & SPECIR) ) {
        rspdda = fiesta2d_sat_getdda( dda );
    } else {
        rspdda = ps2_dda;
    }
    rspbas    = 0;
    rspvus    = 1024;
    rspgy1    = 0;
    rspnex    = ps2_nex;
    rspslq    = slquant1;  /* rspslq=opslquant for interleave acq, 
                              rspslq=opfphases for sequential acq. */
    if (PSD_3PLANE == opplane)
    {
        rspslq = preslquant;
    }
    rspsct    = -1;
    rspesl    = -1;
    rspasl    = -1;
    rsplock   = 5;
    rspisi    = isi_flag;
    rspscptrg = scptrg;

    cm_pass = 0;
    pass = 0;
    rsp_cmndir = 1;

    if (1 == cs_sat)
    {
        cs_tune = 1;
    }

    psdinit();
    strcpy( psdexitarg.text_arg, "aps2" );

    /* Begin RTIA change */
    /* See comment in mps2 section */
    if ( !(feature_flag & RTIA98) ) { 
        setperiod( scan_deadtime, &seqcore, 0 );
    } 
    /* End RTIA */

    pass = pre_pass;
  
    first_scan     = YES;
    first_prepscan = YES;

    /* Begin RTIA */
    /* ps2 sequence is same as the scan core sequence. */
    /* For RTIA, the sequence downloaded is for 
       FOV = opfov * RTIA_ZOOM_FACTOR. Update the sequence to 
       prescan at the prescribed FOV here. */
    /* RTIAUpdateFOV scales the required pulses with the 
       scale factor passed. */
    if ( feature_flag & RTIA98 ) {
        float fov_scale_factor;

        fov_scale_factor = opfov / psd_fov;
        slthick_scale_factor = opslthick / psd_slthick; /* RTCA */
        /* The first argument should be 1 if we decide to
           use flowcomp sequence to prescan */
        rtia98_update_fov ( 0,  fov_scale_factor );
        rtca_update_slthick ( 0, slthick_scale_factor );

        /* MRIge81613 */
        /* Now all RSPs hold new valid data.
           Create the Rotmatrix and RSPinfo  */
        setup_geometry_arrays( opfov );

    } else if( (feature_flag & ECHOTRAIN) && oprealtime ) {
        /* YMSmr07697  09/09/2005 YI */
        fill_rsp_info_rsprot();
        slthick_scale_factor = opslthick / psd_slthick;
        rtca_update_slthick_et( 0, slthick_scale_factor );
        flip_scale_factor = opflip / (float)psd_flip;
        rtca_update_flip_et( flip_scale_factor );
        setupslices( rf1_freq, rsp_info, 1, a_gzrf1 / slthick_scale_factor,
                     1.0, rhfreqscale * rspfov, (INT)TYPTRANSMIT );
        et_setup_rf();
        setrotatearray( (SHORT)(1), rsprot[0] );
    }
    /* End RTIA */

    if ((PSD_3PLANE == opplane) &&
        ((PSD_3PLANELOC == oppseq) ||
          !(feature_flag & FIESTA) ||
          (feature_flag & IRPREP)))
    {
        ps2mplcore( rspvus, rspnex );
    }
    else if ((PSD_3PLANE == opplane) && (feature_flag & FIESTA)) 
    {
        ps2fiestacore();
    }
    else 
    {
        ps2core_select( scan_deadtime, rspdda, rspvus, rspnex, feature_flag );
    }

    /* Deallocate the global array for RTIA */
    RTIAExit(feature_flag);

    printdbg( "Normal End of APS2", debugstate );
    rspexit();

    return SUCCESS;
}   /* end aps2() */


STATUS 
ref( void )
{
    INT pause;

    if( feature_flag & ECHOTRAIN ) 
    {
        int refacqs;

        rspent = L_REF;

        refacqs = 1;
        psdinit();

        for (pass = 0; pass < refacqs; pass++) 
        {
            /*
              if (mpet_on==PSD_ON)
              mpet_ref();
              else
            */
            etmpl_ref();

            boffset( off_seqpass );

            if (pass == (refacqs - 1)) {  /* Last pass */
                /* Set DAB pass packet to end of scan */
                setwamp(SSPD + DABPASS + DABSCAN, &pass_pulse, 2);
                printdbg("End of Scan and Pass", debugstate);
            } else {
                /* Set DAB pass packet to end of pass */
                setwamp(SSPD + DABPASS, &pass_pulse, 2);
                printdbg("End of Pass", debugstate);
            }

            if (pass == (refacqs -1))
                pause = MAY_PAUSE;
            else {  /* if not last pass */
                pause = AUTO_PAUSE;	/* or if required */
            }

            startseq((SHORT)0,(SHORT)pause);
        }

        rspexit();
    }

    return SUCCESS;
}   /* end ref() */


/*
 *  fgre_viewrecorder
 *  
 *  Type: Function
 *  
 *  Description:
 *  
 */
static STATUS
fgre_viewrecorder( int record_size )
{
    int i;
    int status = SUCCESS;
#ifdef SIM_IO
    char record_file[] = "./viewtab.log";
#else
    char record_file[] = "/usr/g/service/log/viewtab.log";
#endif
    FILE *opf; /*output file*/

    opf = fopen( record_file, "w" );
    status = (NULL != opf);
    if( status ) {
        for( i = 0; i < record_size; ++i ) {
            fprintf( opf, "%d\n", viewtab[i] );
            if( viewtab[i] <= 0 ) {
                fprintf( stderr, "Zero or negative value found"
                         " at entry %d\n", i + 1 );
                fflush( stderr );
            }
        }
        fclose( opf );
    } else {
        fprintf( stderr, "Could not open %s\n", record_file );
        fflush( stderr );
    }

    return status;
}


/**
 * Entry point that allows the PSD to cleanup any unhandled items before
 * stopping acquisition.  MCT task performs a symbol lookup on this
 * function and calls it once the scan stops due an abort, crash, etc.
 *
 * @return the status after executing the cleanup:
 *         <ol>
 *         <li><code>EM_PSD_NO_ERROR</code> if the cleanup is successful</li>
 *         <li><code>EM_PSD_RTP_CLEANUP_FAILED</code> if there is an error
 *         ending the RTP application</li>
 *         </ol>
 */
n32
psdcleanup(n32 abort)
{
    n32 rv = EM_PSD_NO_ERROR;
    int rtpendstatus = 0;
    abort = 1; /* Dummy to avoid compilation failure for unused variables - Used in Monitor.e */
    if(isrtplaunched)
    {
        rtpendstatus = RtpEnd();
   
        if(SUCCESS == rtpendstatus)
        {
            isrtplaunched = 0;
            rv = EM_PSD_NO_ERROR;
        }
        else
        {
            rv = EM_PSD_RTP_CLEANUP_FAILED;
        }
    }
    return rv;
}


/*
 *  scan
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
scan( void )
{
    INT viewtab_size;   /* view table size - 14/Jan/1998 - GFN */


    normscan();

    /* debug step */
    if( viewtab_on ) {
        /* For non-realtime dumps to protect time constraints */
        viewtab_size = (INT)ceil( (double)rspvus / (double)opvps ) * opvps;
        fgre_viewrecorder( viewtab_size );
    }

    rspexit();

    return SUCCESS;
}   /* end scan() */


/*
 *  normscan
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
normscan( void )
{
    INT pause;   /* pause attribute storage loc */
    INT viewtab_size;   /* view table size - 14/Jan/1998 - GFN */
    INT pass_shot; /*ZL scic+ two passes*/

    extern int cont_trip_mode;
    extern int cont_trip_phasecount;
    extern int track_runtime_debug;

    /* Begin RTIA */
    unsigned long *input_id_values_buffer;
    unsigned long *recon_id_values_buffer;
    INT issue_stop_scan ;
    INT dis;  /* RJF-GB Project 9484;AMR for MRIge53904 */
    /* End RTIA */

%ifdef DEBUG
    printdbg( "Greetings from SCAN", debugstate );
%endif /* DEBUG */

#ifdef QQQ
    print_offsets( off_seqcore, "off_seqcore", "normscan" );
#endif /* QQQ */


    /* liyuan */
#ifdef SIM
    if (realu_debug == 1){
	fprintf(stdout, "Start normscan\n");
	fflush(stdout);
    }
#endif /* SIM */
    /* liyuan end */


    /* Begin RTIA change - RJF */
    offset_to_seqcore();
    /* End RTIA change */

    rspent    = L_SCAN;
    rspdda    = dda;
    rspbas    = rhbline;
    rspvus    = rhnframes + temp_rhhnover; /* HCSDM00397211 */
    rspgy1    = 1;
    rspnex    = nex;
    rspslq    = slquant1;  /* For MPH scans: rspslq=opslquant for
                              interleave acq, rspslq=opfphases for
                              sequential acq. */
    rspasl    = -1;
    rspesl    = -1;
    rspisi    = isi_flag;
    rspscptrg = scptrg;
    rspsct    = 0;        /* only open scope trigger for the first
                             slice in a pass */

    if (touch_flag)
    {
        rsp_cmndir = touch_ndir;
    }
    else
    {
        rsp_cmndir = 0;
    }

    if (1 == cs_sat)
    {
        cs_tune = 1;
    }

    /* Begin RTIA */
    /* See comment in mps2 section */
    /* change deadtime to SCAN TR */
    if( !(feature_flag & RTIA98) ) {
        setperiod( scan_deadtime, &seqcore, 0 );
    } 
    /* End RTIA */

    psdinit();

    if( !((PSD_ON == perfusion_flag) || (feature_flag & RTIA98) || (feature_flag & FASTCINE) || (feature_flag & FASTCARD)
          || (feature_flag & TAGGING) || (feature_flag & FASTCARD_PC) || (feature_flag & FASTCARD_MP) || (feature_flag & ECHOTRAIN)
          || (feature_flag & MPH) || (feature_flag & TOUCH) || (PSD_3PLANE == opplane) || (PSD_ON == opirmode) || (PSD_ON == track_flag)) )
    {
        NoiseCalrcvn();
    }

    /* only start RTP when in scan mode */
    if(PSD_ON == track_flag )
    {
        TrackRtpInit();
    }

    /* Start the ETA coprocess on TPS */
#ifdef PSD_HW
    if (feature_flag & ECHOTRAIN) {
        EtaCoprocess(PSD_ON);
    }
#endif /* PSD_HW */

    strcpy( psdexitarg.text_arg, "scan" );
    if (PSD_ON == opcgate)
    {
        /* Changed the check to PSD_HW - 06/Aug/1997 - GFN */
#ifdef PSD_HW
        /* Don't check ecg rate in simulator mode. */
        if(1==test_getecg)
        {
            getecgrate( &rsp_hrate );
            if(0==rsp_hrate)
            {
                psdexit( EM_PSD_NO_HRATE, 0, "", "psd scan entry point", 0 );
            }
        }
#endif /* PSD_HW */
    }

    first_scan     = YES;
    first_prepscan = YES;

    phase_ordering( viewtab, phorder, rspvus, viewoffs, opvps,
                    offset_inter, feature_flag, isInh2DTOF, debug_viewtab ); 
    /* MRIge90145: generate centric-ordered view table for RTIA IR */
    phase_ordering( viewtab_IR, phorder_IR, rspvus, viewoffs, opvps,
                    offset_inter, feature_flag, isInh2DTOF,  debug_viewtab );

    /* Calculate view table size - 14/Jan/1998 - GFN */
    viewtab_size = (INT)ceil( (double)rspvus / (double)opvps ) * opvps;

    /* Show contents of the view table in debug mode */
    if( debug_viewtab ) {
        printf( "\n" );
        for( view = 0; view < viewtab_size; ++view ) {
            printf( " %3d ", viewtab[view] );
            if( ((view + 1) % 10) == 0 ) {
                printf( "\n" );
            }
        }
        printf( "\n" );
        fflush(stdout);
    }

    /* Fast CINE - 13/Feb/1998 - GFN */
    /* Pass viewtable to Recon through Tgt Shared Memory Buffer */
    if( feature_flag & FASTCINE ) {
        if( !(feature_flag & ECHOTRAIN) ) {
            if(PSD_OFF == cine_kt_flag)
            {
                if( FAILURE == fcine_passviewtab( viewtab, viewtab_size ) ) {
                    return FAILURE;
                }
            }
        } else {
            /* Echotrain uses it's own fcine routine */
            if( FAILURE == et_fcine_passviewtab( viewtab_size ) ) {
                return FAILURE;
            }
        }
    }

    /* Initialize copydab packet to off 
       if the modules allow view sharing, then
       the copydab packet will be enabled from the modules. */

    /* Turn of view sharing for RTIA FlowComp core too. */
    fgre_copyframe( &copydab, frame_control, 0, 0, 0, 0, 0, 0, 0, 0, 
                    copyframes, (TYPDAB_PACKETS)DABOFF );

    /* Set right interrupt routine for CMON - LX2 */
    if ((PSD_ON == cine_flag) || (PSD_ON == cmon_flag)) 
    {
        ssivector( ssiupdates, (short)FALSE );
    }
    else if ( ((PSD_ON == opsat) &&
                 ((opsatx)||(opsaty)||(opsatz)||(opexsatmask)) ) || 
                (feature_flag & RTIA98) ) 
    {
%ifdef DEBUG
        printdbg( "setting ssivector to ssisat..\n", rtia_ipg_debug );
%endif /* DEBUG */
        ssivector( ssisat, (short)FALSE );
    }
 
    /* Allocate Space for RTIA RSP buffers */
    if( oprealtime ) 
    {
%ifdef DEBUG
        printdbg( "Allocating id value buffers..\n", rtia_ipg_debug );
%endif /* DEBUG */
        input_id_values_buffer = (unsigned long *)AllocNode( sizeof(unsigned long) *
                                                             (CS_MAX_NUM_RSPS * 2 + 1) );
        recon_id_values_buffer = (unsigned long *)AllocNode( sizeof(unsigned long) *
                                                             (CS_MAX_NUM_RSPS * 2 + 1) );
    }
 
    /* turning pass packet off for fast_pass */
    if (PSD_ON == fast_pass) 
    {
        setwamp(SSPD, &pass_pulse, 2);  
    }

    cont_rtia_stop = 0;
    /* Allow first time entry */
    while (0 == cont_rtia_stop)
    {
#ifdef PSD_HW
        cont_rtia_stop = (INT)BoreOverTemp( btemp_monitor, btemp_debug );
#endif /* PSD_HW */
        if ( (oprealtime != PSD_ON)  ) {
            /* One time loop for non realtime mode */
            cont_rtia_stop = 1;
        }

        if( (PSD_ON == oprealtime) && (PSD_ON == opirmode) && (PSD_SSFP != oppseq) ) {
            SynchronizedPause();
        }

#ifdef PSD_HW
        if (PSD_OFF == oprealtime)
        {
            /* Perform ETA reference scans.
               For realtime, this will be done 
               after the realtime update. */        
            EtaMakeDtTable(feature_flag); 
        }
#endif /* PSD_HW */
        
        /* MRIhc15304: Check the rxCoilType, txCoilType and hubindex of
         * the volRecCoil and send as inputs to CoilSwitchSetCoil
         * function. This function sets the RF HUB index as the data for
         * the ssp command and also send setrcvportimm command if
         * needed. 
         * We do this coil Switch ONLY if volRecCoil is different than
         * the logical coil - For Pure Cal. 
         * In Case of Swift Cal, we switch to the second logical coil.
         */

        /* getperiod and setperiod get and set the period of an instruction and
           not the sequence. Introducing getperiod here to make sure setperiod
           is setting the right value to the last instruction of seqpass  - MRIhc20775 */

        getperiod((long*)&pass_seqtime, &seqpass, 0);

        for( pass_shot = 0; pass_shot < pass_reps; ++pass_shot ) 
        {
            /* Switch coils for the second pass shot */
            if( (PSD_ON == run_setcoil ) && (PSD_ON == pure_ref) 
                && (pass_shot == (pass_reps - 1)))
            {
                if(coilInfo_tgt[0].hubIndex != volRecCoilInfo_tgt[0].hubIndex)
                {
                    if(FAILURE == CoilSwitchSetCoil(volRecCoilInfo_tgt[0], run_setrcvportimm))
                    {
                        return FAILURE;
                    }
                    
                    offset_to_seqcore();
                }
            }

            /* Swift cal: switch coils for the second shot. PV coil is not pure
             * compatible */
            if( (PSD_ON == swift_cal) && (pass_shot == (pass_reps - 1)) ) {
                printdbg("swift_cal\n", swift_cal_debug);
                
                if(FAILURE == CoilSwitchSetCoil(coilInfo_tgt[1], 0))
                {
                    return FAILURE;
                }

                offset_to_seqcore();
            }

            for ( pass=0 ; pass<acqs ; pass++ ) 
            {
            
            /* liyuan realu */
            #ifdef SIM
                if (realu_debug == 1){
                fprintf(stdout, "In normscan(), pass = %d < acqs = %d, realu_flag = %d, (rspent == L_SCAN) = %d\n",pass,acqs,realu_flag,(int)((rspent == L_SCAN)));
                fflush(stdout);
                }
            #endif /* SIM */

            /* CC: PROP, set the new rotating matrix according specific rotating angle */
    	/*	if ((realu_flag == PSD_ON) && (rspent == L_SCAN) && (pass > 0))  */  /* liyuan buyao*/
    		if ((realu_flag == PSD_ON) && (rspent == L_SCAN))

    		{
		    set_realu_rotation();
		    set_prop_offcenter();   /*liyuan yao */
            /*
		    if (prop_delay_flag == PSD_ON) prop_delaycore(RUP_GRD(prop_tdelay));  */ /*liyuan buyao */
#ifdef SIM
	    	    if (realu_debug == 1){
	    	    /*
		    	fprintf(stdout, "Run prop_delaycore with delay=%d",RUP_GRD(prop_tdelay)); */

                fprintf(stdout, "In normscan(), after set_realu_rotation\n");

	   	    	fflush(stdout);
	    	    }
#endif /* SIM */

            }

                if (pass!= acqs-1) 
                {
                    /* MRIhc08009/MRIhc08223: Set length of pass sequence to pass_seqtime if not the
                     * last acquisition*/
                    setperiod( pass_seqtime, &seqpass, 0 );
                } else {
                    /* MRIhc08009/MRIhc08223: If last acquisition then set length of pass sequence to
                     * TR_PASS */
                    setperiod( TR_PASS, &seqpass, 0 );
                }
		
                /* MRIhc03524: For Concat SAT with pause, make sure clock time is set correctly. 
                 * Added function call setscantimeimm()
                 */
                if( (SatRelaxers) && (opslicecnt > 1) && (0 == pass))
                {
                    setscantimeimm( 0, (INT)((pitscan-ccsrelaxtime)/acqs*opslicecnt
                                    + ccsrelaxtime/true_acqs*(opslicecnt-1)), 
                                    piviews, pitslice, opslicecnt );
                }

                /**MRgFUS tracking realtime mode **/
                if ( track_flag && (rspent == L_SCAN))
                {
                    if (SUCCESS != track_check_rtp_update())
                    { /*if rtp failed, the scan will quit*/
                        return FAILURE;
                    }
                    /*cont_trip_phaseno is used on recon side to check if there is any image loss for realtime imaging*/
                    if(oprealtime)
                    {
                        cont_trip_phaseno = ++phaseno_fus;
                    }
                    else
                    {
                        ++phaseno_fus;
                    }

                    switch(cont_trip_mode)
                    {
                        case 0:
                            if ( FAILURE == track_normscan(1) )
                            {
                                return FAILURE;
                            }
                            cont_rtia_stop = PSD_ON;
                            break;

                        case 1: /*realtime imaging only, - thermal mapping, KL*/
                            if ((phaseno_fus == 1) && (fus_phase1_track == 1))
                            {
                                if ( FAILURE == track_normscan(1) )
                                {
                                    return FAILURE;
                                }
                                rspdda = cont_trip_phasedda;
                            }
                            else
                            {
                                rspdda = 0;
                            }
                            break;

                        case 2:
                            /*force to run a tracking at the very first phase*/
                            if( ((phaseno_fus == 1) && (fus_phase1_track == 1))
                                || (((phaseno_fus-1) % (cont_trip_phasecount)) == 0) )
                            {
                                if ( FAILURE == track_normscan(phaseno_fus - prev_pass_num) )
                                {
                                    return FAILURE;
                                }
                                prev_pass_num = phaseno_fus;
                                rspdda = cont_trip_phasedda;
                            }
                            else
                            {
                                rspdda = 0;
                            }
                            break;

                        case 3:
                            /*force to run a tracking at the very first phase*/
                            if( ((phaseno_fus == 1) && (fus_phase1_track == 1))
                                || (cont_trip == PSD_ON) )
                            {
                                cont_trip = 0;
                                if (FAILURE == track_normscan(phaseno_fus - prev_pass_num ))
                                {
                                    return FAILURE;
                                }
                                prev_pass_num = phaseno_fus;
                                rspdda = cont_trip_phasedda;
                            }
                            else
                            {
                                rspdda = 0;
                            }
                            break;

                        default:
                            break;
                    }

                    if(track_runtime_debug)
                    {
                        sprintf(psddbgstr,  "Current phase number is: %d, rspdda is: %d", phaseno_fus, rspdda);
                        printdbg(psddbgstr, track_runtime_debug);
                    }

                    cont_trip = 0;

                    offset_to_seqcore();
                    setrotatearray( (short)opslquant, rsprot[0] );
                    settriggerarray( (short)opslquant, rsptrigger );
                }

                if( (feature_flag & FIESTA) && oprealtime )
                {
                    fiesta_realtime_update( input_id_values_buffer,
                                            recon_id_values_buffer );
                }
                else if( feature_flag & RTIA98 )
                {
                    rtia98_update ( input_id_values_buffer,
                                    recon_id_values_buffer );

                    /* RTIA adds IR sequence prior to the core in a pass. */
                    /* MRIge90145: add viewtable switching support */
                    if( cont_IR )
                    {
                        viewtab_ptr = viewtab_IR;
                        PlayHard180 (psd_index);
                        boffset(off_seqcore);
                        /* Play disdaqs after Hard180 */
                        for( dis = -IRdda ; dis < 0; dis ++ )
                        {
                            fgre_loaddab_echo1( 0, 0, 0, 0, DABOFF );
                            startseq( (SHORT)0, (SHORT)MAY_PAUSE );
                            /* RJF-GB Project 9484;AMR for MRIge53904 */
                        }
                    }
                    else
                    {
                        viewtab_ptr = viewtab;
                    }
                    /* End RTIA */
                }
                else if( (feature_flag & ECHOTRAIN) && oprealtime )
                {
                    echotrain_realtime_update( input_id_values_buffer,
                                               recon_id_values_buffer );
#ifdef PSD_HW
                    /* perform Echo Alignment Scans after the update */
                    if( cont_rtia_stop == PSD_OFF ) {
                        EtaMakeDtTable( feature_flag );
                    }
#endif /* PSD_HW */
                }

                if( feature_flag & RTIA98 )
                {
                    rtiacore();
                } else { 
                    core_select( feature_flag, rspslq, phorder, opaphases );
                    /* MRIhc08009/MRIhc08223: Moved the scandelay1 call from coreselect to
                     * here. For Multi-Phase scans and if last acquisition then
                     * do not wait for delay time. If greater than 10sec then
                     * split delay (see Mph.e mph_long_delay()  for more
                     * details)*/
                    if ((feature_flag & MPH) && (pass!=acqs-1))
                    {
                        if ((sldeltime > 10s) && (slicecnt == acqs)) 
                        {  /* YMSmr07539  08/15/2005 YI */
                            scandelay1();
                        }
                    }
                } 
        
                /* If fast_pass == PSD_ON,  pass packet will be sent in 
                   Echotrain.e */
                if(PSD_OFF == fast_pass)
                {
                    if(PSD_ON == oprealtime)
                    {
                        if(PSD_ON == cont_rtia_stop)
                        {
                            issue_stop_scan = 1;
                        } else {
                            issue_stop_scan = 0;
                        }
                    } else {
                        if ((pass == (acqs -1)) && (pass_shot == (pass_reps-1))) 
                        {
                            issue_stop_scan = 1;
                        } else {
                            issue_stop_scan = 0;
                        }
                    }

                    if(1 == issue_stop_scan)
                    {
                        /* Set DAB pass packet to end of scan */
                        setwamp( SSPD + DABPASS + DABSCAN, &pass_pulse, 2 );
                    } else {
                        /* Set DAB pass packet to end of pass */
                        setwamp( SSPD + DABPASS, &pass_pulse, 2 );
                    }

                    if(FAILURE == settriggerarray((short)1, rsptrigger_temp))
                    {
                        return FAILURE;
                    }

                    /* Set pause logic.  This includes locs b4 pause. */
                    if( PSD_ON == oprealtime ) 
                    {
                        pause = AUTO_PAUSE;
                    } else {
                        if( (pass_shot < (pass_reps-1)) && (PSD_ON == pure_ref) && (opslicecnt>0) ){
                            pause = MUST_PAUSE;   /* pause if desired */
                        }
                        else if(( pass == (acqs - 1)) && (pass_shot == (pass_reps -1)) ) {
                            pause = MAY_PAUSE;
                        } else {
                            /* if not last pass */
                            if( (pass != (acqs - 1)) && (((pass + 1) % slicecnt) == 0) ) {
                                pause = MUST_PAUSE;   /* pause if desired */
                            } else {
                                pause = AUTO_PAUSE;   /* or if required */
                            }
                        }
                    }

                    /* Auto Voice */ /* 04/18 2005 YI */
                    if( (MUST_PAUSE == pause) || issue_stop_scan ) 
                    {
                        setperiod(avminsldelaydef, &seqpass, 0 ) ; 
                    }
                    else
                    {
                         if( (feature_flag & MPH) && (slicecnt != acqs) )
                         { /* YMSmr07539  08/15/2005 YI */
                             setperiod(avminsldelaydef, &seqpass, 0 );
                         } else {
                             setperiod( pass_seqtime, &seqpass, 0 );
                         }
                    }

                    sp_sat_index = 0;
                    boffset( off_seqpass );

                    /* Begin RTIA addition */
#ifdef PSD_HW
                    /* Pass the recon id values to the tps/tgt shared
                       buffer so that recon gets it at the end of pass
                       interrupt. */
                    if (oprealtime == PSD_ON) 
                    {
                        cs_save_recon_values( recon_id_values_buffer );
                    }
#endif /* PSD_HW */

#ifdef PSD_HW       /* Auto Voice */
                    if (pi_sldelnub && (touch_flag || (feature_flag & MPH)) && (pass != acqs-1) && (slicecnt == acqs)) { 
                        broadcast_autovoice_timing(0, sldeltime/1ms, TRUE, TRUE);
                    }
#endif

                    if (FAILURE == startseq((SHORT)0, (SHORT)pause))
                    {
                        return FAILURE;
                    }
                    /* Update Exorcist pulse - LX2 */
                    if( (pass != (acqs -1)) &&
                        (PSD_ON==opexor || PSD_ON==cmon_flag))
                    {
                        exorcist_pass_init();
                        setwamp( SSPD, &pass_pulse, 2 );
                        sp_sat_index = 0;
                        startseq( 0, MAY_PAUSE );
                    }

                    /* Return to standard trigger array and core offset */
                    /* Set trigger array size to max (if sat) */
                    /* Fast CINE - 13/Feb/1998 - GFN */
                    /* MRIge60002 - removed opaphases -- caused reference
                       into non-existent slices */
                    settriggerarray( (short)opslquant, rsptrigger );

                    mpl_settriggers( feature_flag );
                    fmpvas_settriggers( feature_flag );

                    /* MRIhc03524: For Concat SAT with pause, make sure clock time is set correctly. 
                     * Added following if statement and function call setscantimeimm() 
                     */
                    if((SatRelaxers) && (opslicecnt > 1) && (MUST_PAUSE == pause))
                    {
                        passes_left = IMin(2, opslicecnt, acqs-1-pass);  /* How many passes remain? */
                        setscantimeimm( 0, (INT)((pitscan-ccsrelaxtime)/acqs*passes_left 
                                        + ccsrelaxtime/true_acqs*(passes_left-1)),  
                                        piviews, pitslice, opslicecnt );
                    }

                    /* If this isn't the last pass and we are doing relaxers  */
                    if((SatRelaxers) && (pass != (acqs - 1)) && (pause != MUST_PAUSE))
                    {
                        /* MRIhc03524: After pause, don't play relaxers. 
                         * Added (pause != MUST_PAUSE) condition to play SpSatPlayRelaxers()
                         */
                        SpSatPlayRelaxers();
                    }

                    /* Begin RTIA modify */
                    offset_to_seqcore();
                    /* End RTIA modify */
                } /* fast_pass == PSD_OFF */            

                /* Write .hb file */
                if( cardt1map_flag ) {
                   cct_output();
                }

            } /* pass loop */
        } /*pass_shot loop*/
    } /* End RTIA loop */

    /* Setting the period of seqpass back to seqpass_deadtime to avoid the scan 
    failures which occurs when scan is done again after the fisrt scan without 
    downloading or copy/save Rx. (i.e. Pressing scan again after the first time). 
    One sees this issue because for the last pass we set the period of seqpass 
    to TR_PASS which is lower than seqpass_deadtime. When Scan is pressed
    again then for the second scan getperiod will return TR_PASS as the
    period instead of seqpass_deadtime and hence a difference in delay time is noticed      
    This was caught by Ikezaki San - MRIhc20775 */ 

    setperiod((long)seqpass_deadtime, &seqpass, 0 ); 
    
#ifdef PSD_HW
    if (feature_flag & ECHOTRAIN) {
        EtaCoprocess(PSD_OFF);    /* Stop the ETA coprocess on TPS */
    }
#endif /* PSD_HW */

#ifdef PSD_HW
    if( track_flag && isrtplaunched )
    {
        RtpEnd();
        isrtplaunched = 0;
    }
#endif

    /* Begin RTIA - RJF */
    /* Free allocated memory */
    RTIAExit( feature_flag );
    /* End RTIA  */

%ifdef DEBUG
    printdbg( "Normal End of SCAN", debugstate );
%endif /* DEBUG */

    return SUCCESS;
}   /* end normscan() */


/*
 *  ps2core
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
ps2core( INT numdda, 
         INT numvus, 
         INT numnex )
{
    SHORT rf_chop_amp;
    INT rspskp;
    /* SVBranch HCSDM00115164 */
    int gx1_val, gxw_val, gxwex_val, sbm_num;

    printdbg( "Starting ps2core", debugstate );

    /* SVBranch HCSDM00115164: support SBM for FIESTA */
    /* Store amplitude for X gradient pulses */
    if(sbm_flag)
    {
        get_gx1_amp(&gx1_val, 0);
        get_gxw_amp(&gxw_val, 0);
        get_gxwex_amp(&gxwex_val, 0);
        sbm_num = 0;
    }

    /* YMSmr08736  02/07/2006 YI */
    if((TYPFASTMPH == seq_type) && (PSD_OFF == opacqo))
        slice = pre_slice;

    SetRspslices( pass, slice );
    seq_count = 0;
    exphase   = 0;

#ifdef QQQ
    print_offsets( off_seqcore, "off_seqcore", "ps2core" );
#endif /* QQQ */
    boffset( off_seqcore );
    
    if (touch_flag)
    {
        set_seqcore_period( mphseq_seqtime, 0) ;
    }

    settrigger( (SHORT)TRIG_INTERN, (SHORT)psd_index );

    dabop = 0;

    set_ps2frequencies( psd_index );

    rf_chop_amp = (SHORT)ia_rf1;

    fgre_loaddab_echo1( slice, dabecho, dabop, dabview, DABOFF );

    for ( view = -numdda ; view < 0 ; view++ ) 
    {
        if (PSD_ON == spgr_flag)
        {
            /* get phase offset and increment seq_count */ 
            get_spgr_phase( &seq_count, &exphase, seed );
            setiphase( exphase, &rf1, scanrf1_inst );
            getphase( &rf1phase, &rf1, scanrf1_inst );   /* used for debugging */

            /* Begin RTIA replace*/
            set_echo1phase(exphase, 0);
            /* End RTIA */
        }

        /* SVBranch HCSDM00115164: support SBM for FIESTA */
        /* Turn off X and Y gradient Pulses      */
        if(sbm_flag)
        {
            set_gx1_amp(0, 0);
            set_gxw_amp(0, 0);
            set_gxwex_amp(0, 0);
            setiamp( 0, &gy1, 0 );
            if (PSD_ON == rewinder_flag)
            {
                setiamp(0, &gy1r, 0);
            }
        }


        startseq( (SHORT)psd_index, (SHORT)MAY_PAUSE );
        syncoff( &seqcore );

        /* Chopper logic */
        if ( (rspchp == 1) || (view < 1) ) 
        {
            setiamp( rf_chop_amp, &rf1, scanrf1_inst );
            rf_chop_amp = -rf_chop_amp;
        }
    }   /* end disdaq loop */

    rspskp = 1;
    rspgy1 = 0;
    for ( view = 1 ; view <= numvus ; view++ ) 
    {
        if ( rspgy1 == 0 ) 
        {
            amp_gy1 = rspgy1;
        } else {
            amp_gy1 = -viewtable[rspgy1];
        }

        if (nope >= 1)
            amp_gy1 = 0;

        setiamp( amp_gy1, &gy1, 0 );

        if (PSD_ON == rewinder_flag)
        {
            setiamp(-amp_gy1, &gy1r, 0);
        }

        if ( (view%rspskp) == 0 ) 
        {
            acq_echo1 = DABON;
        } else {
            acq_echo1 = DABOFF;
        }

        /* SVBranch HCSDM00115164: support SBM for FIESTA */
        /* Recover amplitude for X gradient pulses */
        if(sbm_flag)
        {
            set_gx1_amp(gx1_val, 0);
            set_gxw_amp(gxw_val, 0);
            set_gxwex_amp(gxwex_val, 0);
        }
  
        fgre_loaddab_echo1( psd_index, dabecho, dabop, dabview, acq_echo1 );

        for ( excitation = 1 ; excitation <= numnex ; excitation++ ) 
        {
            attenlockoff( &attenuator_key );

            if (sp_sat && touch_flag) 
            {
                SpSatUpdateRsp(1, pass, opccsat);
                SatPrep(psd_index); 
                offset_to_seqmps2();
            }


            if (PSD_ON == spgr_flag)
            {
                /* get phase offset and increment seq_count */ 
                get_spgr_phase( &seq_count, &exphase, seed );
                set_ps2_phase( exphase );   /*&rf1phase, &rcvphase - removed */
            } 

            /* SVBranch HCSDM00115164: support SBM for FIESTA */
            /* Record index of TR number */
            if(sbm_flag)
            {
                sbm_num ++;
            }

            startseq( (SHORT)psd_index, (SHORT)MAY_PAUSE );
            syncoff( &seqcore );

            /* Chopping */
            if (1==rspchp)
            {
                setiamp( rf_chop_amp, &rf1, scanrf1_inst );
                rf_chop_amp = -rf_chop_amp;
            }

            /* SVBranch HCSDM00115164: support SBM for FIESTA */
            /* When heat reaches limit, play waiting sequence */
            if(sbm_flag && (sbm_num == sbm_mps2_num))
            {
                sbm_num = 0;
                runSbmWait((int)sbm_time_limit*1000000);
            }

        }   /* excitation */
    }
    printdbg( "Returning from ps2core", debugstate );

    return SUCCESS;
}   /* end ps2core() */


/*
 *  scancore
 *
 *  Type: Function
 *
 *  Description:
 *     This function executes the real time code needed to adquire
 *     images with the SCAN button.
 *     The argument is the number of slices to play out per pass.
 */
STATUS
scancore( INT num_rspslq )
{
    int  ndir, touch_amp, play_spsat;
    INT cntvus;   /* Flag for collecting central views in
                     Oddnex NPW case - MHN */
    INT dis;		     
    CHAR psddbgstr[256] = "";
    INT temp_seqcount,temp_exphase;
    extern INT arc_fullbam_flag;

    printdbg( "Starting Core", debugstate );

    if (touch_flag) 
    {
        offset_to_seqcore();
        /* Begin RTIA manual merge */
        /* The deadtime could have been reset in psdinit 
           or during prescan. Set the right deadtime here.-
           RJF */

        set_seqcore_period( mphseq_seqtime, 0) ;
    
        ndir = rsp_cmndir;                                    
    }
    else 
    {
        ndir = 1;
    }

    for ( slice = 0 ; slice < num_rspslq ; slice++ ) 
    {
        /* rspslq=opslquant for interleave acq, 
           rspslq=opfphases for sequential acq. */
        if (1==debugstate)
        {
            sprintf( psddbgstr, "    slice=%6d", slice );
        }
        printdbg( psddbgstr, debugstate );

        if((touch_flag || (feature_flag & MPH)) && (PSD_SEQMODE_ON == opacqo)) 
        {
            /* MRIge60002 -- pass means slice and slice means phase
               so only give pass for sequential multi-phase */
            SetRspslices( pass, 0 );
        } else {
            /* MRIge60002 -- pass means acq or phase and slice means
               true slice so give both for all other scans */
            SetRspslices( pass, slice );
        }

        /* Load Transmit and Receive Frequencies */
        if (1==debugstate)
        {
            /* For debugging OCFOV */
            sprintf( psddbgstr, 
                     "\tTf= %d, Rf= %d ->rsp_info[%d].rsploc= %f", 
                     rf1_freq[psd_index], receive_freq1[psd_index], 
                     psd_index, rsp_info[psd_index].rsprloc );
            printdbg( psddbgstr, debugstate );
        }

        if (touch_flag) 
        {
            SlideTouchTrig();
        }

        /* Begin RTIA */
        set_rf1frequency( rf1_freq[psd_index], scanrf1_inst );
        set_echo1frequency( receive_freq1[psd_index], 0 ); 
        /* End RTIA */ 
        /*MRIge91882*/
        if(((PSD_GE == oppseq) || (PSD_3PLANELOC == oppseq)) && 
           (PSD_3PLANE == opplane) && !(feature_flag & IRPREP))
        {
            if((psd_index > 0) && ((rsprot[psd_index-1][2] != rsprot[psd_index][2]) || (rsprot[psd_index-1][5] != rsprot[psd_index][5])))
            {
                for( dis = -threeplane_dda ; dis < 0; dis ++ ) 
                {
                    fgre_loaddab_echo1( 0, 0, 0, 0, DABOFF );
                    startseq( (SHORT)psd_index,(SHORT)MAY_PAUSE );
                    if(threeplane_debug) {
                        printf("pass:%d,psd_index:%d\n",pass,psd_index);
                    }
                } 
            }
        }

        for (view = disdaqs + baseviews; view <= rspvus; view++) 
        {
            if((1 == cs_sat) && ((L_MPS2 == rspent) || (L_APS2 == rspent))) 
            {
                CsSatMod(cs_satindex, cs_sat, cs_tune);
            }

            if((view <= 0) && (rspgy1 > 0)) 
            {
                dabview = viewtab[0];   /* viewtab index starts from 0 */
                /* Begin RTIA */
                amp_gy1 = viewtable[ARCGetDabView(dabview)];
                if (nope >= 1)
                    amp_gy1 = 0; 
                set_gy1_amp ((INT) amp_gy1, 0L); 
            } 
            else
            {
                if ( (view > 0) && (rspgy1 > 0) ) 
                {
                    dabview = viewtab[view - 1];
                    amp_gy1 = viewtable[ARCGetDabView(dabview)];
                    if (nope >= 1)
                        amp_gy1 = 0; 
                    set_gy1_amp ((INT)amp_gy1, 0L);
                }
            }
            /* End RTIA */

            cntvus = 0; /* Initialize flag for isOddNexGreaterThanOne NPW - MHN */

            for ( excitation = 1-rspdex;
                  excitation <= rspnex && (cntvus < 1);
                  excitation++ )
            {
                /* Condition to turn cntvus flag on/off - MHN */
                if ((1 == isNonIntNexGreaterThanOne) && (L_SCAN == rspent) && 
                     (excitation == (rspnex -1)) &&
                     ( (view <= (rspvus / 4)) ||
                       (view > (3 * rspvus / 4)) ) ) 
                {
                    /* check for nop and isNonIntNexGreaterThanOne */
                    cntvus = 1;
                } else {
                    cntvus = 0;
                }

                if (1 == debugstate)
                {
                    sprintf(psddbgstr, "  Excitation=%6d", excitation);
                }
                printdbg(psddbgstr, debugstate);

                for (rsp_cmdir=0; rsp_cmdir<ndir; rsp_cmdir++) 
                {
                    if (touch_flag) 
                    {
                        if (sp_sat)  {
                            play_spsat = 1 ;
                        } else {
                            play_spsat = 0 ;
                        }

                        if (play_spsat) 
                        {
                            sat_flag = 1;
                            get_spgr_defphase(&temp_seqcount,&temp_exphase);
                            SpSatSPGR(temp_exphase);
                            SpSatUpdateRsp(1, pass, opccsat);
                            SatPrep(psd_index); 
                        }

                        sat_flag = 0;
                        set_rf1frequency(rf1_freq[psd_index], scanrf1_inst);
                    }

                    /* Load dab information */
                    if ( (1 == acq_sl) &&
                         (view >= baseviews) && (excitation > 0) ) {
                        acq_echo1 = DABON;
                        touch_amp = 1;
                    } else {
                        acq_echo1 = DABOFF;
                        touch_amp = 0;
                    }

                    /* MRIge36313 */ 
                    /* Tell exorcist which slices to acquire - LX2 */
                    if (PSD_ON == cmon_flag)
                    {
                        exorcist_pulse.echo[0].dab_onoff = acq_echo1;
                    }

                    /* RTIA, RJF */
                    /* turn on rho board */
                    turn_rho_board( (int)PSD_ON );
                    /* End RTIA change */

                    if (1 == excitation)
                    {
                        dabop = 0;
                    } else {
                        dabop = 1;
                    }

                    if (touch_flag) 
                    {
                        dabecho = rsp_cmdir;
                        if (touch_amp)
                        {
                            SetTouchAmp(rsp_cmdir);
                        }
                        else
                        {
                            NullTouchAmp() ;
                        }
                    }

                    /* All DAB Info is Set, Load it Up ! */
                    if (arc_fullbam_flag)
                    {
                        fgre_loaddab_echo1( slice, dabecho, dabop, ARCGetDabView(dabview), acq_echo1 );
                    }
                    else
                    {
                        fgre_loaddab_echo1( slice, dabecho, dabop, dabview, acq_echo1 );
                    }
                    if (PSD_ON == spgr_flag)
                    {
                        /* get phase offset and increment seq_count */ 
                        get_spgr_phase( &seq_count, &exphase, seed );
                        set_rf1phase (exphase, scanrf1_inst);
                    }

                    if (PSD_ON == opsat)
                    {
                        SpSatSPGR(exphase);
                    }

                    if (PSD_ON == cs_sat)
                    {
                        ChemSatPhase(exphase, 0);
                    }

                    /* calculate the phase offset for the sliceindex and view, 
                       then set exciter phase */

                    /* Check for CMON - LX2 */
                    if (0 == cmon_flag)
                    {
                        set_yres_phase(psd_index, dabview, exphase, rcphase_chop);
                    } else {
                        setiphase(exphase, &echo1, 0);
                    }

                    if (nope >= 1)
                        setiphase(0, &echo1, 0);

                    if (YES == first_scan)
                    {
                        /* not sure if some other routine uses this */
                        first_scan = NO;
                    }

                    /* RTIA delete */
                    /* rewinder amp set in set_gy1_amp */
                    /* End RTIA delete */

                    /* Do the sequence */
                    printdbg( "      Before startseq", debugstate );
                    sp_sat_index = psd_index;
                    startseq( (SHORT)psd_index, (SHORT)MAY_PAUSE );
                    printdbg( "      After startseq", debugstate );

                    /* Update Exorcist - LX2 */
                    if (PSD_ON == cmon_flag)
                    {
                        ExorUpdate();
                        exor_check_status();
                    }

                    syncoff(&seqcore);

                    /* Don't bother with chopping rf.
                       Receiver chopping so everything is cool */
                    if ( view < 1 ) {
                        /* Skip excitation loop for disdaqs */
                        /* and baseviews */
                        break;
                    }

                    if (1 == debugstate)
                    {
                        sprintf( psddbgstr, "view=%6d", view );
                    }
                    printdbg( psddbgstr, debugstate );

                }   /* rsp_cmdir */
            }   /* excitation */

            /* FUS */
            if( (ext_trig || track_flag)
                && (L_SCAN == rspent) && (0 == slice) && (view == disdaqs + baseviews))
            {
                rsptrigger[0] = gating;
                settriggerarray( (SHORT)num_rspslq, rsptrigger );
            }
        }  /* view */
    }   /* slice */
    printdbg( "Returning from CORE", debugstate );

    return SUCCESS;
}   /* end scancore() */



/*
 *  SetRspslices
 *
 *  Type: Function
 *
 *  Description:
 *    Setup slice acq. order and trigger mechanism.
 */
STATUS
SetRspslices( int this_pass, int this_slice )
{
    /* Determine if this slice should be acquired */
    if ((this_slice == rspasl) || (-1 == rspasl))
    {
        acq_sl = 1;
    } else {
        acq_sl = 0;
    }
  
    /* Determine which slice is to be excited ( find spot in
       rspinfo table). Remember slices and passes start at 0 */
    if (-1 == rspesl)
    {
        /***** issue **  don't really need two of this. The % opslquant
               is just to keep psd_index < opslquant **/
        /* interleaved */
        psd_index = acq_ptr[this_pass] + this_slice;
    } else {
        psd_index = acq_ptr[this_pass] + rspesl;
    }

    /* Scope Trigger 90 - 180 */
    if (((rspsct == this_slice) || (-1 == rspsct)) && (1 == rspscptrg))
    {
        scopeon(&seqcore);
    } else {
        scopeoff(&seqcore);
    }
  
    printdbg( "Returning from SetUpslices", debugstate );
    
    return SUCCESS;
}   /* end SetRspslices() */


/*
 *  SatPrep
 *
 *  Type: Function
 *
 *  Description:
 *    Sat section of the sequence.
 */
STATUS
SatPrep( INT psdindex )
{
    INT rot_offset;

    offset_to_Spsat_fgre();

    /* Fast CINE - 13/Feb/1998 - GFN */
    /* MRIge60002 - removed opaphases -- caused reference
       into non-existent slices */
    rot_offset = psdindex + opslquant;

    sp_sat_index = psdindex;
    startseq( (SHORT)rot_offset, (SHORT)MAY_PAUSE );

#ifdef QQQ
    print_offsets( off_seqcore, "off_seqcore", "SatPrep" );
#endif /* QQQ */

    /* Begin RTIA replace */
    offset_to_seqcore();
    /* End RTIA */

    printdbg( "Returning from SATPREP", debugstate );
    
    return SUCCESS;
}   /* end SatPrep() */


/*
 *  offset_to_seqcore
 *
 *  Type: Function
 *
 *  Description:
 *    Offset calls for modifying engine params from modules.
 */
STATUS
offset_to_seqcore( void )
{
#ifdef QQQ
    print_offsets( off_seqcore, "off_seqcore", "offset_to_seqcore" );
#endif /* QQQ */
    if (! (feature_flag & RTIA98) ) {
        boffset( off_seqcore );
    } else { 
        if (1 == cont_flowComp)
        { 
            offset_to_seqcorefc ();
        } else { 
            boffset( off_seqcore );
        } 
    }
    return SUCCESS;
}   /* end offset_to_seqcore() */


/* ETA */
STATUS
offset_to_eta_seqpause( void )
{
    boffset( off_eta_seqpause );
    return SUCCESS;
}


/*
 *  offset_to_seqmps2
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
offset_to_seqmps2( void )
{
#ifdef QQQ
    print_offsets( off_seqcore, "off_seqcore", "offset_to_seqmps2" );
#endif /* QQQ */
    boffset( off_seqcore );

    return SUCCESS;
}   /* end offset_to_seqmps2() */


/*
 *  offset_to_seqcopy
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
offset_to_seqcopy( void )
{
#ifdef QQQ
    print_offsets( off_seqcopy, "off_seqcopy", "offset_to_seqcopy" );
#endif /* QQQ */
    boffset( off_seqcopy );

    return SUCCESS;
}   /* end offset_to_seqcopy() */


/*
 *  syncoff_seqmps2
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
syncoff_seqmps2( void )
{
    syncoff( &seqcore );

    return SUCCESS;
}   /* end syncoff_seqmps2() */


/*
 *  syncoff_seqcore
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
syncoff_seqcore( void )
{
    if ( !(feature_flag & RTIA98) ) { 
        syncoff( &seqcore );
    } else { 
        if (1 == cont_flowComp)
        { 
            syncoff_seqcorefc();
        } else { 
            syncoff( &seqcore );
        }
    }

    return SUCCESS;
}   /* end syncoff_seqcore() */


/*
 *  set_rf1frequency
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_rf1frequency( INT freq, 
                  LONG n_inst )
{  
    if ( !(feature_flag & RTIA98) ) { 
        setfrequency( freq, &rf1, n_inst );
    } else { 
        if (1 == cont_flowComp)
        { 
            set_rf1fcfrequency (freq); /* Instr index 0 */
        } else { 
            setfrequency( freq, &rf1, n_inst );
        }
    } 

    return SUCCESS;
}   /* end set_rf1frequency() */


/*
 *  set_echo1frequency
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
set_echo1frequency( INT freq, 
                    INT n_inst )
{ 
   int i;

    if ( !(feature_flag & RTIA98)) {
        setfrequency( freq, &echo1, n_inst );
        for(i=1;i<(opnecho-1);i+=2) {
            setfrequency( freq, &(readecho[i]), n_inst );
        }
    } else { 
        if (1 == cont_flowComp)
        {
            set_echo1fcfrequency (freq); /* Instr index 0 */
        } else { 
            setfrequency( freq, &echo1, n_inst );
            for(i=1;i<(opnecho-1);i+=2) {
                setfrequency( freq, &(readecho[i]), n_inst );
            }

        } 
    }
    return SUCCESS;
}   /* end set_echo1frequency() */


/* DUALECHO addition */
STATUS
set_echo2frequency( INT freq,
                    INT n_inst )
{
    int i;

    for(i=0;i<(opnecho-1);i+=2) {
        setfrequency( freq, &(readecho[i]), n_inst );
    }

    return SUCCESS;
}   /* end set_echo2frequency() */


/*
 *  set_rf1phase
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_rf1phase( INT phase, 
              INT n_inst )
{  
    if ( !(feature_flag & RTIA98 )) {
        setiphase( phase, &rf1, n_inst );
        getphase( &rf1phase, &rf1, n_inst ); /* used for debugging */
    } else { 
        if (1==cont_flowComp)
        {
            set_rf1fcphase (phase); /* Instr index 0 */
        } else { 
            setiphase( phase, &rf1, n_inst );
        }
    }
    return SUCCESS;
}   /* end set_rf1phase() */


/*
 *  set_echo1phase
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_echo1phase( INT phase, 
                INT n_inst )
{
    if ( !(feature_flag & RTIA98) ) {
        setiphase( phase, &echo1, n_inst );
    } else { 
        if (1==cont_flowComp)
        {
            set_echo1fcphase(phase); 
        } else { 
            setiphase( phase, &echo1, n_inst );
        } 
    } 

    return SUCCESS;
}   /* end set_echo1phase() */


STATUS
set_echo2phase( INT phase,
                INT n_inst )
{
    int i;

    for(i=0;i<(opnecho-1);i++) {
        setiphase( phase, &(readecho[i]), n_inst );
    }

    return SUCCESS;

}


/*
 *  set_rf1amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_rf1amp( INT amp, 
            LONG n_inst )
{  
    if ( !(feature_flag & RTIA98) ) {
        setiamp( amp, &rf1, n_inst );
    } else { 
        if (1==cont_flowComp)
        {
            set_rf1fcamp ( amp ); /* Instr index 0 */
        } else { 
            setiamp( amp, &rf1, n_inst );
        }
    } 

    return SUCCESS;
}   /* end set_rf1amp() */


/*
 *  set_ps2_rf1amp
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
set_ps2_rf1amp( INT rf1amp )
{
    setiamp( rf1amp, &rf1, scanrf1_inst );

    return SUCCESS;
}   /* end set_ps2_rf1amp() */


/*
 *  set_gy1_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gy1_amp( INT ph_encode_amp, 
             LONG waveform_index ) 
{
    if (nope >= 1)
        ph_encode_amp = 0;

    if ( !(feature_flag & RTIA98) ) 
    { 
        setiamp( -ph_encode_amp, &gy1, waveform_index );
        if (PSD_ON == rewinder_flag)
        {
            setiamp( ph_encode_amp, &gy1r, waveform_index );
        } 
    } else { 
        if (1==cont_flowComp)
        {
            set_gy1fc_amp (ph_encode_amp, waveform_index, rewinder_flag);
        } else { 
            setiamp( -ph_encode_amp, &gy1, waveform_index );
            if (PSD_ON == rewinder_flag) 
            {
                setiamp( ph_encode_amp, &gy1r, waveform_index );
            } 
        }
    } 
    return SUCCESS;
}   /* end set_gy1_amp() */


/*
 *  set_gy1_amp2
 *  
 *  Type: Function
 *  
 *  Description:
 *    ???
 */
STATUS
set_gy1_amp2( INT ph_encode_amp, 
              INT ph_rewind_amp,
              LONG waveform_index ) 
{
    if (nope >= 1) {
        ph_encode_amp = 0;
        ph_rewind_amp = 0;
    }

    setiamp( ph_encode_amp, &gy1, waveform_index );
    if (PSD_ON == rewinder_flag)
    {
        setiamp( ph_rewind_amp, &gy1r, waveform_index );
    }

    return SUCCESS;
}   /* end set_gy1_amp() */


/*
 *  set_gyb_amp
 *  
 *  Type: Function
 *  
 *  Description:
 *    ???
 */
STATUS 
set_gyb_amp( INT blip_amp,
             INT Etl )
{
    INT i;

    for ( i = 0 ; i < Etl - 1 ; i++ ) 
    {
        setiampt( blip_amp, &gyb, i );
    }

    return SUCCESS;
}   /* end set_gyb_amp() */


/*
 *  set_gy1_ampimm
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gy1_ampimm( INT ph_encode_amp, 
                LONG waveform_index )
{
    if (nope >= 1)
        ph_encode_amp = 0;

    if ( !(feature_flag & RTIA98)) 
    { 
        setiampimm( -ph_encode_amp, &gy1, waveform_index );
        if (PSD_ON == rewinder_flag) 
        {
            setiampimm( ph_encode_amp, &gy1r, waveform_index );
        }
    } else { 
        if (1==cont_flowComp)
        {
            set_gy1fc_ampimm (ph_encode_amp, waveform_index, rewinder_flag); 
        } else { 
            setiampimm( -ph_encode_amp, &gy1, waveform_index );
            if (PSD_ON == rewinder_flag)
            {
                setiampimm( ph_encode_amp, &gy1r, waveform_index );
            } 
        }
    }

    return SUCCESS;
}   /* end set_gy1_ampimm() */


/*
 *  load_ps2echo1dab
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
load_ps2echo1dab( INT slice_num, 
                  INT echo_num, 
                  INT dabOP, 
                  INT dab_view, 
                  TYPDAB_PACKETS acq_echo )
{
    fgre_loaddab_echo1( slice_num, echo_num, dabOP, dab_view,
                        (TYPDAB_PACKETS)acq_echo );

    return SUCCESS;
}   /* end load_ps2echo1dab() */


/* dual echo addition DUALECHO ALP */
STATUS
load_ps2echo2dab( INT slice_num, 
                  INT echo_num, 
                  INT dabOP, 
                  INT dab_view, 
                  TYPDAB_PACKETS acq_echo )
{
    fgre_loaddab_echo2( slice_num, echo_num, dabOP, dab_view,
                        (TYPDAB_PACKETS)acq_echo );

    return SUCCESS;
}   /* end load_ps2echo2dab() */


/*
 *  set_ps2_gy1amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_ps2_gy1amp( INT ph_encode_amp, 
                LONG waveform_index )
{
    setiamp( -ph_encode_amp, &gy1, waveform_index );
    if (PSD_ON == rewinder_flag)
    {
        setiamp( ph_encode_amp, &gy1r, waveform_index );
    }

    return SUCCESS;
}   /* end set_ps2_gy1amp() */


/*
 *  calc_yres_phase
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
calc_yres_phase( INT *receiver_phase, 
                 INT index, 
                 INT view_num, 
                 INT exciter_phase, 
                 INT rc_phase_chop )
{
    INT Rcvr_phase;

    yres_phase = phase_off[index].ysign *
        (((ARCGetDabView(view_num) - 1) * phase_off[index].yoffs + 3L *FS_PI) %
         FS_2PI - FS_PI);

    if (nope >= 1)
       yres_phase = 0;

    if (rc_phase_chop) 
    {
        /* let's do receiver phase chopping */
        if(arc_ph_flag)
        {
            Rcvr_phase = (INT)(((exciter_phase +
                                 (ARCGetDabView(view_num) * FS_PI) % FS_2PI + 3L * FS_PI) % 
                                FS_2PI) - FS_PI);
        }
        else
        {
            Rcvr_phase = (INT)(((exciter_phase +
                                 (view_num * FS_PI) % FS_2PI + 3L * FS_PI) % 
                                FS_2PI) - FS_PI);
        }
        /* now combine this phase with the yres phase offset */
        /* set phase here and not in exorcist.e */
    } else {
        Rcvr_phase = exciter_phase;
    }

    *receiver_phase = (Rcvr_phase + yres_phase + 3L * FS_PI) % FS_2PI - FS_PI;

    return SUCCESS;
}   /* end calc_yres_phase() */


/*
 *  set_yres_phase
 *
 *
 *  Type: Function
 *
 *  Description:
 *     ???
 */
STATUS
set_yres_phase( INT index, 
                INT view_num, 
                INT exciter_phase, 
                INT rc_phase_chop )
{
    int i;

    calc_yres_phase( &rcphase, index, view_num, exciter_phase, rc_phase_chop );
    if( !(feature_flag & RTIA98) ) {
        setiphase( rcphase, &echo1, 0 );
        /* Dual echo, DUALECHO ALP*/
        if( opnecho >= 2 ) {
            for(i=0;i<(opnecho-1);i++) {
                setiphase( rcphase, &(readecho[i]), 0);
            }
            /* setiphase( rcphase, &echo2, 0); */
        }
        getphase( &rcvphase, &echo1, 0 );   /* used for debugging */
    } else { 
        if(1==cont_flowComp)
        {
            set_echo1fcphase( rcphase );
        } else { 
            setiphase( rcphase, &echo1, 0 );
        }
    }

    return SUCCESS;
}   /* end set_yres_phase() */


/*
 *  set_dummy_phase
 *  
 *  Type: Function
 *  
 *  Description:
 *    ??
 */
STATUS
set_dummy_phase( INT exciter_phase )
{
    if ( ! (feature_flag & RTIA98) ) {
        setiphase( exciter_phase, &echo1, 0 );
        getphase( &rcvphase, &echo1, 0 );   /* used for debugging */
    } else { 
        if (1==cont_flowComp)
        {
            set_echo1fcphase ( exciter_phase ); 
        } else { 
            setiphase( exciter_phase, &echo1, 0 );
        } 
    } 

    return SUCCESS;
}   /* end set_dummy_phase() */


/*
 *  turn_rho_board
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
turn_rho_board( INT state )
{
    if ( ! (feature_flag & RTIA98) ) { 
        if ( state == PSD_ON ) {
            setieos( (SHORT)EOS_PLAY, &rho_td0, 0 );
        } else {
            setieos( (SHORT)EOS_DEAD, &rho_td0, 0 );
        }
    } else { 
        if (1==cont_flowComp) {
            turn_rho_board_fc (state);
        } else { 
            if (PSD_ON == state)
            {
                setieos( (SHORT)EOS_PLAY, &rho_td0, 0 );
            } else { 
                setieos( (SHORT)EOS_DEAD, &rho_td0, 0 );
            } 
        } 
    } 

    return SUCCESS;
}   /* end turn_rho_board() */


/*
 *  set_ps2frequencies
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_ps2frequencies( INT Psd_index )
{
    setfrequency( rf1_freq[Psd_index], &rf1, scanrf1_inst );
    setfrequency( receive_freq1[Psd_index], &echo1, 0 );

    return SUCCESS;
}   /* end INT set_ps2frequencies() */


/* dual echo addition DUALECHO ALP */
STATUS
set_ps2echo2frequencies( INT Psd_index )
{
    int i;

    for(i=0;i<(opnecho-1);i++) {
        setfrequency( receive_freq2[Psd_index], &(readecho[i]), 0 );
    }

    /* setfrequency( receive_freq2[Psd_index], &echo2, 0 ); */


    return SUCCESS;
}   /* end INT set_ps2e2frequencies() */


/*
 *  set_seqps2_period
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_seqps2_period( INT period, 
                   INT offset )
{
    setperiod( period, &seqcore, offset );

    return SUCCESS;
}   /* end set_seqps2_period() */


/*
 *  set_ps2_phase
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_ps2_phase( INT Exphase )
{
    setiphase( Exphase, &rf1, scanrf1_inst );
    getphase( &rf1phase, &rf1, 0 );   /* used for debugging */
  
    setiphase( exphase, &echo1, 0 );
    getphase( &rcvphase, &echo1, 0 );   /* used for debugging */

    return SUCCESS;
}   /* end set_ps2_phase() */


/*
 *  copy_frame
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
copy_frame( INT source_pass, 
            INT source_slice, 
            INT source_echo, 
            INT source_view, 
            INT dest_pass, 
            INT dest_slice, 
            INT dest_echo, 
            INT dest_view, 
            INT num_copies, 
            TYPDAB_PACKETS op_ctrl )
{
    fgre_copyframe( &copydab, (INT)frame_control, 
                    (INT)source_pass, (INT)source_slice, 
                    (INT)source_echo, (INT)source_view, 
                    (INT)dest_pass, (INT)dest_slice, 
                    (INT)dest_echo, (INT)dest_view, 
                    (INT)num_copies, (TYPDAB_PACKETS)op_ctrl );
    
    return SUCCESS;
}   /* end copy_frame() */


/*
 *  copy_frame2
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
copy_frame2( INT source_pass, 
             INT source_slice, 
             INT source_echo, 
             INT source_view, 
             INT dest_pass, 
             INT dest_slice, 
             INT dest_echo, 
             INT dest_view, 
             INT num_copies, 
             TYPDAB_PACKETS op_ctrl )
{
    fgre_copyframe( &copydab2, (INT)frame_control, 
                    (INT)source_pass, (INT)source_slice, 
                    (INT)source_echo, (INT)source_view, 
                    (INT)dest_pass, (INT)dest_slice, 
                    (INT)dest_echo, (INT)dest_view, 
                    (INT)num_copies, (TYPDAB_PACKETS)op_ctrl );

    return SUCCESS;
}   /* end copy_frame2() */


/*
 *  set_gyfe1_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gyfe1_amp( INT flow_encode_amp, 
               LONG waveform_index )
{
    setiamp( flow_encode_amp, &gyfe1, waveform_index );

    return SUCCESS;
}   /* end set_gyfe1_amp() */


/*
 *  set_gyfe2_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gyfe2_amp( INT flow_encode_amp, 
               LONG waveform_index )
{
    setiamp( flow_encode_amp, &gyfe2, waveform_index );

    return SUCCESS;
}   /* end set_gyfe2_amp() */


/*
 *  set_gz1_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gz1_amp( INT flow_encode_amp, 
             LONG waveform_index )
{
    setiamp( flow_encode_amp, &gz1, waveform_index );

    return SUCCESS;
}   /* end set_gz1_amp() */


/*
 *  set_gzfc_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gzfc_amp( INT flow_encode_amp, 
              LONG waveform_index )
{
    setiamp( flow_encode_amp, &gzfc, waveform_index );
    
    return SUCCESS;
}   /* end set_gzfc_amp() */


/*
 *  set_gx1_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gx1_amp( INT flow_encode_amp, 
             LONG waveform_index )
{
    setiamp( flow_encode_amp, &gx1, waveform_index );

    return SUCCESS;
}   /* end set_gx1_amp() */


/*
 *  set_gxfc_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gxfc_amp( INT flow_encode_amp, 
              LONG waveform_index )
{
    setiamp( flow_encode_amp, &gxfc, waveform_index );

    return SUCCESS;
}   /* end set_gxfc_amp() */


/*  SVBranch HCSDM00115164
 *  set_gxw_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gxw_amp( INT gxw_amp,
             LONG waveform_index )
{
    setiampt( gxw_amp, &gxw, waveform_index );

    return SUCCESS;
}   /* end set_gxfc_amp() */


/*
 *  set_gxwex_amp
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
set_gxwex_amp( INT gxwex_amp,
               LONG waveform_index )
{
    setiampt( gxwex_amp, &gxwex, waveform_index );

    return SUCCESS;
}   /* end set_gxfc_amp() */


/*
 *  turnoff_isi6
 *
 *  Type: Function
 *
 *  Description:
 *    Turn OFF control bit for Tgt to service the ISI interrupt.
 */
STATUS
turnoff_isi6( void )
{
    long psd_ctrl;

    getctrl( &psd_ctrl, &isi6, 0 );

    /* PSD bits based on binary representation of the ISI vector
       6 = 110;  7 = 111  */
    psd_ctrl &= ~( PSD_ISI1_BIT | PSD_ISI2_BIT );

    setctrl( psd_ctrl, &isi6, 0 );

    return SUCCESS;
}   /* end turnoff_isi6() */

/*
 *  fgre_copyframe2
 *
 *  Type: Function
 *
 *  Description:
 *    Arguments are:
 *      WF_PULSE_ADDR pulse;
 *      LONG frame_control;          -> Copy control flag
 *      LONG pass_src;               -> Pass number  - Source
 *      LONG slice_src;              -> Slice number - Source
 *      LONG echo_src;               -> Echo Number  - Source
 *      LONG view_src;               -> View number  - Source
 *      LONG pass_des;               -> Pass number  - Destination
 *      LONG slice_des;              -> Slice number - Destination
 *      LONG echo_des;               -> Echo Number  - Destination
 *      LONG view_des;               -> View number  - Destination
 *      LONG nframes;                -> Number of frames to copy
 *      TYPDAB_PACKETS acqon_flag;   -> Acquisition on/off
 */
STATUS
fgre_copyframe2( WF_PULSE_ADDR pulse, 
                 LONG frame_control, 
                 LONG pass_src, 
                 LONG slice_src, 
                 LONG echo_src, 
                 LONG view_src, 
                 LONG pass_des, 
                 LONG slice_des, 
                 LONG echo_des, 
                 LONG view_des, 
                 LONG nframes, 
                 TYPDAB_PACKETS acqon_flag )
{
    copyframe( pulse, frame_control, 
               pass_src, slice_src, echo_src, view_src, 
               pass_des, slice_des, echo_des, view_des, 
               nframes, acqon_flag );

    return SUCCESS;
}   /* end fgre_copyframe2() */


/*
 *  fgre_copyframe3
 *
 *  Type: Function
 *
 *  Description:
 *    Unused until converted for CERD 12/19/95 - JDM
 *    Arguments are:
 *      WF_PULSE_ADDR pulse;
 *      LONG frame_control;          -> Copy control flag
 *      LONG pass_src;               -> Pass number  - Source
 *      LONG slice_src;              -> Slice number - Source
 *      LONG echo_src;               -> Echo Number  - Source
 *      LONG view_src;               -> View number  - Source
 *      LONG pass_des;               -> Pass number  - Destination
 *      LONG slice_des;              -> Slice number - Destination
 *      LONG echo_des;               -> Echo Number  - Destination
 *      LONG view_des;               -> View number  - Destination
 *      LONG nframes;                -> Number of frames to copy
 *      TYPDAB_PACKETS acqon_flag;   -> Acquisition on/off
 */
STATUS
fgre_copyframe3( WF_PULSE_ADDR pulse, 
                 LONG frame_control, 
                 LONG pass_src, 
                 LONG slice_src, 
                 LONG echo_src, 
                 LONG view_src, 
                 LONG pass_des, 
                 LONG slice_des, 
                 LONG echo_des, 
                 LONG view_des, 
                 LONG nframes, 
                 TYPDAB_PACKETS acqon_flag )
{
    SHORT dabbits;
    s32  copy_dab_data[10];

    /* Add the parameters to the DAB packet */
    if (DABON == acqon_flag) 
    {
        dabbits = DABDC;
    } else {
        dabbits = 0;
    }

    sspload(&dabbits,
            pulse,
            0,
            1,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);

    copy_dab_data[ 0 ] = frame_control;
    copy_dab_data[ 1 ] = pass_src;
    copy_dab_data[ 2 ] = slice_src;
    copy_dab_data[ 3 ] = echo_src;
    copy_dab_data[ 4 ] = view_src;
    copy_dab_data[ 5 ] = pass_des;
    copy_dab_data[ 6 ] = slice_des;
    copy_dab_data[ 7 ] = echo_des;
    copy_dab_data[ 8 ] = view_des;
    copy_dab_data[ 9 ] = nframes;

    sspextload(copy_dab_data,
               pulse,
               2,
               10,
               (HW_DIRECTION)TOHARDWARE,
               (SSP_S_ATTRIB)SSPS2);

    return SUCCESS;
}   /* end fgre_copyframe3() */


/*
 *  fgre_loaddab_echo1
 *
 *  Type: Function
 *
 *  Description:
 *    This function is an optimization of loaddab where a ctrlmask of
 *    PSD_LOAD_DAB_ALL is assumed.  echo1 is assumed as the pulse.
 *    A more generic optimization of loaddab would include a pulse
 *    parameter to specifiy which DAB packet to load.
 *    Another generic optimization might call sspload instead of
 *    ssploadrsp, but it would be better to do the parameter checking
 *    once during pulsegen rather than in every sequence preparation.
 *    Arguments are:
 *      LONG slice;                 -> Slice number
 *      LONG echo;                  -> Echo Number
 *      LONG oper;                  -> Operation field
 *      LONG view;                  -> View number
 *      TYPDAB_PACKETS acqon_flag;  -> Acquisition on/off
 *      INT load_ctrl;              -> not used
 */
STATUS
fgre_loaddab_echo1( LONG slice, 
                    LONG echo, 
                    LONG oper, 
                    LONG view, 
                    TYPDAB_PACKETS acqon_flag )
{
    SHORT dabbits;
    SHORT rbabits;
    SHORT dabis_data[6];
    LONG  ssp_ix = 0;

    switch( psd_board_type ) {
    case PSDCERD:
    case PSDDVMR:
        ssp_ix = 8;
        break;
    }
    
    if (DABON == acqon_flag)
    {
        dabbits = DABDC;
        rbabits = RDC;
    } else {
        dabbits = 0;
        rbabits = 0;
    }

    /* Add DABON/DABOFF to the DAB packet */
    sspload(&dabbits,
            &echo1,
            0,
            1,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);

    /* RBA pulse is the associated pulse of the XTR pulse which is the */
    /* associated pulse of the DAB pulse which is passed in */
    sspload(&rbabits,
            echo1rba,
            0,
            1,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);

    /* Prepare an array with the 6 new DAB packet bytes. */
    /* Only the lower 8 bits of each array element are used. */
    dabis_data[ 0 ] = (SHORT)( slice >> 8 );
    dabis_data[ 1 ] = (SHORT)slice;
    if ( echo == -1 ) {
        dabis_data[ 2 ] = DABIE;
    } else {
        dabis_data[ 2 ] = (SHORT)echo;
    }

    dabis_data[ 3 ] = (SHORT)oper;
    dabis_data[ 4 ] = (SHORT)( view >> 8 );
    dabis_data[ 5 ] = (SHORT)view;
    
    /* Add the 6 bytes to the DAB packet */
    sspload(dabis_data,
            &echo1,
            ssp_ix,
            6,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);

    return SUCCESS;
}   /* end fgre_loaddab_echo1() */


/* Dual echo support DUALECHO */
STATUS
fgre_loaddab_echo2( LONG slice,
                    LONG echo,
                    LONG oper,
                    LONG view,
                    TYPDAB_PACKETS acqon_flag )
{
    SHORT dabbits;
    SHORT rbabits;
    SHORT dabis_data[6];
    LONG  ssp_ix = 0;
    int i;

    switch( psd_board_type ) {
    case PSDCERD:
    case PSDDVMR:
        ssp_ix = 8;
        break;
    }

    if (DABON == acqon_flag)
    {
        dabbits = DABDC;
        rbabits = RDC;
    } else {
        dabbits = 0;
        rbabits = 0;
    }

    /* MEGE */
    for (i=0; i<(opnecho-1); i++) {
        /* Add DABON/DABOFF to the DAB packet */
        sspload(&dabbits,
                &(readecho[i]),
                0,
                1,
                (HW_DIRECTION)TOHARDWARE,
                (SSP_S_ATTRIB)SSPS1);

        /* RBA pulse is the associated pulse of the XTR pulse which is the */
        /* associated pulse of the DAB pulse which is passed in */
        sspload(&rbabits,
                p_readechorba[i],
                0,
                1,
                (HW_DIRECTION)TOHARDWARE,
                (SSP_S_ATTRIB)SSPS1);

        /* Prepare an array with the 6 new DAB packet bytes. */
        /* Only the lower 8 bits of each array element are used. */
        dabis_data[ 0 ] = (SHORT)( slice >> 8 );
        dabis_data[ 1 ] = (SHORT)slice;
        if ( (echo + i) == -1 ) {
            dabis_data[ 2 ] = DABIE;
        } else {
            if (PSD_OFF == pos_read)
                dabis_data[ 2 ] = (SHORT)(echo + i);
            else
                dabis_data[ 2 ] = (SHORT)(echo + i*intte_flag);
        }

        dabis_data[ 3 ] = (SHORT)oper;
        dabis_data[ 4 ] = (SHORT)( view >> 8 );
        dabis_data[ 5 ] = (SHORT)view;

        /* Add the 6 bytes to the DAB packet */
        sspload(dabis_data,
                &(readecho[i]),
                ssp_ix,
                6,
                (HW_DIRECTION)TOHARDWARE,
                (SSP_S_ATTRIB)SSPS1);

    }
    return SUCCESS;
}   /* end fgre_loaddab_echo2() */


/*
 *  settriggerarray_dmy
 *
 *  Type: Function
 *
 *  Description:
 *    ???
 */
STATUS
settriggerarray_dmy( INT number_of_triggers, 
                     LONG *trigger_array )
{
    INT i;

    printf( "settriggerarray( %04X, ", (UINT)number_of_triggers );
    printf( "*%08X )\n", (LONG)trigger_array );
    for ( i = 0 ; i < number_of_triggers ; i++ ) {
        printf( "  trigger[%d]=%ld\n", i, (long)trigger_array[i] );
    }

    return SUCCESS;
}   /* end settriggerarray_dmy() */


/*
 *  fgre_copyframe
 *
 *  Type: Function
 *
 *  Description:
 *    FIX for MRIge35761 and MRIge36249:
 *    The original view copy packet was 8 words and this had to be
 *    reduced to 7 words to give enough time for CERD to process the data.
 *
 *
 *   ORIGINAL VIEW COPY PKT             NEW VIEW COPY PKT
 *
 *  |------------------------|         |-------------------------------------| 
 *  | Device    | opcode     |         | Device        | opcode              |
 *  |-----------|------------|         |---------------|---------------------|
 *  | Copy Ctrl | Copy #     |         | Copy Ctrl     | Copy #              |
 *  |-----------|------------|         |---------------|---------------------|
 *  |     Pass Source        |         | Pass Src      | Pass Dest           |
 *  |------------------------|         |---------------|---------------------|
 *  |     Pass Dest          |         | Slice Src     | Slice Dest          |
 *  |------------------------|         |---------------|---------------------|
 *  | Slice Src | Slice Dest |         |PS |PD |SS |SD | Echo Src | Echo Des |
 *  |-----------|------------|         |---------------|---------------------|
 *  | Echo Src  | Echo Dest  |         |          View Source                |
 *  |-----------|------------|         |-------------------------------------|
 *  |     View Source        |         |          View Destination           |
 *  |------------------------|         |-------------------------------------|
 *  |     View Dest          |
 *  |------------------------|
 *
 *    The limitation with this change is that we cannot use more
 *    than 16 echoes. Tom Foo was informed about this and he agreed for this.
 *    Arguments are:
 *      WF_PULSE_ADDR pulse;
 *      LONG frame_control;          -> Copy control flag
 *      LONG pass_src;               -> Pass number  - Source
 *      LONG slice_src;              -> Slice number - Source
 *      LONG echo_src;               -> Echo Number  - Source
 *      LONG view_src;               -> View number  - Source
 *      LONG pass_des;               -> Pass number  - Destination
 *      LONG slice_des;              -> Slice number - Destination
 *      LONG echo_des;               -> Echo Number  - Destination
 *      LONG view_des;               -> View number  - Destination
 *      LONG nframes;                -> Number of frames to copy
 *      TYPDAB_PACKETS acqon_flag;   -> Acquisition on/off
 */
STATUS
fgre_copyframe( WF_PULSE_ADDR pulse, 
                LONG frame_control, 
                LONG pass_src, 
                LONG slice_src, 
                LONG echo_src, 
                LONG view_src, 
                LONG pass_des, 
                LONG slice_des, 
                LONG echo_des, 
                LONG view_des, 
                LONG nframes, 
                TYPDAB_PACKETS acqon_flag )
{
    SHORT dabbits;
    s16 copy_dab_data[12];

    /* Add the parameters to the DAB packet */
    if (DABON == acqon_flag)
    {
        dabbits = DABDC;
    } else {
        dabbits = 0;
    }

    sspload(&dabbits,
            pulse,
            0,
            1,
            (HW_DIRECTION)TOHARDWARE, 
            (SSP_S_ATTRIB)SSPS1);

    copy_dab_data[  0 ] = frame_control;
    copy_dab_data[  1 ] = nframes;

    copy_dab_data[  2 ] = pass_src;
    copy_dab_data[  3 ] = pass_des;

    copy_dab_data[  4 ] = slice_src;
    copy_dab_data[  5 ] = slice_des;

    copy_dab_data[  6 ] = (slice_des  >> 8) +
        ((slice_src >> 8) << 2) +
        ((pass_des  >> 8) << 4) +
        ((pass_src  >> 8) << 6);
    
    copy_dab_data[  7 ] = (echo_src << 4) + echo_des;

    copy_dab_data[  8 ] = view_src >> 8;
    copy_dab_data[  9 ] = view_src;

    copy_dab_data[ 10 ] = view_des >> 8;
    copy_dab_data[ 11 ] = view_des;

    sspload(copy_dab_data,
            pulse,
            2,
            12,
            (HW_DIRECTION)TOHARDWARE,
            (SSP_S_ATTRIB)SSPS1);
    
    return SUCCESS;

}   /* end fgre_copyframe() */

void dummylinks( void )
{
    epic_loadcvs("theFile");
}

/* SVBranch HCSDM00115164: support SBM for FIESTA */
/* wait until heat sink */
STATUS runSbmWait(INT period)
{
    boffset(off_seqsbmwait);
    setperiod(period, &seqsbmwait, 0);
    startseq( (SHORT)0, (SHORT)MAY_PAUSE );
    offset_to_seqcore();
    return SUCCESS;
}

/* get amplitude of gx1 */
STATUS get_gx1_amp( INT *gx1_val, LONG waveform_index)
{
    SHORT tmp_amp;

    getiamp(&tmp_amp, &gx1, waveform_index);
    *gx1_val = (INT)tmp_amp;
    return SUCCESS;
}

/* get amplitude of gxw */
STATUS get_gxw_amp( INT *gxw_val, LONG waveform_index)
{
    SHORT tmp_amp;

    getiamp(&tmp_amp, &gxw, waveform_index);
    *gxw_val = (INT)tmp_amp;
    return SUCCESS;
}

/* get amplitude of gxwex */
STATUS get_gxwex_amp( INT *gxwex_val, LONG waveform_index)
{
    SHORT tmp_amp;

    getiamp(&tmp_amp, &gxwex, waveform_index);
    *gxwex_val = (INT)tmp_amp;
    return SUCCESS;
}

/************************ END OF FGRE.E ******************************/

