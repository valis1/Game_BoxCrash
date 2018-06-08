
local composer = require( "composer" )

local scene = composer.newScene()


local function gotoGame()
    composer.gotoScene("game")
end

local function exit()
	os.exit()
end 


function scene:create( event )

	local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "UI/BackgroundMenu.png", 360, 570 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local label = display.newImageRect(sceneGroup, "UI/label.png", 240, 75 )
    label.x = display.contentCenterX
    label.y = 30

    local BackButton = display.newText( sceneGroup, "Back Game", display.contentCenterX-75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    BackButton:setFillColor(0.757, 0.757, 0.757,1)
    local ExitButton = display.newText( sceneGroup, "Exit Game", display.contentCenterX+75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    ExitButton:setFillColor(0.757, 0.757, 0.757,1)

    BackButton:addEventListener( "tap", gotoGame)
    ExitButton:addEventListener('tap',exit)

end

scene:addEventListener( "create", scene )

return scene
