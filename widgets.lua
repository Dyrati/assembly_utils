-- exports

    mainloop = {
        init = function(self)
            local frameadvance = emu.frameadvance
            emu.frameadvance = function()
                for i,f in ipairs(mainloop) do f() end
                frameadvance()
            end
            vba.frameadvance = emu.frameadvance
        end,
        push = function(self,f) table.insert(self,f) end,
        pop = function(self) table.remove(self) end,
    }
    mainloop:init()

    inputs = {
        keys={}, keydown={}, keyup={}, mouse={}, mousedown={},
        static={xmouse=true, ymouse=true, capslock=true, scrolllock=true, numlock=true},
        init = function(self)
            setmetatable(self, {__index=self.keys})
        end,
        update = function(self)
            self.keydown = {}
            self.keyup = {}
            local keys = input.get()
            for k, v in pairs(keys) do
                if not self.keys[k] then self.keydown[k] = true end
                self.keys[k] = self.static[k] and v or (self.keys[k] or 0) + 1
            end
            if self.keydown.leftclick then
                self.mousedown[1], self.mousedown[2] = unpack(self.mouse)
            end
            for k, v in pairs(self.keys) do
                if not keys[k] then
                    if self.keys[k] then self.keyup[k] = true end
                    self.keys[k] = nil
                end
            end
            self.mouse[1], self.mouse[2] = keys.xmouse, keys.ymouse
        end,
    }
    inputs:init()
    mainloop:push(function() inputs:update() end)

    clipboard = {
        filename = "widgets_clipboard.txt",
        copy = function(self,text)
            local f = io.open(self.filename, "w")
            f:write(text); f:flush(); f:close()
        end,
        paste = function(self)
            local f = io.open(self.filename, "r")
            local txt = f:read("*a")
            f:close()
            return txt
        end,
        open = function(self)
            os.execute("start "..self.filename)
        end,
    }

    widgets = setmetatable({x=0,y=0,w=240,h=120,enabled=true}, {__index=_G, entries={}})

--

module("widgets")

-- constants

    local help_text = [[
        Example test script (creates a UI with a button at {2,2}):
            ------------------------------------------------------------------------
            require "widgets"

            button = widgets.Button{x=2, y=2}

            while true do
                if button.clicked then print("you clicked the button, good job") end
                emu.frameadvance()
            end
            ------------------------------------------------------------------------

        You can create new widgets (outside the main loop) like so: "w = widgets.Window{}"
        After creation, the widget will automatically be updated within emu.frameadvance().
        And that's all you need to make a fancy UI!
        
        Every widget has a "box" with collision properties updated each frame
        
        Collision properties:
            x - x-coordinate
            y - y-coordinate
            w - width
            h - height
            hover: whether cursor is within widget's box
            active: depends on active_mode:
              - pressed (default): active on click within box;
                  remains active until click is released (regardless of cursor location)
              - toggle: alternates true/false on click within widget's box
              - select: active on click within widget's box; deactivated on click outside of box
            clicked: only true on the frame a widget was clicked on
            released: if widget is active, and active_mode is "pressed", true on the frame click was released, 
            selected: true on click within widget's box; false on click outside of box (same as active_mode: select)
            deselected: only true on first frame that selected became false
            clicks.count: number of consecutive fast-clicks on widget (2=doubleclick, 3=tripleclick, etc)
            clicks.timer: cooldown before clicks.count resets to 0

        Properties that can last for more than one frame will be set to an integer equal to the number of frames
            that property has been true, instead of the boolean value true.
        
        Widget dynamic properties:
            table of properties that are calculated "as-needed" (only when read from or written to)
            to use, add an entry to the properties attribute of the widget in the format [name] = {getter_func, setter_func}
              - getter_func should accept one argument: t, where t is the widget itself
              - setter_func should accept two arguments: t, v, where t is the widget itself, and v is the value to set
            default properties:
              - .box - returns x1, y1, x2, y2 where x1,y1 is the top left, and x2,y2 is the bottom right
              - .center - returns the coordinates of the center of the widget
    ]]

    local Charmap = {
        ['0'] = {'0',')'},
        ['1'] = {'1','!'},
        ['2'] = {'2','@'},
        ['3'] = {'3','#'},
        ['4'] = {'4','$'},
        ['5'] = {'5','%'},
        ['6'] = {'6','^'},
        ['7'] = {'7','&'},
        ['8'] = {'8','*'},
        ['9'] = {'9','('},
        ['A'] = {'a','A'},
        ['B'] = {'b','B'},
        ['C'] = {'c','C'},
        ['D'] = {'d','D'},
        ['E'] = {'e','E'},
        ['F'] = {'f','F'},
        ['G'] = {'g','G'},
        ['H'] = {'h','H'},
        ['I'] = {'i','I'},
        ['J'] = {'j','J'},
        ['K'] = {'k','K'},
        ['L'] = {'l','L'},
        ['M'] = {'m','M'},
        ['N'] = {'n','N'},
        ['O'] = {'o','O'},
        ['P'] = {'p','P'},
        ['Q'] = {'q','Q'},
        ['R'] = {'r','R'},
        ['S'] = {'s','S'},
        ['T'] = {'t','T'},
        ['U'] = {'u','U'},
        ['V'] = {'v','V'},
        ['W'] = {'w','W'},
        ['X'] = {'x','X'},
        ['Y'] = {'y','Y'},
        ['Z'] = {'z','Z'},
        ['backslash'] = {'\\','|'},
        ['comma'] = {',','<'},
        ['leftbracket'] = {'[','{'},
        ['minus'] = {'-','_'},
        ['numpad*'] = {'*','*'},
        ['numpad+'] = {'+','+'},
        ['numpad-'] = {'-','-'},
        ['numpad.'] = {'.','.'},
        ['numpad/'] = {'/','/'},
        ['numpad0'] = {'0','0'},
        ['numpad1'] = {'1','1'},
        ['numpad2'] = {'2','2'},
        ['numpad3'] = {'3','3'},
        ['numpad4'] = {'4','4'},
        ['numpad5'] = {'5','5'},
        ['numpad6'] = {'6','6'},
        ['numpad7'] = {'7','7'},
        ['numpad8'] = {'8','8'},
        ['numpad9'] = {'9','9'},
        ['period'] = {'.','>'},
        ['plus'] = {'=','+'},
        ['quote'] = {"'",'"'},
        ['rightbracket'] = {']','}'},
        ['semicolon'] = {';',':'},
        ['slash'] = {'/','?'},
        ['space'] = {' ',' '},
        ['tilde'] = {'`','~'},
    }

    tabs = {
        spacing = 17,
        insert = function(self,w)
            table.insert(self, {w, {x=w.x, y=w.y, w=w.w, h=w.h}})
            self[w] = #self
            w.x, w.y, w.w, w.h = self.spacing*(#self-1)+2, 151, 16, 21
        end,
        remove = function(self,w)
            local index = self[w]
            if not index then return end
            local w, state = unpack(table.remove(self, index))
            setkeys(w, state)
            self[w] = nil
            for i=index,#self do
                local w2 = self[i][1]
                self[w2] = i
                w2.x = w2.x - self.spacing
            end
        end,
    }

--

-- drawing

    drawings = {
        none = function(w) end,
        basic = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                gui.box(x1, y1, x2, y2, 0xC0C0C0FF, 0xFF)
            end,
        button = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                local fill
                if w.active then fill = 0x808080FF
                elseif w.hover then fill = 0xA0A0A0FF
                else fill = 0xC0C0C0FF end
                gui.box(x1, y1, x2, y2, fill, 0xFF)
            end,
        minesweeper = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                local c1, c2, c3 = 0xFFFFFFFF, 0xC0C0C0FF, 0x808080FF
                if w.active then
                    c1, c2, c3 = c3, c2, c2
                    if w.icon then w.icon.x, w.icon.y = x1+1,y1+1 end
                else
                    if w.icon then w.icon.x, w.icon.y = x1, y1 end
                end
                gui.box(x1, y1, x2, y2, c2)
                gui.line(x1, y1, x2-1, y1, c1)
                gui.line(x1, y1, x1, y2-1, c1)
                gui.line(x1+1, y2, x2, y2, c3)
                gui.line(x2, y1+1, x2, y2, c3)
            end,
        checkbox = function(w)
                local x1, y1, x2, y2 = unpack(w.box)
                gui.box(x1, y1, x2, y2, 0xFFFFFFFF, 0xFF)
                if w.state then
                    local w, h = math.floor((w.w-1)/2), math.floor((w.h-1)/2)
                    gui.line(x1+1, y1+h, x1+w, y2-1, 0x008000FF)
                    gui.line(x1+w, y2-1, x2, y1-1, 0x008000FF)
                end
            end,
        radiobutton = function(w)
                local x1, y1, x2, y2 = unpack(w.box)
                local c1, c2, c3 = 0xFFFFFFFF, 0xC0C0C0FF, 0x808080FF
                if w.state then c1, c3 = c3, c2 end
                gui.box(x1+1, y1+1, x2-1, y2-1, c2, c2)
                gui.line(x1+2, y1, x2-2, y1, c1)
                gui.line(x1+2, y2, x2-2, y2, c3)
                gui.line(x1, y1+2, x1, y2-2, c1)
                gui.line(x2, y1+2, x2, y2-2, c3)
                gui.pixel(x1+1, y1+1, c1)
                gui.pixel(x2-1, y2-1, c3)
            end,
        closebutton = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                local c1,c2 = 0, 0xFF
                if w.hover then c1,c2 = 0xE00000FF, 0xFFFFFFFF end
                gui.box(x1, y1, x2, y2, c1, c1)
                gui.line(x-1, y-1, x+1, y+1, c2)
                gui.line(x-1, y+1, x+1, y-1, c2)
            end,
        maximize = function (w)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                if w.hover or w.parent.maximized then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.box(x-1,y-1,x+1,y+1,0,0xFF)
            end,
        minimize = function (w)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                if w.hover then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.line(x-1,y,x+1,y,0xFF)
            end,
        undo = function (w)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                if w.hover then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.pixel(x,y-1,0xFF)
                gui.pixel(x-1,y,0xFF)
                gui.pixel(x,y+1,0xFF)
            end,
        redo = function (w)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                if w.hover then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.pixel(x,y-1,0xFF)
                gui.pixel(x+1,y,0xFF)
                gui.pixel(x,y+1,0xFF)
            end,
        find = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                if w.hover or w.parent.find_box then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.line(x1+1,y1+1,x2-1,y2-1,0xFF)
                gui.line(x1+1,y1+2,x1+2,y1+1,0xFF)
            end,
        play = function(w)
                local x1,y1,x2,y2 = unpack(w.box)
                if w.hover then gui.box(x1,y1,x2,y2,0x808080FF,0x808080FF) end
                gui.line(x1+2,y1+1,x1+2,y2-1,0x00C000FF)
                gui.line(x1+2,y1+2,x1+3,y1+2,0x00C000FF)
            end,
        dragbutton = function(w)
                local x1, y1, x2, y2 = unpack(w.box)
                local c1, c2 = 0xC0C0C0FF, 0x404040FF
                if w.active then c1 = 0x808080FF
                elseif w.hover then c1 = 0xA0A0A0FF end
                gui.box(x1, y1, x2, y2, c1, 0xFF)
                for i=1,x2-x1-1 do gui.line(x1+i, y2-1, x2-1, math.min(y2-1, y1+i), c2) end
            end,
        arrow = function(w, direction, c1, c2)
                local x1,y1,x2,y2 = unpack(w.box)
                local x,y = unpack(w.center)
                local c1,c2 = c1 or 0xC0C0C0FF, c2 or 0xFF
                if w.active then c1 = 0x808080FF
                elseif w.hover then c1 = 0xA0A0A0FF end
                gui.box(x1, y1, x2, y2, c1, c2)
                for i,v in ipairs{{1,0}, {-1,0}, {0,1}, {0,-1}} do
                    if i ~= direction then
                        gui.pixel(x+v[1], y+v[2], 0xFF)
                    end
                end
            end,
        arrowleft = function(w) drawings.arrow(w, 1) end,
        arrowright = function(w) drawings.arrow(w, 2) end,
        arrowup = function(w) drawings.arrow(w, 3) end,
        arrowdown = function(w) drawings.arrow(w, 4) end,
    }

    styles = {
        box = function(w, state)
                local x1, y1, x2, y2 = unpack(w.box)
                local c1, c2 = unpack(w.color[state] or w.color)
                gui.box(x1, y1, x2, y2, c1, c2 or c1)
                if w.icon then draw_icon(w.center, w.icon, state) end
            end,
        popout = function(w, state)
                local x1, y1, x2, y2 = unpack(w.box)
                local c1, c2, c3 = unpack(w.color[state] or w.color)
                gui.box(x1, y1, x2, y2, c2)
                gui.line(x1, y1, x2-1, y1, c1)
                gui.line(x1, y1, x1, y2-1, c1)
                gui.line(x1+1, y2, x2, y2, c3)
                gui.line(x2, y1+1, x2, y2, c3)
                if w.active then x1,x2 = x1+1, x2+1 end
                if w.icon then draw_icon(w.center, w.icon, state) end
            end,
    }       

    bitmaps = {
        x = {
            {1,0,1},
            {0,1,0},
            {1,0,1},
        },
        up = {
            {0,1,0},
            {1,0,1},
        },
        down = {
            {1,0,1},
            {0,1,0},
        },
        left = {
            {0,1},
            {1,0},
            {0,1},
        },
        right = {
            {1,0},
            {0,1},
            {1,0},
        },
        box = {
            {1,1,1},
            {1,0,1},
            {1,1,1},
        },
        dash = {
            {1,1,1},
        },
        plus = {
            {0,1,0},
            {1,1,1},
            {0,1,0},
        },
        check = {
            {0,0,0,0,1},
            {0,0,0,1,0},
            {1,0,0,1,0},
            {0,1,1,0,0},
            {0,0,1,0,0},
        },
    }

    palettes = {
        translucent = {
            0xFFFFFFC0, 0xFF,
            selected = {0xFFFFFFE0, 0xFF},
        },
        basic = {
            0xC0C0C0FF, 0xFF
        },
        pop = {
            0xFFFFFFFF, 0xC0C0C0FF, 0x808080FF,
            active = {0x808080FF, 0xC0C0C0FF, 0xC0C0C0FF},
        },
        interactive = {
            0xC0C0C0FF,
            hover = {0xA0A0A0FF},
            active = {0x808080FF},
        },
        red_white = {
            0, 0xFF,
            hover = {0xE00000FF, 0xFFFFFFFF},
        },
    }

--

-- functions

    function draw_icon(center, icon, state)
        local img, p = icon.img, icon.color[state] or icon.color
        local x,y = unpack(center)
        if type(img) == "string" then
            x,y = x-2*#img+1, y-3
            gui.text(x,y,img,p[1],p[2])
        elseif type(img) == "function" then
            img(x,y,p)
        else
            x,y = x-SHIFT(#img[1],1), y-SHIFT(#img,1)
            for i,row in ipairs(img) do
                for j,index in ipairs(row) do
                    if p[index+1] ~= 0 then gui.pixel(x+j-1,y+i-1,p[index+1]) end
                end
            end
        end
    end

    function setkeys(tbl1, tbl2)
        for k,v in pairs(tbl2) do tbl1[k] = v end
        return tbl1
    end

    function slice(tbl,i,j)
        local out = {}
        if j < 0 then j = #tbl+1-j end
        for x=i,j do out[#out+1] = tbl[x] end
        return out
    end

    local function collidepoint(point, box)
        local x, y = unpack(point)
        local x1, y1, x2, y2 = unpack(box)
        return x1 <= x and x <= x2 and y1 <= y and y <= y2
    end

    local function Components() -- Double Linked List + Hashmap; ideal data structure for insertion/deletion
        local out = {head={}, tail={}, n=0}
        out.head.next, out.tail.prev = out.tail, out.head
        function out:insert(prev, value, next)
            local node = {prev=prev, value=value, next=next}
            node.prev.next, node.next.prev = node, node
            self[value] = node
            self.n = self.n + 1
        end
        function out:remove(value)
            local node = self[value]
            node.prev.next, node.next.prev = node.next, node.prev
            self[value] = nil
            self.n = self.n - 1
        end
        function out:push(value)
            self:insert(self.head, value, self.head.next)
        end
        function out:append(value)
            self:insert(self.tail.prev, value, self.tail)
        end
        function out:iter()
            local cur = self.head
            return function() cur = cur.next; return cur.value end
        end
        function out:reverse()
            local cur = self.tail
            return function() cur = cur.prev; return cur.value end
        end
        return out
    end

    function HistoryManager(obj,...) -- Add directions for how to undo actions
        local out = {pos=1, entries={}, buffer={}, obj=obj, attrs=arg, freeze_buffer=false}
        function out:add(func,...)
            if self.freeze_buffer then return end
            local attrs = {}
            for i,k in ipairs(self.attrs) do
                local v = self.obj[k]
                if type(v) == "table" then attrs[k] = copytable(v)
                else attrs[k] = v end
            end
            table.insert(self.buffer, {func=func, attrs=attrs, unpack(arg)})
        end
        function out:set(func,...)
            self:add(func, unpack(arg))
            self.freeze_buffer = true
        end
        function out:undo()
            if self.pos > 1 then
                self.pos = self.pos - 1
                self:execute()
            end
        end
        function out:redo()
            if self.pos <= #self.entries then 
                self:execute()
                self.pos = self.pos + 1
            end
        end
        function out:execute()
            local entry = self.entries[self.pos]
            for i=#entry,1,-1 do
                local event = entry[i]
                event.func(self.obj, unpack(event))
                setkeys(self.obj, event.attrs)
            end
            self.entries[self.pos] = self.buffer
            self.buffer = {}
            self.freeze_buffer = false
        end
        function out:update()
            if #self.buffer > 0 then
                self.entries[self.pos] = self.buffer
                self.buffer = {}
                if self.pos < #self.entries then
                    self.entries = slice(self.entries, 1, self.pos)
                end
                self.pos = self.pos + 1
            end
            self.freeze_buffer = false
        end
        return out
    end

    function update(widget)
        local function reverse_update(w, hover)
            if not w.enabled then
                if w.prev.enabled then setkeys(w, {
                    hover=false, active=false, clicked=false, released=false, selected=false,
                    deselected=false, clicks={count=0,timer=0}})
                end
                return
            end
            if w.parent then
                if hover and collidepoint(inputs.mouse, w.box) then
                    w.hover = (w.hover or 0) + 1
                else
                    w.hover = false
                end
                w.clicked, w.released, w.deselected = false, false, false
                if inputs.keydown.leftclick then
                    if w.hover then
                        w.clicked = true
                        w.clicks.count, w.clicks.timer = w.clicks.count + 1, 20
                        w.selected = w.selected or 0
                        if w.active_mode == "pressed" then
                            w.active = 0
                        elseif w.active_mode == "toggle" then
                            w.active = not(w.active) and 0
                        end
                    else
                        if w.selected then w.deselected = true end
                        w.selected = false
                    end
                    if w.active_mode == "select" then w.active = w.selected end
                elseif inputs.keyup.leftclick then
                    if w.active and w.active_mode == "pressed" then
                        w.released = true
                        w.active = false
                    end
                end
                if w.active then w.active = w.active + 1 end
                if w.selected then w.selected = w.selected + 1 end
                if w.clicks.timer > 0 then w.clicks.timer = w.clicks.timer - 1 end
                if w.clicks.timer == 0 and not w.active then w.clicks.count = 0 end
            end
            if w.children then
                local hover = not w.parent or w.hover
                for c in w.children:reverse() do
                    reverse_update(c,hover)
                    if c.hover then hover = false end
                    if not w.parent and c.clicked and w.children[c] then
                        w.children:remove(c); w.children:append(c)
                    end
                end
            end
            if w.parent and w.update then w:update() end
        end
        local function forward_update(w)
            if not w.enabled then return end
            if w.children and w.parent then
                local dx, dy, dw, dh = w.x-w.prev.x, w.y-w.prev.y, w.w-w.prev.w, w.h-w.prev.h
                if OR(dx,dy,dw,dh) ~= 0 then
                    for c in w.children:iter() do
                        local flags = {}
                        for s in c.anchor:gmatch("%a") do flags[s] = true end
                        c.x, c.y = c.x+dx, c.y+dy
                        if flags.S then
                            if flags.N then c.h = c.h + dh
                            else c.y = c.y + dh end
                        end
                        if flags.E then
                            if flags.W then c.w = c.w + dw
                            else c.x = c.x + dw end
                        end
                    end
                end
            end
            if w.draw then
                if drawings[w.draw] then drawings[w.draw](w)
                else w:draw() end
            end
            if w.children then
                for c in w.children:iter() do forward_update(c) end
            end
            w.prev = {x=w.x, y=w.y, w=w.w, h=w.h, enabled=w.enabled}
        end
        reverse_update(widget, true)
        forward_update(widget)
    end

    function del(w)
        if w.parent.children[w] then w.parent.children:remove(w) end
    end

    function activate(w)
        w.parent.children:remove(w)
        w.parent.children:append(w)
        w.selected = true
    end

    local function exec(string)
        local func = loadstring("return " .. string)
        if func == nil then func, error = loadstring(string) end
        if func ~= nil then
            local values = {pcall(func)}
            if values[1] then
                if values[2] ~= nil then print(unpack(values, 2)) end
            else print(values[2]) end
        else print(error) end
    end

    local function splitlines(str)
        local lines = {}
        local maxw = 0
        for line in (str.."\n"):gmatch("(.-)\n") do
            lines[#lines+1] = line
            maxw = math.max(maxw, #line)
        end
        return lines, maxw
    end

    function repr(var, depth, indent) -- can print self-referential tables
        depth = depth or 0
        indent = (" "):rep(indent or 2)
        local path = {len=0}
        local escapes = {['"']='\"'}
        for i=7,13 do escapes[string.char(i)] = "\\"..("abtnvfr"):sub(i-6,i-6) end
        local key_format, value_format, parent_format -- can't use "local function()" syntax because key/value_format call each other
        function parent_format(var)
            if path.len - path[var] > 1 then
                return "table:parent^"..(path.len - path[var])
            else
                return "table:parent"
            end
        end
        function key_format(var)
            if type(var) == "string" then
                var = var:gsub("[\"\a\b\t\n\v\f\r]", escapes)
                return var:match("^[%a_][%w_]*$") and var or ('["%s"]'):format(var)
            else
                var = path[var] and parent_format(var) or value_format(var)
                return ("[%s]"):format(var)
            end
        end
        function value_format(var)
            if type(var) == "string" then
                return ('"%s"'):format(var:gsub("[\"\a\b\t\n\v\f\r]", escapes))
            elseif type(var) == "table" then
                path[var], path.len = path.len, path.len + 1
                local s = {}
                for k,v in pairs(var) do
                    v = path[v] and parent_format(v) or value_format(v)
                    local standard_key = type(k) == "number" and k > 0 and k <= #var and k % 1 == 0
                    s[#s+1] = standard_key and v or ("%s=%s"):format(key_format(k), v)
                end
                path[var], path.len = nil, path.len - 1
                if path.len < depth and #s > 0 then
                    local sep = "\n"..indent:rep(path.len+1)
                    return "{"..sep..table.concat(s,","..sep)..",\n"..indent:rep(path.len).."}"
                else
                    return "{"..table.concat(s,", ").."}"
                end
            else
                return tostring(var)
            end
        end
        return value_format(var)
    end

    function reduce(tbl) -- eliminates recursive table elements so it can be printed
        local out = setkeys({}, tbl)
        out.parent, out.children, out.history = nil, nil, nil
        for k,v in pairs(out) do
            if type(v) == "table" then out[k] = reduce(v)
            elseif out.class and type(v) == "function" then out[k] = nil end
        end
        return out
    end

    function gui_color(x,y,text,clist,offset)
        for i=1,#text do
            gui.text(x+(i-1)*4, y, text:sub(i,i), clist[i+offset] or 0xFFFFFFFF)
        end
    end

--

-- widgets

    function Div(w, options) -- base class for all widgets
        if options then setkeys(w, options) end
        w = setkeys({
            class=debug.getinfo(2).name, enabled=true, parent=widgets, x=0, y=0, w=0, h=0, anchor="NW",
            hover=false, active=false, clicked=false, released=false, active_mode="pressed",
            selected=false, deselected=false, clicks={count=0,timer=0}, properties={}
        }, w)
        setmetatable(w, {
            __index = function(t,k)
                local p = w.properties[k]
                return p and p[1](t)
            end,
            __newindex = function(t,k,v)
                local p = w.properties[k]
                if not p then rawset(t,k,v) else p[2](t,v) end
            end,
        })
        w.properties.box = {function(t) return {t.x, t.y, t.x+t.w-1, t.y+t.h-1} end}
        w.properties.center = {
            function(t) return {SHIFT(t.w-1,1)+t.x, SHIFT(t.h-1,1)+t.y} end,
            function(t,v) t.x, t.y = v[1]-SHIFT(t.w-1,1), v[2]-SHIFT(t.h-1,1) end,
        }
        w.x, w.y = w.parent.x + w.x, w.parent.y + w.y
        w.parent.children = w.parent.children or Components()
        if w.parent.children[w] then w.parent.children:remove(w) end
        w.parent.children:append(w)
        w.prev = {x=w.x, y=w.y, w=w.w, h=w.h, enabled=w.enabled}
        return w
    end

    function Button(options)
        local out = Div({x=0, y=0, w=7, h=7, draw="minesweeper"}, options)
        function out:update()
            if self.clicked and self.onclick then self:onclick() end
            if self.released and self.onrelease then self:onrelease() end
        end
        return out
    end

    function Checkbox(options)
        local out = Div({x=0, y=0, w=7, h=7, draw="checkbox", state=false}, options)
        function out:update()
            if self.clicked then
                self.state = not self.state
                if self.onclick then self:onclick(self.state) end
            end
        end
        return out
    end

    function Radio(options)
        local out = Div({x=0, y=0, w=7, h=24, size=3}, options)
        out.buttons = {}
        out.value = 0
        function out:update()
            self.h = 8*self.size
            for i=1,self.size do
                local b = self.buttons[i]
                if not b then
                    b = Checkbox{draw="radiobutton", parent=self}
                    table.insert(self.buttons, b)
                end
                if b.clicked then self.value = i end
                b.state = i==self.value
            end
            for i=#self.buttons,self.size+1,-1 do
                self.children:remove(table.remove(self.buttons))
            end
        end
        function out:draw()
            for i,b in ipairs(self.buttons) do
                b.x, b.y = self.x, self.y+8*(i-1)
            end
        end
        return out
    end

    function Inputbox(options)
        local out = Div({
            x=0, y=0, w=121, h=11, lineheight=8,
            lines={""}, cursor={0,1}, cursor2={0,1}, xview=0, yview=0, maxw=0, flash=0, x_hover=false,
            y_hover=false, highlight=false, textcolor={0xFFFFFFFF,0xFF}, background={0xFFFFFFE0,0xFF}},
            options)
        out.properties.text = {
            function(t) t._text = t._text or table.concat(t.lines, "\n"); return t._text end,
            function(t,v) t:set_text(v) end}
        out.properties.charwidth = {
            function(t) return bit.arshift(t.w-5, 2) end,
            function(t,v) t.w = 4*v + 5 end}
        out.properties.charheight = {
            function(t) return bit.arshift(t.h-2, 3) end,
            function(t,v) t.h = 8*v + 3 end}
        out.properties.endpos = {function(t) return {#t.lines[#t.lines], #t.lines} end}
        out.history = HistoryManager(out, "cursor", "cursor2", "highlight", "xview", "yview")
        local function bound(x,y)
            local y = math.max(1, math.min(#out.lines, y))
            local x = math.max(0, math.min(#out.lines[y], x))
            return x,y
        end
        local function sort_cursors(c1,c2)
            c1, c2 = c1 or out.cursor, c2 or out.cursor2
            local x1, y1 = unpack(c1)
            local x2, y2 = unpack(c2)
            if y1 > y2 or y1==y2 and x1 > x2 then return c2, c1
            else return c1, c2 end
        end
        local function cursor_coords(c1,c2)
            c1, c2 = sort_cursors(c1, c2)
            local x1, y1 = bound(unpack(c1))
            local x2, y2 = bound(unpack(c2))
            return x1, y1, x2, y2
        end
        local function rel_cursor(distance, cursor)
            local x, y = unpack(cursor or out.cursor)
            x = x + distance
            while x < 0 and y > 1 do
                x,y = x+1 + #out.lines[y-1], y-1
            end
            local len = #out.lines[y]
            while x > len and y < #out.lines do
                x,y = x-1 - len, y + 1
                len = #out.lines[y]
            end
            return {math.max(0, math.min(len, x)), y}
        end
        local function word_bounds(cursor, both)
            local x, y = unpack(cursor or out.cursor)
            local l = ("%s\n%s\n%s"):format(out.lines[y-1] or "", out.lines[y], out.lines[y+1] or "")
            x = x + #(out.lines[y-1] or "") + 1
            local lc, rc = l:sub(x,x), l:sub(x+1,x+1)
            if both then lc, rc = lc..rc, lc..rc end
            local lp, rp = "[^%s%w_]+", "[^%s%w_]+"
            for i,p in pairs({"[ ]","[%w_]","\n"}) do
                if lc:match(p) then lp = p.."+" end
                if rc:match(p) then rp = p.."+" end
            end
            local _,left = l:reverse():sub(#l-x):find(lp)
            local _,right = l:sub(x):find(rp)
            return {rel_cursor(1-left, cursor), rel_cursor(right-1, cursor)}
        end
        function out:get_selected(s,e)
            local x1,y1,x2,y2 = cursor_coords(s,e)
            local s = table.concat(slice(self.lines,y1,y2), "\n")
            return s:sub(x1+1, x2-1-#self.lines[y2])
        end
        function out:set_view(x,y)
            self.xview = math.max(math.min(self.xview, x), x-self.charwidth)
            self.yview = math.max(math.min(self.yview, y-1), y-self.charheight)
        end
        function out:set_cursor(x, y, select)
            if not self.highlight or x ~= self.cursor[1] then self.cursor2[3] = x end
            x,y = bound(x,y)
            if select and not self.highlight then
                self.cursor2[1], self.cursor2[2] = unpack(self.cursor)
            elseif not select then
                self.cursor2[1], self.cursor2[2] = x, y
            end
            self.cursor[1], self.cursor[2] = x, y
            self:set_view(x,y)
        end
        function out:set_highlight(c1, c2)
            setkeys(self.cursor, c2)
            setkeys(self.cursor2, c1)
            self.highlight=true
            self:set_view(unpack(c2))
            self:set_view(unpack(c1))
        end
        function out:find(text, start, plain)
            plain = not plain
            start = start or {0,1}
            local search = table.concat(slice(self.lines, start[2], -1), "\n")
            local s,e = search:find(text, start[1]+1, plain)
            if not s then return end
            local c1 = rel_cursor(s-start[1]-1, start)
            local c2 = rel_cursor(e-s+1, c1)
            self:set_highlight(c1, c2)
            return c1, c2
        end
        function out:insert_text(text, cursor)
            local newlines, maxw = splitlines(text)
            local x, y = unpack(cursor)
            newlines[1] = self.lines[y]:sub(1,x)..newlines[1]
            x, newlines[#newlines] = #newlines[#newlines], newlines[#newlines]..self.lines[y]:sub(x+1,-1)
            self.lines[y] = newlines[1]
            if #newlines > 1 then
                for i = #self.lines+#newlines-1, y+#newlines, -1 do
                    self.lines[i] = self.lines[i-#newlines+1]
                end
                for i = y+#newlines-2, y+1, -1 do self.lines[i] = newlines[i-y+1] end
                self.lines[y+#newlines-1] = newlines[#newlines]
            end
            self.maxw = math.max(self.maxw, maxw, #newlines[1], #newlines[#newlines])
            self:on_modify()
            self.history:add(self.remove_text, copytable(cursor), {x, y+#newlines-1})
            return x, y+#newlines-1
        end
        function out:write(text)
            if self.highlight then self:set_cursor(self:remove_text()) end
            self:set_cursor(self:insert_text(text, out.cursor))
        end
        function out:remove_text(s, e)
            local x1, y1, x2, y2 = cursor_coords(s, e)
            if x1==x2 and y1==y2 then return x1, y1 end
            self.history:add(self.insert_text, self:get_selected(s,e), {x1,y1})
            self.lines[y1] = self.lines[y1]:sub(1,x1)..self.lines[y2]:sub(x2+1,-1)
            if y2 ~= y1 then
                for y=y1+1,#self.lines do self.lines[y] = self.lines[y+y2-y1] end
            end
            self:on_modify()
            return x1, y1
        end
        function out:delete(s,e)
            if self.highlight then
                self:set_cursor(self:remove_text(self.cursor, self.cursor2))
            else
                self:set_cursor(self:remove_text(s,e))
            end
        end
        function out:set_text(text)
            if text == self.text then return end
            local s,e = text:find(self.text,1,1)
            if s and #self.lines > 1 then
                if s > 1 then self:insert_text(text:sub(1,s-1), {0,1}) end
                if e < #text then self:insert_text(text:sub(e+1), self.endpos) end
            else
                self.history:set(self.set_text, self.text)
                self.lines, self.maxw = splitlines(text)
            end
            self._text = text
        end
        function out:on_modify()
            if #self.lines == 1 then self._text, self.maxw = self.lines[1], #self.lines[1]
            else self._text = nil end
        end
        function out:update()
            local x = math.floor((inputs.xmouse-self.x)/4) + self.xview
            local y = math.floor((inputs.ymouse-2-self.y)/8)+1 + self.yview
            x,y = bound(x,y)
            if self.hover then self.x_hover, self.y_hover = x,y
            else self.x_hover, self.y_hover = false, false end
            if not self.selected then return end
            self.flash = self.flash==60 and 0 or self.flash + 1
            if self.active then
                self.flash = 0
                self:set_view(x,y)
                self.cursor2[3] = x
                if self.clicked and not inputs.shift then setkeys(self.cursor2, {x,y}) end
                setkeys(self.cursor, {x,y})
                if self.clicks.count >= 2 then
                    if not self.highlight then self.dclickpos = copytable(self.cursor) end
                    local c1, c2 = sort_cursors(self.dclickpos, self.cursor)
                    local lb, rb = word_bounds(c1,1)[1], word_bounds(c2,1)[2]
                    if self.clicks.count == 3 then lb, rb = {0,lb[2]}, {#self.lines[rb[2]], rb[2]}
                    elseif self.clicks.count >= 4 then lb, rb = {0,1}, self.endpos end
                    if self.cursor ~= c1 then lb,rb = rb,lb end
                    setkeys(self.cursor,lb); setkeys(self.cursor2,rb)
                end
            end
            self.highlight = self.cursor2[1] ~= self.cursor[1] or self.cursor2[2] ~= self.cursor[2]
            joypad.set(1, {})
            for key,value in pairs(inputs.keys) do
                if type(value) == "number" and (value == 1 or value >= 30) then
                    local modified = key
                    if inputs.shift then modified = "shift+"..modified end
                    if inputs.control then modified = "control+"..modified end
                    local hotkey = self.hotkeys[modified] or self.hotkeys[key]
                    if hotkey then
                        hotkey(); self.flash=0
                    elseif Charmap[key] and not inputs.control then
                        self.flash=0
                        local is_letter = #key == 1 and string.byte(key) >= 0x41 and string.byte(key) <= 0x5a
                        local mode = 0
                        if is_letter and inputs.capslock then mode = XOR(mode, 1) end
                        if inputs.shift then mode = XOR(mode, 1) end
                        local char = Charmap[key][mode + 1]
                        local open = char:match("['\"([{]")
                        if self.highlight and open then
                            local close = ({["'"]="'", ['"']='"', ["("]=")", ["["]="]", ["{"]="}"})[open]
                            local x1,y1 = cursor_coords()
                            self:write(open..self:get_selected()..close)
                            setkeys(self.cursor2, {x1+1, y1}); self.cursor[1] =  self.cursor[1] - 1
                        else
                            self:write(char)
                        end
                    end
                end
            end
            self.history:update()
        end
        function out:draw()
            local x1, y1, x2, y2 = unpack(self.box)
            local xtext, ytext = self.x+3, self.y+2
            self.xview = math.max(0,math.min(self.maxw-self.charwidth,self.xview))
            self.yview = math.max(0,math.min(#self.lines-self.charheight,self.yview))
            local bc1, bc2 = unpack(self.background)
            if not self.selected then
                bc1 = OR(AND(bc1,0xFFFFFF00), math.max(0, AND(bc1,0xFF)-0x20))
                bc2 = OR(AND(bc2,0xFFFFFF00), math.max(0, AND(bc2,0xFF)-0x20))
            end
            gui.box(x1, y1, x2, y2, bc1, bc2)
            if self.highlight then
                local x1, y1, x2, y2 = cursor_coords()
                x1, y1, x2, y2 = x1-self.xview, y1-self.yview, x2-self.xview, y2-self.yview
                for y=math.max(1,y1),math.min(self.charheight,y2) do
                    local x3, x4 = x1, x2
                    if y > y1 then x3 = 0 end
                    if y < y2 then x4 = #self.lines[y+self.yview]-self.xview end
                    x3, x4 = math.max(0, math.min(self.charwidth, x3)), math.max(0, math.min(self.charwidth, x4))
                    local highlight_color = self.selected and 0x80C0FFFF or 0xC0C0C0FF
                    gui.box(xtext-1 + 4*x3, ytext-1 + 8*(y-1), xtext-1 + 4*x4, ytext+7 + 8*(y-1), highlight_color)
                end
            end
            for y=1,self.charheight do
                local text = (self.lines[y+self.yview] or ""):sub(self.xview + 1, self.xview + self.charwidth)
                if self.clist and self.clist[y+self.yview] then
                    gui_color(xtext, ytext + 8*(y-1), text, self.clist[y+self.yview], self.xview)
                else
                    gui.text(xtext, ytext + 8*(y-1), text, unpack(self.textcolor))
                end
            end
            if self.selected and self.flash < 30 then
                local x,y = self.cursor[1] - self.xview, self.cursor[2] - self.yview
                if x >= 0 and x <= self.charwidth and y >= 1 and y <= self.charheight then
                    local cursorcolor = self.background[1] % 256 == 0 and 0xFF or OR(XOR(self.background[1],-1),0xFF)
                    gui.line(xtext + 4*x - 1, ytext + 8*y - 9, xtext + 4*x - 1, ytext + 8*y - 1, cursorcolor)
                end
            end
        end
        out.hotkeys = {
            ["backspace"] = function()
                local s,e = rel_cursor(-1), out.cursor
                if inputs.control then s = word_bounds()[1] end
                out:delete(s, e)
            end,
            ["delete"] = function()
                local s,e = out.cursor, rel_cursor(1)
                if inputs.control then e = word_bounds()[2] end
                out:delete(s, e)
            end,
            ["left"] = function()
                local x,y = unpack(inputs.control and word_bounds()[1] or rel_cursor(-1))
                if out.highlight and not inputs.shift and not inputs.control then x,y = cursor_coords() end
                out:set_cursor(x, y, inputs.shift)
            end,
            ["right"] = function()
                local x,y = unpack(inputs.control and word_bounds()[2] or rel_cursor(1))
                if out.highlight and not inputs.shift and not inputs.control then _,_,x,y = cursor_coords() end
                out:set_cursor(x, y, inputs.shift)
            end,
            ["up"] = function ()
                if inputs.control and not inputs.shift then
                    out.yview = math.max(0, out.yview-1); return
                end
                local x,y = unpack(out.cursor)
                if out.highlight then x = out.cursor2[3] end
                if out.highlight and not inputs.shift then y = math.min(y, out.cursor[2]) end
                out:set_cursor(x, y-1, inputs.shift)
            end,
            ["down"] = function ()
                if inputs.control and not inputs.shift then
                    out.yview = math.min(#out.lines-out.charheight, out.yview+1); return
                end
                local x,y = unpack(out.cursor)
                if out.highlight then x = out.cursor2[3] end
                if out.highlight and not inputs.shift then _,_,x,y = cursor_coords() end
                out:set_cursor(x, y+1, inputs.shift)
            end,
            ["home"] = function()
                out:set_cursor(0, inputs.control and 1 or out.cursor[2], inputs.shift)
            end,
            ["end"] = function()
                local y = inputs.control and #out.lines or out.cursor[2]
                out:set_cursor(#out.lines[y], y, inputs.shift)
            end,
            ["tab"] = function()
                local c1,c2 = sort_cursors(out.cursor, out.cursor2)
                if c1[2]~=c2[2] or inputs.shift then
                    local l1, l2 = #out.lines[out.cursor[2]], #out.lines[out.cursor2[2]]
                    for y=c1[2],c2[2] do
                        local l = out.lines[y]
                        local _,d = l:find("%s*")
                        if inputs.shift then
                            if d > 0 then out:remove_text({0,y}, {(d-1)%4+1, y}) end
                        else
                            out:insert_text((" "):rep(4-d%4), {0,y})
                        end
                    end
                    local d1, d2 = #out.lines[out.cursor[2]]-l1, #out.lines[out.cursor2[2]]-l2
                    out.cursor[1], out.cursor2[1] = out.cursor[1]+d1, out.cursor2[1]+d2
                else
                    if out.highlight then out:delete() end
                    out:write((" "):rep(4 - out.cursor[1] % 4))
                end
            end,
            ["escape"] = function() out.selected = false end,
            ["enter"] = function() out:write("\n") end,
            ["pageup"] = function() out:set_cursor(out.cursor[1], out.cursor[2]-out.charheight, inputs.shift) end,
            ["pagedown"] = function() out:set_cursor(out.cursor[1], out.cursor[2]+out.charheight, inputs.shift) end,
            ["control+C"] = function() clipboard:copy(out:get_selected()) end,
            ["control+X"] = function() clipboard:copy(out:get_selected()); out:delete() end,
            ["control+V"] = function() out:write(clipboard:paste()) end,
            ["control+A"] = function() out.cursor, out.cursor2, out.highlight = {0,1}, copytable(out.endpos), true end,
            ["control+Z"] = function() out.history:undo() end,
            ["control+Y"] = function() out.history:redo() end,
        }
        if options and options.text then out.text = nil; out.text = options.text end
        return out
    end

    function Interpreter(options)
        local out = Inputbox(options)
        out.commands = {}
        out.command_pos = 1
        out.hotkeys["shift+enter"] = out.hotkeys["enter"]
        out.hotkeys["enter"] = function()
            if out.text == "" then return end
            exec(out.text)
            if out.text ~= out.commands[#out.commands] then
                table.insert(out.commands, out.text)
            end
            out.command_pos = #out.commands+1
            out.text = ""
            out:set_cursor(0,1)
        end
        out.hotkeys["up"] = function()
            if #out.commands == 0 then return end
            out.command_pos = math.max(1, out.command_pos - 1)
            out.text = out.commands[out.command_pos]
            out:set_cursor(#out.lines[#out.lines], #out.lines)
        end
        out.hotkeys["down"] = function()
            out.command_pos = math.min(#out.commands + 1, out.command_pos + 1)
            out.text = out.commands[out.command_pos] or ""
            out:set_cursor(#out.lines[#out.lines], #out.lines)
        end
        return out
    end

    function Slider(options)
        local out = Div({x=0, y=0, w=50, h=7, bounds={0,1}, step=0, orientation="h"}, options)
        out.slideline = Div{parent=out, draw="basic"}
        out.button = Div{parent=out, draw="basic"}
        out.value, out.position = 0, 0
        function out:update()
            local lower, upper = unpack(self.bounds)
            if self.button.active then
                local x1, y1, x2, y2 = unpack(self.slideline.box)
                x1, y1, x2, y2 = inputs.xmouse-x1, inputs.ymouse-y1, x2-x1, y2-y1
                self.position = math.min(1, math.max(0, (x1*x2 + y1*y2)/(x2*x2 + y2*y2)))
                self.value = (upper-lower)*self.position + lower
                if self.step ~= 0 then self.value = math.floor(self.value/self.step + 0.5)*self.step end
            end
            self.position = math.min(1, math.max(0, (self.value-lower)/(upper-lower)))
        end
        function out:draw()
            local x, y, w, h = self.x, self.y, self.w, self.h
            local bsize = self.orientation=="h" and h or self.orientation=="v" and w
            local r = SHIFT(bsize-1,1)
            setkeys(self.slideline, {x=x+r, y=y+r, w=w-bsize+1, h=h-bsize+1})
            local x1, y1, x2, y2 = unpack(self.slideline.box)
            local bx, by = (x2-x1)*self.position + x, (y2-y1)*self.position + y
            setkeys(self.button, {x=bx, y=by, w=bsize, h=bsize})
        end
        return out
    end

    function ScrollV(options)
        local out = Div({x=0, y=0, w=7, h=50, bounds={1,10}, step=1, viewsize=1}, options)
        out.button1 = Button{x=0, y=0, w=out.w, h=out.w, anchor="NEW", draw="arrowup", parent=out}
        out.button2 = Div{x=0, y=out.h-out.w, w=out.w, h=out.w, anchor="SEW", draw="arrowdown", parent=out}
        out.slideline = Div{x=SHIFT(out.w,1), y=out.w, w=1, anchor="NSW", draw="none", parent=out}
        out.slidebutton = Div{x=0, y=out.w, w=out.w, anchor="NSEW", draw="button", parent=out}
        out.value, out.position = 0, 0
        function out:update()
            local lower, upper = unpack(self.bounds)
            local b1, b2, sb = self.button1, self.button2, self.slidebutton
            if sb.clicked then sb.rel = inputs.ymouse - sb.center[2] end
            if sb.active then
                local x1, y1, x2, y2 = unpack(self.slideline.box)
                x1, y1, x2, y2 = inputs.xmouse-x1, inputs.ymouse-sb.rel-y1, x2-x1, y2-y1
                self.position = math.min(1, math.max(0, (x1*x2 + y1*y2)/(x2*x2 + y2*y2)))
                self.value = (upper-lower)*self.position + lower
                self.value = math.floor(self.value/self.step + 0.5)*self.step
            elseif b1.clicked or (b1.active or 0) >= 30 then self.value = self.value - self.step
            elseif b2.clicked or (b2.active or 0) >= 30 then self.value = self.value + self.step
            elseif self.clicked or (self.active or 0) >= 30 then
                if inputs.ymouse < sb.y then
                    self.value = self.value - self.viewsize
                elseif inputs.ymouse >= sb.y + sb.h then
                    self.value = self.value + self.viewsize
                end
            end
            if self.value < lower then self.value = lower
            elseif self.value > upper then self.value = upper end
            self.position = (self.value-lower)/(upper-lower)
        end
        function out:draw()
            local x1, y1, x2, y2 = unpack(self.box)
            gui.box(x1, y1, x2, y2, 0xE0E0E0C0, 0xff)
            local lower, upper = unpack(self.bounds)
            local w, h, sb, sl = self.w, self.h, self.slidebutton, self.slideline
            self.button1.h, self.button2.h = w, w
            sb.h = math.max(math.min(w,h-2*w), math.floor(self.viewsize/(upper-lower+self.viewsize)*(h-2*w+2)))
            sl.h = math.max(1, h - 2*w - sb.h + 1)
            sl.y = y1 + w + SHIFT(sb.h,1)
            sb.y = y1 + w + (sl.h-1)*self.position
        end
        return out
    end

    function ScrollH(options)
        local out = Div({x=0, y=0, w=50, h=7, bounds={1,10}, step=1, viewsize=1}, options)
        out.button1 = Div{x=0, y=0, w=out.h, h=out.h, anchor="NSW", draw="arrowleft", parent=out}
        out.button2 = Div{x=out.w-out.h, y=0, w=out.h, h=out.h, anchor="NSE", draw="arrowright", parent=out}
        out.slideline = Div{x=out.h, y=SHIFT(out.h,1), h=1, anchor="EWN", draw="none", parent=out}
        out.slidebutton = Div{x=out.h, y=0, w=out.h, h=out.h, anchor="NSEW", draw="button", parent=out}
        out.value, out.position = 0, 0
        function out:update()
            local lower, upper = unpack(self.bounds)
            local b1, b2, sb = self.button1, self.button2, self.slidebutton
            if sb.clicked then sb.rel = inputs.xmouse - sb.center[1] end
            if sb.active then
                local x1, y1, x2, y2 = unpack(self.slideline.box)
                x1, y1, x2, y2 = inputs.xmouse-sb.rel-x1, inputs.ymouse-y1, x2-x1, y2-y1
                self.position = math.min(1, math.max(0, (x1*x2 + y1*y2)/(x2*x2 + y2*y2)))
                self.value = (upper-lower)*self.position + lower
                self.value = math.floor(self.value/self.step + 0.5)*self.step
            elseif b1.clicked or (b1.active or 0) >= 30 then self.value = self.value - self.step
            elseif b2.clicked or (b2.active or 0) >= 30 then self.value = self.value + self.step
            elseif self.clicked or (self.active or 0) >= 30 then
                if inputs.xmouse < sb.x then
                    self.value = self.value - self.viewsize
                elseif inputs.xmouse >= sb.x + sb.w then
                    self.value = self.value + self.viewsize
                end
            end
            if self.value < lower then self.value = lower
            elseif self.value > upper then self.value = upper end
            self.position = (self.value-lower)/(upper-lower)
        end
        function out:draw()
            local x1, y1, x2, y2 = unpack(self.box)
            gui.box(x1, y1, x2, y2, 0xE0E0E0C0, 0xff)
            local lower, upper = unpack(self.bounds)
            local w, h, sb, sl = self.w, self.h, self.slidebutton, self.slideline
            self.button1.w, self.button2.w = h, h
            sb.w = math.max(math.min(w-2*h,h), math.floor(self.viewsize/(upper-lower+self.viewsize)*(w-2*h+2)))
            sl.w = math.max(1, w - 2*h - sb.w + 1)
            sl.x = x1 + h + SHIFT(sb.w,1)
            sb.x = x1 + h + (sl.w-1)*self.position
        end
        return out
    end

    function Window(options)
        local out = Div({x=2, y=17, w=121, h=100, title=""}, options)
        out.properties.text = {function(t) return t.inputbox.text end, function(t,v) t.inputbox.text = v end}
        out.topbar = Button{w=out.w, h=9, anchor="NEW", parent=out}
        out.inputbox = Inputbox{x=0, y=8, w=out.w-6, h=out.h-14, anchor="NSEW", parent=out}
        out.vscroll = ScrollV{x=out.w-7, y=8, w=7, h=out.h-14, anchor="NSE", step=1, parent=out}
        out.hscroll = ScrollH{x=0, y=out.h-7, w=out.w-6, h=7, anchor="SEW", step=1, parent=out}
        out.dragbutton = Button{x=out.w-7, y=out.h-7, w=7, h=7, anchor="SE", draw="dragbutton", parent=out}
        out.topbuttons = {spacing=5}
        function out.topbuttons:new(draw)
            local s = self.spacing
            local b = Button{x=out.w-s*#self-s-1, y=1, w=s, h=s, anchor="NE", draw=draw, parent=out}
            table.insert(self, 1, b)
            return b
        end
        out.closebutton = out.topbuttons:new("closebutton")
        out.maximizebutton = out.topbuttons:new("maximize")
        out.minimizebutton = out.topbuttons:new("minimize")
        out.redobutton = out.topbuttons:new("redo")
        out.undobutton = out.topbuttons:new("undo")
        out.findbutton = out.topbuttons:new("find")
        out.playbutton = out.topbuttons:new("play")
        out.topbar.draw = function(w)
            drawings.basic(w)
            if out.title_box then return end
            local len = math.floor((out.w - out.topbuttons.spacing*#out.topbuttons - 6)/4)
            local title = out.title:sub(1,math.max(1, len))
            gui.text(w.x+3, w.y+1, title, 0xFF, 0)
        end
        out.minimized = false
        out.maximized = false
        -- Button Effects
            function out.playbutton.onclick()
                out:run(inputs["shift"])
            end
            function out.findbutton:onclick()
                if not out.find_box then
                    out:start_find_box()
                else
                    out.find_box.esc()
                end
            end
            function out.undobutton:onclick() out.inputbox.history:undo() end
            function out.redobutton:onclick() out.inputbox.history:redo() end
            function out.minimizebutton:onclick()
                out.minimized = not out.minimized
                if out.minimized then
                    tabs:insert(out)
                else
                    tabs:remove(out)
                end
            end
            function out.maximizebutton:onclick()
                if out.minimized then
                    tabs:remove(out)
                    out.minimized = false
                elseif not out.maximized then
                    out.maximizebutton.initsize = {x=out.x, y=out.y, w=out.w, h=out.h}
                    setkeys(out, {x=0, y=0, w=240, h=161})
                    out.maximized = true
                else
                    setkeys(out, out.maximizebutton.initsize)
                    out.maximized = false
                end
            end
            function out.closebutton:onclick()
                tabs:remove(out); out.parent.children:remove(out)
            end
            function out.topbar:onclick()
                if out.minimized then tabs:remove(out); out.minimized = false
                else out.topbar.init_pos = {inputs.xmouse-out.x, inputs.ymouse-out.y} end
            end
            function out.topbar:onrelease() out.topbar.init_pos = nil end
            function out.dragbutton:onclick()
                out.dragbutton.init_pos = {inputs.xmouse, inputs.ymouse, out.w, out.h}
            end
        --
        function out:run(highlighted_only)
            if highlighted_only then exec(self.inputbox:get_selected())
            else exec(self.inputbox.text) end
        end
        function out:save(filename)
            local f = io.open(filename, "w")
            f:write(self.inputbox.text)
            f:close()
            print('Saved to "'..filename..'"')
        end
        function out:load(filename)
            local f = io.open(filename)
            self.inputbox.text = f:read("*a")
            f:close()
            print('Loaded from "'..filename..'"')
        end
        function out:edit_title()
            if not self.title_box then
                self.title_box = Inputbox{
                    y=-1, w=out.w, text=self.title, textcolor={0xFF,0}, background={0,0}, anchor="NEW", parent=out}
                self.title_box.hotkeys["enter"] = function()
                    self.title = self.title_box.text
                    del(self.title_box); self.title_box = nil
                end
                self.inputbox.selected = false
                update(self.title_box)
            end
        end
        function out:start_find_box()
            self.find_box = Inputbox{
                x=SHIFT(self.w,1), y=self.topbar.h-1, w=self.w-SHIFT(self.w,1)-self.vscroll.w+1,
                anchor="NE", parent=out}
            self.find_box.init = function()
                    self.find_box.selected = 1
                    self.find_box.text = self.inputbox:get_selected()
                    self.inputbox.selected = false
                end
            self.find_box.esc = function() del(self.find_box); self.find_box = nil end
            self.find_box.hotkeys["enter"] = function()
                    local s = self.inputbox:find(self.find_box.text, self.inputbox.cursor)
                    if not s then self.inputbox:find(self.find_box.text) end
                    self.find_box.esc()
                end
            self.find_box.init()
        end
        function out:update()
            if inputs.control and inputs.keydown["F"] then
                if not self.find_box then self:start_find_box()
                else self.find_box.init() end
            end
            if not (self.find_box or self.title_box) then
                self.inputbox.selected = self.selected
            end
            if self.find_box and inputs.escape then self.find_box.esc() end
            if self.hscroll.active then self.inputbox.xview = self.hscroll.value
            else self.hscroll.value = self.inputbox.xview end
            if self.vscroll.active then self.inputbox.yview = self.vscroll.value
            else self.vscroll.value = self.inputbox.yview end
            self.hscroll.bounds = {0, math.max(0, self.inputbox.maxw-self.inputbox.charwidth)}
            self.vscroll.bounds = {0, math.max(0, #self.inputbox.lines-self.inputbox.charheight)}
            self.hscroll.viewsize = self.inputbox.charwidth
            self.vscroll.viewsize = self.inputbox.charheight
            if self.topbar.active and self.topbar.init_pos then
                local x,y = unpack(self.topbar.init_pos)
                self.x, self.y = inputs.xmouse-x, inputs.ymouse-y
            end
            if self.topbar.clicks.count >= 2 and not self.title_box then self:edit_title() end
            if self.title_box and not self.title_box.selected then del(self.title_box); self.title_box = nil end
            if self.dragbutton.active then
                local x, y, w, h = unpack(self.dragbutton.init_pos)
                self.w = math.max(13, inputs.xmouse-x+w)
                self.h = math.max(21, inputs.ymouse-y+h)
                self.maximized = false
            end
            for i,b in ipairs(self.topbuttons) do b.enabled = b.x >= self.x + 8 end
            if self.hook then self.inputbox.text = repr(reduce(self.hook), 1) end
        end
        return out
    end

--

mainloop:push(function() widgets:update() end)