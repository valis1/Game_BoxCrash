
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
    local background = display.newImageRect(sceneGroup, "UI/BackgroundMenu.png", 800, 1400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local label = display.newImageRect(sceneGroup, "UI/label.png", 320, 10 )
    title.x = display.contentCenterX
    title.y = 200

    local BackButton = display.newText( sceneGroup, "Back", display.contentCenterX, 700, 'UI/DroidSerif-Regular.ttf', 44 )
    BackButton:setFillColor(0.757, 0.757, 0.757,1)

    local ExitButton = display.newText( sceneGroup, "Exit Game", display.contentCenterX, 750, 'UI/DroidSerif-Regular.ttf', 44 )
    ExitButton:setFillColor(0.757, 0.757, 0.757,1)

    BackButton:addEventListener( "tap", gotoGame)
    ExitButton:addEventListener('tap',exit)

end

scene:addEventListener( "create", scene )

return scene
