-- Project Description says that the Boss is supposed to extend functionality of Enemy class
-- I'm not 100% sure what that means so I'm just doing this for now -- Lilli
local Enemy = require("objects.Enemy_Base");
local soundTable=require("soundTable");
local composer = require("composer");
local physics = require("physics");

local Boss = Enemy:new( {HP=30} );

--The variable 'fish' contains every display object that makes up the fish    

function Boss:spawn()
    --Set HP to 30  
    self.HP = 30

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
    local scaleFactor = 2.5;
    self.shape:scale(scaleFactor, scaleFactor)
    -- self.shape.xScale = 2.5
    -- self.shape.yScale = 2.5

    --Add the mouth
    mouth = display.newSprite(self.shape, fishSheet, fishSeqData)
    mouth:setSequence("mouthOn")
    mouth:toBack()
    mouth.anchorX, mouth.anchorY = 1, 0 --Set the anchor point to the top right corner of the mouth
    mouth.x, mouth.y = -11, -6.5 --Move the mouth
    mouth.xScale, mouth.yScale = 1.032, 1.042 --The mouth didn't fit on the fish's body perfectly so I stretched it a super small ammount to make it fit.
   
    --Add the caudal fin
    cFin = display.newSprite(self.shape, fishSheet, fishSeqData)
    cFin:setSequence("cFinOn")
    cFin.anchorX, cFin.anchorY = 0, 0.5
    cFin.x, cFin.y = 76, -3

    --Add the pectoral fin
    pFin = display.newSprite(self.shape, fishSheet, fishSeqData)
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


    --(fishOpt.frames[14].width*scaleFactor)/2

    --Hitbox shape
    local snout = {halfWidth = 80, halfHeight=20, x=-200, y=23}
    local body = {halfWidth = 140, halfHeight=50, x=0, y=15}
    local dFin = {halfWidth = 30, halfHeight=70, x=10, y=-75, angle=55}
    local cFin = {halfWidth = 30, halfHeight=70, x=10, y=75, angle=-55}

    local enemyCollisionFilter = { categoryBits = 4, maskBits = 2 }
    physics.addBody(self.shape, "kinematic",
        {box=snout, isSensor=true, filter=enemyCollisionFilter},
        {box=body, isSensor=true, filter=enemyCollisionFilter},
        {box=dFin, isSensor=true, filter=enemyCollisionFilter},
        {box=cFin, isSensor=true, filter=enemyCollisionFilter}
    ); 
end

function Boss:move()
    -- Moves to a random position on the screen
    local function singleMove()
        transition.to(self.shape,{time=2000,x=math.random(display.contentCenterX-75,display.actualContentWidth-100),y=math.random(50,display.actualContentHeight-100) }) 
    end
    movingTimer = timer.performWithDelay(2000,singleMove,-1) -- repeatedly move

    local speed = 100;
    self.shape:setLinearVelocity(-speed, 0);
end

function Boss:hit()
    self.HP = self.HP - 1
    if (self.HP > 0) then 
		audio.play( soundTable["hitSound"] );
        print("boss hit: " .. self.HP)
        return 0;
	else 
		audio.play( soundTable["explodeSound"] );
        transition.cancel( self.shape );
        transition.cancel(movingTimer)
        
		if (self.timerRef ~= nil) then
			timer.cancel ( self.timerRef );
		end

		-- die
		self.shape:removeSelf();
		self.shape=nil;	
		--self = nil;

        -- Acknowledge boss has been destroyed
        composer.setVariable("bossDefeated",true);
    
        --increase score
        composer.setVariable( "Score", composer.getVariable( "Score" ) + 10E3 )

        return 1;
	end		
end

local projectileOpt = { frames = {
    {x = 25, y = 18, width = 137, height = 67},
    {x = 195, y = 44, width = 75, height = 36},
    {x = 295, y = 39, width = 101, height = 46},
    {x = 26, y = 109, width = 128, height = 93},
    {x = 225, y = 136, width = 96, height = 39},
  }}
local projectileSheet = graphics.newImageSheet("objects/Projectiles.png", projectileOpt)
local projectileSeq = {
    {name = "shark", frames = {1}},
    {name = "blueFireball1", frames = {2}},
    {name = "blueFireball2", frames = {3}},
    {name = "arc", frames = {4}},
    {name = "redFireball", frames = {5}},
}


function Boss:fireProjectile(sceneGroup, playerX, playerY)
    local function playerDirection(playerX, playerY)
        local xDist = playerX - self.shape.x;
        local yDist = playerY - self.shape.y;
        local dist = math.sqrt(xDist^2 + yDist^2);
        local xUnit = xDist/dist;
        local yUnit = yDist/dist;
        return xUnit, yUnit
    end

    local function createProjectile(sequence, xScale, yScale)
        --Default values
        sequence = sequence or "blueFireball1"
        xScale = xScale or 1
        yScale = yScale or 1

        local projectile = display.newSprite(projectileSheet, projectileSeq);
        projectile:setSequence(sequence)
        sceneGroup:insert(projectile)
        projectile.tag = "EnemyProjectile";
        --Mirror projectile so it's facing the player
        projectile.xScale = -1;
        local projectileCollisionFilter = { categoryBits = 8, maskBits = 17 }
        projectile.x, projectile.y = self.shape.x-150, self.shape.y

        projectile:scale(xScale, yScale)
        local projectileHitbox = {-projectile.width*xScale/2, -projectile.height*yScale/2, projectile.width*xScale/2, -projectile.height*yScale/2, projectile.width*xScale/2, projectile.height*yScale/2, -projectile.width*xScale/2, projectile.height*yScale/2}
        physics.addBody(projectile, "kinematic", {isSensor=true, filter=projectileCollisionFilter, shape=projectileHitbox})
        return projectile
    end

    --Generate a random number between 1 and 3 to determine which projectile to fire
    local projectileType = math.random(1,100);
    --Fire the projectile
    if (projectileType <= 25) then
        --25% chance to fire a shark that moves towards the player faster than the other projectiles
        local projectile = createProjectile("shark", 1, 1)

        projectile.rotation = math.atan((playerY - self.shape.y)/(playerX - self.shape.x))*180/math.pi
        local xUnit, yUnit = playerDirection(playerX, playerY)
        projectile:setLinearVelocity(xUnit*500, yUnit*500);
    elseif (projectileType > 25 and projectileType <= 65) then
        --40% chance to fire a blue fireball that moves straight across the screen
        local projectile1 = createProjectile("blueFireball1")
        projectile1:setLinearVelocity(-300, 0);
    elseif (projectileType > 65 and projectileType <= 90) then
        --25% chance to fire a fan of blue fireballs
        --One fireball goes straight across the screen
        local projectile = createProjectile("blueFireball2", 0.5, 0.5)
        projectile:setLinearVelocity(-300, 0);

        --One fireball is angled up
        local projectile2 = createProjectile("blueFireball2", 0.5, 0.5)
        projectile2.rotation = 10
        projectile2:setLinearVelocity(-300, -50);

        --One is angled down
        local projectile3 = createProjectile("blueFireball2", 0.5, 0.5)
        projectile3.rotation = -10
        projectile3:setLinearVelocity(-300, 50);
    elseif (projectileType > 90 and projectileType <= 100) then
        --20% chance to fire an wide arc
        local projectile = createProjectile("arc", 1, 2)
        projectile:setLinearVelocity(-200, 0);
    end

end

return Boss;
