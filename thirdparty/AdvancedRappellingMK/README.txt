ADVANCED RAPPELLING MK
A corrected version of Advanced Rappelling by Seth Duda ([SA] Duda), MIT licence (LICENSE.txt).
Use it INSTEAD of the original - not together with it. It is also built into MCC Sandbox MK.

Use: as the original - in a helicopter 5 to 55 m up: "Rappel Self" (hold your move-back key to descend, turbo for
faster), "Rappel AI Units" (squad leader), "Detach Rappel Device". Script: [helicopter, height, positionASL] call
ARMK_Rappel_All_Cargo; [unit, helicopter] call ARMK_Rappel_From_Heli. Function and variable names start with ARMK_,
so they never clash with the original's; the original's mission settings (AR_SUPPORTED_VEHICLES_OVERRIDE,
AR_MAX_RAPPEL_POINTS_OVERRIDE, AR_DISABLE_SHOOTING_OVERRIDE, AP_CUSTOM_RAPPEL_POINTS) still apply.

WHAT IS CORRECTED
Config
 1. Loaded after all of Arma's data. The original could be read before Arma's animations and corrupt the standing,
    weapon-raised stance: AI that twitch, can't raise their weapons and fire into the ground.
 2. Arma's own seat poses are no longer redefined; the rope poses use their own classes.
Safety
 3. Not offered above 55 m (60 m of rope): a man came off the end of the rope and fell.
 4. The helicopter lost mid-rappel: the man comes off the rope there (he was snapped to the corner of the map).
 5. Damage is put back as it was (it was always switched on, even for a man the mission had made invulnerable).
 6. He starts at the rope point (it was up to 2 m off to a random side).
Getting stuck
 7. Units are never frozen on the machine that owns them, and simulation is always restored (frozen AI).
 8. Time limits on every wait: a man who can't leave his seat no longer blocks a rope point for good.
 9. An unconscious player is lowered by itself; helpers and ropes left by a cut-short rappel are removed.
10. ARMK_Rappel_All_Cargo: time limits throughout - it could wait for ever, holding the helicopter in place.
11. "This helicopter has no rappel points" when that is the case (it said all anchors were in use).
Behaviour
12. No missiles hanging in the air: the hidden helper (a launcher) is emptied and locked.
13. Men are un-assigned from the helicopter when they rappel (they went back to it on their next order).
14. Who goes down is decided by whose men they are, not their seat: "Rappel AI Units" sends all your squad's AI aboard
    except whoever is flying; ARMK_Rappel_All_Cargo leaves a man in a crew seat aboard unless his squad has men in the
    back. Players may still rappel themselves from any seat but the pilot's with the engine running.
18. "Rappel AI Units" with more than 6 men aboard: a helicopter has 6 rope points at most, and the men who found them
    all taken were skipped and left aboard. They now wait for a point to come free and go then.
Multiplayer
15. Every machine installs it from its own copy (the original broadcast its code from the server, which servers that
    restrict remote execution block); its functions are declared for remote execution.
Smaller
16. The descent keys are whatever is bound to "move back" and "turbo".
17. The descent runs once a frame (smoother when the mission is busy).

SIGNING: addons\ARMK_AdvancedRappelling.pbo is unsigned - sign it with your own key.
