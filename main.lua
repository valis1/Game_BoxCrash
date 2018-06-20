local composer = require( "composer" )
local json = require( "json" )

--request params
local settings



--get system settings 
local function getSettings()
	local path=system.pathForFile("settings.json")
	local file,errorString=io.open(path,"r")
	if file then
		local content=file:read( "*a" )
		io.close(file)
		return json.decode(content)
	else
		return false
	end
end

local function compleateAlert(event)
    if (event.action == "clicked") then
    	os.exit()
    end
end

display.setStatusBar( display.HiddenStatusBar )



settings=getSettings()
if not settings then
	local alert = native.showAlert( "Error", "Can`t load settings", { "Exit"},compleateAlert)
end
composer.gotoScene( "game",{params={settings=settings}} )
