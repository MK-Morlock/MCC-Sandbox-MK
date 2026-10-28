private _h = [1] execVM format ["%1mcc\pop_menu\spawn_group3d.sqf", MCC_path];
waitUntil {scriptDone _h};
closeDialog 0;
