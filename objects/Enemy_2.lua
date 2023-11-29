local Enemy = require("objects.Enemy_Base");

local Triangle = Enemy:new( {HP=3});

local spriteOpt = {frames={
    {x = 24, y = 246, width = 300, height = 162}
  }}
local spriteSheet = graphics.newImageSheet("objects/Enemy.png", spriteOpt)
local spriteSeq = {
    {name = "default", frames = {1}}
}

local scaleFactor = 0.5;
--Get width and height of sprite from spriteOpt
local width = spriteOpt.frames[1].width * scaleFactor;
local height = spriteOpt.frames[1].height * scaleFactor;
local hitboxShape = {-width/2,-height/2, width/2,-height/2, width/2,height/2, -width/2,height/2};
--Shape goes counter-clockwise from bottom left corner
--Just take the width and height of the sprite from spriteOpt, multiply by the scale, and divide by 2 to get the coordinates of the corners. Round up.

function Triangle:spawn()
    self.shape = display.newSprite(spriteSheet, spriteSeq);
    self.shape:setSequence("default");
    self.shape:play();
    self.shape.x = display.actualContentWidth+50;
    self.shape.y = math.random(50, display.actualContentHeight-50);
    self.shape:scale(scaleFactor, scaleFactor)

    self.shape.pp = self;
    self.shape.tag = "enemy";
    local enemyCollisionFilter = { categoryBits = 4, maskBits = 19 }
    physics.addBody(self.shape, "kinematic",{shape=hitboxShape, filter=enemyCollisionFilter});

end

function Triangle:move(playerX, playerY)
    --idk what the movement is exactly for this enemy.
    --It say's it should move towards the player, but idk if that means constantly (follow the player) or move towards the players position at time of spawn.
    --I'm going to assume it means move towards the player at time of spawn.

    --Find the unit vector between the player and the enemy
    local xDist = playerX - self.shape.x;
    local yDist = playerY - self.shape.y;
    local dist = math.sqrt(xDist^2 + yDist^2);
    local xUnit = xDist/dist;
    local yUnit = yDist/dist;

    --Set the velocity of the enemy to the unit vector * speed
    local speed = 200;
    self.shape:setLinearVelocity(xUnit*speed, yUnit*speed);
end


return Triangle;
