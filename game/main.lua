require "collision"
require "ball"

function love.load()
	math.randomseed(os.time())

	-- Is game over?
	gameover = false

	-- Difficulty rating (0 to 1) DIFFICULTY GOES UP EXPONENTIALLY!
	-- Increase means increase in speed
	difficulty = 0.04
	difficultyIncrease = 0.5

	-- Cave Height to control bouncing
	cave = {}

	cave.top = 100
	cave.bottom = love.graphics.getHeight() - 150
	cave.left = 50

	-- Added new score
	score = 0

	balls = {}

	fonts = {}
	fonts.score = love.graphics.newFont("assets/Gamer.ttf",36)
	fonts.gameover = love.graphics.newFont("assets/Gamer.ttf", 250)

	images = {}
	images.background = love.graphics.newImage("assets/ground.png")
	images.ball = love.graphics.newImage("assets/coin.png")
	images.player = love.graphics.newImage("assets/player_down.png")
	
	player = {}	
	player.x = 50
	player.y = 210
	player.w = images.player:getWidth()
	player.h = images.player:getHeight()
	player.jump = images.player:getHeight()

	-- Each ball's Initial properties - init_ball
	init_ball = {}
	init_ball.width = images.ball:getWidth()
	init_ball.height = images.ball:getWidth()
	init_ball.speed = 5
end



function love.update(dt)

	if gameover == true then
		return
	end

	if math.random() < difficulty then
		createBall()
	end
	
	
	-- Iterate through balls
	for i=#balls, 1, -1 do
		local ball = balls[i]

		if AABB(player.x, player.y, player.w, player.h, ball.x , ball.y , init_ball.width , init_ball.height) then
			-- Player has collided, dead.
			gameover = true
			return
		end

		if ball.x < cave.left then
			-- ball has ended
			table.remove(balls, i)
			score = score + 1
		else
			
			-- MODIFY BALL SPEED HERE --
			if ball.y < cave.top or ball.y > cave.bottom - images.ball:getHeight() then
				-- If collision, change y speed by reversing
				ball.sy = 0 - ball.sy

				init_ball.speed = init_ball.speed + difficultyIncrease
			end
			-- END MODIFY BALL SPEED HERE

			-- Move ball
			ball.x = ball.x + ball.sx
			ball.y = ball.y + ball.sy
		end
	end

end

function love.draw()

	-- Background
	for x = 0, love.graphics.getWidth(), images.background:getWidth() do
		for y = cave.top, cave.bottom - images.background:getHeight(), images.background:getHeight() do
			love.graphics.draw(images.background, x,y)
		end
	end
	
	-- Player
	love.graphics.draw(images.player, player.x,player.y)
	
	-- Balls
	for i=1, #balls, 1 do
		local ball = balls[i]
		love.graphics.draw(images.ball, ball.x, ball.y)
	end
	
	love.graphics.setFont(fonts.score)
	love.graphics.print("Score: " .. score, 10, 10)
	--love.graphics.print(#balls, 20, 10)
	if gameover then
		love.graphics.setFont(fonts.gameover)
		love.graphics.print("gameover", 10, 200)
	end


end

function love.keypressed(key)

	-- Add an 'anti-sticking' measure to prevent players sticking to the top or bottom
	antiStick = 30

	if key == "up" then
		if player.y > cave.top + antiStick then
			player.y = player.y - player.jump
		end
	elseif key == "down" then
		if player.y < cave.bottom - images.ball:getHeight() - antiStick then
			player.y = player.y + player.jump
		end
	end

end