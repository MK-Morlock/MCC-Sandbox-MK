/*
 ANC_fnc_isZodiac
 - the Zodiac-type Assault Boat (B_/O_/I_..._Boat_Transport_01_F and variants).
*/
params [["_v", objNull, [objNull]]];
!isNull _v && {((toLower typeOf _v) find "boat_transport_01") != -1}
