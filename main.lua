function range(x, v1, v2)
	return x > v1 and x < v2
end

function checkRow(y, num)
	for x = 0,8 do
		if grid[x][y] == num then
			return false
		end
	end
	return true
end

function checkColumn(x, num)
	for y = 0, 8 do
		if grid[x][y] == num then
			return false
		end
	end
	return true
end

function checkBox(x,y,num)
	for x = math.floor(x/3)*3, math.floor(x/3)*3+2 do
		for y = math.floor(y/3)*3, math.floor(y/3)*3+2  do
			if grid[x][y] == num then
				return false
			end
		end
	end
	return true
end

function clearBoard()
	for x = 0,8 do
		for y = 0,8 do
			grid[x][y] = 0
		end
	end
end

function solve()

	
	attempts = attempts+1
	elapsed = love.timer.getTime()
	if grid[active[1]][active[2]] == 0 then --find empty cell
		for guess = 1,9 do --attempt numbers 1-9
			if checkRow(active[2], guess) and checkColumn(active[1], guess) and checkBox(active[1],active[2],guess) then --fill cell w/ guess and stop guessing if valid
				grid[active[1]][active[2]] = guess 
				break 
			end
		end
		if grid[active[1]][active[2]] == 0 then --if no valid guess
			for recent = #blank, 1, -1 do
				local cell = grid[blank[recent][1]][blank[recent][2]]
				changed = false
				if cell < 9 and cell > 0 then --find most recently filled cell that is <9
					for change = 1, 9-cell do
						if checkRow(blank[recent][2], change+cell) and checkColumn(blank[recent][1], change+cell) and checkBox(blank[recent][1], blank[recent][2], change+cell) then
							grid[blank[recent][1]][blank[recent][2]] = cell + change
							active = {blank[recent][1], blank[recent][2]}
							changed = true
							break
						end
					end
					if changed then
						break
					else
						grid[blank[recent][1]][blank[recent][2]] = 0
					end
				else
					grid[blank[recent][1]][blank[recent][2]] = 0 --delete cell if = 9, no other guesses available, must be wrong
				end
			end
		end
	end
	if active[1] == 8 and active[2] == 8 or elapsed-start >= limit then
			solving = false
			solvinging = false
		return true --stop solving
	end
	active[1] = active[1] + 1
	if active[1] == 9 then
		active[1],active[2] = 0, active[2] + 1
	end	
	--[[
	 -find empty cell
	-attempt number 1-9, starting from 1 until valid
	-if not valid, erase all cells after the most recent cell that is less than 9
	-change cell value to +1
	--retry
	]]
end
	

function love.load() 

	blank = {}
	limit = 20
	attempts = 0
	solving = false
	process = false
	love.window.setIcon(love.image.newImageData("icon.png"))
	love.graphics.setBackgroundColor(255,255,255)
	textFont = love.graphics.newFont(18)
	numberFont = love.graphics.newFont(25)
	active = {0,0}
	grid = {}
	for x = 0,8 do
		grid[x] = {}
		for y = 0,8 do
			grid[x][y] = 0
		end
	end --2D array of board
	
	
		
end

function love.draw()

	love.graphics.setFont(numberFont)
	for x = 0,8 do
		love.graphics.setColor(100,100,100)
		if x%3 == 0 then
			love.graphics.setColor(0,0,0)
		end
		love.graphics.line(50*x, 0, 50*x, 450)
		love.graphics.line(0, 50*x, 450, 50*x)
		for y = 0,8 do
			if grid[x][y] > 0 then
				love.graphics.setColor(100,100,100)
				love.graphics.printf(grid[x][y],x*50,y*50+12.5,50,"center")
			end
		end
	end
	love.graphics.rectangle("line",0,0,450,450)	--grid
	love.graphics.setFont(textFont)
	love.graphics.printf("Mouse/arrows to select a cell.\n1-9 to input numbers into selected cell.\n'p' to toggle if solving process is displayed ("..tostring(process)..")\n'c' to clear the board or stop solving.\n'i'/'d' to increase/decrease maximum time to be spent solving ("..limit.." seconds)\n's' to solve the puzzle.\n'esc' to quit.", 0,450,450,"center")
	if solving then
		love.graphics.printf("\n\n\n\n\n\n\n\nSolving...", 0,450,450,"center")
		solvinging = true
	else
		if start and elapsed then
			if elapsed-start >= limit then
				love.graphics.printf("\n\n\n\n\n\n\n\nRequest timed out. ("..attempts.." recursions)", 0,450,450,"center")
			else
				love.graphics.printf("\n\n\n\n\n\n\n\n("..attempts.." recursions, "..math.floor(elapsed-start).." seconds elapsed)", 0,450,450,"center")
			end
		end
	end
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("line", active[1]*50, active[2]*50, 50, 50) --selected tile
	
	
end

function love.update()
	if solving and solvinging then
		if process then
			solve()
		else
			repeat solve() until solve()
			solving = false
			solvinging = false
		end
	end
end

function love.mousepressed(xmouse,ymouse)
	if not solving then
		active = {math.floor( xmouse/50 ), math.floor( ymouse/50) }
	end
end

function love.keypressed(key)
	
	if key == "c" then
		solving = false
		clearBoard()
	end

	if key == "escape" then
		os.exit()
	end
	
	if not solving then
	
		if key == "left" then
			active[1] = active[1]-1
		elseif key == "right" then
			active[1] = active[1]+1
		elseif key == "up" then
			active[2] = active[2]-1
		elseif key == "down" then
			active[2] = active[2]+1
			
	
		elseif tonumber(key) then
			grid[active[1]][active[2]] = tonumber(key)
		
		
		elseif key == "s" then
			for y = 0,8 do
				for x = 0,8 do
					if grid[x][y] == 0 then
						table.insert(blank, {x,y})
					end
				end
			end
			active = {0,0}
			attempts = 0
			start = love.timer.getTime()
			solving = true
		
		elseif key == "p" then
			if process then
				process = false
			else
				process = true
			end
			
		elseif key == "i" then
			limit = limit+5
		elseif key == "d" then
			limit = limit - 5
			if limit < 0 then
				limit = 0
			end
		end
		
	end
end