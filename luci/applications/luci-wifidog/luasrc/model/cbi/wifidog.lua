--[[
live-8.taobao.com
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

--limeng
local running=(luci.sys.call("pidof wifidog > /dev/null") == 0)
local button=""

if running then
	m = Map("wifidog", translate("wifidog-web"), translate("wifidog：running........."))
else
	m = Map("wifidog", translate("wifidog-web"), translate("wifidog not start"))
end

if fs.access("/usr/bin/wifidog") then
	s = m:section(TypedSection, "wifidog", translate("wifidog config"))
	s.anonymous = true
	s.addremove = false

	wifi_enable = s:option(Flag, "wifidog_enable", translate("run wifidog"),translate("run or shuutdown wifidog"))
	wifi_enable.default = 0

	
	gatewayID = s:option(Value,"gateway_id",translate("GatewayID"),translate("id（GatewayID）"))
	gateway_interface = s:option(Value,"gateway_interface",translate("lan"),translate("br-lan"))
	gateway_eninterface = s:option(Value,"gateway_eniterface",translate("wan"),translate("eth1/eth2"))
	gateway_hostname = s:option(Value,"gateway_hostname",translate("server ip"))
	gateway_httpport = s:option(Value,"gateway_httpport",translate("server prot"))
	gateway_path = s:option(Value,"gateway_path",translate("url"),translate("/wifidog/"))
	gateway_connmax = s:option(Value,"HTTPDMaxConn",translate("max usr"))

	
	--deamo_enable = s:option(Flag, "enable", translate("Dog"),translate("reboot wifidog"))
	--deamo_enable:depends("wifidog_enable","1")
	--deamo_enable.default = 0
else
	m.pageaction = false
end

return m

