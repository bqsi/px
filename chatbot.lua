-- Chat Bot Script, made by alexa#0001 / pxl on V3rmillion.
-- I don't mind you using this code, modifying it, or anything like that.
-- No bullshit licenses, no terms, whitelists, etc.
-- Please do credit me if you find the kindness in your heart and you're reposting this somewhere.
-- I'll be commenting most of the code if you wanna read it.
-- You need gethiddenproperty for the !age command to work.

-- Just in-case you slap this in an autoexec.
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- LocalPlayer, ChatRequest / ChatRemote, Player Service and HTTPService variables. Just some shorthands.
local lp,cr,p,http,sgui = game.Players.LocalPlayer,game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest, game:GetService('Players'), game:GetService('HttpService'), game:GetService('StarterGui')
local char = lp.Character

-- Prevent double executions.
getgenv().cbG = cbG or {}
local cons = {cbG.allcon, cbG.allcon2, cbG.pcon}
if cbG.ChatBotActive then for i,v in pairs(cons) do if v then v:Disconnect() end end end
cbG.ChatBotActive = true
local Active = true
local AcceptingOthers = true
local FireWarnings = true

-- Return a string with title casing.
-- e.g "hello" -> "Hello"
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function fireDialog(text, type)
    sgui:SetCore('ChatMakeSystemMessage', {
        Text = text,
        Color = (type == "error" and Color3.fromRGB(255,0,0)) or (type == "warning" and Color3.fromRGB(255,255,0)) or (type == "dialog" and Color3.fromRGB(255,223,0)),
        Font = Enum.Font.Code,
        TextSize = 20,
    })
end

-- Shorthand for game:HttpGet.
local HttpGet = function(link)
    local content
    local success, response = pcall(function()
        content = game:HttpGet(link)
    end)
    if not success then warn'API Call Failed. Check your link!' end
    return content
end

-- Shorthand to teleport the localplayer to someone.
function TeleportTo(plr)
    if not lp.Character then lp.CharacterAdded:Wait() end
    local char = lp.Character
    char.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.pi,0) * CFrame.new(0,0,3) + Vector3.new(-2,0,0)
    return true
end

-- I'll list all the APIs in a table for easy access later.
local APILinks = {
	['!compliment'] = "https://complimentr.com/api",
	['!insult'] = "https://insult.mattbas.org/api/insult",
	['!randomfact'] = "https://uselessfacts.jsph.pl/random.json",
	['!joke'] = "https://official-joke-api.appspot.com/random_joke",
	['!verse'] = "https://quotes.rest/bible/verse.json"
}

-- A simple FindPlayer function which supports partial names.
-- I already wrote this myself, so I just nabbed it from an old script.
function FindPlayer(name)
    if name == nil then return end
	local Match
	for _,plr in pairs(p:GetPlayers()) do
		if plr.Name:lower():sub(1, #name) == name:lower() then
			Match = plr
			break
		end
	end
	return Match
end

-- We'll need this.
local db = false

-- List all command aliases along with their respective functions.
-- Not all will need an API link, so that's fine. We just won't call one.
-- I'm not commenting on ALL of these functions. Fuck that.
local CommandFunctions = {
    ['!compliment'] = function(args, api) -- API is totally optional. Args is not. We'll need a target each time. Well, sometimes.
        if not args[1] then fireDialog("This command works better with arguments! Try adding a name!", "warning") end
        local content = http:JSONDecode(HttpGet(api)) -- Retrieve content from an API
        if content == nil then return; end -- If the call failed, exit the function to prevent errors
        local compliment = content.compliment -- Get the compliment from the JSON table
		local target = FindPlayer(args[1]) or nil -- Find the player or have no target
		if char.Parent ~= workspace then return; end -- If we're dead, exit the function to prevent errors
		if target then TeleportTo(target) end -- TP to the target
		cr:FireServer(firstToUpper(compliment), "All") -- say nice thing :)
	end,
    ['!insult'] = function(args, api)
        if not args[1] then fireDialog("This command works better with arguments! Try adding a name!", "warning") end
        local target = FindPlayer(args[1]) or nil
        local content = target and HttpGet(api.."?who="..target.Name) or HttpGet(api)
        if content == nil then return; end
		if char.Parent ~= workspace then return; end
		if target then char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0) end
		cr:FireServer(content, "All")
	end,
    ['!randomfact'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
        local content = http:JSONDecode(HttpGet(api.."?language=en")).text
        if content == nil then return; end
        cr:FireServer(firstToUpper(content), "All")
	end,
    ['!joke'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
        local content = http:JSONDecode(HttpGet(api))
        if content == nil then return; end
        local setup,pl = content.setup,content.punchline
        cr:FireServer(firstToUpper(setup), "All")
        wait(2)
        cr:FireServer(firstToUpper(pl), "All")
	end,
    ['!verse'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
        local content = http:JSONDecode(HttpGet(api))
        if content == nil then return; end
        local contents = content.contents
        local verse = contents.verse
        local book = contents.book
        local chapter = contents.chapter
        local number = contents.number
        cr:FireServer("'"..verse.."' - "..book.." "..chapter..":"..number, "All")
	end,
    ['!age'] = function(args, api)
        if args[1] == nil then fireDialog("Missing required arguments from !age. Try !age "..lp.Name, "error"); return end
        local tar = FindPlayer(args[1])
        if not gethiddenproperty or not gethidden then fireDialog("!age does not work - your exploit does not support gethiddenproperty!", "warning") end
        local age = gethiddenproperty(tar, "AccountAge") or gethidden(tar, "Account Age")
        cr:FireServer(tar.Name.."'s account is "..age.." days old.", "All")
	end,
    ['!spank'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
		local phrases = {
            "Waah~!",
            "Aah! Be careful..",
            "Onii-Chan!",
            "Hey, be gentle..!~",
            "Ahaaa..! Stop it~!"
        }
        wait(.1)
        local text = phrases[math.random(1, #phrases)]
        cr:FireServer(text, "All")
	end,
    ['!randomnum'] = function(args, api)
        local num = args[1]:match("%d")
        if not num then fireDialog("Invalid arguments provided for !randomnum. Try '!randomnum 10'", "error"); return end
        cr:FireServer("Your random number is "..math.random(1, tonumber(args[1])), "All")
    end,
    ['!flipcoin'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
        local rand = math.random(1,2)
        local text = rand == 1 and "I flipped heads!" or "I flipped tails!"
        cr:FireServer(text, "All")
    end,
    ['!cmds'] = function(args, api)
        if args[1] then fireDialog("This command does not need arguments! Avoid using them!", "warning") end
        warn("Chat Bot Commands\
        \
        '!compliment <plr>' - Compliments said player. If no player is supplied, you will not be teleported.\
        '!insult <plr>' - Insults said player. If no player is supplied, you will not be teleported.\
        '!randomfact' - Supplies a random fact.\
        '!joke' - Supplies a random joke.\
        '!verse' - Supplies a random bible verse.\
        '!age <plr>' - Chats a player's account age. If no player is supplied, this will not work.\
        '!spank' - Ahh~! Be careful please...\
        '!randomnum <max number>' - Supplies a random number from 1 to <max number>. Requires <max number>.\
        '!flipcoin' - Flips a coin and chats the result.\
        '!cmds' - Prints this dialog.\
        '!off / !on' - Disables / enables chat commands.\
        '!acceptothers / !denyothers' - Disables / enables others being able to execute commands.\
        '!togglewarnings' - Toggles the warnings you get if you give a command something it doesn't need.")
        sgui:SetCore('ChatMakeSystemMessage', {
            Text = "Printed commands in console. Press F9.",
            Color = Color3.fromRGB(255,223,0),
            Font = Enum.Font.Code,
            TextSize = 20
        })
    end,
    ['!off'] = function(...)
        Active = false
        fireDialog("Disabled Commands. Use !on to turn them on again.", "dialog")
    end,
    ['!on'] = function(...)
        Active = true
        fireDialog("Enabled Commands. Use !off to turn them off again.", "dialog")
    end,
    ['!acceptothers'] = function(...)
        AcceptingOthers = true
        fireDialog("Now accepting commands from others. Use !denyothers to disable this.", "dialog")
    end,
    ['!denyothers'] = function(...)
        AcceptingOthers = false
        fireDialog("Now denying commands from others. Use !acceptothers to enable this.", "dialog")
    end,
    ['!togglewarnings'] = function(...)
        FireWarnings = not FireWarnings
        fireDialog((FireWarnings and "Warnings now enabled. !togglewarnings to disable.") or (not FireWarnings and "Warnings now enabled. !togglewarnings to disable."), "dialog")
    end
}

function Chatted(text)
	if text:sub(1,2) == "/e" then text = text:sub(4) end
    if not Active and text ~= "!on" and text ~= "!off" then return end
    -- If they don't use the correct prefix, don't count their message.
	if not text:sub(1,1) == "!" then return end
	-- Split the text into the command itself and any arguments.
    local split, arg = text:split(" ")
    arg = split[2] or nil
	-- If what they typed is a valid command, register such.
	local MatchedCommand = CommandFunctions[split[1]] and split[1] or nil
	-- If they did not match a command, exit the function.
    if not MatchedCommand then return end
    if db then return end
    db = true
    coroutine.resume(coroutine.create(function()
        wait(1)
        db = false
    end))
	-- If there is a valid API link attached to the command, call the command function WITH the API link as an arg.
	if APILinks[MatchedCommand] then
        CommandFunctions[MatchedCommand]({arg}, APILinks[MatchedCommand])
    else
        CommandFunctions[MatchedCommand]({arg})
	end
end

for _,p in pairs(p:GetPlayers()) do
    if lp:IsFriendsWith(p.UserId) or lp == p then
        cbG.pcon = p.Chatted:Connect(function(text)
            if AcceptingOthers or lp == p then
                Chatted(text)
            elseif AcceptingOthers and lp ~= p then
                TeleportTo(p)
                Chatted(text)
            end
        end)
    end
end

-- When players join the game and if they chat, fire the Chatted event.
cbG.allcon = p.PlayerAdded:Connect(function(plr)
    if lp:IsFriendsWith(plr.UserId) then
        cbG.allcon2 = plr.Chatted:Connect(function(text)
            if AcceptingOthers then
                TeleportTo(plr)
                Chatted(text)
            end
        end)
    end
end)

-- Display a 'loaded' message.
fireDialog("Chat bot loaded! Made by alexa#0001 / pxl on V3rmillion.", "dialog")
fireDialog("Happy chatting!", "dialog")

CommandFunctions['!cmds']({nil})
CommandFunctions['!denyothers']({nil})
