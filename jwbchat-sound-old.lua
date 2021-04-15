os.pullEvent = os.pullEventRaw -- Stop people from quiting, I don't want you messing up Skynet stuff
-- Is this a color terminal? If not, fuck off.
if term.isColor() then
else
 error ("Program made for Advanced Computers!")
end
-- Locate the speaker- fairly intuitive.
local speaker = peripheral.find("speaker")
-- For printing, get the term size
local w,h = term.getSize()
-- For the main menu
local nOption = 1
 -- Print text centered
function printCentered(y,s)
 local x = math.floor((w - string.len(s)) /2)
 term.setCursorPos(x,y)
 term.clearLine()
 if nOption + 8 == y or y == 7 then
  term.setTextColor( colors.lightBlue )
 else
  term.setTextColor( colors.white )
 end
 term.write(s)
end
-- Table tools, save and load to and from files
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
-- This set of wonderful functions is about turning a number into a color
local d2clist = {
    c1 = colors.white,
    c2 = colors.gray,
    c3 = colors.red,
    c4 = colors.orange,
    c5 = colors.yellow,
    c6 = colors.green,
    c7 = colors.blue,
    c8 = colors.purple,
    c9 = colors.lightBlue
}
function d2c(digit)
 local tocolorc = "c" .. digit
 local tocolor = d2clist[tocolorc]
 return tocolor
end
-- Check if the config exists, if not, make it
local function jconfiginit()
 if fs.exists("/jc/jconfig") then
 else
  jconfig = {chan = "",name = "", namc = ""}
  tsave(jconfig,"/jc/jconfig")
 end
end
-- Config setup for channel
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
-- Config setup for name
local function jname()
 jconfiginit()
 term.setTextColor( colors.white )
 jconfig = tload("/jc/jconfig")
 term.clear()
 term.setCursorPos(1,1)
 print("Set your username. Keep it to simple alphanumerics, and no spaces.")
 input = read()
 jconfig.name = input
 inputr = 9
 while inputr > 8 or inputr < 1 do
  term.clear()
  term.setCursorPos(1,1)
  print("Set your username color.")
  print("1 - White")
  term.setTextColor( colors.gray )
  print("2 - Gray")
  term.setTextColor( colors.red )
  print("3 - Red")
  term.setTextColor( colors.orange )
  print("4 - Orange")
  term.setTextColor( colors.yellow )
  print("5 - Yellow")
  term.setTextColor( colors.green )
  print("6 - Green")
  term.setTextColor( colors.blue )
  print("7 - Blue")
  term.setTextColor( colors.purple )
  print("8 - Purple")
  term.setTextColor( colors.white )
  input = read()
  inputr = tonumber(input)
  if inputr < 9 and inputr > 0 then
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
-- Main function, running the chat
local function jchat()
 term.clear()
 term.setCursorPos(1,1)
 jconfig = tload("/jc/jconfig")
 if jconfig.name == "" then 
  error("No username!") -- You need a username dude
 end
 if jconfig.namc == "" then
  error("No username color!") -- This is theoretically impossible to achieve but HEY, PEOPLE ALWAYS FIND A WAY
 end
 if jconfig.chan == "" then
  error("No channel!") -- You.. need something to join
 end

 -- Skynet installing
if fs.exists("/jc/skynet.lua") then
else
 local a=http.get"https://raw.githubusercontent.com/osmarks/skynet/master/client.lua"local b=fs.open("/jc/skynet.lua","w")b.write(a.readAll())a.close()b.close()
end
_G.skynet_CBOR_path = "/jc/cbor.lua"
-- Import Skynet functions
skynet = dofile("/jc/skynet.lua")
skynet.open(1503)

 -- Copied from program chat.lua, window setup
 local parentTerm = term.current()
 local titleWindow = window.create(parentTerm, 1, 1, w, 1, true)
 local historyWindow = window.create(parentTerm, 1, 2, w, h - 2, true)
 local promptWindow = window.create(parentTerm, 1, h, w, 1, true)
 historyWindow.setCursorPos(1, h - 2)
  -- Copied from program chat.lua, edited colors, color setup
local textColor = colors.white
local highlightColor = colors.lightBlue
 -- Copied from program chat.lua, 
 term.clear()
 term.setTextColor(textColor)
 term.redirect(promptWindow)
 promptWindow.restoreCursor()
 -- Copied from program chat.lua, edited variables
local function drawTitle()
    local w = titleWindow.getSize()
    local sTname = jconfig.name
    local sTitle = " on " .. jconfig.chan
    local sFull = sTname .. sTitle
    titleWindow.setTextColor(highlightColor)
    titleWindow.setCursorPos(math.floor(w / 2 - #sFull / 2), 1)
    titleWindow.clearLine()
    titleWindow.setTextColor(d2c(tonumber(jconfig.namc)))
    titleWindow.write(sTname)
    titleWindow.setTextColor(highlightColor)
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
            term.setTextColour(d2c(tonumber(msg.ucolor)))
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
-- Local printmessage basically. It just runs off of smsg instead of umsg- explained later
local function printMessageL(ssMessage)
    term.redirect(historyWindow)
    print()
    if string.match(ssMessage, "^%*") then
        -- Information
        term.setTextColour(highlightColor)
        write(ssMessage)
        term.setTextColour(textColor)
    else
        -- Chat
        local ssUsernameBit = string.match(ssMessage, "^<[^>]*>")
        if ssUsernameBit then
            term.setTextColour(d2c(tonumber(smsg.ucolor)))
            write(ssUsernameBit)
            term.setTextColour(textColor)
            write(string.sub(ssMessage, #ssUsernameBit + 1))
        else
            write(ssMessage)
        end
    end
     -- Copied from program chat.lua
    term.redirect(promptWindow)
    promptWindow.restoreCursor()
end
-- Skynet, handles incoming messages
local function openSkynet()
    while true do
        evt, channel, msg = os.pullEvent("skynet_message")
        if msg.channel ~= nil and channel == 1503 then
            if msg.channel == jconfig.chan then
                local fullmsg = "<" .. msg.uname .. "> " .. msg.umsg
                printMessage(fullmsg)
                if speaker ~= nil then
                 if msg.mtype == 0 then
                  speaker.playNote("pling",3,11)
                  --speaker.playNote("xylophone",3,3)
                  --sleep(0.05)
                  --speaker.playNote("xylophone",3,5)
                  --sleep(0.05)
                  --speaker.playNote("xylophone",3,6)
                 elseif msg.mtype == 1 then
                  speaker.playNote("xylophone",3,3)
                  sleep(0.05)
                  speaker.playNote("xylophone",3,5)
                 elseif msg.mtype == 2 then
                  speaker.playNote("xylophone",3,5)
                  sleep(0.05)
                  speaker.playNote("xylophone",3,3)
                 else
                  speaker.playNote("bell",3,11)
                 end
                end
            end
        end
    end
end
-- Chat sending
local function mainChat()
            local tSendHistory = {}
             while true do
                 promptWindow.setCursorPos(1, 1)
                 promptWindow.clearLine()
                 promptWindow.setTextColor(highlightColor)
                 promptWindow.write(": ")
                 promptWindow.setTextColor(textColor)
                 local sChat = read()
                 if string.match(sChat, "^/logout") then
                    local exitMsg = jconfig.name .. " has left!"
                    local exitInfo = {
                        channel = "",
                        umsg = "",
                        uname = "*System*",
                        ucolor = "9",
                        mtype = 2
                    }
                    exitInfo["channel"] = jconfig.chan
                    exitInfo["umsg"] = exitMsg
                    skynet.send(1503,exitInfo)
                    skynet.disconnect()
                    break
                 else
                    smsg = {
                        channel = "",
                        umsg = "",
                        uname = "",
                        ucolor = "",
                        mtype = 0
                    }
                    smsg["channel"] = jconfig.chan
                    smsg["umsg"] = sChat
                    smsg["uname"] = jconfig.name
                    smsg["ucolor"] = jconfig.namc
                    skynet.send(1503,smsg)
                    local smsgfull = "<" .. smsg.uname .. "> " .. smsg.umsg
                    printMessageL(smsgfull)
                    if speaker ~= nil then
                     speaker.playNote("snare",3,5)
                    end
                 end
             end
end
-- Data for your joining message
local joinedMsg = jconfig.name .. " has joined!"
local joinedInfo = {
    channel = "",
    umsg = "",
    uname = "*System*",
    ucolor = "9",
    mtype = 1
}
joinedInfo["channel"] = jconfig.chan
joinedInfo["umsg"] = joinedMsg
skynet.send(1503,joinedInfo)
-- Print the tip
printMessageL("* Type /logout to exit. It will alert others that you left and properly disconnect.")
-- Begin.
local ok, error = pcall(parallel.waitForAny(skynet.listen,openSkynet,mainChat))
-- Close the windows, Copied from program chat.lua
term.redirect(parentTerm)
term.clear()
term.setCursorPos(1,1)

end
 
jconfiginit()
-- Menu
local function drawMenu()
 term.clear()
 term.setCursorPos(1,1)
 term.setTextColor( colors.lightBlue )
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
-- More Menu
term.clear()
local function drawFrontend()
 printCentered(math.floor(h/2) - 3, "")
 term.setTextColor( colors.lightBlue )
 printCentered(math.floor(h/2) - 2, "JWBchat: Your place to talk.")
 term.setTextColor( colors.white )
 printCentered(math.floor(h/2) - 1, "")
 printCentered(math.floor(h/2) + 0, ((nOption == 1) and "[ Join            ]") or "Join           ")
 printCentered(math.floor(h/2) + 1, ((nOption == 2) and "[ Change Channel  ]") or "Change Channel ")
 printCentered(math.floor(h/2) + 2, ((nOption == 3) and "[ Change Username ]") or "Change Username")
 printCentered(math.floor(h/2) + 3, ((nOption == 4) and "[ Exit            ]") or "Exit           ")
end
 
drawMenu()
drawFrontend()
-- Make the JWBchat directory
if fs.exists("/jc") then
else
 fs.makeDir("/jc")
end
-- Keys n stuff for the menu
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
-- Do stuff
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
