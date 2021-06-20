-- List of usgns with access to admin commands
cas.adminlist = {
	154048, 6161, 3738, 3898, 2422,
	17315, 17195, 16847, 52164, 4618,
	66681, 9689, 137843, 111403, 20137,
	116519, 79761, 37996, 14008, 16991,
	173424, 14545, 57114
}

-- Set $16000 for each player at round start
cas.always16k = false

-- Enable mixmatch features
cas.mixmatch = true

-- Number of players needed to start mixmatch
cas.required = 10

-- Number of rounds needed to start halftime
cas.mr = 15

-- Enable uploading logs after mixmatch ends
cas.upload_logs = true

-- Number of rounds to start votemap (0 disabled)
cas.votemap_rounds = 0

-- Number of minutes to start votemap (0 disabled)
cas.votemap_minutes = 0

-- Number of seconds until vote ends
cas.voting_timelimit = 10

-- List of available maps in votemap
cas.mappool = {
	"icc_nuke", "icc_aztec", "icc_inferno", "de_mirage", "de_cpl_mill",
	"icc_cbble", "de_thorpod", "de_train", "de_dust2_eu", "de_cache",
	"de_tuscanpod", "icc_dust2", "de_dust2_source", "icc_cima", "de_infernopod",
	"icc_cima_beta", "pcs_arno", "sf_mirage", "de_cima", "de_vertigo",
	"de_cobblestone", "de_kabul", "de_inferno_eu", "de_dust2", "de_inferno"
}

-- List of files to check while joining the server
cas.check_files = {
	["sfx/player/hit1.wav"] = "1ff855e59dc1d55fbdd899b3734bf65747078f41738b7ebdb1e6fdda54298e6b",
	["sfx/player/hit2.wav"] = "bb2b7393b580220df80966a5d4ed89c1f4eaa7e0d4690f27221e9dc021c4d9f2",
	["sfx/player/hit3.wav"] = "ebabd453fd91ef46f4067720bedf2ff51140e1d0f9f5cafd29c530c29bfddd4a"
}
