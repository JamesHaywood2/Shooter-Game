local Enemy = require("objects.Enemy_Base");
local physics = require("physics");

local Plane = Enemy:new( {HP=2, fR=720, fT=700, bT=700} );

local spriteOpt = {frames={
  {x = 15, y = 4, width = 221, height = 118}
}}
local spriteSheet = graphics.newImageSheet("objects/Enemy.png", spriteOpt)
local spriteSeq = {
  {name = "default", frames = {1}}
}

local scaleFactor = 0.35;
--Get width and height of sprite from spriteOpt
local width = spriteOpt.frames[1].width * scaleFactor;
local height = spriteOpt.frames[1].height * scaleFactor;
local hitboxShape = {-width/2,-height/2, width/2,-height/2, width/2,height/2, -width/2,height/2};
--Shape goes counter-clockwise from bottom left corner
--Just take the width and height of the sprite from spriteOpt, multiply by the scale, and divide by 2 to get the coordinates of the corners. Round up.

function Plane:spawn(xPos, yPos)
  self.shape = display.newSprite(spriteSheet, spriteSeq);
  self.shape:setSequence("default");
  self.shape:play();
  self.shape.x = xPos
  self.shape.y = yPos
  self.shape:scale(scaleFactor, scaleFactor)
  
  self.shape.pp = self;
  self.shape.tag = "enemy";
  
  local enemyCollisionFilter = { categoryBits = 4, maskBits = 19 }
  physics.addBody(self.shape, "kinematic",{shape=hitboxShape, filter=enemyCollisionFilter});
end

--Will add velocity to the Plane in the -x direction
function Plane:move()
    --speed should be like 150 - 250??
    local speed = 200;
    self.shape:setLinearVelocity(-speed, 0);
end

return Plane;