local fs = require "nixio.fs"
local util = require "nixio.util"

local running=(luci.sys.call("pidof EmbedThunderManager > /dev/null") == 0)
local button=""
local xunleiinfo=""
local tblXLInfo={}
local detailInfo = "启动后会看到类似如下信息：<br /><br />[ 0, 1, 1, 0, “7DHS94”,1, “201_2.1.3.121”, “zhuowei”, 1 ]<br /><br />其中有用的几项为：<br /><br />第一项： 0表示返回结果成功；<br /><br />第二项： 1表示检测网络正常，0表示检测网络异常；<br /><br />第四项： 1表示已绑定成功，0表示未绑定；<br /><br />第五项： 未绑定的情况下，为绑定的需要的激活码；<br /><br />第六项： 1表示磁盘挂载检测成功，0表示磁盘挂载检测失败。"

--limeng
local rst=0
rst=luci.sys.call("bash /usr/lmxl.sh >/dev/null")
point=fs.readfile("/tmp/lmmntpoint")
--end limeng

if running then
	xunleiinfo = luci.sys.exec("wget http://localhost:9000/getsysinfo -O - 2>/dev/null")
	upinfo = luci.sys.exec("wget -qO- http://592.3322.org:592/OpenRouter/xunlei/latest 2>/dev/null")
        button = "&nbsp;&nbsp;&nbsp;&nbsp;" .. translate("运行状态：") .. xunleiinfo	
	m = Map("xunlei", translate("Xware"), translate("迅雷远程下载 正在运行...") .. button)
	string.gsub(string.sub(xunleiinfo, 2, -2),'[^,]+',function(w) table.insert(tblXLInfo, w) end)
	
	detailInfo = [[<p>检测到本机远程迅雷运行状态信息]].. xunleiinfo ..[[</p>]]
	if tonumber(tblXLInfo[1]) == 0 then
	  detailInfo = detailInfo .. [[<p></p><p style="font-size:10pt;color:blue">状态正常</p>]]
	else
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:red">执行异常</p>]]
	end
	
	if tonumber(tblXLInfo[2]) == 0 then
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:red">网络异常</p>]]
	else
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:blue">网络正常</p>]]
	end
	
	if tonumber(tblXLInfo[4]) == 0 then
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:red">激活码未绑定]].. [[&nbsp;&nbsp;本机激活码：]].. tblXLInfo[5] ..[[</p>]]	  
	else
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:blue">激活码已绑定</p>]]
	end

	if tonumber(tblXLInfo[6]) == 0 then
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:red">挂载检测失败</p>]]
	else
	  detailInfo = detailInfo .. [[<p style="font-size:10pt;color:blue">挂载检测成功</p>]]
	end
else
	m = Map("xunlei", translate("Xware"), translate("[Thunder remotely download has not started]"))
end

-----------
--Xware--
-----------

s = m:section(TypedSection, "xunlei", translate("Xware Set"))
s.anonymous = true

s:tab("basic",  translate("Settings"))

--limeng
if(rst == 0)then
	enable = s:taboption("basic", Flag, "enable", translate("Enable remote download Thunder"))
	enable.rmempty = false
elseif(rst == 1)then
	enable = s:taboption("basic", DummyValue, "", translate("硬盘未插,无法启动迅雷！"))
	enable.rmempty = false
elseif(rst == 2)then
	enable = s:taboption("basic", DummyValue, "", translate("挂载点不能为空!"))
	enable.rmempty = false
elseif(rst == 3)then
    local buf = "请输入实际挂载点：" .. point
	enable = s:taboption("basic", DummyValue, "", translate(buf))
	enable.rmempty = false
end
--end limeng

local devices = {}
util.consume((fs.glob("/dev/sd??*")), devices)

device = s:taboption("basic", Value, "device", translate("Device"), translate("Device mount point for thunder"))
for i, dev in ipairs(devices) do
    device:value(dev)
end

upinfo = luci.sys.exec("wget -qO- http://592.3322.org:592/OpenRouter/xunlei/latest 2>/dev/null")
up = s:taboption("basic", Flag, "up", translate("Upgrade Thunder Remote Download"), translate("The latest version:") .. upinfo)
up.rmempty = false

zversion = s:taboption("basic", Flag, "zversion", translate("Custom version"), translate("Custom Thunder remotely download version."))
zversion.rmempty = false
zversion:depends("up",1)

ver = s:taboption("basic", Value, "ver", translate("The version number"), translate("Custom Thunder remotely download version."))
ver:depends("zversion",1)
ver:value("1.0.21", translate("1.0.21"))


xwareup = s:taboption("basic", Value, "xware", translate("Xware version:"),translate("请选择硬件平台：ar71xxx选择 mipseb，MT300N选 mipsel"))
xwareup.rmempty = false
xwareup:value("Xware_mipseb_32_uclibc.tar.gz", translate("mipseb"))
xwareup:value("Xware_mipsel_32_uclibc.tar.gz", translate("mipsel"))


s:taboption("basic", DummyValue,"opennewwindow" ,translate("<br /><p align=\"justify\"><script type=\"text/javascript\"></script><input type=\"button\" class=\"cbi-button cbi-button-apply\" value=\"获取启动信息\" onclick=\"window.open('http://'+window.location.host+':9000/getsysinfo')\" /></p>"), detailInfo)


s:taboption("basic", DummyValue,"opennewwindow" ,translate("<br /><p align=\"justify\"><script type=\"text/javascript\"></script><input type=\"button\" class=\"cbi-button cbi-button-apply\" value=\"打开远程迅雷\" onclick=\"window.open('http://yuancheng.xunlei.com')\" /></p>"), translate("The activation code pages can be filled into the binding."))

s:tab("editconf_mounts", translate("Mount point configuration"))
editconf_mounts = s:taboption("editconf_mounts", Value, "_editconf_mounts", 
	translate("Mount point configuration (under normal circumstances just fill in your mount point directory can)"), 
	translate("Comment Using #"))
editconf_mounts.template = "cbi/tvalue"
editconf_mounts.rows = 20
editconf_mounts.wrap = "off"

function editconf_mounts.cfgvalue(self, section)

	return fs.readfile("/tmp/etc/thunder_mounts.cfg") or ""
end
function editconf_mounts.write(self, section, value1)
	if value1 then
		value1 = value1:gsub("\r\n?", "\n")
		fs.writefile("/tmp/thunder_mounts.cfg", value1)
		if (luci.sys.call("cmp -s /tmp/thunder_mounts.cfg /tmp/etc/thunder_mounts.cfg") == 1) then
			fs.writefile("/tmp/etc/thunder_mounts.cfg", value1)
		end
		fs.remove("/tmp/thunder_mounts.cfg")
	end
end

s:tab("editconf_etm", translate("Xware configuration"))
editconf_etm = s:taboption("editconf_etm", Value, "_editconf_etm", 
	translate("Xware configuration"), 
	translate("Comment by  ;"))
editconf_etm.template = "cbi/tvalue"
editconf_etm.rows = 20
editconf_etm.wrap = "off"

function editconf_etm.cfgvalue(self, section)
	return fs.readfile("/tmp/etc/etm.cfg") or ""
end
function editconf_etm.write(self, section, value2)
	if value2 then
		value2 = value2:gsub("\r\n?", "\n")
		fs.writefile("/tmp/etm.cfg", value2)
		if (luci.sys.call("cmp -s /tmp/etm.cfg /tmp/etc/etm.cfg") == 1) then
			fs.writefile("/tmp/etc/etm.cfg", value2)
		end
		fs.remove("/tmp/etm.cfg")
	end
end

s:tab("editconf_download", translate("Download Configuration"))
editconf_download = s:taboption("editconf_download", Value, "_editconf_download", 
	translate("Download Configuration"), 
	translate("Comment by  ;"))
editconf_download.template = "cbi/tvalue"
editconf_download.rows = 20
editconf_download.wrap = "off"

function editconf_download.cfgvalue(self, section)
	return fs.readfile("/tmp/etc/download.cfg") or ""
end
function editconf_download.write(self, section, value3)
	if value3 then
		value3 = value3:gsub("\r\n?", "\n")
		fs.writefile("/tmp/download.cfg", value3)
		if (luci.sys.call("cmp -s /tmp/download.cfg /tmp/etc/download.cfg") == 1) then
			fs.writefile("/tmp/etc/download.cfg", value3)
		end
		fs.remove("/tmp/download.cfg")
	end
end
return m


