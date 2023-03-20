-- /!\ CONDEMNED
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

local function printMessage(sMessage)
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

-- Begin.
local ok, error = pcall(parallel.waitForAny(skynet.listen,openSkynet))
-- Close the windows, Copied from program chat.lua
term.redirect(parentTerm)
term.clear()
term.setCursorPos(1,1)
shell.run(shell.getRunningProgram())
end

jchat()
