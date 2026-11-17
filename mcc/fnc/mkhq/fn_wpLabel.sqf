params [["_t", "", [""]]];
switch (true) do {
	case ((_t find "Water landing") == 0): {"WATER LANDING"};
	case ((_t find "Boat drop") == 0): {"BOAT DROP"};
	case (_t == "Boat load"): {"LOAD BOAT"};
	default {toUpper _t};
}
