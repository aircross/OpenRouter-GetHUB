--[[
卓微电子
]]--


local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

m = Map("wifidog", "wifidog WEB", translate("wifidog WEB))	



if fs.access("/usr/bin/wifidog") then
	s = m:section(TypedSection, "wifidog", "wifidog set")
	s.anonymous = true
	s.addremove = false

	wifi_enable = s:option(Flag, "wifidog_enable", translate("wifidog"),"wifidog")
	--wifi_enable.default = wifi_enable.enable
	--wifi_enable.optional = true
	

	
	gatewayID = s:option(Value,"gateway_id","gateway_id")
	gateway_interface = s:option(Value,"gateway_interface","'br-lan'-eth1, wlan0, ath0....")
	gateway_eninterface = s:option(Value,"gateway_eniterface","eth0")
	gateway_hostname = s:option(Value,"gateway_hostname","www")
	gateway_httpport = s:option(Value,"gateway_httpport","80")
	gateway_path = s:option(Value,"gateway_path","/auth/wifidog/")
	gateway_connmax = s:option(Value,"HTTPDMaxConn","max usr")
	
	

	deamo_enable = s:option(Flag, "enable", translate("baohu-wifidog")
	deamo_enable:depends("wifidog_enable","1")
else
	m.pageaction = false
end


return m


