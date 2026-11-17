// (MK) BOAT CARRIERS ON THE WATER: how deep each can sit before Arma drowns its engine (maxFordingDepth, metres) raised to
// 3 m - a boat pressing on the lowered ramp pushed a floating Huron 1.3 m deeper than its 1 m: the engine cut out, filled
// with water damage (waterDamageEngine 0.2 a second) and the AI crew left it. Only the families Floatary lets carry a
// boat (the Huron, Taru, Mohawk, and the Blackfish and Xi'an transports - not the Blackfish gunship, not any other
// helicopter); each set its own value, so the change is made on each family's own class (Arma's own values: Huron 1,
// Taru 1.4, Mohawk 1.65; Blackfish and Xi'an none of their own - 0.001 from "Air"). waterDamageEngine is not changed:
// really under, an engine still drowns. A mod's variant of these families gets it too unless it sets its own value.
class Helicopter_Base_H;
class Heli_Transport_02_base_F: Helicopter_Base_H {maxFordingDepth = 3;};	// Mohawk
class Heli_Transport_03_base_F: Helicopter_Base_H {maxFordingDepth = 3;};	// Huron
class Heli_Transport_04_base_F: Helicopter_Base_H {maxFordingDepth = 3;};	// Taru
class VTOL_01_base_F;
class VTOL_01_unarmed_base_F: VTOL_01_base_F {maxFordingDepth = 3;};	// Blackfish (infantry, vehicle - not the gunship)
class VTOL_Base_F;
class VTOL_02_base_F: VTOL_Base_F {maxFordingDepth = 3;};	// Xi'an (infantry, vehicle)
