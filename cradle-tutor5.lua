--[[ Cradle code --]]

--[[ Constant Declarations --]]

TAB = '\t'
CR = '\n'

--[[ Variable Declarations --]]

look = nil    -- Lookahead char
LCount = 0

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

--[[ Match a Specific Input Character --]]

function Match (x)
    if look == x then
        GetChar()
    else
        Expected("'" .. x .. "'")
    end
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

--[[ Get an Identifier --]]

function GetName ()
    if not IsAlpha(look) then Expected('Name') end
    return string.upper(look), GetChar()
end

--[[ Get a Number --]]

function GetNum ()
    if not IsDigit(look) then Expected('Integer') end
    return look, GetChar()
end

--[[ Output a String with Tab --]]

function Emit(s)
    print(TAB .. s)
end

--[[ Output a String with Tab and CRLF --]]

function EmitLn(s)
    Emit(s)
    print()
end

--[[ Recognize and Translate an "Other" --]]

function Other()
    EmitLn(GetName())
end

--[[ Recognize and Translate a Statement Block --]]

function Block()
    while not (look == 'e' 
            or look =='l'
            or look =='p') do
        if look == 'i' then
            DoIf()
        elseif look == 'w' then
            DoWhile()
        else
            Other()
        end
    end
end

--[[ Generate a Unique Label --]]

function NewLabel()
    s = tostring("L" .. LCount)
    LCount = LCount + 1
    return s
end

--[[ Post a Label To Output -]]

function PostLabel(L)
    print(L .. ":")
end

--[[ Parse and Translate a Boolean Condition --]]

function Condition()
    EmitLn("<condition>")
end

--[[ Recognize and Translate an IF Construct --]]

function DoIf()
    Match('i')
    Condition()
    local L1 = NewLabel()
    local L2 = L1
    EmitLn("BEQ " .. L1)
    Block()
    if look == 'l' then
        Match('l')
        L2 = NewLabel()
        EmitLn("BRA " .. L2)
        PostLabel(L1)
        Block()
    end
    Match('e')
    PostLabel(L2)
end

--[[ Parse and Translate a WHILE Statement -]]

function DoWhile()
    Match('w')
    local L1 = NewLabel()
    local L2 = L1
    PostLabel(L1)
    Condition()
    EmitLn("BEQ " .. L2)
    Block()
    Match('e')
    EmitLn("BRA " .. L1)
    PostLabel(L2)
end

--[[ Parse and Translate a LOOP Statement --]]

function DoLoop()
    Match('p')
    L = NewLabel()
    PostLabel(L)
    Block()
    Match('e')
    EmitLn("BRA " .. L)
end

--[[ Parse and Translate a REPEAT Statement --]]

function DoRepeat()

end


--[[ Parse and Translate a Program --]]

function DoProgram()
    Block()
    if look ~= 'e' then Expected('END') end
    EmitLn('END')
end
   
--[[ Initialize --]]

function Init()
    GetChar()
end

--[[ Main Program --]]

Init()
DoProgram()
