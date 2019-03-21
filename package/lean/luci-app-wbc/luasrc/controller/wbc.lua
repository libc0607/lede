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
	local mainorder = uci:get_first("wbc", "luci", "mainorder", 10)
	if not uci:get_first("wbc", "luci", "configured", false) then
		entry({"admin", "wbc"}, 				alias("admin", "wbc", "settings"), 	translate("EZWBC Settings"), mainorder)
		entry({"admin", "wbc", "settings"}, 	cbi("wbc/wbc"), 					translate("Settings"), 10).leaf = true
		entry({"admin", "wbc", "status"}, 		call("action_status"), 				translate("Status"), 20).leaf = true
	else
		entry({"admin", "wbc"}, 				alias("admin", "wbc", "status"), 	translate("EZWBC Settings"), mainorder)
		entry({"admin", "wbc", "status"}, 		call("action_status"), 				translate("Status"), 10 ).leaf = true
		entry({"admin", "wbc", "settings"}, 	cbi("wbc/wbc"), 					translate("Settings"), 20).leaf = true
	end
	entry({"admin", "wbc", "logs"}, 			template("wbc/logs"), 				translate("Log"), 30).leaf = true
	entry({"admin", "wbc", "about"}, 			call("action_about"), 				translate("About"), 40).leaf = true
	
	-- APIs
	entry({"admin", "wbc", "log"}, 				call("get_log"))
	entry({"admin", "wbc", "netstat"}, 			call("get_netstat"))
	entry({"admin", "wbc", "tx_measure"}, 		call("get_tx_measure"))
	-- To do
	--entry({"admin", "wbc", "set_wireless"}, 	call("set_wireless"))		-- TBD
	--entry({"admin", "wbc", "set_pwd"}, 			call("set_pwd"))			-- TBD
	--entry({"admin", "wbc", "restart"}, 			call("restart"))			-- TBD
	--entry({"admin", "wbc", "wireless_stat"}, 	call("wireless_stat"))		-- TBD
end

function get_log()
	local send_log_lines = 100
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

function action_about()
	luci.template.render("wbc/about")
end

function action_status()
	luci.template.render("wbc/status")
end

function get_tx_measure()
	local result = tonumber(sys.exec("/etc/init.d/wbc measure"))
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
