local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )

local myId
local top={}
local url
local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
local progressText

local scene = composer.newScene()

local function gotoGame()
    composer.gotoScene("game")
end

local function exit()
	os.exit()
end 

function getStatisticCallback(event)
    if event.isError then
        progressText.text="Can`t connect the sever"
        progressText.isVisible=true
    elseif (event.phase == "began" or event.phase == "progress") then
        progressText.text="Loading..."
        progressText.isVisible=true
    elseif (event.phase=="ended") then
         local response= json.decode(event.response)
    end
end


function scene:create( event )

    myId=event.params.id
    url=event.params.url

	local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "UI/BackgroundMenu.png", 360, 570 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local label = display.newImageRect(sceneGroup, "UI/Label.png", 240, 75 )
    label.x = display.contentCenterX
    label.y = 30

    progressText=display.newText(sceneGroup,"Loading...",display.contentCenterX, display.contentCenterY, 'UI/DroidSerif-Regular.ttf', 22)
    progressText:setFillColor(0.757, 0.757, 0.757,1)
    progressText.isVisible=false

    local BackButton = display.newText( sceneGroup, "Back Game", display.contentCenterX-75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    BackButton:setFillColor(0.757, 0.757, 0.757,1)
    local ExitButton = display.newText( sceneGroup, "Exit Game", display.contentCenterX+75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    ExitButton:setFillColor(0.757, 0.757, 0.757,1)

    BackButton:addEventListener( "tap", gotoGame)
    ExitButton:addEventListener('tap',exit)

end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        network.request(url.."/api/reports/statistic/"..myId, "GET",getStatisticCallback)
        print(url.."api/reports/statistic/"..myId)
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

return scene
