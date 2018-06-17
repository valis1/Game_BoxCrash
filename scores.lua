local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )

local myId
local top={}
local url
local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
local progressText
local scoreTable

local tableOptions={
        x = display.contentCenterX,
        y = display.contentCenterY,
        height = 330,
        width = 300,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = scrollListener
    }

local scene = composer.newScene()

local function gotoGame()
    composer.gotoScene("game")
end

local function exit()
	os.exit()
end
--sort function
local function compare(a,b)
  return a.score < b.score
end

function update_table()
    for k,v in pairs(top) do
        scoreTable:insertRow{v.nick,v.score}
    end
end

function getStatisticCallbackTwo(event)
    if event.isError then
        progressText.text="Can`t connect the sever"
        progressText.isVisible=true
    elseif (event.phase == "began" or event.phase == "progress") then
        progressText.text="Loading..."
        progressText.isVisible=true
    elseif (event.phase=="ended") then
         local response= json.decode(event.response)
         for k,v in pairs(response) do
            table.insert(top,v)
        end
        table.sort(top,compare)
        update_table()
    end
end


local function getStatisticCallbackOne(event)
    if event.isError then
        progressText.text="Can`t connect the sever"
        progressText.isVisible=true
    elseif (event.phase == "began" or event.phase == "progress") then
        progressText.text="Loading..."
        progressText.isVisible=true
    elseif (event.phase=="ended") then
         local response= json.decode(event.response)
         for k,v in pairs(response) do
            table.insert(top,v)
        end
        network.request(url.."/api/reports/statistic/down/"..myId, "GET",getStatisticCallbackTwo)
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

    scoreTable = widget.newTableView(tableOptions)

end

 function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        network.request(url.."/api/reports/statistic/up/"..myId, "GET",getStatisticCallbackOne)
    end
end


 function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
         scoreTable.isVisible=false
    elseif ( phase == "did" ) then
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener("hide",scene)

return scene
