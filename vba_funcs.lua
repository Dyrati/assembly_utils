AND = function (a,b) return a & b end
OR = function (a,b) return a | b end
XOR = function (a,b) return a ~ b end
ROR = function(a,b) return (a >> b | a << 32-b) & 0xFFFFFFFF end
SHIFT = function (a,b) return a >> b end
local function normalize(n) return (n & 0xFFFFFFFF ~ 0x80000000) - 0x80000000 end
bit = {
    band = function(a,b) return a & b end,
    bor = function(a,b) return a | b end,
    bnot = function(a) return ~a end,
    bxor = function(a,b) return a ~ b end,
    ror = function(a,b) return normalize(a >> b | a << 32-b) end,
    rol = function(a,b) return normalize(a << b | a >> 32-b) end,
    lshift = function(a,b) return normalize(a & 0xFFFFFFFF << b) end,
    rshift = function(a,b) return normalize(a & 0xFFFFFFFF >> b) end,
    arshift = function(a,b) return a >> b end,
    tobit = function(a) return normalize(a) end,
    tohex = function(a,n) return ("%%0%dx"):format(n or 8):format(a) end
}

unpack = table.unpack
copytable = function(t)
        local out = {}
        for k,v in pairs(t) do out[k] = v end
        return out
    end