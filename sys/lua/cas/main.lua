function scriptPath()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end
cas = {}
cas.path = scriptPath()
cas.hook = {}
cas.admin = {}
cas.mute = {}
cas.damage = {}
cas.total = {}
cas.mvp = {}
cas.con = {}
cas.voteopt = {}
cas.counted_votes = {}
for id = 1, 32 do
	cas.admin[id] = false
	cas.mute[id] = false
	cas.damage[id] = 0
	cas.total[id] = 0
	cas.mvp[id] = 0
	cas.con[id] = false
	cas.voteopt[id] = 0
	cas.counted_votes[id] = 0
end
cas.logs = {}
cas.votemap_minutes_countdown = 0
cas.state = 0
cas.ct_score = 0
cas.tt_score = 0
cas.fh_ct = 0
cas.fh_tt = 0
cas.cpt1 = 0
cas.cpt2 = 0
cas.cmds = {}
cas.matchnow = false
cas.between = false
cas.lock = false
cas.knives = false
cas.warmup = false
cas.warmup_weapons = {}
cas.warmup_armor = 0
cas.permit = 0
cas.recentmvp = 0
cas.vote = 0
cas.votecountdown = 0
cas.mutelist = {}
cas.adminlist = {}
cas.spawn_16k = false
cas.mixmatch = false
cas.required = 10
cas.mr = 15
cas.upload_logs = true
cas.votemap_rounds = 0
cas.votemap_minutes = 0
cas.voting_timelimit = 10
cas.mappool = {}
cas.version = "v1.5-beta"
cas.ft = tonumber(game("mp_freezetime"))
cas.map = map("name")
cas.map_sha256 = checksumfile("maps/" .. cas.map .. ".map")
cas.port = game("port")
dofile(cas.path .. "functions.lua")
dofile(cas.path .. "commands.lua")
dofile(cas.path .. "hooks.lua")
cas.addhooks()
cas.reload()
