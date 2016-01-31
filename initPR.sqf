//General
missionNameSpace setVariable ["MCC_syncOn",false];
missionNameSpace setVariable ["MCC_teleportToTeam",false];
missionNameSpace setVariable ["MCC_saveGear",false];
missionNameSpace setVariable ["MCC_Chat",false];
missionNameSpace setVariable ["MCC_deletePlayersBody",false];
missionNameSpace setVariable ["MCC_allowlogistics",true];
missionNameSpace setVariable ["MCC_allowRTS",true];				//Just for test disable later

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
missionNameSpace setVariable ["MCC_quickWeaponChange",true];
missionNameSpace setVariable ["MCC_surviveMod",false];
missionNameSpace setVariable ["MCC_showActionKey",true];
missionNamespace setVariable ["MCC_allowSQLRallyPoint",true];

//Medical
missionNameSpace setVariable ["MCC_medicXPmesseges",true];
missionNameSpace setVariable ["MCC_medicPunishTK",true];

//Radio
missionNameSpace setVariable ["MCC_VonRadio",true];
missionNameSpace setVariable ["MCC_vonRadioDistanceGlobal",200000];
missionNameSpace setVariable ["MCC_vonRadioDistanceSide",10000];
missionNameSpace setVariable ["MCC_vonRadioDistanceCommander",10000];
missionNameSpace setVariable ["MCC_vonRadioDistanceGroup",1000];
missionNameSpace setVariable ["MCC_vonRadioKickIdle",true];
missionNameSpace setVariable ["MCC_vonRadioKickIdleTime",15];

enableEngineArtillery false;

//Spawn UI
_null = [1,true,true,true,true,true,true] spawn MCC_fnc_inGameUI;

if (isServer) then {
	//Tickets
	[west, 200] call BIS_fnc_respawnTickets;
	[east, 200] call BIS_fnc_respawnTickets;

	//Resources
	missionNamespace setVariable ["MCC_resWest",[5000,5000,5000,200,200]];
	missionNamespace setVariable ["MCC_resEast",[5000,5000,5000,200,200]];
	missionNamespace setVariable ["MCC_resGUER",[5000,5000,5000,200,200]];
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

	_time spawn BIS_fnc_paramDaytime;
};

if (!isDedicated && hasInterface) then {
	waituntil {!(IsNull (findDisplay 46))};
	sleep 1;

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

	//Disable inventory
	player addEventHandler ["InventoryOpened", {true}];

	MCC_fnc_AASmarkers = {
	private ["_logic","_owner","_triggers","_attack","_pos"];
		_logic = _this;
		_triggers = _logic getvariable ["areas",[]];
		while {true} do {
			_owner = _logic getvariable ["owner",sideunknown];

			if ({((triggerArea _x) select 0) > 0} count _triggers > 0 && _owner !=sideUnknown) then {
				_attack = playerSide != _owner;
				_pos = position (_triggers select 0);

				_attackText = if (_attack) then {"Attack"} else {"Defend"};
				_marker = missionNamespace getVariable [format ["MCC_AASmarker_%1",_attackText],""];
				if (str getMarkerPos _marker == "[0,0,0]") then {
					_marker = createMarkerLocal [format ["MCC_AASmarker_%1",_attackText], _pos];
					_marker setMarkerText _attackText;
					_marker setMarkerShapeLocal "ICON";
					_marker setMarkerTypeLocal  "mil_marker";
					_marker setMarkerColorLocal (if (_attack) then {"ColorRed"} else {"ColorBlue"});
					missionNamespace setVariable [format ["MCC_AASmarker_%1",_attackText],_marker];
				};

				_marker setMarkerPosLocal _pos;
			};

			sleep 1;
		};
	};

	{
		_x spawn MCC_fnc_AASmarkers;
	} forEach [s1,s2,s3,s4,s5,s6];

};