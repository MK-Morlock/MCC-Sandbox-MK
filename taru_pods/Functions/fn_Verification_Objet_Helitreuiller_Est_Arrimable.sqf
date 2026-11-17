private _vehicule = param [0,objnull];

private _objet_Est_Arrimable = true;
private _liste_isKindOf = ["Pod_Heli_Transport_04_crewed_base_F","Pod_Heli_Transport_04_base_F","Cargo_base_F","Slingload_01_Base_F"];


_objet_Helitreuiller_Nest_Pas_Du_Type_Arrimable = count (_liste_isKindOf select {getSlingLoad _vehicule iskindof _x}) isEqualTo 0;
_objet_Helitreuiller_Est_Arrimer = !isnull (attachedTo getSlingLoad _vehicule);

if (_objet_Helitreuiller_Nest_Pas_Du_Type_Arrimable OR {_objet_Helitreuiller_Est_Arrimer}) then {_objet_Est_Arrimable = false;};

_objet_Est_Arrimable