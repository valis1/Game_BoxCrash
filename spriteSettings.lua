local m={}

m.sheetOptions={
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
    }
   }
}

m.scoresSheetOptions={frames={
    --+2
	{
	x=0,
	y=0,
	width=20,
	height=20
    },
    --+3
    {
	x=21,
	y=0,
	width=20,
	height=20
    },
    --+6
    {
	x=43,
	y=0,
	width=20,
	height=20
    },
    --+20
    {
	x=64,
	y=0,
	width=33,
	height=20
    },
    --+30
    {
	x=98,
	y=0,
	width=33,
	height=20
    },
    --+60
    {
	x=132,
	y=0,
	width=33,
	height=20
    },
}}

m.ballSheetOptions={
	frames={
	--inital Red Ball (1)
	{
	x=0,
	y=0,
	width=65,
	height=96
    },
    --Rad Ball Crash 1 (2)
    {
	x=75,
	y=0,
	width=80,
	height=97
    },
    --Rad Ball Crash 2 (3)
    {
	x=156,
	y=0,
	width=94,
	height=124
    },
    --Rad Ball Final Crash (4)
    {
	x=263,
	y=0,
	width=93,
	height=132
    },
    --inital Blue Ball (5)
	{
	x=0,
	y=135,
	width=65,
	height=96
    },
    --Blue Ball Crash 1 (6)
    {
	x=75,
	y=135,
	width=80,
	height=97
    },
    --Blue Ball Crash 2 (7)
    {
	x=156,
	y=135,
	width=94,
	height=124
    },
    --Blue Ball Final Crash (8)
    {
	x=263,
	y=135,
	width=93,
	height=132
    },
    --inital Green Ball (9)
	{
	x=0,
	y=288,
	width=65,
	height=96
    },
    --Green Ball Crash 1 (10)
    {
	x=75,
	y=288,
	width=80,
	height=97
    },
    --Green Ball Crash 2 (11)
    {
	x=156,
	y=288,
	width=94,
	height=124
    },
    --Green Ball Final Crash (12)
    {
	x=263,
	y=288,
	width=93,
	height=132
    }
   }
} 

m.crashBallSequences = {
    {
        name = "RedBall",
        frames = {1,2,3,4},
        time = 300,
        loopCount = 1
    },
    {
        name = "BlueBall",
        frames = {5,6,7,8},
        time = 300,
        loopCount = 1
    },
    {
        name = "GreenBall",
        frames = {9,10,11,12},
        time = 300,
        loopCount = 1
    },
}
return m