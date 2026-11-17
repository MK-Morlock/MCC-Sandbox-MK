params [["_t", 0, [0]]];
switch (_t) do {
	case 0: {[
		["B_Ship_MRLS_01_F", [0.09, -62.51], 180],
		["B_Ship_Gun_01_F", [0.39, -78.39], 180],
		["B_SAM_System_02_F", [0.36, 50.52], 180],
		["B_AAA_System_01_F", [0.02, -48], 180],
		["B_AAA_System_01_F", [0.39, 36.05], 0]
	]};
	case 1: {[
		["B_SAM_System_02_F", [30, 175], 0],
		["B_SAM_System_02_F", [-40, 179], 0],
		["B_SAM_System_02_F", [-30, -100], 0],
		["B_AAA_System_01_F", [-30, -105], 0],
		["B_AAA_System_01_F", [25, -115], 0]
	]};
	case 3: {[
		["B_AAA_System_01_F", [-8.4, -21.3], 0],
		["B_AAA_System_01_F", [13.6, 123.8], 180],
		["B_SAM_System_02_F", [-12.1, -33.6], 0],
		["B_SAM_System_02_F", [0, 123], 1],
		["B_SAM_System_01_F", [-12.1, -41.1], 0],
		["B_SAM_System_01_F", [-13.6, 124.2], 0]
	]};
	default {[]};
}
