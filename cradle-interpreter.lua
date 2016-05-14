--[[ Cradle code --]]

--[[ Constant Declarations --]]

TAB = '\t'
CR = '\n'

--[[ Variable Declarations --]]

look = nil    -- Lookahead char

--[[ Read New Character From Input Stream --]]

function GetChar ()
    look = io.read(1)
end

--[[ Report an Error --]]

function Error (s)
   io.write("\t\a")
   io.write("Error: " .. s .. ".\n")
end

--[[ Report Error and Halt --]]

function Abort (s)
    Error(s)
    os.exit()
end

--[[ Report What Was Expected --]]

function Expected (s)
    Abort(s .. " Expected")
end

--[[ Recognize White Space --]]

function IsWhite (c)
    if c == ' ' or c == TAB then return true else return false end
end

--[[ Recognize an Alpha Character --]]

function IsAlpha (c)
    if string.match(c, "%a") then return true else return false end
end

--[[ Recognize a Decimal Digit --]]

function IsDigit (c)
    if string.match(c, "%d") then return true else return false end
end

--[[ Recognize an Alphanumeric --]]

function IsAlnum (c)
    if string.match(c, "%w") then return true else return false end
end

--[[ Recognize and Addop --]]

function IsAddop (c)
    if c == '+' or c == '-' then return true else return false end
end

--[[ Skip Over Leading White Space -]]

function SkipWhite ()
    while IsWhite(look) do
        GetChar()
    end
end
--[[ Match a Specific Input Character --]]

function Match (x)
    if look ~= x then Expected("'" .. x .. "'")
    else
        GetChar()
        SkipWhite()
    end
end

--[[ Get an Identifier --]]

function GetName ()
    Token = ""
    if not IsAlpha(look) then Expected('Name') end
    while IsAlnum(look) do
        Token = Token .. string.upper(look)
        GetChar()
    end
    SkipWhite()
    return Token
end

--[[ Get a Number --]]

function GetNum ()
    Value = 0
    if not IsDigit(look) then Expected("Integer") end
    while IsDigit(look) do
        Value = 10*Value + tonumber(look)
        GetChar()
    end
    return Value 
end

--[[ Output a String with Tab --]]

function Emit(s)
    io.write(TAB .. s)
end

--[[ Output a String with Tab and CRLF --]]

function EmitLn(s)
    Emit(s)
    print()
end

--[[ Parse and Translate an Identifier --]]

function Ident()
    Name = GetName()
    if look == '(' then
        Match('(')
        Match(')')
        EmitLn("BSR " .. Name)
    else
        EmitLn("MOVE " .. Name .. "(PC),D0")
    end
end

--[[ Parse and Translate a Math Factor --]]

function Factor()
    returnVal = 0
    if look == '(' then
        Match('(')
        returnVal = Expression()
        Match(')')
    else
        returnVal = GetNum()
    end
    return returnVal
end

--[[ Recognize and Translate a Multiply --]]

function Multiply()
    Match('*')
    Factor()
    EmitLn("MULS (SP)+,D0")
end

--[[ Recognize and Translate a Divide --]]

function Divide()
    Match('/')
    Factor()
    EmitLn("MULS (SP)+,D1")
    EmitLn("DIVS D1,D0")
end

--[[ Parse and Translate a Math Term --]]

function Term()
    Value = Factor()
    while look == '*' or look == '/' do
        if look == '*' then
            Match('*')
            Value = Value * Factor()
        elseif look == '/' then
            Match('/')
            --all numbers are floats in Lua
            Value = math.floor(Value / Factor())
        end
    end
    return Value
end



--[[ Recognize and Translate an Add --]]

function Add()
    Match('+')
    Term()
    EmitLn("ADD (SP)+,D0")
end

--[[ Recognize and Translate a Subract --]]

function Subtract()
    Match('-')
    Term()
    EmitLn("SUB (SP)+,D0")
    EmitLn("NEG D0")
end            
   
--[[ Parse and Translate an Expression --]]

function Expression()
    Value = 0
    if IsAddop(look) then Value = 0
    else Value = Term() end
    while IsAddop(look) do
        if look == '+' then
            Match('+')
            Value = Value + Term()
        elseif look == '-' then
            Match('-')
            Value = Value - Term()
        end
    end
    return Value
end

--[[ Parse and Translate an Assignment Statement --]]

function Assignment()
    Name = GetName()
    Match('=')
    Expression()
    EmitLn("LEA " .. Name .. "(PC),A0")
    EmitLn("MOVE D0,(A0)")
end

--[[ Initialize --]]

function Init()
    GetChar()
    SkipWhite()
end

--[[ Main Program --]]

Init()
print(Expression())
