require('bk2_compat').ible()

DebugFlag = 0
TASFlag = 0
old_gamemode = 0
font = gui.font.load("data\\snes9xluasmall.font")
blocks = {[0x02]=true, [0x09]=true}
doors = {[0x88FE]=true, [0x890A]=true, [0x8916]=true, [0x8922]=true, [0x892E]=true, [0x893A]=true, [0x8946]=true, [0x8952]=true, [0x895E]=true, [0x896A]=true, [0x8976]=true, [0x8982]=true, [0x898E]=true, [0x899A]=true, [0x89A6]=true, [0x89B2]=true, [0x89BE]=true, [0x89CA]=true, [0x89D6]=true, [0x89E2]=true, [0x89EE]=true, [0x89FA]=true, [0x8A06]=true, [0x8A12]=true, [0x8A1E]=true, [0x8A2A]=true, [0x8A36]=true, [0x8A42]=true, [0x8A4E]=true, [0x8A5A]=true, [0x8A66]=true, [0x8A72]=true, [0x8A7E]=true, [0x8A8A]=true, [0x8A96]=true, [0x8AA2]=true, [0x8AAE]=true, [0x8ABA]=true, [0x8AC6]=true, [0x8AD2]=true, [0x8ADE]=true, [0x8AEA]=true, [0x8AF6]=true, [0x8B02]=true, [0x8B0E]=true, [0x8B1A]=true, [0x8B26]=true, [0x8B32]=true, [0x8B3E]=true, [0x8B4A]=true, [0x8B56]=true, [0x8B62]=true, [0x8B6E]=true, [0x8B7A]=true, [0x8B86]=true, [0x8B92]=true, [0x8B9E]=true, [0x8BAA]=true, [0x8BB6]=true, [0x8BC2]=true, [0x8BCE]=true, [0x8BDA]=true, [0x8BE6]=true, [0x8BF2]=true, [0x8BFE]=true, [0x8C0A]=true, [0x8C16]=true, [0x8C22]=true, [0x8C2E]=true, [0x8C3A]=true, [0x8C46]=true, [0x8C52]=true, [0x8C5E]=true, [0x8C6A]=true, [0x8C76]=true, [0x8C82]=true, [0x8C8E]=true, [0x8C9A]=true, [0x8CA6]=true, [0x8CB2]=true, [0x8CBE]=true, [0x8CCA]=true, [0x8CD6]=true, [0x8CE2]=true, [0x8CEE]=true, [0x8CFA]=true, [0x8D06]=true, [0x8D12]=true, [0x8D1E]=true, [0x8D2A]=true, [0x8D36]=true, [0x8D42]=true, [0x8D4E]=true, [0x8D5A]=true, [0x8D66]=true, [0x8D72]=true, [0x8D7E]=true, [0x8D8A]=true, [0x8D96]=true, [0x8DA2]=true, [0x8DAE]=true, [0x8DBA]=true, [0x8DC6]=true, [0x8DD2]=true, [0x8DDE]=true, [0x8DEA]=true, [0x8DF6]=true, [0x8E02]=true, [0x8E0E]=true, [0x8E1A]=true, [0x8E26]=true, [0x8E32]=true, [0x8E3E]=true, [0x8E4A]=true, [0x8E56]=true, [0x8E62]=true, [0x8E6E]=true, [0x8E7A]=true, [0x8E86]=true, [0x8E92]=true, [0x8E9E]=true, [0x8EAA]=true, [0x8EB6]=true, [0x8EC2]=true, [0x8ECE]=true, [0x8EDA]=true, [0x8EE6]=true, [0x8EF2]=true, [0x8EFE]=true, [0x8F0A]=true, [0x8F16]=true, [0x8F22]=true, [0x8F2E]=true, [0x8F3A]=true, [0x8F46]=true, [0x8F52]=true, [0x8F5E]=true, [0x8F6A]=true, [0x8F76]=true, [0x8F82]=true, [0x8F8E]=true, [0x8F9A]=true, [0x8FA6]=true, [0x8FB2]=true, [0x8FBE]=true, [0x8FCA]=true, [0x8FD6]=true, [0x8FE2]=true, [0x8FEE]=true, [0x8FFA]=true, [0x9006]=true, [0x9012]=true, [0x901E]=true, [0x902A]=true, [0x9036]=true, [0x9042]=true, [0x904E]=true, [0x905A]=true, [0x9066]=true, [0x9072]=true, [0x907E]=true, [0x908A]=true, [0x9096]=true, [0x90A2]=true, [0x90AE]=true, [0x90BA]=true, [0x90C6]=true, [0x90D2]=true, [0x90DE]=true, [0x90EA]=true, [0x90F6]=true, [0x9102]=true, [0x910E]=true, [0x911A]=true, [0x9126]=true, [0x9132]=true, [0x913E]=true, [0x914A]=true, [0x9156]=true, [0x9162]=true, [0x916E]=true, [0x917A]=true, [0x9186]=true, [0x9192]=true, [0x919E]=true, [0x91AA]=true, [0x91B6]=true, [0x91C2]=true, [0x91CE]=true, [0x91DA]=true, [0x91E6]=true, [0x91F2]=true, [0x91FE]=true, [0x920A]=true, [0x9216]=true, [0x9222]=true, [0x922E]=true, [0x923A]=true, [0x9246]=true, [0x9252]=true, [0x925E]=true, [0x926A]=true, [0x9276]=true, [0x9282]=true, [0x928E]=true, [0x929A]=true, [0x92A6]=true, [0x92B2]=true, [0x92BE]=true, [0x92CA]=true, [0x92D6]=true, [0x92E2]=true, [0x92EE]=true, [0x92FA]=true, [0x9306]=true, [0x9312]=true, [0x931E]=true, [0x932A]=true, [0x9336]=true, [0x9342]=true, [0x934E]=true, [0x935A]=true, [0x9366]=true, [0x9372]=true, [0x937E]=true, [0x938A]=true, [0x9396]=true, [0x93A2]=true, [0x93AE]=true, [0x93BA]=true, [0x93C6]=true, [0x93D2]=true, [0x93DE]=true, [0x93EA]=true, [0x93F6]=true, [0x9402]=true, [0x940E]=true, [0x941A]=true, [0x9426]=true, [0x9432]=true, [0x943E]=true, [0x944A]=true, [0x9456]=true, [0x9462]=true, [0x946E]=true, [0x947A]=true, [0x9486]=true, [0x9492]=true, [0x949E]=true, [0x94AA]=true, [0x94B6]=true, [0x94C2]=true, [0x94CE]=true, [0x94DA]=true, [0x94E6]=true, [0x94F2]=true, [0x94FE]=true, [0x950A]=true, [0x9516]=true, [0x9522]=true, [0x952E]=true, [0x953A]=true, [0x9546]=true, [0x9552]=true, [0x955E]=true, [0x956A]=true, [0x9576]=true, [0x9582]=true, [0x958E]=true, [0x959A]=true, [0x95A6]=true, [0x95B2]=true, [0x95BE]=true, [0x95CA]=true, [0x95D6]=true, [0x95E2]=true, [0x95EE]=true, [0x95FA]=true, [0x9606]=true, [0x9612]=true, [0x961E]=true, [0x962A]=true, [0x9636]=true, [0x9642]=true, [0x964E]=true, [0x965A]=true, [0x9666]=true, [0x9672]=true, [0x967E]=true, [0x968A]=true, [0x9696]=true, [0x96A2]=true, [0x96AE]=true, [0x96BA]=true, [0x96C6]=true, [0x96D2]=true, [0x96DE]=true, [0x96EA]=true, [0x96F6]=true, [0x9702]=true, [0x970E]=true, [0x971A]=true, [0x9726]=true, [0x9732]=true, [0x973E]=true, [0x974A]=true, [0x9756]=true, [0x9762]=true, [0x976E]=true, [0x977A]=true, [0x9786]=true, [0x9792]=true, [0x979E]=true, [0x97AA]=true, [0x97B6]=true, [0x97C2]=true, [0x97CE]=true, [0x97DA]=true, [0x97E6]=true, [0x97F2]=true, [0x97FE]=true, [0x980A]=true, [0x9816]=true, [0x9822]=true, [0x982E]=true, [0x983A]=true, [0x9846]=true, [0x9852]=true, [0x985E]=true, [0x986A]=true, [0x9876]=true, [0x9882]=true, [0x988E]=true, [0x989A]=true, [0x98A6]=true, [0x98B2]=true, [0x98BE]=true, [0x98CA]=true, [0x98D6]=true, [0x98E2]=true, [0x98EE]=true, [0x98FA]=true, [0x9906]=true, [0x9912]=true, [0x991E]=true, [0x992A]=true, [0x9936]=true, [0x9942]=true, [0x994E]=true, [0x995A]=true, [0x9966]=true, [0x9972]=true, [0x997E]=true, [0x998A]=true, [0x9996]=true, [0x99A2]=true, [0x99AE]=true, [0x99BA]=true, [0x99C6]=true, [0x99D2]=true, [0x99DE]=true, [0x99EA]=true, [0x99F6]=true, [0x9A02]=true, [0x9A0E]=true, [0x9A1A]=true, [0x9A26]=true, [0x9A32]=true, [0x9A3E]=true, [0x9A4A]=true, [0x9A56]=true, [0x9A62]=true, [0x9A6E]=true, [0x9A7A]=true, [0x9A86]=true, [0x9A92]=true, [0x9A9E]=true, [0x9AAA]=true, [0x9AB6]=true, [0xA18C]=true, [0xA198]=true, [0xA1A4]=true, [0xA1B0]=true, [0xA1BC]=true, [0xA1C8]=true, [0xA1D4]=true, [0xA1E0]=true, [0xA1EC]=true, [0xA1F8]=true, [0xA204]=true, [0xA210]=true, [0xA21C]=true, [0xA228]=true, [0xA234]=true, [0xA240]=true, [0xA24C]=true, [0xA258]=true, [0xA264]=true, [0xA270]=true, [0xA27C]=true, [0xA288]=true, [0xA294]=true, [0xA2A0]=true, [0xA2AC]=true, [0xA2B8]=true, [0xA2C4]=true, [0xA2D0]=true, [0xA2DC]=true, [0xA2E8]=true, [0xA2F4]=true, [0xA300]=true, [0xA30C]=true, [0xA318]=true, [0xA324]=true, [0xA330]=true, [0xA33C]=true, [0xA348]=true, [0xA354]=true, [0xA360]=true, [0xA36C]=true, [0xA378]=true, [0xA384]=true, [0xA390]=true, [0xA39C]=true, [0xA3A8]=true, [0xA3B4]=true, [0xA3C0]=true, [0xA3CC]=true, [0xA3D8]=true, [0xA3E4]=true, [0xA3F0]=true, [0xA3FC]=true, [0xA408]=true, [0xA414]=true, [0xA420]=true, [0xA42C]=true, [0xA438]=true, [0xA444]=true, [0xA450]=true, [0xA45C]=true, [0xA468]=true, [0xA474]=true, [0xA480]=true, [0xA48C]=true, [0xA498]=true, [0xA4A4]=true, [0xA4B0]=true, [0xA4BC]=true, [0xA4C8]=true, [0xA4D4]=true, [0xA4E0]=true, [0xA4EC]=true, [0xA4F8]=true, [0xA504]=true, [0xA510]=true, [0xA51C]=true, [0xA528]=true, [0xA534]=true, [0xA540]=true, [0xA54C]=true, [0xA558]=true, [0xA564]=true, [0xA570]=true, [0xA57C]=true, [0xA588]=true, [0xA594]=true, [0xA5A0]=true, [0xA5AC]=true, [0xA5B8]=true, [0xA5C4]=true, [0xA5D0]=true, [0xA5DC]=true, [0xA5E8]=true, [0xA5F4]=true, [0xA600]=true, [0xA60C]=true, [0xA618]=true, [0xA624]=true, [0xA630]=true, [0xA63C]=true, [0xA648]=true, [0xA654]=true, [0xA660]=true, [0xA66C]=true, [0xA678]=true, [0xA684]=true, [0xA690]=true, [0xA69C]=true, [0xA6A8]=true, [0xA6B4]=true, [0xA6C0]=true, [0xA6CC]=true, [0xA6D8]=true, [0xA6E4]=true, [0xA6F0]=true, [0xA6FC]=true, [0xA708]=true, [0xA714]=true, [0xA720]=true, [0xA72C]=true, [0xA738]=true, [0xA744]=true, [0xA750]=true, [0xA75C]=true, [0xA768]=true, [0xA774]=true, [0xA780]=true, [0xA78C]=true, [0xA798]=true, [0xA7A4]=true, [0xA7B0]=true, [0xA7BC]=true, [0xA7C8]=true, [0xA7D4]=true, [0xA7E0]=true, [0xA7EC]=true, [0xA7F8]=true, [0xA810]=true, [0xA828]=true, [0xA834]=true, [0xA840]=true, [0xA84C]=true, [0xA858]=true, [0xA864]=true, [0xA870]=true, [0xA87C]=true, [0xA888]=true, [0xA894]=true, [0xA8A0]=true, [0xA8AC]=true, [0xA8B8]=true, [0xA8C4]=true, [0xA8D0]=true, [0xA8DC]=true, [0xA8E8]=true, [0xA8F4]=true, [0xA900]=true, [0xA90C]=true, [0xA918]=true, [0xA924]=true, [0xA930]=true, [0xA93C]=true, [0xA948]=true, [0xA954]=true, [0xA960]=true, [0xA96C]=true, [0xA978]=true, [0xA984]=true, [0xA990]=true, [0xA99C]=true, [0xA9A8]=true, [0xA9B4]=true, [0xA9C0]=true, [0xA9CC]=true, [0xA9D8]=true, [0xA9E4]=true, [0xA9F0]=true, [0xA9FC]=true, [0xAA08]=true, [0xAA14]=true, [0xAA20]=true, [0xAA2C]=true, [0xAA38]=true, [0xAA44]=true, [0xAA50]=true, [0xAA5C]=true, [0xAA68]=true, [0xAA74]=true, [0xAA80]=true, [0xAA8C]=true, [0xAA98]=true, [0xAAA4]=true, [0xAAB0]=true, [0xAABC]=true, [0xAAC8]=true, [0xAAD4]=true, [0xAAE0]=true, [0xAAEC]=true, [0xAAF8]=true, [0xAB04]=true, [0xAB10]=true, [0xAB1C]=true, [0xAB28]=true, [0xAB34]=true, [0xAB40]=true, [0xAB4C]=true, [0xAB58]=true, [0xAB64]=true, [0xAB70]=true, [0xAB7C]=true, [0xAB88]=true, [0xAB94]=true, [0xABA0]=true, [0xABAC]=true, [0xABB8]=true, [0xABC4]=true, [0xABCF]=true, [0xABDA]=true, [0xABE5]=true}
slope = {
    [0x00] = function ()
		gui.box(TileX+8*HFlip, TileY+4+12*VFlip, 8, 4, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
    end,
    [0x01] = function ()
		gui.box(TileX+4+12*HFlip, TileY+8*VFlip, 4, 8, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
    end,
    [0x02] = function ()
		gui.box(TileX+4+12*HFlip, TileY+4+12*VFlip, 4, 4, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
    end,
    [0x03] = function ()
        gui.line(TileX+4*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+4*HFlip, TileY, TileX+4*HFlip, TileY+3*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+4*VFlip, TileX+3*HFlip, TileY+4*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+4*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x05] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+3*HFlip, TileY+4*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+4*HFlip, TileY+4*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x06] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+3*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+4*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x07] = function ()
        --gui.box(TileX, TileY+8*VFlip, 16*HFlip, 8*VFlip, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
		gui.box(TileX+8*HFlip, TileY+4+4*VFlip, 8, 4, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
    end,
    [0x0E] = function ()
        gui.line(TileX, TileY+3*VFlip, TileX+3*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX, TileY+3*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+3*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x0F] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+5*HFlip, TileY+14*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+6*HFlip, TileY+3*VFlip, TileX+9*HFlip, TileY+12*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+10*HFlip, TileY+5*VFlip, TileX+5*HFlip, TileY+10*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+12*HFlip, TileY+9*VFlip, TileX+3*HFlip, TileY+6*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+14*HFlip, TileY+5*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x12] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x13] = function ()
		gui.box(TileX + 16*HFlip, TileY + 16*VFlip, 16, 16, 1, gui.color(0, 255, 0), gui.color(0, 255, 0), -1)
    end,
    [0x14] = function ()
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x15] = function ()
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+3*VFlip, TileX+3*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x16] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x17] = function ()
        gui.line(TileX, TileY+3*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x18] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+5*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+5*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x19] = function ()
        gui.line(TileX, TileY+10*VFlip, TileX+8*HFlip, TileY+5*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+10*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+5*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1A] = function ()
        gui.line(TileX, TileY+4*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX, TileY+4*VFlip, TileX, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1B] = function ()
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1C] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+3*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1D] = function ()
        gui.line(TileX+10*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+10*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1E] = function ()
        gui.line(TileX+5*HFlip, TileY+8*VFlip, TileX+10*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+10*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX+5*HFlip, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end,
    [0x1F] = function ()
        gui.line(TileX, TileY+8*VFlip, TileX+5*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+5*HFlip, TileY, TileX+8*HFlip, TileY, gui.color(0, 255, 0))
        gui.line(TileX+8*HFlip, TileY, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
        gui.line(TileX, TileY+8*VFlip, TileX+8*HFlip, TileY+8*VFlip, gui.color(0, 255, 0))
    end
}
outline = {
    [0x00] = function ()
    end, -- Air
    [0x01] = function ()
        local b = memory.readbyte('BUS', BTS)
        if bit.band(b, 0x40) ~= 0 then
            TileX = TileX+8
            HFlip = -1
        else
            HFlip = 1
        end

		-- Inverts the horizontal co-ordinates of the lines
        if bit.band(b, 0x80) ~= 0 then
            TileY = TileY+8
            VFlip = -1
        else
            VFlip = 1
        end

		local sf = bit.band(memory.readbyte('BUS', BTS), 0x1F)
		if sf == 0x13 or sf == 0x00 or sf == 0x01 or sf == 0x02 or sf == 0x07 then
			if VFlip == 1 then
				VFlip = 0
			end
			if HFlip == 1 then
				HFlip = 0
			end
		end

        -- Inverts the vertical co-ordinates of the lines
        --slopefunction = slope[sf] or function () gui.box(TileX, TileY, 8*HFlip, 8*VFlip, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1) end
        --slopefunction()
		--gui.box(TileX, TileY, 8*HFlip, 8*VFlip, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1)
    end, -- Slope
    [0x02] = function ()
		gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(128, 128, 255), -1)
    end, -- Air, tricks X-ray
    [0x03] = function ()
        --gui.box(TileX, TileY, 8, 8, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
    end, -- Treadmill
    [0x05] = function ()
        stack = stack + 1
        local b = memory.readsbyte('BUS', BTS)
        if stack < 16 and (b ~= 0) then
            BTS = BTS + b
            Clip = Clip + bit.lrshift(b, -1)
            outlinefunction = outline[bit.lrshift(memory.readword('BUS', Clip), 12)] or function() gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1) end
            outlinefunction()
        else
            gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1)
        end
    end, -- Horizontal extend
    [0x08] = function ()
        gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 0), gui.color(255, 0, 0), -1)
    end, -- Normal block
    [0x09] = function ()
        door = memory.readword('BUS', 0x8F0000 + memory.readword('BUS', 0x7E07B5) + 2*bit.band(memory.readbyte('BUS', BTS), 0x7F))
        if door == 0x8000 then
            gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 255, 255), gui.color(0, 255, 255), -1)
        elseif doors[door] then
            gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 255, 255), gui.color(0, 255, 255), -1)
        else
            gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 255, 255), gui.color(0, 255, 255), -1)
        end
    end, -- Transition block
    [0x0A] = function ()
        gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
    end, -- Spike block
    [0x0B] = function ()
        gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
    end, -- Crumble block
    [0x0C] = function ()
        local b = memory.readbyte('BUS', BTS)
        if b >= 0x40 and b <= 0x43 then
            gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 165, 0), gui.color(255, 165, 0), -1)
        else
            gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
        end
    -- makes doors orange
    end, -- Shot block
    [0x0D] = function ()
        stack = stack + 1
        local b = memory.readsbyte('BUS', BTS)
        if stack < 16 and (b ~= 0) then
            BTS = BTS + b*width
            Clip = Clip + bit.lrshift(b*width, -1)
            outlinefunction = outline[bit.lrshift(memory.readword('BUS', Clip), 12)] or function() gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1) end
            outlinefunction()
        else
            gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1)
        end
    end, -- Vertical extend
    [0x0E] = function ()
        gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
    end, -- Grapple block
    [0x0F] = function ()
        gui.box(TileX, TileY, 4, 4, 1, gui.color(0, 0, 255), gui.color(0, 0, 255), -1)
    end -- Bomb block
}

function on_video()
	cur_gamemode = memory.readbyte('BUS', 0x7E0998)

--	if cur_gamemode == 0x08 then
		local ChangedInput = memory.readword('BUS', 0x7E008F)
		if bit.band(memory.readword('BUS', 0x7E008B), 0x2000) ~= 0 then
			DebugFlag = bit.bxor(DebugFlag, bit.band(ChangedInput, 0x0080))
			-- this shows the clipdata and BTS of every block on screen
		end

		local cameraX, cameraY = bit.band(memory.readword('BUS', 0x7E0AF6)-1024, 0xFFFF), bit.band(memory.readword('BUS', 0x7E0AFA)-896, 0xFFFF)
		-- these are the co-ordinates of the top-left of the screen

		if cameraX >= 10000 then
			cameraX = cameraX-65535
		end

		if cameraY >= 10000 then
			cameraY = cameraY-65535
		end


		width = memory.readword('BUS', 0x7E07A5)
		-- this is how wide the room is in blocks
		for y=0,112 do
			for x=0,128 do
				stack = 0
				-- for when garbage data causes extend blocks that make infinate loops
				TileX, TileY = x*4 - math.floor(bit.band(cameraX, 0x000F)/4), y*4 - math.floor(bit.band(cameraY, 0x000F)/4)
				-- this if for pixel-aligning the grid, because the screen doesn't just scroll per block!
				a = bit.lrshift(bit.band(cameraX+x*16, 0xFFFF), 4) + bit.band(bit.lrshift(bit.band(cameraY+y*16, 0xFFF), 4)*width, 0xFFFF)
				-- get block's tile number
				BTS = 0x7F0000 + ((0x6402 + a)%0x10000)
				-- BTS of block
				Clip = 0x7F0000 + ((0x0002 + a*2)%0x10000)
				-- clipdata of block
				if DebugFlag ~= 0 or bit.lrshift(memory.readword('BUS', Clip), 12) == 0x09 or bit.lrshift(memory.readword('BUS', Clip), 12) == 0x02 then
				--	gui.text(TileX+4, TileY, string.format("%02X",bit.lrshift(memory.readword(Clip), 12)), gui.color(255, 0, 0))
				--	gui.text(TileX+4, TileY+4, string.format("%02X",bit.band(memory.readword(Clip), 0x00FF)), gui.color(255, 0, 0))
				--	gui.text(TileX, TileY, string.format("%02X",memory.readbyte('BUS', BTS)), gui.color(255, 165, 0))
				--	gui.text(TileX, TileY, string.format("%02X", bit.lrshift(memory.readword(Clip), 12)) , gui.color(255, 165, 0))
				--	font(TileX+1, TileY, string.format("%02X",bit.lrshift(memory.readword('BUS',Clip), 12)), gui.color(255, 0, 0))
				--	font(TileX+1, TileY+3, string.format("%02X",memory.readbyte('BUS',BTS)), gui.color(255, 165, 0))
				end
				outlinefunction = outline[bit.lrshift(memory.readword('BUS', Clip), 12)] or function() gui.box(TileX, TileY, 4, 4, 1, gui.color(255, 0, 255), gui.color(255, 0, 255), -1) end
				outlinefunction()
				-- that's for the block's clipdata nibble
			end
		end
		gui.text(0, 0, string.format(
			"cameraX: %03X\ncameraY: %03X\nClip: %X\nDivisor: %X\nProduct: %X\nMode: %X",
			bit.lrshift(cameraX, 4),
			bit.lrshift(bit.band(cameraY, 0xFFF), 4),
			0x7F0002 + (bit.lrshift(cameraX, 4) + bit.lrshift(bit.band(cameraY, 0xFFF), 4)*width)*2,
			memory.readbyte('BUS', 0x4214),
			memory.readbyte('BUS', 0x4216),
			cur_gamemode
		), gui.color(0,255,255))


		for i=0,31 do
			local enemyX, enemyY = memory.readword('BUS',0x7E0F7A + i*64), memory.readword('BUS',0x7E0F7E + i*64)
			local eradiusX, eradiusY = memory.readsword('BUS',0x7E0F82 + i*64), memory.readsword('BUS',0x7E0F84 + i*64)
			local topleft = {enemyX - cameraX - eradiusX, enemyY - cameraY - eradiusY}
			local bottomright = {enemyX - cameraX + eradiusX, enemyY - cameraY + eradiusY}
			gui.rectangle(math.floor(topleft[1]/4), math.floor(topleft[2]/4), math.floor((bottomright[1]-topleft[1])/4),math.floor((bottomright[2] - topleft[2])/4), 1, gui.color(200,200,200), -1)
			gui.rectangle(topleft[1], topleft[2], bottomright[1]-topleft[1],bottomright[2] - topleft[2], 1, gui.color(200,200,200), -1)
			-- draw enemy hitbox
			local enemyhealth = memory.readword('BUS', 0x7E0F8C + i*64)
			local enemyspawnhealth = memory.readword('BUS', 0xA00004 + memory.readword('BUS', 0x7E0F78 + i*64))
			if enemyspawnhealth ~= 0 then
				--gui.text(topleft[1], topleft[2]-16, enemyhealth .. "/" .. enemyspawnhealth, "#FFFFFF")
				-- show enemy health
				if enemyhealth ~= 0 then
					gui.box(tonumber(topleft[1]), tonumber(topleft[2]-8), math.floor(tonumber(topleft[1] + tonumber(enemyhealth/enemyspawnhealth*32))), tonumber(topleft[2]-5), 1, gui.color(0x60, 0x60, 0x60), gui.color(0x60, 0x60, 0x60), -1)
					gui.box(tonumber(topleft[1]), tonumber(topleft[2]-8), tonumber(topleft[1] + 32), 							  tonumber(topleft[2]-5), 1, gui.color(0x80, 0x80, 0x80), gui.color(0x80, 0x80, 0x80), -1)
					-- draw enemy health bar
				end
			end
		end


		do
			local radiusX, radiusY = memory.readsword('BUS', 0x7E0AFE), memory.readsword('BUS', 0x7E0B00)
			local topleft = {1024 - radiusX, 896 - radiusY}
			local bottomright = {1024 + radiusX, 896 + radiusY}
			gui.box(math.floor(topleft[1]/4),math.floor(topleft[2]/4), math.floor((bottomright[1]-topleft[1])/4), math.floor((bottomright[2]-topleft[2])/4), 1, gui.color(128,255,255), gui.color(128,255,255), -1)
			-- draw Samus' hitbox

		end
--	end
	-- snes9x.frameadvance()
end
