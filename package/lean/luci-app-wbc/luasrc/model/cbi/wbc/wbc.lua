-- YJSNPI-Broadcast
-- Another EZ-WifiBroadcast Mod
-- Dirty mod by @libc0607 (libc0607@gmail.com)

m = Map("wbc", translate("YJSNPI-Broadcast"), 
			translate("Another <a href=\"https://github.com/rodizio1/EZ-WifiBroadcast\">rodizio1/EZ-WifiBroadcast</a> Mod")
			.."<br />"..translate("Kusai Digital HD Video Transmission")
			.."<br />"..translate("<a href=\"https://github.com/libc0607/YJSNPI-Broadcast\">Github Homepage</a>")
			)

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
		tty_list[#tty_list+1] = "/dev/"..e
	end
end

-- wbc.wbc: Global settings
s_wbc = m:section(TypedSection, "wbc", translate("YJSNPI-Broadcast Settings"))
s_wbc.anonymous = true
s_wbc.addremove = false
-- wbc.wbc.enable: Enable
o_wbc_enable = s_wbc:option(Flag, "enable", translate("Enable YJSNPI-Broadcast"))
o_wbc_enable.rmempty = false
-- wbc.nic: Wi-Fi settings
s_nic = m:section(TypedSection, "nic", translate("Wi-Fi Settings"))
s_nic.anonymous = true
s_nic.addremove = false
-- wbc.nic.iface: Wireless Interface
o_nic_iface = s_nic:option(Value, "iface", translate("Wireless Interface"))
o_nic_iface.rmempty = false
for k,v in ipairs(wlan_dev_list) do 
	o_nic_iface:value(v) 
end
o_nic_iface.default = "wlan0"
-- wbc.nic.freq: Frequency
o_nic_freq = s_nic:option(Value, "freq", translate("Center Frequency"))
o_nic_freq.rmempty = false
for k,v in ipairs(freq_list) do 
	o_nic_freq:value(v, v.." MHz") 
end
o_nic_freq.default = 2437
-- wbc.nic.chanbw: Channel Bandwidth
o_nic_chanbw = s_nic:option(ListValue, "chanbw", translate("Channel Bandwidth"))
o_nic_chanbw.rmempty = false
o_nic_chanbw:value(5,  "5 MHz")
o_nic_chanbw:value(10, "10 MHz")
o_nic_chanbw:value(20, "20 MHz")
o_nic_chanbw.default = 20


-- wbc.video: Video transfer settings
s_video = m:section(TypedSection, "video", translate("Video Transfer Settings"))
s_video.anonymous = true
s_video.addremove = false
-- wbc.video.enable: Video Transfer Enable
o_video_enable = s_video:option(Flag, "enable", translate("Enable Video Transfer"))
o_video_enable.rmempty = false
-- wbc.video.mode: Video Transfer Mode
o_video_mode = s_video:option(ListValue, "mode", translate("Transfer Mode"))
o_video_mode.rmempty = false
o_video_mode:value("tx", translate("Transceiver"))
o_video_mode:value("rx", translate("Receiver"))
o_video_mode.default = "tx"
-- wbc.video.listen_port: Listen on port
o_video_listen_port = s_video:option(Value, "listen_port", translate("Listen On Local Port"))
o_video_listen_port.datatype = "portrange(1024,65535)"
o_video_listen_port:depends("mode", "tx")
o_video_listen_port.placeholder = 35000
o_video_listen_port.default = 35000
-- wbc.video.send_ip_port: Send Video Stream to IP:Port
o_video_send_ip_port = s_video:option(Value, "send_ip_port", translate("Send Video Stream to IP:Port"))
o_video_send_ip_port.datatype = "ipaddrport"
o_video_send_ip_port:depends("mode", "rx")
-- wbc.video.datanum: Data packets in a block
o_video_datanum = s_video:option(Value, "datanum", translate("Data packets in a block"))
o_video_datanum.default = 8
o_video_datanum.datatype = "range(1,32)"
o_video_datanum.placeholder = 8
-- wbc.video.fecnum: FEC packets in a block
o_video_fecnum = s_video:option(Value, "fecnum", translate("FEC packets in a block"))
o_video_fecnum.default = 4
o_video_fecnum.datatype = "range(1,32)"
o_video_fecnum.placeholder = 4
-- wbc.video.packetsize: Bytes per packet
o_video_packetsize = s_video:option(Value, "packetsize", translate("Bytes per packet"))
o_video_packetsize.default = 1024
o_video_packetsize.placeholder = 1024
o_video_packetsize.datatype = "range(32,1450)"
-- wbc.video.port: Port on Air
o_video_port = s_video:option(Value, "port", translate("Port on Air"))
o_video_port.default = 0
o_video_port.placeholder = 0
o_video_port.datatype = "range(0,127)"
-- wbc.video.frametype: Frame Type
o_video_frametype = s_video:option(ListValue, "frametype", translate("Wireless Frame Type"))
o_video_frametype:value(0, "DATA Short")
o_video_frametype:value(1, "DATA Standard")
o_video_frametype:value(2, "RTS")
o_video_frametype.default = 0
-- wbc.video.bitrate: Bit Rate
o_video_bitrate = s_video:option(ListValue, "bitrate", translate("Bit Rate"))
o_video_bitrate:value(6, "6 Mbps")
o_video_bitrate:value(12, "12 Mbps")
o_video_bitrate:value(18, "18 Mbps")
o_video_bitrate:value(24, "24 Mbps")
o_video_bitrate:value(36, "36 Mbps")
o_video_bitrate.default = 24
o_video_bitrate:depends("mode", "tx")
-- wbc.video.rxbuf: RX Buf Size
o_video_rxbuf = s_video:option(Value, "rxbuf", translate("RX Buf Size"))
o_video_rxbuf.default = 1
o_video_rxbuf.placeholder = 1
o_video_rxbuf.datatype = "range(0,32)"
o_video_rxbuf:depends("mode", "rx")
-- wbc.video.fps: Video FPS
o_video_fps = s_video:option(ListValue, "fps", translate("Video FPS"))
o_video_fps.default = 48
o_video_fps.placeholder = 48
o_video_fps:value(30, "30 fps")
o_video_fps:value(40, "40 fps")
o_video_fps:value(48, "48 fps")
o_video_fps:value(59.9, "59.9 fps")
-- wbc.video.imgsize: Video resolution
o_video_imgsize = s_video:option(ListValue, "imgsize", translate("Img Size (resolution)"))
o_video_imgsize.default = "1280x720"
o_video_imgsize.placeholder = "1280x720"
o_video_imgsize:value("480x272")
o_video_imgsize:value("800x480")
o_video_imgsize:value("1280x720")
o_video_imgsize:value("1640x922")
o_video_imgsize:value("1920x1080")
o_video_imgsize:depends("mode", "tx")
-- wbc.video.bitrate_mode: Bitrate Mode
o_video_bitrate_mode = s_video:option(ListValue, "bitrate_mode", translate("Video Bitrate Mode"))
o_video_bitrate_mode.rmempty = false
o_video_bitrate_mode:value("auto", translate("Auto"))
o_video_bitrate_mode:value("manual", translate("Manual"))
o_video_bitrate_mode:depends("mode", "tx")
o_video_bitrate_mode.default = "auto"
-- wbc.video.bitrate_percent: Bitrate Percent
o_video_bitrate_percent = s_video:option(Value, "bitrate_percent", translate("Video Bitrate Percent"))
o_video_bitrate_percent.default = 65
o_video_bitrate_percent.placeholder = 65
o_video_bitrate_percent.datatype = "range(0,100)"
o_video_bitrate_percent:depends("bitrate_mode", "auto")
-- wbc.video.bitrate_manual: Bitrate Manual
o_video_bitrate_manual = s_video:option(Value, "bitrate_manual", translate("Video Bitrate Manual"))
o_video_bitrate_manual.default = 5000
o_video_bitrate_manual.placeholder = 5000
o_video_bitrate_manual.datatype = "range(500,16000)"
o_video_bitrate_manual:depends("bitrate_mode", "manual")
-- wbc.video.keyframerate: Keyframe Rate
o_video_keyframerate = s_video:option(Value, "keyframerate", translate("Key Frame Rate"))
o_video_keyframerate.default = 5
o_video_keyframerate.placeholder = 5
o_video_keyframerate.datatype = "range(2,10)"
o_video_keyframerate:depends("mode", "tx")
-- wbc.video.extraparams: raspivid Extra Params
o_video_extraparams = s_video:option(Value, "extraparams", translate("raspivid Extra Params"))
o_video_extraparams.default = '-cd H264 -n -fl -ih -pf high -if both -ex sports -mm average -awb horizon'
o_video_extraparams.placeholder = '-cd H264 -n -fl -ih -pf high -if both -ex sports -mm average -awb horizon'
o_video_extraparams:depends("mode", "tx")
-- wbc.video.savepath: Save Raw Video To Path
o_video_savepath = s_video:option(Value, "savepath", translate("Save Raw Video To Path"))
o_video_savepath.default = '/mnt/sda1/wbc_video'
o_video_savepath.placeholder = '/mnt/sda1/wbc_video'
o_video_savepath:depends("mode", "rx")


-- wbc.rssi: RSSI settings
s_rssi = m:section(TypedSection, "rssi", translate("RSSI Settings"))
s_rssi.anonymous = true
s_rssi.addremove = false
-- wbc.rssi.enable: RSSI Enable
o_rssi_enable = s_rssi:option(Flag, "enable", translate("Enable RSSI"))
o_rssi_enable.rmempty = false
-- wbc.rssi.mode: RSSI Transfer Mode
o_rssi_mode = s_rssi:option(ListValue, "mode", translate("Transfer Mode"))
o_rssi_mode.rmempty = false
o_rssi_mode:value("tx", translate("Transceiver"))
o_rssi_mode:value("rx", translate("Receiver"))
o_rssi_mode.default = "tx"
-- wbc.rssi.send_ip_port: RSSI RX Data Send to IP:Port	
o_rssi_send_ip_port = s_rssi:option(Value, "send_ip_port", translate("Send RSSI Data to IP:Port"))
o_rssi_send_ip_port.datatype = "ipaddrport"
o_rssi_send_ip_port:depends("mode", "rx")


-- wbc.telemetry: Telemetry settings
s_telemetry = m:section(TypedSection, "telemetry", translate("Telemetry Settings"))
s_telemetry.anonymous = true
s_telemetry.addremove = false
-- wbc.telemetry.enable: Telemetry Enable
o_telemetry_enable = s_telemetry:option(Flag, "enable", translate("Enable Telemetry"))
o_telemetry_enable.rmempty = false
-- wbc.telemetry.mode: Telemetry Transfer Mode
o_telemetry_mode = s_telemetry:option(ListValue, "mode", translate("Transfer Mode"))
o_telemetry_mode.rmempty = false
o_telemetry_mode:value("tx", translate("Transceiver"))
o_telemetry_mode:value("rx", translate("Receiver"))
o_telemetry_mode.default = "tx"
-- wbc.telemetry.uart: Telemetry Input UART Interface
o_telemetry_uart = s_telemetry:option(ListValue, "uart", translate("Telemetry Input UART Interface"))
for k,v in ipairs(tty_list) do 
	o_telemetry_uart:value(v) 
end
o_telemetry_uart.default = "/dev/ttyUSB0"

-- wbc.telemetry.baud: Telemetry UART Baud rate
o_telemetry_baud = s_telemetry:option(ListValue, "baud", translate("Telemetry UART Baud Rate"))
o_telemetry_baud:value(9600, "9600 bps")
o_telemetry_baud:value(19200, "19200 bps")
o_telemetry_baud:value(38400, "38400 bps")
o_telemetry_baud:value(57600, "57600 bps")
o_telemetry_baud:value(115200, "115200 bps")
o_telemetry_baud:value(230400, "230400 bps")
o_telemetry_baud.default = 57600
o_telemetry_baud:depends("mode", "tx")
-- wbc.telemetry.port: Telemetry Port on Air
o_telemetry_port = s_telemetry:option(Value, "port", translate("Telemetry Port on Air"))
o_telemetry_port.default = 1
o_telemetry_port.placeholder = 1
o_telemetry_port.datatype = "range(0,127)"
-- wbc.telemetry.cts: Telemetry TX CTS
o_telemetry_cts = s_telemetry:option(ListValue, "cts", translate("Telemetry TX CTS Mode"))
o_telemetry_cts:value(0, translate("CTS Protection Disabled"))
o_telemetry_cts:value(1, translate("CTS Protection Enabled"))
o_telemetry_cts.default = 0
o_telemetry_cts:depends("mode", "tx")
-- wbc.telemetry.retrans: Telemetry TX Retransmission Count
o_telemetry_retrans = s_telemetry:option(ListValue, "retrans", translate("Telemetry TX Retransmission Count"))
o_telemetry_retrans:value(1, translate("Send each frame once"))
o_telemetry_retrans:value(2, translate("Twice"))
o_telemetry_retrans:value(3, translate("Three times"))
o_telemetry_retrans.default = 2
o_telemetry_retrans:depends("mode", "tx")
-- wbc.telemetry.proto: Telemetry TX Protocol
o_telemetry_proto = s_telemetry:option(ListValue, "proto", translate("Telemetry Protocol"))
o_telemetry_proto:value(0, translate("Mavlink"))
o_telemetry_proto:value(1, translate("Generic"))
o_telemetry_proto.default = 0
o_telemetry_proto:depends("mode", "tx")
-- wbc.telemetry.bitrate: Telemetry TX Bit Rate
o_telemetry_bitrate = s_telemetry:option(ListValue, "bitrate", translate("Telemetry TX Bitrate"))
o_telemetry_bitrate:value(6, "6 Mbps")
o_telemetry_bitrate:value(12, "12 Mbps")
o_telemetry_bitrate:value(18, "18 Mbps")
o_telemetry_bitrate:value(24, "24 Mbps")
o_telemetry_bitrate:value(36, "36 Mbps")
o_telemetry_bitrate.default = 24
o_telemetry_bitrate:depends("mode", "tx")
-- wbc.telemetry.send_ip_port: Telemetry RX Send to IP:Port	
o_telemetry_send_ip_port = s_telemetry:option(Value, "send_ip_port", translate("Send Telemetry Data to IP:Port"))
o_telemetry_send_ip_port.datatype = "ipaddrport"
o_telemetry_send_ip_port:depends("mode", "rx")
-- wbc.telemetry.savepath: Save Telemetry Data To Path
o_telemetry_savepath = s_telemetry:option(Value, "telemetry", translate("Save Telemetry Data To Path"))
o_telemetry_savepath.default = '/mnt/sda1/wbc_telemetry'
o_telemetry_savepath.placeholder = '/mnt/sda1/wbc_telemetry'
o_telemetry_savepath:depends("mode", "rx")

-- wbc.uplink: Uplink settings
s_uplink = m:section(TypedSection, "uplink", translate("Uplink Settings"))
s_uplink.anonymous = true
s_uplink.addremove = false
-- wbc.uplink.enable: Uplink Enable
o_uplink_enable = s_uplink:option(Flag, "enable", translate("Enable Uplink"))
o_uplink_enable.rmempty = false
-- wbc.uplink.mode: Uplink Transfer Mode
o_uplink_mode = s_uplink:option(ListValue, "mode", translate("Transfer Mode"))
o_uplink_mode.rmempty = false
o_uplink_mode:value("tx", translate("Transceiver"))
o_uplink_mode:value("rx", translate("Receiver"))
o_uplink_mode.default = "tx"
-- wbc.uplink.port: Uplink Port on Air
o_uplink_port = s_uplink:option(Value, "port", translate("Uplink Port on Air"))
o_uplink_port.default = 3
o_uplink_port.placeholder = 3
o_uplink_port.datatype = "range(0,127)"
-- wbc.uplink.cts: Uplink TX CTS
o_uplink_cts = s_uplink:option(ListValue, "cts", translate("Uplink TX CTS Mode"))
o_uplink_cts:value(0, translate("CTS Protection Disabled"))
o_uplink_cts:value(1, translate("CTS Protection Enabled"))
o_uplink_cts.default = 0
o_uplink_cts:depends("mode", "tx")
-- wbc.uplink.retrans: Uplink TX Retransmission Count
o_uplink_retrans = s_uplink:option(ListValue, "retrans", translate("Uplink TX Retransmission Count"))
o_uplink_retrans:value(1, translate("Send each frame once"))
o_uplink_retrans:value(2, translate("Twice"))
o_uplink_retrans:value(3, translate("Three times"))
o_uplink_retrans.default = 2
o_uplink_retrans:depends("mode", "tx")
-- wbc.uplink.bitrate: Uplink TX Bit Rate
o_uplink_bitrate = s_uplink:option(ListValue, "bitrate", translate("Uplink TX Bitrate"))
o_uplink_bitrate:value(6, "6 Mbps")
o_uplink_bitrate:value(12, "12 Mbps")
o_uplink_bitrate:value(18, "18 Mbps")
o_uplink_bitrate:value(24, "24 Mbps")
o_uplink_bitrate:value(36, "36 Mbps")
o_uplink_bitrate.default = 6
o_uplink_bitrate:depends("mode", "tx")
-- wbc.uplink.uart: Uplink Input UART Interface (Ground)
o_uplink_uart = s_uplink:option(ListValue, "uart", translate("Uplink Input UART Interface"))
for k,v in ipairs(tty_list) do 
	o_uplink_uart:value(v) 
end
o_uplink_uart.default = "/dev/ttyUSB0"
o_uplink_uart:depends("mode", "rx")
-- wbc.uplink.baud: Uplink UART Baud rate
o_uplink_baud = s_uplink:option(ListValue, "baud", translate("Uplink UART Baud Rate"))
o_uplink_baud:value(9600, "9600 bps")
o_uplink_baud:value(19200, "19200 bps")
o_uplink_baud:value(38400, "38400 bps")
o_uplink_baud:value(57600, "57600 bps")
o_uplink_baud:value(115200, "115200 bps")
o_uplink_baud:value(230400, "230400 bps")
o_uplink_baud.default = 57600
o_uplink_baud:depends("mode", "rx")
-- wbc.uplink.proto: Uplink TX Protocol
o_uplink_proto = s_uplink:option(ListValue, "proto", translate("Uplink Protocol"))
o_uplink_proto:value(0, translate("Mavlink"))
o_uplink_proto:value(1, translate("Generic"))
o_uplink_proto.default = 0
o_uplink_proto:depends("mode", "tx")
-- wbc.uplink.listen_port: Listen on port
o_uplink_listen_port = s_uplink:option(Value, "listen_port", translate("Listen On Local Port"))
o_uplink_listen_port.datatype = "portrange(1024,65535)"
o_uplink_listen_port.placeholder = 35002
o_uplink_listen_port.default = 35002
o_uplink_listen_port:depends("mode", "tx")

-- wbc.log: Log settings
s_log = m:section(TypedSection, "log", translate("Log Settings"))
s_log.anonymous = true
s_log.addremove = false
-- wbc.log.enable: Log Enable
o_log_enable = s_log:option(Flag, "enable", translate("Enable Log"))
o_log_enable.rmempty = false
-- wbc.log.save_dir: Log Save to Dir
o_log_save_dir = s_log:option(Value, "save_dir", translate("Log Save to Dir"))
o_log_save_dir.rmempty = false

-- wbc.encrypt: Encrypt settings
s_encrypt = m:section(TypedSection, "encrypt", translate("Encrypt Settings"))
s_encrypt.anonymous = true
s_encrypt.addremove = false
-- wbc.encrypt.enable: Encrypt Enable
o_encrypt_enable = s_encrypt:option(Flag, "enable", translate("Enable Encrypt"))
o_encrypt_enable.rmempty = false
-- wbc.encrypt.method: Encrypt Method
o_encrypt_method = s_encrypt:option(Value, "method", translate("Encrypt Method"))
o_encrypt_method.rmempty = false
o_encrypt_method:value("aes-128-cfb")
o_encrypt_method:value("blowfish")
o_encrypt_method.default = "blowfish"
o_encrypt_method:depends("enable", 1)
-- wbc.encrypt.password: Encrypt Password
o_encrypt_password = s_encrypt:option(Value, "password", translate("Password"))
o_encrypt_password.rmempty = false
o_encrypt_password.password = true
o_encrypt_password:depends("enable", 1)

return m
