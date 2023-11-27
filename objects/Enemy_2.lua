local Enemy = require("objects.Enemy_Base");

local Triangle = Enemy:new( {HP=3});

function Triangle:spawn()
    self.shape = display.newPolygon(display.actualContentWidth+50, math.random(50, display.actualContentHeight-50),{-15,-15, 15,-15 ,0,15});
    self.shape.xScale = 2;
    self.shape.yScale = 2;
    self.shape.pp = self;
    self.shape.tag = "enemy";
    self.shape:setFillColor ( 1, 0, 1);
    physics.addBody(self.shape, "kinematic",{shape={-30,-30,30,-30,0,30}}); 
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
