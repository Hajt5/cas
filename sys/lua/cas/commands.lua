cas.aliases = {
	["!t"] = "!maket",
	["!ct"] = "!makect",
	["!spec"] = "!makespec",
	["!ft"] = "!freezetime",
	["!sm"] = "!startmoney",
	["!pw"] = "!password",
	["!bc"] = "!broadcast",
	["!rt"] = "!roundtime",
	["!rs"] = "!resetscore",
	["!swap"] = "!switch"
}

cas.cmds["!help"] = {
	syntax = "",
	maxarg = 0,
	alert = false,
	admin = false,
	func = function(id, arguments)
		cas.cmsg2(id, "\169255255255----- Commands -----")
		for cmd in pairs(cas.commands) do
			local syntax = ""
			local alias = ""
			if cas.cmds[cmd]["syntax"] ~= "" then
				syntax = " " .. cas.cmds[cmd]["syntax"]
			end
			local sc = cas.aliases[cmd]
			if sc ~= nil then
				alias = " \169000255150or \169150255000" .. sc .. syntax
			end
			cas.cmsg2(id, "\169150255000" .. cmd .. syntax .. alias)
		end
		msg2(id, "\169000255150List of commands have been printed to the console")
	end
}

cas.cmds["!maps"] = {
	syntax = "",
	maxarg = 0,
	alert = false,
	admin = false,
	func = function(id, arguments)
		cas.cmsg2(id, "\169255255255----- Maps -----")
		for key, map in pairs(cas.maps) do
			cas.cmsg2(id, "\169150255000" .. map)
		end
		msg2(id, "\169000255150List of maps have been printed to the console")
	end
}

cas.cmds["!kick"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if arg1 == nil then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		local adm = player(id, "usgnname")
		local reason = adm .. " says goodbye"
		cas.kick(arg1, reason)
	end
}

cas.cmds["!ban"] = {
	syntax = "<id> <[duration]>",
	maxarg = 2,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		local arg2 = tonumber(arguments[2])
		if not arg1 then
			return false
		end
		if not arg2 then
			arg2 = 0
		end
		if arg2 < 0 or arg2 > 1440 then
			return "Duration must be in the range 0-1440"
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		local adm = player(id, "usgnname")
		local date = os.date("%Y-%m-%d %H:%M:%S")
		local reason = adm .. " says goodbye @ " .. date
		cas.ban(arg1, arg2, reason)
	end
}

cas.cmds["!mute"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		if cas.mute[arg1] == true then
			return "Player is already muted"
		end
		cas.mute[arg1] = true
		table.insert(cas.mutelist, player(arg1, "usgn"))
	end
}

cas.cmds["!unmute"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		if cas.mute[arg1] == false then
			return "Player is not muted"
		end
		cas.mute[arg1] = false
		table.remove(cas.mutelist, player(arg1, "usgn"))
	end
}

cas.cmds["!maket"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		if player(arg1, "team") == 1 then
			return "Player is already in terrorists"
		end
		cas.permit = arg1
		parse("maket " .. arg1)
		cas.permit = 0
	end
}

cas.cmds["!makect"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		if player(arg1, "team") > 1 then
			return "Player is already in counter-terrorists"
		end
		cas.permit = arg1
		parse("makect " .. arg1)
		cas.permit = 0
	end
}

cas.cmds["!makespec"] = {
	syntax = "<id>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if cas.con[arg1] == false then
			return "Player does not exist"
		end
		if player(arg1, "team") == 0 then
			return "Player is already in spectators"
		end
		cas.permit = arg1
		parse("makespec " .. arg1)
		cas.permit = 0
	end
}

cas.cmds["!fow"] = {
	syntax = "<mode>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if arg1 < 0 or arg1 > 3 then
			return "Value must be in the range 0-3"
		end
		if arg1 == tonumber(game("sv_fow")) then
			return "Value is already in use"
		end
		parse("sv_fow " .. arg1)
	end
}

cas.cmds["!freezetime"] = {
	syntax = "<seconds>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if arg1 < 0 or arg1 > 30 then
			return "Value must be in the range 0-30"
		end
		if arg1 == tonumber(game("mp_freezetime")) then
			return "Value is already in use"
		end
		cas.ft = arg1
		parse("mp_freezetime " .. arg1)
	end
}

cas.cmds["!roundtime"] = {
	syntax = "<minutes>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if arg1 < 0 or arg1 > 100 then
			return "Value must be in the range 0-100"
		end
		if arg1 == tonumber(game("mp_roundtime")) then
			return "Value is already in use"
		end
		parse("mp_roundtime " .. arg1)
	end
}

cas.cmds["!startmoney"] = {
	syntax = "<money>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = tonumber(arguments[1])
		if not arg1 then
			return false
		end
		if arg1 < 0 or arg1 > 16000 then
			return "Value must be in the range 0-16000"
		end
		if arg1 == tonumber(game("mp_startmoney")) then
			return "Value is already in use"
		end
		parse("mp_startmoney " .. arg1)
	end
}

cas.cmds["!map"] = {
	syntax = "<map>",
	maxarg = false,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if #arguments == 0 then
			return false
		end
		local arg1 = table.concat(arguments, " ")
		if cas.in_tbl(cas.maps, arg1) == false then
			return "Map does not exist on the server"
		end
		parse("map " .. arg1)
	end
}

cas.cmds["!password"] = {
	syntax = "<[password]>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = arguments[1]
		if arg1 == nil then
			arg1 = ""
		end
		if arg1 == game("sv_password") then
			return "Value is already in use"
		end
		parse("sv_password " .. arg1)
	end
}

cas.cmds["!broadcast"] = {
	syntax = "<message>",
	maxarg = false,
	alert = false,
	admin = true,
	func = function(id, arguments)
		if #arguments == 0 then
			return false
		end
		msg("\169255255255" .. player(id, "name") .. ": " .. table.concat(arguments, " "))
	end
}

cas.cmds["!live"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.between then
			return "You have to wait until next round"
		end
		cas.knives = false
		cas.warmup = false
		parse("sv_gamemode 0")
		parse("mp_freezetime " .. cas.ft)
		parse("mp_randomspawn 0")
		parse("restart")
		if cas.mixmatch == false then
			return
		end
		local plist = player(0, "table")
		if #plist >= cas.required and cas.state == 0 then
			cas.start1st()
		elseif cas.state == 1 then
			cas.start1st()
		elseif cas.state == 2 or cas.state == 3 then
			cas.start2nd()
		end
	end
}

cas.cmds["!knife"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.between then
			return "Wait for the next round"
		end
		cas.knives = true
		cas.warmup = false
		cas.ft = tonumber(game("mp_freezetime"))
		parse("sv_gamemode 0")
		parse("mp_freezetime 0")
		parse("mp_randomspawn 0")
		parse("restart")
	end
}

cas.cmds["!warmup"] = {
	syntax = "<wpn,...>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = arguments[1]
		if not arg1 then
			return false
		end
		if cas.between then
			return "Wait for the next round"
		end
		cas.warmup_weapons = {}
		cas.warmup_armor = 0
		local allowed = {
			1, 2, 3, 4, 5, 6, 10, 11, 20, 21, 22, 23, 24, 30, 31, 32, 33, 34, 35, 36,
			37, 38, 39, 91, 40, 45, 46, 47, 48, 49, 88, 90, 50, 69, 74, 78, 85, 51, 52,
			53, 54, 72, 73, 75, 76, 86, 89, 77, 87, 41, 57, 58, 59, 60, 79, 80, 81, 82,
			83, 84
		}
		local arr = cas.split(arg1, ",")
		for _, wpn in pairs(arr) do
			local wpn = tonumber(wpn)
			if not wpn then
				return false
			end
			if cas.in_tbl(cas.warmup_weapons, wpn) then
				return "The item was specified more than once"
			end
			if cas.in_tbl(allowed, wpn) == false then
				return "The item you specified is not allowed in warmup"
			end
			if wpn == 57 or wpn == 58 or wpn >= 79 and wpn <= 84 then
				if cas.warmup_armor == 0 then
					cas.warmup_armor = wpn
				else
					return "The armor was specified more than once"
				end
			else
				table.insert(cas.warmup_weapons, wpn)
			end
		end
		if #cas.warmup_weapons == 0 and cas.warmup_armor == 0 then
			return "Please specify at least one item"
		end
		cas.knives = false
		cas.warmup = true
		parse("sv_gamemode 2")
		parse("mp_freezetime 0")
		parse("mp_randomspawn 1")
		parse("restart")
	end
}

cas.cmds["!resetscore"] = {
	syntax = "",
	maxarg = 0,
	alert = false,
	admin = false,
	func = function(id, arguments)
		parse("setmvp " .. id .. " 0")
		parse("setscore " .. id .. " 0")
		parse("setassists " .. id .. " 0")
		parse("setdeaths " .. id .. " 0")
		msg2(id, "\169000255150You have just reset your score")
	end
}

cas.cmds["!specall"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local team1 = player(0, "team1")
		local team2 = player(0, "team2")
		local amount = #team1 + #team2
		if amount == 0 then
			return "Teams are empty"
		end
		local plist = player(0, "table")
		for _, i in pairs(plist) do
			cas.permit = i
			parse("makespec " .. i)
			cas.permit = 0
		end
	end
}

cas.cmds["!lock"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.lock == true then
			return "Teams are already locked"
		end
		cas.lock = true
	end
}

cas.cmds["!unlock"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.lock == false then
			return "Teams are not locked"
		end
		cas.lock = false
	end
}

cas.cmds["!switch"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		cas.swap()
	end
}

cas.cmds["!reroute"] = {
	syntax = "<address>",
	maxarg = 1,
	alert = true,
	admin = true,
	func = function(id, arguments)
		local arg1 = string.lower(arguments[1])
		local plist = player(0, "table")
		for _, i in pairs(plist) do
			parse("reroute " .. i .. " " .. arg1)
		end
	end
}

cas.cmds["!votecpt"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.vote > 0 then
			return "Vote is already in progress"
		end
		cas.vote = 2
		parse("sv_sound hajt/countdown.ogg")
		timer(3000, "cas.startvote")
	end
}

cas.cmds["!votemap"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		if cas.vote > 0 then
			return "Vote is already in progress"
		end
		cas.vote = 1
		parse("sv_sound hajt/countdown.ogg")
		timer(3000, "cas.startvote")
	end
}

cas.cmds["!reload"] = {
	syntax = "",
	maxarg = 0,
	alert = true,
	admin = true,
	func = function(id, arguments)
		cas.reload()
	end
}
