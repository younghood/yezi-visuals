local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

-- WHITELIST --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local whitelist = {
    "yasha_lava055",
    "supra2JZmax",
}

local function isWhitelisted(player)
    local name = player.Name:lower()
    for _, v in ipairs(whitelist) do
        if v:lower() == name then
            return true
        end
    end
    return false
end

if not isWhitelisted(LocalPlayer) then
    LocalPlayer:Kick("You are not in the white list")
    return
end


local Window = MacLib:Window({
    Title = "Yezi Visuals",
    Subtitle = "Visuals | V0.12",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 2,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

local globalSettings = {
    UIBlurToggle = Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool)
            Window:SetAcrylicBlurState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
                Lifetime = 5
            })
        end,
    }),
    NotificationToggler = Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool)
            Window:SetNotificationsState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " Notifications",
                Lifetime = 5
            })
        end,
    }),
    ShowUserInfo = Window:GlobalSetting({
        Name = "Show User Info",
        Default = Window:GetUserInfoState(),
        Callback = function(bool)
            Window:SetUserInfoState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Showing" or "Redacted") .. " User Info",
                Lifetime = 5
            })
        end,
    })
}

local tabVisuals = {
    Visuals = Window:TabGroup()
}

local tabs = {
    Main = tabVisuals.Visuals:Tab({ Name = "Visuals", Image = "rbxassetid://18821914323" }),
    Settings = tabVisuals.Visuals:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })
}

-- FIXED: Defined once, and populated without wiping the table
local sections = {
    MainSection1 = tabs.Main:Section({ Side = "Left" }),
    MainSection3 = tabs.Main:Section({ Side = "Left" }),
    MainSection2 = tabs.Main:Section({ Side = "Right" }),
    MainSection4 = tabs.Main:Section({ Side = "Right" }),
}

-- HEADERS --
sections.MainSection1:Header({
    Name = "Visual"
})

sections.MainSection2:Header({
    Name = "World"
})

sections.MainSection3:Header({
    Name = "Particles"
})

sections.MainSection4:Header({
    Name = "Utils"
})

sections.MainSection1:Slider({
    Name = "Field of View",
    Default = 70,
    Minimum = 1,
    Maximum = 120,
    DisplayMethod = "Percent",
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera

        if _G.FOVConnection then
            _G.FOVConnection:Disconnect()
            _G.FOVConnection = nil
        end

        _G.TargetFOV = Value

        if not _G.FOVConnection then
            _G.FOVConnection = RunService.RenderStepped:Connect(function(delta)
                if Camera then
                    local currentFOV = Camera.FieldOfView
                    local target = _G.TargetFOV
                    if math.abs(currentFOV - target) > 0.01 then
                        Camera.FieldOfView = currentFOV + (target - currentFOV) * (delta * 10)
                    else
                        Camera.FieldOfView = target
                    end
                end
            end)
        end
    end,
}, "FOVSlider")

local BlinkTrailEnabled = false
local TrailSpawnDelay = 0.1     
local TrailFadeTime = 0.4      
local OutlineColor = Color3.fromRGB(255, 0, 0)

local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function createBlinkGhost(character)
	if not character then return end
	
	local ghostModel = Instance.new("Model")
	ghostModel.Name = "Blink_SelectionBoxTrail"
	
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			
			local ghostPart = Instance.new("Part")
			ghostPart.Size = part.Size
			ghostPart.CFrame = part.CFrame
			ghostPart.Anchored = true
			ghostPart.CanCollide = false
			ghostPart.CanTouch = false
			ghostPart.CanQuery = false
			ghostPart.Transparency = 1 
			ghostPart.Parent = ghostModel
			
			local selectionBox = Instance.new("SelectionBox")
			selectionBox.Adornee = ghostPart 
			selectionBox.Color3 = OutlineColor
			selectionBox.LineThickness = 0.05 
			selectionBox.SurfaceTransparency = 1 
			selectionBox.Transparency = 0 
			selectionBox.Parent = ghostPart
			
			local tweenInfo = TweenInfo.new(TrailFadeTime, Enum.EasingStyle.Linear)
			local tween = TweenService:Create(selectionBox, tweenInfo, {Transparency = 1})
			tween:Play()
		end
	end
	
	ghostModel.Parent = workspace
	
	task.delay(TrailFadeTime + 0.1, function()
		ghostModel:Destroy()
	end)
end

task.spawn(function()
	while true do
		task.wait(0.01)
		if BlinkTrailEnabled then
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			
			if hrp and hum and hum.MoveDirection.Magnitude > 0 then
				createBlinkGhost(char)
				task.wait(TrailSpawnDelay)
			end
		end
	end
end)

sections.MainSection1:Divider()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local MAX_ESP_DISTANCE = 3000
local ESPOptions = {
    Box       = false,
    HealthBar = false,
    Nickname  = false,
    Distance  = false,
    Skeleton  = false,
}

local COLOR_BOX      = Color3.fromRGB(255, 255, 255)
local COLOR_NICK     = Color3.fromRGB(255, 255, 255)
local COLOR_DIST     = Color3.fromRGB(200, 200, 200)
local COLOR_HP_BG    = Color3.fromRGB(50,  50,  50)
local COLOR_HP_FG    = Color3.fromRGB(220, 50,  50)
local COLOR_BLACK    = Color3.fromRGB(0,   0,   0)
local COLOR_SKELETON = Color3.fromRGB(255, 255, 255)

local THICKNESS = 1
local FONT      = Drawing.Fonts.UI
local TEXT_SIZE = 13

-- Кости скелета
local SKELETON_BONES_R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}, {"Left Arm", "Left Leg"}, {"Right Arm", "Right Leg"},
}
local SKELETON_BONES_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local espObjects = {}

local function SetVis(obj, visible)
    if obj.Visible ~= visible then
        obj.Visible = visible
    end
end

local function NewDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function MakeBoneLines(count)
    local lines = {}
    for i = 1, count do
        lines[i] = NewDrawing("Line", { Thickness = 1, Color = COLOR_SKELETON, Visible = false })
    end
    return lines
end

local function CreateESPForPlayer(player)
    if espObjects[player] then return end

    -- ИСПРАВЛЕНИЕ: Используем Square с Filled = false для идеального бокса без стрелок и дыр
    local box = NewDrawing("Square", { Thickness = THICKNESS, Color = COLOR_BOX, Filled = false, Visible = false })

    -- ИСПРАВЛЕНИЕ: Обводка хпбара теперь тоже цельный прямоугольник
    local hpOutline = NewDrawing("Square", { Thickness = 1, Color = COLOR_BLACK, Filled = false, Visible = false })
    local healthBg  = NewDrawing("Square", { Color = COLOR_HP_BG, Filled = true, Visible = false })
    local healthFg  = NewDrawing("Square", { Color = COLOR_HP_FG, Filled = true, Visible = false })

    local nick = NewDrawing("Text", { Size = TEXT_SIZE, Font = FONT, Color = COLOR_NICK, Outline = true, Visible = false, Center = true })
    local dist = NewDrawing("Text", { Size = TEXT_SIZE, Font = FONT, Color = COLOR_DIST, Outline = true, Visible = false })

    local skeletonLines = MakeBoneLines(#SKELETON_BONES_R15)

    espObjects[player] = {
        box            = box,
        hpOutline      = hpOutline,
        healthBg       = healthBg,
        healthFg       = healthFg,
        nick           = nick,
        dist           = dist,
        skeletonLines  = skeletonLines,
    }
end

local function RemoveESPForPlayer(player)
    local data = espObjects[player]
    if not data then return end
    data.box:Remove()
    for _, line in ipairs(data.skeletonLines) do line:Remove() end
    data.hpOutline:Remove()
    data.healthBg:Remove()
    data.healthFg:Remove()
    data.nick:Remove()
    data.dist:Remove()
    espObjects[player] = nil
end

local function HideESP(data)
    if not data then return end
    SetVis(data.box, false)
    for _, line in ipairs(data.skeletonLines) do SetVis(line, false) end
    SetVis(data.hpOutline, false)
    SetVis(data.healthBg, false)
    SetVis(data.healthFg, false)
    SetVis(data.nick, false)
    SetVis(data.dist, false)
end

local function GetCharacterParts(character)
    if not character then return nil, nil, nil end
    return character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild("Head"), character:FindFirstChildOfClass("Humanoid")
end

local function GetBoundingBox(root, head, cam)
    local topWorld    = head.Position + Vector3.new(0,  head.Size.Y / 2 + 0.15, 0)
    local bottomWorld = root.Position - Vector3.new(0,  3.1, 0)

    local topScreen,    _ = cam:WorldToViewportPoint(topWorld)
    local bottomScreen, _ = cam:WorldToViewportPoint(bottomWorld)

    if topScreen.Z <= 0 and bottomScreen.Z <= 0 then return nil end

    local screenH = math.abs(bottomScreen.Y - topScreen.Y)
    local screenW = screenH * 0.55
    local centerX = (topScreen.X + bottomScreen.X) / 2

    -- Оптимизация + фикс стыков: Округляем координаты до целых чисел
    return math.floor(centerX - screenW / 2), math.floor(math.min(topScreen.Y, bottomScreen.Y)), math.floor(screenW), math.floor(screenH)
end

local function DrawSkeleton(character, lines, cam)
    local isR15 = character:FindFirstChild("UpperTorso") ~= nil
    local bones = isR15 and SKELETON_BONES_R15 or SKELETON_BONES_R6

    for i = 1, #lines do
        local line = lines[i]
        local bonePair = bones[i]

        if bonePair then
            local partA = character:FindFirstChild(bonePair[1])
            local partB = character:FindFirstChild(bonePair[2])

            if partA and partB then
                local sA, onA = cam:WorldToViewportPoint(partA.Position)
                local sB, onB = cam:WorldToViewportPoint(partB.Position)
                
                if sA.Z > 0 and sB.Z > 0 then
                    line.From = Vector2.new(sA.X, sA.Y)
                    line.To   = Vector2.new(sB.X, sB.Y)
                    SetVis(line, true)
                else
                    SetVis(line, false)
                end
            else
                SetVis(line, false)
            end
        else
            SetVis(line, false)
        end
    end
end

RunService:BindToRenderStep("ESPMaster_Update", Enum.RenderPriority.Camera.Value + 1, function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local lpChar = LocalPlayer.Character
    local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    local myPos  = lpRoot and lpRoot.Position or cam.CFrame.Position

    for player, data in pairs(espObjects) do
        if not ESPEnabled then
            HideESP(data)
            continue
        end

        local character = player.Character
        local root, head, hum = GetCharacterParts(character)

        if not root or not head or not hum or hum.Health <= 0 then
            HideESP(data)
            continue
        end

        local distAmount = math.floor((root.Position - myPos).Magnitude)
        if distAmount > MAX_ESP_DISTANCE then
            HideESP(data)
            continue
        end

        local x, y, w, h = GetBoundingBox(root, head, cam)
        if not x then
            HideESP(data)
            continue
        end

        -- BOX (Идеальный нативный квадрат)
        if ESPOptions.Box then
            data.box.Size     = Vector2.new(w, h)
            data.box.Position = Vector2.new(x, y)
            SetVis(data.box, true)
        else
            SetVis(data.box, false)
        end

        -- HEALTH BAR (Идеальные стыки без шпор)
        if ESPOptions.HealthBar then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barWidth = w
            local barHeight = 3 
            local barY = y + h + 5
            local barX = x
            
            data.healthBg.Size     = Vector2.new(barWidth, barHeight)
            data.healthBg.Position = Vector2.new(barX, barY)
            SetVis(data.healthBg, true)

            data.healthFg.Size     = Vector2.new(math.floor(barWidth * hpRatio), barHeight)
            data.healthFg.Position = Vector2.new(barX, barY)
            SetVis(data.healthFg, true)
            
            -- Обводка теперь просто внешний Square на 1 пиксель больше во все стороны
            data.hpOutline.Size     = Vector2.new(barWidth + 0, barHeight + 0)
            data.hpOutline.Position = Vector2.new(barX - 0, barY - 0)
            SetVis(data.hpOutline, true)
        else
            SetVis(data.hpOutline, false)
            SetVis(data.healthBg, false)
            SetVis(data.healthFg, false)
        end

        -- NICKNAME
        if ESPOptions.Nickname then
            data.nick.Text = player.DisplayName
            data.nick.Position = Vector2.new(x + w / 2, y - TEXT_SIZE - 4)
            SetVis(data.nick, true)
        else
            SetVis(data.nick, false)
        end

        -- DISTANCE
        if ESPOptions.Distance then
            data.dist.Text     = distAmount .. " studs"
            data.dist.Position = Vector2.new(x + w + 4, y)
            SetVis(data.dist, true)
        else
            SetVis(data.dist, false)
        end

        -- SKELETON
        if ESPOptions.Skeleton then
            DrawSkeleton(character, data.skeletonLines, cam)
        else
            for _, line in ipairs(data.skeletonLines) do SetVis(line, false) end
        end
    end
end)

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    CreateESPForPlayer(player)

    local function OnCharacterAdded(character)
        character:WaitForChild("HumanoidRootPart", 10)
        character:WaitForChild("Head", 10)
        character:WaitForChild("Humanoid", 10)
    end

    if player.Character then OnCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(OnCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(RemoveESPForPlayer)

-- UI Кнопки
sections.MainSection1:Toggle({
    Name    = "ESP Master",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if not ESPEnabled then
            for _, data in pairs(espObjects) do HideESP(data) end
        end
    end,
}, "EspMasterToggle")

sections.MainSection1:Dropdown({
    Name     = "Esp function",
    Search   = true,
    Multi    = true,
    Required = false,
    Options  = {"Box", "Health bar", "Nickname", "Distance", "Skeleton"},
    Default  = {},
    Callback = function(Value)
        ESPOptions.Box       = Value["Box"]        == true
        ESPOptions.HealthBar = Value["Health bar"] == true
        ESPOptions.Nickname  = Value["Nickname"]   == true
        ESPOptions.Distance  = Value["Distance"]   == true
        ESPOptions.Skeleton  = Value["Skeleton"]   == true
    end,
}, "EspFunctionDropdown")

-- Слайдер дистанции ESP
sections.MainSection1:Slider({
    Name = "ESP Distance",
    Default = 3000,
    Minimum = 0,
    Maximum = 25000,
    DisplayMethod = "Value",
    Callback = function(Value)
        MAX_ESP_DISTANCE = Value
    end,
}, "ESPDistanceSlider")

sections.MainSection1:Divider()

sections.MainSection1:Toggle({
	Name = "Blink Trail",
	Default = false,
	Callback = function(value)
		BlinkTrailEnabled = value
	end,
})

sections.MainSection1:Slider({
	Name = "Trail Density",
	Default = 0.1,
	Minimum = 0.05,
	Maximum = 0.5,
	DisplayMethod = "Value",
	Callback = function(Value)
		TrailSpawnDelay = Value
	end,
})

sections.MainSection1:Colorpicker({
	Name = "Trail Color",
	Default = Color3.fromRGB(255, 0, 0),
	Alpha = 0,
	Callback = function(color, alpha)
		OutlineColor = color
		
		local r, g, b = math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)
		local formattedColor = string.format("%d, %d, %d", r, g, b)
	end,
}, "TrailColorToggle")

sections.MainSection1:Divider()

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Флаги состояния (чтобы скрипт знал, включен ли эффект и какой цвет выбран)
local haloEnabled = false
local haloColor = Color3.fromRGB(0, 133, 220) -- Дефолтный голубой цвет со скрина

-- Функция, которая создаёт и настраивает партиклы
local function createHalo(character)
	local head = character:WaitForChild("Head", 5)
	if not head then return end

	-- Удаляем старый атчмент, если он вдруг остался
	local oldAttachment = head:FindFirstChild("HaloAttachment")
	if oldAttachment then oldAttachment:Destroy() end

	-- Если тумблер выключен, ничего не создаем
	if not haloEnabled then return end

	-- 1. Создаем базовый Attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = "HaloAttachment" -- Техническое имя для отслеживания скриптом
	attachment.Visible = false
	attachment.CFrame = CFrame.new(
		-0.250003815, 0.933012962, 0.258823395,
		0.468902647, -0.249989927, -0.847133636,
		-0.117149852, 0.933033288, -0.340183437,
		0.87544632, 0.258754492, 0.408215493
	)
	attachment.Parent = head

	-- Хелпер для общих настроек
	local function applyParticleSettings(particle)
		particle.Brightness = 2
		particle.Color = ColorSequence.new(haloColor) -- Применяем выбранный цвет
		particle.LightEmission = 1
		particle.LightInfluence = 0
		particle.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		particle.Squash = NumberSequence.new(0)
		particle.Texture = "rbxassetid://8819682608"
		particle.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.8, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		particle.LockedToPart = true
		particle.EmissionDirection = Enum.NormalId.Top
		particle.Enabled = true
		particle.Lifetime = NumberRange.new(1, 1)
		particle.Rate = 7
		particle.Rotation = NumberRange.new(0, 360)
		particle.RotSpeed = NumberRange.new(-400, 400)
		particle.Speed = NumberRange.new(0.001, 0.001)
		particle.SpreadAngle = Vector2.new(5, 5)
		particle.FlipbookLayout = Enum.ParticleFlipbookLayout.None
		particle.FlipbookMode = Enum.ParticleFlipbookMode.Loop
		particle.FlipbookFramerate = NumberRange.new(1, 1)
	end

	-- 2. Создаем Ring1
	local ring1 = Instance.new("ParticleEmitter")
	ring1.Name = "Ring1"
	applyParticleSettings(ring1)
	ring1.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2.5),
		NumberSequenceKeypoint.new(1, 3)
	})
	ring1.Parent = attachment

	-- 3. Создаем Ring2
	local ring2 = Instance.new("ParticleEmitter")
	ring2.Name = "Ring2"
	applyParticleSettings(ring2)
	ring2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 3)
	})
	ring2.Parent = attachment
end

-- Авто-респавн эффекта после смерти
localPlayer.CharacterAdded:Connect(function(character)
	createHalo(character)
end)

-- Функция для быстрого обновления цвета/состояния "на лету" без ресета
local function updateExistingHalo()
	if localPlayer.Character then
		local head = localPlayer.Character:FindFirstChild("Head")
		if head then
			local attachment = head:FindFirstChild("HaloAttachment")
			if attachment then
				if haloEnabled then
					-- Если включен, просто обновляем цвета у Ring1 и Ring2
					if attachment:FindFirstChild("Ring1") then attachment.Ring1.Color = ColorSequence.new(haloColor) end
					if attachment:FindFirstChild("Ring2") then attachment.Ring2.Color = ColorSequence.new(haloColor) end
				else
					-- Если выключили — сносим атчмент
					attachment:Destroy()
				end
			elseif haloEnabled then
				-- Если эффекта нет, но его включили — создаем
				createHalo(localPlayer.Character)
			end
		end
	end
end

--- ====================================================================
--- ТВОИ ЭЛЕМЕНТЫ МЕНЮ:
--- ====================================================================

sections.MainSection1:Toggle({
	Name = "Halo Rings",
	Default = false,
	Callback = function(value)
		haloEnabled = value
		updateExistingHalo()
	end,
}, "HaloRingsToggle")

sections.MainSection1:Colorpicker({
	Name = "Halo Color",
	Default = Color3.fromRGB(0, 133, 220), -- Дефолтный голубой
	Alpha = 0,
	Callback = function(color, alpha)
		haloColor = color
		updateExistingHalo()
	end,
}, "HaloColorToggle")

sections.MainSection1:Divider()

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Переменные для хранения ссылок на эффекты (чтобы управлять ими из UI)
local rightWing, leftWing, ambientParticle
local connections = {}

-- Функция для создания крыльев
local function createWings()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local torso = character:WaitForChild("Torso", 5)

    if torso and torso:IsA("BasePart") then
        -- 1. ПЕРВЫЙ АТЧМЕНТ (ПРАВОЕ КРЫЛО)
        local rightAttachment = Instance.new("Attachment")
        rightAttachment.Name = "Wings_RightAttach"
        rightAttachment.Visible = false
        rightAttachment.CFrame = CFrame.new(
            1.167, 0.5, 0.852,
            0.966, 0, -0.259,
            0, 1, 0,
            0.259, 0, 0.966
        )
        rightAttachment.Parent = torso

        rightWing = Instance.new("ParticleEmitter")
        rightWing.Name = "Wing"
        rightWing.Brightness = 1
        rightWing.Color = ColorSequence.new(Color3.fromRGB(0, 133, 220))
        rightWing.LightEmission = 1
        rightWing.LightInfluence = 0
        rightWing.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        rightWing.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 2.75),
            NumberSequenceKeypoint.new(1, 3.5)
        })
        rightWing.Squash = NumberSequence.new(0)
        rightWing.Texture = "http://www.roblox.com/asset/?id=13267054240"
        rightWing.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.944),
            NumberSequenceKeypoint.new(0.2, 0),
            NumberSequenceKeypoint.new(0.8, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        rightWing.LockedToPart = true
        rightWing.EmissionDirection = Enum.NormalId.Front
        rightWing.Enabled = false -- Изначально выключено, управляется через Toggle
        rightWing.Lifetime = NumberRange.new(1, 1)
        rightWing.Rate = 4
        rightWing.Rotation = NumberRange.new(-15, -15)
        rightWing.RotSpeed = NumberRange.new(0, 0)
        rightWing.Speed = NumberRange.new(0.05, 0.05)
        rightWing.SpreadAngle = Vector2.new(0, 0)
        rightWing.Parent = rightAttachment

        -- 2. ВТОРОЙ АТЧМЕНТ (ЛЕВОЕ КРЫЛО)
        local leftAttachment = Instance.new("Attachment")
        leftAttachment.Name = "Wings_LeftAttach"
        leftAttachment.Visible = false
        leftAttachment.CFrame = CFrame.new(
            -1.012, 0.5, 0.852,
            0.966, 0, 0.259,
            0, 1, 0,
            -0.259, 0, 0.966
        )
        leftAttachment.Parent = torso

        leftWing = rightWing:Clone()
        leftWing.EmissionDirection = Enum.NormalId.Back
        leftWing.Parent = leftAttachment

        -- 3. ТРЕТИЙ АТЧМЕНТ (ЦЕНТРАЛЬНЫЙ ЭМБИЕНТ)
        local ambientAttachment = Instance.new("Attachment")
        ambientAttachment.Name = "Wings_AmbientAttach"
        ambientAttachment.Visible = false
        ambientAttachment.CFrame = CFrame.new(
            0, 0.3, 0,
            1, 0, 0,
            0, 1, 0,
            0, 0, 1
        )
        ambientAttachment.Parent = torso

        ambientParticle = Instance.new("ParticleEmitter")
        ambientParticle.Name = "Ambient"
        ambientParticle.Brightness = 2
        ambientParticle.Color = ColorSequence.new(Color3.fromRGB(0, 133, 220))
        ambientParticle.LightEmission = 1
        ambientParticle.LightInfluence = 0
        ambientParticle.Orientation = Enum.ParticleOrientation.FacingCamera
        ambientParticle.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 3),
            NumberSequenceKeypoint.new(1, 4)
        })
        ambientParticle.Squash = NumberSequence.new(0)
        ambientParticle.Texture = "rbxassetid://11402221943"
        ambientParticle.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        ambientParticle.LockedToPart = true
        ambientParticle.EmissionDirection = Enum.NormalId.Top
        ambientParticle.Enabled = false -- Изначально выключено, управляется через Toggle
        ambientParticle.Lifetime = NumberRange.new(2, 2)
        ambientParticle.Rate = 5
        ambientParticle.Rotation = NumberRange.new(0, 360)
        ambientParticle.RotSpeed = NumberRange.new(0, 0)
        ambientParticle.Speed = NumberRange.new(0.5, 0.5)
        ambientParticle.SpreadAngle = Vector2.new(180, 180)
        ambientParticle.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        ambientParticle.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
        ambientParticle.FlipbookFramerate = NumberRange.new(1, 1)
        ambientParticle.Parent = ambientAttachment
    end
end

-- Инициализируем создание при первом запуске
createWings()

-- Пересоздаем крылья после респавна персонажа
local characterAddedConnection = localPlayer.CharacterAdded:Connect(function()
    createWings()
end)

-- Глобальное состояние (включены ли крылья сейчас в UI)
local wingsEnabled = false
local currentColor = Color3.fromRGB(0, 133, 220) -- Цвет по умолчанию

---
--- ИНТЕГРАЦИЯ В ТВОЮ UI БИБЛИОТЕКУ (Пример со скриншотов)
---

-- 1. Элемент включения/выключения крыльев
sections.MainSection1:Toggle({
    Name = "Flight Wings",
    Default = false,
    Callback = function(value)
        wingsEnabled = value
        
        -- Меняем состояние партиклов, если они существуют в данный момент
        if rightWing and leftWing and ambientParticle then
            rightWing.Enabled = value
            leftWing.Enabled = value
            ambientParticle.Enabled = value
        end
    end
}, "FlightToggle")

-- 2. Элемент выбора цвета для крыльев
sections.MainSection1:Colorpicker({
    Name = "Wings Color",
    Default = Color3.fromRGB(0, 133, 220),
    Alpha = 0,
    Callback = function(color, alpha)
        currentColor = color
        
        -- Динамически обновляем цвет партиклов
        if rightWing and leftWing and ambientParticle then
            local colorSeq = ColorSequence.new(color)
            rightWing.Color = colorSeq
            leftWing.Color = colorSeq
            ambientParticle.Color = colorSeq
        end
    end
}, "WingsColorToggle")

sections.MainSection1:Divider()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local hatName = "ChinaHat_Visual_True"

local HatEnabled = false
local HatColor = Color3.fromRGB(255, 255, 255)

local function removeAllOldHats(character)
    if not character then return end
    for _, child in pairs(character:GetChildren()) do
        if child.Name:find("ChinaHat") then
            child:Destroy()
        end
    end
    local head = character:FindFirstChild("Head")
    if head then
        for _, child in pairs(head:GetChildren()) do
            if child.Name:find("ChinaHat") then
                child:Destroy()
            end
        end
    end
end

local function createChinaHat(character)
    removeAllOldHats(character)
    
    if not HatEnabled then return end

    local head = character:WaitForChild("Head", 5)
    if not head then return end

    local cone = Instance.new("ConeHandleAdornment")
    cone.Name = hatName
    cone.Height = 0.7 
    cone.Radius = 1.5 
    cone.Transparency = 0.4 
    
    cone.Adornee = head
    cone.CFrame = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
    cone.AlwaysOnTop = false
    cone.Color3 = HatColor
    cone.Parent = head

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not cone or not cone.Parent or not character or not character.Parent or not head or not head.Parent then
            connection:Disconnect()
            return
        end

        if not HatEnabled then
            cone:Destroy()
            connection:Disconnect()
            return
        end

        if cone.Color3 ~= HatColor then
            cone.Color3 = HatColor
        end

        if Camera and Camera.Focus then
            local distance = (Camera.CoordinateFrame.p - head.Position).Magnitude
            if distance < 2 then
                cone.Visible = false
            else
                cone.Visible = true
            end
        end
    end)
end

local function refreshHat()
    if LocalPlayer.Character then
        createChinaHat(LocalPlayer.Character)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if HatEnabled then
        createChinaHat(character)
    end
end)

--- ====================================================================
--- АДАПТИРОВАННЫЕ ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (Kuzu Hub)
--- ====================================================================

-- Замени `sections.MainSection1` на твою секцию, если она называется иначе
sections.MainSection1:Toggle({
    Name = "ChinaHat",
    Default = false,
    Callback = function(value)
        HatEnabled = value
        refreshHat()
    end,
}, "ToggleChinaHat")

sections.MainSection1:Colorpicker({
    Name = "Color ChinaHat",
    Default = Color3.fromRGB(255, 255, 255),
    Alpha = 0,
    Callback = function(color, alpha)
        -- Библиотека может возвращать RGB в диапазоне 0-1, конвертируем в 0-255 для надежности
        local r = math.round(color.R * 255)
        local g = math.round(color.G * 255)
        local b = math.round(color.B * 255)
        
        HatColor = Color3.fromRGB(r, g, b)
    end,
}, "ColorChinaHat")

sections.MainSection1:Divider()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Глобальные переменные управления состоянием плаща
local capeEnabled = false
local capeTextureId = "" 
local capeColor = Color3.fromRGB(150, 0, 0) -- Дефолтный цвет плаща
local characterAddedConnection = nil
local renderConnection = nil

-- Функция полной очистки плаща из памяти
local function destroyCape()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    local character = localPlayer.Character
    if character then
        local oldCape = character:FindFirstChild("StrictCape")
        if oldCape then oldCape:Destroy() end
    end
end

-- Основная функция создания и обсчета физики плаща
local function createUltimateCape()
    destroyCape() -- Чистим старый плащ перед пересозданием
    if not capeEnabled then return end

    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local torso = character:WaitForChild("Torso", 5) or character:WaitForChild("UpperTorso", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)

    if torso and torso:IsA("BasePart") and humanoid then
        local CAPE_MATERIAL = Enum.Material.SmoothPlastic
        
        -- Настройки углов наклона (Твоя физика)
        local IDLE_PITCH = -4      
        local FORWARD_PITCH = -35  
        local OTHER_PITCH = 0      
        local FALL_PITCH = -85     
        local SIDE_ROLL = 15
        local LERP_SPEED = 6

        -- 1. Создаем саму деталь плаща
        local cape = Instance.new("Part")
        cape.Name = "StrictCape"
        cape.Size = Vector3.new(1.8, 2.8, 0.1) 
        cape.Color = capeColor -- Применяем цвет из колорпикера
        cape.Material = CAPE_MATERIAL
        cape.CanCollide = false
        cape.Massless = true
        cape.Parent = character

        -- Наложение текстуры
        if capeTextureId ~= "" then
            local decal = Instance.new("Decal")
            decal.Name = "CapeTexture"
            decal.Face = Enum.NormalId.Back -- ФИКС: Теперь используется правильный Enum.NormalId
            decal.Texture = capeTextureId
            decal.Parent = cape
        end

        -- 2. Сварка плаща со спиной
        local weld = Instance.new("Weld")
        weld.Name = "CapeWeld"
        weld.Part0 = torso
        weld.Part1 = cape
        
        local baseC0 = CFrame.new(0, 1.0, 0.55)
        local baseC1 = CFrame.new(0, 1.4, 0)
        
        weld.C0 = baseC0
        weld.C1 = baseC1
        weld.Parent = cape

        local currentPitch = IDLE_PITCH
        local currentRoll = 0

        -- 3. Физический цикл движения плаща
        renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if not character:IsDescendantOf(workspace) or not cape:IsDescendantOf(character) or not torso:IsDescendantOf(character) then
                if renderConnection then renderConnection:Disconnect() end
                return
            end

            local targetPitch = IDLE_PITCH
            local targetRoll = 0
            
            local velocity = torso.AssemblyLinearVelocity
            local fallSpeed = velocity.Y
            local moveDirection = humanoid.MoveDirection
            local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
            local inAir = (humanoid.FloorMaterial == Enum.Material.Air)

            -- Наклоны и крены при ходьбе
            if horizontalSpeed > 1 and moveDirection.Magnitude > 0.1 then
                local localMove = torso.CFrame:VectorToObjectSpace(moveDirection)

                if localMove.X > 0.5 then
                    targetRoll = -SIDE_ROLL 
                elseif localMove.X < -0.5 then
                    targetRoll = SIDE_ROLL  
                end

                if localMove.Z < -0.5 then
                    targetPitch = FORWARD_PITCH 
                elseif localMove.Z > 0.5 then
                    targetPitch = OTHER_PITCH
                end
            end

            -- Падение
            if inAir and fallSpeed < -8 then
                targetPitch = FALL_PITCH
            end

            -- Сглаживание через Lerp
            currentPitch = currentPitch + (targetPitch - currentPitch) * math.clamp(deltaTime * LERP_SPEED, 0, 1)
            currentRoll = currentRoll + (targetRoll - currentRoll) * math.clamp(deltaTime * LERP_SPEED, 0, 1)

            weld.C0 = baseC0 * CFrame.Angles(math.rad(currentPitch), 0, math.rad(currentRoll))
        end)
    end
end

--- ==========================================
--- ИНТЕГРАЦИЯ В ТВОЁ МЕНЮ (KUZU HUB)
--- ==========================================

-- 1. Переключатель плаща (Включение/Выключение)
sections.MainSection1:Toggle({
    Name = "Cape",
    Default = false,
    Callback = function(value)
        capeEnabled = value
        if capeEnabled then
            createUltimateCape()
            characterAddedConnection = localPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                createUltimateCape()
            end)
        else
            if characterAddedConnection then
                characterAddedConnection:Disconnect()
                characterAddedConnection = nil
            end
            destroyCape()
        end
    end
}, "CapeToggle")

-- 2. Выбор цвета (Обновляет цвет основы плаща в реальном времени)
sections.MainSection1:Colorpicker({
    Name = "Cape Color",
    Default = Color3.fromRGB(150, 0, 0),
    Alpha = 0,
    Callback = function(color, alpha)
        capeColor = color
        
        -- Если плащ уже создан, меняем ему цвет на лету без перезапуска скрипта
        local character = localPlayer.Character
        local cape = character and character:FindFirstChild("StrictCape")
        if cape and cape:IsA("BasePart") then
            cape.Color = color
        end
    end
}, "CapeColorToggle")

-- 3. Поле ввода текстуры (Принимает и ID, и ссылки целиком)
sections.MainSection1:Input({
    Name = "Cape Texture ID",
    Placeholder = "Insert the ID or the link in full...",
    AcceptedCharacters = "All",
    Callback = function(input)
        local assetId = string.match(input, "%d+")
        
        if assetId then
            capeTextureId = "rbxthumb://type=Asset&id=" .. assetId .. "&w=420&h=420"
        else
            capeTextureId = ""
        end
        
        if capeEnabled then
            createUltimateCape()
        end
    end
}, "CapeTextureInput")

sections.MainSection2:Toggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(value)
        local Lighting = game:GetService("Lighting")

        if not _G.FullBrightExecuted then
            _G.FullBrightEnabled = false
            _G.NormalLightingSettings = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient
            }

            Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
                if Lighting.Brightness ~= 1 and Lighting.Brightness ~= _G.NormalLightingSettings.Brightness then
                    _G.NormalLightingSettings.Brightness = Lighting.Brightness
                    if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
                    Lighting.Brightness = 1
                end
            end)
            Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
                if Lighting.ClockTime ~= 12 and Lighting.ClockTime ~= _G.NormalLightingSettings.ClockTime then
                    _G.NormalLightingSettings.ClockTime = Lighting.ClockTime
                    if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
                    Lighting.ClockTime = 12
                end
            end)
            Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
                if Lighting.FogEnd ~= 786543 and Lighting.FogEnd ~= _G.NormalLightingSettings.FogEnd then
                    _G.NormalLightingSettings.FogEnd = Lighting.FogEnd
                    if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
                    Lighting.FogEnd = 786543
                end
            end)
            Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
                if Lighting.GlobalShadows ~= false and Lighting.GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
                    _G.NormalLightingSettings.GlobalShadows = Lighting.GlobalShadows
                    if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
                    Lighting.GlobalShadows = false
                end
            end)
            Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
                if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) and Lighting.Ambient ~= _G.NormalLightingSettings.Ambient then
                    _G.NormalLightingSettings.Ambient = Lighting.Ambient
                    if not _G.FullBrightEnabled then repeat wait() until _G.FullBrightEnabled end
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                end
            end)

            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 786543
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)

            local LatestValue = true
            spawn(function()
                repeat wait() until _G.FullBrightEnabled
                while wait() do
                    if _G.FullBrightEnabled ~= LatestValue then
                        if not _G.FullBrightEnabled then
                            Lighting.Brightness = _G.NormalLightingSettings.Brightness
                            Lighting.ClockTime = _G.NormalLightingSettings.ClockTime
                            Lighting.FogEnd = _G.NormalLightingSettings.FogEnd
                            Lighting.GlobalShadows = _G.NormalLightingSettings.GlobalShadows
                            Lighting.Ambient = _G.NormalLightingSettings.Ambient
                        else
                            Lighting.Brightness = 1
                            Lighting.ClockTime = 12
                            Lighting.FogEnd = 786543
                            Lighting.GlobalShadows = false
                            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                        end
                        LatestValue = not LatestValue
                    end
                end
            end)
        end

        _G.FullBrightExecuted = true
        _G.FullBrightEnabled = value
    end,
}, "FullBrightToggle")

-- Подключаем слайдер к твоей секции меню
sections.MainSection2:Slider({
    Name = "World time",
    Default = 12, -- Начнем с полдня
    Minimum = 0,
    Maximum = 23,
    DisplayMethod = "Value", -- Показывает часы вместо процентов
    Callback = function(Value)
        -- Меняем время суток в Lighting на ходу
        game:GetService("Lighting").ClockTime = Value
        
        -- Если выкрутил ползунок на самый максимум (24), 
        -- запускаем бесконечный лютый цикл быстрой смены времени
        if Value >= 24 then
            _G.DirtLoop = true
            task.spawn(function()
                while _G.DirtLoop do
                    -- Крутим время с бешеной скоростью
                    game:GetService("Lighting").ClockTime = game:GetService("Lighting").ClockTime + 0.2
                    
                    -- Добавим немного треша: меняем цвета неба рандомно
                    game:GetService("Lighting").Ambient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    
                    task.wait(0.01) -- Минимальная задержка для максимального эффекта
                end
            end)
        else
            -- Если убрал с максимума — выключаем лютый режим и возвращаем дефолтные цвета
            _G.DirtLoop = false
            game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end,
}, "TimeSlider")

sections.MainSection2:Dropdown({
    Name = "Skybox Changer",
    Search = true,
    Multi = false,
    Required = false,
    Options = {"Pink Sky", "Black Sky", "Rain Sky", "Red Sky", "Darkness Sky", "Black-Blue Sky", "Crossroads Sky", "Orange Sky", "Meme Sky"},
    Default = {"Pink Sky"},
    Callback = function(Value)
    local selectedSky
    if type(Value) == "string" then
        selectedSky = Value
    elseif type(Value) == "table" then
        selectedSky = Value[1]
    end

    if not selectedSky then return end

    -- Получаем Lighting правильно
    local Lighting = game:GetService("Lighting")

        local skyPresets = {
            ["Pink Sky"] = {
                CelestialBodiesShown = false,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "http://www.roblox.com/asset/?id=271042516",
                SkyboxDn = "http://www.roblox.com/asset/?id=271077243",
                SkyboxFt = "http://www.roblox.com/asset/?id=271042556",
                SkyboxLf = "http://www.roblox.com/asset/?id=271042310",
                SkyboxRt = "http://www.roblox.com/asset/?id=271042467",
                SkyboxUp = "http://www.roblox.com/asset/?id=271077958",
                StarCount = 1334,
                SunAngularSize = 21,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Black Sky"] = {
                CelestialBodiesShown = false,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "http://www.roblox.com/asset/?id=2013298",
                SkyboxDn = "http://www.roblox.com/asset/?id=2013298",
                SkyboxFt = "http://www.roblox.com/asset/?id=2013298",
                SkyboxLf = "http://www.roblox.com/asset/?id=2013298",
                SkyboxRt = "http://www.roblox.com/asset/?id=2013298",
                SkyboxUp = "http://www.roblox.com/asset/?id=2013298",
                StarCount = 0,
                SunAngularSize = 21,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Rain Sky"] = {
                CelestialBodiesShown = true,
                MoonAngularSize = 1,
                MoonTextureId = "",
                SkyboxBk = "http://www.roblox.com/asset/?id=4495864450",
                SkyboxDn = "http://www.roblox.com/asset/?id=4495864887",
                SkyboxFt = "http://www.roblox.com/asset/?id=4495865458",
                SkyboxLf = "http://www.roblox.com/asset/?id=4495866035",
                SkyboxRt = "http://www.roblox.com/asset/?id=4495866584",
                SkyboxUp = "http://www.roblox.com/asset/?id=4495867486",
                StarCount = 3000,
                SunAngularSize = 1,
                SunTextureId = ""
            },
            ["Red Sky"] = {
                CelestialBodiesShown = false,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "rbxassetid://108929045660200",
                SkyboxDn = "rbxassetid://78646480540009",
                SkyboxFt = "rbxassetid://90546017435179",
                SkyboxLf = "rbxassetid://109838453114563",
                SkyboxRt = "rbxassetid://94190734796082",
                SkyboxUp = "rbxassetid://126944775797063",
                StarCount = 3000,
                SunAngularSize = 21,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Darkness Sky"] = {
                CelestialBodiesShown = false,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "rbxassetid://15470149279",
                SkyboxDn = "rbxassetid://15470151245",
                SkyboxFt = "rbxassetid://15470153860",
                SkyboxLf = "rbxassetid://15470155938",
                SkyboxRt = "rbxassetid://15470158022",
                SkyboxUp = "rbxassetid://15470160563",
                StarCount = 3000,
                SunAngularSize = 21,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Black-Blue Sky"] = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "",
                SkyboxBk = "rbxassetid://1233158420",
                SkyboxDn = "rbxassetid://1233158838",
                SkyboxFt = "rbxassetid://1233157105",
                SkyboxLf = "rbxassetid://1233157640",
                SkyboxRt = "rbxassetid://1233157995",
                SkyboxUp = "rbxassetid://1233159158",
                StarCount = 3000,
                SunAngularSize = 21,
                SunTextureId = ""
            },
            ["Crossroads Sky"] = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "http://www.roblox.com/asset/?version=1&id=1013852",
                SkyboxDn = "http://www.roblox.com/asset/?version=1&id=1013853",
                SkyboxFt = "http://www.roblox.com/asset/?version=1&id=1013850",
                SkyboxLf = "http://www.roblox.com/asset/?version=1&id=1013851",
                SkyboxRt = "http://www.roblox.com/asset/?version=1&id=1013849",
                SkyboxUp = "http://www.roblox.com/asset/?version=1&id=1013854",
                StarCount = 3000,
                SunAngularSize = 27,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Orange Sky"] = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "rbxasset://sky/moon.jpg",
                SkyboxBk = "http://www.roblox.com/asset/?id=150939022",
                SkyboxDn = "http://www.roblox.com/asset/?id=150939038",
                SkyboxFt = "http://www.roblox.com/asset/?id=150939047",
                SkyboxLf = "http://www.roblox.com/asset/?id=150939056",
                SkyboxRt = "http://www.roblox.com/asset/?id=150939063",
                SkyboxUp = "http://www.roblox.com/asset/?id=150939082",
                StarCount = 3000,
                SunAngularSize = 21,
                SunTextureId = "rbxasset://sky/sun.jpg"
            },
            ["Meme Sky"] = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "rbxassetid://6444320592",
                SkyboxBk = "rbxassetid://117003589797607",
                SkyboxDn = "rbxassetid://117003589797607",
                SkyboxFt = "rbxassetid://128526893232764",
                SkyboxLf = "rbxassetid://132330407505752",
                SkyboxRt = "rbxassetid://137981272047053",
                SkyboxUp = "rbxassetid://88459308213437",
                StarCount = 3000,
                SunAngularSize = 11,
                SunTextureId = "rbxassetid://6196665106"
            }
        }

    local preset = skyPresets[selectedSky]
    if not preset then return end

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end

    local newSky = Instance.new("Sky")
    newSky.Name = selectedSky
    newSky.CelestialBodiesShown = preset.CelestialBodiesShown
    newSky.MoonAngularSize = preset.MoonAngularSize
    newSky.MoonTextureId = preset.MoonTextureId
    newSky.SkyboxBk = preset.SkyboxBk
    newSky.SkyboxDn = preset.SkyboxDn
    newSky.SkyboxFt = preset.SkyboxFt
    newSky.SkyboxLf = preset.SkyboxLf
    newSky.SkyboxRt = preset.SkyboxRt
    newSky.SkyboxUp = preset.SkyboxUp
    newSky.StarCount = preset.StarCount
    newSky.SunAngularSize = preset.SunAngularSize
    newSky.SunTextureId = preset.SunTextureId
    newSky.Parent = Lighting
end,
}, "SkyboxDropdown1")

-- Инициализируем начальное значение (по умолчанию для слайдера поставим 0.65, как в примере)
getgenv().Resolution = {
    [".gg/scripters"] = 1
}

local Camera = workspace.CurrentCamera

-- Запускаем цикл рендера, если он еще не был запущен
if getgenv().gg_scripters == nil then
    game:GetService("RunService").RenderStepped:Connect(
        function()
            -- Скрипт постоянно берет актуальное значение из getgenv().Resolution[".gg/scripters"]
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end
    )
end
getgenv().gg_scripters = "Aori0001"

-- Конструктор слайдера для твоего UI-либы
sections.MainSection4:Slider({
	Name = "Aspect ratio",
	Default = 1,
	Minimum = 0.1,
	Maximum = 1,
	DisplayMethod = "Percent",
	Callback = function(Value)
		-- Обновляем значение в таблице при каждом движении слайдера
		getgenv().Resolution[".gg/scripters"] = Value
	end,
}, "AspectRatioSlider")

sections.MainSection4:Divider()

sections.MainSection4:Toggle({
	Name = "Dynamic island",
	Default = false,
	Callback = function(value)
		local MarketplaceService = game:GetService("MarketplaceService")
		local TweenService = game:GetService("TweenService")
		local Stats = game:GetService("Stats")
		local CoreGui = game:GetService("CoreGui")
		
		local guiName = "DynamicIsland_MaxTop"
		_G.DynamicIslandLoop = _G.DynamicIslandLoop or false

		if value then
			_G.DynamicIslandLoop = true
			
			-- 1. Получение названия плейса
			local success, placeInfo = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)
			local placeName = success and placeInfo.Name or "Unknown Place"

			-- 2. Корневой GUI
			local targetParent = (CoreGui:FindFirstChild("RobloxGui") or CoreGui)
			local oldGui = targetParent:FindFirstChild(guiName)
			if oldGui then oldGui:Destroy() end

			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = guiName
			ScreenGui.ResetOnSpawn = false
			ScreenGui.Parent = targetParent

			-- Главный контейнер
			local MainAnchor = Instance.new("Frame")
			MainAnchor.Name = "MainAnchor"
			MainAnchor.Size = UDim2.new(0, 0, 0, 30)
			MainAnchor.Position = UDim2.new(0.5, 0, 0, -50)
			MainAnchor.AnchorPoint = Vector2.new(0.5, 0)
			MainAnchor.BackgroundTransparency = 1
			MainAnchor.Parent = ScreenGui

			-- 3. Капсула Dynamic Island
			local Island = Instance.new("Frame")
			Island.Name = "Island"
			Island.ZIndex = 3
			Island.BackgroundColor3 = Color3.fromRGB(10, 22, 18)
			Island.BackgroundTransparency = 0.1
			Island.Parent = MainAnchor

			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 15)
			UICorner.Parent = Island

			local UIStroke = Instance.new("UIStroke")
			UIStroke.Color = Color3.fromRGB(25, 45, 38)
			UIStroke.Thickness = 1
			UIStroke.Transparency = 0.1
			UIStroke.Parent = Island

			-- Название плейса
			local PlaceLabel = Instance.new("TextLabel")
			PlaceLabel.Name = "PlaceLabel"
			PlaceLabel.Size = UDim2.new(1, 0, 1, 0)
			PlaceLabel.BackgroundTransparency = 1
			PlaceLabel.Text = placeName
			PlaceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			PlaceLabel.Font = Enum.Font.GothamMedium
			PlaceLabel.TextSize = 13
			PlaceLabel.TextTransparency = 1
			PlaceLabel.ZIndex = 4
			PlaceLabel.Parent = Island

			-- Расчет ширины под текст
			local textWidth = PlaceLabel.TextBounds.X
			local islandWidth = math.clamp(textWidth + 30, 95, 350)
			Island.Size = UDim2.new(0, islandWidth, 0, 30)
			Island.Position = UDim2.new(0.5, -islandWidth / 2, 0, 0)

			-- 4. Время (Жирный шрифт)
			local TimeLabel = Instance.new("TextLabel")
			TimeLabel.Name = "TimeLabel"
			TimeLabel.Size = UDim2.new(0, 45, 0, 30)
			TimeLabel.Position = UDim2.new(0.5, -15, 0, 0)
			TimeLabel.BackgroundTransparency = 1
			TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TimeLabel.Font = Enum.Font.GothamBold
			TimeLabel.TextSize = 15
			TimeLabel.TextTransparency = 1
			TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
			TimeLabel.ZIndex = 1
			
			-- КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Записываем время СРАЗУ при создании объекта
			local initialDate = os.date("*t")
			TimeLabel.Text = string.format("%02d:%02d", initialDate.hour, initialDate.min)
			TimeLabel.Parent = MainAnchor

			-- 5. Иконка сети
			local NetworkFrame = Instance.new("Frame")
			NetworkFrame.Name = "NetworkFrame"
			NetworkFrame.Size = UDim2.new(0, 18, 0, 12)
			NetworkFrame.Position = UDim2.new(0.5, -5, 0, 9)
			NetworkFrame.BackgroundTransparency = 1
			NetworkFrame.ZIndex = 1
			NetworkFrame.Parent = MainAnchor

			local NetLayout = Instance.new("UIListLayout")
			NetLayout.FillDirection = Enum.FillDirection.Horizontal
			NetLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			NetLayout.Padding = UDim.new(0, 2)
			NetLayout.Parent = NetworkFrame

			local bars = {}
			local barHeights = {4, 6, 9, 12}
			for i = 1, 4 do
				local bar = Instance.new("Frame")
				bar.Name = "Bar" .. i
				bar.Size = UDim2.new(0, 3, 0, barHeights[i])
				bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				bar.BackgroundTransparency = 1
				bar.BorderSizePixel = 0
				Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 1)
				bar.Parent = NetworkFrame
				table.insert(bars, bar)
			end

			-- 6. ТАЙМЛАЙН АНИМАЦИЙ
			local tweenDrop = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local tweenSlide = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			-- Выезд всей конструкции сверху вниз
			TweenService:Create(MainAnchor, tweenDrop, {Position = UDim2.new(0.5, 0, 0, 12)}):Play()
			task.wait(0.25)

			-- Проявление текста плейса
			TweenService:Create(PlaceLabel, tweenSlide, {TextTransparency = 0}):Play()

			-- Выдвижение времени и пинга (уже с готовым текстом внутри)
			local finalTimePos = UDim2.new(0.5, -(islandWidth / 2) - 45 - 8, 0, 0)
			local finalNetPos = UDim2.new(0.5, (islandWidth / 2) + 8, 0, 9)

			TweenService:Create(TimeLabel, tweenSlide, {Position = finalTimePos, TextTransparency = 0}):Play()
			TweenService:Create(NetworkFrame, tweenSlide, {Position = finalNetPos}):Play()
			
			for _, bar in ipairs(bars) do
				TweenService:Create(bar, tweenSlide, {BackgroundTransparency = 0}):Play()
			end

-- 7. Цикл последующих обновлений (ПОЛНОСТЬЮ НАДЁЖНЫЙ)
            task.spawn(function()
                local Players = game:GetService("Players")
                local localPlayer = Players.LocalPlayer
                
                while _G.DynamicIslandLoop and task.wait(0.5) do
                    if not ScreenGui or not ScreenGui.Parent then break end
                    
                    -- 1. Обновление времени
                    local date = os.date("*t")
                    TimeLabel.Text = string.format("%02d:%02d", date.hour, date.min)

                    -- 2. Нормальное получение пинга без Stats
                    local ping = 0
                    if localPlayer then
                        -- Умножаем на 1000, так как GetNetworkPing() возвращает значение в секундах (например, 0.113)
                        ping = math.round(localPlayer:GetNetworkPing() * 1000)
                    end
                    
                    -- Если пинг не определился или равен 0, поставим средний, чтобы не пугать красной полосой
                    if ping <= 0 then ping = 60 end 

                    -- 3. Логика палочек (4 — идеальный, 1 — лагает)
                    for idx, bar in ipairs(bars) do
                        if ping > 200 then
                            -- Ужасный пинг: 1 красная палочка
                            bar.BackgroundTransparency = (idx <= 1) and 0 or 0.6
                            bar.BackgroundColor3 = Color3.fromRGB(240, 80, 80)
                        elseif ping > 110 then
                            -- Средний пинг (твои 113 мс попадут сюда): 2 палочки желтые
                            bar.BackgroundTransparency = (idx <= 2) and 0 or 0.6
                            bar.BackgroundColor3 = Color3.fromRGB(240, 200, 80)
                        elseif ping > 60 then
                            -- Хороший пинг: 3 палочки белые
                            bar.BackgroundTransparency = (idx <= 3) and 0 or 0.6
                            bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            -- Идеальный пинг: все 4 палочки белые/зеленые
                            bar.BackgroundTransparency = 0
                            bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end)

		else
			-- Деактивация
			_G.DynamicIslandLoop = false
			local targetParent = (CoreGui:FindFirstChild("RobloxGui") or CoreGui)
			local activeGui = targetParent:FindFirstChild(guiName)
			
			if activeGui and activeGui:FindFirstChild("MainAnchor") then
				local MainAnchor = activeGui.MainAnchor
				local tweenHide = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

				if MainAnchor:FindFirstChild("Island") then
					TweenService:Create(MainAnchor.Island.PlaceLabel, tweenHide, {TextTransparency = 1}):Play()
				end
				if MainAnchor:FindFirstChild("TimeLabel") then
					TweenService:Create(MainAnchor.TimeLabel, tweenHide, {Position = UDim2.new(0.5, -15, 0, 0), TextTransparency = 1}):Play()
				end
				if MainAnchor:FindFirstChild("NetworkFrame") then
					TweenService:Create(MainAnchor.NetworkFrame, tweenHide, {Position = UDim2.new(0.5, -5, 0, 9)}):Play()
					for _, bar in ipairs(MainAnchor.NetworkFrame:GetChildren()) do
						if bar:IsA("Frame") then TweenService:Create(bar, tweenHide, {BackgroundTransparency = 1}):Play() end
					end
				end

				task.wait(0.15)

				local liftUp = TweenService:Create(MainAnchor, tweenHide, {Position = UDim2.new(0.5, 0, 0, -50)})
				liftUp:Play()
				liftUp.Completed:Connect(function()
					activeGui:Destroy()
				end)
			end
		end
	end,
}, "FlightToggle")

tabs.Settings:InsertConfigSection("Left")
tabs.Main:Select()
MacLib:LoadAutoLoadConfig()