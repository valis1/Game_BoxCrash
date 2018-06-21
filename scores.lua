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
local params = {}
params['timeout']=5


local function onRowRender( event )
   local row = event.row
   local id = row.index
   local params = event.row.params
   local name =  params.name
   row.nameText = display.newText( name, 12, 0, 'UI/DroidSerif-Regular.ttf', 18 )
   row.nameText.anchorX = 0
   row.nameText.anchorY = 0
   row.nameText:setFillColor(0.757, 0.757, 0.757,1)
   row.nameText.y = 20
   row.nameText.x = 42

   row.scoreText = display.newText( params.score, 12, 0,'UI/DroidSerif-Regular.ttf', 18 )
   row.scoreText.anchorX = 0
   row.scoreText.anchorY = 0
   row.scoreText:setFillColor( 0.757, 0.757, 0.757,1)
   row.scoreText.y = 20
   row.scoreText.x = 230

   if params.isMe then
      row.isMeText = display.newText( 'Мой игрок:', 12, 0,'UI/DroidSerif-Regular.ttf', 15 )
      row.isMeText.anchorX = 0
      row.isMeText.anchorY = 0
      row.isMeText:setFillColor( 0.757, 0.757, 0.757,1)
      row.isMeText.y = 12
      row.nameText.y = 30
      row.isMeText.x = 42
      row:insert( row.isMeText )
   end

   row:insert( row.nameText )
   row:insert( row.scoreText )
   return true
end

local tableOptions={
   top = 40, 
   width = display.contentWidth, 
   height = display.contentHeight - 70,
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
  return a.score > b.score
end

function createTable()
    --it`s bad idea 
    local usedId={}
    local isMe=false
    for i=1,#top do
        local color= { default={ 0.349, 0.341, 0.757, 0.1}, over={ 0.12, 0, 0.51, 0.1} }
        if (table.indexOf(usedId,top[i]._id) ==nil) then
            if top[i]._id==myId then
                color= { default={ 0.349, 0.341, 0.757, 0.9}, over={ 0.12, 0, 0.51, 0.8} }
                isMe=true
            end
            scoreTable:insertRow{ 
                rowHeight = 60,
                isCategory = false,
                rowColor =color,
                lineColor = { 0.349, 0.341, 0.757,0.5},
                params = {
                     name = top[i].nick,
                     score = top[i].score,
                     isMe=isMe
                }
            }
            isMe=false
            table.insert(usedId,top[i]._id)
        end
    end
end

function getStatisticCallbackTwo(event)
    if event.isError then
        progressText.text="Can`t connect the sever"
        progressText.isVisible=true
    elseif (event.phase == "began" or event.phase == "progress") then

    elseif (event.phase=="ended") then
         progressText.isVisible=false
         local response= json.decode(event.response)
         for k,v in pairs(response) do
            table.insert(top,v)
        end

        table.sort(top,compare)
        if inital then
            inital=false
            createTable()
        else
            createTable()
            scoreTable.isVisible=true
        end
    end
end


local function getStatisticCallbackOne(event)
    if event.isError then
        progressText.text="Can`t connect the sever"
        progressText.isVisible=true
    elseif (event.phase == "began" or event.phase == "progress") then

    elseif (event.phase=="ended") then
         top={}
         local response= json.decode(event.response)
         for k,v in pairs(response) do
            table.insert(top,v)
        end
        network.request(url.."/api/reports/statistic/down/"..myId, "GET",getStatisticCallbackTwo,params)
    end
end


 function scene:create( event )
    myId=event.params.id
    url=event.params.url
	local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "UI/BackgroundMenu.png", 360, 570 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    local welcomeText= display.newText(sceneGroup,"Таблица лидеров",display.contentCenterX, 10, 'UI/DroidSerif-Regular.ttf', 26)
    welcomeText:setFillColor(0.757, 0.757, 0.757,1)

    progressText=display.newText(sceneGroup,"Загрузка...",display.contentCenterX, display.contentCenterY, 'UI/DroidSerif-Regular.ttf', 22)
    progressText:setFillColor(0.757, 0.757, 0.757,1)
    progressText.isVisible=false

    local BackButton = display.newText( sceneGroup, "В игру", display.contentCenterX-75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    BackButton:setFillColor(0.757, 0.757, 0.757,1)
    local ExitButton = display.newText( sceneGroup, "Выйти", display.contentCenterX+75, display.contentCenterY+250, 'UI/DroidSerif-Regular.ttf', 22 )
    ExitButton:setFillColor(0.757, 0.757, 0.757,1)

    BackButton:addEventListener( "tap", gotoGame)
    ExitButton:addEventListener('tap',exit)

    scoreTable = widget.newTableView(tableOptions)
end

 function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        scoreTable:deleteAllRows()
        progressText.text="Загрузка..."
        progressText.isVisible=true
        network.request(url.."/api/reports/statistic/up/"..myId, "GET",getStatisticCallbackOne,params)
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
