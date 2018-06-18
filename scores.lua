local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )

local myId
local top={}
local url
local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
local progressText
local scoreTable
local inital=true


local function onRowRender( event )
   local row = event.row
   local id = row.index
   row.nameText = display.newText( top[id].nick, 12, 0, 'UI/DroidSerif-Regular.ttf', 18 )
   row.nameText.anchorX = 0
   row.nameText.anchorY = 0
   row.nameText:setFillColor(0.757, 0.757, 0.757,1)
   row.nameText.y = 20
   row.nameText.x = 42

   row.scoreText = display.newText( top[id].score, 12, 0,'UI/DroidSerif-Regular.ttf', 18 )
   row.scoreText.anchorX = 0
   row.scoreText.anchorY = 0
   row.scoreText:setFillColor( 0.757, 0.757, 0.757,1)
   row.scoreText.y = 20
   row.scoreText.x = 230

   row:insert( row.nameText )
   row:insert( row.scoreText )
   return true
end

local tableOptions={
   top = 60, 
   width = display.contentWidth, 
   height = display.contentHeight - 60 - 50,
   onRowRender = onRowRender,
   onRowTouch = onRowTouch,
   listener = scrollListener,
   hideBackground =true
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

function createTable()
    --it`s bad idea 
    local usedId={}
    for i=1,#top do
        local cat=false
        local color= { default={ 0.349, 0.341, 0.757, 0.1}, over={ 0.12, 0, 0.51, 0.1} }
        if not table.indexOf(usedId,top[i]._id) then
            if top[i]._id==myId then
                cat=true
                color= { default={ 0.349, 0.341, 0.757, 0.9}, over={ 0.12, 0, 0.51, 0.8} }
            end
            scoreTable:insertRow{ 
                rowHeight = 60,
                isCategory = cat,
                rowColor =color,
                lineColor = { 0.349, 0.341, 0.757,0.5}
            }
        end
        table.insert(usedId,top[i]._id)
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
        if inital then
            inital=false
            createTable()
        else
            scoreTable:reloadData()
            scoreTable.isVisible=true
        end
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
        network.request(url.."/api/reports/statistic/up/"..myId, "GET",getStatisticCallbackOne)
    elseif ( phase == "did" ) then
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
