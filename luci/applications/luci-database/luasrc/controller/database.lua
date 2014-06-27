--[[
卓微科技@limeng
]]--

module("luci.controller.database", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/database") then
		return
	end

	local page
	page = entry({"admin", "Extend", "database"}, cbi("database"), _("database"), 36)
	page.i18n = "database"
	page.dependent = true
end