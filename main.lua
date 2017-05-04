-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

display.setStatusBar(display.HiddenStatusBar);

screen_width = display.contentWidth;
screen_height = display.contentHeight;

-- Level Text
level = 1;
level_string = "Level " .. tostring(level)
level_text = display.newText(level_string,screen_width/2,30);

-- Question Text
question = "What day is it?";
display.newText(question,screen_width/2,70);

-- Wrong Answer
times_wrong = 0;

spacing = 40
for i=0,2 do
  failed_text = display.newText("X", screen_width/2 - 40 + (40 * i), screen_height-20);
end

-- Make Objects for each X and set isVisible
-- failed_text.isVisible = false;

-- Remove Text
