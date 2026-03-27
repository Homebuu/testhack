local targetParent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not game:IsLoaded() then
    game.Loaded:Wait() 
end
task.wait(math.random(10, 15)) 

-- [[ Services & Variables ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = WindUI:CreateWindow({
	Title = "Homebuu Hub X1",
	Author = "by homebuu",
	Icon = "palette",
	Parent = targetParent,
	Folder = "HomebuuConfigs",
	NewElements = true,
	Theme = "Dark",
	Size = UDim2.fromOffset(550, 450),
	Acrylic = false,
	HideSearchBar = true,
	SideBarWidth = 180,
	ThemeSwitch = false,
	OpenButton = {
		Title = "Open Menu",
		CornerRadius = UDim.new(1, 0), 
		StrokeThickness = 3,
		Enabled = true, 
		Draggable = true, 
		OnlyMobile = true, 
		Color = ColorSequence.new(Color3.fromHex("#FF3030"), Color3.fromHex("#FF8C00")),
	},
	User = {
		Enabled = true,
		Anonymous = false,
	},
})

Window:SetToggleKey(Enum.KeyCode.LeftControl)
Window:Tag({
    Title = "v1.0.1",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 10, 
})

Window:SetBackgroundTransparency(0.1)
Window:SetToggleKey(Enum.KeyCode.LeftControl) 
-----------------------------------------------------

local WALK_SPEED = 100
local JUMP_POWER = 50
local speedEnabled = true
local jumpEnabled = false
local flyEnabled = false
local selectedPlayer = "" -- ตัวแปรเก็บชื่อผู้เล่นที่เลือก (เริ่มต้นเป็นว่างเปล่า)
local highlight = nil
local flingEnabled = false
local orbitAngle = 0

-- [[ ESP Variables ]] --
local espSettings = {
    Names = false,
    Distances = false,
    Boxes = false,
    Lines = false,
    Color = Color3.fromRGB(255, 255, 255),
}

local espStorage = {
    Tags = {},
    Boxes = {},
    Lines = {},
}

local randomName = "Internal_" .. math.random(100000, 999999)
local espFolder = Instance.new("Folder")
espFolder.Name = randomName
espFolder.Parent = player:WaitForChild("PlayerGui")

-- [[ ESP Functions ]] --
local function createDrawing(class, properties)
    local drawing = Drawing.new(class)
    for i, v in pairs(properties) do
        drawing[i] = v
    end
    return drawing
end

local function handlePlayerESP(v)
    if v == player then return end

    local function addESP()
		if not espStorage.Tags[v.Name] then
            local billboard = Instance.new("BillboardGui", espFolder)
            billboard.Name = v.Name .. "_Tag"
            billboard.Size = UDim2.new(0, 150, 0, 70) 
            billboard.StudsOffset = Vector3.new(0, 3.5, 0) 
            billboard.AlwaysOnTop = true
            billboard.Enabled = false

            local label = Instance.new("TextLabel", billboard)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextColor3 = espSettings.Color
            label.TextStrokeTransparency = 0
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            
            label.Text = v.DisplayName .. "\n(@" .. v.Name .. ")"
            
            label.TextYAlignment = Enum.TextYAlignment.Top 
            espStorage.Tags[v.Name] = {Billboard = billboard, Label = label}
        end

        if not espStorage.Boxes[v.Name] then
            espStorage.Boxes[v.Name] = createDrawing("Square", {
                Color = espSettings.Color,
                Thickness = 1,
                Filled = false,
                Transparency = 1,
                Visible = false,
            })
        end

        if not espStorage.Lines[v.Name] then
            espStorage.Lines[v.Name] = createDrawing("Line", {
                Color = espSettings.Color,
                Thickness = 1,
                Transparency = 1,
                Visible = false,
            })
        end
    end

    if v.Character then addESP() end
    v.CharacterAdded:Connect(addESP)
end

-- [[ RunService Loop ]] --
RunService.RenderStepped:Connect(function()
	if not (espSettings.Names or espSettings.Boxes or espSettings.Lines) then 
        return 
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v == player then continue end
        local char = v.Character
        local tagData = espStorage.Tags[v.Name]
        local box = espStorage.Boxes[v.Name]
        local line = espStorage.Lines[v.Name]

        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local rootPart = char.HumanoidRootPart
            local head = char.Head
            local hrpPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 0

            -- Update Names
            if tagData then
                if espSettings.Names and onScreen then
                    tagData.Billboard.Adornee = rootPart
                    tagData.Billboard.Enabled = true
                    tagData.Label.Text = v.DisplayName .. " (" .. math.floor(distance) .. "m)\n(@" .. v.Name .. ")"
                else
                    tagData.Billboard.Enabled = false
                end
            end

            -- Update Boxes
            if box then
                if espSettings.Boxes and onScreen then
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                    box.Visible = true
                else
                    box.Visible = false
                end
            end

            -- Update Lines
            if line then
                if espSettings.Lines and onScreen then
                    local screenCenterBottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    
                    line.From = screenCenterBottom
                    line.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    line.Color = espSettings.Color 
                    line.Visible = true
                else
                    line.Visible = false 
                end
            end
        else
            if tagData then tagData.Billboard.Enabled = false end
            if box then box.Visible = false end
            if line then line.Visible = false end
        end
    end
end)

-- [[ Functions ]] --
local function getPlayerList()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player then table.insert(list, v.Name) end
    end
    return list
end

-- Fly Smooth System
local flyConnection, bv, bg
local function toggleFly(state)
    flyEnabled = state
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char.Humanoid

    if flyEnabled then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.P = 10000
        hum.PlatformStand = true
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)

            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            
            if moveDir.Magnitude == 0 then
                local joystickDir = hum.MoveDirection
                if joystickDir.Magnitude > 0 then
                    moveDir = (cam.CFrame.LookVector * joystickDir.Z) + (cam.CFrame.RightVector * joystickDir.X)
                end
            end

            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            bv.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * WALK_SPEED or Vector3.zero
            bg.CFrame = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        hum.PlatformStand = false
        task.wait(0.1)
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- [[ Tabs Setup ]] --
local MainTab = Window:Tab({ Title = "เมนูหลัก", Icon = "star" })
local TeleportTab = Window:Tab({ Title = "เทเลพอร์ต", Icon = "navigation" })
local PlayerVisible = Window:Tab({ Title = "การมองเห็น", Icon = "eye" }) 
local FlingLuck = Window:Tab({ Title = "ฟังก์ชั่นเถื่อน", Icon = "geist:warning" }) 

local discordBTN = Window:Tab({ Title = "Discord Server", Icon = "geist:discord" }) 

-- --- [ เมนูหลัก ] --- --
MainTab:Section({ Title = "Movement / การเคลื่อนที่" })
MainTab:Toggle({
    Title = "เปิด/ปิด วิ่งเร็ว",
    Value = false,
    Callback = function(state)
        speedEnabled = state
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = state and WALK_SPEED or 16
        end
    end
})

MainTab:Slider({
    Title = "ความเร็ว (Speed/Fly)",
    Step = 1,
    Value = {Min = 16, Max = 500, Default = 16},
    Callback = function(v) 
        WALK_SPEED = v 
        if speedEnabled and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

MainTab:Toggle({
    Title = "เปิด/ปิด กระโดดสูง",
    Value = false,
    Callback = function(state)
        jumpEnabled = state
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = state
            player.Character.Humanoid.JumpPower = state and JUMP_POWER or 50
        end
    end
})

MainTab:Slider({
    Title = "แรงกระโดด (Jump)",
    Step = 1,
    Value = {Min = 50, Max = 500, Default = 50},
    Callback = function(v) 
        JUMP_POWER = v 
        if jumpEnabled and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

MainTab:Toggle({
    Title = "บินทะลุกำแพง (Smooth Fly)",
    Value = false,
    Callback = function(state) toggleFly(state) end
})

-- --- [ เทเลพอร์ต ] --- --
TeleportTab:Section({ Title = "Player Teleport" })

-- Dropdown เลือกผู้เล่น
local pDropdown = TeleportTab:Dropdown({
    Title = "เลือกผู้เล่น",
    Desc = "ดึงรายชื่อผู้เล่นทั้งหมดในเซิร์ฟเวอร์",
    Multi = false,
    Values = getPlayerList(),
    Callback = function(name)
        selectedPlayer = name 
        local target = Players:FindFirstChild(name)
        if target and target.Character then end
    end
})

TeleportTab:Button({
    Title = "อัปเดตรายชื่อ (Refresh)",
    Desc = "กดเมื่อมีคนเข้าหรือออกจากเซิร์ฟเวอร์",
    Callback = function()
        pDropdown:SetValues(getPlayerList())
    end
})

TeleportTab:Button({
    Title = "วาร์ปไปหาผู้เล่นที่เลือก",
    Desc = "คุณต้องเลือกชื่อจาก Dropdown ก่อนกด",
    Callback = function()
        if selectedPlayer == "" or selectedPlayer == nil then
            WindUI:Notify({
                Title = "Error!",
                Content = "คุณยังไม่ได้เลือกชื่อผู้เล่นที่จะวาร์ป!",
                Duration = 4,
                Type = "Error"
            })
            return 
        end

        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        else
            WindUI:Notify({
                Title = "Error!",
                Content = "ไม่สามารถหาตัวละครของผู้เล่นคนนี้ได้",
                Duration = 4,
                Type = "Error"
            })
        end
    end
})

TeleportTab:Button({
    Title = "ส่องดูผู้เล่น (Spectate)",
    Desc = "เปลี่ยนมุมกล้องไปที่ผู้เล่นที่เลือก",
    Callback = function()
        if selectedPlayer == "" or selectedPlayer == nil then
            WindUI:Notify({
                Title = "Error!",
                Content = "กรุณาเลือกชื่อผู้เล่นก่อน!",
                Duration = 4,
                Type = "Error"
            })
            return
        end

        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
            WindUI:Notify({
                Title = "Spectating",
                Content = "กำลังดู: " .. selectedPlayer,
                Duration = 3,
                Type = "Success"
            })
        else
            WindUI:Notify({
                Title = "Error!",
                Content = "ไม่สามารถส่องได้ (ผู้เล่นอาจตายหรือไม่มีตัวละคร)",
                Duration = 4,
                Type = "Error"
            })
        end
    end
})

TeleportTab:Button({
    Title = "ยกเลิกการส่อง (Stop Spectate)",
    Desc = "กลับมามองที่ตัวละครตัวเอง",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = char.Humanoid
            WindUI:Notify({
                Title = "Spectate Stopped",
                Content = "กลับมาที่ตัวละครของคุณแล้ว",
                Duration = 3,
                Type = "Info"
            })
        end
    end
})

PlayerVisible:Section({ Title = "Player Visuals" })
PlayerVisible:Toggle({
    Title = "เปิด/ปิด แสดงชื่อ (ESP Name)",
    Value = false,
    Callback = function(state) 
		espSettings.Names = state 
		if state then
            for _, p in pairs(Players:GetPlayers()) do 
                handlePlayerESP(p) 
            end
        end
	end
})
PlayerVisible:Toggle({
    Title = "เปิด/ปิด กรอบ (ESP Box)",
    Value = false,
    Callback = function(state) espSettings.Boxes = state end
})
PlayerVisible:Toggle({
    Title = "เปิด/ปิด เส้นลาก (ESP Line)",
    Value = false,
    Callback = function(state) espSettings.Lines = state end
})
PlayerVisible:Colorpicker({
    Title = "สีของ ESP",
    Default = espSettings.Color,
    Callback = function(color)
        espSettings.Color = color
        for _, tag in pairs(espStorage.Tags) do tag.Label.TextColor3 = color end
        for _, box in pairs(espStorage.Boxes) do box.Color = color end
        for _, line in pairs(espStorage.Lines) do line.Color = color end
    end
})


-- [[ ฟังก์ชั่นเถื่อน ]] --
FlingLuck:Section({ Title = "เถื่อน (แนะนำอย่าเปิด มีผลกับไอดีตัวเอง)" })
FlingLuck:Toggle({
    Title = "Fling Player",
    Desc = "เตะผู้เล่นออกจากแมพ > เลือกจากเมณูค้นหา Teleport",
    Value = false,
    Callback = function(state)
        flingEnabled = state
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if flingEnabled then
            if selectedPlayer == "" or selectedPlayer == nil then
                WindUI:Notify({
                    Title = "Error!",
                    Content = "กรุณาเลือกผู้เล่นก่อน!",
                    Duration = 4,
                    Type = "Error"
                })
                return
            end

            local target = Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                
                local originalCFrame = hrp.CFrame
                
                task.spawn(function()
                    WindUI:Notify({
                        Title = "Flinging...",
                        Content = "กำลังส่ง " .. selectedPlayer .. " ไปนอกโลก",
                        Duration = 3,
                        Type = "Warning"
                    })

                    while flingEnabled and char and hrp and target and target.Character do
                        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if not targetHrp then break end
                        
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end

                        hrp.Velocity = Vector3.new(0, 3000, 0)
                        hrp.RotVelocity = Vector3.new(3000, 3000, 3000) 

                        local jitter = Vector3.new(math.random(-1,1)/100, 0, math.random(-1,1)/100)
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, -1.5, 0) * CFrame.new(jitter)
                        
                        task.wait() 
                    end
                    
                    if hrp then
                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        hrp.CFrame = originalCFrame
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = true end
                        end
                    end
                end)
            else
                WindUI:Notify({
                    Title = "Error!",
                    Content = "ไม่พบตัวละครเป้าหมาย",
                    Duration = 4,
                    Type = "Error"
                })
            end
        end
    end
})


discordBTN:Button({
    Title = "เข้าร่วม Discord",
    Desc = "กดเพื่อดูลิงก์เชิญเข้าร่วมกลุ่ม",
    Callback = function()
        WindUI:Popup({
            Title = "Discord Invitation",
            Icon = "message-square", -- ไอคอนข้อความ
            Content = "คุณต้องการคัดลอกลิงก์ Discord ไปยัง Clipboard หรือไม่?",
            Buttons = {
                {
                    Title = "ยกเลิก",
                    Callback = function() 
                        print("User cancelled") 
                    end,
                    Variant = "Tertiary", 
                },
                {
                    Title = "คัดลอกลิงก์",
                    Icon = "copy",
                    Variant = "Primary",
                    Callback = function()
                        setclipboard("https://discord.gg/B8RGAP6bKa")
                        
                        WindUI:Notify({
                            Title = "Success!",
                            Content = "คัดลอกลิงก์แล้ว! นำไปวางใน Browser ได้เลย",
                            Type = "Success"
                        })
                    end,
                }
            }
        })
    end
})

-- [[ Notification & Start ]] --
WindUI:Notify({
    Title = "HG HUB V1",
    Content = "โปรดใช้ด้วยความระมัดระวัง บางฟังก์ชั่นอาจจะมีการแบนได้!",
    Duration = 10, -- 3 seconds
    Icon = "bird",
})
