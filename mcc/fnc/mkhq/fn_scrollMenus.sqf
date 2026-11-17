/*
	MCCMK_fnc_scrollMenus - do MCC MK's own actions go on the scroll menu? Yes without ACE, and with "MCC actions with ACE"
	set to "Scroll menu only" or "ACE menu and scroll menu". Read at mission start.
*/
(call MCCMK_fnc_aceMode) in [0, 1]
