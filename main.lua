local composer = require( "composer" )
local json = require( "json" )

--request params
local params = {}
local body = "model="..system.getInfo("model")
params.body = body

--file params 
local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
local file, errorString = io.open(path, "r")


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


--if File does not Exist Create file and user on the server
if not file then
    network.request("http://localhost:3000/api/scores", "POST", genName,params) 
end


composer.gotoScene( "game" )
