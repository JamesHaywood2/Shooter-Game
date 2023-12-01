local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   
   --Add title text
   local titleText = display.newText( "Shooter Game", display.contentCenterX, display.contentCenterY - 100, native.systemFont, 75 )
   sceneGroup:insert( titleText )
   --Group member text
   local groupText = display.newText( "James Haywood, Lillian Snoddy, Elisabeth Elgin, Adam Pruitt ", display.contentCenterX, display.contentCenterY - 50, native.systemFont, 32 )
   sceneGroup:insert( groupText )
   --Add start button
   ButtonCounter = 0;
   local startButton = widget.newButton({
      x = display.contentCenterX,
      y = display.contentCenterY+100,
      id = "button1",
      label = "Start",
      fontSize = 64,
      shape = "roundedRect",
      width = 300,
      height = 100,
      cornerRadius = 25,
      onEvent = function(event)
         if (event.phase == "began") then 
            ButtonCounter = 1;
         elseif (event.phase == "ended") then
            if (ButtonCounter == 1) then
               composer.gotoScene("scene.Game");
            end
            ButtonCounter = 0;
         end
      end
   })
   sceneGroup:insert( startButton )
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
 
return scene