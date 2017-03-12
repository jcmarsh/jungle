Console = {displayed = {}, console = "> ", typed = "", functions = {}, width = 100, height = 100, line_height = 12, margin = 3, grab_keyboard = true}

function Console:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self:registerFunction("help", self.help)
   self:registerFunction("set", self.set)
   self:registerFunction("printT", self.printT)
   return o
end

function Console:draw()
   love.graphics.push()
   love.graphics.setColor(200, 200, 200)

   for i = 1, #self.lines, 1 do
      love.graphics.print(self.lines[i], self.margin, i * self.line_height)
   end

   love.graphics.pop()
end

function Console:handleMouse(x, y, button)
   self.grab_keyboard = true
end

function Console:println(line)
   -- Need to truncate lines ... maybe
   num_lines = math.floor((self.height - (2 * self.margin)) / self.line_height) - 1 - 1
   if num_lines > #self.lines then -- Add line to the bottom
      if self.lines[#self.lines] == (self.console .. self.typed) then
	 self.lines[#self.lines] = line
      else
	 self.lines[#self.lines + 1] = line
      end
      self.lines[#self.lines + 1] = self.console .. self.typed
   else                            -- Console full; shift everything up
      for i = 1, #self.lines - 2, 1 do
	 self.lines[i] = self.lines[i + 1]
      end
      self.lines[#self.lines - 1] = line
      self.lines[#self.lines] = self.console .. self.typed
   end
end

function Console:processKey(key)
   if key == nil then
      return
   end
   if key ~= "return" then
      if key == "backspace" then
	 self.typed = string.sub(self.typed, 1, -2)
      else
	 self.typed = self.typed .. key
      end
   else
      -- Process command
      self:println(self.console .. self.typed)
      cmd, args = self:parseCmd(self.typed)
      if cmd == nil then
	 -- blank line
	 -- Do nothing
      elseif self.functions[cmd] == nil then
	 self:println("No such function: " .. cmd)
      else
	 self.functions[cmd](self, args)
      end
      self.typed = ""      
   end
   self.lines[#self.lines] = self.console .. self.typed
end

function Console:registerFunction(name, func)
   self.functions[name] = func
end

function Console:help()
   self:println("This is a \"helpful\" help message")
end

function Console:parseCmd(line)
   cmd = nil
   args = {}
   for w in line:gmatch("[a-zA-Z0-9_]+") do
      if cmd == nil then
	 cmd = w
      else
	 args[#args + 1] = w
      end
   end

   return cmd, args
end

function Console:set(args)
   -- TODO: can top level values be set?
   local table = _G
   prev = nil

   for i = 1, #args - 1, 1 do
      prev = table
      table = Console.stepTable(table, args[i])
      print("Pabs", table, args[i])
   end

   prev[args[#args-1]] = tonumber(args[#args])
end

function Console:printT(args)
   local table = _G

   if #args < 1 then
      Console.printTable(table)
   end

   for i = 1, #args, 1 do
      table = Console.stepTable(table, args[i])
      Console.printTable(table)
   end
end

function Console.stepTable(start, arg)
   local table = start

   if tonumber(arg) == nil then -- arg is a string
      table = table[arg]
   else
      table = table[tonumber(arg)] -- convert to number
   end

   return table
end

function Console.printTable(table)
   print(table)
   if type(table) == "table" then
      for k, v in pairs(table) do
	 print("\t", k, "\t", v)
      end
   else
      print("\tValue", table)
   end
end