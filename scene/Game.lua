local composer = require( "composer" )
local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
--paralax variables


-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   display.setDefault("background", 1, 1, 1)
   
   addScrollableBg()
   Runtime:addEventListener("enterFrame", enterFrame)


end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------


--Other game code

local bg1
local bg2
local bg3
local runtime = 0
local scrollSpeed = 1.4 --1.4

local bgS1
local bgS2
local bgS3
local scrollSpeed2 = 5

function addScrollableBg()
   --Again this just condenses the code. I think it makes it a little easier to read. - James
   local function makeBG(image, xPos)
      local bg = display.newRect(0, 0, display.contentWidth, display.actualContentHeight)
      bg.fill = image
      bg.x = xPos
      bg.y = display.contentCenterY
      return bg
   end

   local bgImage = { type="image", filename="farback.png" }
   --Add first bg image in the center
   bg1 = makeBG(bgImage, display.contentCenterX)
   --Add second bg image. This should be behind the first one
   bg2 = makeBG(bgImage, display.contentCenterX - display.actualContentWidth + 250)
   --Add third bg image. This should be in front of the first one
   bg3 = makeBG(bgImage, display.contentCenterX + display.actualContentWidth - 250)

   local bgImage2 = { type="image", filename="starfield.png" }
   --Add first bg image in the center
   bgS1 = makeBG(bgImage2, display.contentCenterX)
   --Add second bg image. This should be behind the first one
   bgS2 = makeBG(bgImage2, display.contentCenterX - display.actualContentWidth + 250)
   --Add third bg image. This should be in front of the first one
   bgS3 = makeBG(bgImage2, display.contentCenterX + display.actualContentWidth - 250)

end

function moveBg(dt)
   --This just condenses code and makes it easier to read imo - James.
   local function move(bg, scrollSpeed)
      bg.x = bg.x + scrollSpeed * dt

      if (bg.x - display.contentWidth/2.5) > display.actualContentWidth then
         bg:translate(-bg.contentWidth * 2.8 , 0)
      end
   end

   move(bg1, scrollSpeed)
   move(bg2, scrollSpeed)
   move(bg3, scrollSpeed)

   move(bgS1, scrollSpeed2)
   move(bgS2, scrollSpeed2)
   move(bgS3, scrollSpeed2)
end

function getDeltaTime()
   local temp = system.getTimer()
   local dt = (temp-runtime) / (1000/60)
   runtime = temp
   return dt
end

function enterFrame()
   local dt = getDeltaTime()
   moveBg(dt)
end




return scene