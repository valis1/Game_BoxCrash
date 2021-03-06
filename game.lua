local widget = require( "widget" )
local composer = require( "composer" )
local json = require( "json" )
local physics = require( "physics" )
local spriteSet=require("spriteSettings")
physics.start()
physics.setGravity( 0, 0 )
--scene
local scene = composer.newScene()

--inital state 
local  state = 2
local scores=0
local speed = 0
local prevScores=0
local busy=false 
local changed=false
local best=false
local next_score=100
local busy=false
local balloonsTable={}
local settings


--variables
local sheet
local crash_sound
local crashed_sound
local ballonCrash
local tapSpeed
local current_sprite
local boxes
local settings
local scoreText
local targetText
local systemSettings

--display groups
local backGroup 
local mainGroup
local ballonGroup 
local uiGroup 

--loading sheet`s options
local sheetOptions=spriteSet.sheetOptions
local scoresSheetOptions=spriteSet.scoresSheetOptions
local ballSheetOptions=spriteSet.ballSheetOptions
local crashBallSequences =spriteSet.crashBallSequences

local scoreSheet=graphics.newImageSheet('sheets/scores.png',scoresSheetOptions)
local balloonSheet = graphics.newImageSheet('sheets/balloonSheet.png',ballSheetOptions)

local progressOptions={
	x=display.contentCenterX,
	y=25,
	width=200,
	isAnimated=true
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
    	for j=1,10 do
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

--scores animation
local function flyScores(score,x,y)
	local sprite_score={2,3,6,20,30,60}
	local sprite=table.indexOf(sprite_score,score)
	local flyScore=display.newImage(uiGroup,scoreSheet,sprite)
	flyScore.x=x or display.contentCenterX+100
	flyScore.y=y or display.contentCenterY-100
	transition.to( flyScore, { x=display.contentCenterX-70,y=40, time=700,
            onComplete = function() 
                         display.remove(flyScore)
                         flyScore=nil
                     end
        } )
end

--scores
local function calcScores(score,x,y)
	scores=scores+score
	flyScores(score,x,y)
	scoreText.text=scores
	if scores >= next_score then
		if best then
		    next_score=scores+math.floor((scores/100)*20)
		    targetText.text=next_score
		end
	end
	local progress=scores/next_score
	progressView:setProgress(progress)
	changed=true
end

--speed calculation
local function calcSpeed()
	-- body
	if prevScores>0  then
		speed=scores-prevScores
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
            calcScores(sprite[state].score)
        end
        sprite[state].isVisible=true
		state=state+1
	elseif state==7 then
		audio.play(crash_sound)
		system.vibrate()
		sprite[6].isVisible=false
		sprite[5].isVisible=true
		calcScores(sprite[state].score)
		state=state+1
	elseif state==8 then
        audio.play(crash_sound)
        system.vibrate()
		sprite[5].isVisible=false
		sprite[7].isVisible=true
		calcScores(sprite[state].score)
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
        calcScores(sprite[state].score)
    elseif state==10 then
    	system.vibrate()
    	audio.play(crashed_sound) 
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
		calcScores(sprite[state].score)

	end
end

local function add_box_listeners(sprites,callback)
	for i=1,3 do
		for j=1,9 do
			sprites[i][j]:addEventListener('tap',callback)
		end
	end
end

local function crashBall(event)
   local thisSprite=event.target
   audio.play(ballonCrash)
   thisSprite:play()
   calcScores(thisSprite.score,thisSprite.x,thisSprite.y)

end 

local function destroyBall(event)
	local thisSprite = event.target 
	if  event.phase == "ended" then 
	    local ind=table.indexOf(balloonsTable,thisSprite)
	    display.remove(thisSprite)
	    table.remove(balloonsTable,ind)
	end
end

local function createBall() --1,5,9
	--probability distribution
	local odds={0,0,0,0,0,0,0,0,20,20,20,20,20,20,30,30,30,30,60,60}
	local x = math.random(#odds)
	local score=odds[x]
	local seq
	if score~=0 then
		if score==20 then
            seq='RedBall'
		elseif score==30 then
			seq='BlueBall'
		else
			seq='GreenBall'
		end
		local newBall = display.newSprite(ballonGroup,balloonSheet,crashBallSequences)
		newBall.score=score
		newBall.alpha=0.7
		newBall:addEventListener('tap',crashBall)
		newBall:addEventListener( "sprite", destroyBall )
		newBall:setSequence(seq)
		newBall.x=math.random(30,160)
		newBall.y=500
		physics.addBody( newBall, "dynamic", { radius=90, bounce=0.8 } )
		newBall:setLinearVelocity(math.random(9,15),math.random(-90,-40))
		table.insert(balloonsTable,newBall)
	end

end
--backend functions

local function statCallback(event)
	if event.isError then 
		print(event.errorString)
		--offlile mode screen
	else
		changed=false
		local response=json.decode(event.response);
		if (#response==0) then
			local progress
			best=true
			if scores >0 then
			    next_score=scores+math.floor((scores/100)*20)
			    progress=scores/next_score
            else 
            	next_score=100
            	progress=0
            end
		    targetText.text=next_score
	        progressView:setProgress(progress)
		else
			best=false
			next_score=response[1].score
			local progress
			if scores==0 and next_score==0 then
				next_score=100
				progress=0
			elseif scores>0 and next_score==0 then
				next_score=scores+math.floor((scores/100)*20)
				progress=0.8
			elseif scores==0 and next_score>0 then
				progress=0
			else
				progress=scores/next_score
            end
		    progressView:setProgress(progress)
			targetText.text=next_score
		end
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
	        network.request(systemSettings.server.."/api/scores/"..settings.id, "PUT",statCallback,params)
	    end
	end
end


local function getMyScoresCallback(event)
	if event.isError then
		print(event.errorString) -- OFFLINE MODE SCREEN
	else
		local response= json.decode(event.response);
		scores=scores+tonumber(response.score)
		next_score=scores+math.floor((scores/100)*20)
		scoreText.text=scores
		targetText.text=next_score
		changed=true
	end
end

local function register(event)
	if not event.isError then
		local response = json.decode(event.response)
		local gameDataPath = system.pathForFile( "gameData.json", system.DocumentsDirectory)
		settings={}
		settings.id=response['_id']
		settings.nick=response['nick']
		local file,errorString=io.open(gameDataPath,'w')
		if  file then
		    file:write(json.encode({id=response['_id'] ,nick=response['nick']}))
		    io.close(file)
		    file=nil
		end 
	end
end	

local function read_settings()
	local path = system.pathForFile( "gameData.json", system.DocumentsDirectory)
	local params = {}
	local body = "model="..system.getInfo("model")
    params.body = body
	if settings == nil then
		local file,errorString=io.open(path,'r')
		if file then
			local content=file:read( "*a" )
			settings=json.decode(content)
			io.close(file)
			network.request(systemSettings.server.."/api/scores/"..settings.id, "GET",getMyScoresCallback)
		else
		    network.request(systemSettings.server.."/api/scores", "POST", register,params) 
		end
	end
end

local function gameLoop()
	createBall()
	read_settings()
	putStatistic()
    --cleenup balls
	for i = #balloonsTable, 1, -1 do
		local ball=balloonsTable[i]
		if ball.x>=display.contentCenterY-100 then
			display.remove(ball)
			table.remove(balloonsTable,i)
		end
	end
end 

local function compleateExitAlert(event)
	if ( event.action == "clicked" ) then
        local i = event.index
        if ( i == 1 ) then
            os.exit()
        elseif ( i == 2 ) then
        end
    end
end 

local function exit()
	local alert = native.showAlert( "Выход", "Хотите выйти?", { "Да","Нет"},compleateExitAlert)
end 
--=============================================================================================
--=======================================END OF GAME FUNCTIONS=================================
--=============================================================================================
local function compleateAlert(event)

end 
local function gotoScores()
	if settings then 
	    composer.gotoScene("scores",{ time=700, effect="crossFade",params={id=settings.id,url=systemSettings.server} })
    else
    	local alert = native.showAlert( "Ошибка", "Нет связи с сервером", { "Выход"},compleateAlert)

    end
end
 function scene:create(event)
	local sceneGroup = self.view
	systemSettings=event.params.settings
    --init display groups
	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)
	mainGroup =display.newGroup()
	sceneGroup:insert(mainGroup)
	ballonGroup=display.newGroup()
	sceneGroup:insert(ballonGroup)
	uiGroup =display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect(backGroup, "UI/Background.png", 360, 570 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local menuIcon=display.newImageRect(uiGroup,'UI/menu.png',94,42)
    menuIcon.x=display.contentCenterX-100
    menuIcon.y=display.contentCenterY+240

    local menuExitIcon=display.newImageRect(uiGroup,'UI/menuExit.png',94,42)
    menuExitIcon.x=display.contentCenterX+100
    menuExitIcon.y=display.contentCenterY+240

    local progText=display.newText(uiGroup,'Прогресс',display.contentCenterX,-10,'UI/DroidSerif-Regular.ttf', 20)
    progText:setFillColor(0.757, 0.757, 0.757,1)

    local myMenuScoreText=display.newText(uiGroup,'Я',60,10,'UI/DroidSerif-Regular.ttf', 20)
    myMenuScoreText:setFillColor(0.757, 0.757, 0.757,1)

    local opponentMenuScoreText=display.newText(uiGroup,'Враг',display.contentCenterX+100,10,'UI/DroidSerif-Regular.ttf', 20)
    opponentMenuScoreText:setFillColor(0.757, 0.757, 0.757,1)

    progressView = widget.newProgressView(progressOptions)
    scoreText=display.newText(uiGroup,scores,display.contentCenterX-100,38,'UI/DroidSerif-Regular.ttf',20)
    scoreText:setFillColor(0.757, 0.757, 0.757,1)

    targetText=display.newText(uiGroup,next_score,display.contentCenterX+100,38,'UI/DroidSerif-Regular.ttf',20)
    targetText:setFillColor(0.757, 0.757, 0.757,1)

    crash_sound = audio.loadSound( "audio/Crash.wav" )
    crashed_sound = audio.loadSound( "audio/crashed.wav" )
    ballonCrash=audio.loadSound("audio/Ballon.wav")

    boxes=create_boxes()
    add_box_listeners(boxes,crashBox)
    menuIcon:addEventListener('tap',gotoScores)
    menuExitIcon:addEventListener('tap',exit)
    current_sprite=choise_sprite(boxes)
    current_sprite[1].x=display.contentCenterX
    current_sprite[1].y=display.contentCenterY
    current_sprite[1].isVisible=true
    --Turn read the settings
    read_settings()
end
-- show()
 function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
        scoreTimer=timer.performWithDelay(1000, calcSpeed,-1)
        gameLoopTimer=timer.performWithDelay(5000,gameLoop,-1)
        physics.start()
        progressView.isVisible=true
	end
end
-- hide()
 function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
         timer.cancel(scoreTimer)
         timer.cancel(gameLoopTimer)
         progressView.isVisible=false
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		 physics.pause()


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
