repeat task.wait() until game.Loaded

local Client = setmetatable({}, {__index = function(self, Value) return rawget(self,Value) or game:GetService(Value) end})
Client.LocalPlayer = Client.Players.LocalPlayer
Client.Mouse = Client.LocalPlayer:GetMouse()

getgenv().saveFileName = 'Anime-Adventures_' .. Client.LocalPlayer.Name .. '.json'

--// VARIABLES
local unitConversion = Client.HttpService:JSONDecode(game:HttpGet 'https://raw.githubusercontent.com/iIUyfbbfu/uvu/main/unitConversion.json')
local GenvVariables = {
    -- MISC
    hideName = false,
    antiAfk = true,
    
    --FARM
    autoSell = false,
    autoFarm = false,
    autoStart = false,
    autoAbility = false,
    autoSummonGEM = false,
    autoSummonTICKET = false,
    autoUpgrade = false,
    
    world = false,
    difficulty = 'Normal',
    sellAtWave = 0,

    -- PRIORITY
    placePriorityEnabled = false,
    upgradePriorityEnabled = false,
    placePriority = {
        U1 = '0',
        U2 = '0',
        U3 = '0',
        U4 = '0',
        U5 = '0',
        U6 = '0'
    },
    upgradePriority = {
        U1 = '0',
        U2 = '0',
        U3 = '0',
        U4 = '0',
        U5 = '0',
        U6 = '0'
    },

    webhook = false,
    webhookUrl = false,
    webhookMention = false,
    webhookMentionID = false,

    SpawnUnitPos = {
        UP1 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        },

        UP2 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        },

        UP3 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        },

        UP4 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        },

        UP5 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        },

        UP6 = {
            x = -2952.81689453125,
            y = 91.80620574951172,
            z = -707.9673461914062
        }
    },
    SelectedUnits = {
        U1 = nil,
        U2 = nil,
        U3 = nil,
        U4 = nil,
        U5 = nil,
        U6 = nil
    },
    autoUnitSell = false,
    unitTypeToSell = false,
    level = 'nil',
    door = 'nil',
}
local Endpoints = setmetatable(
    {
        'spawn_unit',
        'redeem_code',
        'vote_wave_skip',
        'sell_unit_ingame',
        'use_active_attack',
        'buy_random_fighter',
        'upgrade_unit_ingame',
        'save_notifications_state'
    },
    {__index = function(_, Value) return Client.ReplicatedStorage.endpoints['client_to_server'][Value] end}
)

local codes = {
    'FIRSTRAIDS',
    'DATAFIX',
    'MARINEFORD',
    'TWOMILLION',
    'SORRYFORSHUTDOWN',
    'CHALLENGEFIX',
    'GINYUFIX',
    'RELEASE',

    'subtomaokuma',
    'subtosnowrbx',
    'SubToKelvingts',
    'SubToBlamspot',
    
    'KingLuffy',
    'TOADBOIGAMING',
    'noclypso',
    'FictioNTheFirst',
    'Cxrsed'
}

do
    local new = {}
    local new2 = {}

    for i, v in next, unitConversion do
        table.insert(new, i)
        table.insert(new2, v)
    end

    unitConversion = {
        CollectableName = new,
        InGameUnitName = new2
    }
end

--// JSON Settings Save File
local loadSaveFile = function()
    local jsonData do
        if not isfile(saveFileName) then
            writefile(saveFileName, Client.HttpService:JSONEncode(GenvVariables))
        end
        jsonData = readfile(saveFileName)
    end
    local data = Client.HttpService:JSONDecode(jsonData)

    table.foreach(GenvVariables, function(i,v)
        if data[i] then
            getgenv()[i] = data[i]
        else
            getgenv()[i] = v
        end
    end)
end

local saveSaveFile = function()
    local data = {}
    table.foreach(GenvVariables, function(i,_)
        data[i] = getgenv()[i]
    end)
    local json = Client.HttpService:JSONEncode(data)
    writefile(saveFileName, json)
end

getgenv().levels = getgenv().levels or {}
loadSaveFile()

--// Discord
local Post = function()
    if not getgenv().webhookUrl or getgenv().webhookUrl == '' then return end
    local passOrFail do
        if getgenv().autoSell then
            if tonumber(getgenv().sellAtWave) and (tonumber(getgenv().sellAtWave) ~= 0) and (tonumber(getgenv().sellAtWave) <= workspace:FindFirstChild('_wave_num').Value) then
                passOrFail = 'PASS'
            else
                passOrFail = 'FAIL'
            end
        else
            passOrFail = 'PASS'
        end
    end
	local color = ((passOrFail == 'PASS') and 110335) or 16711680

    local Stats = Client.LocalPlayer:WaitForChild('_stats')
    local PlayerGui = Client.LocalPlayer:WaitForChild('PlayerGui')
    local Holder = PlayerGui:WaitForChild('ResultsUI'):WaitForChild('Holder')

    local WaveCount do
        local succ,_ = pcall(function() WaveCount = select(1, Holder:WaitForChild('Middle'):WaitForChild('WavesCompleted').Text:gsub('%D+','')) end)
        if not succ or WaveCount == '999' then succ,_ = pcall(function() WaveCount = PlayerGui:WaitForChild('Waves'):WaitForChild('HealthBar'):WaitForChild('WaveNumber').Text end) end
        if not succ then WaveCount = 'Unable to Obtain Data!' end
    end

    local TimeCount do
        local succ,_ = pcall(function() TimeCount = select(1, Holder:WaitForChild('Middle'):WaitForChild('Timer').Text:gsub('Total Time: ', '')) end)
        if not succ then TimeCount = 'Unable to Obtain Data!' end
    end

    local info = {
        XP = tostring(Holder:WaitForChild('GoldGemXP'):WaitForChild('XPReward').Main.Amount.Text),
        Gems = tostring(Holder:WaitForChild('GoldGemXP'):WaitForChild('GemReward').Main.Amount.Text),
        Waves = tostring(WaveCount),
        Time = tostring(TimeCount),
    }

    local data = {
        content = '<@' .. (getgenv().webhookMention and getgenv().webhookMentionID and tostring(getgenv().webhookMentionID)) .. '>',
        username = 'Anime Adventures',
        avatar_url = 'https://tr.rbxcdn.com/e5b5844fb26df605986b94d87384f5fb/150/150/Image/Jpeg',
        embeds = {
            {
                author = {
                    name = 'Anime Adventures | ' .. passOrFail,
                    icon_url = 'https://cdn.discordapp.com/emojis/997123585476927558.webp?size=96&quality=lossless'
                },
                description = Client.LocalPlayer.Name,
                color = color,
                thumbnail = {
                    url = 'https://www.roblox.com/headshot-thumbnail/image?userId=' .. Client.LocalPlayer.UserId .. '&width=420&height=420&format=png'
                },

                fields = {
                    {name = 'Waves: ', value = info.Waves},
                    {name = 'Gems Got: ', value = info.Gems},
                    {name = 'XP Got: ', value = info.XP},
                    {name = 'Time: ', value = info.Time},
                    {name = 'Current Gems: ', value = tostring(Stats.gem_amount.Value)},
                    {name = 'Current Level: ', value = tostring(PlayerGui.spawn_units.Lives.Main.Desc.Level.Text)},
                }
            }
        }
    }

	pcall(function()
        request = http_request or request or HttpPost or syn.request or http.request
        request({
            Url = getgenv().webhookUrl,
            Method = 'POST',
            Body = Client.HttpService:JSONEncode(data),
            Headers = {
                ['content-type'] = 'application/json'
            }
        })
	end)
end

--// Making UI
local DiscordLib = loadstring(game:HttpGet 'https://raw.githubusercontent.com/iIUyfbbfu/uvu/main/DiscordUI.lua')()
local win = DiscordLib:Window('Exploit v0.0.3' .. ' - ' .. tostring(identifyexecutor()))

local Server = win:Server('Anime Adventures', 'http://www.roblox.com/asset/?id=6031075938')
local Misc_Channel = Server:Channel('Misc')
local Units_Channel = Server:Channel('Units')
local Farming_Channel = Server:Channel('Farming')
local Position_Channel do if game.PlaceId ~= 8304191830 then Position_Channel = Server:Channel('Position') end end
local Priority_Channel = Server:Channel('Priority')
local Webhook_Channel = Server:Channel('Webhook')

local PriorityServer = win:Server('Priority', 'http://www.roblox.com/asset/?id=4949649813')
local Placing_Channel = PriorityServer:Channel('Placing')
local Upgrading_Channel = PriorityServer:Channel('Upgrading')

local ErrorNotif = function(need)
    DiscordLib:Notification(
        'Warning',
        'Please input a ' .. need .. '!',
        'Okay'
    )
end

--// Tabs [[MISC]]
Misc_Channel:Toggle('Hide Name', getgenv().hideName, function(bool)
    getgenv().hideName = bool
    saveSaveFile()
end)
Misc_Channel:Toggle('Anti Afk', getgenv().antiAfk, function(bool)
    getgenv().antiAfk = bool
    saveSaveFile()
end)

--// Tabs [[UNITS]]
Units_Channel:Label('Equip units to allow Farming to Work!')
Units_Channel:Seperator()
local Units = {}

local loadUnit = function()
    local PlayerGui = Client.LocalPlayer:WaitForChild('PlayerGui')
    repeat task.wait() until
        PlayerGui:FindFirstChild('collection')
        and PlayerGui.collection:FindFirstChild('grid')
        and PlayerGui.collection.grid:FindFirstChild('List')
        and PlayerGui.collection.grid.List:FindFirstChild('Outer')
        and PlayerGui.collection.grid.List.Outer:FindFirstChild('UnitFrames')

    task.wait(2)
    table.clear(Units)
    pcall(function()
        for _, v in next, PlayerGui:WaitForChild('collection'):WaitForChild('grid'):WaitForChild('List'):WaitForChild('Outer'):WaitForChild('UnitFrames'):GetChildren() do
            if (v.Name == "CollectionUnitFrame") and v['name'] and v:FindFirstChild('_uuid') then
                table.insert(Units, v.name.Text .. " #" .. v._uuid.Value)
            end
        end
    end)
end
loadUnit()

local Equip = function()
    Endpoints.unequip_all:InvokeServer()
    for i = 1, 6 do
        local unitinfo = getgenv().SelectedUnits["U" .. i]
        if unitinfo ~= nil then
            local unitinfo_ = unitinfo:split(" #")
            task.wait(0.3)
            Endpoints.equip_unit:InvokeServer(unitinfo_[2])
        end
    end
    saveSaveFile()
end

local drop = Units_Channel:Dropdown("Unit 1", Units, getgenv().SelectedUnits["U1"], function(bool)
    getgenv().SelectedUnits["U1"] = bool
    Equip()
end)

local drop2 = Units_Channel:Dropdown("Unit 2", Units, getgenv().SelectedUnits["U2"], function(bool)
    getgenv().SelectedUnits["U2"] = bool
    Equip()
end)

local drop3 = Units_Channel:Dropdown("Unit 3", Units, getgenv().SelectedUnits["U3"], function(bool)
    getgenv().SelectedUnits["U3"] = bool
    Equip()
end)

local drop4 = Units_Channel:Dropdown("Unit 4", Units, getgenv().SelectedUnits["U4"], function(bool)
    getgenv().SelectedUnits["U4"] = bool
    Equip()
end)

local axx = Client.LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('spawn_units').Lives.Main.Desc.Level.Text:split(" ")
_G.drop5 = nil
_G.drop6 = nil
if tonumber(axx[2]) >= 20 then
    _G.drop5 = Units_Channel:Dropdown("Unit 5", Units, getgenv().SelectedUnits["U5"], function(bool)
        getgenv().SelectedUnits["U5"] = bool
        Equip()
    end)
end

if tonumber(axx[2]) >= 50 then
    _G.drop6 = Units_Channel:Dropdown("Unit 6", Units, getgenv().SelectedUnits["U6"], function(bool)
        getgenv().SelectedUnits["U6"] = bool
        Equip()
    end)
end
--------------// Refresh Unit List \\-------------

Units_Channel:Button("Unequip All Units", function()
    drop:Clear()
    drop2:Clear()
    drop3:Clear()
    drop4:Clear()
    if _G.drop5 ~= nil then
        _G.drop5:Clear()
    end
    if _G.drop6 ~= nil then
        _G.drop6:Clear()
    end

    loadUnit()
    Endpoints.unequip_all:InvokeServer()
    for _, v in ipairs(Units) do
        drop:Add(v)
        drop2:Add(v)
        drop3:Add(v)
        drop4:Add(v)
        if _G.drop5 ~= nil then
            _G.drop5:Add(v)
        end
        if _G.drop6 ~= nil then
            _G.drop6:Add(v)
        end
    end
    getgenv().SelectedUnits = {
        U1 = nil,
        U2 = nil,
        U3 = nil,
        U4 = nil,
        U5 = nil,
        U6 = nil
    }
end)

--// Tabs [[FARMING]]
Farming_Channel:Toggle('Auto Start', getgenv().autoStart, function(bool)
    getgenv().autoStart = bool
    saveSaveFile()
end)
Farming_Channel:Seperator()
Farming_Channel:Toggle('Auto Farm', getgenv().autoFarm, function(bool)
    getgenv().autoFarm = bool
    saveSaveFile()
end)
Farming_Channel:Toggle("Auto Upgrade Units", getgenv().autoUpgrade, function(bool)
    getgenv().autoUpgrade = bool
    saveSaveFile()
end)
Farming_Channel:Toggle("Auto Ability", getgenv().autoAbility, function(bool)
    getgenv().autoAbility = bool
    saveSaveFile()
end)
Farming_Channel:Seperator()
Farming_Channel:Toggle("Auto Sell at Spectic Wave", getgenv().autoSell, function(bool)
    getgenv().autoSell = bool
    saveSaveFile()
end)
Farming_Channel:Textbox("Select Wave Number for Auto Sell {Press Enter}", getgenv().sellAtWave or 'nil', false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().placePriority['U1'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Farming_Channel:Dropdown("Select World", {"Plannet Namak", "Shiganshinu District", "Snowy Town", "Hidden Sand Village", "Marine's Ford"}, getgenv().world, function(world)
    getgenv().world = world
    saveSaveFile()

    if world == "Plannet Namak" then
        getgenv().leveldrop:Clear()
        table.clear(levels)
        getgenv().levels = {"namek_infinite", "namek_level_1", "namek_level_2", "namek_level_3", "namek_level_4", "namek_level_5", "namek_level_6"}
        for _, v in ipairs(levels) do getgenv().leveldrop:Add(v) end

    elseif world == "Shiganshinu District" then
        getgenv().leveldrop:Clear()
        table.clear(levels)
        getgenv().levels = {"aot_infinite", "aot_level_1", "aot_level_2", "aot_level_3", "aot_level_4", "aot_level_5", "aot_level_6"}
        for _, v in ipairs(levels) do  getgenv().leveldrop:Add(v) end

    elseif world == "Snowy Town" then
        getgenv().leveldrop:Clear()
        table.clear(levels)
        getgenv().levels = {"demonslayer_infinite", "demonslayer_level_1", "demonslayer_level_2", "demonslayer_level_3", "demonslayer_level_4", "demonslayer_level_5", "demonslayer_level_6"}
        for _, v in ipairs(levels) do getgenv().leveldrop:Add(v) end

    elseif world == "Hidden Sand Village" then
        getgenv().leveldrop:Clear()
        table.clear(levels)
        getgenv().levels = {"naruto_infinite", "naruto_level_1", "naruto_level_2", "naruto_level_3", "naruto_level_4", "naruto_level_5", "naruto_level_6"}
        for _, v in ipairs(levels) do getgenv().leveldrop:Add(v) end

    elseif world == "Marine's Ford" then
        getgenv().leveldrop:Clear()
        table.clear(levels)
        getgenv().levels = {"marineford_infinite", "marineford_level_1", "marineford_level_2", "marineford_level_3", "marineford_level_4", "marineford_level_5", "marineford_level_6"}
        for _, v in ipairs(levels) do getgenv().leveldrop:Add(v) end
    end
end)
getgenv().leveldrop = Farming_Channel:Dropdown("Select Level", getgenv().levels, getgenv().level, function(level)
    getgenv().level = level
    saveSaveFile()
end)
getgenv().diff = Farming_Channel:Dropdown("Select Difficulty", {"Normal", "Hard"}, getgenv().difficulty, function(diff)
    getgenv().difficulty = diff
    saveSaveFile()
end)

--// Tabs [[Priority]]
Priority_Channel:Label('Manage the order in the next tab!')
Priority_Channel:Seperator()
Priority_Channel:Toggle('Placing', getgenv().placePriorityEnabled, function(bool)
    getgenv().placePriorityEnabled = bool
    saveSaveFile()
end)
Priority_Channel:Toggle('Upgrading', getgenv().upgradePriorityEnabled, function(bool)
    getgenv().upgradePriorityEnabled = bool
    saveSaveFile()
end)

Placing_Channel:Label('Largest Integer has Highest Priority')
Placing_Channel:Seperator()
Placing_Channel:Textbox('Set: Unit 1', getgenv().placePriority['U1'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().placePriority['U1'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Placing_Channel:Textbox('Set: Unit 2', getgenv().placePriority['U2'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().placePriority['U2'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Placing_Channel:Textbox('Set: Unit 3', getgenv().placePriority['U3'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().placePriority['U3'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Placing_Channel:Textbox('Set: Unit 4', getgenv().placePriority['U4'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().placePriority['U4'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)

if tonumber(axx[2]) >= 20 then
    Placing_Channel:Textbox('Set: Unit 5', getgenv().placePriority['U5'], false, function(num)
        if select(1, num:gsub('%D+', '')) == tostring(num) then
            getgenv().placePriority['U5'] = num
            saveSaveFile()
        else
            ErrorNotif('Integer')
        end
    end)
end

if tonumber(axx[2]) >= 50 then
    Placing_Channel:Textbox('Set: Unit 6', getgenv().placePriority['U6'], false, function(num)
        if select(1, num:gsub('%D+', '')) == tostring(num) then
            getgenv().placePriority['U6'] = num
            saveSaveFile()
        else
            ErrorNotif('Integer')
        end
    end)
end
Placing_Channel:Seperator()
Placing_Channel:Button('Reset Priority', function()
    for t = 1,6 do
        getgenv().placePriority['U'..t] = '0'
    end
    saveSaveFile()
end)

Upgrading_Channel:Label('Largest Integer Highest Priority')
Upgrading_Channel:Seperator()
Upgrading_Channel:Textbox('Set: Unit 1', getgenv().upgradePriority['U1'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().upgradePriority['U1'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Upgrading_Channel:Textbox('Set: Unit 2', getgenv().upgradePriority['U2'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().upgradePriority['U2'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Upgrading_Channel:Textbox('Set: Unit 3', getgenv().upgradePriority['U3'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().upgradePriority['U3'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)
Upgrading_Channel:Textbox('Set: Unit 4', getgenv().upgradePriority['U4'], false, function(num)
    if select(1, num:gsub('%D+', '')) == tostring(num) then
        getgenv().upgradePriority['U4'] = num
        saveSaveFile()
    else
        ErrorNotif('Integer')
    end
end)

if tonumber(axx[2]) >= 20 then
    Upgrading_Channel:Textbox('Set: Unit 5', getgenv().upgradePriority['U5'], false, function(num)
        if select(1, num:gsub('%D+', '')) == tostring(num) then
            getgenv().upgradePriority['U5'] = num
            saveSaveFile()
        else
            ErrorNotif('Integer')
        end
    end)
end

if tonumber(axx[2]) >= 50 then
    Upgrading_Channel:Textbox('Set: Unit 6', getgenv().upgradePriority['U6'], false, function(num)
        if select(1, num:gsub('%D+', '')) == tostring(num) then
            getgenv().upgradePriority['U6'] = num
            saveSaveFile()
        else
            ErrorNotif('Integer')
        end
    end)
end
Upgrading_Channel:Seperator()
Upgrading_Channel:Button('Reset Priority', function()
    for t = 1,6 do
        getgenv().upgradePriority['U'..t] = '0'
    end
    saveSaveFile()
end)

--// Tabs [[WEBHOOK]]
Webhook_Channel:Toggle('Webhook', getgenv().webhook, function(bool)
    getgenv().webhook = bool
    saveSaveFile()
end)
do
    local PlaceHolder = (((getgenv().webhookUrl == "") or (not getgenv().webhookUrl)) and 'Insert Url Here!') or getgenv().webhookUrl
    Webhook_Channel:Textbox("Webhook URL {Press Enter}", PlaceHolder, false, function(url)
        getgenv().webhookUrl = url
        saveSaveFile()
    end)
end
Webhook_Channel:Label("Webhook sends notification in discord everytime\nGame is Finished!")
Webhook_Channel:Seperator()
Webhook_Channel:Toggle('Mention', getgenv().webhookMention, function(bool)
    getgenv().webhookMention = bool
    saveSaveFile()
end)
do
    local PlaceHolder = (((getgenv().webhookMentionID == "") or (not getgenv().webhookMentionID)) and 'Insert ID to mention Here!') or getgenv().webhookMentionID
    Webhook_Channel:Textbox("ID {Press Enter}", PlaceHolder, false, function(url)
        getgenv().webhookMentionID = url
        saveSaveFile()
    end)
end
Webhook_Channel:Seperator()
Webhook_Channel:Button('Test Webhook', function()
    local success, err = pcall(function()
        Post()
    end)
    print(success, err)
end)

--// PLACE SPECIFIC
if game.PlaceId == 8304191830 then
    Misc_Channel:Seperator()
    Misc_Channel:Button('Redeem Codes', function()
        for _, v in next, codes do
            Endpoints.redeem_code:InvokeServer(v)
        end
    end)

    local summon = function()
        if not getgenv().autoSummonGEM and not getgenv().autoSummonTICKET then return end
        local PlayerGui = Client.LocalPlayer:WaitForChild('PlayerGui')
        local GemNumber = Client.LocalPlayer:WaitForChild('_stats'):WaitForChild('gem_amount')

        while getgenv().autoSummonGEM do
            local gems10 = math.floor(GemNumber.Value/500)
            local gems = GemNumber.Value - (gems10*500)

            if (gems10 > 0) or (gems >= 50) then
                Endpoints.buy_random_fighter:InvokeServer(
                    'dbz_fighter',
                    (gems10>0 and 'gems10') or 'gems'
                )
                task.wait()
            else
                break
            end
        end

        while getgenv().autoSummonTICKET do
            local TicketNumber = 0
            for _, v in next, PlayerGui:WaitForChild('items'):WaitForChild('grid'):WaitForChild('List'):WaitForChild('Outer'):WaitForChild('ItemFrames'):GetChildren() do
                if v.Name == 'summon_ticket' then TicketNumber = TicketNumber + 1 end
            end

            if TicketNumber > 0 then
                Endpoints.buy_random_fighter:InvokeServer(
                    'dbz_fighter',
                    'ticket'
                )
                task.wait()
            else
                break
            end
        end
    end
    Misc_Channel:Seperator()
    Misc_Channel:Toggle('Auto Summon (Gems)', getgenv().autoSummonGEM, function(bool)
        getgenv().autoSummonGEM = bool
        saveSaveFile()
        summon()
    end)
    Misc_Channel:Toggle('Auto Summon (Tickets)', getgenv().autoSummonTICKET, function(bool)
        getgenv().autoSummonTICKET = bool
        saveSaveFile()
        summon()
    end)

    task.spawn(summon)
else
    repeat task.wait() until Client.LocalPlayer.Character
    Endpoints.vote_start:InvokeServer()
    repeat task.wait() until workspace["_waves_started"] and (workspace["_waves_started"].Value == true)

    Client.LocalPlayer.PlayerGui.MessageGui.Enabled = false
    Client.ReplicatedStorage.packages.assets["ui_sfx"].error.Volume = 0
    Client.ReplicatedStorage.packages.assets["ui_sfx"].error_old.Volume = 0

    function MouseClick(UnitPos)
        local connection
        connection = Client.UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                local a = Instance.new("Part", game.Workspace)
                a.Size = Vector3.new(1, 1, 1)
                a.Material = Enum.Material.Neon
                a.Position = Client.Mouse.hit.p
                task.wait()
                a.Anchored = true
                DiscordLib:Notification("Spawn Unit Posotion:", tostring(a.Position), "Okay!")
                a.CanCollide = false
                for i = 0, 1, 0.1 do
                    a.Transparency = i
                    task.wait()
                end
                a:Destroy()
                SpawnUnitPos[UnitPos]["x"] = a.Position.X
                SpawnUnitPos[UnitPos]["y"] = a.Position.Y
                SpawnUnitPos[UnitPos]["z"] = a.Position.Z
                saveSaveFile()
            end
        end)
    end

    Position_Channel:Label('Set Unit Spawn Positions')
    Position_Channel:Seperator()
    Position_Channel:Button("Set Unit 1 Postion", function()
        DiscordLib:Notification(
            "Set Unit 1 Spawn Position",
            "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
            "Done"
        )
        MouseClick("UP1")
    end)

    Position_Channel:Button("Set Unit 2 Postion", function()
        DiscordLib:Notification(
            "Set Unit 2 Spawn Position",
            "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
            "Done"
        )
        MouseClick("UP2")
    end)
    Position_Channel:Button("Set Unit 3 Postion", function()
        DiscordLib:Notification(
            "Set Unit 3 Spawn Position",
            "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
            "Done"
        )
        MouseClick("UP3")
    end)
    Position_Channel:Button("Set Unit 4 Postion", function()
        DiscordLib:Notification(
            "Set Unit 4 Spawn Position",
            "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
            "Done"
        )
        MouseClick("UP4")
    end)

    local axxc = Client.LocalPlayer.PlayerGui["spawn_units"].Lives.Main.Desc.Level.Text:split(" ")

    if tonumber(axxc[2]) >= 20 then
        Position_Channel:Button("Set Unit 5 Postion", function()
            DiscordLib:Notification(
                "Set Unit 5 Spawn Position",
                "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
                "Done"
            )
            MouseClick("UP5")
        end)
    end

    if tonumber(axxc[2]) >= 50 then
        Position_Channel:Button("Set Unit 6 Postion", function()
            DiscordLib:Notification(
                "Set Unit 6 Spawn Position",
                "Click on the floor to set the spawn unit position!\n (don't press \"Done\" until you set position)",
                "Done"
            )
            MouseClick("UP6")
        end)
    end
end

--// Tabs [[DEBUG]]
local DebugServer = win:Server('Debug', 'http://www.roblox.com/asset/?id=10425947463')
local Debug_Channel = DebugServer:Channel('Reset')
Debug_Channel:Button('Re-Align Exploit Ui', function()
    win:ResetWindow()
end)
Debug_Channel:Seperator()
Debug_Channel:Label('---- DANGER ----\n(WARNING! This will affect current settings!)')
Debug_Channel:Button('Reset Exploit Data', function()
    for i,v in next, GenvVariables do
        getgenv()[i] = v
    end
    saveSaveFile()
    DiscordLib:Notification(
        'NOTICE',
        'Reset All Saved Exploit Data!',
        'Okay'
    )
end)

--// Auto Sell and Abilities and Upgrade
task.spawn(function()
    if game.PlaceId == 8304191830 then return end
    local GameFinished = workspace:WaitForChild("_DATA"):WaitForChild("GameFinished")
    GameFinished:GetPropertyChangedSignal("Value"):Connect(function()
        if GameFinished.Value == true then
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Enabled == true
            task.wait()
            local succ, err = pcall(function() Post() end) print(succ, err)
            task.wait(2)
            Client.TeleportService:Teleport(8304191830, Client.LocalPlayer)
        end
    end)

    while task.wait() do
        local _wave = workspace:WaitForChild("_wave_num")
        local pastWave = function()
            return tonumber(getgenv().sellAtWave) and (tonumber(getgenv().sellAtWave) ~= 0) and (tonumber(getgenv().sellAtWave) <= _wave.Value)
        end
        local expired = false

        local getCurrentUnits = function()
            local curr = {}
            for _, v in next, workspace:WaitForChild('_UNITS'):GetChildren() do
                if v:FindFirstChild('_stats') and (v._stats.player.Value == Client.LocalPlayer) and v.Name ~= 'aot_generic' then
                    table.insert(curr, v)
                end
            end
            return curr
        end

        local currentUnits, toUpgrade, toPlace do
            currentUnits, toUpgrade, toPlace = {}, {}, {}

            for _, v in next, workspace:WaitForChild('_UNITS'):GetChildren() do
                if v:FindFirstChild('_stats') and (v._stats.player.Value == Client.LocalPlayer) and v.Name ~= 'aot_generic' then
                    table.insert(currentUnits, v)
                    for t = 1,6 do
                        local unitinfo = getgenv().SelectedUnits['U'..t]
                        if unitinfo ~= nil then
                            local unitinfo_ = unitinfo:split(" #")
                            if unitinfo_[1]:lower():find(unitConversion.CollectableName[table.find(unitConversion.InGameUnitName, v.Name)]) then
                                table.insert(toUpgrade, {
                                    Priority = (getgenv().upgradePriorityEnabled and tonumber(getgenv().upgradePriority[t])) or 0,
                                    Object = v
                                })
                            end
                        end
                    end
                end
            end

            for i, v in next, getgenv().placePriority do
                table.insert(toPlace, {
                    Unit = i,
                    Priority = tonumber((getgenv().placePriorityEnabled and v) or '0')
                })
            end

            table.sort(toUpgrade, function(a, b)
                return tonumber(a.Priority) > tonumber(b.Priority)
            end)
            table.sort(toPlace, function(a,b)
                return tonumber(a.Priority) > tonumber(b.Priority)
            end)
        end

        if getgenv().autoFarm then
            if pastWave() then
                if getgenv().autoSell then --// Auto Sell
                    for _, v in next, currentUnits do
                        Endpoints.sell_unit_ingame:InvokeServer(v)
                    end
                end
            else
                if getgenv().autoAbility then
                    for _, v in next, currentUnits do
                        pcall(function()
                            Endpoints.use_active_attack:InvokeServer(v)
                        end)
                    end
                end
    
                if getgenv().autoUpgrade then
                    local maxUnits = 10
                    local succ, err = pcall(function()
                        for _, v in next, toUpgrade do
                            if v.Object['_stats'] and v.Object['_stats'].upgrade and ((v.Object['_stats'].upgrade.Value == 0) or (v.Object['_stats'].upgrade.Value <= maxUnits)) then
                                local start = tick()
                                repeat Endpoints.upgrade_unit_ingame:InvokeServer(v.Object); task.wait(0.01) until (tick() - start) >= v.Priority
                            end
                        end
                    end)
                    if not succ then warn(err) end
                end

                do
                    local x = 4
                    local y = 3
                    local z = 4
    
                    for _, v in next, toPlace do
                        local unitinfo = getgenv().SelectedUnits[v.Unit]
                        if unitinfo ~= nil then
                            local start = tick()
                            local unitinfo_ = unitinfo:split(" #")
                            local pos = getgenv().SpawnUnitPos["UP" .. v.Unit:sub(-1)]
                            local checkCount = function(num)
                                local count = 0
                                for _, v2 in next, getCurrentUnits() do
                                    if unitinfo_[1]:lower():find(unitConversion.CollectableName[table.find(unitConversion.InGameUnitName, v2.Name)]) then
                                        count = count + 1
                                    end
                                end
                                return (count >= num)
                            end

                            repeat
                            -- place units 0
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"], pos["y"], pos["z"]), Vector3.new(0, 0, -1))
                                )
    
                                -- place units 1
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"] - x, pos["y"], pos["z"]), Vector3.new(0, 0, -1))
                                )
    
                                -- place units 2 
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"], pos["y"], pos["z"] + z), Vector3.new(0, 0, -1))
                                )
    
                                -- place units 3 
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"] - x, pos["y"], pos["z"] + z), Vector3.new(0, 0, -1))
                                )
    
                                -- place units 4
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"] + x, pos["y"], pos["z"] + z), Vector3.new(0, 0, -1))
                                )
    
                                -- place units 5
                                Endpoints.spawn_unit:InvokeServer(
                                    unitinfo_[2],
                                    CFrame.new(Vector3.new(pos["x"] + x, pos["y"], pos["z"]), Vector3.new(0, 0, -1))
                                )
                                task.wait()
                            until checkCount(1) or ((tick() - start) >= v.Priority)
                        end
                    end
                end
            end
        end
    end
end)

--// Auto Start and Sell Unit
task.spawn(function()
    while task.wait() and (game.PlaceId == 8304191830) do
        if getgenv().autoStart and getgenv().autoFarm then
            local referencePoint = workspace:WaitForChild('_codes'):WaitForChild('area')
            local avaliableDoors = {}

            for _, v in next, workspace:WaitForChild('_LOBBIES').Story:GetDescendants() do
                if v.Name == "Owner" and v.Value == nil then
                    table.insert(avaliableDoors, {
                        distance = (v.Parent:GetPrimaryPartCFrame().Position - referencePoint.Position).Magnitude,
                        name = v.Parent.Name
                    })
                end
            end

            table.sort(avaliableDoors, function(a,b)
                return a.distance > b.distance
            end)
            getgenv().door = avaliableDoors[1].name

            if getgenv().door then
                task.wait(0.1)
                Endpoints.request_join_lobby:InvokeServer(getgenv().door)
                task.wait(0.1)
        
                Endpoints.request_lock_level:InvokeServer(
                    getgenv().door,
                    getgenv().level,
                    true,
                    getgenv().difficulty
                )
        
                task.wait(3)
        
                Endpoints.request_start_game:InvokeServer(getgenv().door)
            end
            task.wait(5)
        end
    end
end)

Client.LocalPlayer.Idled:Connect(function()
    if getgenv().antiAfk then
        Client.VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        Client.VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

Client.RunService.Stepped:Connect(function()
    if getgenv().hideName and Client.LocalPlayer.Character and Client.LocalPlayer.Character.Head:FindFirstChild('_overhead') then
        workspace[Client.LocalPlayer.Name].Head._overhead:Destroy()
    end
end)
