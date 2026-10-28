// Keywords are matched case-insensitively against each objects model file name and class (MCC_fnc_survivalObjectType).
// The second half of each list covers CUP / Arma 2 style terrain objects (GitHub #48). A mission can override all of this
// with its own CfgMCCspawnObjects in description.ext. Tip: with MCC debug on, searching copies the objects name to the clipboard.
class CfgMCCspawnObjects {
	class MCC_barrels {
		itemClasses[] = {"garbagebarrel","garbagebin","toiletbox","garbagecontainer","fieldtoilet","tabledesk","cashdesk","popelnice","kontejner","garbage_can","garbage_container","trashcan","trash_bin","dumpster","misc_toilet","toilet_box"};
		chanceWeapon = 5;
		maxWeapon = 1;
		chanceAmmo = 20;
		maxAmmo = 2;
		chanceMed = 10;
		maxMed = 2;
		chanceFuel = 10;
		maxFuel = 2;
		chanceRepair = 20;
		maxRepair = 2;
		chanceFood = 20;
		maxFood = 2;
		chanceMoney = 15;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_grave {
		itemClasses[] = {"grave_forest","grave_dirt","grave_rocks","grave","hrob"};
		chanceWeapon = 15;
		maxWeapon = 1;
		chanceAmmo = 20;
		maxAmmo = 6;
		chanceMed = 10;
		maxMed = 2;
		chanceFuel = 10;
		maxFuel = 2;
		chanceRepair = 10;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 15;
		maxMoney = 5;
		chanceFruit = 1;
		maxFruit = 1;
	};

	class MCC_containers {
		itemClasses[] = {"woodenbox","barreltrash","metalbarrel_f","cratesplastic","cargo20","cargo40","crates","misc_cargo","cargo_cont","barels","barel1","barel2","barel3","barel4","barel5","barel6","barel7","barel8","paleta","bedna","misc_crate","crate_"};
		chanceWeapon = 10;
		maxWeapon = 1;
		chanceAmmo = 20;
		maxAmmo = 2;
		chanceMed = 10;
		maxMed = 2;
		chanceFuel = 10;
		maxFuel = 2;
		chanceRepair = 30;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 15;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_food {
		itemClasses[] = {"icebox","rack","shelves","sacks_goods","basket","sack_f","regal","shelf","market_stall","stand_","misc_sacks","sacks","lednice","fridge"};
		chanceWeapon = 5;
		maxWeapon = 1;
		chanceAmmo = 10;
		maxAmmo = 2;
		chanceMed = 5;
		maxMed = 2;
		chanceFuel = 5;
		maxFuel = 2;
		chanceRepair = 10;
		maxRepair = 2;
		chanceFood = 60;
		maxFood = 6;
		chanceMoney = 5;
		maxMoney = 10;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_fuel {
		itemClasses[] = {"watertank","waterbarrel","barrelwater","stallwater","water_tank","misc_watertank","studna","pumpa","misc_well"};
		chanceWeapon = 5;
		maxWeapon = 1;
		chanceAmmo = 10;
		maxAmmo = 2;
		chanceMed = 5;
		maxMed = 2;
		chanceFuel = 50;
		maxFuel = 2;
		chanceRepair = 10;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 5;
		maxMoney = 10;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_plantsFruit {
		itemClasses[] = {"neriumo","ficusc"};
		chanceWeapon = 1;
		maxWeapon = 1;
		chanceAmmo = 2;
		maxAmmo = 1;
		chanceMed = 3;
		maxMed = 1;
		chanceFuel = 3;
		maxFuel = 1;
		chanceRepair = 3;
		maxRepair = 1;
		chanceFood = 3;
		maxFood = 1;
		chanceMoney = 3;
		maxMoney = 3;
		chanceFruit = 50;
		maxFruit = 2;
	};

	class MCC_misc {
		itemClasses[] = {"fishinggear","crabcages","rowboat","calvary","pipes_small","woodpile","pallets_stack","wheelcart","misc_boat","lodka","fishing","misc_woodpile","drevo_hromada","misc_pipes","cart_"};
		chanceWeapon = 5;
		maxWeapon = 1;
		chanceAmmo = 10;
		maxAmmo = 2;
		chanceMed = 10;
		maxMed = 2;
		chanceFuel = 10;
		maxFuel = 2;
		chanceRepair = 20;
		maxRepair = 2;
		chanceFood = 20;
		maxFood = 2;
		chanceMoney = 5;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_garbage {
		itemClasses[] = {"garbagebags","junkpile","garbagepallet","tyres","garbagewashingmachine","scrapheap","garbage","junk","smetiste","misc_tyres","pneu","scrap","misc_rubble"};
		chanceWeapon = 5;
		maxWeapon = 1;
		chanceAmmo = 20;
		maxAmmo = 2;
		chanceMed = 10;
		maxMed = 2;
		chanceFuel = 10;
		maxFuel = 2;
		chanceRepair = 30;
		maxRepair = 2;
		chanceFood = 20;
		maxFood = 2;
		chanceMoney = 15;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_wreck {
		itemClasses[] = {"wreck_car","wreck_truck","wreck_offroad","wreck_van","skodawreck","datsun01wreck","datsun02wreck","hiluxwreck","ladawreck","volhawreck","carwreck","car_wreck","bus_wreck","tractorwreck","hatchback_wreck","sedan_wreck"};
		chanceWeapon = 10;
		maxWeapon = 1;
		chanceAmmo = 20;
		maxAmmo = 2;
		chanceMed = 20;
		maxMed = 2;
		chanceFuel = 40;
		maxFuel = 2;
		chanceRepair = 30;
		maxRepair = 2;
		chanceFood = 20;
		maxFood = 2;
		chanceMoney = 15;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_wreckMil {
		itemClasses[] = {"wreck_ural","wreck_uaz","wreck_hmmwv","wreck_heli","wreck_hunter","wreck_brdm","wreck_bmp","wreck_t72_hull","wreck_slammer","uazwreck","uralwreck","bmp2wreck","t72wreck","hmmwvwreck","mi8wreck","uh1ywreck","uh60wreck","brdmwreck","btrwreck","m113wreck","bradleywreck","t72_wreck","bmp_wreck","heli_wreck"};
		chanceWeapon = 30;
		maxWeapon = 2;
		chanceAmmo = 40;
		maxAmmo = 10;
		chanceMed = 20;
		maxMed = 2;
		chanceFuel = 20;
		maxFuel = 2;
		chanceRepair = 20;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 5;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_wreckSub {
		itemClasses[] = {"uwreck"};
		chanceWeapon = 30;
		maxWeapon = 3;
		chanceAmmo = 50;
		maxAmmo = 10;
		chanceMed = 20;
		maxMed = 2;
		chanceFuel = 20;
		maxFuel = 2;
		chanceRepair = 20;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 5;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};

	class MCC_ammoBox {
		itemClasses[] = {"woodenbox","luggageheap","pallet_milboxes_f","case","suitcase","kufr","luggage"};
		chanceWeapon = 30;
		maxWeapon = 3;
		chanceAmmo = 50;
		maxAmmo = 10;
		chanceMed = 20;
		maxMed = 2;
		chanceFuel = 20;
		maxFuel = 2;
		chanceRepair = 20;
		maxRepair = 2;
		chanceFood = 10;
		maxFood = 2;
		chanceMoney = 5;
		maxMoney = 5;
		chanceFruit = 0;
		maxFruit = 0;
	};
};