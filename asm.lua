-- info from: https://www.akkit.org/info/gbatek.htm

if not vba then require "vba_funcs" end

-- Global tables

    OPS_A = {
        {"aaaa000100101111111111110001bbbb", "bx{cond} Rn",                               "BX",},
        {"aaaa000100101111111111110011bbbb", "blx{cond} Rn",                              "BX",},
        {"aaaa1010bbbbbbbbbbbbbbbbbbbbbbbb", "b{cond} label",                             "BL",},
        {"aaaa1011bbbbbbbbbbbbbbbbbbbbbbbb", "bl{cond} label",                            "BL",},
        {"aaaa0000000bddddccccgggggff0eeee", "and{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000000bddddcccc00000000eeee", "and{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000000bddddccccgggg0ff1eeee", "and{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010000bddddcccceeeeeeeeeeee", "and{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000001bddddccccgggggff0eeee", "eor{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000001bddddcccc00000000eeee", "eor{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000001bddddccccgggg0ff1eeee", "eor{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010001bddddcccceeeeeeeeeeee", "eor{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000010bddddccccgggggff0eeee", "sub{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000010bddddcccc00000000eeee", "sub{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000010bddddccccgggg0ff1eeee", "sub{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010010bddddcccceeeeeeeeeeee", "sub{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000011bddddccccgggggff0eeee", "rsb{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000011bddddcccc00000000eeee", "rsb{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000011bddddccccgggg0ff1eeee", "rsb{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010011bddddcccceeeeeeeeeeee", "rsb{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000100bddddccccgggggff0eeee", "add{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000100bddddcccc00000000eeee", "add{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000100bddddccccgggg0ff1eeee", "add{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010100bddddcccceeeeeeeeeeee", "add{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000101bddddccccgggggff0eeee", "adc{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000101bddddcccc00000000eeee", "adc{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000101bddddccccgggg0ff1eeee", "adc{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010101bddddcccceeeeeeeeeeee", "adc{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000110bddddccccgggggff0eeee", "sbc{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000110bddddcccc00000000eeee", "sbc{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000110bddddccccgggg0ff1eeee", "sbc{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010110bddddcccceeeeeeeeeeee", "sbc{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0000111bddddccccgggggff0eeee", "rsc{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0000111bddddcccc00000000eeee", "rsc{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0000111bddddccccgggg0ff1eeee", "rsc{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0010111bddddcccceeeeeeeeeeee", "rsc{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa00010001bbbb0000eeeeedd0cccc", "tst{cond} Rn, Rm, shift nn",                "DataProc",},
        {"aaaa00010001bbbb000000000000cccc", "tst{cond} Rn, Rm",                          "DataProc",},
        {"aaaa00010001bbbb0000eeee0dd1cccc", "tst{cond} Rn, Rm, shift Rs",                "DataProc",},
        {"aaaa00110001bbbb0000cccccccccccc", "tst{cond} Rn, nn",                          "DataProc",},
        {"aaaa00010011bbbb0000eeeeedd0cccc", "teq{cond} Rn, Rm, shift nn",                "DataProc",},
        {"aaaa00010011bbbb000000000000cccc", "teq{cond} Rn, Rm",                          "DataProc",},
        {"aaaa00010011bbbb0000eeee0dd1cccc", "teq{cond} Rn, Rm, shift Rs",                "DataProc",},
        {"aaaa00110011bbbb0000cccccccccccc", "teq{cond} Rn, nn",                          "DataProc",},
        {"aaaa00010101bbbb0000eeeeedd0cccc", "cmp{cond} Rn, Rm, shift nn",                "DataProc",},
        {"aaaa00010101bbbb000000000000cccc", "cmp{cond} Rn, Rm",                          "DataProc",},
        {"aaaa00010101bbbb0000eeee0dd1cccc", "cmp{cond} Rn, Rm, shift Rs",                "DataProc",},
        {"aaaa00110101bbbb0000cccccccccccc", "cmp{cond} Rn, nn",                          "DataProc",},
        {"aaaa00010111bbbb0000eeeeedd0cccc", "cmn{cond} Rn, Rm, shift nn",                "DataProc",},
        {"aaaa00010111bbbb000000000000cccc", "cmn{cond} Rn, Rm",                          "DataProc",},
        {"aaaa00010111bbbb0000eeee0dd1cccc", "cmn{cond} Rn, Rm, shift Rs",                "DataProc",},
        {"aaaa00110111bbbb0000cccccccccccc", "cmn{cond} Rn, nn",                          "DataProc",},
        {"aaaa0001100bddddccccgggggff0eeee", "orr{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0001100bddddcccc00000000eeee", "orr{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0001100bddddccccgggg0ff1eeee", "orr{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0011100bddddcccceeeeeeeeeeee", "orr{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0001101b0000ccccfffffee0dddd", "mov{cond}{s} Rd, Rm, shift nn",             "DataProc",},
        {"aaaa0001101b0000cccc00000000dddd", "mov{cond}{s} Rd, Rm",                       "DataProc",},
        {"11100001101000000000000000000000", "nop",                                       "DataProc",},
        {"aaaa0001101b0000ccccffff0ee1dddd", "mov{cond}{s} Rd, Rm, shift Rs",             "DataProc",},
        {"aaaa0011101b0000ccccdddddddddddd", "mov{cond}{s} Rd, nn",                       "DataProc",},
        {"aaaa0001110bddddccccgggggff0eeee", "bic{cond}{s} Rd, Rn, Rm, shift nn",         "DataProc",},
        {"aaaa0001110bddddcccc00000000eeee", "bic{cond}{s} Rd, Rn, Rm",                   "DataProc",},
        {"aaaa0001110bddddccccgggg0ff1eeee", "bic{cond}{s} Rd, Rn, Rm, shift Rs",         "DataProc",},
        {"aaaa0011110bddddcccceeeeeeeeeeee", "bic{cond}{s} Rd, Rn, nn",                   "DataProc",},
        {"aaaa0001111b0000ccccfffffee0dddd", "mvn{cond}{s} Rd, Rm, shift nn",             "DataProc",},
        {"aaaa0001111b0000cccc00000000dddd", "mvn{cond}{s} Rd, Rm",                       "DataProc",},
        {"aaaa0001111b0000ccccffff0ee1dddd", "mvn{cond}{s} Rd, Rm, shift Rs",             "DataProc",},
        {"aaaa0011111b0000ccccdddddddddddd", "mvn{cond}{s} Rd, nn",                       "DataProc",},
        {"aaaa00010c001111bbbb000000000000", "mrs{cond} Rd, Psr",                         "PSR_Transfer",},
        {"aaaa00010b10cccc111100000000dddd", "msr{cond} Psr{_field}, Rm",                 "PSR_Transfer",},
        {"aaaa00110b10cccc1111dddddddddddd", "msr{cond} Psr{_field}, nn",                 "PSR_Transfer",},
        {"aaaa0000000bcccc0000eeee1001dddd", "mul{cond}{s} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa0000001bccccffffeeee1001dddd", "mla{cond}{s} Rd, Rm, Rs, Rn",               "Multiply",},
        {"aaaa0000100bddddccccffff1001eeee", "umull{cond}{s} RdLo, RdHi, Rm, Rs",         "Multiply",},
        {"aaaa0000101bddddccccffff1001eeee", "umlal{cond}{s} RdLo, RdHi, Rm, Rs",         "Multiply",},
        {"aaaa0000110bddddccccffff1001eeee", "smull{cond}{s} RdLo, RdHi, Rm, Rs",         "Multiply",},
        {"aaaa0000111bddddccccffff1001eeee", "smlal{cond}{s} RdLo, RdHi, Rm, Rs",         "Multiply",},
        {"aaaa00010000bbbbeeeedddd1000cccc", "smlabb{cond} Rd, Rm, Rs, Rn",               "Multiply",},
        {"aaaa00010000bbbbeeeedddd1010cccc", "smlatb{cond} Rd, Rm, Rs, Rn",               "Multiply",},
        {"aaaa00010000bbbbeeeedddd1100cccc", "smlabt{cond} Rd, Rm, Rs, Rn",               "Multiply",},
        {"aaaa00010000bbbbeeeedddd1110cccc", "smlatt{cond} Rd, Rm, Rs, Rn",               "Multiply",},
        {"aaaa00010010bbbb0000dddd1000cccc", "smlawb{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010010bbbb0000dddd1100cccc", "smlawt{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010010bbbb0000dddd1010cccc", "smulwb{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010010bbbb0000dddd1110cccc", "smulwt{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010100ccccbbbbeeee1000dddd", "smlalbb{cond} RdLo, RdHi, Rm, Rs",          "Multiply",},
        {"aaaa00010100ccccbbbbeeee1010dddd", "smlaltb{cond} RdLo, RdHi, Rm, Rs",          "Multiply",},
        {"aaaa00010100ccccbbbbeeee1100dddd", "smlalbt{cond} RdLo, RdHi, Rm, Rs",          "Multiply",},
        {"aaaa00010100ccccbbbbeeee1110dddd", "smlaltt{cond} RdLo, RdHi, Rm, Rs",          "Multiply",},
        {"aaaa00010110bbbb0000dddd1000cccc", "smulbb{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010110bbbb0000dddd1010cccc", "smultb{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010110bbbb0000dddd1100cccc", "smulbt{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa00010110bbbb0000dddd1110cccc", "smultt{cond} Rd, Rm, Rs",                   "Multiply",},
        {"aaaa0100fbc0eeeeddddffffffffffff", "str{cond}{b}{t} Rd, [Rn], nn",              "SingleDataTransfer",},
        {"aaaa0110fbc0eeeeddddhhhhhgg0ffff", "str{cond}{b}{t} Rd, [Rn], Rm shift nn",     "SingleDataTransfer",},
        {"aaaa0110fbc0eeeedddd00000000ffff", "str{cond}{b}{t} Rd, [Rn], Rm",              "SingleDataTransfer",},
        {"aaaa0101ebf0ddddcccceeeeeeeeeeee", "str{cond}{b} Rd, [Rn, nn]{!}",              "SingleDataTransfer",},
        {"aaaa0111ebh0ddddccccgggggff0eeee", "str{cond}{b} Rd, [Rn, Rm shift nn]{!}",     "SingleDataTransfer",},
        {"aaaa0111ebh0ddddcccc00000000eeee", "str{cond}{b} Rd, [Rn, Rm]{!}",              "SingleDataTransfer",},
        {"aaaa0100fbc1eeeeddddffffffffffff", "ldr{cond}{b}{t} Rd, [Rn], nn",              "SingleDataTransfer",},
        {"aaaa0110fbc1eeeeddddhhhhhgg0ffff", "ldr{cond}{b}{t} Rd, [Rn], Rm shift nn",     "SingleDataTransfer",},
        {"aaaa0110fbc1eeeedddd00000000ffff", "ldr{cond}{b}{t} Rd, [Rn], Rm",              "SingleDataTransfer",},
        {"aaaa0101ebf1ddddcccceeeeeeeeeeee", "ldr{cond}{b} Rd, [Rn, nn]{!}",              "SingleDataTransfer",},
        {"aaaa0111ebh1ddddccccgggggff0eeee", "ldr{cond}{b} Rd, [Rn, Rm shift nn]{!}",     "SingleDataTransfer",},
        {"aaaa0111ebh1ddddcccc00000000eeee", "ldr{cond}{b} Rd, [Rn, Rm]{!}",              "SingleDataTransfer",},
        {"aaaa0000d000ccccbbbb00001011dddd", "str{cond}h Rd, [Rn], Rm",                   "OtherDataTransfer",},
        {"aaaa0000d100ccccbbbbdddd1011dddd", "str{cond}h Rd, [Rn], nn",                   "OtherDataTransfer",},
        {"aaaa0001d0e0ccccbbbb00001011dddd", "str{cond}h Rd, [Rn, Rm]{!}",                "OtherDataTransfer",},
        {"aaaa0001d1e0ccccbbbbdddd1011dddd", "str{cond}h Rd, [Rn, nn]{!}",                "OtherDataTransfer",},
        {"aaaa0000d000ccccbbbb00001101dddd", "ldr{cond}d Rd, [Rn], Rm",                   "OtherDataTransfer",},
        {"aaaa0000d100ccccbbbbdddd1101dddd", "ldr{cond}d Rd, [Rn], nn",                   "OtherDataTransfer",},
        {"aaaa0001d0e0ccccbbbb00001101dddd", "ldr{cond}d Rd, [Rn, Rm]{!}",                "OtherDataTransfer",},
        {"aaaa0001d1e0ccccbbbbdddd1101dddd", "ldr{cond}d Rd, [Rn, nn]{!}",                "OtherDataTransfer",},
        {"aaaa0000d000ccccbbbb00001111dddd", "str{cond}d Rd, [Rn], Rm",                   "OtherDataTransfer",},
        {"aaaa0000d100ccccbbbbdddd1111dddd", "str{cond}d Rd, [Rn], nn",                   "OtherDataTransfer",},
        {"aaaa0001d0e0ccccbbbb00001111dddd", "str{cond}d Rd, [Rn, Rm]{!}",                "OtherDataTransfer",},
        {"aaaa0001d1e0ccccbbbbdddd1111dddd", "str{cond}d Rd, [Rn, nn]{!}",                "OtherDataTransfer",},
        {"aaaa0000d001ccccbbbb00001011dddd", "ldr{cond}h Rd, [Rn], Rm",                   "OtherDataTransfer",},
        {"aaaa0000d101ccccbbbbdddd1011dddd", "ldr{cond}h Rd, [Rn], nn",                   "OtherDataTransfer",},
        {"aaaa0001d0e1ccccbbbb00001011dddd", "ldr{cond}h Rd, [Rn, Rm]{!}",                "OtherDataTransfer",},
        {"aaaa0001d1e1ccccbbbbdddd1011dddd", "ldr{cond}h Rd, [Rn, nn]{!}",                "OtherDataTransfer",},
        {"aaaa0000d001ccccbbbb00001101dddd", "ldr{cond}sb Rd, [Rn], Rm",                  "OtherDataTransfer",},
        {"aaaa0000d101ccccbbbbdddd1101dddd", "ldr{cond}sb Rd, [Rn], nn",                  "OtherDataTransfer",},
        {"aaaa0001d0e1ccccbbbb00001101dddd", "ldr{cond}sb Rd, [Rn, Rm]{!}",               "OtherDataTransfer",},
        {"aaaa0001d1e1ccccbbbbdddd1101dddd", "ldr{cond}sb Rd, [Rn, nn]{!}",               "OtherDataTransfer",},
        {"aaaa0000d001ccccbbbb00001111dddd", "ldr{cond}sh Rd, [Rn], Rm",                  "OtherDataTransfer",},
        {"aaaa0000d101ccccbbbbdddd1111dddd", "ldr{cond}sh Rd, [Rn], nn",                  "OtherDataTransfer",},
        {"aaaa0001d0e1ccccbbbb00001111dddd", "ldr{cond}sh Rd, [Rn, Rm]{!}",               "OtherDataTransfer",},
        {"aaaa0001d1e1ccccbbbbdddd1111dddd", "ldr{cond}sh Rd, [Rn, nn]{!}",               "OtherDataTransfer",},
        {"aaaa100bbfd0cccceeeeeeeeeeeeeeee", "stm{cond}{amod} Rn{!}, {Rlist}{^}",         "BlockDataTransfer",},
        {"aaaa100bbfd1cccceeeeeeeeeeeeeeee", "ldm{cond}{amod} Rn{!}, {Rlist}{^}",         "BlockDataTransfer",},
        {"aaaa00010b00eeeecccc00001001dddd", "swp{cond}{b} Rd, Rm, [Rn]",                 "SWP",},
        {"aaaa1111bbbbbbbbbbbbbbbbbbbbbbbb", "swi{cond} nn",                              "SWI",},
        {"111000010010aaaaaaaaaaaa0111aaaa", "bkpt nn",                                   "BKPT",},
        {"aaaa1110cccceeeeddddbbbbggg0ffff", "cdp{cond} Pn, <cpopc>, Cd, Cn, Cm{, <cp>}", "CDP",},
        {"11111110cccceeeeddddbbbbggg0ffff", "cdp2 Pn, <cpocp>, Cd, Cn, Cm{, <cp>}",      "CDP",},
        {"aaaa1100fb10eeeeddddccccffffffff", "stc{cond}{l} Pn, Cd, [Rn], nn",             "CoprocessorDataTransfer",},
        {"aaaa1100fb11eeeeddddccccffffffff", "ldc{cond}{l} Pn, Cd, [Rn], nn",             "CoprocessorDataTransfer",},
        {"aaaa1101fbg0eeeeddddccccffffffff", "stc{cond}{l} Pn, Cd, [Rn, nn]{!}",          "CoprocessorDataTransfer",},
        {"aaaa1101fbg1eeeeddddccccffffffff", "ldc{cond}{l} Pn, Cd, [Rn, nn]{!}",          "CoprocessorDataTransfer",},
        {"11111100ea10ddddccccbbbbeeeeeeee", "stc2{l} Pn, Cd, [Rn], nn",                  "CoprocessorDataTransfer",},
        {"11111100ea11ddddccccbbbbeeeeeeee", "ldc2{l} Pn, Cd, [Rn], nn",                  "CoprocessorDataTransfer",},
        {"11111101eaf0ddddccccbbbbeeeeeeee", "stc2{l} Pn, Cd, [Rn, nn]{!}",               "CoprocessorDataTransfer",},
        {"11111101eaf1ddddccccbbbbeeeeeeee", "ldc2{l} Pn, Cd, [Rn, nn]{!}",               "CoprocessorDataTransfer",},
        {"aaaa1110ccc0eeeeddddbbbbggg1ffff", "mcr{cond} Pn, <cpopc>, Rd, Cn, Cm{, <cp>}", "CoprocessorRegisterTransfer",},
        {"aaaa1110ccc1eeeeddddbbbbggg1ffff", "mrc{cond} Pn, <cpopc>, Rd, Cn, Cm{, <cp>}", "CoprocessorRegisterTransfer",},
        {"11111110bbb0ddddccccaaaafff1eeee", "mcr2 Pn, <cpopc>, Rd, Cn, Cm{, <cp>}",      "CoprocessorRegisterTransfer",},
        {"11111110bbb1ddddccccaaaafff1eeee", "mrc2 Pn, <cpopc>, Rd, Cn, Cm{, <cp>}",      "CoprocessorRegisterTransfer",},
        {"aaaa11000100eeeeddddbbbbccccffff", "mcrr{cond} Pn, opcode, Rd, Rn, Cm",         "CoprocessorDoubleRegTransfer",},
        {"aaaa11000101eeeeddddbbbbccccffff", "mrrc{cond} Pn, opcode, Rd, Rn, Cm",         "CoprocessorDoubleRegTransfer",},
        {"aaaa000101101111bbbb11110001cccc", "clz{cond} Rd, Rm",                          "CLZ",},
        {"xxxx011xxxxxxxxxxxxxxxxxxxx1xxxx", "undefined",                                 "undefined",},
        {"aaaa00010000ddddbbbb00000101cccc", "qadd{cond} Rd, Rm, Rn",                     "QAddSub",},
        {"aaaa00010010ddddbbbb00000101cccc", "qsub{cond} Rd, Rm, Rn",                     "QAddSub",},
        {"aaaa00010100ddddbbbb00000101cccc", "qdadd{cond} Rd, Rm, Rn",                    "QAddSub",},
        {"aaaa00010110ddddbbbb00000101cccc", "qdsub{cond} Rd, Rm, Rn",                    "QAddSub",},
    }

    OPS_T = {
        {"00000cccccbbbaaa", "lsl Rd, Rs, #Offset",       "ShiftReg"},
        {"00001cccccbbbaaa", "lsr Rd, Rs, #Offset",       "ShiftReg"},
        {"00010cccccbbbaaa", "asr Rd, Rs, #Offset",       "ShiftReg"},
        {"0001100cccbbbaaa", "add Rd, Rs, Rn",            "AddSub1"},
        {"0001101cccbbbaaa", "sub Rd, Rs, Rn",            "AddSub1"},
        {"0001110cccbbbaaa", "add Rd, Rs, #nn",           "AddSub2"},
        {"0001110000bbbaaa", "mov Rd, Rs",                "AddSub2"},
        {"0001111cccbbbaaa", "sub Rd, Rs, #nn",           "AddSub2"},
        {"00100aaabbbbbbbb", "mov Rd, #nn",               "Imm"},
        {"00101aaabbbbbbbb", "cmp Rd, #nn",               "Imm"},
        {"00110aaabbbbbbbb", "add Rd, #nn",               "Imm"},
        {"00111aaabbbbbbbb", "sub Rd, #nn",               "Imm"},
        {"0100000000bbbaaa", "and Rd, Rs",                "ALU"},
        {"0100000001bbbaaa", "eor Rd, Rs",                "ALU"},
        {"0100000010bbbaaa", "lsl Rd, Rs",                "ALU"},
        {"0100000011bbbaaa", "lsr Rd, Rs",                "ALU"},
        {"0100000100bbbaaa", "asr Rd, Rs",                "ALU"},
        {"0100000101bbbaaa", "adc Rd, Rs",                "ALU"},
        {"0100000110bbbaaa", "sbc Rd, Rs",                "ALU"},
        {"0100000111bbbaaa", "ror Rd, Rs",                "ALU"},
        {"0100001000bbbaaa", "tst Rd, Rs",                "ALU"},
        {"0100001001bbbaaa", "neg Rd, Rs",                "ALU"},
        {"0100001010bbbaaa", "cmp Rd, Rs",                "ALU"},
        {"0100001011bbbaaa", "cmn Rd, Rs",                "ALU"},
        {"0100001100bbbaaa", "orr Rd, Rs",                "ALU"},
        {"0100001101bbbaaa", "mul Rd, Rs",                "ALU"},
        {"0100001110bbbaaa", "bic Rd, Rs",                "ALU"},
        {"0100001111bbbaaa", "mvn Rd, Rs",                "ALU"},
        {"01000100abbbbaaa", "add Rd, Rs",                "HiReg"},
        {"01000101abbbbaaa", "cmp Rd, Rs",                "HiReg"},
        {"01000110abbbbaaa", "mov Rd, Rs",                "HiReg"},
        {"0100011011000000", "nop",                       "HiReg"},
        {"010001110aaaa000", "bx Rs",                     "HiReg"},
        {"010001111aaaa000", "blx Rs",                    "HiReg"},
        {"01001aaabbbbbbbb", "ldr Rd, [PC, #nn]",         "LdrPC"},
        {"0101000cccbbbaaa", "str Rd, [Rb, Ro]",          "LdrStr"},
        {"0101010cccbbbaaa", "strb Rd, [Rb, Ro]",         "LdrStr"},
        {"0101100cccbbbaaa", "ldr Rd, [Rb, Ro]",          "LdrStr"},
        {"0101110cccbbbaaa", "ldrb Rd, [Rb, Ro]",         "LdrStr"},
        {"0101001cccbbbaaa", "strh Rd, [Rb, Ro]",         "LdrStrSH"},
        {"0101011cccbbbaaa", "ldsb Rd, [Rb, Ro]",         "LdrStrSH"},
        {"0101101cccbbbaaa", "ldrh Rd, [Rb, Ro]",         "LdrStrSH"},
        {"0101111cccbbbaaa", "ldsh Rd, [Rb, Ro]",         "LdrStrSH"},
        {"01100cccccbbbaaa", "str Rd, [Rb, #nn]",         "LdrStrIMM"},
        {"01101cccccbbbaaa", "ldr Rd, [Rb, #nn]",         "LdrStrIMM"},
        {"01110cccccbbbaaa", "strb Rd, [Rb, #nn]",        "LdrStrIMM"},
        {"01111cccccbbbaaa", "ldrb Rd, [Rb, #nn]",        "LdrStrIMM"},
        {"10000cccccbbbaaa", "strh Rd, [Rb, #nn]",        "LdrStrH"},
        {"10001cccccbbbaaa", "ldrh Rd, [Rb, #nn]",        "LdrStrH"},
        {"10010aaabbbbbbbb", "str Rd, [SP, #nn]",         "LdrStrSP"},
        {"10011aaabbbbbbbb", "ldr Rd, [SP, #nn]",         "LdrStrSP"},
        {"10100aaabbbbbbbb", "add Rd, PC, #nn",           "GetRelAddr"},
        {"10101aaabbbbbbbb", "add Rd, SP, #nn",           "GetRelAddr"},
        {"101100000aaaaaaa", "add SP, #nn",               "AddSP"},
        {"101100001aaaaaaa", "add SP, #-nn",              "AddSP"},
        {"1011010baaaaaaaa", "push {Rlist}{LR}",          "PushPop"},
        {"1011110baaaaaaaa", "pop {Rlist}{PC}",           "PushPop"},
        {"11000aaabbbbbbbb", "stmia Rb!, {Rlist}",        "StmLdm"},
        {"11001aaabbbbbbbb", "ldmia Rb!, {Rlist}",        "StmLdm"},
        {"11010000aaaaaaaa", "beq label",                 "BCond"},
        {"11010001aaaaaaaa", "bne label",                 "BCond"},
        {"11010010aaaaaaaa", "bcs label",                 "BCond"},
        {"11010011aaaaaaaa", "bcc label",                 "BCond"},
        {"11010100aaaaaaaa", "bmi label",                 "BCond"},
        {"11010101aaaaaaaa", "bpl label",                 "BCond"},
        {"11010110aaaaaaaa", "bvs label",                 "BCond"},
        {"11010111aaaaaaaa", "bvc label",                 "BCond"},
        {"11011000aaaaaaaa", "bhi label",                 "BCond"},
        {"11011001aaaaaaaa", "bls label",                 "BCond"},
        {"11011010aaaaaaaa", "bge label",                 "BCond"},
        {"11011011aaaaaaaa", "blt label",                 "BCond"},
        {"11011100aaaaaaaa", "bgt label",                 "BCond"},
        {"11011101aaaaaaaa", "ble label",                 "BCond"},
        {"11011111aaaaaaaa", "swi nn",                    "SWI"},
        {"10111110aaaaaaaa", "bkpt nn",                   "SWI"},
        {"11100aaaaaaaaaaa", "b label",                   "Branch"},
        {"11111aaaaaaaaaaa", "blh label",                 "BL"},
        {"11101aaaaaaaaaaa", "blxh label",                "BL"},
        {"11110aaaaaaaaaaa", "bl",                        "BL"},
        {"11111aaaaaaaaaaa11110aaaaaaaaaaa", "bl label",  "BL"},
        {"11101aaaaaaaaaaa11110aaaaaaaaaaa", "blx label", "BL"},
    }

    ARGS_A = {
        BX = {
            {"cond","Op","Rn"}, {31,28}, {7,4}, {3,0}},
        BL = {
            {"cond","Op","nn","pc"}, {31,28}, 24, {23,0}},
        DataProc = {
            {"cond","I","Op","S","Rn","Rd","Is1","shift","R","Rm","Rs","Is2","nn"},
            {31,28},25,{24,21},20,{19,16},{15,12},{11,7},{6,5},4,{3,0},{11,8},{11,8},{7,0}},
        PSR_Transfer = {
            {"cond","I","Psr","Op","f","s","x","c","Rd","Is","Imm","Rm"},
            {31,28},25,22,21,19,18,17,16,{15,12},{11,8},{7,0},{3,0}},
        Multiply = {
            {"cond","Op","S","Rd","Rn","Rs","y","x","Rm"},
            {31,28},{24,21},20,{19,16},{15,12},{11,8},6,5,{3,0}},
        SingleDataTransfer = {
            {"cond","I","P","U","B","T","W","L","Rn","Rd","Imm","Is","shift","Rm","pc"},
            {31,28},25,24,23,22,21,21,20,{19,16},{15,12},{11,0},{11,7},{6,5},{3,0}},
        OtherDataTransfer = {
            {"cond","P","U","I","W","L","Rn","Rd","Imm1","Op","Rm","Imm2"},
            {31,28},24,23,22,21,20,{19,16},{15,12},{11,8},{6,5},{3,0},{3,0}},
        BlockDataTransfer = {
            {"cond","amod","S","W","L","Rn","Rlist"},
            {31,28},{24,23},22,21,20,{19,16},{15,0}},
        SWP = {
            {"cond","B","Rn","Rd","Rm"},
            {31,28},22,{19,16},{15,12},{3,0}},
        SWI = {
            {"cond","nn"}, {31,28},{23,0}},
        BKPT = {
            {"cond","nn1","nn2"}, {31,28},{19,8},{3,0}},
        CDP = {
            {"cond","CP_Opc","Cn","Cd","Pn","CP","Cm"},
            {31,28},{23,20},{19,16},{15,12},{11,8},{7,5},{3,0}},
        CoprocessorDataTransfer = {
            {"cond","P","U","N","W","Op","Rn","Cd","Pn","nn"},
            {31,28},24,23,22,21,20,{19,16},{15,12},{11,8},{7,0}},
        CoprocessorRegisterTransfer = {
            {"cond","CP_Opc","Op","Cn","Rd","Pn","CP","Cm"},
            {31,28},{23,21},20,{19,16},{15,12},{11,8},{7,5},{3,0}},
        CoprocessorDoubleRegTransfer = {
            {"cond","L","Rn","Rd","Pn","CP_Opc","Cm"},
            {31,28},20,{19,16},{15,12},{11,8},{7,4},{3,0}},
        undefined = {{}},
        CLZ = {
            {"cond","Rd","Rm"},{31,28},{15,12},{3,0}},
        QAddSub = {
            {"cond","Op","Rn","Rd","Rm"},{31,28},{23,20},{19,16},{15,12},{3,0}},
    }

    ARGS_T = {
        ShiftReg = {
            {"Op","Offset","Rs","Rd"},{12,11},{10,6},{5,3},{2,0}},
        AddSub1 = {
            {"Op","Rn","Rs","Rd"},9,{8,6},{5,3},{2,0}},
        AddSub2 = {
            {"Op","nn","Rs","Rd"},9,{8,6},{5,3},{2,0}},
        Imm = {
            {"Op","Rd","nn"},{12,11},{10,8},{7,0}},
        ALU = {
            {"Op","Rs","Rd"},{9,6},{5,3},{2,0}},
        HiReg = {
            {"Op","MSBd","MSBs","Rs","Rd"},{9,8},7,6,{5,3},{2,0}},
        LdrPC = {
            {"Rd","nn","pc"},{10,8},{7,0}},
        LdrStr = {
            {"Op","Ro","Rb","Rd"},{11,10},{8,6},{5,3},{2,0}},
        LdrStrSH = {
            {"Op","Ro","Rb","Rd"},{11,10},{8,6},{5,3},{2,0}},
        LdrStrIMM = {
            {"Op","nn","Rb","Rd"},{12,11},{10,6},{5,3},{2,0}},
        LdrStrH = {
            {"Op","nn","Rb","Rd"},11,{10,6},{5,3},{2,0}},
        LdrStrSP = {
            {"Op","Rd","nn"},11,{10,8},{7,0}},
        GetRelAddr = {
            {"Op","Rd","nn"},11,{10,8},{7,0}},
        AddSP = {
            {"Op","nn"},7,{6,0}},
        PushPop = {
            {"Op","PCLR","Rlist"},11,8,{7,0}},
        StmLdm = {
            {"Op","Rb","Rlist"},11,{10,8},{7,0}},
        BCond = {
            {"Op","Offset","pc"},{11,8},{7,0}},
        SWI = {
            {"Op","nn"},{15,8},{7,0}},
        Branch = {
            {"Offset","pc"},{10,0}},
        BL = {
            {"Op1","upper","Op2","lower","pc"},{15,11},{10,0},{31,27},{26,16}},
    }

    SUFFIXES = {"eq","ne","cs","cc","mi","pl","vs","vc","hi","ls","ge","lt","gt","le","al","nv"}
    REGISTERS = {"r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","sp","lr","pc"}
    SFX_ID = {hs=2, lo=3, [""]=14}
    REG_ID = {sb=9,sl=10,fp=11,ip=12,sp=13,lr=14,pc=15}
    for i=0,15 do
        SFX_ID[SUFFIXES[i+1]] = i
        REG_ID["r"..i] = i
    end

--

-- Global Functions
    function find(value,...)
        local arg = {...}
        for k,v in ipairs(arg) do
            if v==value then return k-1 end
        end
    end

    function index(tbl,...)
        local arg = {...}
        for i=1,#arg do arg[i] = tbl[arg[i]+1] end
        return unpack(arg)
    end

    function setbits(b,...)
        local arg = {...}
        for i=1,#arg,2 do b = OR(b, arg[i+1]*2^arg[i]) end
        return b
    end

    function sel(v,...)
        return ({...})[v+1]
    end

    function bsub(v,shift,size)
        return AND(SHIFT(v,shift),2^(size or 1)-1)
    end

    if not ROR then
        function ROR(v,shift) return OR(SHIFT(v, shift-32), SHIFT(v,shift)) end
    end

    function signed(v,size)
        v = AND(v,2^size-1)
        local msb = SHIFT(1,1-size)
        return XOR(v,msb) - msb
    end

    function undefined()
        return "undefined"
    end

    function argsfrom(v,args,pc)
        local out = {}
        for i=2,#args do
            local r = args[i]
            if type(r)=="number" then
                out[#out+1] = AND(SHIFT(v, r), 1)
            else
                out[#out+1] = AND(SHIFT(v, r[2]), 2^(r[1]-r[2]+1)-1)
            end
        end
        if #args[1] > #out then out[#out+1] = pc end
        return unpack(out)
    end

    function mla64(a,b,c,d) -- multiply and accumulate 32-bit numbers; returns two 32-bit chunks (lower, upper)
        local afill, bfill = a<0 and 0xFFFF or 0, b<0 and 0xFFFF or 0
        a,b,c,d = {a % 0x10000, SHIFT(a,16)}, {b % 0x10000, SHIFT(b,16)}, c or 0, d or 0
        local n = {c % 0x10000, SHIFT(c,16), d % 0x10000, SHIFT(d,16)}
        for digit=1,4 do -- 16-bit
            for i=1,digit do
                n[digit] = n[digit] + (a[i] or afill)*(b[digit-i+1] or bfill)
            end
            n[digit], n[digit+1] = n[digit] % 0x10000, (n[digit+1] or 0) + math.floor(n[digit]/0x10000)
        end
        return n[1] + n[2]*0x10000, n[3] + n[4]*0x10000
    end

    function argfields(s)
        local alphabet = "abcdefghijklmnopqrstuvwxyz"
        local prev
        local fields = {tonumber(s:gsub("[^01]","0"),2)}
        for i=1,#s do
            local m = alphabet:find(s:sub(i,i))
            if m then
                if m ~= prev then table.insert(fields, {m}) end
                fields[#fields][2] = #s-i
                fields[#fields][3] = (fields[#fields][3] or 0) + 1
            end
            prev = m
        end
        return fields
    end

    function writefields(fields, ...)
        local arg = {...}
        local tbl = arg
        local out = fields[1]
        for index = #fields,2,-1 do
            local i,shift,size = unpack(fields[index])
            out = OR(out, SHIFT(AND(arg[i], 2^size-1),-shift))
            tbl[i] = SHIFT(arg[i], size)
        end
        return out
    end

    function readfields(fields, v)
        local out = {}
        for index=2,#fields do
            local i,shift,size = unpack(fields[index])
            out[i] = OR(SHIFT(out[i] or 0,-size), AND(SHIFT(v,shift), 2^size-1))
        end
        return unpack(out)
    end

    function read_rlist(s)
        local out, prev_n, prev_sep = 0, 0, ""
        for r,sep in s:gmatch("(%w+)([, -]*)") do
            local n = REG_ID[r]
            if prev_sep:match("-") then out = OR(out, SHIFT(1,-n-1)-SHIFT(1,-prev_n))
            else out = OR(out,SHIFT(1,-n)) end
            prev_n = n
            prev_sep = sep
        end
        return out
    end

    function write_rlist(v)
        local out = {}
        local consecutive = 0
        for i=0,15 do
            if AND(v,2^i)~=0 then
                local r = REGISTERS[i+1]
                local sep = ","
                if consecutive > 1 then table.remove(out); sep = "-" end
                table.insert(out, sep..r)
                consecutive = consecutive + 1
            else
                consecutive = 0
            end
        end
        return table.concat(out):sub(2)
    end

    function generate_bin_tree(op_map)
        local size = 0
        for k in pairs(op_map) do size = math.max(size, #k) end
        local bitmask = 2^size-1
        for bitpos=0,size-1 do -- bitmask = which bit positions have only 0s or 1s (not letters)
            for k in pairs(op_map) do
                if k:sub(-bitpos-1,-bitpos-1):match("[^01]") then
                    bitmask = XOR(bitmask, 2^bitpos)
                    break
                end
            end
        end
        local out = {}
        if bitmask ~= 0 then
            for op_string,v in pairs(op_map) do
                local value = AND(bitmask, tonumber(op_string:gsub("[^01]","0"),2)) -- value = bits & bitmask
                if not out[value] then out[value] = {} end
                op_string = op_string:gsub("()(.)", function(pos,bit)  -- replace bitmask positions with "x"
                    return AND(bitmask,2^(#op_string-pos)) ~= 0 and "x" or bit
                end)
                out[value][op_string] = v
            end
            for k,v in pairs(out) do out[k] = generate_bin_tree(v) end
            out.bitmask = bitmask
            return out
        else -- bitmask == 0 means either len(op_map)==1 or an op_string is a subset of another
            local out = {}
            local special_cases = {}
            for k,v in pairs(op_map) do
                if k:match("[01]") then
                    local bitmask = tonumber(k:gsub("[01]","1"):gsub("[^01]","0"),2)
                    local value = tonumber(k:gsub("[^01]","0"),2)
                    special_cases[{bitmask, value}] = v
                else
                    out = copytable(v)
                end
            end
            if next(special_cases) then out.special_cases = special_cases end
            return out
        end
    end

    function nav_bin_tree(bits, tree)
        repeat tree = tree[AND(bits,tree.bitmask)] until tree==nil or tree.bitmask == nil
        if tree and tree.special_cases then
            for case, node in pairs(tree.special_cases) do
                if AND(bits, case[1]) == case[2] then
                    tree = node; break
                end
            end
        end
        return tree
    end
--

-- Assemble/Disassemble instructions

    ARM_DASM = {}
    do
        local function cname(cond)
            local c = SUFFIXES[cond+1]
            if c == "al" then return "" else return c end
        end

        function ARM_DASM.BX(cond,Op,Rn)
            if Op==1 then Op = "bx" elseif Op==3 then Op = "blx" end
            return ("%s%s %s"):format(Op,cname(cond),index(REGISTERS,Rn))
        end

        function ARM_DASM.BL(cond,Op,nn,pc)
            return ("%s%s $%08X"):format(sel(Op,"b","bl"), cname(cond), pc + 8 + 4*signed(nn,24))
        end

        function ARM_DASM.DataProc(cond,I,Op,S,Rn,Rd,Is1,shift,R,Rm,Rs,Is2,nn)
            local name = sel(Op,"and","eor","sub","rsb","add","adc","sbc","rsc","tst","teq","cmp","cmn","orr","mov","bic","mvn")
            Rn, Rd, Rs, Rm = index(REGISTERS, Rn, Rd, Rs, Rm)
            local word = name..cname(cond)
            S = sel(S,"","s")
            local Op2
            if I==1 then
                Op2 = ("#0x%x"):format(ROR(nn, 2*Is2))
            elseif R==1 then
                Op2 = ("%s, %s %s"):format(Rm, sel(shift,"lsl","lsr","asr","ror"), Rs)
            else
                if Is1 == 0 then
                    Op2 = sel(shift,"lsl #0","lsr #32","asr #32","rrx")
                else
                    Op2 = sel(shift,"lsl","lsr","asr","ror").." #"..Is1
                end
                if Op2 == "lsl #0" then Op2 = Rm else Op2 = Rm..", "..Op2 end
            end
            if Op <= 7 or Op==12 or Op==14 then
                return ("%s %s, %s, %s"):format(word..S, Rd, Rn, Op2)
            elseif Op >=8 and Op <= 11 then
                return ("%s %s, %s"):format(word, Rn, Op2)
            else
                local s = ("%s %s, %s"):format(word..S, Rd, Op2)
                if s == "mov r0, r0" then return "nop" else return s end
            end
        end

        function ARM_DASM.PSR_Transfer(cond,I,Psr,Op,f,s,x,c,Rd,Is,Imm,Rm)
            Rd, Rm = index(REGISTERS, Rd, Rm)
            local word = sel(Op,"mrs","msr")..cname(cond)
            local Psr = sel(Psr,"cpsr","spsr")
            if Op == 0 then
                return ("%s %s, %s"):format(word, Rd, Psr)
            else
                local fields = "_"..sel(f,"","f")..sel(s,"","s")..sel(x,"","x")..sel(c,"","c")
                if fields == "_" then fields = "" end
                if I == 1 then
                    return ("%s %s%s, #0x%x"):format(word, Psr, fields, ROR(Imm, 2*Is))
                else
                    return ("%s %s%s, %s"):format(word, Psr, fields, Rm)
                end
            end
        end

        function ARM_DASM.Multiply(cond,Op,S,Rd,Rn,Rs,y,x,Rm)
            Rd,Rn,Rs,Rm = index(REGISTERS,Rd,Rn,Rs,Rm)
            local word = sel(Op,"mul","mla","","","umull","umlal","smull","smlal","smla","","smlal","smul")
            if Op == 9 then
                word = sel(x,"smlaw","smulw")..sel(y,"b","t")
            elseif Op >= 8 then
                word = word..sel(x,"b","t")..sel(y,"b","t")
            end
            word = word..cname(cond)
            if Op <= 7 then word = word..sel(S,"","s") end
            if Op==0 or (Op==9 and x==1) or Op==11 then
                return ("%s %s, %s, %s"):format(word, Rd, Rm, Rs)
            elseif Op==1 or Op==8 or (Op==9 and x==0) then
                return ("%s %s, %s, %s, %s"):format(word, Rd, Rm, Rs, Rn)
            else
                return ("%s %s, %s, %s, %s"):format(word, Rn, Rd, Rm, Rs)
            end
        end

        function ARM_DASM.SingleDataTransfer(cond,I,P,U,B,T,W,L,Rn,Rd,Imm,Is,shift,Rm,pc)
            Rn,Rd,Rm = index(REGISTERS,Rn,Rd,Rm)
            local word = sel(L,"str","ldr")..cname(cond)..sel(B,"","b")
            if P==0 then word = word..sel(T,"","t") end
            local offset
            if I==0 then
                offset = ("%s#0x%x"):format(sel(U,"-",""),Imm)
            else
                local s = sel(shift,"lsl","lsr","asr","ror").." #"..Is
                if Is==0 then s = sel(shift,"lsl #0","lsr #32","asr #32","rrx") end
                offset = ("%s%s, %s"):format(sel(U,"-",""),Rm,s)
                if s == "lsl #0" then offset = sel(U,"-","")..Rm end
            end
            if L==1 and pc>0 and Rn=="pc" then
                local addr = pc + Imm*sel(U,-1,1) + 8
                return ("%s %s, [$%08X]"):format(word, Rd, addr)
            elseif P==0 then
                return ("%s %s, [%s], %s"):format(word, Rd, Rn, offset)
            else
                return ("%s %s, [%s, %s]%s"):format(word, Rd, Rn, offset, sel(W,"","!"))
            end
        end

        function ARM_DASM.OtherDataTransfer(cond,P,U,I,W,L,Rn,Rd,Imm1,Op,Rm,Imm2)
            Rn,Rd,Rm = index(REGISTERS,Rn,Rd,Rm)
            Op = 4*L+Op
            local word = "ldr"
            if Op==1 or Op==3 then word = "str" end
            word = word..cname(cond)..sel(Op,"","h","d","d","","h","sb","sh")
            local offset = ("%s%s"):format(sel(U,"-",""),Rm)
            if I==1 then offset = ("%s#0x%x"):format(sel(U,"-",""),OR(SHIFT(Imm1,-4),Imm2)) end
            if P==0 then
                return ("%s %s, [%s], %s"):format(word, Rd, Rn, offset)
            else
                return ("%s %s, [%s, %s]%s"):format(word, Rd, Rn, offset, sel(W,"","!"))
            end
        end

        function ARM_DASM.BlockDataTransfer(cond,amod,S,W,L,Rn,Rlist)
            local word = sel(L,"stm","ldm")..cname(cond)..sel(amod,"da","ia","db","ib")
            return ("%s %s%s, {%s}%s"):format(word, index(REGISTERS,Rn), sel(W,"","!"), write_rlist(Rlist), sel(S,"","^"))
        end

        function ARM_DASM.SWP(cond,B,Rn,Rd,Rm)
            return ("swp%s%s %s, %s, [%s]"):format(cname(cond),sel(B,"","b"),index(REGISTERS,Rd,Rm,Rn))
        end

        function ARM_DASM.SWI(cond,nn)
            return ("swi%s #0x%x"):format(cname(cond),nn)
        end

        function ARM_DASM.BKPT(cond,nn1,nn2)
            return ("bkpt%s #0x%x"):format(cname(cond),nn1*16 + nn2)
        end

        function ARM_DASM.CDP(cond,CP_Opc,Cn,Cd,Pn,CP,Cm)
            local name = cond ~= 0xF and "cdp"..cname(cond) or "cdp2"
            CP = CP==0 and "" or ", "..CP
            return ("%s p%d, %d, c%d, c%d, c%d%s"):format(name,Pn,CP_Opc,Cd,Cn,Cm,CP)
        end

        function ARM_DASM.CoprocessorDataTransfer(cond,P,U,N,W,Op,Rn,Cd,Pn,nn)
            local name = sel(Op,"stc","ldc")..(cond ~= 0xF and cname(cond) or "2")..sel(N,"","l")
            local offset = ("%s#0x%x"):format(sel(U,"-",""),4*nn)
            if P==0 then
                return ("%s p%d, c%d, [%s], %s"):format(name,Pn,Cd,index(REGISTERS,Rn),offset)
            else
                return ("%s p%d, c%d, [%s, %s]%s"):format(name,Pn,Cd,index(REGISTERS,Rn),offset,sel(W,"","!"))
            end
        end

        function ARM_DASM.CoprocessorRegisterTransfer(cond,CP_Opc,Op,Cn,Rd,Pn,CP,Cm)
            local name = sel(Op,"mcr","mrc")..(cond ~= 0xF and cname(cond) or "2")
            CP = CP==0 and "" or ", "..CP
            return ("%s p%d, %d, %s, c%d, c%d%s"):format(name,Pn,CP_Opc,index(REGISTERS,Rd),Cn,Cm,CP)
        end

        function ARM_DASM.CoprocessorDoubleRegTransfer(cond,L,Rn,Rd,Pn,CP_Opc,Cm)
            local Rd,Rn = index(REGISTERS,Rd,Rn)
            return ("%s%s p%d, %d, %s, %s, c%d"):format(sel(L,"mcrr","mrrc"),cname(cond),Pn,CP_Opc,Rd,Rn,Cm)
        end

        function ARM_DASM.undefined()
            return "undefined"
        end

        function ARM_DASM.CLZ(cond,Rd,Rm)
            return ("clz%s %s, %s"):format(cname(cond),index(REGISTERS,Rd,Rm))
        end

        function ARM_DASM.QAddSub(cond,Op,Rn,Rd,Rm)
            local word = sel(SHIFT(Op,1),"qadd","qsub","qdadd","qdsub")
            return ("%s%s %s, %s, %s"):format(word,cname(cond),index(REGISTERS,Rd,Rm,Rn))
        end

        ARM_DASM.FMAP = {}
        for i,row in ipairs(OPS_A) do ARM_DASM.FMAP[row[1]] = row end
        ARM_DASM.FMAP = generate_bin_tree(ARM_DASM.FMAP)
    end

    ARM_ASM = {}
    do
        function ARM_ASM.BX(name, Rn, cond)
            return setbits(0x012FFF10, 28, cond, 5, find(name,"bx","blx"), 0, REG_ID[Rn])
        end

        function ARM_ASM.BL(name, label, cond, pc)
            local typ, nn = label:match("($?)([+-]?[x%x]+)")
            nn = typ=="$" and tonumber(nn,16) or tonumber(nn)
            return setbits(0x0A000000, 28, cond, 24, find(name,"b","bl"), 0, AND((nn-pc-8)/4, 2^24-1))
        end

        function ARM_ASM.DataProc(name, args, cond, S)
            local I,Op,Rn,Rd,Is1,Rs,shift,Rm,Is2,nn,Op2
            if name == "nop" then name, args, cond, S = "mov", "r0, r0", 0xE, 0 end
            Op = find(name,"and","eor","sub","rsb","add","adc","sbc","rsc","tst","teq","cmp","cmn","orr","mov","bic","mvn")
            if Op <= 7 or Op==12 or Op==14 then
                Rd,Rn,Op2 = args:match("(%w+)[, ]+(%w+)[, ]+(.*)")
            elseif Op==13 or Op==15 then
                Rd,Op2 = args:match("(%w+)[, ]+(.*)")
            else
                Rn,Op2 = args:match("(%w+)[, ]+(.*)")
                S = 1
            end
            Rd,Rn = REG_ID[Rd] or 0, REG_ID[Rn] or 0
            if Op2:match("^[x%x]+$") then
                Is2, nn = 0, tonumber(Op2)
                while Is2<16 and nn~=AND(nn,255) do nn = ROR(nn,30); Is2 = Is2 + 1 end
                I, Op2 = 1, setbits(0,8,Is2,0,nn)
            elseif Op2:match("%w+[, ]+%a%a%a[, ]-[x%x]*$") then
                Rm, shift, Is1 = Op2:match("(%w+)[, ]+(%a%a%a)[, ]-([x%x]*)$")
                Rm, shift = REG_ID[Rm], find(shift,"lsl","lsr","asr","ror") or 3
                Is1 = AND(Is1=="" and 0 or tonumber(Is1), 31)
                Op2 = setbits(0,7,Is1,5,shift,0,Rm)
            elseif Op2:match("%w+[, ]+%a%a%a[, ]+%w+") then
                Rm, shift, Rs = Op2:match("(%w+)[, ]+(%a%a%a)[, ]+(%w+)")
                Rm, shift, Rs = REG_ID[Rm], find(shift,"lsl","lsr","asr","ror") or 3, REG_ID[Rs]
                Op2 = setbits(0x10,8,Rs,5,shift,0,Rm)
            else
                Op2 = REG_ID[Op2:match("%w+")]
            end
            return setbits(0x00000000,28,cond,25,I or 0,21,Op,20,S or 0,16,Rn,12,Rd,0,Op2)
        end

        function ARM_ASM.PSR_Transfer(name, args, cond)
            local I,Psr,Op,f,s,x,c,Rd,Is,Imm,out
            Op = find(name, "mrs","msr")
            if Op==0 then
                Rd, Psr = args:match("(%w+)[, ]+(%a)psr")
                out = setbits(0x010F0000,28,cond,22,find(Psr,"c","s"),21,Op,12,REG_ID[Rd])
            else
                Psr,f,s,x,c,Op2 = args:match("(%a)psr_?(f?)(s?)(x?)(c?)[, ]-([^, ]*)$")
                Psr,f,s,x,c = find(Psr,"c","s"),find(f,"","f"),find(s,"","s"),find(x,"","x"),find(c,"","c")
                if Op2:match("^[x%x]+$") then
                    Is, Imm = 0, tonumber(Op2:match("([x%x]*)"))
                    while Is<16 and Imm~=AND(Imm,255) do Imm = ROR(Imm,30); Is = Is + 1 end
                    I, Op2 = 1, setbits(0,8,Is,0,Imm)
                else
                    I, Op2 = 0, REG_ID[Op2]
                end
                out = setbits(0x0120F000,28,cond,25,I,22,Psr,19,f,18,s,17,x,16,c,0,Op2)
            end
            return out
        end

        function ARM_ASM.Multiply(name, args, cond, S)
            local Op,Rd,Rn,Rs,y,x,Rm,out
            Op = find(name,"mul","mla","","","umull","umlal","smull","smlal")
            if not Op then
                name,x,y = name:match("^(%a-)([bt]?)([bt]?)$")
                Op = (find(name,"smla","smlaw","smlal","smul") or 1) + 8
            end
            if Op <= 7 then
                if Op <= 1 then Rd, Rm, Rs, Rn = args:match("^(%w+)[, ]+(%w+)[, ]+(%w+)[, ]-(%w*)$")
                else Rn, Rd, Rm, Rs = args:match("^(%w+)[, ]+(%w+)[, ]+(%w+)[, ]+(%w+)$") end
                out = setbits(0x00000090,28,cond,21,Op,20,S,16,REG_ID[Rd],12,REG_ID[Rn] or 0,8,REG_ID[Rs],0,REG_ID[Rm])
            else
                if Op ~= 10 then Rd, Rm, Rs, Rn = args:match("^(%w+)[, ]+(%w+)[, ]+(%w+)[, ]-(%w*)$")
                else Rn, Rd, Rm, Rs = args:match("^(%w+)[, ]+(%w+)[, ]+(%w+)[, ]+(%w+)$") end
                x,y = find(x,"b","t"),find(y,"b","t")
                if Op == 9 then x,y = find(name,"smlaw","smulw"),x end
                out = setbits(0x00000080,28,cond,21,Op,16,REG_ID[Rd],12,REG_ID[Rn] or 0,8,REG_ID[Rs],6,y,5,x,0,REG_ID[Rm])
            end
            return out
        end

        function ARM_ASM.SingleDataTransfer(name,args,cond,B,T)
            local I,P,U,W,L,Rn,Rd,Is,shift,Rm,Op2
            L = find(name,"str","ldr")
            if args:match("(.-)%b[]!?$") then
                Rd, Rn, U, Op2, W = args:match("^(%w+)[, ]+%[(%w+)[, ]+([+-]?)(.-)%](!?)$")
                if not Rd then Rd, Rn, W = args:match("^(%w+)[, ]+%[(%w+)%](!?)$"); U = 0 end
                P, T = 1, find(W,"","!")
            else
                Rd, Rn, U, Op2 = args:match("^(%w+)[, ]+%[(%w+)%][, ]+([+-]?)(.*)$")
                P, T = 0, T or 0
            end
            U = find(U,"-","")
            if not Op2 or Op2:match("^[x%x]+$") then
                I, Op2 = 0, tonumber(Op2 or 0)
            else
                Rm, shift, Is = Op2:match("^(%w+)[, ]+(%a%a%a)[, ]-([x%x]*)$")
                if not Rm then Rm, shift, Is = Op2:match("^(%w+)$"), "lsl", "0" end
                Rm, shift, Is = REG_ID[Rm], find(shift,"lsl","lsr","asr","ror") or 3, Is=="" and 0 or Is
                I, Op2 = 1, setbits(0,7,AND(Is,31),5,shift,0,Rm)
            end
            return setbits(0x04000000,28,cond,25,I,24,P,23,U,22,B,21,T,20,L,16,REG_ID[Rn],12,REG_ID[Rd],0,Op2)
        end

        function ARM_ASM.OtherDataTransfer(name,args,cond)
            local P,U,I,W,L,Rn,Rd,Imm1,Op,Rm,Imm2
            Op = find(name,"","strh","ldrd","strd","","ldrh","ldrsb","ldrsh")
            Op,L = Op % 4, Op <= 3 and 0 or 1
            if args:match("(.-)%b[]!?$") then
                Rd, Rn, U, Op2, W = args:match("^(%w+)[, ]+%[(%w+)[, ]+([+-]?)(.-)%](!?)$")
                if not Rd then Rd, Rn, W = args:match("^(%w+)[, ]+%[(%w+)%](!?)$"); U = 0 end
                P,W = 1, find(W,"","!")
            else
                Rd, Rn, U, Op2 = args:match("^(%w+)[, ]+%[(%w+)%][, ]+([+-]?)(.*)$")
                P,W = 0,0
            end
            U = find(U,"-","")
            if not Op2 or Op2:match("^[x%x]+$") then
                I, Op2 = 1, tonumber(Op2 or 0)
                Op2 = OR(SHIFT(SHIFT(Op2,4),-8), AND(Op2,15))
            else
                I, Op2 = 0, REG_ID[Op2]
            end
            return setbits(0x00000090,28,cond,24,P,23,U,22,I,21,W,20,L,16,REG_ID[Rn],12,REG_ID[Rd],5,Op,0,Op2)
        end

        function ARM_ASM.BlockDataTransfer(name,args,cond,amod)
            local S,W,Rn,Rlist
            L = find(name,"stm","ldm")
            Rn, W, Rlist, S = args:match("(%w*)(!?)[, ]+{(.*)}(^?)")
            Rn, W, Rlist, S = REG_ID[Rn], find(W,"","!"), read_rlist(Rlist), find(S,"","^")
            amod = amod <= 3 and amod or L==1 and amod-4 or 7-amod
            return setbits(0x08000000,28,cond,23,amod,22,S,21,W,20,L,16,Rn,0,Rlist)
        end

        function ARM_ASM.SWP(name,args,cond,B)
            local Rd, Rm, Rn = args:match("(%w+)[, ]+(%w+)[, ]+%[(%w+)%]")
            return setbits(0x01000090,28,cond,22,B,16,REG_ID[Rn],12,REG_ID[Rd],0,REG_ID[Rm])
        end

        function ARM_ASM.SWI(name,args,cond)
            args = tonumber(args:match("[x%x]+"))
            return setbits(0x0F000000,28,cond,0,args)
        end

        function ARM_ASM.BKPT(name,args)
            args = tonumber(args:match("[x%x]+"))
            return setbits(0xE1200070,0,OR(SHIFT(SHIFT(args,4),-8), AND(args,15)))
        end
        
        function ARM_ASM.CDP(name,args,cond)
            if name == "cdp2" then cond = 0xf end
            local Pn, CP_Opc, Cd, Cn, Cm, CP = args:match("p(%d+)[, ]+(%d+)[, ]+(%w+)[, ]+c(%d+)[, ]+c(%d+)[, ]*(%d*)")
            Cd = REG_ID[Cd] or Cd:sub(2)
            return setbits(0x0E000000,28,cond,20,CP_Opc,16,Cn,12,Cd,8,Pn,5,CP=="" and 0 or CP,0,Cm)
        end

        function ARM_ASM.CoprocessorDataTransfer(name, args, cond, N)
            local P,U,W,Op,Rn,Cd,Pn,nn
            if name:match("2") then N=cond; cond = 0xf end
            Op = name:match("stc") and 0 or 1
            P = args:match("%[[%w ]+,[^%]]+%]") == nil and 0 or 1
            if P==0 then
                Pn, Cd, Rn, U, nn = args:match("p(%d+)[, ]+(%w+)[, ]+%[(%w+)%][, ]+([+-]?)([x%x]+)")
                W = 1
            else
                Pn, Cd, Rn, U, nn, W = args:match("p(%d+)[, ]+(%w+)[, ]+%[(%w+)[, ]+([+-]?)([x%x]+)%](!?)")
                W = W=="!" and 1 or 0
            end
            U = U=="-" and 0 or 1
            Cd = REG_ID[Cd] or Cd:sub(2)
            nn = SHIFT(nn, 2)
            return setbits(0x0C000000,28,cond,24,P,23,U,22,N,21,W,20,Op,16,REG_ID[Rn],12,Cd,8,Pn,0,nn)
        end

        function ARM_ASM.CoprocessorRegisterTransfer(name, args, cond)
            local Pn, CP_Opc, Rd, Cn, Cm, CP = args:match("p(%d+)[, ]+(%d+)[, ]+(%w+)[, ]+c(%d+)[, ]+c(%d+)[, ]*(%d*)")
            if name:match("2") then cond = 0xf end
            Op = name:match("mcr") and 0 or 1
            return setbits(0x0E000010,28,cond,21,CP_Opc,20,Op,16,Cn,12,REG_ID[Rd],8,Pn,5,CP=="" and 0 or CP,0,Cm)
        end

        function ARM_ASM.CoprocessorDoubleRegTransfer(name, args, cond)
            local L = find(name,"mcrr","mrrc")
            local Pn, CP_Opc, Rd, Rn, Cm = args:match("p(%d+)[, ]+(%d+)[, ]+(%w+)[, ]+(%w+)[, ]+c(%d+)")
            return setbits(0x0C400000,28,cond,20,L,16,REG_ID[Rn],12,REG_ID[Rd],8,Pn,4,CP_Opc,0,Cm)
        end

        function ARM_ASM.undefined(name)
            return 0x06000010
        end

        function ARM_ASM.CLZ(name,args,cond)
            local Rd, Rm = args:match("(%w+)[, ]+(%w+)")
            return setbits(0x016F0F10,28,cond,12,REG_ID[Rd],0,REG_ID[Rm])
        end

        function ARM_ASM.QAddSub(name,args,cond)
            local Op = find(name,"qadd","qsub","qdadd","qdsub")
            local Rd, Rm, Rn = args:match("(%w+)[, ]+(%w+)[, ]+(%w+)")
            return setbits(0x01000050,28,cond,21,Op,16,REG_ID[Rn],12,REG_ID[Rd],0,REG_ID[Rm])
        end

        local function expand_keys(fmap)
            local out = {}
            local amod = {}
            for i,v in ipairs({"da","ia","db","ib","fa","fd","ea","ed"}) do amod[v] = i-1 end
            local replacements = {cond=SFX_ID, amod=amod}
            local function inner(key)
                local s,w,pos = key:match("^(.-){(.-)}()")
                if not(w) then return {[key]={}} end
                local out = {}
                for r,index in pairs(replacements[w] or {[""]=0,[w]=1}) do
                    for k, sublist in pairs(inner(key:sub(pos))) do
                        out[s..r..k] = {index, unpack(sublist)}
                    end
                end
                return out
            end
            for k,f in pairs(fmap) do
                local word = k:match("%S+")
                for key,path in pairs(inner(word)) do
                    out[key] = {f=f, name=word:gsub("%b{}",""), unpack(path)}
                end
            end
            return out
        end

        local function expand_fmap(fmap)
            local amod = {}
            for i,v in ipairs({"da","ia","db","ib","fa","fd","ea","ed"}) do amod[v] = i-1 end
            local replacements = {cond=SFX_ID, amod=amod}
            local function expand_key(key)
                local s,w,pos = key:match("^(.-){(.-)}()")
                if not(w) then return {[key]={}} end
                local out = {}
                for r,index in pairs(replacements[w] or {[""]=0,[w]=1}) do
                    for k, sublist in pairs(expand_key(key:sub(pos))) do
                        out[s..r..k] = {index, unpack(sublist)}
                    end
                end
                return out
            end
            local function arg_map(list)
                local out = {}
                for i,row in ipairs(list) do
                    local s,f,name,path = unpack(row)
                    local word,rest = s:lower():match("([%-{}%w]+)[^%-{}%w]*(.*)")
                    if word then
                        word = word:match("{.*}") and "{}" or word:match("r%a")
                            and "r" or word:match("%a%a%a") and "s" or "#"
                        if not out[word] then out[word] = {} end
                        table.insert(out[word], {rest,f,name,path})
                    else
                        out.f,out[1],out[2] = f,name,path
                    end
                end
                for word,l in pairs(copytable(out)) do
                    if type(word)~="number" then out[word] = arg_map(l) end
                end
                return out
            end
            local out = {}
            for i,row in ipairs(fmap) do
                local s,f = unpack(row)
                local word,rest = s:match("([^, ]+)[, ]*(.*)")
                for key,path in pairs(expand_key(word)) do
                    if not out[key] then out[key] = {} end
                    table.insert(out[key], {rest, f, word:gsub("%b{}",""), path})
                end
            end
            for k,v in pairs(copytable(out)) do
                out[k] = arg_map(v)
            end
            return out
        end
        
        ARM_ASM.FMAP = {}
        for i,row in ipairs(OPS_A) do ARM_ASM.FMAP[row[2]] = row[3] end
        ARM_ASM.FMAP = expand_keys(ARM_ASM.FMAP)
    end

    THUMB_DASM = {}
    do
        function THUMB_DASM.ShiftReg(Op,Offset,Rs,Rd)
            if Offset == 0 and Op > 0 then Offset = 32 end
            Op = sel(Op,"lsl","lsr","asr")
            Rs, Rd = index(REGISTERS, Rs, Rd)
            return ("%s %s, %s, #0x%x"):format(Op, Rd, Rs, Offset)
        end
        
        function THUMB_DASM.AddSub1(Op,Rn,Rs,Rd)
            local name = sel(Op,"add","sub")
            Rn, Rs, Rd = index(REGISTERS, Rn, Rs, Rd)
            return ("%s %s, %s, %s"):format(name, Rd, Rs, Rn)
        end
        
        function THUMB_DASM.AddSub2(Op,nn,Rs,Rd)
            local name = sel(Op,"add","sub")
            Rs, Rd = index(REGISTERS, Rs, Rd)
            if nn == 0 and name=="add" then
                return ("mov %s, %s"):format(Rd, Rs)
            else
                return ("%s %s, %s, #0x%x"):format(name, Rd, Rs, nn)
            end
        end
        
        function THUMB_DASM.Imm(Op,Rd,nn)
            Op = sel(Op,"mov","cmp","add","sub")
            return ("%s %s, #0x%x"):format(Op, REGISTERS[Rd+1], nn)
        end
        
        function THUMB_DASM.ALU(Op,Rs,Rd)
            Op = sel(Op,"and","eor","lsl","lsr","asr","adc","sbc","ror","tst","neg","cmp","cmn","orr","mul","bic","mvn")
            return ("%s %s, %s"):format(Op, REGISTERS[Rd+1], REGISTERS[Rs+1])
        end
        
        function THUMB_DASM.HiReg(Op,MSBd,MSBs,Rs,Rd)
            Op = sel(Op,"add","cmp","mov","bx")
            Rs = REGISTERS[SHIFT(MSBs,-3) + Rs + 1]
            Rd = REGISTERS[SHIFT(MSBd,-3) + Rd + 1]
            if Op == "bx" then
                return ("%s %s"):format(sel(MSBd,"bx","blx"), Rs)
            else
                local out = ("%s %s, %s"):format(Op, Rd, Rs)
                if out == "mov r8, r8" then return "nop"
                else return out end
            end
        end
        
        function THUMB_DASM.LdrPC(Rd,nn,pc)
            if pc > 0 then
                return ("ldr %s, [$%08X]"):format(REGISTERS[Rd+1], AND(pc,-3) + 4 + 4*nn)
            else
                return ("ldr %s, [pc, #0x%x]"):format(REGISTERS[Rd+1], 4 + 4*nn)
            end
        end
        
        function THUMB_DASM.LdrStr(Op,Ro,Rb,Rd)
            Op = sel(Op,"str","strb","ldr","ldrb")
            Ro,Rb,Rd = index(REGISTERS,Ro,Rb,Rd)
            return ("%s %s, [%s, %s]"):format(Op, Rd, Rb, Ro)
        end
        
        function THUMB_DASM.LdrStrSH(Op,Ro,Rb,Rd)
            Op = sel(Op,"strh","ldsb","ldrh","ldsh")
            Ro,Rb,Rd = index(REGISTERS,Ro,Rb,Rd)
            return ("%s %s, [%s, %s]"):format(Op, Rd, Rb, Ro)
        end
        
        function THUMB_DASM.LdrStrIMM(Op,nn,Rb,Rd)
            if Op <= 1 then nn = 4*nn end
            Op = sel(Op,"str","ldr","strb","ldrb")
            Rb,Rd = index(REGISTERS,Rb,Rd)
            return ("%s %s, [%s, #0x%x]"):format(Op, Rd, Rb, nn)
        end
        
        function THUMB_DASM.LdrStrH(Op,nn,Rb,Rd)
            Rb, Rd = index(REGISTERS,Rb,Rd)
            return ("%s %s, [%s, #0x%x]"):format(sel(Op,"strh","ldrh"), Rd, Rb, 2*nn)
        end
        
        function THUMB_DASM.LdrStrSP(Op,Rd,nn)
            return ("%s %s, [sp, #0x%x]"):format(sel(Op,"str","ldr"), REGISTERS[Rd+1], 4*nn)
        end
        
        function THUMB_DASM.GetRelAddr(Op,Rd,nn)
            return ("add %s, %s, #0x%x"):format(REGISTERS[Rd+1], sel(Op,"pc","sp"), 4*nn)
        end
        
        function THUMB_DASM.AddSP(Op,nn)
            return ("add sp, #%s0x%x"):format(sel(Op,"","-"), 4*nn)
        end
        
        function THUMB_DASM.PushPop(Op,PCLR,Rlist)
            if PCLR == 1 then Rlist = OR(Rlist, 2^sel(Op,14,15)) end
            return  ("%s {%s}"):format(sel(Op,"push","pop"),write_rlist(Rlist))
        end
        
        function THUMB_DASM.StmLdm(Op,Rb,Rlist)
            Op, Rb, Rlist = sel(Op,"stmia","ldmia"), REGISTERS[Rb+1], write_rlist(Rlist)
            return ("%s %s!, {%s}"):format(Op,Rb,Rlist)
        end 
        
        function THUMB_DASM.BCond(Op,Offset,pc)
            Op = sel(Op,"beq","bne","bcs","bcc","bmi","bpl","bvs","bvc","bhi","bls","bge","blt","bgt","ble")
            return ("%s $%08X"):format(Op, pc + 4 + 2*signed(Offset,8))
        end
        
        function THUMB_DASM.SWI(Op,nn)
            if Op==0xDF then Op="swi" elseif Op==0xBE then Op="bkpt" end
            return ("%s $%x"):format(Op, nn)
        end
        
        function THUMB_DASM.Branch(Offset,pc)
            Offset = 4 + 2*signed(Offset,11)
            return ("b $%08X"):format(pc + Offset)
        end
        
        function THUMB_DASM.BL(Op1,upper,Op2,lower,pc)
            if Op2 > 0 or lower > 0 then
                local Offset = pc + 2*signed(upper*2^11 + lower, 22) + 4
                return ("bl%s $%08X"):format(Op2 == 0x1F and "" or "x",Offset)
            else
                return ("bl%sh $%X"):format(Op1 == 0x1F and "" or "x",2*upper)
            end
        end

        THUMB_DASM.FMAP = {}
        for i,row in ipairs(OPS_T) do THUMB_DASM.FMAP[row[1]] = row end
        THUMB_DASM.FMAP = generate_bin_tree(THUMB_DASM.FMAP)
    end

    THUMB_ASM = {}
    do 
        function THUMB_ASM.ShiftReg(name, Rd, Rs, Offset)
            return setbits(0x0000,11,find(name,"lsl","lsr","asr"),6,tonumber(Offset % 32),3,Rs,0,Rd)
        end
        
        function THUMB_ASM.AddSub1(name, Rd, Rs, Rn)
            return setbits(0x1800,9,find(name,"add","sub"),6,Rn,3,Rs,0,Rd)
        end

        function THUMB_ASM.AddSub2(name, Rd, Rs, nn)
            if name == "mov" then name, nn = "add", 0 end
            return setbits(0x1C00,9,find(name,"add","sub"),6,nn,3,Rs,0,Rd)
        end
        
        function THUMB_ASM.Imm(name, Rd, nn)
            return setbits(0x2000,11,find(name,"mov","cmp","add","sub"),8,Rd,0,nn)
        end
        
        function THUMB_ASM.ALU(name, Rd, Rs)
            name = find(name,"and","eor","lsl","lsr","asr","adc","sbc","ror","tst","neg","cmp","cmn","orr","mul","bic","mvn")
            return setbits(0x4000,6,name,3,Rs,0,Rd)
        end
        
        function THUMB_ASM.HiReg(name, Rd, Rs)
            if name == "nop" then name, Rd, Rs = "mov", 8, 8 end
            local n1, n2 = find(name,"add","cmp","mov"), find(name,"bx","blx")
            return n1 and setbits(0x4400,8,n1,7,SHIFT(Rd,3),3,Rs,0,AND(Rd,7)) or setbits(0x4700,7,n2,3,Rd)
        end
        
        function THUMB_ASM.LdrPC(name, Rd, pc, nn)
            return setbits(0x4800,8,Rd,0,SHIFT(nn-4,2))
        end
        
        function THUMB_ASM.LdrStr(name, Rd, Rb, Ro)
            return setbits(0x5000,10,find(name,"str","strb","ldr","ldrb"),6,Ro,3,Rb,0,Rd)
        end
        
        function THUMB_ASM.LdrStrSH(name, Rd, Rb, Ro)
            return setbits(0x5200,10,find(name,"strh","ldsb","ldrh","ldsh"),6,Ro,3,Rb,0,Rd)
        end
        
        function THUMB_ASM.LdrStrIMM(name, Rd, Rb, nn)
            name = find(name,"str","ldr","strb","ldrb")
            if name <= 1 then nn = SHIFT(nn,2) end
            return setbits(0x6000,11,name,6,nn,3,Rb,0,Rd)
        end
        
        function THUMB_ASM.LdrStrH(name, Rd, Rb, nn)
            return setbits(0x8000,11,find(name,"strh","ldrh"),6,SHIFT(nn,1),3,Rb,0,Rd)
        end
        
        function THUMB_ASM.LdrStrSP(name, Rd, sp, nn)
            return setbits(0x9000,11,find(name,"str","ldr"),8,Rd,0,SHIFT(nn,2))
        end
        
        function THUMB_ASM.GetRelAddr(name, Rd, Op, nn)
            Op = Op==15 and 0 or Op==13 and 1
            return setbits(0xA000,11,Op,8,Rd,0,SHIFT(nn,2))
        end
        
        function THUMB_ASM.AddSP(name, sp, nn)
            if AND(nn,2^31)~=0 then nn = nn-2^32 end
            local sign = nn < 0 and 1 or 0
            if sign == 1 then nn = -nn end
            return setbits(0xB000,7,sign,0,SHIFT(nn,2))
        end
        
        function THUMB_ASM.PushPop(name, Rlist)
            name = find(name,"push","pop")
            Rlist = read_rlist(Rlist)
            local pclr = SHIFT(Rlist,14+name)
            return setbits(0xB400,11,name,8,pclr,0,AND(Rlist,255))
        end
        
        function THUMB_ASM.StmLdm(name, Rb, Rlist)
            return setbits(0xC000,11,find(name,"stmia","ldmia"),8,Rb,0,read_rlist(Rlist))
        end
        
        function THUMB_ASM.BCond(name, label, pc)
            name = find(name,"beq","bne","bcs","bcc","bmi","bpl","bvs","bvc","bhi","bls","bge","blt","bgt","ble")
            return setbits(0xD000,8,name,0,AND(255,SHIFT(label-pc-4,1)))
        end
        
        function THUMB_ASM.SWI(name, nn)
            return setbits(name=="swi" and 0xDF00 or name=="bkpt" and 0xBE00,0,nn)
        end
        
        function THUMB_ASM.Branch(name, label, pc)
            return setbits(0xE000,0,AND(0x7FF,SHIFT(label-pc-4,1)))
        end
        
        function THUMB_ASM.BL(name, label, pc)
            local n1, n2 = find(name,"blx","bl"), find(name,"blxh","blh")
            if not pc then
                return 0xF000
            elseif n1 then
                label = AND(SHIFT(label-pc-4,1),0x3FFFFF)
                return setbits(0xE800F000,28,n1,16,AND(label,0x7FF),0,SHIFT(label,11))
            else
                return setbits(0xE800,12,n2,0,SHIFT(label,1))
            end
        end

        local function generate_fmap(list) -- r: r0-r7, R: r8-r15, sp: sp, pc: pc, n: number, b: braces
            local out = {}
            for i,row in ipairs(list) do
                local s,f,path = unpack(row)
                local word, rest = s:lower():match("([{}%w]+)[^{}%w]*(.*)")
                if word then
                    local ids = (path==nil or REG_ID[word]) and {word} or word:match("{.*}")
                        and {"b"} or word:match("r%a") and {"r"} or {"n"}
                    if path~=nil and f=="HiReg" then
                        ids = path[1]=="r" and {"R","sp","pc"} or {"r","R","sp","pc"}
                    end
                    for _,k in ipairs(ids) do
                        if not out[k] then out[k] = {} end
                        table.insert(out[k], {rest, f, {k, unpack(path or {})}})
                    end
                else
                    out.f = f
                end
            end
            for word, v in pairs(copytable(out)) do
                if word ~= "f" then out[word] = generate_fmap(v) end
            end
            return out
        end

        THUMB_ASM.FMAP = {}
        for i,row in ipairs(OPS_T) do THUMB_ASM.FMAP[i] = {row[2], row[3]} end
        THUMB_ASM.FMAP = generate_fmap(THUMB_ASM.FMAP)
    end

--

-- Emulator (WIP)
    function Emulator(link)
        local out = {}
        function out:set_memory()
            local mem_regions = {
                [0x00000000] = 0x4000,
                [0x02000000] = 0x40000,
                [0x03000000] = 0x8000,
                [0x04000000] = 0x400,
                [0x05000000] = 0x400,
                [0x06000000] = 0x18000,
                [0x07000000] = 0x400,
                [0x08000000] = 0x2000000,
                [0x0E000000] = 0x10000,
            }
            self.memory = setmetatable({}, {
                __index = function(self,k)
                    local size = mem_regions[AND(k,0xF000000)]
                    return rawget(self, AND(k, 0xF000000 + size-1)) or 0
                end,
                __newindex = function(self,k,v)
                    local size = mem_regions[AND(k,0xF000000)]
                    self[AND(k, 0xF000000 + size-1)] = v
                end,
            })
            self.registers = {}
            for i=0,15 do self.registers[i] = 0 end
            self.registers.cpsr = 0x1F
            self.registers.spsr = 0
            
            -- for i=0,15 do self["r"..i] = 0 end
            -- for i=8,12 do self["r"..i.."_fiq"] = 0 end
            -- for i=8,12 do self["r"..i.."_fiq"] = 0 end
            -- for i,v in ipairs{"fiq","svc","abt","irq","und"} do
            --     self["r13_"..v], self["r14_"..v], self["spsr_"..v] = 0
            -- end
            -- self.cpsr = 0x1F
        end
        function out:link_emulator_memory()
            self.memory = setmetatable({}, {
                __index = function(self,k) return memory.readbyte(k) end,
                __newindex = function(self,k,v) memory.writebyte(k,v) end,
            })
            self.registers = setmetatable({}, {
                __index = function(self,k) return memory.getregister(type(k)=="number" and "r"..k or k) end,
                __newindex = function(self,k,v) memory.setregister(type(k)=="number" and "r"..k or k, v) end,
            })
        end
        out.flagmap = {N=31,Z=30,C=29,V=28,I=7,F=6,T=5}
        out.modes = {[0x10]="user", [0x11]="fiq", [0x12]="irq", [0x13]="svc", [0x17]="abt", [0x1B]="und", [0x1F]="system"}
        function out:set_cpsr(fmap)
            local r = self.registers
            for k,v in pairs(fmap) do
                local setbit = 2^self.flagmap[k]
                r.cpsr = AND(r.cpsr, -setbit-1) + setbit*(v and 1 or 0)
                self[k] = v
            end
        end
        function out:set_flags()
            for k,v in pairs(self.flagmap) do
                self[k] = AND(self.registers.cpsr,2^v) ~= 0
            end
            self.mode = self.modes[AND(self.registers.cpsr, 0x1F)]
        end
        function out:read(addr,size)
            if not size or size==1 then return self.memory[addr] end
            local out = 0
            for i=addr+size-1,addr,-1 do
                out = out*2^8 + self.memory[i]
            end
            return out
        end
        function out:write(addr,value,size)
            if not size or size==1 then self.memory[addr] = value end
            for i=addr,addr+size-1 do
                self.memory[i] = value % 256
                value = SHIFT(value,8)
            end
        end
        function out:execute_instruction(v)
            if not self.T then
                local node = nav_bin_tree(v, ARM_DASM.FMAP)
                self.arm_funcs[node[3]](argsfrom(v, ARGS_A[node[3]], self.registers[15]))
            end
        end
        out.conditions = {
            [0] = function() return out.Z end,                  -- EQ: n == 0
            function() return not out.Z end,                    -- NE: n ~= 0
            function() return out.C end,                        -- CS/HS: n >= 0
            function() return not out.C end,                    -- CC/LO: n < 0
            function() return out.N end,                        -- MI: n & 2^31 == 1
            function() return not out.N end,                    -- PL: n & 2^31 == 0
            function() return out.V end,                        -- VS: n not in [-2^31, 2^31-1]
            function() return not out.V end,                    -- VC: n in [-2^31, 2^31-1]
            function() return out.C and not out.Z end,          -- HI: n > 0
            function() return not out.C or out.Z end,           -- LS: n <= 0
            function() return out.N == out.V end,               -- GE: n >= 0
            function() return out.N ~= out.V end,               -- LT: n < 0
            function() return not out.Z and out.N == out.V end, -- GT: n > 0
            function() return out.Z or out.N ~= out.V end,      -- LE: n <= 0
            function() return true end,                         -- AL: true
            function() return false end,                        -- NV: false
        }
        out.shift_ops = {
            [0]=function(a,b)
                if b == 0 then return a end
                return SHIFT(a,-b), SHIFT(a,1-b)<0
            end,
            function(a,b)
                if b == 0 then b = 32 end
                return SHIFT(a,b), SHIFT(a,32-b)<0
            end,
            function(a,b)
                if b == 0 then b = 32 end
                return bit.arshift(a,b), SHIFT(a,32-b)<0
            end,
            function(a,b)
                if b == 0 then
                    return SHIFT(a,1) + (out.C and 2^31 or 0), a%2 == 1
                else
                    return bit.ror(a,b), SHIFT(a,32-b)<0
                end
            end,
        }
        out.alu_ops = {
            [0]=function(Rn,Op2) -- and
                local r = AND(Rn,Op2)
                return r, r<0, r==0
            end,
            function(Rn,Op2) -- eor
                local r = XOR(Rn,Op2)
                return r, r<0, r==0
            end,
            function(Rn,Op2) -- sub
                Op2 = OR(-Op2)
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- rsb
                Rn = OR(-Rn)
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- add
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- adc
                Op2 = Op2+(out.C and 1 or 0)
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- sbc
                Op2 = OR(-Op2+(out.C and 1 or 0)-1)
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- rsc
                Rn = OR(-Rn+(out.C and 1 or 0)-1)
                local r = OR(Rn+Op2)
                return r, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- tst
                local r = AND(Rn,Op2)
                return nil, r<0, r==0
            end,
            function(Rn,Op2) -- teq
                local r = XOR(Rn,Op2)
                return nil, r<0, r==0
            end,
            function(Rn,Op2) -- cmp
                Op2 = OR(-Op2)
                local r = OR(Rn+Op2)
                return nil, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- cmn
                local r = OR(Rn+Op2)
                return nil, r<0, r==0, Rn%2^32+Op2%2^32>=2^32, Rn+Op2~=r
            end,
            function(Rn,Op2) -- orr
                local r = OR(Rn,Op2)
                return r, r<0, r==0
            end,
            function(Rn,Op2) -- mov
                return Op2, Op2<0, Op2==0
            end,
            function(Rn,Op2) -- bic
                local r = AND(Rn, -Op2-1)
                return r, r<0, r==0
            end,
            function(Rn,Op2) -- mvn
                local r = bit.bnot(Op2)
                return r, r<0, r==0
            end,
        }
        out.thumb_funcs = {}
        out.arm_funcs = {
            BX = function(cond,Op,Rn)
                if not out.conditions[cond]() then return end
                local r = out.registers
                if Op==3 then r[14] = r[15] + 4 end
                r[15] = AND(r[Rn],-2)
                out:set_cpsr{T = r[Rn] % 2 ~= 0}
            end,
            BL = function(cond,Op,nn)
                if not out.conditions[cond]() then return end
                local r = out.registers
                if Op==1 then r[14] = r[15] + 4 end
                r[15] = r[15] + 8 + nn*4
            end,
            DataProc = function(cond,I,Op,S,Rn,Rd,Is1,shift,R,Rm,Rs,Is2,nn)
                local N,Z,C,V
                if not out.conditions[cond]() then return end
                local r = out.registers
                local Op2
                if I==1 then
                    Op2 = ROR(nn, 2*Is2)
                elseif R==1 then
                    Op2, C = out.shift_ops[shift](r[Rm], r[Rs])
                else
                    Op2, C = out.shift_ops[shift](r[Rm], Is1)
                end
                local result,N,Z,C,V = out.alu_ops[Op](r[Rn],Op2)
                r[Rd] = result or r[Rd]
                if S==1 then out:set_cpsr{N=N,Z=Z,C=C,V=V} end
            end,
            PSR_Transfer = function(cond,I,Psr,Op,f,s,x,c,Rd,Is,Imm,Rm)
                if not out.conditions[cond]() then return end
                local r = out.registers
                Psr = Psr==0 and "cpsr" or "spsr"
                if Op == 0 then
                    r[Rd] = r[Psr]
                else
                    local bitmask = OR(f*0xFF000000,s*0x00FF0000,x*0x0000FF00,c*0x000000FF)
                    local Op2 = I==0 and r[Rm] or bit.ror(Imm,Is*2)
                    r[Psr] = AND(r[Psr],-bitmask-1) + AND(Op2, bitmask)
                    out:set_flags()
                end
            end,
            Multiply = function(cond,half,long,sign,acc,S,Rd,Rn,Rs,y,x,Rm)
                if not out.conditions[cond]() then return end
                local r = out.registers
                local a,b,c,d = r[Rm], r[Rs], r[Rn], r[Rd]
                if long==1 then
                    if sign == 0 then a,b = a % 2^32, b % 2^32 end
                    r[Rn], r[Rd] = mla64(a, b, c*acc, d*acc)
                else
                    r[Rd] = mla64(a, b, c*acc)
                end
                r[Rn], r[Rd] = OR(r[Rn]), OR(r[Rd])
                if S==1 then
                    out:set_cpsr{N = r[Rd] < 0, Z = r[Rd]==0 and r[Rn]*long==0}
                end
            end,
        }
        function out:init()
            if link then
                self:link_emulator_memory()
            else
                self:set_memory()
            end
            self:set_flags()
        end
        out:init()
        return out
    end
--

-- Assemble/Disassemble functions
    function asm_a(s, pc)
        local word, args = s:lower():gsub("#",""):match("(%S+)%s*(.*)")
        local entry = copytable(ARM_ASM.FMAP[word])
        if entry==nil then return undefined() end
        entry[#entry+1] = pc or 0
        return ARM_ASM[entry.f](entry.name, args, unpack(entry))
    end

    function dis_a(bits, pc)
        local node = nav_bin_tree(bits, ARM_DASM.FMAP)
        if node==nil then return undefined() end
        if node.case then node = node[AND(bits, node.case)] or node end
        return ARM_DASM[node[3]](argsfrom(bits, ARGS_A[node[3]], pc or 0))
    end

    function asm_t(s, pc)
        local words = s:lower():gsub("%b{}","{}"):gmatch("[{}$#+%-%w]+")
        local name = words()
        local node = THUMB_ASM.FMAP[name]
        local args = {}
        for m in words do
            local r = REG_ID[m]
            if r then
                args[#args+1] = r
                node = node[r<=7 and "r" or r==15 and "pc" or r==13 and "sp" or "R"]
            elseif m == "{}" then
                args[#args+1] = s:match("{(.*)}")
                node = node["b"]
            else
                local n = m:gsub("[$#]","")
                args[#args+1] = tonumber(n, m:match("%$") and 16)
                node = node["n"]
            end
        end
        if node==nil then return undefined() end
        args[#args+1] = pc or 0
        return THUMB_ASM[node.f](name, unpack(args))
    end

    function dis_t(bits, pc)
        local node = nav_bin_tree(bits, THUMB_DASM.FMAP)
        if node==nil then return undefined() end
        if node.case then node = node[AND(bits, node.case)] or node end
        return THUMB_DASM[node[3]](argsfrom(bits, ARGS_T[node[3]], pc or 0))
    end
--
