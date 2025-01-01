local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sepper2023/Scorp.xyz/refs/heads/main/LinoriaFixed'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Awakenchan/Misc-Release/main/linoracolor'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sepper2023/Scorp.xyz/refs/heads/main/SaveManagerFixed'))()

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.Camera
local Players = game.Players
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local AntiAimVisualPart = Instance.new("Part",game.Workspace)
AntiAimVisualPart.Name = "AntiAimVisual"
AntiAimVisualPart.BottomSurface = Enum.SurfaceType.Smooth
AntiAimVisualPart.TopSurface = Enum.SurfaceType.Smooth
AntiAimVisualPart.Size = Vector3.new(5, 1, 2.7)
AntiAimVisualPart.Shape = Enum.PartType.Ball
AntiAimVisualPart.Transparency = 1
AntiAimVisualPart.Anchored = true
AntiAimVisualPart.CanCollide = false

local ViewAimPart = Instance.new("Part",game.Workspace)
ViewAimPart.Name = "AntiAimVisual"
ViewAimPart.BottomSurface = Enum.SurfaceType.Smooth
ViewAimPart.TopSurface = Enum.SurfaceType.Smooth
ViewAimPart.Size = Vector3.new(2,2,2)
ViewAimPart.Shape = Enum.PartType.Ball
ViewAimPart.Transparency = 1
ViewAimPart.Anchored = true
ViewAimPart.CanCollide = false

local AntiAimVisualHighlight = Instance.new("Highlight",AntiAimVisualPart)
AntiAimVisualHighlight.FillColor = Color3.fromRGB(66, 66, 255)
AntiAimVisualHighlight.FillTransparency = 0

local ViewAimPartHighlight = Instance.new("Highlight",ViewAimPart)
ViewAimPartHighlight.FillColor = Color3.fromRGB(66, 66, 255)
ViewAimPartHighlight.FillTransparency = 0

Mouse.TargetFilter = ViewAimPart

local MainEvent = ReplicatedStorage.assets.dh.MainEvent

local Speed = false
local Flight = false
local SpeedAmount = 5
local FlightAmount = 5

local SelectedPlayer = ""
local LoopGoto = false
local ViewAim = false

local OrbitKill = false
local OrbitKillRadius = 10
local OrbitKillSpeed = 15
local OrbitKillAngle = 0
local OrbitKillPrediction = 0.1
local OrbitKillShootPos = nil

local SilentAim = false
local SilentAimPart = "Head"
local SilentAimPrediction = 0.1

local Aimbot = false
local AimbotLock = false
local AimbotPart = "Head"
local AimbotPrediction = 0.1

local AntiAim = false
local VisualizeAntiAim = false
local AntiAimX = 0
local AntiAimY = 0
local AntiAimZ = 0

local SilentFovCircle = Drawing.new("Circle")
SilentFovCircle.Radius = 150
SilentFovCircle.Visible = false
SilentFovCircle.NumSides = 128
SilentFovCircle.Thickness = 1.5
SilentFovCircle.Color = Color3.fromRGB(255,255,255)

local AimbotFovCircle = Drawing.new("Circle")
AimbotFovCircle.Radius = 150
AimbotFovCircle.Visible = false
AimbotFovCircle.NumSides = 128
AimbotFovCircle.Thickness = 1.5
AimbotFovCircle.Color = Color3.fromRGB(255,255,255)

game:GetService("RunService").RenderStepped:Connect(function()
    SilentFovCircle.Position = UserInputService:GetMouseLocation()
    AimbotFovCircle.Position = UserInputService:GetMouseLocation()
end)

local function GetEquippedWeapon()
    local Char = Player.Character

    if Char then
        local Tool = Char:FindFirstChildWhichIsA("Tool")

        if Tool then
            if Tool:GetAttribute("MaxAmmo") then return Tool end
        end
    end
end

local function GetPlayerFromName(Name)
    print(Name)

    return Players:FindFirstChild(Name)
end

local function GetAimPos(Char)
    local BD = Char:FindFirstChild("BD")

    if BD then
        local MousePos = BD:FindFirstChild("MousePos")

        if MousePos then
            return MousePos.Value
        end
    end

    return Vector3.new(0,0,0)
end

local function IsKnocked(Char)
    local BD = Char:FindFirstChild("BD")

    if BD then
        local Knocked = BD:FindFirstChild("Knocked")

        if Knocked then
            return Knocked.Value
        end
    end

    return true
end

local function GetFovTarget(Circle,HitPart)
    local Target
    local LowestDistance = math.huge

    for i,v in pairs(Players:GetPlayers()) do
        local Char = v.Character

        if v ~= Player and Char then
            local Part = Char:FindFirstChild(HitPart)
            local Hmrp = Char:FindFirstChild("HumanoidRootPart")

            if Hmrp and Part and not IsKnocked(Char) then
                local ScreenPos,OnScreen = Camera:WorldToViewportPoint(Part.Position)
                local Distance = (Circle.Position - Vector2.new(ScreenPos.X,ScreenPos.Y)).Magnitude

                if Distance < Circle.Radius and Distance < LowestDistance and OnScreen then
                    Target = v
                    LowestDistance = Distance
                end
            end
        end
    end

    return Target
end

local Window = Library:CreateWindow({
    Title = 'OneTake | DaHills',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

Library.KeybindFrame.Visible = true

local Tabs = {
    Player = Window:AddTab('Player'),
    Server = Window:AddTab('Server'),
    Combat = Window:AddTab('Combat'),
    Settings = Window:AddTab("Settings")
}

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:ApplyTheme("Tokyo Night")

SaveManager:SetLibrary(Library)
SaveManager:SetFolder('DahillsConfig')
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs.Settings)

local Combat_SilentAim = Tabs.Combat:AddLeftGroupbox("Silent-Aim")
local Combat_Aimbot = Tabs.Combat:AddRightGroupbox("Aimbot")

local Combat_SilentFovCircle = Tabs.Combat:AddLeftGroupbox("Silent Fov Circle")
local Combat_AimbotFovCircle = Tabs.Combat:AddRightGroupbox("Aimbot Fov Circle")
local Combat_AntiAim = Tabs.Combat:AddLeftGroupbox("Anti-Aim")

local Server_Players = Tabs.Server:AddLeftGroupbox("Players")
local Server_Session = Tabs.Server:AddRightGroupbox("Session")

local Player_Main = Tabs.Player:AddLeftGroupbox("Main")
local Player_Character = Tabs.Player:AddRightGroupbox("Character")
local Player_AutoBuy = Tabs.Player:AddLeftGroupbox("Auto-Buy")

local PlrList = {}
for _,v in pairs(Players:GetPlayers()) do
    table.insert(PlrList,v.Name)
end

local PlayerList = Server_Players:AddDropdown('PlayerList', {
    Values = PlrList,
    Default = 1,
    Multi = false,
    Text = nil,
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

Players.PlayerAdded:Connect(function(Plr)
    local PlrList = {}
    for _,v in pairs(Players:GetPlayers()) do
        table.insert(PlrList,v.Name)
    end

    PlayerList:SetValues(PlrList)
end)

Players.PlayerRemoving:Connect(function(Plr)
    local PlrList = {}
    for _,v in pairs(Players:GetPlayers()) do
        table.insert(PlrList,v.Name)
    end

    PlayerList:SetValues(PlrList)
end)

Server_Session:AddButton({
    Text = 'Rejoin Server',
    Func = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,Player)
    end,
    DoubleClick = false,
})

Server_Players:AddToggle('ViewAim', {
    Text = 'View Aim',
    Default = false,
    Tooltip = "Displays a highlighted part.",
    Callback = function(value)
        ViewAim = value

        if value then
            ViewAimPart.Transparency = 0
        else
            ViewAimPart.Transparency = 1
        end

        while ViewAim do
            local Target = GetPlayerFromName(SelectedPlayer)

            if Target then
                local Char = Target.Character
                print("e")

                if Char then
                    local MousePos = GetAimPos(Char)

                    ViewAimPart.Position = MousePos

                    print("done")
                end
            end

            task.wait()
        end
    end
})

Server_Players:AddToggle('LoopGoto', {
    Text = 'Loop Goto',
    Default = false,
    Callback = function(value)
        LoopGoto = value

        while LoopGoto do
            local Target = GetPlayerFromName(SelectedPlayer)

            if (Target) and Target.Character and Player.Character then
                Player.Character:PivotTo(Target.Character:GetPivot() + Vector3.new(0,4,0))
            end

            task.wait()
        end
    end
})

Server_Players:AddButton({
    Text = 'Teleport To',
    Func = function()
        local Target = GetPlayerFromName(SelectedPlayer)

        if (Target) and Target.Character and Player.Character then
            Player.Character:PivotTo(Target.Character:GetPivot())
        end
    end,
    DoubleClick = false,
})

Player_Main:AddToggle('Speed', {
    Text = 'Enable Speed',
    Default = false,
    Callback = function(value)
        Speed = value

        while Speed do
            local delta = RunService.Heartbeat:Wait()

            local Char = Player.Character

            if (Char) and not Flight and not IsKnocked(Char) then
                local Humanoid = Char:FindFirstChild("Humanoid")

                if Humanoid then
                    Char:PivotTo(Char:GetPivot() + Humanoid.MoveDirection * SpeedAmount * delta * 10)
                end
            end
        end
    end
}):AddKeyPicker('SpeedKey', {
    Default = '...',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Speed',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(New)
    end
})

Player_Main:AddToggle('Flight', {
    Text = 'Enable Flight',
    Default = false,
    Callback = function(value)
        Flight = value

        while Flight do
            local delta = RunService.Heartbeat:Wait()

            local Char = Player.Character

            if (Char) and not IsKnocked(Char) then
                local Humanoid = Char:FindFirstChild("Humanoid")
                local Hmrp = Char:FindFirstChild("HumanoidRootPart")

                if Humanoid and Hmrp then
                    Hmrp.Velocity = Vector3.new(0,0,0)

                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Char:PivotTo(Char:GetPivot() + Vector3.new(0,1,0) * FlightAmount * delta * 5)
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        Char:PivotTo(Char:GetPivot() - Vector3.new(0,1,0) * FlightAmount* delta * 5)
                    end

                    Char:PivotTo(Char:GetPivot() + Humanoid.MoveDirection * delta * FlightAmount * 5)     
                end
            end
        end
    end
}):AddKeyPicker('FlightKey', {
    Default = '...',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Flight',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(New)
    end
})

Player_Main:AddSlider('SpeedAmount', {
    Text = 'Speed Amount:',
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        SpeedAmount = value
    end
})

Player_Main:AddSlider('FlightAmount', {
    Text = 'Flight Amount:',
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        FlightAmount = value
    end
})

Combat_AntiAim:AddToggle('AntiAim', {
    Text = "Enable",
    Default = false,
    Tooltip = "Wont work with flight enabled.",
    Callback = function(value)
        AntiAim = value

        while AntiAim do
            RunService.Heartbeat:Wait()

            local Char = Player.Character 

            if Char and not Flight then
                local Hmrp = Char:FindFirstChild("HumanoidRootPart")

                if Hmrp then
                    local OldVel = Hmrp.Velocity
                    local OldLinearVel = Hmrp.AssemblyLinearVelocity

                    Hmrp.Velocity = Vector3.new(AntiAimX,AntiAimY,AntiAimZ)
                    Hmrp.AssemblyLinearVelocity = Vector3.new(AntiAimX,AntiAimY,AntiAimZ)

                    RunService.RenderStepped:Wait()

                    Hmrp.Velocity = OldVel
                    Hmrp.AssemblyLinearVelocity = OldLinearVel
                end
            end
        end
    end
}):AddKeyPicker('AntiAimKey', {
    Default = '...',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Anti-Aim',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(New)
    end
})

Combat_AntiAim:AddToggle('VisualizeAntiAim', {
    Text = "Visualize Velocity",
    Default = false,
    Callback = function(value)
        VisualizeAntiAim = value

        if value then
            AntiAimVisualPart.Transparency = 0
        else
            AntiAimVisualPart.Transparency = 1
        end

        while VisualizeAntiAim do
            local Char = Player.Character

            if Char then
                AntiAimVisualPart.CFrame = CFrame.new(Char:GetPivot().Position + Vector3.new(AntiAimX,AntiAimY,AntiAimZ))
            end

            task.wait()
        end
    end
})

Combat_AntiAim:AddSlider('AntiAimX', {
    Text = 'Velocity X',
    Default = 0,
    Min = -150,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        AntiAimX = value
    end
})

Combat_AntiAim:AddSlider('AntiAimY', {
    Text = 'Velocity Y',
    Default = 0,
    Min = -150,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        AntiAimY = value
    end
})

Combat_AntiAim:AddSlider('AntiAimZ', {
    Text = 'Velocity Z',
    Default = 0,
    Min = -150,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        AntiAimZ = value
    end
})

Combat_SilentAim:AddToggle('SilentAim', {
    Text = "Enable",
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        SilentAim = value
    end
}):AddKeyPicker('SilentAimKey', {
    Default = '...',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Silent-Aim',
    NoUI = false,
    Callback = function(Value)
    end,
    ChangedCallback = function(New)
    end
})

Combat_SilentAim:AddDropdown('SilentHitBone', {
    Values = {"Head","HumanoidRootPart"},
    Default = 1,
    Multi = false,
    Text = "HitBone",
    Callback = function(Value)
        SilentAimPart = Value
    end
})

Combat_SilentAim:AddSlider('SilentAimPred', {
    Text = 'Prediction',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        SilentAimPrediction = value
    end
})

Combat_Aimbot:AddToggle('Aimbot', {
    Text = "Enable",
    Default = false,
    Tooltip = nil,
    Callback = function(value)
        Aimbot = value
    end
}):AddKeyPicker('AimbotLockKey', {
    Default = '...',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Aimbot Lock',
    NoUI = false,
    Callback = function(Value)
        AimbotLock = Value

        while AimbotLock do
            local Target = GetFovTarget(AimbotFovCircle,AimbotPart)
            
            if Target and Aimbot then
                local Vel = Target.Character.HumanoidRootPart.Velocity
                local NewPos = Target.Character[AimbotPart].Position + (Vel * AimbotPrediction)
        
                Camera.CFrame = CFrame.new(Camera.CFrame.Position,NewPos)
            end
        
            task.wait()
        end
    end,
    ChangedCallback = function(New)
    end
})

Combat_Aimbot:AddDropdown('AimbotHitBone', {
    Values = {"Head","HumanoidRootPart"},
    Default = 1,
    Multi = false,
    Text = "HitBone",
    Callback = function(Value)
        AimbotPart = Value
    end
})

Combat_Aimbot:AddSlider('AimbotPred', {
    Text = 'Prediction',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        AimbotPrediction = value
    end
})


Combat_SilentFovCircle:AddToggle('ShowSilentFov', {
    Text = 'Show Fov',
    Default = false,
    Callback = function(value)
        SilentFovCircle.Visible = value
    end,
}):AddColorPicker('SilentFovColor', {
    Default = Color3.fromRGB(255,255,255),
    Callback = function(Value)
       SilentFovCircle.Color = Value
    end
})

Combat_AimbotFovCircle:AddToggle('ShowAimbotFov', {
    Text = 'Show Fov',
    Default = false,
    Callback = function(value)
        AimbotFovCircle.Visible = value
    end,
}):AddColorPicker('AimbotFovColor', {
    Default = Color3.fromRGB(255,255,255),
    Callback = function(Value)
       AimbotFovCircle.Color = Value
    end
})

Combat_SilentFovCircle:AddSlider('SilentFovSize', {
    Text = 'Size',
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        SilentFovCircle.Radius = value
    end
})

Combat_SilentFovCircle:AddSlider('SilentFovThickness', {
    Text = 'Thickness',
    Default = 1.5,
    Min = 1.5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        SilentFovCircle.Thickness = value
    end
})

Combat_AimbotFovCircle:AddSlider('AimbotFovSize', {
    Text = 'Size',
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        AimbotFovCircle.Radius = value
    end
})

Combat_AimbotFovCircle:AddSlider('AimbotFovThickness', {
    Text = 'Thickness',
    Default = 1.5,
    Min = 1.5,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        AimbotFovCircle.Thickness = value
    end
})

oldNamecall = hookmetamethod(game,"__index",function(Key,Value)
    if Key == Mouse and Value == "Hit" then
        if SilentAim then
            local Target = GetFovTarget(SilentFovCircle,SilentAimPart)

            if Target then
                local Velocity = Target.Character.HumanoidRootPart.Velocity
    
                return Target.Character[SilentAimPart].CFrame + (Velocity * SilentAimPrediction)
            end
        end
    end

    return oldNamecall(Key,Value)
end)
