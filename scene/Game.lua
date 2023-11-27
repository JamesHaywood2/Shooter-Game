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
 
physics.setDrawMode('hybrid');
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

   gameRunning = false;

   enemyTable = {}



   --Add scrolling background
   --bg display group
   local bgGroup = display.newGroup()
   sceneGroup:insert( bgGroup )
   runtime = 0
   scrollSpeed = 1.4 --1.4

   bgS1 = nil
   bgS2 = nil
   bgS3 = nil
   scrollSpeed2 = 5

   function addScrollableBg()
      --Again this just condenses the code. I think it makes it a little easier to read. - James
      local function makeBG(image, xPos)
         local bg = display.newRect(0, 0, display.contentWidth, display.actualContentHeight)
         bgGroup:insert(bg)
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

   addScrollableBg()
   Runtime:addEventListener("enterFrame", enterFrame)

   --Add player character
   ---- Main Player
   playerHP = 5;
   PC = display.newCircle (75, display.contentCenterY, 25);
   PC.tag = "player";
   physics.addBody (PC, "dynamic", {radius = 25, isSensor=true}); --I made it a sensor because collision with enemies was moving it. - James
   --If an enemy collides with the player, enemy should be removed and player should lose 1 HP.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         print("Collision with player")
         if (event.other.tag == "enemy") then
            event.other:removeSelf();
            event.other = nil;
            playerHP = playerHP - 1;
            --Play a sound when the player is hit.
         end
         --Can include other collision events here.
      end
   end
   PC.collision = onLocalCollision;
   PC:addEventListener( "collision" );
   sceneGroup:insert(PC);

   --Controller
   controlBar = display.newRect (-50, display.contentCenterY, 200, display.contentHeight);
   controlBar:setFillColor(1,1,1,0.5);
   sceneGroup:insert( controlBar )
   local function move ( event )
      if (gameRunning) then
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
      end
      return false;
   end
   controlBar:addEventListener("touch", move);

   -- Projectile 
   local cnt = 0;
   function fire (event) 
      if (gameRunning) then
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
                  --If the projectile hits an enemy, trigger the enemy's hit function.
                  if (event.other.tag == "enemy") then
                     local isDead = event.other.pp:hit();
                     if (isDead == 1) then
                        local indexOfEnemy = table.indexOf(enemyTable, event.other)
                        table.remove(enemyTable, indexOfEnemy)
                        event.other:removeSelf();
                        event.other = nil;
                     end
                  end
               end
            end
            p:addEventListener("collision", removeProjectile);
         end
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
            print("HP UP: " .. playerHP .. " -> " .. playerHP + 1)
            playerHP = playerHP + 1;
         elseif (event.keyName == "down") then
            print("HP DOWN: " .. playerHP .. " -> " .. playerHP - 1)
            playerHP = playerHP - 1;
         end
      end

      return false;
   end
   Runtime:addEventListener( "key", KeyHandler );

   --HUD
   ---Score
   ScoreText = display.newText( "Score: 0", display.contentCenterX + 200, 25, native.systemFont, 45 )
   ScoreText:setFillColor(0.03,0.7,0)
   composer.setVariable("Score", 0);
   sceneGroup:insert( ScoreText )

   --HP
   HPText = display.newText( "HP: 5", display.contentCenterX - 200, 25, native.systemFont, 45 )
   HPText:setFillColor(0.9,0.1,0.1)
   sceneGroup:insert( HPText )

   --Game Over Text
   gameOverText = display.newText( "Game Over", display.contentCenterX, display.contentCenterY, native.systemFont, 64 )
   gameOverText:setFillColor(1,0,0)
   gameOverText:toFront();
   sceneGroup:insert( gameOverText )
   gameOverText.isVisible = false;

   --Congratulations Text
   congratsText = display.newText( "CONTRATULATIONS, YOU WIN", display.contentCenterX, display.contentCenterY, native.systemFont, 64 )
   congratsText:setFillColor(0,1,0)
   congratsText:toFront();
   sceneGroup:insert( congratsText )
   congratsText.isVisible = false;

   --Add kill zones for projectiles and enemies
   --Wall off the screen to the right.
   local killZoneR = display.newRect(display.contentWidth + 150, display.contentCenterY, 100, display.contentHeight);
   killZoneR:setFillColor(1,0,0,0.5);
   physics.addBody (killZoneR, "dynamic", {isSensor=true});
   sceneGroup:insert(killZoneR);

   --Wall off the screen to the left. This is for the enemies
   local killZoneL = display.newRect(-150, display.contentCenterY, 100, display.contentHeight);
   killZoneL:setFillColor(1,0,0,0.5);
   physics.addBody (killZoneL, "dynamic", {isSensor=true});
   sceneGroup:insert(killZoneL);

   --Really just need to check for the enemies hitting the kill zone. Projectiles destroy themselves regardless.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         print("Collision with kill zone")
         if (event.other.tag == "enemy") then
            local indexOfEnemy = table.indexOf(enemyTable, event.other)
            table.remove(enemyTable, indexOfEnemy)
            event.other:removeSelf();
            event.other = nil;
         end
         --Can include other collision events here.
      end
   end
   killZoneL.collision = onLocalCollision;
   killZoneL:addEventListener( "collision" );

   composer.setVariable("bossDefeated",false);

   
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).

      --Reset the player's HP and score.
      playerHP = 5;
      composer.setVariable("Score", 0);
      composer.setVariable("bossDefeated",false);

      --GameOver text should be invisible.
      gameOverText.isVisible = false;
      congratsText.isVisible = false;
      --PC should be visible.
      PC.isVisible = true;


   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      gameRunning = true;
      --Start the updater
      Runtime:addEventListener("enterFrame", enterFrame)

      --Spawn enemies
      function spawnEnemies()
         local spawnNum = math.random(1,2)
         for i=1, spawnNum do
            local RNG = math.random();
            local enemy = nil;
            if (RNG < 0.5) then
               enemy = square:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
               enemy:spawn()
               enemy:move()
            else
               enemy = triangle:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
               enemy:spawn()
               enemy:move(PC.x, PC.y)
            end
            table.insert( enemyTable, enemy )
            sceneGroup:insert( enemy.shape )
         end

      end
      spawnTimer = timer.performWithDelay(3E3,spawnEnemies,-1) -- Spawn regular intervals, doesn't stop

      
      -- Boss will enter after two mintues of playing
      function enterBoss()
         timer.cancel(spawnTimer)
         local boss = fish:new({xPos=display.contentCenterX, yPos=display.contentCenterY})
         boss:spawn()
         boss:move()
         sceneGroup:insert(boss.shape)
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

      gameRunning = false;
      --Stop the updater
      Runtime:removeEventListener("enterFrame", enterFrame)

      --Cancel the spawn timer
      timer.cancel(spawnTimer)

      --Clear the enemy table
      for i = #enemyTable, 1, -1 do
         local enemy = enemyTable[i]
         display.remove(enemy.shape)
         enemy = nil
         table.remove(enemyTable, i)
      end


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


local function moveBg(dt)
   --This just condenses code and makes it easier to read imo - James.
   local function move(bg, scrollSpeed)
      bg.x = bg.x + -scrollSpeed * dt

      --If the background image has moved far enough to the right, move it back to the left side.
      -- if (bg.x - display.contentWidth/2.5) > display.actualContentWidth then
      --    bg:translate(-bg.contentWidth * 2.8 , 0)
      -- end

      --If background has moved far enough to the left, move it back to the right side.
      if (bg.x + 2*(display.contentWidth/2.5)) < 0 then
         bg:translate(bg.contentWidth*2.8,0);
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

--This gets called every frame. Use this as the main game loop I guess.
function enterFrame()
   
   if (gameRunning) then
      local dt = getDeltaTime()
      moveBg(dt)

      --Update the score and HP text.
      ScoreText.text = "Score: " .. composer.getVariable( "Score" )
      HPText.text = "HP: " .. playerHP

   end

   --Print enemy table size
   -- print("Enemy table size: " .. #enemyTable)

   --If the player's HP is 0, display the game over text.
   if (playerHP <= 0 and gameRunning == true) or (composer.getVariable("bossDefeated") == true) then
      if composer.getVariable("bossDefeated") == true then
         congratsText.isVisible = true;
      else 
         gameOverText.isVisible = true;

         --cancel the spawn timer
         timer.cancel(spawnTimer)
      end
      gameRunning = false;

      --Make the player disappear.
      PC.isVisible = false;
      
      --If you tap the screen in this state, it should go back to the title screen.
      --Same method should work for the boss kill.
      local function goBackToTitle(event)
         if (event.phase == "ended") then
            Runtime:removeEventListener("touch", goBackToTitle)
            composer.gotoScene("scene.Title");
            print("Going to title");
         end
      end
      Runtime:addEventListener("touch", goBackToTitle)
   end
end
 
return scene