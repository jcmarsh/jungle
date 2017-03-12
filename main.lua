require("sim_window")
require("console")
require("hex_tile")
require("hex_types")
require("keyboard")

version_num = 0.01
scrn_width = 1024
scrn_height = 600
-- Layout is four panes, main window on left with console in the bottom, stat and misc on right. 
-- +----------+-----+
-- |          |     |
-- |          |  3  |
-- |     1    |     |
-- |          +-----+ .... half_height
-- |          |     |
-- +----------+  4  | .... console_h_calc
-- |     2    |     |
-- +----------+-----+
--            .
--            .... third_w_calc
half_height = scrn_height / 2
third_width = math.floor(scrn_width / 3)
third_w_calc = scrn_width - third_width
console_height = 8 * 12 + 6;
console_h_calc = scrn_height - console_height;

main = 1; console = 2; detailed = 3; misc_4 = 4;
con = {}

-- other good options: (60, 52) (74, 64) (90, 78) (104, 90) (120, 104)
--hex_width = 104; hex_height = 90;
hex_width = 104; hex_height = 52;

function setDetailed(a)
   windows[detailed].actors[1] = a
end

function love.load()
   love.window.setMode(scrn_width, scrn_height, {fullscreen=false, vsync=false, fsaa=0})
   love.window.setTitle("Ver: " .. version_num) 

   windows = {}
   windows[main] = Window:new({orig_x = 0, orig_y = 0, width = third_w_calc, height = console_h_calc, actors = {}})
   windows[console] = Window:new({orig_x = 0, orig_y = console_h_calc, width = third_w_calc, height = console_height, actors = {}})
   windows[detailed] = DetailWindow:new({orig_x = third_w_calc, orig_y = 0, width = third_width, height = half_height, actors = {}})
   windows[misc_4] = Window:new({orig_x = third_w_calc, orig_y = half_height, width = third_width, height = half_height, actors = {}})

   con = Console:new({lines = {"Welcome to the Jungle!", "Alpha Ver: " .. version_num}, width = windows[console].width, height = windows[console].height})
   windows[console].actors[1] = con

   con:registerFunction("quit", love.event.quit)

   -- Make the hex map
   windows[main].actors = buildThreeLayer(windows[main].width / 2, windows[main].height / 2, hex_width, hex_height)
end

function love.draw()
   for i = 1, #windows, 1 do
      windows[i]:draw()
   end
end

function love.update(dt)
-- should update windows, yeah?
end

function love.mousepressed(mouseX, mouseY, button)
   if button == 'l' then
      for i = 1, #windows, 1 do
	 if windows[i]:containsPoint(mouseX, mouseY) then
	    con:println("Mouse clicked in window: " .. i)
	    windows[i]:handleMouse(mouseX, mouseY, button)
	    -- Who grabs keyboard? There is probably a better way
	    if i ~= console then
	       con.grab_keyboard = false
	    end
	 end
      end
   end
   if button == 'r' then

   end
end
-- Fix input to have a key typed?
space_pressed = false
w_pressed, a_pressed, s_pressed, d_pressed = false
up_pressed, left_pressed, down_pressed, right_pressed = false
function love.keypressed(key, unicode)
   if con.grab_keyboard then
      keyboard_pressed(key)
   else
      -- exit the sim
      if key == 'escape' or key == 'q' then
      love.event.quit()
      end
      if key == ' ' then
	 space_pressed = true
      end
      if key == 'w' then
	 w_pressed = true
      end
      if key == 'a' then
	 a_pressed = true
      end
      if key == 's' then
	 s_pressed = true
      end
      if key == 'd' then
	 d_pressed = true
      end
      if key == 'up' then
	 up_pressed = true
      end
      if key == 'left' then
	 left_pressed = true
      end
      if key == 'down' then
	 down_pressed = true
      end
      if key == 'right' then
	 right_pressed = true
      end
   end
end

function love.keyreleased(key, unicode)
   if con.grab_keyboard then
      con:processKey(keyboard_released(key))
   else
      if key == ' ' then
	 space_pressed = false
      end
      if key == 'w' then
	 w_pressed = false
      end
      if key == 'a' then
	 a_pressed = false
      end
      if key == 's' then
	 s_pressed = false
      end
      if key == 'd' then
	 d_pressed = false
      end
      if key == 'up' then
	 up_pressed = false
      end
      if key == 'left' then
	 left_pressed = false
      end
      if key == 'down' then
	 down_pressed = false
      end
      if key == 'right' then
	 right_pressed = false
      end
   end
end