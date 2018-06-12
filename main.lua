local composer = require( "composer" )
local json = require( "json" )

--request params
local params = {}
local settings
local body = "model="..system.getInfo("model")
params.body = body

--file params 
local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
local file, errorString = io.open(path, "r")

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

local function genName(event)
	if not event.isError then
		local response = json.decode(event.response)
		local file,errorString=io.open(path,'w')
		if  file then
		    file:write(json.encode({id=response['_id'] ,nick=response['nick']}))
		    io.close(file)
		    file=nil
		end
	else 
		print(event.errorString)
	end
end	

settings=getSettings()
if not settings then
	local alert = native.showAlert( "Error", "Can`t load settings", { "Exit"},compleateAlert)
end
--if File does not Exist Create file and user on the server
if not file then
    network.request(settins.server.."/api/scores", "POST", genName,params) 
end

composer.gotoScene( "game" )
