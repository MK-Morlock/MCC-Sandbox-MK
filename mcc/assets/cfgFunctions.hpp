class assets
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\assets";
	#else
	file = "mcc\assets";
	#endif

	class assetsData		{description = "Asset presets per enemy faction (console Assets page)";};
	class assetsCandidates	{description = "Classes offered for an asset slot";};
	class assetsPreview	{description = "3D preview on the Assets page";};
	class assetsSyncConsole	{description = "Show the Assets page faction in the console list";};
	class assetsUI			{description = "Console Assets page";};
};
