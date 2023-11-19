local soundTable=require("soundTable");
local composer = require("composer");

local Enemy = {tag="enemy", HP=1, xPos=0, yPos=0, fR=0, sR=0, bR=0, fT=1000, sT=500, bT	=500};
--HP is hitpoints,
--xpos and ypos are the starting position of the enemy
--fR is the rotation of the enemy when it is moving forward
--sR is the rotation of the enemy when it is moving to the side
--bR is the rotation of the enemy when it is moving backwards
--fT is the time it takes for the enemy to move forward
--sT is the time it takes for the enemy to move to the side
--bT is the time it takes for the enemy to move backwards

--I think??? - James


function Enemy:new (o)    --constructor
  o = o or {}; 
  setmetatable(o, self);
  self.__index = self;
  return o;
end

function Enemy:spawn()
  self.shape=display.newCircle(self.xPos, self.yPos,15);
  self.shape.pp = self;  -- parent object
  self.shape.tag = self.tag; -- “enemy”
  self.shape:setFillColor (1,1,0);
  physics.addBody(self.shape, "kinematic"); 

end


function Enemy:back ()
  transition.to(self.shape, {x=self.shape.x+100, y=150,  
  time=self.fB, rotation=self.bR, 
  onComplete=function (obj) self:forward() end} );
end

function Enemy:side ()   
   transition.to(self.shape, {x=self.shape.x-200, 
   time=self.fS, rotation=self.sR, 
   onComplete=function (obj) self:back() end } );
end

function Enemy:forward ()   
   transition.to(self.shape, {x=self.shape.x+100, y=800, 
   time=self.fT, rotation=self.fR, 
   onComplete= function (obj) self:side() end } );
end

function Enemy:move ()	
	self:forward();
end

function Enemy:hit () 
	self.HP = self.HP - 1;
	if (self.HP > 0) then 
		audio.play( soundTable["hitSound"] );
		self.shape:setFillColor(0.5,0.5,0.5);
	
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
    
    --Increase score
    composer.setVariable( "Score", composer.getVariable( "Score" ) + 100 )
	end		
end


function Enemy:shoot (interval)
  interval = interval or 1500;
  local function createShot(obj)
    local p = display.newRect (obj.shape.x, obj.shape.y+50, 
                               10,10);
    p:setFillColor(1,0,0);
    p.anchorY=0;
    physics.addBody (p, "dynamic");
    p:applyForce(0, 1, p.x, p.y);
		
    local function shotHandler (event)
      if (event.phase == "began") then
        event.target:removeSelf();
        event.target = nil;
      end
    end
    p:addEventListener("collision", shotHandler);		
  end
  self.timerRef = timer.performWithDelay(interval, 
	function (event) createShot(self) end, -1);
end




return Enemy

