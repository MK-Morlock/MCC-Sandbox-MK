params [["_w", objNull, [objNull]], ["_on", true, [true]]];
if (isNull _w || {!alive _w}) exitWith {};
_w setVehicleRadar ([2, 1] select _on);
_w setVehicleReportRemoteTargets _on;
_w setVehicleReceiveRemoteTargets _on;
_w setVehicleReportOwnPosition _on;
