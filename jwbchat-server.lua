os.pullEvent = os.pullEventRaw -- Stop people from quiting, I don't want you messing up Skynet stuff
-- Is this a color terminal? If not, fuck off.
if term.isColor() then
else
 error ("Program made for Advanced Computers!")
end
-- Locate the speaker- fairly intuitive.
local speaker = peripheral.find("speaker")
-- Sound handler I guess, allows editing from config
local function makeSound(soundid)
    if jconfig.sound.stoggle == 1 then -- Sorry for the shitty ordering, I didn't know what order I wanted at the time and I don't feel like rearranging it
        if soundid == 2 then -- Join
            speaker.playNote("xylophone",jconfig.sound.svol,3)
            sleep(0.05)
            speaker.playNote("xylophone",jconfig.sound.svol,5)
        elseif soundid == 3 then -- Leave
            speaker.playNote("xylophone",jconfig.sound.svol,5)
            sleep(0.05)
            speaker.playNote("xylophone",jconfig.sound.svol,3)
        elseif soundid == 1 then -- Message
            speaker.playNote("pling",jconfig.sound.svol,11)
        elseif soundid == 5 then -- Unknown
            speaker.playNote("bell",jconfig.sound.svol,11)
        elseif soundid == 4 then -- Send
            speaker.playNote("snare",jconfig.sound.svol,5)
        elseif soundid == 6 then -- Alt 1
            speaker.playNote("xylophone",jconfig.sound.svol,3)
            sleep(0.05)
            speaker.playNote("xylophone",jconfig.sound.svol,5)
            sleep(0.05)
            speaker.playNote("xylophone",jconfig.sound.svol,6)
        elseif soundid == 7 then -- Alt 2
            speaker.playNote("hat",jconfig.sound.svol,6) 
        end
    end
end
-- Return 1 and 0 as On and Off
local function bin2str(b2s)
    if b2s == 0 then
        return "Off"
    elseif b2s == 1 then
        return "On"
    end
end
-- For printing, get the term size
local w,h = term.getSize()
-- For the main menu
local nOption = 1
 -- Print text centered
function printCentered(y,s)
 local x = math.floor((w - string.len(s)) /2)
 term.setCursorPos(x,y)
 term.clearLine()
 if nOption + 8 == y or y == 7 or (nOption == 6 and nOption + 10 == y) then
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
    c1 = "white",
    c2 = "dark_gray",
    c3 = "red",
    c4 = "gold",
    c5 = "yellow",
    c6 = "dark_green",
    c7 = "blue",
    c8 = "light_purple",
    c9 = "dark_aqua"
}
function d2c(digit)
 local tocolorc = "c" .. digit
 local tocolor = d2clist[tocolorc]
 return tocolor
end
jconfig = {
      chan = "5001",
      name = "Gallifrey-Aternos",
      namc = "7",
      sound = {
          stoggle = 1,
          svol = 3,
          sjoin = 2,
          sexit = 3,
          smessage = 1,
          sunknown = 5,
          ssend = 4
      }
}
-- Config setup for channel

-- Config setup for name

-- Sound config changing

-- Program stuff

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
    else
        -- Chat
        local sUsernameBit = string.match(sMessage, "^<[^>]*>")
        if sUsernameBit then
            vcolor = d2c(tonumber(msg.ucolor))
            vusername = msg.uname
            vmessage = msg.umessage
            commands.exec("/tellraw @a [\"\",{\"text\":\"<" .. vusername .. "> \",\"color\":\"" .. vcolor .."\"},\"" .. vmessage .."\"]")
        else
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
        term.setTextColor(highlightColor)
        write(ssMessage)
        term.setTextColor(textColor)
    else
        -- Chat
        local ssUsernameBit = string.match(ssMessage, "^<[^>]*>")
        if ssUsernameBit then
            term.setTextColor(d2c(tonumber(smsg.ucolor)))
            write(ssUsernameBit)
            term.setTextColor(textColor)
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
                    makeSound(jconfig.sound.smessage)
                 elseif msg.mtype == 1 then
                    makeSound(jconfig.sound.sjoin)
                 elseif msg.mtype == 2 then
                    makeSound(jconfig.sound.sexit)
                 else
                    makeSound(jconfig.sound.sunknown)
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
                     makeSound(jconfig.sound.ssend)
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
shell.run(shell.getRunningProgram())
end

jchat()