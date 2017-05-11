-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- imports
local mymodule = require "MainMenu";
local physics = require("physics");
local widget = require("widget");
local math = require("math");
local json = require("json");

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

local question_text = nil;

local failed_timer_time = 10000

local answers = nil

-- Function to handle button events
local function handleButtonEvent( event )
  if( event.phase == "began") then
    menu:remove()
    startGame(1)
  end
end

-- Create Start Button
local start_button = widget.newButton(
    {
        id = "start_button",
        label = "Start Game",
        onEvent = handleButtonEvent,
        shape = "roundedRect",
        width = 200,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4
    }
)

start_button.x = screen_width/2;
start_button.y = screen_height-120;

local restart_button = nil;
local failed_text = nil;

-- timer for failed level
function levelFailed()
  failed_text = display.newText("Failed Level", screen_width/2, screen_height/2)

  -- Function to handle button events
  local function restartButtonEvent( event )
    if( event.phase == "began") then
      startGame(2)
    end
  end

  -- Create Start Button
  restart_button = widget.newButton(
      {
          id = "restart_button",
          label = "Try Again?",
          onEvent = restartButtonEvent,
          shape = "roundedRect",
          width = 200,
          height = 40,
          cornerRadius = 2,
          fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
          strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
          strokeWidth = 4
      }
  )

  restart_button.x = screen_width/2;
  restart_button.y = screen_height-100;
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
			  return returnTable
			else
			  counter = counter + 1
			end
		end
		return nil
	end
end

-- Function to start game
function startGame(type_button)
  if(type_button == 1) then
    display.remove(start_button);
  else
    display.remove(restart_button);
    display.remove(failed_text);
    display.remove(level_text);
    display.remove(question_text);
    failed_timer_time = 10000;
    level = 1;
    x_velocity = -100;
    for i=0,table.getn(failed_attempts) do
      failed_attempts[i].isVisible = false;
    end
  end

  level_string = "Level " .. tostring(level);
  level_text = display.newText(level_string,screen_width/2,30);

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

  trivia_table = getQuestion()
  question = trivia_table[1]
  answers = trivia_table[2]

  -- Question Text
  question_text = display.newText(question,screen_width/2,60);

  -- starting coordinates for answers
  random_x = {screen_width + 40, screen_width + 100, screen_width + 160}
  random_y = {screen_height/2 - 40, screen_height/2 + 20, screen_height/2 + 80}

  -- answer list
  real_answer = answers[1]
  randAnswerList()

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
  failed_timer = timer.performWithDelay(failed_timer_time, levelFailed)
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
  display.remove(question_text)
  timer.cancel(failed_timer)
  failed_timer_time = failed_timer_time - 50;

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
    timer.cancel(failed_timer)
    levelFailed()
  end
end

function randAnswerList()
  length = table.getn(answers) - 1;
  random_list = {}
  print("Going in Bro")
  for i=0,length do
    index = math.random(1,table.getn(answers))
    print(answers[index])
    table.insert(random_list, answers[index])
    table.remove(answers,index)
  end
  answers = random_list;
end

-- make restart Game Button
-- make start Game Button
