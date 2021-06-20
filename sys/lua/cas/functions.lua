function cas.pnt(...)
	if cas.mixmatch == 0 then
		return
	end
	table.insert(cas.logs, table.concat({...}, ","))
end

function cas.split(s, sep)
	local fields = {}
	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(
		s,
		pattern,
		function(c)
			fields[#fields + 1] = c
		end
	)
	return fields
end

function cas.nick(id)
	if cas.con[id] == false then
		return "\169255220000Undefined"
	end
	local team = player(id, "team")
	local name = player(id, "name")
	if team == 0 then
		return "\169255220000" .. name
	elseif team == 1 then
		return "\169255025000" .. name
	else
		return "\169050150255" .. name
	end
end

function cas.escape(text)
	text:gsub("^%s*(.-)%s*$", "%1")
	while text:sub(-2) == "@C" do
		text = text:sub(1, -3)
	end
	return text
end

function cas.swap()
	local team1 = player(0, "team1")
	local team2 = player(0, "team2")
	for _, id in pairs(team1) do
		cas.permit = id
		parse("makect " .. id)
	end
	for _, id in pairs(team2) do
		cas.permit = id
		parse("maket " .. id)
	end
	cas.permit = 0
end

function cas.in_tbl(tbl, item)
	for key, value in pairs(tbl) do
		if value == item then
			return key
		end
	end
	return false
end

function cas.cmsg2(id, txt)
	parse('cmsg "' .. txt .. '" ' .. id)
end

function cas.kick(id, reason)
	parse("kick " .. id .. ' "' .. reason .. '"')
end

function cas.ban(id, duration, reason)
	local ip = player(id, "ip")
	local usgn = player(id, "usgn")
	local steamid = player(id, "steamid")

	if usgn > 0 then
		parse("banusgn " .. usgn .. " " .. duration .. ' "' .. reason .. '"')
	end
	if steamid ~= "0" then
		parse("bansteam " .. steamid .. " " .. duration .. ' "' .. reason .. '"')
	end
	parse("banip " .. ip .. " " .. duration .. ' "' .. reason .. '"')
end

function cas.highest_val(arr)
	local max_val, key = -math.huge
	for k, v in pairs(arr) do
		if v > max_val then
			max_val, key = v, k
		end
	end
	return max_val, key
end

function cas.time(seconds)
	local seconds = tonumber(seconds)
	if seconds <= 0 then
		return "00:00"
	end
	local hours = math.floor(seconds / 3600)
	local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
	local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
	return mins .. ":" .. secs
end

function cas.hud(id)
	local txt1 = ""
	local txt2 = ""
	if cas.knives == true then
		txt1 = "Knife Round"
		txt2 = "Buying disabled"
	elseif cas.warmup == true then
		local weapons = {}
		for _, id in pairs(cas.warmup_weapons) do
			table.insert(weapons, itemtype(id, "name"))
		end
		if cas.warmup_armor ~= 0 then
			table.insert(weapons, itemtype(cas.warmup_armor, "name"))
		end
		txt1 = "Warmup"
		txt2 = table.concat(weapons, " + ")
	elseif cas.mixmatch == 1 then
		if cas.status == "1st Half" or cas.status == "2nd Half" then
			txt1 = cas.status
			txt2 = "Round " .. cas.round .. "/" .. cas.mr * 2
		elseif cas.status == "Halftime" then
			txt1 = cas.status
			txt2 = "Prepare to fight"
		else
			txt1 = "Match not started"
			txt2 = "Requires " .. cas.required .. " players to start"
		end
	else
		return
	end

	local x = player(id, "screenw") / 2
	parse("hudtxt2 " .. id .. ' 199 "\169000255150' .. txt1 .. '" ' .. x .. " 2 1 0 18")
	parse("hudtxt2 " .. id .. ' 198 "\169000255150' .. txt2 .. '" ' .. x .. " 20 1 0 14")
end

function cas.pntdamage(id)
	if cas.damage[id] > 0 and cas.con[id] == true then
		cas.pnt("d", id, cas.damage[id])
	end
end

function cas.process(id, cmd, txt)
	local arguments = {}
	if txt ~= nil then
		for word in txt:gmatch("[^%s]+") do
			table.insert(arguments, word)
		end
	end

	if cas.commands[cmd].admin == true and cas.admin[id] == false then
		msg2(id, "\169000255150You do not have access to admin commands")
		return
	end

	if cas.commands[cmd].maxarg ~= false and cas.commands[cmd].maxarg < #arguments then
		msg2(id, "\169000255150You have entered too many arguments")
		return
	end

	local ret = cas.commands[cmd].func(id, arguments)
	if ret ~= nil then
		if ret == false then
			msg2(id, "\169000255150Correct syntax is \169150255000" .. cmd .. " " .. cas.commands[cmd].syntax)
		else
			msg2(id, "\169000255150" .. ret)
		end
		return
	end

	local cmdarg = cmd .. " " .. table.concat(arguments, " ")
	if cas.commands[cmd].alert == true then
		msg(cas.nick(id) .. " \169000255150used command \169150255000" .. cmdarg)
	end
end

function cas.say(id, message, sayteam)
	local message = cas.escape(message:gsub("[^%w%s%p]+", ""))
	if message == "" then
		return 1
	end

	if message == "rank" then
		return 0
	end

	local cmd = message:match("^([!][%w]+)[%s]?")
	if cmd then
		cmd = string.lower(cmd)

		local sc = cas.aliases[cmd]
		if sc ~= nil then
			cmd = sc
		end

		if not cas.commands[cmd] then
			msg2(id, "\169000255150Command does not exist")
			return 1
		end

		local aftercmd = message:match("[%s](.*)")
		cas.process(id, cmd, aftercmd)
		return 1
	end

	if cas.mute[id] == true then
		msg2(id, "\169000255150You are muted")
		return 1
	end

	local txt_team = ""
	if sayteam == true then
		txt_team = " (Team)"
	end

	local txt_dead = ""
	if player(id, "health") == 0 then
		txt_dead = " *DEAD*"
	end

	local txt = cas.nick(id) .. "\169255220000" .. txt_team .. txt_dead .. ": " .. message
	local plist = player(0, "table")

	if sayteam == true then
		for _, v in pairs(plist) do
			if player(v, "team") == player(id, "team") then
				msg2(v, txt)
			end
		end
		return 1
	end

	if player(id, "health") == 0 then
		for _, v in pairs(plist) do
			if player(v, "health") == 0 then
				msg2(v, txt)
			end
		end
	else
		msg(txt)
	end
	
	return 1
end

function cas.votemap_minutes_info()
	if cas.vote == true then
		return
	end
	local seconds = cas.votemap_minutes_countdown - os.time(os.date("!*t"))
	msg("\169000255150Vote for next map will start in \169150255000" .. cas.time(seconds))
end

function cas.votemap_minutes_over(parameter)
	if cas.votemap_minutes == 0 then
		return
	end

	if parameter == "startvote" and cas.vote == false then
		cas.vote = true
		parse("sv_sound hajt/countdown.ogg")
		timer(3000, "cas.startvote", "votemap")
		return
	end

	cas.votemap_minutes_countdown = os.time(os.date("!*t")) + (cas.votemap_minutes * 60)
	timer(cas.votemap_minutes * 60000 - 3000, "cas.votemap_minutes_over", "startvote", 0)
	timer(45000, "cas.votemap_minutes_info", 0)
end

function cas.percentage(opt)
	local votes = 0
	local total_votes = 0
	local plist = player(0, "table")
	for _, id in pairs(plist) do
		if opt == cas.voteopt[id] then
			votes = votes + 1
		end
		if cas.voteopt[id] > 0 then
			total_votes = total_votes + 1
		end
	end
	if votes == 0 then
		return "0%"
	end
	return math.floor(votes / total_votes * 100) .. "%"
end

function cas.showhud(votetype)
	local plist = player(0, "table")
	for _, id in pairs(plist) do
		local x = 5
		local y = player(id, "screenh") / 2 - 100
		local textId = 100

		local text
		if votetype == "votemap" then
			text = "\169000255150Vote for next map"
		elseif votetype == "votecpt" then
			text = "\169000255150Vote for team captain"
		end

		parse("hudtxt2 " .. id .. " " .. textId .. ' "' .. text .. '" ' .. x .. " " .. y .. " 0 1 16")

		for i = 1, #cas.votelist do
			textId = textId + 1
			y = y + 18

			text = cas.votelist[i]
			if votetype == "votecpt" then
				if cas.con[cas.votelist[i]] == true then
					text = player(cas.votelist[i], "name")
				else
					text = "---"
				end
			end

			if cas.voteopt[id] == i then
				text = "\169150255000" .. i .. ". " .. text .. " (" .. cas.percentage(i) .. ")"
			else
				text = "\169000255150" .. i .. ". " .. text .. " (" .. cas.percentage(i) .. ")"
			end

			parse("hudtxt2 " .. id .. " " .. textId .. ' "' .. text .. '" ' .. x .. " " .. y .. " 0 1 16")
		end

		textId = textId + 1
		y = y + 18
		local seconds = cas.votecountdown - os.time(os.date("!*t"))
		text = "\169000255150Vote ends in \169150255000" .. cas.time(seconds)
		parse("hudtxt2 " .. id .. " " .. textId .. ' "' .. text .. '" ' .. x .. " " .. y .. " 0 1 16")
	end
end

function cas.startvote(votetype)
	cas.votelist = {}
	if votetype == "votemap" then
		cas.votelist = cas.mappool
		math.randomseed(os.time())
		while #cas.votelist > 9 do
			table.remove(cas.votelist, math.random(#cas.votelist))
		end
	elseif votetype == "votecpt" then
		local limit = 1
		local plist = player(0, "table")
		for _, id in pairs(plist) do
			if limit < 10 then
				table.insert(cas.votelist, id)
				limit = limit + 1
			end
		end
	end

	for i = 1, #cas.votelist do
		addbind(i)
	end

	timer(1000 * cas.voting_timelimit, "cas.endvote", votetype)
	cas.votecountdown = os.time(os.date("!*t")) + cas.voting_timelimit
	timer(100, "cas.showhud", votetype, 0)
end

function cas.endvote(votetype)
	freetimer("cas.showhud", votetype)
	parse("sv_sound hajt/endvote.ogg")

	local plist = player(0, "table")
	for _, id in pairs(plist) do
		local textId = 100
		parse("hudtxt2 " .. id .. " " .. textId)
		for i = 1, #cas.votelist do
			textId = textId + 1
			parse("hudtxt2 " .. id .. " " .. textId)
		end
		textId = textId + 1
		parse("hudtxt2 " .. id .. " " .. textId)

		local opt = cas.voteopt[id]
		if opt > 0 then
			cas.counted_votes[opt] = cas.counted_votes[opt] + 1
		end
	end

	for i = 1, #cas.votelist do
		removebind(i)
	end

	if votetype == "votemap" then
		local val, key = cas.highest_val(cas.counted_votes)
		if val == 0 then
			msg("\169000255150Not enough players voted")
		else
			parse("map " .. cas.votelist[key])
		end
	elseif votetype == "votecpt" then
		local cpt1 = 0
		local cpt2 = 0
		local val, key = cas.highest_val(cas.counted_votes)
		if val > 0 then
			cpt1 = key
		end
		cas.counted_votes[key] = 0
		local val, key = cas.highest_val(cas.counted_votes)
		if val > 0 then
			cpt2 = key
		end
		local plist = player(0, "table")
		for _, id in pairs(plist) do
			cas.permit = id
			if id == cpt1 and cas.con[cpt1] == true then
				if player(id, "team") < 2 then
					parse("makect " .. id)
				end
				msg(cas.nick(cpt1) .. " \169000255150became captain of team A")
			elseif id == cpt2 and cas.con[cpt2] == true then
				if player(id, "team") ~= 1 then
					parse("maket " .. id)
				end
				msg(cas.nick(cpt2) .. " \169000255150became captain of team B")
			else
				parse("makespec " .. id)
			end
			cas.permit = 0
		end
	end

	for i = 1, 32 do
		cas.voteopt[i] = 0
		cas.counted_votes[i] = 0
	end
	cas.vote = false
end

function cas.addhooks()
	for hook in pairs(cas.hook) do
		addhook(hook, "cas.hook." .. hook, 999)
	end
end

function cas.start1st()
	cas.logs = {}
	cas.logfile = os.time(os.date("!*t")) .. "-" .. map("name")
	cas.status = "1st Half"
	cas.round = 0

	local plist = player(0, "table")
	for _, id in pairs(plist) do
		local name = player(id, "name")
		local ip = player(id, "ip")
		local usgn = player(id, "usgn")
		local steamid = player(id, "steamid")
		local team = player(id, "team")
		cas.pnt("j", id, name, ip, usgn, steamid, team)
	end
end

function cas.start2nd()
	cas.logs = {}
	cas.status = "2nd Half"
	cas.round = cas.mr
	timer(500, "parse", "setteamscores " .. cas.fh_ct .. " " .. cas.fh_tt)

	local plist = player(0, "table")
	for _, id in pairs(plist) do
		local name = player(id, "name")
		local ip = player(id, "ip")
		local usgn = player(id, "usgn")
		local steamid = player(id, "steamid")
		local team = player(id, "team")
		cas.pnt("j", id, name, ip, usgn, steamid, team)
	end
end

function cas.showmoneyhud()
	if tonumber(game("phase")) == 1 then
		freetimer("cas.showmoneyhud")
		for id = 1, 32 do
			parse("hudtxt " .. id)
		end
		return
	end

	for _, id in pairs(player(0, "tableliving")) do
		local winX = player(id, "screenw") / 2
		local winY = player(id, "screenh") / 2
		local scale = math.min(player(id, "screenw") / 640, player(id, "screenh") / 480)

		local team = player(0, "team1living")

		if player(id, "team") == 2 or player(id, "team") == 3 then
			team = player(0, "team2living")
		end

		if player(id, "team") ~= 0 then
			for _, all in pairs(team) do
				local hudX = winX - math.floor(player(id, "x") - player(all, "x")) * scale
				local hudY = winY - math.floor(player(id, "y") - player(all, "y")) * scale
				cas.moneyhud(id, all, player(all, "money"), hudX, hudY)
			end
		end
	end
end

function cas.moneyhud(id, hudid, money, x, y)
	local color = "000255000"

	if player(id, "team") == 1 and money < 3150 then
		color = "255255000"
	end
	
	if player(id, "team") == 2 and money < 3750 then
		color = "255255000"
	end

	if money < 1000 then
		color = "255000000"
	end

	parse("hudtxt2 " .. id .. " " .. hudid .. ' "\169' .. color .. "$" .. money .. '" ' .. x .. " " .. (y - 32) .. " 1")
end

function cas.sendlog()
	local file = cas.logfile
	local data = cas.fh_logs .. "," .. cas.sh_logs
	local handle = io.popen("curl -d \"f=" .. file .. "&d=" .. data .. "\" -X POST http://cs2d.eu/api/parser2.php")
	local result = handle:read("*a")
	msg("\169150255000cs2d.eu/www/matches.php?id=" .. result)
	handle:close()
end

function cas.loadmaps()
	cas.maps = {}
	for name in io.enumdir("maps") do
		local map = name:match("(.*).map")
		if map ~= nil then
			table.insert(cas.maps, map)
		end
	end
end

function cas.reload()
	dofile(cas.path .. "config.lua")
	local plist = player(0, "table")
	for _, id in pairs(plist) do
		local usgn = player(id, "usgn")
		if cas.in_tbl(cas.adminlist, usgn) == false then
			cas.admin[id] = false
		else
			cas.admin[id] = true
		end
		if cas.in_tbl(cas.mutelist, usgn) == false then
			cas.mute[id] = false
		else
			cas.mute[id] = true
		end
		cas.hud(id)
	end
	cas.loadmaps()
	cas.votemap_minutes_over()
	print("config loaded")
end
