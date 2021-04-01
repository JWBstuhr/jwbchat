os.pullEvent = os.pullEventRaw

if term.isColor() then
else
 error ("Program made for Advanced Computers!")
end

local w,h = term.getSize()
 
function printCentered(y,s)
 local x = math.floor((w - string.len(s)) /2)
 term.setCursorPos(x,y)
 term.clearLine()
 term.write(s)
end

function tsave(table,name)
 local file = fs.open(name,"w")
 file.write(textutils.serialize(table))
 file.close()
end
function tload(name)
 local file = fs.open(name, "r")
 local data = file.readAll()
 file.close()
 return textutils.unserialize(data)
end

local function jconfiginit()
 if fs.exists("/jc/jconfig") then
 else
  jconfig = {chan = "",name = "", namc = ""}
  tsave(jconfig,"/jc/jconfig")
 end
end
local function jchan()
 jconfiginit()
 jconfig = tload("/jc/jconfig")
 term.clear()
 term.setCursorPos(1,1)
 inputr = 0
 while inputr < 1 or inputr > 5000 do
 print("Pick a number between 1 and 5000 to connect to.")
 input = read()
 inputr = tonumber(input)
 if inputr > 0 and inputr < 5001 then
  jconfig.chan = input
  tsave(jconfig,"/jc/jconfig")
 else
  print("Not in the range.")
  sleep(2)
 end
 end
 sleep(1)
 shell.run(shell.getRunningProgram())
end
local function jname()
 jconfiginit()
 term.setTextColor( colors.white )
 jconfig = tload("/jc/jconfig")
 term.clear()
 term.setCursorPos(1,1)
 print("Set your username. Keep it to simple alphanumerics, and no spaces.")
 input = read()
 jconfig.name = input
 inputr = 8
 while inputr > 6 or inputr < 1 do
  term.clear()
  term.setCursorPos(1,1)
  print("Set your username color.")
  print("1 - White")
  term.setTextColor( colors.gray )
  print("2 - Gray")
  term.setTextColor( colors.red )
  print("3 - Red")
  term.setTextColor( colors.yellow )
  print("4 - Yellow")
  term.setTextColor( colors.blue )
  print("5 - Blue")
  term.setTextColor( colors.green )
  print("6 - Green")
  term.setTextColor( colors.white )
  input = read()
  inputr = tonumber(input)
  if inputr < 7 and inputr > 0 then
   jconfig.namc = input
   tsave(jconfig,"/jc/jconfig")
  else
   print("Not an option.")
   sleep(2)
  end
 end
 sleep(1)
 shell.run(shell.getRunningProgram())
end
local function jchat()
 term.clear()
 term.setCursorPos(1,1)
 jconfig = tload("/jc/jconfig")
 if jconfig.name == "" then 
  error("No username!")
 end
 if jconfig.namc == "" then
  error("No username color!")
 end
 if jconfig.chan == "" then
  error("No channel!")
 end

 -- Skynet installing
if fs.exists("/jc/skynet.lua") then
else
 local a=http.get"https://raw.githubusercontent.com/osmarks/skynet/master/client.lua"local b=fs.open("/jc/skynet.lua","w")b.write(a.readAll())a.close()b.close()
 _G.skynet_CBOR_path = "/jc/cbor.lua"
end
-- Import Skynet functions
skynet = dofile("/jc/skynet.lua")

 -- Copied from program chat.lua
 local parentTerm = term.current()
 local titleWindow = window.create(parentTerm, 1, 1, w, 1, true)
 local historyWindow = window.create(parentTerm, 1, 2, w, h - 2, true)
 local promptWindow = window.create(parentTerm, 1, h, w, 1, true)
 historyWindow.setCursorPos(1, h - 2)
  -- Copied from program chat.lua, edited colors
local textColor = colors.white
local highlightColor = colors.lightBlue
 -- Copied from program chat.lua
 term.clear()
 term.setTextColor(textColor)
 term.redirect(promptWindow)
 promptWindow.restoreCursor()
 -- Copied from program chat.lua, edited variables
 local function drawTitle()
    local w = titleWindow.getSize()
    local sTitle = jconfig.name .. " on " .. jconfig.chan
    titleWindow.setTextColor(highlightColor)
    titleWindow.setCursorPos(math.floor(w / 2 - #sTitle / 2), 1)
    titleWindow.clearLine()
    titleWindow.write(sTitle)
    promptWindow.restoreCursor()
 end
 drawTitle()
  -- Copied from program chat.lua
 local function printMessage(sMessage)
    term.redirect(historyWindow)
    print()
    if string.match(sMessage, "^%*") then
        -- Information
        term.setTextColour(highlightColor)
        write(sMessage)
        term.setTextColour(textColor)
    else
        -- Chat
        local sUsernameBit = string.match(sMessage, "^<[^>]*>")
        if sUsernameBit then
            term.setTextColour(highlightColor)
            write(sUsernameBit)
            term.setTextColour(textColor)
            write(string.sub(sMessage, #sUsernameBit + 1))
        else
            write(sMessage)
        end
    end
     -- Copied from program chat.lua
    term.redirect(promptWindow)
    promptWindow.restoreCursor()
end
local ok, error = pcall(parallel.waitForAny,
 function()
     -- Copied from program chat.lua, edited sending
 local tSendHistory = {}
            while true do
                promptWindow.setCursorPos(1, 1)
                promptWindow.clearLine()
                promptWindow.setTextColor(highlightColor)
                promptWindow.write(": ")
                promptWindow.setTextColor(textColor)

                local sChat = read(nil, tSendHistory)
                if string.match(sChat, "^/logout") then
                    break
                else
                    
                    table.insert(tSendHistory, sChat)
                end
            end
 end
)
-- Close the windows, Copied from program chat.lua
term.redirect(parentTerm)
term.clear()
term.setCursorPos(1,1)

end
 
local nOption = 1
jconfiginit()
local function drawMenu()
 term.clear()
 term.setCursorPos(1,1)
 term.write("JWBChat")
 term.setCursorPos(w-11,1)
 if nOption == 1 then
  term.write("Join")
 elseif nOption == 2 then
  term.write("Setting 1")
 elseif nOption == 3 then
  term.write("Setting 2")
 elseif nOption == 4 then
  term.write("Exit")
 else
 end
end
 
term.clear()
local function drawFrontend()
 printCentered(math.floor(h/2) - 3, "")
 printCentered(math.floor(h/2) - 2, "Main Menu")
 printCentered(math.floor(h/2) - 1, "")
 printCentered(math.floor(h/2) + 0, ((nOption == 1) and "[ Join            ]") or "Join           ")
 printCentered(math.floor(h/2) + 1, ((nOption == 2) and "[ Change Channel  ]") or "Change Channel ")
 printCentered(math.floor(h/2) + 2, ((nOption == 3) and "[ Change Username ]") or "Change Username")
 printCentered(math.floor(h/2) + 3, ((nOption == 4) and "[ Exit            ]") or "Exit           ")
end
 
drawMenu()
drawFrontend()

if fs.exists("/jc") then
else
 fs.makeDir("/jc")
end
 
while true do
 local e,p = os.pullEvent("key")
  if e == "key" then
   local key = p
   if key == keys.w or key == keys.up then
    if nOption > 1 then
     nOption = nOption - 1
     drawMenu()
     drawFrontend()
    end
   elseif key == keys.s or key == keys.down then
    if nOption < 4 then
     nOption = nOption + 1
     drawMenu()
     drawFrontend()
    end
   elseif key == keys.enter then
    break
   end
  end
 end
term.clear()
 
if nOption == 1 then
 jchat()
elseif nOption == 2 then
 jchan()
elseif nOption == 3 then
 jname()
elseif nOption == 4 then
 term.clear()
 term.setCursorPos(1,1)
end
