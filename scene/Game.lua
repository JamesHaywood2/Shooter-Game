local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics")
local soundTable = require("soundTable")
local enemy = require("objects.Enemy_Base")
local square = require("objects.Enemy_1")
local triangle = require("objects.Enemy_2")
local fish = require("objects.Boss")


physics.start()
physics.setGravity(0,0);
 
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

   PC = nil

   --Add scrolling background
   local bg1
   local bg2
   local bg3
   local runtime = 0
   local scrollSpeed = 1.4 --1.4

   local bgS1
   local bgS2
   local bgS3
   local scrollSpeed2 = 5

   local function addScrollableBg()
      --Again this just condenses the code. I think it makes it a little easier to read. - James
      local function makeBG(image, xPos)
         local bg = display.newRect(0, 0, display.contentWidth, display.actualContentHeight)
         sceneGroup:insert( bg )
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

   local function moveBg(dt)
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

   local function getDeltaTime()
      local temp = system.getTimer()
      local dt = (temp-runtime) / (1000/60)
      runtime = temp
      return dt
   end

   --This gets called every frame. Use this as the main game loop I guess.
   local function enterFrame()
      local dt = getDeltaTime()
      moveBg(dt)
   end
   
   addScrollableBg()
   Runtime:addEventListener("enterFrame", enterFrame)

   --- Arena
   --I don't think top and bottom are needed. May remove them later. - James.
   local top = display.newRect(0, -20, display.contentWidth, 20);
   local left = display.newRect(-200, 0, 20, display.contentHeight);
   local right = display.newRect(display.actualContentWidth+100, 0, 20, display.contentHeight);
   local bottom = display.newRect(0, display.contentHeight, display.contentWidth, 20);
   sceneGroup:insert( top )
   sceneGroup:insert( left )
   sceneGroup:insert( right )
   sceneGroup:insert( bottom )

   top.anchorX = 0;top.anchorY = 0;
   left.anchorX = 0;left.anchorY = 0;
   right.anchorX = 0;right.anchorY = 0;
   bottom.anchorX = 0;bottom.anchorY = 0;

   physics.addBody( bottom, "dynamic", {isSensor=true} );
   physics.addBody( left, "dynamic", {isSensor=true} );
   physics.addBody( right, "dynamic", {isSensor=true} );
   physics.addBody( top, "dynamic", {isSensor=true});

   --Anything that collides with the back wall would be off the screen and should be destroyed.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         event.other:removeSelf();
         event.other = nil;
      end
   end
   left.collision = onLocalCollision;
   left:addEventListener( "collision" );

   ---Score
   ScoreText = display.newText( "Score: 0", display.contentCenterX + 200, 25, native.systemFont, 45 )
   ScoreText:setFillColor(0.03,0.7,0)
   composer.setVariable("Score", 0);
   sceneGroup:insert( ScoreText )

   --HP
   HPText = display.newText( "HP: 5", display.contentCenterX - 200, 25, native.systemFont, 45 )
   HPText:setFillColor(0.9,0.1,0.1)
   composer.setVariable( "playerHP", 5 );
   sceneGroup:insert( HPText )

   gameOverText = display.newText( "Game Over", display.contentCenterX, display.contentCenterY, native.systemFont, 64 )
   gameOverText:setFillColor(1,0,0)
   gameOverText:toFront();
   sceneGroup:insert( gameOverText )
   gameOverText.isVisible = false;

   --Controller
   controlBar = display.newRect (-50, display.contentCenterY, 200, display.contentHeight);
   controlBar:setFillColor(1,1,1,0.5);
   sceneGroup:insert( controlBar )

   ---- Main Player
   PC = display.newCircle (75, display.contentCenterY, 25);
   PC.tag = "player";
   physics.addBody (PC, "dynamic", {isSensor=true}); --I made it a sensor because collision with enemies was moving it. - James
   --If an enemy collides with the player, enemy should be removed and player should lose 1 HP.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         print("Collision with player")
         if (event.other.tag == "enemy") then
            event.other:removeSelf();
            event.other = nil;
            composer.setVariable( "playerHP", composer.getVariable( "playerHP" ) - 1 ) --I forgot if I had a good reason to do this.
            --Play a sound when the player is hit.
         end
         --Can include other collision events here.
      end
   end
   PC.collision = onLocalCollision;
   PC:addEventListener( "collision" );

   sceneGroup:insert( PC )

   local function move ( event )
      if event.phase == "began" then		
         PC.markY = PC.y 
      elseif event.phase == "moved" then	 	
         local y = (event.y - event.yStart) + PC.markY	 	
         
         if (y <= 20 + PC.height/2) then
            PC.y = 20+PC.height/2;
         elseif (y >= display.contentHeight-20-PC.height/2) then
            PC.y = display.contentHeight-20-PC.height/2;
         else
            PC.y = y;		
         end

      end
      return false;

   end
   controlBar:addEventListener("touch", move);

   -- Projectile 
   local cnt = 0;
   function fire (event) 
      if (cnt < 3) then
         cnt = cnt+1;
         local p = display.newCircle (PC.x+50, PC.y, 15);
         sceneGroup:insert( p )
         p.anchorY = 1;
         p:setFillColor(0,1,0);
         physics.addBody (p, "dynamic", {radius=5} );
         p:applyForce(2, 0, p.x, p.y);

         audio.play( soundTable["shootSound"] );

         local function removeProjectile (event)
            if (event.phase=="began") then
               event.target:removeSelf();
               event.target=nil;
               cnt = cnt - 1;

               if (event.other.tag == "enemy") then
                  event.other.pp:hit();
               end
            end
         end
         p:addEventListener("collision", removeProjectile);
      end
      return false;
   end
   Runtime:addEventListener("tap", fire)

   --I added this to make it easier to fire. - James
   function KeyHandler( event )
      if (event.phase == "down") then
         if (event.keyName == "f") then
            fire();
         elseif (event.keyName == "up") then
            composer.setVariable( "playerHP", composer.getVariable( "playerHP" ) + 1 )
         elseif (event.keyName == "down") then
            composer.setVariable( "playerHP", composer.getVariable( "playerHP" ) - 1 )
         end
      end

      return false;
   end
   Runtime:addEventListener( "key", KeyHandler );
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

      --Reset score and HP
      composer.setVariable( "Score", 0 );
      composer.setVariable( "playerHP", 5 );

      --start update loop
      Runtime:addEventListener("enterFrame", update)

      -- Spawns two enemies, type randomly chosen
      -- Clumsy implementation, could change later -- Lilli
      function spawnEnemies()
         -- Spawn first enemy
         randomNumber = math.random()
         if randomNumber < 0.5 then
            local squareEnemy = square:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
            squareEnemy:spawn()
            squareEnemy:move()
            sceneGroup:insert( squareEnemy.shape )
         else
            local polyEnemy = triangle:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
            polyEnemy:spawn()
            polyEnemy:move(PC.x, PC.y)
            sceneGroup:insert( polyEnemy.shape )
         end

         local spawnNumber = math.random(1,2)
         for i=1,spawnNumber do
            randomNumber = math.random()
            if randomNumber < 0.5 then
               local enemy = square:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
               enemy:spawn()
               enemy:move()
               sceneGroup:insert( enemy.shape )
            else
               local enemy = triangle:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
               enemy:spawn()
               enemy:move(PC.x, PC.y)
               sceneGroup:insert( enemy.shape )
            end
         end
      end
      spawnTimer = timer.performWithDelay(3E3,spawnEnemies,-1) -- Spawn regular intervals, doesn't stop

      -- Boss will enter after two mintues of playing
      function enterBoss()
         timer.cancel(spawnTimer)
         local boss = fish:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
         boss:spawn()
         boss:move()
      end
      timer.performWithDelay(120E3,enterBoss,1) -- Boss will only enter once
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

      --Stop the spawnTimer
      timer.cancel(spawnTimer)
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
      
      --Right after you leave the game screen to go back to the title screen, the game screen is destroyed.
      --This should then reset the game screen when you go back to it. - James
      composer.removeScene("scene.Game");
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.

   --Delete everything in sceneGroup
   for i=sceneGroup.numChildren,1,-1 do
      local child = sceneGroup[i]
      child.parent:remove( child )
      child = nil
   end
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------


--Game loop function
function update()
   -- --Update score
   ScoreText.text = "Score: " .. composer.getVariable( "Score" );
   -- --Update HP
   local playerHP = composer.getVariable( "playerHP" )
   HPText.text = "HP: " .. playerHP;

   --Check if the player is dead. If so, pause the game and display a game over message.
   --Pausing the game should pause the physics and set scrollSpeeds to 0.
   if (playerHP <= 0) then
      physics.pause();
      scrollSpeed = 0;
      scrollSpeed2 = 0;

      --Remove event listeners
      Runtime:removeEventListener("enterFrame", enterFrame)
      Runtime:removeEventListener("tap", fire)
      Runtime:removeEventListener("key", KeyHandler)
      
      --Display game over message
      gameOverText.isVisible = true;

      --Set PC color to red
      PC:setFillColor(1,0,0);

      --Disable the controller
      controlBar.isVisible = false;

      --If you tap the screen in this state, it should go back to the title screen.
      --Same method should work for the boss kill.
      local function goBackToTitle(event)
         if (event.phase == "ended") then
            composer.gotoScene("scene.Title");
            print("Going to title");
         end
      end
      Runtime:addEventListener("touch", goBackToTitle)
      return false;
   end
end

return scene