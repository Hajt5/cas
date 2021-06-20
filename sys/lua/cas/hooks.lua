function cas.hook.join(id)
	cas.con[id] = true
	local name = player(id, "name")
	local ip = player(id, "ip")
	local usgn = player(id, "usgn")
	local steamid = player(id, "steamid")

	msg2(id, "\169000255150Welcome on the server \169150255000" .. cas.escape(name))
	parse("sv_sound2 " .. id .. " hajt/welcome.ogg")

	for file in pairs(cas.check_files) do
		reqcld(id, 4, file)
	end

	if cas.in_tbl(cas.adminlist, usgn) ~= false then
		cas.admin[id] = true
		msg2(id, "\169000255150You are logged in as \169150255000admin")
	end

	if cas.in_tbl(cas.mutelist, usgn) ~= false then
		cas.mute[id] = true
	end

	cas.hud(id)
	cas.pnt("j", id, name, ip, usgn, steamid, 0)
end

function cas.hook.say(id, message)
	return cas.say(id, message, false)
end

function cas.hook.sayteam(id, message)
	return cas.say(id, message, true)
end

function cas.hook.leave(id, reason)
	if cas.con[id] == false then
		return
	end
	cas.admin[id] = false
	cas.mute[id] = false
	cas.damage[id] = 0
	cas.total[id] = 0
	cas.mvp[id] = 0
	cas.con[id] = false
	cas.voteopt[id] = 0
	cas.counted_votes[id] = 0
	cas.pnt("l", id, reason, cas.damage[id])
end

function cas.hook.team(id, team)
	if cas.lock == true and cas.permit ~= id then
		msg2(id, "\169000255150Teams are locked")
		return 1
	end
	cas.pnt("t", id, team)
end

function cas.hook.clientdata(id, mode, data1, data2)
	if mode ~= 4 then
		return
	end

	if cas.check_files[data1] ~= data2 then
		cas.kick(id, "Modified file " .. data1 .. " " .. data2)
	end
end

function cas.hook.startround(mode)
	timer(100, "cas.showmoneyhud", "", 0)
	cas.between = false
	cas.round = cas.round + 1

	if cas.knives == true then
		local itemlist = item(0, "table")
		for _, id in pairs(itemlist) do
			parse("removeitem " .. id)
		end
	end

	local plist = player(0, "table")
	for _, id in pairs(plist) do
		if cas.always16k == true then
			parse("setmoney " .. id .. " 16000")
		end
		if cas.status == "1st Half" or cas.status == "2nd Half" then
			cas.pntdamage(id)
		end
		cas.hud(id)
		cas.damage[id] = 0
		cas.mvp[id] = player(id, "mvp")
	end

	if cas.votemap_rounds > 0 then
		if cas.votemap_rounds == cas.round then
			cas.vote = true
			parse("sv_sound hajt/countdown.ogg")
			timer(3000, "cas.startvote", "votemap")
			timer(18500, "parse", "restart")
		else
			local txt = cas.votemap_rounds - cas.round
			if txt == 1 then
				txt = "next round"
			else
				txt = txt .. " rounds"
			end
			msg("\169000255150Vote for next map will start in \169150255000" .. txt)
		end
	end

	cas.pnt("sr", cas.round)
end

function cas.hook.endround(mode)
	cas.between = true

	if mode == 3 then
		cas.round = cas.round - 1
		return
	end

	local plist = player(0, "table")
	if mode == 4 or mode == 5 then
		cas.round = 0
		cas.ct_score = 0
		cas.tt_score = 0
		for _, id in pairs(plist) do
			cas.total[id] = 0
		end
		return
	end

	for _, id in pairs(plist) do
		cas.total[id] = cas.total[id] + cas.damage[id]
		if player(id, "team") > 0 then
			local txt = ""
			if cas.total[id] > 0 then
				txt = " \169000255150(total \169150255000" .. cas.total[id] .. " HP\169000255150)"
			end
			msg2(id, "\169000255150Damage dealt \169150255000" .. cas.damage[id] .. " HP" .. txt)
		end
		if player(id, "mvp") > cas.mvp[id] then
			cas.recentmvp = id
		end
	end

	local val, key = cas.highest_val(cas.damage)
	if val > 0 then
		msg(cas.nick(key) .. " \169000255150highest damage \169150255000" .. val .. " HP")
	end

	if cas.round > 1 and cas.round > cas.mr then
		val, key = cas.highest_val(cas.total)
		if val > 0 then
			msg(cas.nick(key) .. " \169000255150highest total damage \169150255000" .. val .. " HP")
		end
	end

	if cas.status == "1st Half" or cas.status == "2nd Half" then
		if cas.in_tbl({1, 10, 12, 20, 30, 40, 50, 60}, mode) then
			cas.tt_score = cas.tt_score + 1
		elseif cas.in_tbl({2, 11, 21, 22, 31, 41, 51, 61}, mode) then
			cas.ct_score = cas.ct_score + 1
		end
	end

	if cas.status == "1st Half" then
		if cas.ct_score + cas.tt_score == cas.mr then
			cas.fh_ct = cas.ct_score
			cas.fh_tt = cas.tt_score
			cas.status = "Halftime"
			timer(500, "cas.swap")
			for _, id in pairs(plist) do
				cas.pntdamage(id)
				cas.hud(id)
			end
			cas.pnt("er", mode, cas.recentmvp)
			cas.pnt("ht")
			cas.fh_logs = table.concat(cas.logs, ",")
			return
		end
	elseif cas.status == "2nd Half" then
		local ct = cas.fh_tt + cas.ct_score
		local tt = cas.fh_ct + cas.tt_score
		local gg = cas.mr + 1
		if ct == cas.mr and tt == cas.mr or ct == gg or tt == gg then
			cas.ct_score = 0
			cas.tt_score = 0
			cas.fh_ct = 0
			cas.fh_tt = 0
			cas.status = nil
			for _, id in pairs(plist) do
				cas.pntdamage(id)
				cas.hud(id)
			end
			cas.pnt("er", mode, cas.recentmvp)
			cas.sh_logs = table.concat(cas.logs, ",")
			if cas.upload_logs == 1 then
				timer(1000, "cas.sendlog")
			end
			return
		end
	end

	cas.pnt("er", mode, cas.recentmvp)
end

function cas.hook.buy(id, weapon)
	if cas.knives == true or cas.warmup == true then
		return 1
	end
end

function cas.hook.bombplant(id)
	if cas.knives == true then
		return 1
	end
end

function cas.hook.spawn(id)
	if cas.knives == true then
		return "x"
	end

	if cas.warmup == true then
		local armor = 0
		if cas.warmup_armor >= 79 and cas.warmup_armor <= 84 then
			armor = cas.warmup_armor + 122
		elseif wpn == 57 then
			armor = 65
		elseif wpn == 58 then
			armor = 100
		end
		parse("setarmor " .. id .. " " .. armor)
		if #cas.warmup_weapons == 0 then
			return "x"
		else
			return table.concat(cas.warmup_weapons, ",")
		end
	end

	cas.pnt("s", id)
end

function cas.hook.hit(id, source, weapon, hpdmg)
	if source == 0 then
		return
	end
	cas.damage[source] = cas.damage[source] + hpdmg
end

function cas.hook.kill(killer, victim, weapon, x, y, object, assistant)
	local killer_x = math.floor(player(killer, "x"))
	local killer_y = math.floor(player(killer, "y"))
	cas.pnt("k", killer, killer_x, killer_y, weapon, victim, x, y, assistant)
end

function cas.hook.clientsetting(id)
	cas.hud(id)
end

function cas.hook.name(id, oldname, newname, forced)
	if forced == 1 then
		msg(cas.nick(id) .. " \169000255150changed name to \169150255000" .. cas.escape(newname))
		cas.pnt("n", id, newname)
		return 0
	end
	parse("setname " .. id .. ' "' .. newname .. '" 1')
	return 1
end

function cas.hook.key(id, key, state)
	if state == 0 or cas.voteopt[id] > 0 then
		return
	end
	parse("sv_sound2 " .. id .. " hajt/menuselect.ogg")
	cas.voteopt[id] = tonumber(key)
end

function cas.hook.rcon(cmds)
	if cmds == "reload" then
		cas.reload()
		return 1
	end
end
