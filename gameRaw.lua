-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
--inital state 
local  state = 2
local scores=0
local prevScores=0
local busy=false


-- display groups 
local backGroup = display.newGroup() 
local mainGroup = display.newGroup()
local uiGroup = display.newGroup() 

-- sheetOptions

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

--loading sheets
local level_one_sheet=graphics.newImageSheet('sheets/SimpleBoxSheet.png',sheetOptions)
local level_twoo_sheet = graphics.newImageSheet('sheets/Level2BoxSheet.png',sheetOptions)
local level_three_sheet = graphics.newImageSheet('sheets/Level3BoxSheet.png',sheetOptions)

local sheet=level_one_sheet

local background = display.newImageRect(backGroup, "UI/Background.png", 360, 570 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local ricon=display.newImageRect(uiGroup,'repeat.png',50,50)
ricon.x=display.contentCenterX -120
ricon.y=5

local scoreText =display.newText(uiGroup,'Scores: ', display.contentCenterX+20, 0,'UI/DroidSerif-Regular.ttf', 28 )
local tapText = display.newText(uiGroup, scores, display.contentCenterX+100, 0, 'UI/DroidSerif-Regular.ttf', 28 )
tapText:setFillColor( 0.757, 0.757, 0.757,1 )
scoreText:setFillColor(  0.757, 0.757, 0.757,1 )

local speedText=display.newText(uiGroup,'Your Speed: ',display.contentCenterX-20,450,'UI/DroidSerif-Regular.ttf', 28)
local tapSpeed=display.newText(uiGroup,'0 src/s',display.contentCenterX+100,450,native.systemFont, 28)
tapSpeed:setFillColor(  0.757, 0.757, 0.757,1 )
speedText:setFillColor(  0.757, 0.757, 0.757,1 )

--sound
local crash_sound = audio.loadSound( "audio/Crash.wav" )
local crashed_sound = audio.loadSound( "audio/crashed.wav" )

--create sprites with boxes 
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
    		sprites[i][j].is_inital=true
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

--inital box Creation 
local boxes=create_boxes()
local current_sprite=choise_sprite(boxes)
current_sprite[1].x=display.contentCenterX
current_sprite[1].y=display.contentCenterY
current_sprite[1].isVisible=true
current_sprite[1].is_inital=false


--scores
local function calcScores()
	scores=scores+current_sprite[state].score
	tapText.text=scores
end

--flyScores
local function flyScores()
	local flyScore=current_sprite[11]
	flyScore.x=display.contentCenterX-100
	flyScore.y=display.contentCenterY-100
	flyScore.isVisible=true
	transition.to( flyScore, { x=tapText.x,y=tapText.y, time=250,
        onComplete = function() 
                         flyScore.isVisible=false
                         calcScores()
                     end
        } )
end

local function crashBox()
	if busy then
		return false
	end
	local sprite=current_sprite
	if state<7 then
		--if creation in inital state
        if sprite[state].is_inital then
        	sprite[state]:addEventListener('tap',crashBox)
        	sprite[state].x=display.contentCenterX
        	sprite[state].y=display.contentCenterY
        	sprite[state].is_inital=false
        end
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
		if sprite[state].is_inital then
        	sprite[7]:addEventListener('tap',crashBox)
        	sprite[7].x=display.contentCenterX
        	sprite[7].y=display.contentCenterY
        	sprite[7].is_inital=false
        end
        audio.play(crash_sound)
        system.vibrate()
		sprite[5].isVisible=false
		sprite[7].isVisible=true
		flyScores()
		state=state+1
	elseif state==9 then
		if sprite[8].is_inital then
        	sprite[8]:addEventListener('tap',crashBox)
        	sprite[8].is_inital=false
        end
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
		transition.to( sprite[8], { x=-100, time=250,
        onComplete = function() sprite[8].isVisible=false end
        } )
	    transition.to( sprite[9], { y=400, time=250,
        onComplete = function() sprite[9].isVisible=false  end
        } )
	    transition.to( sprite[10], { y=-200, time=250,
        onComplete = function() sprite[10].isVisible=false
                                current_sprite=choise_sprite(boxes)
                                busy=false
                                crashBox()

                       end
        } )
		flyScores()

	end
end

current_sprite[1]:addEventListener('tap',crashBox)

local function calcSpeed()
	-- body
	if prevScores>0  then
		local src=scores-prevScores
		tapSpeed.text=src..'src/s'
	end
	prevScores=scores
end 

local function rsume()
	os.exit()
end 
ricon:addEventListener( "tap", rsume )

local function game_loop()

	
end 
timer.performWithDelay( 1000, calcSpeed,-1 )
ricon:addEventListener( "tap", rsume )