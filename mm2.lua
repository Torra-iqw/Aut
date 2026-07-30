-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Функция градиента для текста
local function gradient(text, color1, color2)
    local result = ""
    local length = #text
    for i = 1, length do
        local ratio = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((color1.R + (color2.R - color1.R) * ratio) * 255)
        local g = math.floor((color1.G + (color2.G - color1.G) * ratio) * 255)
        local b = math.floor((color1.B + (color2.B - color1.B) * ratio) * 255)
        result = result .. '<font color="rgb(' .. r .. ', ' .. g .. ', ' .. b .. ')">' .. text:sub(i, i) .. '</font>'
    end
    return result
end

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = gradient("Murderer Mystery 2", Color3.fromHex("#001e80"), Color3.fromHex("#ffea00")),
    Icon = "infinity",
    Author = gradient("t.me/dj_swaston", Color3.fromHex("#1bf2b2"), Color3.fromHex("#1bcbf2")),
    Folder = "WindUI",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Midnight",
    SideBarWidth = 200,
    BackgroundImageTransparency = .42,
    UserEnabled = true,
    HasOutline = true,
    ScrollBarEnabled = true
})

Window:EditOpenButton({
    Title = "Open UI",
    Icon = "monitor",
    CornerRadius = UDim.new(2, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("1E213D"), Color3.fromHex("1F75FE")),
    Draggable = true
})

-- Вкладки
local Tabs = {
    CharacterTab = Window:Tab({ Title = gradient("CHARACTER", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "file-cog" }),
    TeleportTab = Window:Tab({ Title = gradient("TELEPORT", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "user" }),
    EspTab = Window:Tab({ Title = gradient("ESP", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "eye" }),
    AimbotTab = Window:Tab({ Title = gradient("AIMBOT", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "arrow-right" }),
    AutoFarmTab = Window:Tab({ Title = gradient("AUTOFARM", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "user" }),
    InnocentTab = Window:Tab({ Title = gradient("INNOCENT", Color3.fromHex("#0ff707"), Color3.fromHex("#1e690c")), Icon = "circle" }),
    MurderTab = Window:Tab({ Title = gradient("MURDER", Color3.fromHex("#e80909"), Color3.fromHex("#630404")), Icon = "circle" }),
    SheriffTab = Window:Tab({ Title = gradient("SHERIFF", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9")), Icon = "circle" }),
    ServerTab = Window:Tab({ Title = gradient("SERVER", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "atom" }),
    SettingsTab = Window:Tab({ Title = gradient("SETTINGS", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")), Icon = "code" })
}

-- ================= CHARACTER TAB =================
local charSettings = { WalkSpeed = 16, JumpPower = 50, WSLocked = false, JPLocked = false }

local function updateCharacter()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if not charSettings.WSLocked then hum.WalkSpeed = charSettings.WalkSpeed end
        if not charSettings.JPLocked then hum.JumpPower = charSettings.JumpPower end
    end
end

Tabs.CharacterTab:Section({ Title = gradient("Walkspeed", Color3.fromHex("#ff0000"), Color3.fromHex("#300000")) })
Tabs.CharacterTab:Slider({ Title = "Walkspeed", Value = { Min = 0, Max = 200, Default = 16 }, Callback = function(v) charSettings.WalkSpeed = v; updateCharacter() end })
Tabs.CharacterTab:Button({ Title = "Reset walkspeed", Callback = function() charSettings.WalkSpeed = 16; updateCharacter() end })
Tabs.CharacterTab:Toggle({ Title = "Block walkspeed", Default = false, Callback = function(v) charSettings.WSLocked = v; updateCharacter() end })

Tabs.CharacterTab:Section({ Title = gradient("JumpPower", Color3.fromHex("#001aff"), Color3.fromHex("#020524")) })
Tabs.CharacterTab:Slider({ Title = "Jumppower", Value = { Min = 0, Max = 200, Default = 50 }, Callback = function(v) charSettings.JumpPower = v; updateCharacter() end })
Tabs.CharacterTab:Button({ Title = "Reset jumppower", Callback = function() charSettings.JumpPower = 50; updateCharacter() end })
Tabs.CharacterTab:Toggle({ Title = "Block jumppower", Default = false, Callback = function(v) charSettings.JPLocked = v; updateCharacter() end })

-- ================= ESP TAB =================
local espSettings = { HighlightMurderer = false, HighlightInnocent = false, HighlightSheriff = false }
local roleData = {}
local mapNames = {"ResearchFacility", "Hospital3", "MilBase", "House2", "Workplace", "Mansion2", "BioLab", "Hotel", "Factory", "Bank2", "PoliceStation"}

local function getRoles()
    local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if remote then
        local success, data = pcall(function() return remote:InvokeServer() end)
        if success and type(data) == "table" then
            roleData = data
        end
    end
end

local function isAlive(player)
    local data = roleData[player.Name]
    if not data then return false end
    return not data.Killed and not data.Dead
end

local function updateHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("Highlight")
            
            local shouldShow = false
            local color = Color3.new(0, 1, 0)
            
            if espSettings.HighlightMurderer and roleData[player.Name] and roleData[player.Name].Role == "Murderer" and isAlive(player) then
                shouldShow = true; color = Color3.fromRGB(255, 0, 0)
            elseif espSettings.HighlightSheriff and roleData[player.Name] and roleData[player.Name].Role == "Sheriff" and isAlive(player) then
                shouldShow = true; color = Color3.fromRGB(0, 0, 255)
            elseif espSettings.HighlightInnocent and isAlive(player) then
                shouldShow = true; color = Color3.fromRGB(0, 255, 0)
            end
            
            if shouldShow then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.Adornee = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                highlight.FillColor = color
                highlight.OutlineColor = color
                highlight.Enabled = true
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
end

Tabs.EspTab:Section({ Title = gradient("Special ESP", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2")) })
Tabs.EspTab:Toggle({ Title = gradient("Higlight Murder", Color3.fromHex("#e80909"), Color3.fromHex("#630404")), Default = false, Callback = function(v) espSettings.HighlightMurderer = v; if not v then updateHighlights() end end })
Tabs.EspTab:Toggle({ Title = gradient("Highlight Innocent", Color3.fromHex("#0ff707"), Color3.fromHex("#1e690c")), Default = false, Callback = function(v) espSettings.HighlightInnocent = v; if not v then updateHighlights() end end })
Tabs.EspTab:Toggle({ Title = gradient("Highlight Sheriff", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9")), Default = false, Callback = function(v) espSettings.HighlightSheriff = v; if not v then updateHighlights() end end })

-- GunDrop ESP
local gunDropEsp = false
local function updateGunDropEsp()
    for _, mapName in pairs(mapNames) do
        local map = Workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop then
                local hl = gunDrop:FindFirstChild("GunDropHighlight")
                if gunDropEsp and not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "GunDropHighlight"
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                    hl.Adornee = gunDrop
                    hl.Parent = gunDrop
                elseif not gunDropEsp and hl then
                    hl:Destroy()
                end
            end
        end
    end
end

Tabs.EspTab:Toggle({ Title = gradient("GunDrop Highlight", Color3.fromHex("#ffff00"), Color3.fromHex("#4f4f00")), Default = false, Callback = function(v) gunDropEsp = v; updateGunDropEsp() end })

RunService.RenderStepped:Connect(function()
    getRoles()
    if espSettings.HighlightMurderer or espSettings.HighlightInnocent or espSettings.HighlightSheriff then
        updateHighlights()
    end
end)

-- ================= TELEPORT TAB =================
Tabs.TeleportTab:Section({ Title = gradient("Default TP", Color3.fromHex("#00448c"), Color3.fromHex("#0affd6")) })

local selectedPlayer = nil
local playerDropdown
local function getPlayersList()
    local list = {"Select Player"}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

playerDropdown = Tabs.TeleportTab:Dropdown({
    Title = "Players",
    Values = getPlayersList(),
    Value = "Select Player",
    Callback = function(v) if v ~= "Select Player" then selectedPlayer = Players:FindFirstChild(v) end end
})

Players.PlayerAdded:Connect(function() task.wait(1); playerDropdown:Refresh(getPlayersList()) end)
Players.PlayerRemoving:Connect(function() playerDropdown:Refresh(getPlayersList()) end)

Tabs.TeleportTab:Button({ Title = "Teleport to player", Callback = function()
    if selectedPlayer and selectedPlayer.Character and LocalPlayer.Character then
        local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame
            WindUI:Notify({ Title = "Teleport", Content = "Successfully teleported to " .. selectedPlayer.Name, Icon = "check-circle", Duration = 3 })
        end
    else
        WindUI:Notify({ Title = "Error", Content = "Target not found or unavailable", Icon = "x-circle", Duration = 3 })
    end
end })

Tabs.TeleportTab:Button({ Title = "Update players list", Callback = function() playerDropdown:Refresh(getPlayersList()) end })

Tabs.TeleportTab:Section({ Title = gradient("Special TP", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2")) })

local function teleportToRole(roleName)
    getRoles()
    local targetName
    for name, data in pairs(roleData) do
        if data.Role == roleName then targetName = name break end
    end
    if targetName then
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                myHRP.CFrame = targetHRP.CFrame
                WindUI:Notify({ Title = "Teleport", Content = "Successfully teleported to " .. targetName, Icon = "check-circle", Duration = 3 })
            end
        end
    else
        WindUI:Notify({ Title = "Error", Content = roleName .. " not found", Icon = "x-circle", Duration = 3 })
    end
end

Tabs.TeleportTab:Button({ Title = "Teleport to Lobby", Callback = function()
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local spawn = lobby:FindFirstChild("SpawnPoint") or lobby:FindFirstChildOfClass("SpawnLocation") or lobby:FindFirstChildWhichIsA("BasePart")
        if spawn and LocalPlayer.Character then
            local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                myHRP.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 3, 0))
                WindUI:Notify({ Title = "Teleport", Content = "Teleported to Lobby!", Icon = "check-circle", Duration = 2 })
            end
        end
    else
        WindUI:Notify({ Title = "Teleport", Content = "Lobby not found!", Icon = "x-circle", Duration = 2 })
    end
end })

Tabs.TeleportTab:Button({ Title = "Teleport to Sheriff", Callback = function() teleportToRole("Sheriff") end })
Tabs.TeleportTab:Button({ Title = "Teleport to Murderer", Callback = function() teleportToRole("Murderer") end })

-- ================= AIMBOT TAB =================
Tabs.AimbotTab:Section({ Title = gradient("Default AimBot", Color3.fromHex("#00448c"), Color3.fromHex("#0affd6")) })
local aimbotSettings = { TargetRole = nil, Spectate = false, LockCamera = false }
local originalCamType = Camera.CameraType
local originalCamSubject = Camera.CameraSubject

Tabs.AimbotTab:Dropdown({
    Title = "Target Role",
    Values = {"None", "Sheriff", "Murderer"},
    Value = "None",
    Callback = function(v) aimbotSettings.TargetRole = v ~= "None" and v or nil end
})

Tabs.AimbotTab:Toggle({ Title = "Spectate Mode", Default = false, Callback = function(v)
    aimbotSettings.Spectate = v
    if v then
        originalCamType = Camera.CameraType
        originalCamSubject = Camera.CameraSubject
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        Camera.CameraType = originalCamType
        Camera.CameraSubject = originalCamSubject
    end
end })

Tabs.AimbotTab:Toggle({ Title = "Lock Camera", Default = false, Callback = function(v)
    aimbotSettings.LockCamera = v
    if not v and not aimbotSettings.Spectate then
        Camera.CameraType = originalCamType
        Camera.CameraSubject = originalCamSubject
    end
end })

RunService.RenderStepped:Connect(function()
    if not aimbotSettings.TargetRole then return end
    getRoles()
    local targetName
    for name, data in pairs(roleData) do
        if data.Role == aimbotSettings.TargetRole then targetName = name break end
    end
    if targetName then
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            if targetHRP then
                if aimbotSettings.Spectate then
                    Camera.CFrame = targetHRP.CFrame * CFrame.new(0, 2, 8)
                elseif aimbotSettings.LockCamera and targetHead then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                end
            end
        end
    end
end)

-- ================= AUTOFARM TAB =================
Tabs.AutoFarmTab:Section({ Title = gradient("Coin and Beach Ball Farming", Color3.fromHex("#FFD700"), Color3.fromHex("#ADD8E6")) })
local autoFarmSettings = { Enabled = false, Mode = "Teleport", TeleportDelay = 0, MoveSpeed = 50, WalkSpeed = 32, CoinCheckInterval = 0.5, Connection = nil }

local function getNearestCoin()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest, closestDist = nil, math.huge
    for _, mapName in pairs(mapNames) do
        local map = Workspace:FindFirstChild(mapName)
        if map then
            local container = map:FindFirstChild("CoinContainer") or (mapName == "Lobby" and map)
            if container then
                for _, obj in ipairs(container:GetChildren()) do
                    if obj:IsA("BasePart") then
                        local dist = (hrp.Position - obj.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = obj
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function farmCoins()
    while autoFarmSettings.Enabled do
        local coin = getNearestCoin()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if coin and hrp then
            if autoFarmSettings.Mode == "Teleport" then
                hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 3, 0))
                task.wait(autoFarmSettings.TeleportDelay)
            elseif autoFarmSettings.Mode == "Smooth" then
                -- Basic smooth teleport
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(coin.Position + Vector3.new(0, 3, 0)), 0.1)
                task.wait()
            elseif autoFarmSettings.Mode == "Walk" then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = autoFarmSettings.WalkSpeed
                    hum:MoveTo(coin.Position)
                end
            end
            firetouchinterest(hrp, coin, 0)
            firetouchinterest(hrp, coin, 1)
        else
            task.wait(autoFarmSettings.CoinCheckInterval)
        end
        task.wait()
    end
end

Tabs.AutoFarmTab:Dropdown({ Title = "Movement Mode", Values = {"Teleport", "Smooth", "Walk"}, Value = "Teleport", Callback = function(v) autoFarmSettings.Mode = v end })
Tabs.AutoFarmTab:Slider({ Title = "Teleport Delay (sec)", Value = { Min = 0, Max = 1, Default = 0, Step = .1 }, Callback = function(v) autoFarmSettings.TeleportDelay = v end })
Tabs.AutoFarmTab:Slider({ Title = "Smooth Move Speed", Value = { Min = 20, Max = 200, Default = 50 }, Callback = function(v) autoFarmSettings.MoveSpeed = v end })
Tabs.AutoFarmTab:Slider({ Title = "Walk Speed", Value = { Min = 16, Max = 100, Default = 32 }, Callback = function(v) autoFarmSettings.WalkSpeed = v end })
Tabs.AutoFarmTab:Slider({ Title = "Check Interval (sec)", Value = { Min = .1, Max = 2, Default = 0.5, Step = .1 }, Callback = function(v) autoFarmSettings.CoinCheckInterval = v end })

Tabs.AutoFarmTab:Toggle({
    Title = "Enable AutoFarm",
    Default = false,
    Callback = function(v)
        autoFarmSettings.Enabled = v
        if v then
            autoFarmSettings.Connection = task.spawn(farmCoins)
            WindUI:Notify({ Title = "AutoFarm", Content = "Started farming nearest coins!", Icon = "check-circle", Duration = 2 })
        else
            if autoFarmSettings.Connection then task.cancel(autoFarmSettings.Connection) end
            WindUI:Notify({ Title = "AutoFarm", Content = "Stopped farming coins", Icon = "x-circle", Duration = 2 })
        end
    end
})

Tabs.AutoFarmTab:Toggle({
    Title = "Enable Beach Ball AutoFarm",
    Default = false,
    Callback = function(v)
        if v then
            pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NoovaScripts/roblox/refs/heads/main/beachballfarm"))() end)
        end
    end
})

-- ================= INNOCENT/MURDERER/SHERIFF TABS =================
-- Hitbox & Noclip (Innocent Tab)
local innocentSettings = { HitboxEnabled = false, HitboxSize = 5, HitboxColor = Color3.fromRGB(255, 0, 0), Noclip = false, AntiAFK = false }
local hitboxAdornments = {}

local function updateHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local adornment = hitboxAdornments[player]
                if innocentSettings.HitboxEnabled then
                    if not adornment then
                        adornment = Instance.new("BoxHandleAdornment")
                        adornment.Adornee = hrp
                        adornment.ZIndex = 10
                        adornment.Transparency = 0.4
                        adornment.Parent = hrp
                        hitboxAdornments[player] = adornment
                    end
                    adornment.Size = Vector3.new(innocentSettings.HitboxSize, innocentSettings.HitboxSize, innocentSettings.HitboxSize)
                    adornment.Color3 = innocentSettings.HitboxColor
                else
                    if adornment then adornment:Destroy(); hitboxAdornments[player] = nil end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if innocentSettings.HitboxEnabled then updateHitboxes() end
    if innocentSettings.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

Tabs.InnocentTab:Section({ Title = gradient("Hitbox", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")) })
Tabs.InnocentTab:Toggle({ Title = "Enable Hitbox", Default = false, Callback = function(v) innocentSettings.HitboxEnabled = v; if not v then updateHitboxes() end end })
Tabs.InnocentTab:Slider({ Title = "Hitbox Size", Value = { Min = 1, Max = 10, Default = 5 }, Callback = function(v) innocentSettings.HitboxSize = v end })
Tabs.InnocentTab:Colorpicker({ Title = "Hitbox Color", Default = Color3.fromRGB(255, 0, 0), Callback = function(v) innocentSettings.HitboxColor = v end })

Tabs.InnocentTab:Section({ Title = gradient("Misc", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")) })
Tabs.InnocentTab:Toggle({ Title = "Noclip", Default = false, Callback = function(v) innocentSettings.Noclip = v end })
Tabs.InnocentTab:Toggle({ Title = "Anti-AFK", Default = false, Callback = function(v)
    innocentSettings.AntiAFK = v
    if v then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end })

-- Murderer Tab (Kill Aura)
local killAuraSettings = { Enabled = false, Delay = 0.5 }

local function getNearestPlayer()
    local closest, closestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myHRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    return closest
end

Tabs.MurderTab:Toggle({
    Title = "Enable Kill Aura",
    Default = false,
    Callback = function(v)
        killAuraSettings.Enabled = v
        if v then
            task.spawn(function()
                while killAuraSettings.Enabled do
                    local target = getNearestPlayer()
                    local myChar = LocalPlayer.Character
                    if target and target.Character and myChar then
                        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        local knife = myChar:FindFirstChild("Knife")
                        
                        if targetHRP and myHRP and knife then
                            myHRP.CFrame = CFrame.new(targetHRP.Position + (myHRP.Position - targetHRP.Position).Unit * 2, targetHRP.Position)
                            local stab = knife:FindFirstChild("Stab")
                            if stab then
                                for _ = 1, 3 do stab:FireServer("Down") end
                            end
                        end
                    end
                    task.wait(killAuraSettings.Delay)
                end
            end)
        end
    end
})

Tabs.MurderTab:Slider({ Title = "Kill Delay (sec)", Value = { Min = 0.1, Max = 2, Default = 0.5 }, Callback = function(v) killAuraSettings.Delay = v end })

-- Sheriff Tab (Gun Grabber & Shooter)
Tabs.SheriffTab:Button({
    Title = "Grab Nearest Gun",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local closestGun, closestDist = nil, math.huge
        for _, mapName in pairs(mapNames) do
            local map = Workspace:FindFirstChild(mapName)
            if map then
                local gunDrop = map:FindFirstChild("GunDrop")
                if gunDrop then
                    local dist = (myHRP.Position - gunDrop.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestGun = gunDrop
                    end
                end
            end
        end

        if closestGun then
            myHRP.CFrame = closestGun.CFrame
            task.wait(0.3)
            local prompt = closestGun:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
        end
    end
})

Tabs.SheriffTab:Button({
    Title = "Shoot Murderer",
    Callback = function()
        getRoles()
        local char = LocalPlayer.Character
        if not char then return end
        local gun = char:FindFirstChild("Gun")
        if not gun then return end

        local targetName
        for name, data in pairs(roleData) do
            if data.Role == "Murderer" then targetName = name break end
        end

        if targetName then
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -4)
                    task.wait(0.1)
                    local beamRemote = gun:FindFirstChild("KnifeLocal", true)
                    if beamRemote and beamRemote:FindFirstChild("CreateBeam") then
                        beamRemote.CreateBeam.RemoteFunction:InvokeServer(1, targetHRP.Position, "AH2")
                    end
                end
            end
        end
    end
})

-- ================= SERVER TAB =================
Tabs.ServerTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.ServerTab:Button({
    Title = "Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local req = request or http_request
        if req then
            local servers = HttpService:JSONDecode(req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"}).Body).data
            for _, server in pairs(servers) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Executor doesn't support HTTP requests.", Icon = "x-circle", Duration = 3 })
        end
    end
})

-- ================= SETTINGS TAB =================
local autoInject = false
local scriptUrl = "YOUR_SCRIPT_URL_HERE" -- Если нужен автоинжект, вставьте URL сюда

Tabs.SettingsTab:Toggle({
    Title = "Auto Inject",
    Default = false,
    Callback = function(v)
        autoInject = v
        if v then
            if queue_on_teleport then
                queue_on_teleport('wait(2); loadstring(game:HttpGet("' .. scriptUrl .. '"))()')
            end
            WindUI:Notify({ Title = "Auto Inject", Content = "Auto inject enabled!", Duration = 3 })
        end
    end
})

Tabs.SettingsTab:Button({
    Title = "Manual Inject",
    Callback = function()
        pcall(function() loadstring(game:HttpGet(scriptUrl))() end)
    end
})

Tabs.SettingsTab:Button({
    Title = "Crack by @dj_swaston",
    Callback = function()
        if setclipboard then setclipboard("t.me/dj_swaston") end
    end
})
