--[[ 
*Edited to accommodate touch screen.
Left half of screen for left paddle. 
Right half of screen tracks right paddle.
]]

--[[
    CS50 2D
    Pong Remake

    pong-3
    "The Paddle Update"

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

-- ***new addition for touch screen
local touches = {}

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)

    -- larger font for drawing the score on the screen
    scoreFont = love.graphics.newFont('font.ttf', 32)

    -- set LÖVE2D's active font to the smallFont obect
    love.graphics.setFont(smallFont)

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        fullscreen = false,
        vsync = true, 
        display = 1
    })

    -- initialize window with virtual resolution
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    -- paddle positions on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50
end

-- ***added this section for touch control
function love.touchpressed(id, x, y, dx, dy, pressure)
  touches[id] = {x = x, y = y}
end

function love.touchmoved(id, x, y, dx, dy, pressure)
  if touches[id] then
    touches[id].x = x
    touches[id].y = y
  end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  touches[id] = nil
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    -- touch-based paddle movement
for id, touch in pairs(touches) do
  -- convert screen touch coordinates to virtual coordinates
  local virtualX = touch.x * (VIRTUAL_WIDTH / love.graphics.getWidth())
  local virtualY = touch.y * (VIRTUAL_HEIGHT / love.graphics.getHeight())
  
  if virtualX < VIRTUAL_WIDTH / 2 then
    -- left side = player 1
    player1Y = virtualY - 10  -- 10 is half paddle height, centers it
    -- clamp to screen
    if player1Y < 0 then player1Y = 0 end
    if player1Y > VIRTUAL_HEIGHT - 20 then player1Y = VIRTUAL_HEIGHT - 20 end
  else
    -- right side = player 2
    player2Y = virtualY - 10
    if player2Y < 0 then player2Y = 0 end
    if player2Y > VIRTUAL_HEIGHT - 20 then player2Y = VIRTUAL_HEIGHT - 20 end
  end
end
end

--[[
    Keyboard handling, called by LÖVE2D each frame;
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen,
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push.start()

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw welcome text toward the top of the screen
    love.graphics.setFont(smallFont)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

    -- render first paddle (left side), now using the players' Y variable
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- end rendering at virtual resolution
    push.finish()
end
