class mcc_test
{
	idd = 9999999;
	movingEnable = true;
	onLoad ="";

	controlsBackground[] =
	{
	};


	//---------------------------------------------
	objects[] =
	{ 	//(0.671875 * safezoneW + safezoneX) / safezoneW -X
	};	//(0.478009 * safezoneH + safezoneY) / safezoneH - Y

	class controls
	{
		class frame: MCC_RscText
		{
			colorBackground[] = {0,0,0,0.9};
			idc = -1;
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.225 * safezoneH + safezoneY;
			w = 0.417656 * safezoneW;
			h = 0.385 * safezoneH;
		};

		class vehicleClass: MCC_RscCombo
		{
			idc = 101;
			onLBSelChanged = "[0] spawn MCC_fnc_vehicleSpawner";
			x = 0.304062 * safezoneW + safezoneX;
			y = 0.346 * safezoneH + safezoneY;
			w = 0.216563 * safezoneW;
			h = 0.055 * safezoneH;
		};

		class SpawnButton: MCC_RscButton
		{
			idc = 102;
			text = "Purchase";
			x = 0.319531 * safezoneW + safezoneX;
			y = 0.544 * safezoneH + safezoneY;
			w = 0.139219 * safezoneW;
			h = 0.055 * safezoneH;
			onButtonClick = "[1] spawn MCC_fnc_vehicleSpawner";
		};

		class close: MCC_RscButton
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			x = 0.639219 * safezoneW + safezoneX;
			y = 0.544 * safezoneH + safezoneY;
			w = 0.061875 * safezoneW;
			h = 0.055 * safezoneH;
			onButtonClick = "closeDialog 0;";
		};

		class ammoPic: MCC_RscPicture
		{
			idc = -1;
			text =  __EVAL(MCCPATH +"data\IconAmmo.paa");
			x = 0.304062 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.0257812 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class repairPic: MCC_RscPicture
		{
			idc = -1;
			text = __EVAL(MCCPATH +"data\IconRepair.paa");
			x = 0.381406 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.0257812 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class fuelPic: MCC_RscPicture
		{
			idc = -1;
			text = __EVAL(MCCPATH +"data\IconFuel.paa");
			x = 0.45875 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.0257812 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class ammoText: MCC_RscText
		{
			idc = 1000;
			x = 0.329844 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.04125 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class repairText: MCC_RscText
		{
			idc = 1001;
			x = 0.407187 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.04125 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class fuelText: MCC_RscText
		{
			idc = 1002;
			x = 0.484531 * safezoneW + safezoneX;
			y = 0.423 * safezoneH + safezoneY;
			w = 0.04125 * safezoneW;
			h = 0.044 * safezoneH;
		};
		class tittle: MCC_RscText
		{
			idc = -1;
			text = "Vehicle Spawn";
			x = 0.319531 * safezoneW + safezoneX;
			y = 0.258 * safezoneH + safezoneY;
			w = 0.170156 * safezoneW;
			h = 0.055 * safezoneH;
			colorText[] = {0,1,1,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5)";
		};

		class availableResourcesTittle: MCC_RscText
		{
			idc = -1;

			text = "Available Resources";
			x = 0.592812 * safezoneW + safezoneX;
			y = 0.247 * safezoneH + safezoneY;
			w = 0.108281 * safezoneW;
			h = 0.055 * safezoneH;
			colorText[] = {0,1,1,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_ResourcesControlsGroup: MCC_RscControlsGroupNoScrollbars
		{
			idc = 80;
			x = 0.592813 * safezoneW + safezoneX;
			y = 0.313 * safezoneH + safezoneY;
			w = 0.108281 * safezoneW;
			h = 0.22 * safezoneH;
			class controls
			{
				class MCC_AmmoText: MCC_RscText
				{
					idc = 81;

					x = 0.0257812 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.04125 * safezoneW;
					h = 0.033 * safezoneH;
				};

				class MCC_RepairText: MCC_RscText
				{
					idc = 82;

					x = 0.0257812 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.04125 * safezoneW;
					h = 0.033 * safezoneH;
				};

				class MCC_FuelText: MCC_RscText
				{
					idc = 83;

					x = 0.0257812 * safezoneW;
					y = 0.099 * safezoneH;
					w = 0.04125 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_FoodText: MCC_RscText
				{
					idc = 84;

					x = 0.0257812 * safezoneW;
					y = 0.143 * safezoneH;
					w = 0.04125 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_MedText: MCC_RscText
				{
					idc = 85;

					x = 0.0257812 * safezoneW;
					y = 0.187 * safezoneH;
					w = 0.04125 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_Ammo: MCC_RscPicture
				{
					idc = -1;

					text =  __EVAL(MCCPATH +"data\IconAmmo.paa");
					x = 0.00515625 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.0154688 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_Repair: MCC_RscPicture
				{
					idc = -1;

					text = __EVAL(MCCPATH +"data\IconRepair.paa");
					x = 0.00515625 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.0154688 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_Fuel: MCC_RscPicture
				{
					idc = -1;

					text = __EVAL(MCCPATH +"data\IconFuel.paa");
					x = 0.00515625 * safezoneW;
					y = 0.099 * safezoneH;
					w = 0.0154688 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_FoodPic: MCC_RscPicture
				{
					idc = -1;

					text = __EVAL(MCCPATH +"data\IconFood.paa");
					x = 0.00515625 * safezoneW;
					y = 0.143 * safezoneH;
					w = 0.0154688 * safezoneW;
					h = 0.033 * safezoneH;
				};
				class MCC_MedPic: MCC_RscPicture
				{
					idc = -1;

					text = __EVAL(MCCPATH +"data\IconMed.paa");
					x = 0.00515625 * safezoneW;
					y = 0.187 * safezoneH;
					w = 0.0154688 * safezoneW;
					h = 0.033 * safezoneH;
				};
			};
		};
	};
};
