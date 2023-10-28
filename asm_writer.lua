require "widgets"
require "asm"

i = widgets.Interpreter{w=169}
t_box = widgets.Inputbox{x=0,y=i.y+12,w=169}
template_box = widgets.Inputbox{x=t_box.x,y=t_box.y+12,w=169}
b_box = widgets.Inputbox{x=t_box.x,y=template_box.y+12,w=133}
h_box = widgets.Inputbox{x=b_box.x+b_box.w-1,y=b_box.y,w=37}
category_box = widgets.Window{x=0,y=b_box.y+12,w=175,h=93}
category_box.text = widgets.repr(OPS_A,1)
category_box.minimizebutton:onclick()
mode_toggle = widgets.Button{x=i.x+i.w+2,y=1,active_mode="toggle",clicked=true}
local colors = {
    a = 0xFF0000FF,
    b = 0xFF8000FF,
    c = 0xFFFF00FF,
    d = 0x00FF00FF,
    e = 0x0080FFFF,
    f = 0x8000FFFF,
    g = 0x00FFFFFF,
    h = 0xFF00FFFF,
}

-- functions
    function hex(v)
        return ("0x%X"):format(v)
    end

    function map_col_to_index(tbl, col)
        local out = {}
        for i=1,#tbl do
            out[tbl[i][col]] = i
        end
        return out
    end

    function list_column(tbl, col)
        local out = {}
        for i=1,#tbl do
            out[i] = tbl[i][col]
        end
        return out
    end

    function get_mappings(OPS)
        local argfield_map = map_col_to_index(OPS, 1)
        local template_map = map_col_to_index(OPS, 2)
        local name_map = {}
        for i=#OPS,1,-1 do
            local template = OPS[i][2]
            name_map[template:match("[^%s{}]+"):sub(1,3)] = i
        end
        local func_map = {}
        local cases = {}
        for i=1,#OPS do
            local func = OPS[i][3]
            func_map[func] = func_map[func] or {}
            if not cases[OPS[i][1]:gsub("[^01]","0")] then
                table.insert(func_map[func], OPS[i][2])
                cases[OPS[i][1]:gsub("[^01]","0")] = true
            end
        end
        return argfield_map, template_map, name_map, func_map, cases
    end

    function arglist(s)
        local args = {}
        local i = 1
        for m in s:gmatch("[^%s,%[%]]+") do
            args[#args+1] = m:match("^[^{}]+")
            if m:match("{.-}") then
                for m2 in m:gmatch("{.-}") do
                    args[#args+1] = m2
                end
            end
            i = i + 1
        end
        return args
    end

    function bin(n, length)
        local s = ""
        local bit
        if not length then length = math.floor(math.log(n)/math.log(2)) + 1 end
        for i=1,length do
            bit, n = n % 2, math.floor(n/2)
            s = bit..s
        end
        return s
    end

    function clist(text, colormap)
        local colors = {}
        for p,c in pairs(colormap) do
            local s,e = 0,0
            repeat
                s,e = text:find(p,s,true)
                if s then
                    for i=s,e do colors[i] = c end
                    s = e+1
                end
            until not s or s > #text
        end
        return text, colors
    end

    function gui_color(x,y,text,clist)
        for i=1,#text do
            gui.text(x+(i-1)*4, y, text:sub(i,i), clist[i] or 0xFFFFFFFF)
        end
    end

    function gui_color2(x,y,text)
        local pos = 1
        local color = 0xFFFFFFFF
        for s, m, e in text:gmatch("()%%c{(.-)}()") do
            gui.text(x, y, text:sub(pos, s-1), color)
            color = tonumber(m)
            x = x + 4*(s-pos)
            pos = e
        end
        gui.text(x, y, text:sub(pos), color)
    end
--

while true do
    if mode_toggle.clicked then
        if mode_toggle.active then
            dis, asm, OPS, FMAP = dis_t, asm_t, OPS_T, THUMB_DASM.FMAP
            category_box.text = table.concat(list_column(OPS_T,2),"\n")
        else
            dis, asm, OPS, FMAP = dis_a, asm_a, OPS_A, ARM_DASM.FMAP
            category_box.text = table.concat(list_column(OPS_A,2),"\n")
        end
        argfield_map, template_map, name_map, func_map, cases = get_mappings(OPS)
    end
    if mode_toggle.active then
        gui.text(mode_toggle.x + mode_toggle.w + 2, mode_toggle.y, "THM")
    else
        gui.text(mode_toggle.x + mode_toggle.w + 2, mode_toggle.y, "ARM")
    end

    if b_box.text:match("[^01]") then b_box.text = b_box.text:gsub("[^01]","0") end
    if not h_box.selected and h_box.text == "" then h_box.text = ("0"):rep(8) end
    if not b_box.selected and b_box.text == "" then b_box.text = ("0"):rep(32) end
    if not t_box.selected or inputs.keydown["enter"] then t_box.text = dis(tonumber(h_box.text,16) or 0) end

    if #h_box.text > 8 then h_box.text = h_box.text:sub(1,8) end
    if #b_box.text > 32 then b_box.text = b_box.text:sub(1,32) end
    if h_box.selected then
        b_box.cursor[1] = h_box.cursor[1]*4
        b_box.cursor2[1] = h_box.cursor2[1]*4
        b_box.selected = h_box.selected
        b_box.flash = h_box.flash
    end

    if h_box.selected and h_box.text:match("^%x+$") then
        local e,n = pcall(function() return tonumber(h_box.text,16) end)
        if e and type(n)=="number" then
            b_box.text = bin(n,32)
            t_box.text = dis(n)
        end
    elseif template_box.selected then
        if template_map[template_box.text] then
            local node = nav_bin_tree(tonumber(b_box.text,2), FMAP)
            if node[2] ~= template_box.text then
                local n = tonumber(OPS[template_map[template_box.text]][1]:gsub("[^01]","0"), 2)
                b_box.text = bin(n,32)
                t_box.text = dis(n)
                h_box.text = ("%08X"):format(n)
            end
        end
    elseif b_box.selected and b_box.text:match("^[a-h01]+$") then
        local e,n = pcall(function() return tonumber(b_box.text:gsub("[^01]","0"),2) end)
        if e and type(n)=="number" then
            h_box.text = ("%08X"):format(n)
            t_box.text = dis(n)
        end
    elseif t_box.selected then
        local e,n = pcall(function() return asm(t_box.text) end)
        local g1 = t_box.text:match("[^%s{}]*"):sub(1,3)
        local g2 = nav_bin_tree(tonumber(b_box.text, 2), FMAP)
        if g2 then g2 = g2[2]:match("[^%s{}]*"):sub(1,3) end
        if e and n ~= "undefined" then
            h_box.text = ("%08X"):format(n)
            b_box.text = bin(n,32)
        elseif name_map[g1] and g1~=g2 then
            n = tonumber(OPS[name_map[g1]][1]:gsub("[^01]","0"),2)
            h_box.text = ("%08X"):format(n)
            b_box.text = bin(n,32)
        end
    end

    local bits = tonumber(b_box.text, 2)
    local node = nav_bin_tree(bits or 0, FMAP)
    if node then
        if not category_box.title_box then category_box.title = node[3] end
        local t1, c1 = clist(("0"):rep(32-#node[1])..node[1], colors)
        b_box.clist = {c1}
        local cmap = {}
        local args = arglist(node[2])
        for i=2,#args do cmap[args[i]] = colors[string.char(0x60+i-1)] end
        local t2, c2 = clist(node[2], cmap)
        if not template_box.selected then
            template_box.text, template_box.clist = t2, {c2}
        end
    end

    if inputs["control"] then
        local i = category_box.inputbox
        if i.hover then i.selected = i.selected or 1 end
        if i.clicked and inputs.keys["control"] then       
            local line = i.lines[i.cursor[2]]
            if template_map[line] then
                b_box.text = OPS[template_map[line]][1]:gsub("[^01]","0")
                h_box.text = ("%08X"):format(tonumber(b_box.text,2))
                t_box.text = dis(tonumber(b_box.text,2))
            end
        end
        i.flash = 30
        if i.hover and i.y_hover >= i.yview and i.y_hover <= i.yview+i.charheight+1 then
            i:set_highlight({0,i.y_hover}, {#i.lines[i.y_hover], i.y_hover})
        end
    end

    emu.frameadvance()
end