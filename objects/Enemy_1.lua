local Enemy = require("objects.Enemy_Base");
local physics = require("physics");

local Square = Enemy:new( {HP=2, fR=720, fT=700, bT=700} );

local opt = 
{
  frames = {
    {x = 15, y = 4, width = 221, height = 118} -- small plane
  }
}

local sheet = graphics.newImageSheet("Enemy.png", opt)

local sequence = {
  {
    name = "plane", frames = {1}
  }
}


function Square:spawn()
  self.shape = display.newRect (display.actualContentWidth+50, math.random(50, display.actualContentHeight-50), 30, 30); 
  --sprite = display.newImage(sheet, 1)
  --self.shape:setSequence("plane")
  self.shape.pp = self;
  self.shape.tag = "enemy";
  self.shape:setFillColor ( 0, 1, 1);
  --planeOutline = graphics.newOutline(1, sheet, 1)
  physics.addBody(self.shape, "kinematic"); 
end

--Will add velocity to the square in the -x direction
function Square:move()
    --speed should be like 150 - 250??
    local speed = 200;
    self.shape:setLinearVelocity(-speed, 0);
end

return Square;