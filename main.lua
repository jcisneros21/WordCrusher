-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- imports
local mymodule = require "MainMenu";
local physics = require("physics");
local json = require("json");
local math = require("math");
physics.start()
physics.setGravity(0,0)

display.setStatusBar(display.HiddenStatusBar);
local background = display.newImage("images/background.jpg",250,160.5);

screen_width = display.contentWidth;
screen_height = display.contentHeight;

-- Create the Main Menu
menu = MainMenu:new(nil)
menu:start(screen_width/2,100);
 
-- text list
local answer_textList = {}

-- answer
local real_answer = nil

-- current level user is on
local level = 1
local level_text = nil

-- question
local question = nil

-- velocity
local x_velocity = -100

-- Text for the timer
local time_text = nil

-- start time for countdown timer
local startTime = 5

-- failed timer
local failed_timer = nil
local failed_text = nil

-- text list for failed tries
local failed_attempts = {}


-- timer for failed level
function levelFailed()
  failed_text = display.newText("Failed Level", screen_width/2, screen_height/2)
end


-- Function to start game
function startGame()
  level_string = "Level " .. tostring(level)
  level_text = display.newText(level_string,screen_width/2,30);

  -- Question Text
  question = "What day is it?";
  display.newText(question,screen_width/2,60);

  -- Wrong Answer
  times_wrong = 0;

  spacing = 40;

  for i=0,2 do
    failed_attempts[i] = display.newText("X", screen_width/2 - 40 + (40 * i), screen_height-20);
    failed_attempts[i].isVisible = false;
    failed_attempts[i]:setTextColor(1,0,0);
  end

  for i=0,times_wrong-1 do
    failed_attempts[i].isVisible = true;
  end

  startTimer()
end

-- Returns a question
function getQuestion()
	local path = system.pathForFile("levels.json")
	local contents = ""
	local myTable = {}
	local file = io.open( path, "r" )
	if file then
		local contents = file:read("*a")
		myTable = json.decode(contents);
		io.close( file )
		tableSize = 0
		for k, v in pairs( myTable ) do
			tableSize = tableSize + 1
		end
		randNumber = math.random(tableSize)
		counter = 1
		returnTable = {}
		for k, v in pairs (myTable) do
			if counter == randNumber then
			  table.insert(returnTable, k)
			  table.insert(returnTable, v)
			  print(k)
			  print(v)
			  return returnTable
			else
			  counter = counter + 1
			end
		end
		return nil
	end
end

-- onclicklister for background
function clickBackground(event)
  if( event.phase == "began") then
    background:removeEventListener("touch", clickBackground)
    menu:remove()
    startGame()
  end
  return true
end

-- timer for level to start
function countdown(event)
  startTime = startTime - 1
  if(startTime == 0) then
    display.remove(time_text)
    print("In countdown")
    loadAnswers()
  end
  time_text.text = tostring(startTime)
end

-- Load Answers for Game
function loadAnswers()
  -- starting coordinates for answers
  random_x = {screen_width + 40, screen_width + 100, screen_width + 160}
  random_y = {screen_height/2 - 40, screen_height/2 + 20, screen_height/2 + 80}


  -- trivia_table = getQuestion()

  -- answer list
  answers = {"example", "here", "me", "wednesday", "white", "420"}

  -- set real answer
  real_answer = "wednesday"

  times = 0;
  for i=1,table.getn(answers) do
    if(i % 3 == 0) then
      times = times + 1;
    end

    y_coordinate = random_y[(i % 3) + 1];
    x_coordinate = random_x[math.random(1,3)];

    answer_textList[i] = display.newText(answers[i],x_coordinate + (times*140), y_coordinate);
    answer_textList[i].id = answers[i];
    physics.addBody(answer_textList[i], "dynamic")
    answer_textList[i]:setLinearVelocity(x_velocity)
    answer_textList[i]:addEventListener("touch", pickAnswer)
    print(answers[i])

  end

  -- timer to end level if user misses the words
  failed_timer = timer.performWithDelay(10000, levelFailed)
end


-- Event Listener for Answers
function pickAnswer(event)
  index = 1;
  for i=1, table.getn(answer_textList) do
    if( answer_textList[i].id == event.target.id) then
      index = i;
      break;
    end
  end

  display.remove(answer_textList[index])
  table.remove(answer_textList, index)

  if(event.target.id == real_answer) then
    nextLevel()
  else
    times_wrong = times_wrong + 1
    displayFails()
  end
end


-- Function to go to next level
function nextLevel()
  timer.cancel(failed_timer)

  for i=1, table.getn(answer_textList) do
    display.remove(answer_textList[1])
    table.remove(answer_textList, 1)
  end
  answer = nil

  x_velocity = x_velocity - 15
  level = level + 1
  level_text.text = "Level " .. tostring(level);
  startTimer()
end

function startTimer()
  startTime = 5
  time_text = display.newText(tostring(startTime), screen_width/2, screen_height/2)
  timer.performWithDelay(1000, countdown, startTime)
end

function displayFails()
  for i=0,times_wrong-1 do
    failed_attempts[i].isVisible = true;
  end

  if(times_wrong == 3) then
    for i=1, table.getn(answer_textList) do
      display.remove(answer_textList[1])
      table.remove(answer_textList, 1)
    end
    levelFailed()
  end
end

-- make restart Game Button
-- make start Game Button

background:addEventListener("touch", clickBackground)
