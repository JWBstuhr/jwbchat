-- /!\ CONDEMNED
print("You'll have to set your Username, Channel, and Audio again!")
sleep(2)
shell.run("rm " .. shell.getRunningProgram())
shell.run("rm jwbchat.lua")
shell.run("rm /jc/jconfig")
shell.run("wget https://github.com/JWBstuhr/jwbchat/raw/main/jwbchat.lua")
shell.run("jwbchat.lua")
