//General
missionNameSpace setVariable ["MCC_syncOn",true];
missionNameSpace setVariable ["MCC_teleportToTeam",false];
missionNameSpace setVariable ["MCC_saveGear",false];
missionNameSpace setVariable ["MCC_Chat",false];
missionNameSpace setVariable ["MCC_deletePlayersBody",false];
missionNameSpace setVariable ["MCC_allowlogistics",true];
missionNameSpace setVariable ["MCC_allowRTS",false];				//Just for test disable later

//Role selection
missionNameSpace setVariable ["CP_activated",true];
missionNameSpace setVariable ["MCC_allowChangingKits",true];

//Mechanics
missionNameSpace setVariable ["MCC_cover",true];
missionNameSpace setVariable ["MCC_changeRecoil",true];
missionNameSpace setVariable ["MCC_coverUI",true];
missionNameSpace setVariable ["MCC_coverVault",true];
missionNameSpace setVariable ["MCC_interaction",true];
missionNameSpace setVariable ["MCC_ingameUI",true];
missionNameSpace setVariable ["MCC_quickWeaponChange",false];
missionNameSpace setVariable ["MCC_surviveMod",false];
missionNameSpace setVariable ["MCC_showActionKey",true];
missionNamespace setVariable ["MCC_allowSQLRallyPoint",true];

//Medical
missionNameSpace setVariable ["MCC_medicXPmesseges",true];
missionNameSpace setVariable ["MCC_medicPunishTK",true];

//Rspawn
missionNameSpace setVariable ["MCC_respawnOnGroupLeader",(paramsArray select 4) ==1];

//Radio
if ((paramsArray select 2) ==1) then {
	missionNameSpace setVariable ["MCC_VonRadio",true];
	missionNameSpace setVariable ["MCC_vonRadioDistanceGlobal",200000];
	missionNameSpace setVariable ["MCC_vonRadioDistanceSide",10000];
	missionNameSpace setVariable ["MCC_vonRadioDistanceCommander",10000];
	missionNameSpace setVariable ["MCC_vonRadioDistanceGroup",1000];
	missionNameSpace setVariable ["MCC_vonRadioKickIdle",true];
	missionNameSpace setVariable ["MCC_vonRadioKickIdleTime",15];
} else {
	missionNameSpace setVariable ["MCC_VonRadio",false];
};

//artillery
enableEngineArtillery false;
HW_arti_types = [["HE Laser-guided","Bo_GBU12_LGB",3,50],["HE 82mm","Sh_82mm_AMOS",1,75]];

//Spawn UI
_null = [1,true,true,true,true,true,true] spawn MCC_fnc_inGameUI;

if (isServer || isDedicated) then {
	0 spawn {
		private ["_side1","_side2","_header","_costsTable","_varName"];
		_side1 = west;
		_side2 = east;

		waitUntil {time > 0};
		//Tickets
		[_side1, 200] call BIS_fnc_respawnTickets;
		[_side2, 200] call BIS_fnc_respawnTickets;

		//Resources
		missionNamespace setVariable ["MCC_resWest",[300,300,300,0,0]];
		missionNamespace setVariable ["MCC_resEast",[300,300,300,0,0]];
		missionNamespace setVariable ["MCC_resGUER",[300,300,300,0,0]];
		publicVariable "MCC_resWest";
		publicVariable "MCC_resEast";
		publicVariable "MCC_resGUER";

		//Random Weather
		private ["_weather"];
		_weather = (["Random","clear","cloudy","rain","storm","sandStorm","snow"]) select (["param_weather", 0] call BIS_fnc_getParamValue);

		if (_weather == "Random") then {
			_weather = [["clear","cloudy","rain","storm","sandStorm","snow"],[0.4,0.15,0.15,0.15,0.075,0.075]] call bis_fnc_selectRandomWeighted;
		};

		switch (_weather) do {
		    case "clear": {
		    	[[(random 0.2), (random 0.2), (random 0.2), 0, 0,(random 0.1),0]] spawn MCC_fnc_setWeather;
		    };

		    case "cloudy": {
		    	[[0.4 + (random 0.2), 0.4 +(random 0.2), 0.4 +(random 0.2), 0.4 +(random 0.2), 0.4 +(random 0.2),0 +(random 0.2),0]] spawn MCC_fnc_setWeather;
		    };

		    case "rain": {
		    	[[0.6 + (random 0.2), 0.6 +(random 0.2), 0.6 +(random 0.2), 0.6 +(random 0.2), 0.6 +(random 0.2),0.1 +(random 0.2),0]] spawn MCC_fnc_setWeather;
		    };

		    case "storm": {
		    	[[0.8 + (random 0.2), 0.8 +(random 0.2), 0.8 +(random 0.2), 0.8 +(random 0.2), 0.8 +(random 0.2),0.3 +(random 0.2),0]] spawn MCC_fnc_setWeather;
		    };

		    case "sandStorm": {
		    	[["sandstorm",false],"MCC_fnc_ppEffects",true,false] call BIS_fnc_MP;
		    };

		    case "snow": {
		    	[["snow",false],"MCC_fnc_ppEffects",true,false] call BIS_fnc_MP;
		    };
		};

		//Random Time
		private ["_time"];
		_time = ([-1,6,12,18,0]) select (["param_daytime", 0] call BIS_fnc_getParamValue);

		if (_time < 0) then {
			_time = [[6,12,18,0],[0.25,0.25,0.25,0.25]] call bis_fnc_selectRandomWeighted;
		};

		//Start AAS
		[[s1,s2,s3,s4,s5],[_side1,_side2],1] call MCC_fnc_aasInit;

		//Delete bodies
		[240] spawn MCC_fnc_deleteBodies;


		_time spawn BIS_fnc_paramDaytime;


		//Start AI behavior
		switch (paramsArray select 3) do {
			//east
		    case 1: {
		    	[_side2] spawn MCC_fnc_aas_AIControl;
		    	[_side2, _side1, true, 15, true, "OPF_F",300,["at","ar","corpsman","rifleman"], position hq_side2] spawn MCC_fnc_aas_AIspawn;
		    };

		    //west
		    case 2: {
		    	[_side1] spawn MCC_fnc_aas_AIControl;
		    	[_side1, _side2, true, 15, true, "BLU_F",300,["at","ar","corpsman","rifleman"], position hq_side1] spawn MCC_fnc_aas_AIspawn;
		    };

		    //both
		    case 3: {
		    	{[_x] spawn MCC_fnc_aas_AIControl} foreach [_side1,_side2];

				//Start AI spawn
				[_side1, _side2, true, 15, true, "BLU_F",300,["at","ar","corpsman","rifleman"],position hq_side1] spawn MCC_fnc_aas_AIspawn;
				[_side2, _side1, true, 15, true, "OPF_F",300,["at","ar","corpsman","rifleman"], position hq_side2] spawn MCC_fnc_aas_AIspawn;
		    };
		};


		//===============CAS =======================

		//Blufor
		_varName = format ["MCC_CASConsoleArray%1",_side1];
		missionNamespace setVariable [_varName,[[["Gun-run (Zeus)"],["B_Plane_CAS_01_F"]],
									 			[["Rockets-run (Zeus)"],["B_Plane_CAS_01_F"]],
									 			[["UAV"],["B_UAV_01_F"]],
									 			[["UAV Armed"],["B_UAV_02_F"]],
									 			[["Cruise Missile"],[""]],
									 			[["AC-130"],[""]]]];

		//Opfor
		_varName = format ["MCC_CASConsoleArray%1",_side2];
		missionNamespace setVariable [_varName,[[["Gun-run (Zeus)"],["O_Plane_CAS_02_F"]],
									 			[["Rockets-run (Zeus)"],["O_Plane_CAS_02_F"]],
									 			[["UAV"],["O_UAV_01_F"]],
									 			[["UAV Armed"],["O_UAV_02_F"]],
									 			[["Cruise Missile"],[""]],
									 			[["AC-130"],[""]]]];

		publicVariable _varName;

		{
			_costsTable = [[["ammo",100]],
			               [["ammo",200]],
			               [["ammo",150],["repair",150]],
			               [["ammo",300],["repair",300]],
			               [["ammo",300]],
			               [["ammo",600],["repair",600]]
				              ];

			_varName = format ["MCC_CASConsoleArray%1",_x];
			{
				missionNamespace setVariable [str _x, _costsTable select _foreachindex];
				publicVariable str _x;
			} forEach (missionNamespace getVariable _varName);
		} forEach [_side1,_side2];

		//===============Airdrops =======================


		//Blufor
		_varName = format ["MCC_ConsoleAirdropArray%1",_side1];
		missionNamespace setVariable [_varName,[[[["B_G_Offroad_01_armed_F"]],[""],2],
												[[["B_UGV_01_rcws_F"]],[""],3],
									 		   [[["Box_NATO_AmmoVeh_F"]],[""],2],
									 		   [[["CargoNet_01_box_F"]],[""],2],
									 		   [[["CargoNet_01_barrels_F"]],[""],2]]];
		publicVariable _varName;

		//Opfor
		_varName = format ["MCC_ConsoleAirdropArray%1",_side2];
		missionNamespace setVariable [_varName,[[[["O_G_Offroad_01_armed_F"]],[""],2],
											   [[["O_UGV_01_rcws_F"]],[""],3],
									 		   [[["Box_NATO_AmmoVeh_F"]],[""],2],
									 		   [[["CargoNet_01_box_F"]],[""],2],
									 		   [[["CargoNet_01_barrels_F"]],[""],2]]];
		publicVariable _varName;

		{
			_costsTable = [[["ammo",200],["repair",150]],
							[["ammo",500],["repair",500]],
			               [["ammo",150]],
			               [["repair",150]],
			               [["fuel",150]]];

			{
				missionNamespace setVariable [str _x, _costsTable select _foreachindex];
				publicVariable str _x;
			} forEach (missionNamespace getVariable _varName);

		} forEach [_side1,_side2];
	};
};


if (!isDedicated && hasInterface) then {
	waituntil {!(IsNull (findDisplay 46))};
	cutText ["","BLACK OUT",0.1];
	sleep 1;

	/*
	//Setup quick weapons
	if (missionNamespace getVariable ["MCC_isCBA",false]) then {
		//Switch weapon 1 - Primary/handgun
		["MCC", "switchWeapon1", ["Switch Weapons 1: Primary/handgun", ""], {if ((player getVariable ["cpReady",true]) && !(player getvariable ["MCC_medicUnconscious",false]) && (missionNamespace getvariable ["MCC_quickWeaponChange",false])) then {[2] spawn MCC_fnc_weaponSelect;true}}, {}, [2, [false,false,false]],false] call cba_fnc_addKeybind;

		//Switch weapon 2 - Launcher
		["MCC", "switchWeapon2", ["Switch Weapons 2: Launcher", ""], {if ((player getVariable ["cpReady",true]) && !(player getvariable ["MCC_medicUnconscious",false]) && (missionNamespace getvariable ["MCC_quickWeaponChange",false])) then {[3] spawn MCC_fnc_weaponSelect;true}}, {}, [3, [false,false,false]],false] call cba_fnc_addKeybind;

		//Switch weapon 3 - Grenade
		["MCC", "switchWeapon3", ["Switch Weapons 3: Grenades", ""], {if ((player getVariable ["cpReady",true]) && !(player getvariable ["MCC_medicUnconscious",false]) && (missionNamespace getvariable ["MCC_quickWeaponChange",false])) then {[4] spawn MCC_fnc_weaponSelect;true}}, {}, [4, [false,false,false]],false] call cba_fnc_addKeybind;

		//Switch weapon 4 - Primary/handgun
		["MCC", "switchWeapon4", ["Switch Weapons 4: Utility", ""], {if ((player getVariable ["cpReady",true]) && !(player getvariable ["MCC_medicUnconscious",false]) && (missionNamespace getvariable ["MCC_quickWeaponChange",false])) then {[5] spawn MCC_fnc_weaponSelect;true}}, {}, [5, [false,false,false]],false] call cba_fnc_addKeybind;
	};
	*/

	//Disable inventory
	player addEventHandler ["InventoryOpened", {true}];

	//Tutorials
	waituntil {player getVariable ["cpReady",false]};

	//Commander
	0 spawn {
		waituntil {((MCC_server getVariable [format ["CP_commander%1",side player],""]) == getPlayerUID player)};
		if (profileNamespace getVariable ["MCC_PRtutorialCommander",true]) then {
			_answer = ["<img size='10' img image='commanderRTS.paa' align='center'/>
						<br/>Open the commander console using your <t color='#FF6A32'>self interaction keys</t> or use the shortcut buttons as defined in the settings.
						<br/>From the console you can <t color='#FF6A32'>order players and AI group</t> by selecting them and double clicking on the map.
						<br/>You can call <t color='#FF6A32'>EVAC CAS and Supply drops</t> using the <t color='#FF6A32'> F2 and F3 buttons</t>.
						<br/>Order <t color='#FF6A32'>artillery</t> using the <t color='#FF6A32'>F4</t> button.
						<br/><br/>Do you want to disable this message in the future?","Commander Role","Yes","No"] call BIS_fnc_guiMessage;

			waituntil {!isnil "_answer" && !dialog};

			profileNamespace setVariable ["MCC_PRtutorialCommander",!_answer];
		};
	};

	//Squad Leader
	0 spawn {
		waituntil {leader player == player && count units group player > 1};
		if (profileNamespace getVariable ["MCC_FCtutorialSQL",true]) then {
			_answer = ["<img size='10' img image='sqlPic.paa' align='center'/>
						<br/>As the Squad Leader you will have more option in the <t color='#FF6A32'>self interaction menu</t>.
						<br/>You'll be able to place <t color='#FF6A32'>support markers</t> or <t color='#FF6A32'>spot enemies</t> by marking them on the map for 5 minutes.
						<br/>The <t color='#FF6A32'>Squad Leader PDA</t> can be used to constantly show friendly player on the HUD and increase battlefield awarness.
						<br/>You can also order the <t color='#FF6A32'>construction of battlefield emplacements</t> such as F.O.B which serves as spawn points.
						<br/><br/>Do you want to disable this message in the future?","Squad Leader Role","Yes","No"] call BIS_fnc_guiMessage;

			waituntil {!isnil "_answer" && !dialog};

			profileNamespace setVariable ["MCC_FCtutorialSQL",!_answer];
		};
	};

	if (profileNamespace getVariable ["MCC_PRtutorialPRKeys",true]) then {
		_answer = ["<img size='8.7' img image='PRkeyboardLayout.paa' />
					<br/>Press <t color='#FF6A32'>Interact</t> button to interact with objects or units (medic other, changing kits, vehicles options, logistics exc).
					<br/><br/>Press <t color='#FF6A32'>Interact Self</t> button to interact with yourself (spot enemy, medic self, construct fortifications exc).
					<br/><br/>Press <t color='#FF6A32'>Squad Dialog</t> button to open the Squad Dialog.
					<br/><br/>Do you want to disable this message in the future?","Project Reality (MCC)","Yes","No"] call BIS_fnc_guiMessage;

		waituntil {!isnil "_answer"};

		profileNamespace setVariable ["MCC_PRtutorialPRKeys",!_answer];
	};

	if (profileNamespace getVariable ["MCC_PRtutorialPR",true]) then {
		_answer = ["<img size='10' img image='PRmap.paa' align='center'/>
					<br/>This is Advance and Secure (AAS) mission where two sides are fighting to capture the island.
					<br/>Each side will have a commander and limited resources to help him capture the island.
					<br/>The capture points can only be captured in a specific order and the mission will end once all one side tickets reached zero or the mission time runs out.
					<br />Squad commanders can build FOB and other players can use the trucks utilize logistics to build the FOB or other battlefield emplacements
					<br/>You can assign yourself as a side commander or a squad leader by pressing on the <t color='#FF6A32'>Squad Dialog</t> button.
					<br/><br/>Do you want to disable this message in the future?","Mission","Yes","No"] call BIS_fnc_guiMessage;

		waituntil {!isnil "_answer"};

		profileNamespace setVariable ["MCC_PRtutorialPR",!_answer];
	};

	//Logistics Trucks
	0 spawn {
		if (profileNamespace getVariable ["MCC_PRtutorialLogistics",true]) then {
			waituntil {typeof vehicle player in (missionNamespace getvariable ["MCC_supplyTracks",[]]) && !dialog};
			_answer = ["<img size='9' img image='PRlogistics.paa' align='center'/>
						<br />While inside this vehicle and within 50 meters from HQ you can load logistics crates from the HQ and delieve them to the front.
						<br/><br/><t color='#FF6A32'>Ammo crates</t> will resupply units and vehicles.
						<br/><t color='#FF6A32'>Supply crates</t> will repair damaged vehicles and will be used to build FOB and battle emplacements.
						<br/><t color='#FF6A32'>Fuel crates</t> will refuel vehicles.
						<br/><br/>Press <t color='#FF6A32'>Interact</t> button to open the logistics dialog while in the driving seat and stopping next to the HQ.
						<br/><br/>Do you want to disable this message in the future?","Logistics","Yes","No"] call BIS_fnc_guiMessage;

			waituntil {!isnil "_answer" && !dialog};

			profileNamespace setVariable ["MCC_PRtutorialLogistics",!_answer];
		};
	};

	//Logistics Helicopters
	0 spawn {
		if (profileNamespace getVariable ["MCC_PRtutorialLogisticsHeli",true]) then {
			waituntil {(vehicle player isKindOf "helicopter") && !dialog};
			_answer = ["<img size='9' img image='logisticsHeli.paa' align='center'/>
						<br />While inside this vehicle and within 50 meters from HQ and flying higher then 15 meters you can <t color='#FF6A32'>slingload logistics crates</t> from the HQ and delieve them to the front.
						<br/><br/><t color='#FF6A32'>Ammo crates</t> will resupply units and vehicles.
						<br/><t color='#FF6A32'>Supply crates</t> will repair damaged vehicles and will be used to build FOB and battle emplacements.
						<br/><t color='#FF6A32'>Fuel crates</t> will refuel vehicles.
						<br/><br/>Press <t color='#FF6A32'>Interact</t> button to open the logistics dialog while autohovering over the HQ.
						<br/><br/>Do you want to disable this message in the future?","Logistics Helicopters","Yes","No"] call BIS_fnc_guiMessage;

			waituntil {!isnil "_answer" && !dialog};

			profileNamespace setVariable ["MCC_PRtutorialLogisticsHeli",!_answer];
		};
	};
};