Hex = {orig_x = 0, orig_y = 0, width = 104, height = 90,
       terrain_height = 0, terrain_scalar = 20, neighbor_heights = {SW_h = 0, S_h = 0, SE_h = 0},
       index = 0, color = {r = 220, g = 0, b = 0}, 
       center = {r = 255, g = 255, b = 0}, revealed = false, hex_type = {}}

function Hex:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function Hex:init()
   extra = (self.width / 4)
   NW = {x = extra, y = 0}
   NE = {x = self.width - extra, y = 0}
   E = {x = self.width, y = self.height / 2}
   SE = {x = self.width - extra, y = self.height}
   SW = {x = extra, y = self.height}
   W = {x = 0, y = self.height / 2}
   C = {x = self.width / 2, y = self.height / 2}
end

function Hex:draw()
   love.graphics.push()
   love.graphics.setColor(self.color.r, self.color.g, self.color.b)
   t_h = self.terrain_height * self.terrain_scalar
   love.graphics.translate(self.orig_x - self.width / 2, self.orig_y - self.height / 2 - t_h)
   --love.graphics.rectangle("line", 0, 0, self.width, self.height)
   --love.graphics.print(self.index, self.width / 2, self.height / 2)

   --  extra = (width / 4)
   --   ___
   --  /   \ ___ height / 2
   --  \___/ ___ height
   --  |   |
   --  |   +-- width - extra
   --  +-- extra
   --
   -- Points start with upper left (north west), go clockwise.


   -- Need to add in terrain height
   --
   --   ___
   --  /   \
   -- |\___/|
   -- \|___|/
   --
   love.graphics.line(NW.x, NW.y, NE.x, NE.y)
   love.graphics.line(NE.x, NE.y, E.x, E.y)
   love.graphics.line(E.x, E.y, SE.x, SE.y)
   love.graphics.line(SE.x, SE.y, SW.x, SW.y)
   love.graphics.line(SW.x, SW.y, W.x, W.y) 
   love.graphics.line(W.x, W.y, NW.x, NW.y)

   -- These need to be scaled by neighbor's terrain height.
   love.graphics.line(W.x, W.y, W.x, W.y + (t_h - self.neighbor_heights.SW_h * self.terrain_scalar))
   love.graphics.line(SW.x, SW.y, SW.x, SW.y + (t_h - self.neighbor_heights.S_h * self.terrain_scalar))
   love.graphics.line(SE.x, SE.y, SE.x, SE.y + (t_h - self.neighbor_heights.S_h * self.terrain_scalar))
   love.graphics.line(E.x, E.y, E.x, E.y + (t_h - self.neighbor_heights.SE_h * self.terrain_scalar))


   love.graphics.pop()
end

function Hex:containsPoint(x, y)
   -- TODO: update to deal with terrain heights?
   shift_x_diff = math.abs(x - self.orig_x)
   shift_y_diff = math.abs(y - self.orig_y)
   extra = (self.width / 4)

   -- East and SouthEast corners of the hex
   E = {x = self.width, y = self.height / 2}
   SE = {x = self.width - extra, y = self.height}

   -- Use SE, E and new Mouse
   mouse = {x = shift_x_diff + self.width / 2, y = shift_y_diff + self.height / 2}
   m = (SE.y - E.y) / (SE.x - E.x)
   b = E.y - m * E.x
   y_hex = m * mouse.x + b

   -- Ya know... I'm not actually sure how this works anymore.
   if (mouse.y < y_hex and shift_y_diff < (self.height / 2)) then
      -- click is under the line (representing edge of hex)
      -- Point is radial... or reflected... due to symmetry only need to check one point / line
      return true
   end
   return false
end

function Hex:handleMouse(x, y, button)
   if self:containsPoint(x, y) then
      setDetailed(self)
      self.revealed = true
      self.color = {r = 0, g = 30, b = 220}
   else 
      self.color = {r = 220, g = 0, b = 0}
   end
end

function makeHex(o_x, o_y, w, h, t_h)
   hex = Hex:new({orig_x = o_x, orig_y = o_y, width = w, height = h, terrain_height = t_h, neighbor_heights = {SW_h = 0, S_h = 0, SE_h = 0}, hex_type = EmptySpace:new()})
   hex:init()
   return hex
end

function buildThreeLayer(center_x, center_y, width, height)
   map = {}
   x_step = 3 * width / 4
   y_step = height / 2
   hex_index = 1
   -- core
   map[hex_index] = makeHex(center_x, center_y, width, height, 0)
   hex_index = hex_index + 1
   -- layer 1
   map[hex_index] = makeHex(center_x, center_y - height, width, height, 1) -- index 2
   map[hex_index].neighbor_heights.SW_h = 1
   map[hex_index].neighbor_heights.S_h = 0
   map[hex_index].neighbor_heights.SE_h = 0
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + x_step, center_y - y_step, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + x_step, center_y + y_step, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x, center_y + hex_height, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - x_step, center_y + y_step, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - x_step, center_y - y_step, width, height, 1)
   hex_index = hex_index + 1
   -- layer 2
   -- layer 2, North
   map[hex_index] = makeHex(center_x, center_y - (height * 2), width, height, 3) -- index 8
   map[hex_index].neighbor_heights.SW_h = 2
   map[hex_index].neighbor_heights.S_h = 1
   map[hex_index].neighbor_heights.SE_h = 2
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + x_step, center_y - (height * 2 - y_step), width, height, 2)
   map[hex_index].neighbor_heights.SW_h = 1
   map[hex_index].neighbor_heights.S_h = 0
   map[hex_index].neighbor_heights.SE_h = 1
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + 2 * x_step, center_y - (height), width, height, 1)
   map[hex_index].neighbor_heights.SW_h = 0
   map[hex_index].neighbor_heights.S_h = 0
   map[hex_index].neighbor_heights.SE_h = 1
   hex_index = hex_index + 1
   -- layer 2, East
   map[hex_index] = makeHex(center_x + 2 * x_step, center_y, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + 2 * x_step, center_y + (height), width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x + x_step, center_y + (height * 2 - y_step), width, height, 0)
   hex_index = hex_index + 1
   -- layer 2, South
   map[hex_index] = makeHex(center_x, center_y + (height * 2), width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - x_step, center_y + (height * 2 - y_step), width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - 2 * x_step, center_y + (height), width, height, 0)
   hex_index = hex_index + 1
   -- layer 2, West
   map[hex_index] = makeHex(center_x - 2 * x_step, center_y, width, height, 0)
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - 2 * x_step, center_y - (height), width, height, 1) -- index 18
   map[hex_index].neighbor_heights.SW_h = 1
   map[hex_index].neighbor_heights.S_h = 0
   map[hex_index].neighbor_heights.SE_h = 1
   hex_index = hex_index + 1
   map[hex_index] = makeHex(center_x - x_step, center_y - (height * 2 - y_step), width, height, 2)
   map[hex_index].neighbor_heights.SW_h = 1
   map[hex_index].neighbor_heights.S_h = 1
   map[hex_index].neighbor_heights.SE_h = 1
   hex_index = hex_index + 1   
   
   for i = 1, #map, 1 do
      map[i].index = i
   end

   return map
end

function buildFourLayer(center_x, center_y, width, height)
   map = buildThreeLayer(center_x, center_y, width, height)
   x_step = 3 * width / 4
   y_step = height / 2
   hex_index = #map + 1

   -- North
   for i = 0, 3, 1 do
      map[hex_index] = makeHex(center_x + i * x_step, center_y - height * 3 + i * y_step, width, height)
      hex_index = hex_index + 1
   end

   -- North East
   for i = 1, 3, 1 do -- 1 so that we skip the last made from North
      map[hex_index] = makeHex(center_x + 3 * x_step, center_y - height * (3 - i) + 3 * y_step, width, height)
      hex_index = hex_index + 1
   end

   -- South East
   for i = 1, 3, 1 do
      map[hex_index] = makeHex(center_x + (3 - i) * x_step, center_y + (3 + i) * y_step, width, height)
      hex_index = hex_index + 1
   end

   -- South
   for i = 1, 3, 1 do
      map[hex_index] = makeHex(center_x - i * x_step, center_y + height * 3 - i * y_step, width, height)
      hex_index = hex_index + 1
   end

   -- South West
   for i = 1, 3, 1 do
      map[hex_index] = makeHex(center_x - 3 * x_step, center_y - height * i + 3 * y_step, width, height)
      hex_index = hex_index + 1
   end

   for i = 1, 2, 1 do -- The first and the last have already been done
      map[hex_index] = makeHex(center_x - (3 - i) * x_step, center_y - (3 + i) * y_step, width, height)
      hex_index = hex_index + 1
   end

   for i = 1, #map, 1 do
      map[i].index = i
   end
   return map
end