
EmptySpace = {orig_x = 0, orig_y = 0, radius = 1, revealed = false, color = {r = 255, g = 255, b = 0}}

function EmptySpace:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function EmptySpace:draw()
   love.graphics.push()
   love.graphics.setColor(self.color.r, self.color.g, self.color.b)
   
   love.graphics.circle("fill", 0, 0, self.radius)

   love.graphics.pop()
end

