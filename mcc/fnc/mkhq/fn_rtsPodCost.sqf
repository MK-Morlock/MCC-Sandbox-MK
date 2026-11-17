// (MK) Taru pods placed in the RTS base: [kind] -> [[label, [[resource, amount], ...]]] - as calling the pod by airdrop,
// less the Taru's delivery fuel. Resources: ammo, repair (Supply), fuel, food, med.
params [["_kind", "box", [""]]];
switch (_kind) do {
	case "medevac": {["Medical", [["med", 75], ["repair", 50]]]};
	case "repair": {["Repair", [["repair", 200]]]};
	case "ammo": {["Ammunition", [["ammo", 200]]]};
	case "fuel": {["Fuel", [["fuel", 200]]]};
	case "bench": {["Bench (8 seats)", [["repair", 100]]]};
	case "covered": {["Transport (16 seats)", [["repair", 200]]]};
	default {["Logistics", [["repair", 150]]]};
}
