//General
missionNameSpace setVariable ["MCC_syncOn",true];
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

MCC_fnc_AAS_drawLine = {
	private ["_dist","_dir","_center"];
	params ["_start","_end","_lineMarkerName"];

	_dist = _start distance _end;
	_dir = ((_end select 0) - (_start select 0)) atan2
	((_end select 1) - (_start select 1));

	_center = [(_start select 0) + ((sin _dir) * _dist / 2),
	(_start select 1) + ((cos _dir) * _dist / 2)];

	createMarkerLocal [_lineMarkerName, _center];
	_lineMarkerName setMarkerShapeLocal "RECTANGLE";
	_lineMarkerName setMarkerSizeLocal [10, _dist / 2];
	_lineMarkerName setMarkerColorLocal "ColorBlack";
	_lineMarkerName setMarkerDirLocal _dir;
};

MCC_fnc_AAS = {
	private ["_sectors","_zoneTriggers","_triggersAreas","_trigger","_fnc_drawLine","_sides"];

	MCC_fnc_AASHandleSector = {
		private ["_owner","_owners","_index","_sides","_factor","_nextTriggerIndex","_lastTriggerIndex","_triggers","_nextTriggerOwner"];
		params ["_sector"];

		_owner = _sector getvariable ["owner",sideunknown];
		_index = (missionNamespace getVariable ["MCC_fnc_AAS_sectors",[]]) find _sector;

		waitUntil {_owner != (_sector getvariable ["owner",sideunknown]);};
		_owner = _sector getvariable ["owner",sideunknown];

		_owners = missionNamespace getVariable ["MCC_fnc_AAS_owners",[]];
		_owners set [_index,_owner];
		missionNamespace setVariable ["MCC_fnc_AAS_owners",_owners];
		publicVariable "MCC_fnc_AAS_owners";

		_sides = missionNamespace getVariable ["MCC_fnc_AAS_sides",[]];

		//We have a valid conquestor
		if (_owner in _sides) then {

			_triggers = missionNamespace getVariable ["MCC_fnc_AAS_triggers",[]];
			_triggersAreas = missionNamespace getVariable ["MCC_fnc_AAS_triggersAreas",[]];

			//open new sector and close this one
			_nextTriggerIndex = if (_owner == (_sides select 0)) then {_index + 1} else {_index -1};
			_lastTriggerIndex = if (_owner == (_sides select 0)) then {_index - 1} else {_index +1};

			// Marker defend current sector
			deleteMarker (missionNamespace getVariable [format ["sector_%1", _index],""]);
			[[_owner, position (_triggers select _index),format ["sector_%1", _index]] ,"MCC_fnc_AASmarkers", true,false] spawn BIS_fnc_MP;

			if (_nextTriggerIndex >= 0 && _nextTriggerIndex < (count _triggers)) then {
				(_triggers select _nextTriggerIndex) setTriggerArea (_triggersAreas select _nextTriggerIndex);

				// Marker
				_nextTriggerOwner = ((missionNamespace getVariable ["MCC_fnc_AAS_sectors",[]]) select _nextTriggerIndex) getVariable ["owner",sideunknown];
				[[_nextTriggerOwner, position (_triggers select _nextTriggerIndex),format ["sector_%1", _nextTriggerIndex]] ,"MCC_fnc_AASmarkers", true,false] spawn BIS_fnc_MP;
			};

			if (_lastTriggerIndex >= 0 && _lastTriggerIndex < (count _triggers)) then {
				(_triggers select _lastTriggerIndex) setTriggerArea [0,0,0,false];
				deleteMarker (missionNamespace getVariable [format ["sector_%1", _lastTriggerIndex],""]);
			};
		};

		_sector spawn MCC_fnc_AASHandleSector;
	};

	//Module or function call
	if (typeName _this == typeName []) then {
		_sectors =  _this select 0;
		_sides = _this select 1;
	} else {
		_sectors = synchronizedObjects _this;
		_sides = [];
		{
			_sides pushBack ([(_this getVariable [_x,1])] call BIS_fnc_sideType);
		} forEach ["side1","side2"];
	};

	//Init
	_triggers = [];
	_triggersAreas = [];
	_owners = [];

	{
		_zoneTriggers = _x getvariable ["areas",[]];
		if (count _zoneTriggers == 0) exitWith {diag_log format ["MCC_fnc_AAS Error: no trigger in sector %1", _foreachindex]};
		_trigger = _zoneTriggers select 0;
		_triggers pushBack _trigger;
		_triggersAreas pushBack (triggerArea _trigger);
		_owners pushBack (_x getvariable ["owner",sideunknown]);
		_trigger setTriggerArea [0,0,0,false];
	} forEach _sectors;

	missionNamespace setVariable ["MCC_fnc_AAS_sides",_sides];
	publicVariable "MCC_fnc_AAS_sides";

	missionNamespace setVariable ["MCC_fnc_AAS_sectors",_sectors];
	publicVariable "MCC_fnc_AAS_sectors";

	missionNamespace setVariable ["MCC_fnc_AAS_triggers",_triggers];
	publicVariable "MCC_fnc_AAS_triggers";

	missionNamespace setVariable ["MCC_fnc_AAS_triggersAreas",_triggersAreas];
	publicVariable "MCC_fnc_AAS_triggersAreas";

	missionNamespace setVariable ["MCC_fnc_AAS_owners",_owners];
	publicVariable "MCC_fnc_AAS_owners";


	//Set the first and last areas open for conquest
	{
		_trigger = _triggers select _x;
		_trigger setTriggerArea (_triggersAreas select _x);

		//Set Markers
		[[_owners select _x, position _trigger,format ["sector_%1", _x]] ,"MCC_fnc_AASmarkers", true,false] spawn BIS_fnc_MP;

	} forEach [0,(count _triggers -1)];

	//Draw Lines
	{
		if (_foreachindex > 0) then {
			[[position _x, position (_triggers select (_foreachindex -1)), format ["MCC_AAS_Line_%1", _foreachindex]] ,"MCC_fnc_AAS_drawLine", true,true] spawn BIS_fnc_MP;
		};
	} forEach _triggers;

	//Main loop
	{
		_x spawn MCC_fnc_AASHandleSector;
	} forEach _sectors;
};

MCC_fnc_AASmarkers = {
	private ["_logic","_triggers","_attack","_marker","_attackText"];
	params ["_owner","_pos","_markerName"];

	_pos =  [_pos, 20, 0] call BIS_fnc_relPos;
	_attack = playerSide != _owner;
	_attackText = if (_attack) then {"Attack"} else {"Defend"};
	_marker = missionNamespace getVariable [_markerName,""];

	if (str getMarkerPos _marker == "[0,0,0]") then {
		_marker = createMarkerLocal [format ["%1_%2",_markerName,_attackText], _pos];
		_marker setMarkerTextLocal _attackText;
		_marker setMarkerShapeLocal "ICON";
		_marker setMarkerTypeLocal  "mil_marker";
		_marker setMarkerColorLocal (if (_attack) then {"ColorRed"} else {"ColorBlue"});
		missionNamespace setVariable [_markerName,_marker];
	};

	_marker setMarkerPosLocal _pos;
};

if (isServer || isDedicated) then {
	0 spawn {
		waitUntil {time > 0};
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

		[[s1,s2,s3,s4,s5,s6],[west,east]] call MCC_fnc_AAS;

		_time spawn BIS_fnc_paramDaytime;
	};
};


if (!isDedicated && hasInterface) then {
	waituntil {!(IsNull (findDisplay 46))};
	cutText ["","BLACK OUT",0.1];
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

	//Tutorials
	waituntil {player getVariable ["cpReady",false]};

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
					<br/>This is Advance and Secure (AAS) mission where two sides are fighting to capture the islan.
					<br/>Each side will have a commander and limited resources to help him capture the island.
					<br/>The capture points can only be captured in a specific order and the mission will end once all one side tickets reached zero or the mission time runs out.
					<br />Squad commanders can build FOB and other players can use the trucks utilize logistics to build the FOB or other battlefield emplacements
					<br/>You can assign yourself as a side commander or a squad leader by pressing on the <t color='#FF6A32'>Squad Dialog</t> button.
					<br/><br/>Do you want to disable this message in the future?","Mission","Yes","No"] call BIS_fnc_guiMessage;

		waituntil {!isnil "_answer"};

		profileNamespace setVariable ["MCC_PRtutorialPR",!_answer];
	};

	if (profileNamespace getVariable ["MCC_PRtutorialLogistics",true]) then {
		waituntil {typeof vehicle player in (missionNamespace getvariable ["MCC_supplyTracks",[]])};
		_answer = ["<img size='9' img image='PRlogistics.paa' align='center'/>
					<br />While inside this vehicle and within 50 meters from HQ you can load logistics crates from the HQ and delieve them to the front.
					<br/><br/>Ammo crates will resupply units and vehicles.
					<br/>Supply crates will repair damaged vehicles and will be used to build FOB and battle emplacements.
					<br/>Fuel crates will refuel vehicles.
					<br/><br/>Press <t color='#FF6A32'>Interact</t> button to open the logistics dialog while sitting in the driving seat and not accelerating.
					<br/><br/>Do you want to disable this message in the future?","Logistics","Yes","No"] call BIS_fnc_guiMessage;

		waituntil {!isnil "_answer"};

		profileNamespace setVariable ["MCC_PRtutorialLogistics",!_answer];
	};

	//MCC_supplyTracks
};