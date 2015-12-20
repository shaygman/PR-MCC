private ["_pos", "_units", "_spawn","_away","_plane","_pilot","_wp","_count","_dropPos","_UMUnit", "_jumpers", "_i",
		"_light","_isHalo","_flightHight","_unitsArray","_unit","_init","_chockArray","_heliClass","_pod"];
_pos 		= _this select 0;
_units 		= _this select 1;
_UMUnit		= _this select 2;
_isHalo		= _this select 3; 
_spawn		= _this select 4;
_away		= _this select 5;

if (count _units == 0) exitWith {};
_flightHight = if (_isHalo) then {500} else {300};

_spawn set [2,(_spawn select 2) + _flightHight];
_away set [2,(_away select 2) + _flightHight];

if (_isHalo) then 
{
	_heliClass = "O_Heli_Transport_04_F";
	_dropPos = [_pos select 0, _pos select 1, _flightHight];
} 
else 
{
	_heliClass = "I_Heli_Transport_02_F";
	_dropPos =  [_pos select 0, _pos select 1, (_pos select 2)+ _flightHight];
};

_unitsArray	= [];
_chockArray = []; 

if (_UMUnit==0) then 
{
	{
		_unitsArray set [count _unitsArray,_x];
		if (count _unitsArray >= 12) then 
		{
			_chockArray set [count _chockArray, _unitsArray];
			_unitsArray	= [];
		};
	} foreach _units;
} 
else
{
	{
		{
			_unitsArray set [count _unitsArray,_x];
			if (count _unitsArray >= 12) then 
			{
				_chockArray set [count _chockArray, _unitsArray];
				_unitsArray	= [];
			};
		} foreach (units _x);
	} foreach _units;
};

//Add the last chock even if it isn't full
_chockArray set [count _chockArray, _unitsArray];

private "_safepos";
{
	_unitsArray = _x; 
	
	_safepos  =[_spawn ,1,200,2,1,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;						
	_plane = [_heliClass, _safepos, _pos, _flightHight, true] call MCC_fnc_createPlane;		//Spawn plane 1 
	
	_pilot = driver _plane;
	
	if (_isHalo) then 
	{
		if (side (_units select 0) != east) then
		{
			_null = [_plane] execVM "\a3\Air_F_Heli\Heli_Transport_04\Scripts\Heli_Transport_04_basic_black.sqf";
		};
		
		_pod = "Land_Pod_Heli_Transport_04_bench_F" createVehicle [0,0,0];
		_pod attachto [_plane,[0,0,-1.2]];
		_plane setVariable ["MCC_attachedPod",_pod,true];
		
		[_pod,_plane] spawn {
			private ["_pod","_vehicle"];
			_pod 		= _this select 0;
			_vehicle 	= _this select 1;
			while {!(isNull attachedTo _pod) && alive _pod} do {if !(alive _vehicle) then {_pod setDammage 1;detach _pod};sleep 0.5};
		};
	}
	else
	{
		if (side (_units select 0)  == east) then 
		{
			_plane setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
			_plane setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
			_plane setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		};

		if (side (_units select 0)  == west) then 
		{
			_plane setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
			_plane setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
			_plane setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		};	
		
		_plane lock true;
	};
	

	//Set plane variables
	_plane flyInHeight _flightHight;
	_plane setVariable ["MCCJumperNumber",-1,true];																		//Number of unit to jump		
	if (_isHalo) then {_plane setVariable ["MCCisHALO",true,true]} else {_plane setVariable ["MCCisHALO",false,true]}; 	//Is HALO jump?
	_plane setVariable ["MCCjumpReady",false,true];																		//Are we ready on the ramp
	MCC_planeNameCount = MCC_planeNameCount + 1;


	_count = 0;
	for [{_x=0},{_x < count _unitsArray},{_x=_x+1}] do 
	{
		_unit = _unitsArray select _x;
		[[_plane, _unit,_count], "MCC_fnc_realParadropPlayer", _unit] spawn BIS_fnc_MP;
		_count = _count + 1;
	};


	//Set waypoint
	_wp = (group _plane) addWaypoint [[_pos select 0, _pos select 1, 0], 0];	//Add WP
	_wp setWaypointStatements ["true", ""];
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointCombatMode "BLUE";
	_wp setWaypointCompletionRadius 200;
	_plane flyInHeight _flightHight;
	
	[_plane, _pos, _flightHight, _pilot, _away, _isHalo] spawn
	{
		private ["_plane","_pos","_flightHight","_pilot","_away","_isHalo"];
		_plane 			= _this select 0;
		_pos 			= _this select 1;
		_flightHight 	= _this select 2;
		_pilot 			= _this select 3;
		_away 			= _this select 4;
		_isHalo			= _this select 5;
		
		//Make them stand on the deck
		while {((_plane distance [_pos select 0, _pos select 1, _flightHight]) > 1000) && (alive _plane)} do {sleep 1};
		_plane setVariable ["MCCjumpReady",true,true];				//Ready for the jump

		sleep 12; 
		//_this animate ["CargoRamp_Open", 0];	
		{_plane animateDoor [_x, 1]} foreach ["CargoRamp_Open"];
		
		sleep 4; 

		if (_isHalo) then
		{
			_plane call MCC_fnc_releasePod;
		}
		else
		{
			_plane setVariable ["MCCJumperNumber",0,true];
		};
			
		[group _pilot, _pilot, _plane, _away] spawn MCC_fnc_deletePlane;
	};
	
	sleep 5;
} foreach _chockArray; 