-- Project Description says that the Boss is supposed to extend functionality of Enemy class
-- I'm not 100% sure what that means so I'm just doing this for now -- Lilli
local Enemy = require("objects.Enemy_Base");
local soundTable=require("soundTable");
local physics = require("physics");

local Boss = Enemy:new( {HP=30} );

--The variable 'fish' contains every display object that makes up the fish    

function Boss:spawn()
    local fishOpt =
    {
        frames = {
            {x=22, y=8, width=167, height=50}, --Fish body -1
            {x=207, y=27, width=16, height=9}, --Snout a -2
            {x=228, y=27, width=16, height=9}, --Snout b -3
            {x=249, y=27, width=16, height=9}, --Snout c-4
            {x=281, y=20, width=56, height=26}, -- mouth a-5
            {x=344, y=20, width=56, height=26}, -- mouth b-6
            {x=407, y=20, width=56, height=26}, -- mouth c-7
            {x=22, y=93, width=54, height=37}, -- P fin a-8
            {x=80, y=99, width=54, height=37}, -- P fin b-9
            {x=140, y=102, width=54, height=37}, -- P fin c-10
            {x=211, y=70, width=47, height=92}, -- caudial fin a-11
            {x=267, y=70, width=55, height=92}, -- caudial fin b-12
            {x=331, y=70, width=60, height=92}, -- caudial fin c-13
            {x=405, y=93, width=60, height=46}, -- dorsal fin-14
        }
    }
    --Image sheet for fish
    local fishSheet = graphics.newImageSheet("objects/KingBayonet.png",fishOpt)

    local fishSeqData = {
        {name = "mouthOn",start=5,count=3,time=1000,loopCount=1},
        {name = "snoutOn", frames={2,3,4},time=500,loopCount=1},
        {name = "pFinOn",frames={8,9,10},time=1000,loopCount=1},
        {name = "cFinOn",frames={11,12,13},time=1000,loopCount=1},
        {name="dFinOn",start=14,count=1,time=100,loopCount=1}
    }

    --Create fish group
    self.shape = display.newGroup()
    --Join all the fish parts together
    local fishBody = display.newImage(self.shape, fishSheet, 1)

    --Set the x and y of the fish parts
    self.shape.anchorChildren = true
    self.shape.AnchorX, self.shape.AnchorY = 0.5, 0.5
    self.shape.x = display.actualContentWidth
    self.shape.y = display.contentCenterY
    self.shape.xScale = 1.5
    self.shape.yScale = 1.5

    --Add the mouth
    local mouth = display.newSprite(self.shape, fishSheet, fishSeqData)
    mouth:setSequence("mouthOn")
    mouth:toBack()
    mouth.anchorX, mouth.anchorY = 1, 0 --Set the anchor point to the top right corner of the mouth
    mouth.x, mouth.y = -11, -6.5 --Move the mouth
    mouth.xScale, mouth.yScale = 1.032, 1.042 --The mouth didn't fit on the fish's body perfectly so I stretched it a super small ammount to make it fit.
   
    --Add the caudal fin
    local cFin = display.newSprite(self.shape, fishSheet, fishSeqData)
    cFin:setSequence("cFinOn")
    cFin.anchorX, cFin.anchorY = 0, 0.5
    cFin.x, cFin.y = 76, -3

    --Add the pectoral fin
    local pFin = display.newSprite(self.shape, fishSheet, fishSeqData)
    pFin:setSequence("pFinOn")
    pFin:toBack()
    pFin.anchorX, pFin.anchorY = 0, 0 --Anchor point is the top left corner of the fin
    pFin.x, pFin.y = 0, 11

    --Add the snout
    local snout = display.newSprite(self.shape, fishSheet, fishSeqData)
    snout:setSequence("snoutOn")
    snout.anchorX, snout.anchorY = 1, 0 --Anchor point is the top right corner of the snout
    snout.x, snout.y = -83, -1.0

    --Add the dorsal fin
    local dFin = display.newSprite(self.shape, fishSheet, fishSeqData)
    dFin:setSequence("dFinOn")
    dFin:toBack()
    dFin.anchorX, dFin.anchorY = 0,1 --Anchor point is the bottom left corner of the fin
    dFin.x, dFin.y = -15.5, -15.5

    self.shape.pp = self;
    self.shape.tag = "enemy";
    physics.addBody(self.shape, "kinematic"); 
end

-- Boss movingly around randomly has not been implemented yet
-- Move function from Enemy1
function Boss:move()
    local speed = 200;
    self.shape:setLinearVelocity(-speed, 0);
end

function Boss:hit()
    self.HP = self.HP - 1
    if (self.HP > 0) then 
		audio.play( soundTable["hitSound"] );
        return 0;
	else 
		audio.play( soundTable["explodeSound"] );
		
        transition.cancel( self.shape );
		
		if (self.timerRef ~= nil) then
			timer.cancel ( self.timerRef );
		end

		-- die
		self.shape:removeSelf();
		self.shape=nil;	
		--self = nil;
    
        --Boss destroyed, increase score
        composer.setVariable( "Score", composer.getVariable( "Score" ) + 10E3 )

        return 1;
	end		
end

return Boss;
