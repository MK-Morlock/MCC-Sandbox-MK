/*
	MCCMK_fnc_aceMenus - do MCC MK's own actions go in the ACE menu? Yes with ACE loaded and "MCC actions with ACE" set to
	"ACE menu only" (the default) or "ACE menu and scroll menu" - directly at the top level. (MCCMK_fnc_scrollMenus: the
	scroll menu.) The original MCC's interactions aren't affected (ACE with ACE, MCC's interaction key menu without).
	Read at mission start.
*/
(call MCCMK_fnc_aceMode) in [0, 2]
