module("luci.controller.wbc", package.seeall)

http = require "luci.http"
fs = require "nixio.fs"
sys  = require "luci.sys"

log_file = "/tmp/wbc.log"

function index()
	if not fs.access("/etc/config/wbc") then
		return
	end
	local uci = require "luci.model.uci".cursor()

	entry({"admin", "wbc"}, 				alias("admin", "wbc", "settings"), 	translate("YJSNPI-Broadcast"), 90)
	entry({"admin", "wbc", "settings"}, 	cbi("wbc/wbc"), 					translate("Settings"), 10).leaf = true
	entry({"admin", "wbc", "log"}, 			call("get_log"))

	-- For auto settings at different distance
	-- use luci-mod-rpc
	entry({"admin", "wbc", "netstat"}, 			call("get_netstat"))
	entry({"admin", "wbc", "tx_measure"}, 		call("get_tx_measure"))	
	entry({"admin", "wbc", "wireless"}, 		call("set_wireless"))	
	entry({"admin", "wbc", "fec"}, 				call("set_fec"))			
	entry({"admin", "wbc", "bitrate"}, 			call("set_bitrate"))	
	entry({"admin", "wbc", "packetsize"}, 		call("set_packetsize"))	
	entry({"admin", "wbc", "port"}, 			call("set_port"))		
	entry({"admin", "wbc", "check_alive"}, 		call("check_alive"))	
	entry({"admin", "wbc", "restart"}, 			call("wbc_restart"))	
	entry({"admin", "wbc", "check_config"}, 	call("check_config"))	
	entry({"admin", "wbc", "get_initconfig"}, 	call("get_initconfig"))	


end

function no_n(s)
	local a = string.find(s, "\n")
	return a and string.sub(s, 1, a-1) or nil
end

function get_log()
	local send_log_lines = 50
	local li = tonumber(luci.http.formvalue("lines"))
	if li then send_log_lines = li end
	if fs.access(log_file) then
		client_log = sys.exec("tail -n "..send_log_lines.." " .. log_file)
	else
		client_log = "Unable to access the log file!"
	end
	http.prepare_content("text/plain; charset=utf-8")
	http.write(client_log)
	http.close()
end

function set_wireless()
	local w_freq = tonumber(luci.http.formvalue("freq")) 
	local w_chanbw = tonumber(luci.http.formvalue("chanbw"))
	local j = {}
	-- todo: should use uci.cursor
	if w_freq then
		sys.exec("uci set wbc.nic.freq="..w_freq)
	end
	if w_chanbw then
		sys.exec("uci set wbc.nic.chanbw="..w_chanbw)
	end	
	sys.exec("uci commit")
	j.freq = no_n(sys.exec("uci get wbc.nic.freq"))
	j.chanbw = no_n(sys.exec("uci get wbc.nic.chanbw"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function set_fec()
	local w_d = tonumber(luci.http.formvalue("datanum")) 
	local w_f = tonumber(luci.http.formvalue("fecnum"))
	local j = {}
	-- todo: should use uci.cursor
	if w_d then
		sys.exec("uci set wbc.video.datanum="..w_d)
	end
	if w_f then
		sys.exec("uci set wbc.video.fecnum="..w_f)
	end	
	sys.exec("uci commit")
	j.datanum = no_n(sys.exec("uci get wbc.video.datanum"))
	j.fecnum = no_n(sys.exec("uci get wbc.video.fecnum"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function set_bitrate()
	local w_bitrate = tonumber(luci.http.formvalue("bitrate")) 
	local j = {}
	-- todo: should use uci.cursor
	if w_bitrate then
		sys.exec("uci set wbc.video.bitrate="..w_bitrate)
	end
	sys.exec("uci commit")
	j.bitrate = no_n(sys.exec("uci get wbc.video.bitrate"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function set_packetsize()
	local w_packetsize = tonumber(luci.http.formvalue("packetsize")) 
	local j = {}
	-- todo: should use uci.cursor
	if w_packetsize then
		sys.exec("uci set wbc.video.packetsize="..w_packetsize)
	end
	sys.exec("uci commit")
	j.packetsize = no_n(sys.exec("uci get wbc.video.packetsize"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function set_port()
	local w_port = tonumber(luci.http.formvalue("port")) 
	local j = {}
	-- todo: should use uci.cursor
	if w_port then
		sys.exec("uci set wbc.video.port="..w_port)
	end
	sys.exec("uci commit")
	j.port = no_n(sys.exec("uci get wbc.video.port"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function wbc_restart()
	local j = {}
	local res = ""
	if tostring(luci.http.formvalue("s")) == "Oniichan" then
		res = sys.exec("/etc/init.d/wbc restart")
		j.stat = "Daisuki"
	else
		j.stat = "Hentai"
	end
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function action_about()
	luci.template.render("wbc/about")
end

function action_status()
	luci.template.render("wbc/status")
end

function get_tx_measure()
	local result = tonumber(no_n(sys.exec("/etc/init.d/ezwifibroadcast measure")))
	local tx_measure = {}
	if result == nil then
		tx_measure.stat = 'Error'
	else
		tx_measure.stat = 'Success'
	end
	tx_measure.speed = result
	http.prepare_content("application/json")
	http.write_json(tx_measure)
	http.close()
end

function get_netstat()
	local hcontent = sys.exec("wget -O- http://whatismyip.akamai.com 2>/dev/null | head -n1")
	local nstat = {}
	if hcontent == '' then
		nstat.stat = 'no_internet'
	elseif hcontent:find("(%d+)%.(%d+)%.(%d+)%.(%d+)") then
		nstat.stat = 'internet'
	else
		nstat.stat = 'no_login'
	end
	http.prepare_content("application/json")
	http.write_json(nstat)
	http.close()
end

function check_alive() 
	local j = {}
	-- todo: should use uci.cursor
	j.alive = no_n(sys.exec("/usr/sbin/check_alive"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function check_config() 
	local j = {}
	-- todo: should use uci.cursor
	j.timestamp = no_n(sys.exec("cat /var/run/wbc/restart_timestamp")) or "0"
	j.configmd5 = no_n(sys.exec("cat /var/run/wbc/restart_config_md5sum")) or "0"
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function get_initconfig()
	local j = {}
	-- todo: should use uci.cursor
	j.fps = no_n(sys.exec("uci get wbc.video.fps"))
	j.imgsize = no_n(sys.exec("uci get wbc.video.imgsize"))
	j.bitrate = no_n(sys.exec("uci get wbc.video.bitrate_mode") == "auto\n" and sys.exec("cat /tmp/bitrate_kbit") or sys.exec("uci get wbc.video.bitrate_manual")) *1024
	j.keyframerate = no_n(sys.exec("uci get wbc.video.keyframerate"))
	j.videoport = no_n(sys.exec("uci get wbc.video.mode") == "tx\n" and sys.exec("uci get wbc.video.listen_port") or sys.exec("uci get wbc.video.send_ip_port|cut -d ':' -f 2"))
	j.teleport = no_n(sys.exec("uci get wbc.telemetry.send_ip_port|cut -d ':' -f 2"))
	j.rssiport = no_n(sys.exec("uci get wbc.rssi.send_ip_port|cut -d ':' -f 2"))
	j.extraparams = no_n(sys.exec("uci get wbc.video.extraparams"))
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end