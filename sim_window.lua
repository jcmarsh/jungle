Window = {orig_x = 0, orig_y = 0, width = 100, height = 100, actors = {}}

function Window:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function Window:draw()
   love.graphics.push()
   love.graphics.setColor(255, 255, 255)
--   love.graphics.rectangle("line", w.orig_x, w.orig_y, w.width, w.height)
   love.graphics.translate(self.orig_x, self.orig_y)
   love.graphics.rectangle("line", 0, 0, self.width, self.height)
   
   for i = 1, #self.actors, 1 do
      self.actors[i]:draw()
   end
   love.graphics.pop()
end

function Window:update(dt)
   for i = 1, #self.actors, 1 do
      self.actors[i]:update(dt)
   end
end

-- Writing this for the mouse... anything else need it?
function Window:containsPoint(x, y)
   if x > self.orig_x and x < (self.orig_x + self.width) then
      if y > self.orig_y and y < (self.orig_y + self.height) then
	 return true
      end
   end
   return false
end

function Window:handleMouse(x, y, button)
   for i = 1, #self.actors, 1 do
      self.actors[i]:handleMouse(x, y, button)
   end
end

DetailWindow = Window:new()

function DetailWindow:draw()
   scale = 3
   love.graphics.push()
   love.graphics.setColor(255, 255, 255)
--   love.graphics.rectangle("line", w.orig_x, w.orig_y, w.width, w.height)
   love.graphics.translate(self.orig_x, self.orig_y)
   love.graphics.rectangle("line", 0, 0, self.width, self.height)
   love.graphics.pop()

   if #self.actors == 1 then
      love.graphics.push()
      love.graphics.scale(scale, scale)
      love.graphics.translate(-self.actors[1].orig_x, -self.actors[1].orig_y) -- TODO: comment below fix could remove this.
      love.graphics.translate((self.orig_x + self.width / 2) / scale, (self.orig_y + self.height / 2) / scale)
      self.actors[1]:draw() -- TODO: Need to figure out how to ignore height in translate. Maybe don't translate in this draw?
      love.graphics.pop()
   end
end

-- Delete?
function rectangle_clip(w)
   local a = w.actors[i]
   love.graphics.setColor(a.color.r, a.color.g, a.color.b)
   local new_x = a.x
   local new_y = a.y
   local new_width = a.width
   local new_height = a.height
      
   if a.x < 0 then
      new_x = 0
      new_width = a.width + a.x
   end
   if a.y < 0 then
      new_y = 0
      new_height = a.height + a.y
   end
   
   if new_x + new_width > w.width then
      new_width = new_width - (new_x + new_width - w.width)
   end
   if new_y + new_height > w.height then
      new_height = new_height - (new_y + new_height - w.height)
   end
   if new_width > 0 and new_height > 0 then
      a.draw_func("fill", w.orig_x + new_x, w.orig_y + new_y, new_width, new_height)
   end
end