


--The variable 'fish' contains every display object that makes up the fish

--Sprite frames
local fishOpt =
{
    frames = {
        {x=22, y=8, width=167, height=50}, --Fish body -1
        {x=207, y=27, width=16, height=9}, --Snout a -2
        {x=228, y=27, width=16, height=9}, --Snout b -3
        {x=249, y=27, width=16, height=9}, --Snout c-4
        {x=281, y=20, width=56, height=26}, -- mouth a-5
        {x=344, y=20, width=56, height=26}, -- mouth b-6
        {x=407, y=20, width=56, height=26}, -- mouth c-7
        {x=22, y=93, width=54, height=37}, -- P fin a-8
        {x=80, y=99, width=54, height=37}, -- P fin b-9
        {x=140, y=102, width=54, height=37}, -- P fin c-10
        {x=211, y=70, width=47, height=92}, -- caudial fin a-11
        {x=267, y=70, width=55, height=92}, -- caudial fin b-12
        {x=331, y=70, width=60, height=92}, -- caudial fin c-13
        {x=405, y=93, width=60, height=46}, -- dorsal fin-14
    }
}
--Image sheet for fish
local fishSheet = graphics.newImageSheet("KingBayonet.png",fishOpt)


--Create fish group
local fish = display.newGroup()
--Join all the fish parts together
local fishBody = display.newImage(fish, fishSheet, 1)

--Set the x and y of the fish parts
fish.anchorChildren = true
fish.AnchorX, fish.AnchorY = 0.5, 0.5
fish.x = display.contentCenterX --Fish starts in the middle of the screen
fish.y = display.contentCenterY
fish.xScale = 1
fish.yScale = 1

--Add the mouth
local mouth = display.newSprite(fish, fishSheet, fishSeqData)
mouth:setSequence("mouthOn")
mouth:toBack()
mouth.anchorX, mouth.anchorY = 1, 0 --Set the anchor point to the top right corner of the mouth
mouth.x, mouth.y = -11, -6.5 --Move the mouth
mouth.xScale, mouth.yScale = 1.032, 1.042 --The mouth didn't fit on the fish's body perfectly so I stretched it a super small ammount to make it fit.

--Add the caudal fin
local cFin = display.newSprite(fish, fishSheet, fishSeqData)
cFin:setSequence("cFinOn")
cFin.anchorX, cFin.anchorY = 0, 0.5
cFin.x, cFin.y = 76, -3

--Add the pectoral fin
local pFin = display.newSprite(fish, fishSheet, fishSeqData)
pFin:setSequence("pFinOn")
pFin:toBack()
pFin.anchorX, pFin.anchorY = 0, 0 --Anchor point is the top left corner of the fin
pFin.x, pFin.y = 0, 11

--Add the snout
local snout = display.newSprite(fish, fishSheet, fishSeqData)
snout:setSequence("snoutOn")
snout.anchorX, snout.anchorY = 1, 0 --Anchor point is the top right corner of the snout
snout.x, snout.y = -83, -1.0

--Add the dorsal fin
local dFin = display.newSprite(fish, fishSheet, fishSeqData)
dFin:setSequence("dFinOn")
dFin:toBack()
dFin.anchorX, dFin.anchorY = 0,1 --Anchor point is the bottom left corner of the fin
dFin.x, dFin.y = -15.5, -15.5





return fish;
