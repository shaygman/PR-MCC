private ["_cmd","_comboBox","_spawnArray","_pos","_spawn","_nearObjects","_spawnAvailable","_safepos","_targets","_target","_groups","_deployAvailable"
		,"_countRole","_roleLimit","_role"];
disableSerialization;

#define CP_RESPAWNPANEL_IDD (uiNamespace getVariable "CP_RESPAWNPANEL_IDD")
#define CP_respawnPointsList (uiNamespace getVariable "CP_respawnPointsList")
#define CP_ticketsWestText (uiNamespace getVariable "CP_ticketsWestText")
#define CP_ticketsEastText (uiNamespace getVariable "CP_ticketsEastText")
#define CP_respawnPanelRoleCombo (uiNamespace getVariable "CP_respawnPanelRoleCombo")
#define CP_deployPanelMiniMap (uiNamespace getVariable "CP_deployPanelMiniMap")
#define CP_gearPanelPiP (uiNamespace getVariable "CP_gearPanelPiP")

#define CP_RscMainXPUI (uiNamespace getVariable "CP_RscMainXPUI")
#define messeges (uiNamespace getVariable "messeges")
#define XPTitle (uiNamespace getVariable "XPTitle")
#define XPValue (uiNamespace getVariable "XPValue")

_cmd = _this select 0;

switch (_cmd) do
	{
		case 0:				//LBL change on respawn marker
		{
			if !(uinameSpace getVariable ["cpLoadingSpawnPoints",false]) then
			{
				_spawnArray	 = missionNamespace getVariable ["MCCActiveSpawnPosArray",[]];

				if (count _spawnArray > 0) then
				{
					CP_respawnPointsIndex = (lbCurSel CP_respawnPointsList);
					_spawn	 = _spawnArray select (lbCurSel CP_respawnPointsList);
					_pos 	 = if (typeName _spawn == "GROUP") then {getpos leader _spawn} else {[(getpos _spawn) select 0, (getpos _spawn) select 1]};
					CP_deployPanelMiniMap ctrlMapAnimAdd [0.4, ctrlMapScale (uiNamespace getVariable "CP_deployPanelMiniMap"), _pos];
					ctrlMapAnimCommit CP_deployPanelMiniMap;
					CP_activeSpawn = _spawn;
				}
				else
				{
					CP_activeSpawn = objnull
				};
			};
		};

		case 1:				//==================================================Deploy pressed============================================================
		{

			//Check if alive
			if (isnull CP_activeSpawn) exitWith {[9999,"Select spawn point!",3,true] spawn MCC_fnc_setIDCText};
			if (typeName CP_activeSpawn == "GROUP") then {CP_activeSpawn = leader CP_activeSpawn};
			if (!alive CP_activeSpawn) exitWith {
				CP_activeSpawn setVariable ["dead",true,true];
				[9999,"Spawn Point destroyed, select another!",3,true] spawn MCC_fnc_setIDCText
			};


			if (CP_activated) then {

				//Check if player assigned to group
				_groups	 = switch (side player) do
							{
								case west:			{CP_westGroups};
								case east:			{CP_eastGroups};
								case resistance:	{CP_guarGroups};
								case civilian:		{CP_guarGroups};
							};

				_deployAvailable = false;
				for [{_i=0},{_i < count _groups},{_i=_i+1}] do {
					if ((group player) == (_groups select _i) select 0) then {_deployAvailable = true};
				};

				if (!_deployAvailable) exitWith {
					[9999,"You must join a squad first!",3,true] spawn MCC_fnc_setIDCText
				};

				if (player getvariable ["CP_role","n/a"] == "n/a") exitWith {
					[9999,"Select a role",3,true] spawn MCC_fnc_setIDCText
				};

				//Check if no enemy is close by

				_spawnAvailable = true;

				if ((CP_activeSpawn getvariable ["type","FOB"]) != "HQ") then {
					_targets = ["Car","Tank","Man"];
					_nearObjects = (getpos CP_activeSpawn) nearObjects 50;

					if ((count _nearObjects) > 0) then {
						private ["_enemySides"];
						_enemySides = [player] call BIS_fnc_enemySides;

						{
							_target = _x;
							{
								if ((_target isKindOf _x) && ((side _target) in _enemySides)) exitWith {_spawnAvailable = false};
							} foreach _targets;
						} foreach _nearObjects;
					};
				};

				if (!_spawnAvailable) exitWith {
					[9999,"Spawn Point overrun, select another",3,true] spawn MCC_fnc_setIDCText
				};


				//looking for a spawn point
				private ["_maxPos","_cpPos"];
				_maxPos = 1;
				_cpPos = getpos CP_activeSpawn;

				waitUntil {
					_maxPos = _maxPos +1;
					playerDeployPos  =_cpPos findEmptyPosition [0,_maxPos];
					count playerDeployPos > 0;
				};

				if (format["%1",playerDeployPos] == "[-500,-500,0]" ) exitWith {
					[9999,"No good position found! Try again.",3,true] spawn MCC_fnc_setIDCText
				};
				playerDeploy = true;

				//Is it a spawn tent and we spawned as the squad leader - delete the tent
				if (((CP_activeSpawn getVariable ["type","FOB"]) == "Rally_Point") && ((player == leader player) || ((player getvariable ["CP_role","n/a"]) == "Officer"))) then
				{
					CP_activeSpawn setDamage 1;
				};

				//Remove escape event handlers and reseting menu
				if (!isnil "CP_RESPAWNPANEL_IDD") then {CP_RESPAWNPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_SQUADPANEL_IDD") then {CP_SQUADPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_GEARPANEL_IDD") then {CP_GEARPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_WEAPONSPANEL_IDD") then {CP_WEAPONSPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_ACCESPANEL_IDD") then {CP_ACCESPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_UNIFORMSPANEL_IDD") then {CP_UNIFORMSPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				CP_respawnPanelOpen = false;
			} else {
				//looking for a spawn point
				private ["_maxPos","_cpPos"];
				_maxPos = 1;
				_cpPos = getpos CP_activeSpawn;

				waitUntil {
					_maxPos = _maxPos +1;
					playerDeployPos  =_cpPos findEmptyPosition [0,_maxPos];
					count playerDeployPos > 0;
				};

				if (format["%1",playerDeployPos] == "[-500,-500,0]" ) exitWith {
					[9999,"No good position found! Try again.",3,true] spawn MCC_fnc_setIDCText;
				};

				//Is it a spawn tent and we spawned as the squad leader - delete the tent
				if (((CP_activeSpawn getVariable ["type","FOB"]) == "Rally_Point") && (player == leader player)) then {
					CP_activeSpawn setDamage 1;
				};

				playerDeploy = true;

				//Remove escape event handlers and reseting menu
				if (!isnil "CP_RESPAWNPANEL_IDD") then {CP_RESPAWNPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_SQUADPANEL_IDD") then {CP_SQUADPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_GEARPANEL_IDD") then {CP_GEARPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_WEAPONSPANEL_IDD") then {CP_WEAPONSPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_ACCESPANEL_IDD") then {CP_ACCESPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				if (!isnil "CP_UNIFORMSPANEL_IDD") then {CP_UNIFORMSPANEL_IDD displayRemoveEventHandler ["KeyDown", CP_disableEsc]};
				CP_respawnPanelOpen = false;
			};
		};

		case 2:				//Change role
		{
			[(lbCurSel CP_respawnPanelRoleCombo),0] call MCC_fnc_setGear;
			[CP_gearPanelPiP] call MCC_fnc_pipOpen;
			CP_gearPanelPiP ctrlSetText "#(argb,512,512,1)r2t(rendertarget7,1.0);";

			//Set XP
			_role = player getvariable "CP_role";
			if (isnil "_role") exitWith {};

			_exp 	 = call compile format  ["%1Level select 1",_role];
			if (isnil "_exp") exitWith {};

			if (_exp < 0) then {_exp = 0};
			_oldLevel = call compile format  ["%1Level select 0",_role];
			_html = "<t color='#818960' size='2' shadow='1' align='center' underline='false'>"+ _role+ " Level " + str _oldLevel + "</t>";
			messeges ctrlSetStructuredText parseText _html;

			_needXP 			= (CP_XPperLevel * _oldLevel);
			_needXPPrevLevel 	= (CP_XPperLevel * (_oldLevel-1));
			XPValue progressSetPosition (1-((_needXP-_exp)/(_needXP - _needXPPrevLevel)));

			//Gear stats
			[ctrlParent ((_this select 1) select 0)] call MCC_fnc_playerStats;
		};
	};