-- Meta class

MainMenu = {};

-- method new

function MainMenu:new (o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self
  self.title = nil
  self.click = nil
  return o
end

-- Start the Main Menu

function MainMenu:start(x,y)
  self.title = display.newText("WordCrusher",x,y);
  self.title.size = 60;
end

-- Remove the Main menu

function MainMenu:remove()
  display.remove(self.title);
end
