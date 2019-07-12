# eyetrackercalibration
Eyetracker calibration on Friday 12 July 2019 (SIJIA ZHAO)

* PROCEDURE: A 30-second-resting block was conducted on a subject (i.e. Alice) wearing a pair of black dot stickers at her eye positions. The diameter of the black dot was 5mm. (The subject wore a pair of glasses whose lenses were covered by white sticker (to avoid reflection), and then placed one black dot sticker for each side. This set up was used to ensure the dots were placed in the position/level of real eyes and the surface of the dots was parallel to the screen.)

If you track a black dot (rather than an artificial pupil), you'll have to use a pupil-only mode. You can add the following commands to your FINAL.INI file in the "ELCL\EXE" directory of the EyeLink Host computer. This will allow you to select “Pupil Only” mode on the Camera Setup screen so that the system will track this black dot (without a CR):

Code:
#####################################################
 
## force_corneal_reflection = <Value>
;; Hides "Pupil" mode button on Camera Setup screen
;; Pupil Only mode should only be used in EyeLink 1000 when
participants head is completely fixed.
;; Default Value: OFF
force_corneal_reflection OFF
 
## allow_pupil_without_cr = <switch>
;; Allows pupil without a CR nearby to be detected
;; in pupil search (after pupil loss or on startup).
;; This command is overridden in P-CR mode.
allow_pupil_without_cr = ON
 
## elcl_hold_if_no_corneal = <switch>
;; If true, eye window is frozen until both pupil and CR are
present.
;; Default Value: OFF
elcl_hold_if_no_corneal = OFF
 
## elcl_search_if_no_corneal = <switch>
;; If corneal missing for long period, assumes false target and
searches for pupil/CR candidate.
;; Default Value: OFF
elcl_search_if_no_corneal = OFF
 
## elcl_use_pcr_matching = <switch>
;; Selects enhanced pupil-CR matching during pupil identification.
;; If used, pupil and CR are selected as best matching pair.
;; This can be used even if CR is not being used for tracking.
;; Default Value: ON
elcl_use_pcr_matching = OFF
#####################################################


* MEASUREMENT:An infrared eye-tracking camera (Eyelink 1000 Desktop Mount, SR Research Ltd.) was positioned at a horizontal distance of 55 cm away from the participant. No calibration was conducted. During the experiment, the eye-tracker continuously tracked gaze position and recorded pupil diameter, focusing binocularly at a sampling rate of 250 Hz (note: normally we use 1000Hz, 250Hz was a mistake. But, since it doesn't affect our calibration result, I didn't re-run the blocks).

Say if you use diameter. You know that the black dot has a diameter of 5mm. The eye tracker reports 4500 arbitary units at the 55cm distance. If you put a real eye in the chinrest at the same distance as the black dot was in your recording, and the eye tracker reports a diameter of 6750 then you can take the eye data to correspond to about 7.5mm. (because 4500/5 = 6750/x).

* RESULT: I computed the median value across the 30 seconds for each side, and computed the conversion rate .
If the pupil size measurement is diameter,  1mm = 905.4(left eye), 820.4(right eye). (<-- DEFAULT)
If the pupil size measurement is area, 1mm2 = 198.2(left eye), 161.2(right eye).


