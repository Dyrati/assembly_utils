require "asm"

-- tables

    THM = {i_size=2, asm=asm_t}
    do
        function THM.dis(addr)
            local i = r32(addr)
            if i & 0xF800F800 ~= 0xF800F000 then
                i = i & 0xFFFF
            end
            return dis_t(i, addr), i
        end

        function THM.start_check(addr)
            return r16(addr) & 0xFF00 == 0xB500
        end

        function THM.end_check(addr)
            local i1 = r16(addr)
            if i1 == 0x4770 or i1 & 0xFF00 == 0xBD00 then -- bx lr or pop {pc}
                return true
            elseif i1 & 0xFF87 == 0x4700 then -- pop {rs}; bx rs
                local reg = (i1 >> 3) & 0xF
                local i2 = r16(addr-2)
                if i2 & 0xFF00 == 0xBC00 and (i2 & 2^reg ~= 0) then
                    return true
                end
            else
                return false
            end
        end

        function THM.branch_check(addr)
            local i = r16(addr)
            if i & 0xF000 == 0xD000 then
                return addr + signed(i & 0xFF, 8)*2 + 4
            elseif i & 0xF800 == 0xE000 then
                return addr + signed(i & 0x7FF, 11)*2 + 4
            end
        end

        function THM.bl_check(addr)
            return r32(addr) & 0xF800F800 == 0xF800F000
        end

        function THM.func_check(addr)
            local i = r32(addr)
            if i & 0xF800F800 == 0xF800F000 then
                local lower, upper = (i >> 16) & 0x7FF, i & 0x7FF
                return addr + signed(upper << 11 | lower, 22)*2 + 4
            end
        end

        function THM.read(addr)
            if THM.bl_check(addr) then
                return r32(addr)
            else
                return r16(addr)
            end
        end

        function THM.get_command(bits,pc)
            local node = nav_bin_tree(bits, THUMB_DASM.FMAP)
            if node==nil then return end
            if node.case then node = node[AND(bits, node.case)] or node end
            return THUMB_DASM[node[3]](bits, pc or 0)
        end

        function THM.mode_swap(addr)
            local i1 = r16(addr)
            if i1 & 0xFF87 == 0x4778 then -- bx pc
                return true
            elseif i1 & 0xF800 == 0xA000 then -- add Rd, pc, nn
                local i2 = r16(addr+2)
                if i2 & 0xFF87 == 0x4700 and (i1 >> 8) & 0xF == (i2 >> 3) & 0xF then -- bx Rs
                    return true
                end
            end
            return false
        end

        function THM.read_check(addr)
            local i = r16(addr)
            if i & 0xF800 == 0x4800 then
                return (addr & ~2) + 4*(i & 0xFF) + 4
            end
        end

        function THM.chain_branch(addr)
            addr = THM.bl_target(addr)
            if not addr then return {} end
            local chain = {addr}
            while r32(addr) == 0x47204C00 do
                addr = r32(addr + 4) & ~1
                chain[#chain+1] = addr
            end
            return chain
        end

        function THM.bl_target(addr)
            local i = r32(addr)
            if (i & 0xF800F800) ~= 0xF800F000 then return end
            local upper, lower = i & 0x7FF, (i >> 0x10) & 0x7FF
            return addr + 2*signed(upper*2^11 + lower, 22) + 4
        end

        function THM.data_range(addr)
            local datarange = range()
            while addr < datarange[1] and not THM.end_check(addr) do
                datarange:add(THM.read_check(addr))
                addr = addr + 2
            end
            if datarange[1] <= datarange[2] then
                datarange:add(datarange[2]+2)
            end
            return datarange
        end

        function THM.iter(s,e)
            local function inner()
                if s > e then return end
                local addr = s
                local i = r16(s)
                if i & 0xF800 == 0xF000 and THM.bl_check(s) then
                    s = s + 2
                end
                s = s + 2
                return addr, i
            end
            return inner
        end
        
        function THM.stack_trace(maxdepth)
            local sp, lr, pc = R[13], R[14], R[15]-2
            local stack = setmetatable({}, {__index=function(t,k) return emu:read32(k) end})
            local trace = {}
            local data_range = THM.data_range(pc)
            while true do
                local i = r16(pc)
                local end_check = THM.end_check(pc)
                pc = pc + 2
                if pc >= data_range[1] then
                    pc = data_range[2] + 2
                    data_range=THM.data_range(pc)
                end
                if i == 0x4770 then -- bx lr
                    pc = lr
                elseif i & 0xFF87 == 0x4700 then -- pop {rx}; bx rx
                    local reg = (i >> 3) & 0xF
                    local i2 = r16(pc-4)
                    if i2 & 0xFF00 == 0xBC00 and (i2 & 2^reg ~= 0) then
                        pc = stack[sp-4]
                    end
                elseif i & 0xFF00 == 0xB000 then -- add sp, nn
                    sp = sp + (i & 0x7F)*4*((i >> 7) & 1 == 1 and -1 or 1)
                elseif i & 0xFE00 == 0xB400 then -- push {rlist}
                    sp = sp - 4*count_setbits(i & 0x1FF)
                    if i & 0x100 ~= 0 then
                        stack[sp] = lr
                    end
                elseif i & 0xFE00 == 0xBC00 then -- pop {rlist}
                    sp = sp + 4*count_setbits(i & 0x1FF)
                    if i & 0x100 ~= 0 then
                        pc = stack[sp-4]
                    end
                end
                if end_check then
                    local arm = pc & 1 == 0
                    pc = pc & ~1
                    if arm then break end
                    local s,e = fbounds(pc)
                    trace[#trace+1] = {s, pc-4}
                    data_range = THM.data_range(pc)
                end
                if maxdepth and #trace >= maxdepth then break end
            end
            return trace
        end
    end

    ARM = {i_size=4, asm=asm_a}
    do
        function ARM.dis(addr)
            local i = r32(addr)
            return dis_a(i, addr), i
        end

        function ARM.start_check(addr)
            local i = r32(addr)
            return i == 0x02004778 or i & 0x0F3F4000 == 0x092D4000
        end

        function ARM.end_check(addr)
            local i = r32(addr)
            return i == 0xE12FFF1E or i & 0x0FBF8000 == 0x08BD8000 -- bx lr or pop {pc}
        end

        function ARM.branch_check(addr)
            local i = r32(addr)
            if i & 0x0F000000 == 0x0A000000 then
                return addr + signed(i & 0xFFFFFF,24)*4 + 8
            end
        end

        function ARM.bl_check(addr)
            return r32(addr) & 0x0F000000 == 0x0B000000
        end

        function ARM.func_check(addr)
            local i = r32(addr)
            if i & 0x0F000000 == 0x0B000000 then
                return signed(i & 0xFFFFFF, 24)*4 + 8
            end
        end

        function ARM.read(addr)
            return r32(addr)
        end
        
        function ARM.mode_swap(addr)
            local i1 = r32(addr)
            if i1 & 0xFFEF0FFF == 0xE28F0001 then  -- add rd, pc, 1
                local i2 = r32(addr + 4)
                if i2 & 0xFFFFFFF0 == 0xE12FFF10 and i2 & 0xF == (i1 >> 12) & 0xF then  -- bx rd
                    return true
                end
            end
            return false
        end

        function ARM.read_check(addr)
            local i = r32(addr)
            if i & 0x0F1F0000 == 0x051F0000 then
                local value = i & 0xFFF
                if i & 2^23 == 0 then value = - value end
                return addr + 8 + value
            elseif i & 0x0F7F00F0 == 0x015F00B0 then
                local value = (i >> 4 & 0xF0) + (i & 0xF)
                if i & 2^23 == 0 then value = - value end
                return addr + 8 + value
            end
        end

        function ARM.chain_branch(addr)
        end

        function ARM.bl_target(addr)
            local i = r32(addr)
            return addr + 4*signed(i & 0xFFFFFF, 24) + 8
        end

        function ARM.data_range(addr)
            local datarange = range()
            while not ARM.end_check(addr) do
                datarange:add(ARM.read_check(addr))
                addr = addr + 4
            end
            return datarange
        end

        function ARM.iter(s,e)
            local function inner()
                while s <= e do
                    local addr = s
                    local i = r32(s)
                    s = s + 4
                    return addr, i
                end
            end
            return inner
        end
    end

    GAME = {
        update = function(self)
            local title = read_ascii(0x080000A0,12)
            if self.game_title ~= title then
                self.game_title = title
                self.game_code = read_ascii(0x080000AC, 4)
                self.dest_language = self.game_code:sub(4,4)
                self.version = self.game_title:sub(12,12)
                if self.game_title == "Golden_Sun_A" then
                    self.tilepntr = 0x020301B8
                    self.eventpntr = 0x02030010
                    self.mapaddr = 0x02000400
                    self.pc_data_pntr = 0x02030014
                    self.docs = read_docs("[GS1] Golden Sun 1_ The Broken Seal Documentation.txt")
                elseif self.game_title == "GOLDEN_SUN_B" then
                    self.tilepntr = 0x020301A4
                    self.eventpntr = 0x02030010
                    self.mapaddr = 0x02000420
                    self.pc_data_pntr = 0x03000014
                    self.layerpntr = 0x03000020
                    self.docs = read_docs("[GS2] Golden Sun 2_ The Lost Age Documentation.txt")
                end
            end
        end
    }

    R = setmetatable(
        {
            tb = console:createBuffer("Registers"),
            names = {"r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","sp","lr","pc","cpsr"},
            enabled = true,
            update = function(self) tb_text(self.tb, 0, 0, reg_format(self)) end,
        },
        {
            __index = function(t,k) return emu:readRegister(t.names[k+1]) end,
            __newindex = function(t,k,v) emu:writeRegister(t.names[k+1],v) end,
        }
    )

    mem_regions = {
        [0x0] = "bios",
        [0x2] = "wram",
        [0x3] = "iwram",
        [0x4] = "io",
        [0x5] = "palette",
        [0x6] = "vram",
        [0x7] = "oam",
        [0x8] = "cart0",
        [0xA] = "cart1",
        [0xC] = "cart2",
    }

    modes = {
        [0]=ARM,
        [1]=THM,
    }

    docs = {}

    ascii_map = {}
    for i=0,255 do ascii_map[string.char(i)] = ("\\x%02x"):format(i) end
    for i=7,13 do ascii_map[string.char(i)] = "\\"..("abtnvfr"):sub(i-6,i-6) end

--

-- general functions

    function get_stack_level()
        local level = 0
        repeat
            level = level + 1
            local info = debug.getinfo(level)
        until not info
        return level-1
    end

    function print_decorator(func)
        local function inner(...)
            local output = func(...)
            if get_stack_level() == 3 then
                print(output)
            end
            return output
        end
        return inner
    end

    function r32(addr) -- handles reading from misaligned addresses and BIOS reading
        local domain = addr & 0x0F000000 ~= 0 and emu or emu.memory.bios
        if addr & 2 ~= 0 then
            return domain:read16(addr+2) * 0x10000 | domain:read16(addr)
        else
            return domain:read32(addr)
        end
    end

    function r16(addr)
        local domain = addr & 0x0F000000 ~= 0 and emu or emu.memory.bios
        return domain:read16(addr)
    end

    function r8(addr)
        local domain = addr & 0x0F000000 ~= 0 and emu or emu.memory.bios
        return domain:read8(addr)
    end
    
    function read_ascii(addr, length)
        local s = ""
        for i=addr, addr+length-1 do
            s = s..string.char(r8(i))
        end
        return s
    end

    function zip(...)
        local arg = {...}
        local i = 1
        local function inner()
            local t = {}
            for j,tbl in ipairs(arg) do
                if tbl[i] == nil then return end
                t[j] = tbl[i]
            end
            i = i + 1
            return table.unpack(t)
        end
        return inner
    end

    function swap_key_value(tbl)
        local out = {}
        for k,v in pairs(tbl) do
            out[v] = k
        end
        return out
    end
    
    function sort_and_get_index_map(tbl, comp) -- return mapping of pre-sorted IDs to post-sorted IDs
        comp = comp or function(a,b) return a < b end
        local sorted = {}
        for i,v in ipairs(tbl) do
            sorted[i] = i
        end
        table.sort(sorted, function(a,b) return comp(tbl[a],tbl[b]) end)
        return swap_key_value(sorted)
    end

    function i_format(addr, mode, docs)
        mode = mode or R[16] >> 5 & 1
        local m = mode == 1 and THM or ARM
        local dis, value = m.dis(addr)
        local v = value >= 0x10000 and ("%08X"):format(value) or ("%04X"):format(value)
        local info = ""
        local read_addr = m.read_check(addr)
        if read_addr then
            local read_value = r32(read_addr)
            info = (" =%08X"):format(read_value)
            if docs and GAME.docs[read_value & ~1] then
                info = info.." // "..GAME.docs[read_value & ~1]
            end
        end
        local chain = m.chain_branch(addr)
        for i=2,#chain do
            info = info..(" ->$ $%08X"):format(chain[i])
        end
        if docs and m.bl_check(addr) then
            local target = chain and chain[#chain] or m.bl_target(addr)
            if GAME.docs[target] then
                info = info.." // "..GAME.docs[target]:match("[^\n]*")
            end
        end
        return ("%08X: %-8s  %s%s"):format(addr, v, dis, info)
    end

    function reg_format(reg)
        local lines = {}
        local cpsr = reg[16]
        local flags = ""
        for k,v in zip({"N","Z","C","V","I","F","T"},{31,30,29,28,7,6,5}) do
            if (cpsr >> v) & 1 == 0 then k = "-" end
            flags = flags..k
        end
        local mode = (cpsr >> 5) & 1
        local m = mode == 1 and THM or ARM
        local addr = reg[15] - 2*m.i_size
        if mode == 1 and m.bl_check(addr-2) then
            addr = addr - 2
        end
        lines[#lines+1] = i_format(addr, mode)
        for y=0,3 do
            local row = {}
            for x=0,3 do
                local r = 4*y+x
                row[#row+1] = ("%3s: %08x"):format("r"..r, reg[r] & 0xFFFFFFFF)
            end
            lines[#lines+1] = table.concat(row,"  ")
        end
        lines[#lines+1] = ("cpsr: %08X [%s]"):format(cpsr & 0xFFFFFFFF, flags)
        lines[#lines+1] = i_format(reg[15]-m.i_size, mode)
        return table.concat(lines,"\n")
    end

    function tb_text(tb,x,y,s)
        x,y = x or 0, y or 0
        s = tostring(s)
        tb:clear()
        for line in (s.."\n"):gmatch("(.-)\n") do
            tb:moveCursor(x,y)
            tb:print(line)
            y = y + 1
        end
    end

    function repr(var, depth, indent) -- return a printable representation of var
        depth = depth or 0
        indent = (" "):rep(indent or 2)
        local path = {len=0}
        local key_format, value_format, parent_format
        function parent_format(var)
            if path.len - path[var] > 1 then
                return "table:parent^"..(path.len - path[var])
            else
                return "table:parent"
            end
        end
        function key_format(var)
            if type(var) == "string" then
                var = var:gsub('"','\\"'):gsub("[^ %g]",ascii_map)
                return var:match("^[%a_][%w_]*$") and var or ('["%s"]'):format(var)
            else
                var = path[var] and parent_format(var) or value_format(var)
                return ("[%s]"):format(var)
            end
        end
        function value_format(var)
            if type(var) == "string" then
                return ('"%s"'):format(var:gsub('"','\\"'):gsub("[^ %g]",ascii_map))
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

    function pprint(var,depth)
        console:log(repr(var, depth))
    end

    function print(...)
        local arg = {...}
        for i=1,#arg do
            if type(arg[i]) == "table" then
                arg[i] = repr(arg[i])
            else
                arg[i] = tostring(arg[i])
            end
        end
        console:log(table.concat(arg, " "))
    end

    function hex(value)
        return ("%X"):format(value)
    end

    function range()
        local out = {math.huge, -math.huge}
        function out:add(n)
            if not n then return end
            if n < self[1] then self[1] = n end
            if n > self[2] then self[2] = n end
        end
        return out
    end

    function instruction_iter(addr,m)
        m = m or guess_mode(addr)
        local data_range = range()
        local function inner()
            local init_addr = addr
            local value
            local d
            if m == 1 and not THM.bl_check(addr) then
                addr = addr + 2
            else
                addr = addr + 4
            end
            local read_addr = modes[m].read_check(init_addr)
            if read_addr and read_addr <= data_range[1] and m==1 and r16(read_addr-2) == 0 then -- check aligned pools
                data_range:add(read_addr-2)
            end
            data_range:add(read_addr)
            if addr == data_range[1] then
                addr = data_range[2] + 4
                d = data_range
                data_range = range()
            end
            if modes[m].mode_swap(init_addr) then
                m = m ~ 1
                if m == 0 and addr & 2 ~= 0 then addr = addr + 2 end
            end
            return init_addr, m, d
        end
        return inner
    end

    function guess_mode(addr)
        for i=1,0x400 do
            if not nav_bin_tree(r16(addr), THUMB_DASM.FMAP) or r16(addr) & 0xF800 == 0xE800 then
                return 0
            elseif addr & 2 == 0 then
                if not nav_bin_tree(r32(addr), ARM_DASM.FMAP) or r32(addr) & 0x0E000010 == 0x06000010 then
                    return 1
                end
            end
            addr = addr + 2
        end
        return 0
    end

    function fbounds(addr, m)
        addr = addr or emu:readRegister("pc")
        m = m or guess_mode(addr)
        local s,e = addr, addr
        while not modes[m].end_check(e) do
            e = e + modes[m].i_size
        end
        if e == addr then s = s - modes[m].i_size end
        local endcount = 0
        while not modes[m].start_check(s) and s & 0xFFFFFF ~= 0 and endcount < 2 do
            if modes[m].end_check(s) then endcount = endcount + 1 end
            s = s - modes[m].i_size
        end
        local datarange = range()
        if endcount >= 1 then
            s = s + 2*modes[m].i_size
            while not modes[m].end_check(s) do
                datarange:add(modes[m].read_check(s))
                if s == datarange[1] then
                    s = datarange[2] + 4
                    datarange = range()
                end
                s = s + modes[m].i_size
                if modes[m].mode_swap(s) then modes[m] = modes[m] == THM and ARM or THM end
            end
            if datarange[2] >= datarange[1] then
                s = datarange[2] + 4
            else
                repeat s = s + modes[m].i_size until modes[m].read(s) ~= 0
            end
        end
        return s, e
    end

    function dis_f(addr, m, docs)
        addr = addr or emu:readRegister("pc")
        m = m or guess_mode(addr)
        local lines = {}
        local addresses = {}
        local s,e = fbounds(addr,m)
        for addr,m in instruction_iter(s,m) do
            lines[#lines+1] = i_format(addr,m,docs)
            addresses[addr] = #lines
            local branch = modes[m].branch_check(addr)
            if addresses[branch] then
                for i=addresses[branch],#lines do
                    lines[i] = "    "..lines[i]
                end
            end
            if addr == e then break end
        end
        return table.concat(lines, "\n")
    end

    function dis(addr, count, m)
        addr = addr or emu:readRegister("pc")
        m = m or guess_mode(addr)
        local lines = {}
        local iter = instruction_iter(addr,m)
        for i=1,count do
            table.insert(lines, i_format(iter()))
        end
        return table.concat(lines, "\n")
    end

    function count_setbits(n,size)
        local count = 0
        while n > 0 do
            if n & 1 ~= 0 then count = count + 1 end
            n = n >> 1
        end
        return count
    end

    function stack_trace(maxdepth)
        local m = (emu:readRegister("cpsr") >> 5) & 1
        local trace = modes[m].stack_trace(maxdepth)
        for i=#trace,1,-1 do
            print(hex(trace[i][1]), hex(trace[i][2]))
        end
    end

    function fprint(addr, docs, indent)
        addr = addr or emu:readRegister("pc")
        indent = ("    "):rep(indent or 0)
        local text = dis_f(addr, nil, docs)
        addr = tonumber(text:match("%x+"),16)
        local lines = {indent..("function %08X()"):format(addr)}
        if docs and GAME.docs[addr] then lines[1] = lines[1].." // "..GAME.docs[addr] end
        for line in text:gmatch("[^\n]+") do
            lines[#lines+1] = "    "..indent..line
        end
        lines[#lines+1] = indent.."end"
        return table.concat(lines, "\n")
    end

    function farmips(addr, docs, relative, indent) -- format a function to assemble with ARMIPS
        addr = addr or emu:readRegister("pc")
        m = m or guess_mode(addr)
        indent = indent or 0
        local addresses = {}
        local addr_to_index = {}
        local bl_list = {}
        local bl_found = {}
        local branches = {}
        local branches_found = {}
        local s,e = fbounds(addr,m)
        for a,m,d in instruction_iter(s,m) do
            addresses[#addresses+1] = {indent=0}
            addr_to_index[a] = #addresses
            local disasm_text = modes[m].dis(a)
            disasm_text = disasm_text:gsub("%$","0x")
            local bl_match = disasm_text:match("bl 0x(%x*)")
            if bl_match then
                if relative then
                    local n = tonumber(bl_match,16)
                    if not bl_found[n] then
                        bl_found[n] = true
                        bl_list[#bl_list+1] = n
                    end
                    disasm_text = "bl @@_"..bl_match
                end
                if docs then
                    local chain = modes[m].chain_branch(a)
                    if #chain > 1 then disasm_text = disasm_text.." //" end
                    for i=2,#chain do
                        disasm_text = disasm_text..(" -> $%08X"):format(chain[i])
                    end
                    if GAME.docs[chain[#chain]] then
                        disasm_text = disasm_text.." // "..GAME.docs[chain[#chain]]
                    end
                end
            end
            local b,des = disasm_text:match("^(b%a?%a?) 0x(%x*)")
            if des and not disasm_text:match("blx?h? ") then
                des = tonumber(des,16)
                if not branches_found[des] then
                    branches[#branches+1] = des
                    branches_found[des] = #branches
                end
                disasm_text = b
                addresses[#addresses].branch = branches_found[des]
            end
            local read_addr = modes[m].read_check(a)
            if read_addr then
                local read_value = r32(read_addr)
                disasm_text = disasm_text:gsub("%[0x%x*%]",("=0x%08X"):format(read_value))
                if docs and GAME.docs[read_value & ~1] then
                    disasm_text = disasm_text.." // "..GAME.docs[read_value & ~1]
                end
            end
            addresses[#addresses].text = disasm_text
            local branch = modes[m].branch_check(a)
            if addr_to_index[branch] then
                for i=addr_to_index[branch],#addresses do
                    addresses[i].indent = addresses[i].indent + 1
                end
            end
            if d then
                addresses[#addresses].pool = true
            end
            if a == e then break end
        end
        for i,a in ipairs(branches) do -- add labels
            addresses[addr_to_index[a]].label = i
        end
        local branch_id_to_label_id = sort_and_get_index_map(branches)
        local lines = {("    "):rep(indent)..("_%08X:"):format(addr)}
        if docs and GAME.docs[addr] then
            lines[1] = lines[1].." // "..GAME.docs[addr]
        end
        for i,addr_info in ipairs(addresses) do
            local spaces = ("    "):rep(addr_info.indent)
            if addr_info.label then
                lines[#lines+1] = spaces.."@@LBL_"..branch_id_to_label_id[addr_info.label]..":"
            end
            lines[#lines+1] = spaces..addr_info.text
            if addr_info.branch then
                lines[#lines] = lines[#lines].." @@LBL_"..branch_id_to_label_id[addr_info.branch]
            end
            if addr_info.pool then
                lines[#lines+1] = spaces..".pool"
            end
        end
        if relative and #bl_list > 0 then
            lines[#lines+1] = ""
            for i,f in ipairs(bl_list) do
                lines[#lines+1] = ("@@_%08X:"):format(f)
                if docs and GAME.docs[f] then
                    lines[#lines] = lines[#lines].." // "..GAME.docs[f]
                end
                lines[#lines+1] = ("    ldr r4, =0x%08X"):format(f+1)
                lines[#lines+1] = ("    bx r4")
                lines[#lines+1] = ("    .pool")
            end
        end
        return table.concat(lines,"\n"..("    "):rep(indent+1))
    end

    function current_folder()
        return debug.getinfo(1).source:match("@?(.*)[\092/]")
    end

    function read_docs(filename)
        filename = filename or "[GS2] Golden Sun 2_ The Lost Age Documentation.txt"
        local folder = current_folder()
        local fmap = {}
        for line in io.lines(folder.."/"..filename) do
            local addr, desc = line:match("^%s*("..("%x"):rep(8)..")%s*=%s*([^\n]-)%s*$")
            if addr then
                fmap[tonumber(addr,16)] = desc
            end
        end
        return fmap
    end

--

-- main loop
    GAME:update()

    for _,f in ipairs{"hex", "dis", "dis_f", "mem", "fprint", "farmips"} do
        _G[f] = print_decorator(_G[f])
    end

    function main()
        GAME:update()
        R:update()
    end

    callbacks:add("frame", main)
--