
local composer = require( "composer" )
local json = require( "json" )

--scene
local scene = composer.newScene()


--inital state 
local  state = 2
local scores=0
local speed = 0
local prevScores=0
local busy=false 
local changed=false

--variables
local sheet
local crash_sound
local crashed_sound
local tapText
local tapSpeed
local current_sprite
local boxes
local setting

--display groups
local backGroup 
local mainGroup 
local uiGroup 


local sheetOptions={
	frames={
	--inital box (1)
	{
	x=0,
	y=0,
	width=275,
	height=258
    },
    --clicked (but not crached) (2)
    {
	x=351,
	y=30,
	width=245,
	height=226
    },
    --inital crash progress 1(3)
    {
	x=669,
	y=21,
	width=241,
	height=242
    },
    --inital crash process 2(4)
    {
	x=2,
	y=312,
	width=294,
	height=270
    },
    --clicked and crashed(5)
    {
	x=986,
	y=35,
	width=247,
	height=224
    },
    --crashed 1 (6)
    {
	x=659,
	y=323,
	width=280,
	height=253
    },
     --crashed 2 (7)
    {
	x=342,
	y=320,
	width=279,
	height=249
    },
     --right top fly-part (8)
    {
	x=998,
	y=358,
	width=200+80,
	height=186+80
    },
    --buttom fly-part (9)
    {
	x=1290,
	y=374,
	width=212,
	height=165
    },
    --left top fly-part (10) 
    {
	x=1336,
	y=4,
	width=168,
	height=274
    },
    --score (11)
    {
	x=1454,
	y=285,
	width=47,
	height=57
    }
   }
}



--===================================================================================
--=================================GAME FUNCTIONS====================================
--===================================================================================
local function create_boxes()
	local sprites={{},{},{}}
	local sheets={}
	--loading sheets
    sheets[1]=graphics.newImageSheet('sheets/SimpleBoxSheet.png',sheetOptions)
    sheets[2]=graphics.newImageSheet('sheets/Level2BoxSheet.png',sheetOptions)
    sheets[3]=graphics.newImageSheet('sheets/Level3BoxSheet.png',sheetOptions)
    local scores={2,3,6}
    for i =1,3 do
    	for j=1,11 do
    		sprites[i][j]=display.newImage(mainGroup,sheets[i],j)
    		sprites[i][j].isVisible=false
    		sprites[i][j].score=scores[i]
    		sprites[i][j].x=display.contentCenterX
    		sprites[i][j].y=display.contentCenterY
    	end
    end
    return sprites
end 

--Randomize sheet choising
local function choise_sprite(boxes)
	--box level probability distribution
	local distr={1,1,1,1,2,2,2,1,3,3}
	local x = math.random(#distr)
	local box_level=distr[x]
	return boxes[box_level]
end 

--scores
local function calcScores()
	scores=scores+current_sprite[state].score
	tapText.text=scores
	changed=true
end

--scores animation
local function flyScores()
	local flyScore=current_sprite[11]
	flyScore.x=display.contentCenterX-100
	flyScore.y=display.contentCenterY-100
	flyScore.isVisible=true
	transition.to( flyScore, { x=display.contentCenterX+100,y=0, time=250,
        onComplete = function() 
                         flyScore.isVisible=false
                         calcScores()
                     end
        } )
end

--speed calculation
local function calcSpeed()
	-- body
	if prevScores>0  then
		speed=scores-prevScores
		tapSpeed.text=speed..'src/s'
	end
	prevScores=scores
end 


--BIG DADDY!!!
local function crashBox()
	if busy then
		return false
	end
	local sprite=current_sprite
	if state<7 then
        audio.play(crash_sound)
        system.vibrate()
        if state~=1 then
            sprite[state-1].isVisible=false
            flyScores()
        end
        sprite[state].isVisible=true
		state=state+1
	elseif state==7 then
		audio.play(crash_sound)
		system.vibrate()
		sprite[6].isVisible=false
		sprite[5].isVisible=true
		flyScores()
		state=state+1
	elseif state==8 then
        audio.play(crash_sound)
        system.vibrate()
		sprite[5].isVisible=false
		sprite[7].isVisible=true
		flyScores()
		state=state+1
	elseif state==9 then
        sprite[7].isVisible=false
        audio.play(crash_sound)
        system.vibrate()
        sprite[8].x= display.contentCenterX
        sprite[8].y=display.contentCenterY-30
        sprite[9].x=display.contentCenterX-40
        sprite[9].y=display.contentCenterY+80
        sprite[10].x=display.contentCenterX+85
        sprite[10].y=display.contentCenterY
        sprite[8].isVisible=true
        sprite[9].isVisible=true
        sprite[10].isVisible=true
        state=state+1
        flyScores()
    elseif state==10 then
    	audio.play(crashed_sound)
    	system.vibrate()
		state=1
		busy=true
		transition.to( sprite[8], { x=-100, time=350,
        onComplete = function() sprite[8].isVisible=false end
        } )
	    transition.to( sprite[9], { y=400, time=350,
        onComplete = function() sprite[9].isVisible=false  end
        } )
	    transition.to( sprite[10], { y=-200, time=350,
        onComplete = function() sprite[10].isVisible=false
                                current_sprite=choise_sprite(boxes)
                                busy=false
                                crashBox()

                       end
        } )
		flyScores()

	end
end

local function add_box_listeners(sprites,callback)
	for i=1,3 do
		for j=1,9 do
			sprites[i][j]:addEventListener('tap',callback)
		end
	end
end

local function read_settings()
	local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
	if settings ==nil then
		file,errorString=io.open(path,'r')
		if file then
			local content=file:read( "*a" )
			settings=json.decode(content)
		end
	end
end

--backend functions
local function catchNetError(event)
	if event.isError then 
		print(event.errorString)
		--offlile mode screen
	else
		changed=false 
	end
end

local  function putStatistic()
	if settings~=nil then
		if changed then 
	        local params={}
	        local headers= {}
	        headers["Content-Type"] = "application/x-www-form-urlencoded"
	        params.body='scores='..scores..'&speed='..speed
	        params.headers=headers
	        network.request("http://localhost:3000/api/scores/"..settings.id, "PUT", catchNetError ,params)
	    end
	else 
		print('offline mode')
	end
end
--=============================================================================================
--=======================================END OF GAME FUNCTIONS=================================
--=============================================================================================

local function gotoScores()
	composer.gotoScene("scores",{ time=700, effect="crossFade" })
end

function scene:create(event)
	local sceneGroup = self.view
    --init display groups
	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)
	mainGroup =display.newGroup()
	sceneGroup:insert(mainGroup)
	uiGroup =display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect(backGroup, "UI/Background.png", 360, 570 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local menuIcon=display.newImageRect(uiGroup,'UI/menu.png',79,61)
    menuIcon.x=display.contentCenterX-100
    menuIcon.y=5

    local scoreText =display.newText(uiGroup,'Scores: ', display.contentCenterX+20, 0,'UI/DroidSerif-Regular.ttf', 28 )
    tapText = display.newText(uiGroup, scores, display.contentCenterX+100, 0, 'UI/DroidSerif-Regular.ttf', 28 )
    tapText:setFillColor( 0.757, 0.757, 0.757,1 )
    scoreText:setFillColor(  0.757, 0.757, 0.757,1 )

    local speedText=display.newText(uiGroup,'Speed: ',display.contentCenterX-20,display.contentCenterY+250,'UI/DroidSerif-Regular.ttf', 28)
    tapSpeed=display.newText(uiGroup,'0 src/s',display.contentCenterX+70,display.contentCenterY+250,native.systemFont, 28)
    tapSpeed:setFillColor(  0.757, 0.757, 0.757,1 )
    speedText:setFillColor(  0.757, 0.757, 0.757,1 )

    crash_sound = audio.loadSound( "audio/Crash.wav" )
    crashed_sound = audio.loadSound( "audio/crashed.wav" )

    boxes=create_boxes()
    add_box_listeners(boxes,crashBox)
    menuIcon:addEventListener('tap',gotoScores)
    current_sprite=choise_sprite(boxes)
    current_sprite[1].x=display.contentCenterX
    current_sprite[1].y=display.contentCenterY
    current_sprite[1].isVisible=true
    --Turn read the settings
    timer.performWithDelay(1000, read_settings,5)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
        scoreTimer=timer.performWithDelay(1000, calcSpeed,-1)
        statisticTimer=timer.performWithDelay(6000,putStatistic,-1)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
         timer.cancel(scoreTimer)
         timer.cancel(statisticTimer)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen


	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
