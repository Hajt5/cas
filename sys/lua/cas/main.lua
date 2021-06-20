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
cas.round = 0
cas.ct_score = 0
cas.tt_score = 0
cas.fh_ct = 0
cas.fh_tt = 0
cas.commands = {}
cas.between = false
cas.lock = false
cas.knives = false
cas.warmup = false
cas.warmup_weapons = {}
cas.warmup_armor = 0
cas.permit = 0
cas.recentmvp = 0
cas.vote = false
cas.votecountdown = 0
cas.mutelist = {}
cas.adminlist = {}
cas.mixmatch = 0
cas.required = 10
cas.mr = 15
cas.upload_logs = 1
cas.votemap_rounds = 0
cas.votemap_minutes = 0
cas.voting_timelimit = 10
cas.mappool = {}
cas.check_files = {}
cas.ft = tonumber(game("mp_freezetime"))
dofile(cas.path .. "functions.lua")
dofile(cas.path .. "commands.lua")
dofile(cas.path .. "hooks.lua")
cas.addhooks()
cas.reload()
