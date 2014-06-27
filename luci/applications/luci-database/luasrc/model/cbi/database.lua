--[[
卓微科技@limeng
]]--

local fs = require "nixio.fs"
local util = require "nixio.util"

m = Map("database", translate("database"))

--挂载点
local rst=0
rst=luci.sys.call("sh /usr/databasemnt.sh >/dev/null")
point=fs.readfile("/tmp/databasemnt")

s = m:section(TypedSection, "database")
s.anonymous = true

--初始化
if(rst == 0)then
	enable = s:option(Flag, "enable", translate("start init database"))
	enable.rmempty = false
elseif(rst == 1)then
	enable = s:option(DummyValue, "", translate("硬盘未插,无法启动服务！"))
	enable.rmempty = false
elseif(rst == 2)then
	enable = s:option(DummyValue, "", translate("挂载点不能为空!"))
	enable.rmempty = false
elseif(rst == 3)then
    local buf = "请输入实际挂载点：" .. point
	enable = s:option(DummyValue, "", translate(buf))
	enable.rmempty = false
end

local devices = {}
util.consume((fs.glob("/dev/sd??*")), devices)

device = s:option(Value, "device", translate("Device"), translate("Device mount point for database"))
for i, dev in ipairs(devices) do
    device:value(dev)
end

--用户名
usr_name = s:option(DummyValue, "", translate("user name is: &nbsp; &nbsp; root"))

--密码
passwd = s:option(Value, "passwd", translate("user passwd"), translate("if passwd is empty, default passwd is: openrouter"))
passwd.password = true

database_name = s:option(Value, "database_name", translate("database name"), translate("if database name is empty, default database name is: openrouter"))

--服务开始
server_start = s:option(Flag, "server_start", translate("server start"))
server_start:depends("enable", 1)

return m

