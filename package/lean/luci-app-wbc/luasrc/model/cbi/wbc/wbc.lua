-- EZWifibroadcast on OpenWrt
-- Dirty mod by @libc0607 (libc0607@gmail.com)

m = Map("wbc", translate("EZWBC Settings"), '')

require "luci.sys"
require "nixio.fs"

-- add all possible frequency to freq_list
local wlan_dev_list = {}
local freq_list = {}
for k, v in ipairs(luci.sys.net.devices()) do
	if string.match(v, "wlan") then
		wlan_dev_list[#wlan_dev_list+1] = v
		local iwi = luci.sys.wifi.getiwinfo(v)
		for i,j in ipairs(iwi.freqlist) do 
			freq_list[#freq_list+1] = iwi.freqlist[i].mhz 
		end
	end
end
-- Get all /dev/tty* to tty_list
local tty_list = {}
for e in nixio.fs.dir("/dev") do 
	if string.match(e, "tty") then
		tty_list[#tty_list+1] = e
	end
end

function wbc.on_commit(self)
	luci.sys.call("uci set wbc.@luci[-1].configured=1")
	luci.sys.call("uci commit")
	luci.sys.call("rm -rf /tmp/luci-*cache")
end



-- wbc.wbc: Global settings
s_wbc = m:section(TypedSection, "wbc", translate("EZ-Wifibroadcast Settings"))
s_wbc.anonymous = true
-- wbc.wbc.enable: Enable
s_wbc:option(Flag, "enable", translate("Enable EZ-Wifibroadcast"))
-- wbc.wbc.mode: Transfer Mode
o_wbc_mode = s_wbc:option(Value, "mode", translate("Transfer Mode"))
o_wbc_mode.rmempty = false
o_wbc_mode:value("tx", translate("Transceiver"))
o_wbc_mode:value("rx", translate("Receiver"))
o_wbc_mode.default = "tx"


-- wbc.nic: Wi-Fi settings
s_nic = m:section(TypedSection, "nic", translate("Wi-Fi Card Settings"))
s_nic.anonymous = true
-- wbc.nic.iface: Wireless Interface
o_nic_iface = s_nic:option(Value, "iface", translate("Wireless Interface"))
o_nic_iface.rmempty = false
for k,v in ipairs(wlan_dev_list) do 
	o_nic_iface:value(v) 
end
o_nic_iface.default = "wlan0"
-- wbc.nic.freq: Frequency
o_nic_freq = s_nic:option(Value, "freq", translate("Frequency"))
o_nic_freq.rmempty = false
for k,v in ipairs(freq_list) do 
	o_nic_freq:value(v, v.." MHz") 
end
o_nic_freq.default = 2432
-- wbc.nic.chanbw: Channel Bandwidth
o_cnic_hanbw = s_nic:option(Value, "chanbw", translate("Channel Bandwidth"))
o_nic_chanbw.rmempty = false
o_nic_chanbw:value(5,  "5 MHz")
o_nic_chanbw:value(10, "10 MHz")
o_nic_chanbw:value(20, "20 MHz")


-- wbc.video: Video transfer settings
s_video = m:section(TypedSection, "nic", translate("Video Transfer Settings"))
s_video.anonymous = true
-- wbc.video.enable: Video Transfer Enable
s_video:option(Flag, "enable", translate("Enable Video Transfer"))
-- wbc.video.listen_port: Listen on port
o_video_listen_port = s_video:option(Value, "listen_port", translate("Listen On Local Port"))
o_video_listen_port.datatype = "portrange(1024,65535)"
-- wbc.video.send_ip: Send Video Stream to IP
o_video_send_ip = s_video:option(Value, "send_ip", translate("Send Video Stream to IP"))
o_video_send_ip.datatype = "ipaddr"
-- wbc.video.send_port: Send Video Stream to Port
o_video_send_port = s_video:option(Value, "send_port", translate("Send Video Stream to Port"))
o_video_send_port.datatype = "portrange(1024,65535)"
-- wbc.video.datanum: Data packets in a block
o_video_datanum = s_video:option(Value, "datanum", translate("Data packets in a block"))
o_video_datanum.default = 8
o_video_datanum.datatype = "range(1,32)"
-- wbc.video.fecnum: FEC packets in a block
o_video_fecnum = s_video:option(Value, "fecnum", translate("FEC packets in a block"))
o_video_fecnum.default = 4
o_video_fecnum.datatype = "range(1,32)"
-- wbc.video.packetsize: Bytes per packet
o_video_packetsize = s_video:option(Value, "packetsize", translate("Bytes per packet"))
o_video_packetsize.default = 1024
o_video_packetsize.datatype = "range(32,1450)"
-- wbc.video.port: Port on Air
o_video_port = s_video:option(Value, "port", translate("Port on Air"))
o_video_port.default = 0
o_video_port.datatype = "range(0,127)"
-- wbc.video.frametype: Frame Type
o_video_frametype = s_video:option(Value, "frametype", translate("Frame Type"))
o_video_frametype:value(0, "DATA Short")
o_video_frametype:value(1, "DATA Standard")
o_video_frametype:value(2, "RTS")
-- wbc.video.bitrate: Bit Rate
o_video_bitrate = s_video:option(Value, "bitrate", translate("Bit Rate"))
o_video_bitrate:value(6, "6 Mbps")
o_video_bitrate:value(12, "12 Mbps")
o_video_bitrate:value(18, "18 Mbps")
o_video_bitrate:value(24, "24 Mbps")
o_video_bitrate:value(36, "36 Mbps")
o_video_bitrate.default = 24
-- wbc.video.rxbuf: RX Buf Size
o_video_rxbuf = s_video:option(Value, "rxbuf", translate("RX Buf Size"))
o_video_rxbuf.default = 1
o_video_rxbuf.datatype = "range(0,32)"


-- wbc.rssi: RSSI settings
s_rssi = m:section(TypedSection, "rssi", translate("RSSI Settings"))
s_rssi.anonymous = true
-- wbc.rssi.enable: RSSI Enable
s_rssi:option(Flag, "enable", translate("Enable RSSI"))


-- wbc.telemetry: Telemetry settings
s_telemetry = m:section(TypedSection, "telemetry", translate("Telemetry Settings"))
s_telemetry.anonymous = true
-- wbc.telemetry.enable: Telemetry Enable
s_telemetry:option(Flag, "enable", translate("Enable Telemetry"))
-- wbc.telemetry.uart: Telemetry Input UART Interface
o_telemetry_uart = s_telemetry:option(Value, "uart", translate("Telemetry Input UART Interface"))
for k,v in ipairs(tty_list) do 
	o_telemetry_uart:value(v) 
end
o_telemetry_uart.default = "/dev/ttyUSB0"
-- wbc.telemetry.baud: Telemetry UART Baud rate
o_telemetry_baud = s_telemetry:option(Value, "baud", translate("Telemetry UART Baud Rate"))
o_telemetry_baud:value(9600, "9600 bps")
o_telemetry_baud:value(19200, "19200 bps")
o_telemetry_baud:value(38400, "38400 bps")
o_telemetry_baud:value(57600, "57600 bps")
o_telemetry_baud:value(115200, "115200 bps")
o_telemetry_baud.default = 57600
-- wbc.telemetry.port: Telemetry Port on Air
o_telemetry_port = s_telemetry:option(Value, "port", translate("Telemetry Port on Air"))
o_telemetry_port.default = 1
o_telemetry_port.datatype = "range(0,127)"
-- wbc.telemetry.cts: Telemetry TX CTS
o_telemetry_cts = s_telemetry:option(Value, "cts", translate("Telemetry TX CTS Mode"))
o_telemetry_cts:value(0, translate("CTS Protection Disabled"))
o_telemetry_cts:value(1, translate("CTS Protection Enabled"))
o_telemetry_cts.default = 0
-- wbc.telemetry.retrans: Telemetry TX Retransmission Count
o_telemetry_retrans = s_telemetry:option(Value, "retrans", translate("Telemetry TX Retransmission Count"))
o_telemetry_retrans:value(1, translate("Send each frame once"))
o_telemetry_retrans:value(2, translate("Twice"))
o_telemetry_retrans:value(3, translate("Three times"))
o_telemetry_retrans.default = 2
-- wbc.telemetry.proto: Telemetry TX Protocol
o_telemetry_proto = s_telemetry:option(Value, "proto", translate("Telemetry Protocol"))
o_telemetry_proto:value(0, translate("Mavlink"))
o_telemetry_proto:value(1, translate("Generic"))
o_telemetry_proto.default = 0
-- wbc.telemetry.bitrate: Telemetry TX Bit Rate
o_telemetry_bitrate = s_telemetry:option(Value, "bitrate", translate("Telemetry TX Bitrate"))
o_telemetry_bitrate:value(6, "6 Mbps")
o_telemetry_bitrate:value(12, "12 Mbps")
o_telemetry_bitrate:value(18, "18 Mbps")
o_telemetry_bitrate:value(24, "24 Mbps")
o_telemetry_bitrate:value(36, "36 Mbps")
o_telemetry_bitrate.default = 24
-- wbc.telemetry.send_ip: Telemetry RX Send to IP	
o_telemetry_send_ip = s_telemetry:option(Value, "send_ip", translate("Send Telemetry Data to IP"))
o_telemetry_send_ip.datatype = "ipaddr"
-- wbc.telemetry.send_port: Telemetry RX Send to Port
o_telemetry_send_port = s_telemetry:option(Value, "send_port", translate("Send Telemetry Data to Port"))
o_telemetry_send_port.datatype = "portrange(1024,65535)"


-- wbc.uplink: Uplink settings
s_uplink = m:section(TypedSection, "uplink", translate("Uplink Settings"))
s_uplink.anonymous = true
-- wbc.uplink.enable: Uplink Enable
s_uplink:option(Flag, "enable", translate("Enable Uplink"))
-- wbc.uplink.port: Uplink Port on Air
o_uplink_port = s_uplink:option(Value, "port", translate("Uplink Port on Air"))
o_uplink_port.default = 3
o_uplink_port.datatype = "range(0,127)"
-- wbc.uplink.cts: Uplink TX CTS
o_uplink_cts = s_uplink:option(Value, "cts", translate("Uplink TX CTS Mode"))
o_uplink_cts:value(0, translate("CTS Protection Disabled"))
o_uplink_cts:value(1, translate("CTS Protection Enabled"))
o_uplink_cts.default = 0
-- wbc.uplink.retrans: Uplink TX Retransmission Count
o_uplink_retrans = s_uplink:option(Value, "retrans", translate("Uplink TX Retransmission Count"))
o_uplink_retrans:value(1, translate("Send each frame once"))
o_uplink_retrans:value(2, translate("Twice"))
o_uplink_retrans:value(3, translate("Three times"))
o_uplink_retrans.default = 2
-- wbc.uplink.bitrate: Uplink TX Bit Rate
o_uplink_bitrate = s_uplink:option(Value, "bitrate", translate("Uplink TX Bitrate"))
o_uplink_bitrate:value(6, "6 Mbps")
o_uplink_bitrate:value(12, "12 Mbps")
o_uplink_bitrate:value(18, "18 Mbps")
o_uplink_bitrate:value(24, "24 Mbps")
o_uplink_bitrate:value(36, "36 Mbps")
o_uplink_bitrate.default = 6
-- wbc.uplink.uart: Uplink Input UART Interface (Ground)
o_uplink_uart = s_uplink:option(Value, "uart", translate("Uplink Input UART Interface"))
for k,v in ipairs(tty_list) do 
	o_uplink_uart:value(v) 
end
o_uplink_uart.default = "/dev/ttyUSB0"
-- wbc.uplink.baud: Uplink UART Baud rate
o_uplink_baud = s_uplink:option(Value, "baud", translate("Uplink UART Baud Rate"))
o_uplink_baud:value(9600, "9600 bps")
o_uplink_baud:value(19200, "19200 bps")
o_uplink_baud:value(38400, "38400 bps")
o_uplink_baud:value(57600, "57600 bps")
o_uplink_baud:value(115200, "115200 bps")
o_uplink_baud.default = 57600
-- wbc.uplink.proto: Uplink TX Protocol
o_uplink_proto = s_uplink:option(Value, "proto", translate("Uplink Protocol"))
o_uplink_proto:value(0, translate("Mavlink"))
o_uplink_proto:value(1, translate("Generic"))
o_uplink_proto.default = 0
-- wbc.uplink.listen_port: Listen on port
o_uplink_listen_port = s_uplink:option(Value, "listen_port", translate("Listen On Local Port"))
o_uplink_listen_port.datatype = "portrange(1024,65535)"





--[[
-- Encrypt Enable
s:option(Flag, "encrypt_enable", translate("Enable Encrypt"))
-- What should be encrypted
o_encrypt_what = s:option(Value, "encrypt_what", translate("What should be encrypted"))
o_encrypt_what.rmempty = false
o_encrypt_what:value("V", translate("Video Stream Only"))
o_encrypt_what:value("T", translate("Telemetry Only"))
o_encrypt_what:value("A", translate("Video Stream and Telemetry"))
o_encrypt_what:depends("encrypt_enable", 1)
-- Encrypt Method
o_method = s:option(Value, "method", translate("Encrypt Method"))
o_method.rmempty = false
o_method:value("aes-128-cfb")
o_method:value("blowfish")
o_method.default = "blowfish"
o_method:depends("encrypt_enable", 1)
-- Password
o_password = s:option(Value, "password", translate("Password"))
o_password.rmempty = false
o_password:depends("encrypt_enable", 1)
]]



return m
