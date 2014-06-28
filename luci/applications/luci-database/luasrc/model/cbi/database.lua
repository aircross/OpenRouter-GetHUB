--[[
卓微科技@limeng
]]--

local fs = require "nixio.fs"
local util = require "nixio.util"

local nginx_running=(luci.sys.call("pidof nginx > /dev/null") == 0)
local php_running=(luci.sys.call("pidof php-cgi > /dev/null") == 0)
local mysqld_running=(luci.sys.call("pidof mysqld > /dev/null") == 0)

if nginx_running and php_running and mysqld_running then
	m = Map("database", translate("database"), translate("database is running..."))
else
	m = Map("database", translate("database"), translate("database is stop!"))
end

--挂载点
local rst=0
rst=luci.sys.call("sh /usr/databasemnt.sh >/dev/null")
point=fs.readfile("/tmp/databasemnt")

s = m:section(TypedSection, "database")
s.anonymous = true

--初始化
if(rst == 0)then
	enable = s:option(DummyValue, "")
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

select=s:option(ListValue,"select",translate("select action"))
select:value("init","database init")
select:value("start","start server")
select:value("stop","stop server")
select:value("del","delete database")

local devices = {}
util.consume((fs.glob("/dev/sd??*")), devices)

device = s:option(Value, "device", translate("Device"), translate("Device mount point for database"))
for i, dev in ipairs(devices) do
    device:value(dev)
end

--用户名
--usr_name = s:option(DummyValue, "root", translate("user name is: root"))
--usr_name:depends("select","init")

--密码
passwd = s:option(Value, "passwd", translate("user passwd"), translate("default user name: root; if passwd is empty, default passwd is: openrouter"))
passwd:depends("select","init")
passwd.password = true

--数据库名字
database_name = s:option(Value, "database_name", translate("database name"), translate("if database name is empty, default database name is: openrouter"))
database_name:depends("select","init")

--php port
nginx_port = s:option(Value, "nginx_port", translate("openrouter port"))
nginx_port:depends("select","start")
nginx_port.default = 90

--web port
uhttpd_port = s:option(Value, "uhttpd_port", translate("web server port"))
uhttpd_port:depends("select","start")
uhttpd_port.default = 80

return m

