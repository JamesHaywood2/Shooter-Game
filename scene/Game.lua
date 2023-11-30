local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics")
local soundTable = require("soundTable")
local Plane = require("objects.Enemy_1")
local JetpackFish = require("objects.Enemy_2")
local fish = require("objects.Boss")


physics.start()
physics.setGravity(0,0);
 
--physics.setDrawMode('hybrid');
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here

--idk if this is exactly necessary/works the way I think it does, but I'm making every global variable local to the scene.
--What I think this means is when you leave the scene (exit scope), all the variables should be destroyed.
--idk if it already does that or it keeps it for some reason because they're global??
--It shouldn't impact anything, but if it for some reason does, just remove all of these.
--It also gets rid of warnings about global variables. - James
local spawnTimer = nil;
local bossTimer = nil;
local gameRunning = false;
local enemyTable = {}
local Boss = nil;
local bg1, bg2, bg3, bgS1, bgS2, bgS3 = nil, nil, nil, nil, nil, nil
local runtime = nil
local scrollSpeed = nil
local scrollSpeed2 = nil
local PC, controlBar, ScoreText, HPText, gameOverText, congratsText = nil, nil, nil, nil, nil, nil
local playerHP = nil
local function enterFrame() end
local function enterBoss() end
local function addScrollableBg() end

---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   gameRunning = false;

   enemyTable = {}

   --Boss object
   Boss = fish:new({xPos=display.contentCenterX, yPos=display.contentCenterY})

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

   --This is the old way of doing it. Just a circle to represent the player character.
   -- PC = display.newCircle (75, display.contentCenterY, 25);

   --This is the new way of doing it. Makes the PC a space ship.
   local shipOpt = { frames = {
         --Unscaled
         -- {x=144, y=0, width=16, height=15}, --Ship 1: White facing right
         -- {x=144, y=24, width=16, height=15}, --Ship 2: White facing left
         --Scaled
         {x=576, y=0, width=64, height=60}, --Ship 1: White facing right
         {x=576, y=96, width=64, height=60}, --Ship 2: White facing left
      }}
   local shipSheet = graphics.newImageSheet("Galaga_Ship_Scaled.png", shipOpt)
   local shipSeqData = {
      {name = "ship1", start=1, count=1, time=0, loopCount=1},
      {name = "ship2", start=2, count=1, time=0, loopCount=1}
   }
   PC = display.newSprite(shipSheet, shipSeqData)
   PC:setSequence("ship2")
   PC.x = 75;
   PC.y = display.contentCenterY;
   

   local pcCollisionFilter = { categoryBits = 1, maskBits = 12 }
   PC.tag = "player";
   physics.addBody (PC, "dynamic", {isSensor=true, filter=pcCollisionFilter}); --I made it a sensor because collision with enemies was moving it. - James
   --If an enemy collides with the player, enemy should be removed and player should lose 1 HP.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         -- print("Collision with player")
         if (event.other.tag == "enemy") then
            audio.play( soundTable["hurtSound"] );
            local indexOfEnemy = table.indexOf(enemyTable, event.other)
            table.remove(enemyTable, indexOfEnemy)
            event.other:removeSelf();
            event.other = nil;
            playerHP = playerHP - 1;
            updateHealthBar(healthBar,playerHP)
            --Play a sound when the player is hit.
         elseif (event.other.tag == "EnemyProjectile") then
            audio.play( soundTable["enemyBulletImpact"] );
            event.other:removeSelf();
            event.other = nil;
            --Only take damage if the game is running. This is to prevent the player from taking damage after the game is over.
            if (gameRunning) then
               playerHP = playerHP - 1;
               updateHealthBar(healthBar,playerHP)
            end
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
            --Gets rid of a bug where if click start, then click-hold super fast after, then move over the control bar, PC.MarkY would be nil.
            --So basically if it's nil just set it to the current y position.
            if (PC.markY == nil) then
               PC.markY = PC.y
            end
            local y = (event.y - event.yStart) + PC.markY;
            
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
   local projectileOpt = { frames = {
      {x = 225, y = 136, width = 96, height = 39},
    }}
  local projectileSheet = graphics.newImageSheet("objects/Projectiles.png", projectileOpt)
  local projectileSeq = {
      {name = "redFireball", frames = {1}},
  }

  local function createProjectile(xScale, yScale)
      xScale = xScale or 1
      yScale = yScale or 1

      local projectile = display.newSprite(projectileSheet, projectileSeq);
      projectile:setSequence("redFireball")
      sceneGroup:insert(projectile)
      local pcBulletCollisionFilter = { categoryBits = 2, maskBits = 20 }
      projectile.x, projectile.y = PC.x, PC.y

      projectile:scale(xScale, yScale)
      local projectileHitbox = {-projectile.width*xScale/2, -projectile.height*yScale/2, projectile.width*xScale/2, -projectile.height*yScale/2, projectile.width*xScale/2, projectile.height*yScale/2, -projectile.width*xScale/2, projectile.height*yScale/2}
      physics.addBody (projectile, "dynamic", {radius=15, friction=0, filter=pcBulletCollisionFilter, shape=projectileHitbox} );
      return projectile
   end

   local cnt = 0;
   local function fire (event) 
      if (gameRunning) then
         if (cnt < 3) then
            cnt = cnt+1;
            --Call the createProjectile function to create a projectile.
            local p = createProjectile(.5,.7)
            p:setLinearVelocity(800, 0);
   
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

   -- Player Health Bar
   backBar = display.newRect(display.contentCenterX-70, 25,playerHP * 25,30)
   backBar:setFillColor(1,1,1,0.5)
   backBar:setStrokeColor(1,1,1)
   backBar.strokeWidth = 2
   sceneGroup:insert(backBar)

   healthBar = display.newRect(display.contentCenterX-70, 25,playerHP * 25,30)
   healthBar:setFillColor(1,0,0,1)
   healthBar:setStrokeColor(1,1,1,0.5)
   healthBar.strokeWidth = 3
   sceneGroup:insert(healthBar)

   function updateHealthBar()
      healthBar.width = playerHP * 25
      healthBar.x = healthBar.x - 25/2
   end

   local killZoneCollisionFilter = { categoryBits = 16, maskBits = 14 }

   --Add kill zones for projectiles and enemies
   --Wall off the screen to the right.
   local killZoneR = display.newRect(display.contentWidth + 170, display.contentCenterY, 100, display.contentHeight);
   killZoneR:setFillColor(1,0,0,0.5);
   physics.addBody (killZoneR, "dynamic", {isSensor=true, filter=killZoneCollisionFilter});
   sceneGroup:insert(killZoneR);

   --Wall off the screen to the left. This is for the enemies
   local killZoneL = display.newRect(-170, display.contentCenterY, 100, display.contentHeight);
   killZoneL:setFillColor(1,0,0,0.5);
   physics.addBody (killZoneL, "dynamic", {isSensor=true, filter=killZoneCollisionFilter});
   sceneGroup:insert(killZoneL);

   --Really just need to check for the enemies hitting the kill zone. Projectiles destroy themselves regardless.
   local function onLocalCollision( self, event )
      if (event.phase == "began") then
         -- print("Collision with kill zone")
         if (event.other.tag == "enemy" or event.other.tag=="EnemyProjectile") then
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
      audio.play( soundTable["backgroundSound"], {loops = -1, fadein = 5000} );
      gameRunning = true;
      --Start the updater
      Runtime:addEventListener("enterFrame", enterFrame)

      --Spawn enemies
      local function spawnEnemies()
         local spawnNum = math.random(1,2)
         local prevY = 0
         for i=1, spawnNum do
            local RNG = math.random();
            local enemy = nil;
            --new random seed
            local xPos = display.actualContentWidth+50;
            local yPos = math.random(50, display.actualContentHeight-50);
            --If new yPosition causes enemy to spawn too close to previous enemy, generate new yPosition
            if (i > 1) then
               while (math.abs(yPos - prevY) < 50) do
                  yPos = math.random(50, display.actualContentHeight-50);
               end
            end
            if (RNG < 0.5) then
               enemy = Plane:new()
               enemy:spawn(xPos, yPos)
               enemy:move()
            else
               enemy = JetpackFish:new()
               enemy:spawn(xPos, yPos)
               enemy:move(PC.x, PC.y)
            end
            table.insert( enemyTable, enemy )
            sceneGroup:insert( enemy.shape )
            prevY = yPos
         end

      end
      spawnTimer = timer.performWithDelay(3E3,spawnEnemies,-1) -- Spawn regular intervals, doesn't stop

      
      -- Boss will enter after two mintues of playing
      function enterBoss()
         timer.cancel(spawnTimer)
         Boss:spawn()
         Boss:move()
         Boss:createHealthBar(sceneGroup)
         sceneGroup:insert(Boss.shape)
         audio.stop()
         audio.play( soundTable["bossTheme"], {loops = -1, fadein = 5000} );

         local function fireBoss()
            if (gameRunning) then
               Boss:fireProjectile(sceneGroup, PC.x, PC.y)
            end
         end
         bossTimer = timer.performWithDelay(1.75E3,fireBoss,-1) -- Boss will fire every second
      end
      bossTimer = timer.performWithDelay(120E3,enterBoss,1) -- Boss will only enter once
      --bossTimer = timer.performWithDelay(5000,enterBoss,1) -- to test boss functionality

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

      --Clear the boss
      if (Boss ~= nil) then
         display.remove(Boss.shape)
         --Stop the boss timer
         timer.cancel(bossTimer)

      end

      --Stop all audio
      audio.stop()


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

   --Remove all event listeners
   Runtime:removeEventListener("enterFrame", enterFrame)
   Runtime:removeEventListener("tap", fire)
   Runtime:removeEventListener("touch", move)
   Runtime:removeEventListener("key", KeyHandler)

   --Remove bgGroup and its children
   bg1:removeSelf()
   bg1 = nil
   bg2:removeSelf()
   bg2 = nil
   bg3:removeSelf()
   bg3 = nil
   bgS1:removeSelf()
   bgS1 = nil
   bgS2:removeSelf()
   bgS2 = nil
   bgS3:removeSelf()
   bgS3 = nil

   --Go through sceneGroup and remove all its contents
   for i = sceneGroup.numChildren, 1, -1 do
      local child = sceneGroup[i]
      child:removeSelf()
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

   local bossDefeated = composer.getVariable("bossDefeated")

   --If the player's HP is 0, display the game over text.
   if (playerHP <= 0 and gameRunning == true) or (bossDefeated) then
      if bossDefeated == true then
         congratsText.isVisible = true;
      else 
         gameOverText.isVisible = true;
         display.remove(Boss.shape)

         --cancel the spawn timer
         timer.cancel(spawnTimer)
         --Cancel the boss timer
         timer.cancel(bossTimer)
         Boss:removeHealthBar()

         --Delete the player.
         PC:removeSelf();
         PC = nil;
         --Delete the control bar.
         controlBar:removeSelf(sceneGroup);
         controlBar = nil;
      end
      gameRunning = false;


      --Originally upon a game over/win the player would just be made invisible, but not be deleted. You would then go back to the title screen.
      --Upon starting again, the player would be made visible again. Nothing ever really god deleted, just reset.
      --NOW, the scene should be getting deleted, so the player can be deleted too.

      --Make the player disappear.
      -- PC.isVisible = false;


      
      --If you tap the screen in this state, it should go back to the title screen.
      --Same method should work for the boss kill.
      local function goBackToTitle(event)
         if (event.phase == "began") then
            Runtime:removeEventListener("touch", goBackToTitle)
            composer.gotoScene("scene.Title");
            print("Going to title");
            --Destroy the game scene.
            composer.removeScene("scene.Game");
            return true;
         end
      end
      Runtime:addEventListener("touch", goBackToTitle)
   end
end
 
return scene