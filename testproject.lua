local targetParent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not game:IsLoaded() then
    game.Loaded:Wait() 
end
task.wait(math.random(5, 10)) 

-- [[ Services & Variables ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = WindUI:CreateWindow({
	Title = "KH Hub X1",
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
		Title = "Homebuu V1",
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
		Callback = function() Window.User:SetAnonymous(true) end,
	},
	KeySystem = { 
        Key = { "HomebuuKuy56", "HomebuuKuy54", "Home56" },
        Note = "กรุณานำคีย์ที่ได้จากทางเรา มาใส่เพื่อรันสคริปต์. -> (https://discord.gg/AZ9tvMCmY7)",
        URL = "https://www.youtube.com/watch?v=euZX5k9pato&list=RDbo4KbfLar8c&index=9",
        SaveKey = true, -- automatically save and load the key.
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
local highlight = nil
local flingEnabled = false
local orbitAngle = 0
local selectedPlayer = nil
local playerData = {}

local flingAllEnabled = false
local pDropdown = nil

local lp = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral"):SendAsync("สวัสดี, มันเป็นแมพที่ดี <3")

if game.PlaceId == 142823291 then 
	local remote = rs
	    :FindFirstChild("Remotes")
	    and rs.Remotes:FindFirstChild("Gameplay")
	    and rs.Remotes.Gameplay:FindFirstChild("PlayerDataChanged")
end 

-- [[ ESP Variables ]] --
local espSettings = { Names = false, Boxes = false, Lines = false, Color = Color3.fromRGB(255, 255, 255) }
local espCache = {} -- ใช้ Table เดียวเก็บข้อมูลเพื่อความลื่น

-- [[ ESP Functions ]] --
local function createESP(v)
    if v == player or espCache[v] then return end
    
    local data = {}
    
    data.Box = Drawing.new("Square")
    data.Box.Thickness = 1
    data.Box.Filled = false
    
    data.Line = Drawing.new("Line")
    data.Line.Thickness = 1
    
    data.Name = Drawing.new("Text")
    data.Name.Size = 14
    data.Name.Center = true
    data.Name.Outline = true

    espCache[v] = data
end

-- [[ RunService Loop ]] --
RunService.Heartbeat:Connect(function()
    for v, drawings in pairs(espCache) do
        local char = v.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0
                
                -- Box & Name Logic
                if espSettings.Boxes or espSettings.Names then
                    local head = char:FindFirstChild("Head")
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    if espSettings.Boxes then
                        drawings.Box.Visible = true
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                        drawings.Box.Color = espSettings.Color
                    else drawings.Box.Visible = false end

                    if espSettings.Names then
                        drawings.Name.Visible = true
                        drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                        drawings.Name.Text = string.format("%s [%dm]\n\n@%s", v.DisplayName, math.floor(distance), v.Name)
                        drawings.Name.Color = espSettings.Color
                    else drawings.Name.Visible = false end
                end

                -- Line Logic (แก้ไขบัคเส้นค้าง)
                if espSettings.Lines then
                    drawings.Line.Visible = true
                    drawings.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(pos.X, pos.Y)
                    drawings.Line.Color = espSettings.Color
                else drawings.Line.Visible = false end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Line.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.Line.Visible = false
        end
    end
end)

-- [[ Anti-Ban Movement ]] --
-- การปรับ WalkSpeed ตรงๆ มักโดน AC แบน แนะนำให้ใช้การเปลี่ยนผ่านค่อยเป็นค่อยไปหรือจำกัดความเร็ว
local function updateMovement()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then
        -- ใช้ความเร็วที่ไม่สูงเกินไป (แนะนำไม่เกิน 100 สำหรับเซิร์ฟเวอร์ที่มี AC)
        hum.WalkSpeed = _G.SpeedEnabled and _G.WalkSpeed or 16
    end
end

-- เพิ่มระบบจัดการผู้เล่นเข้า-ออก
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(v)
    if espCache[v] then
        for _, d in pairs(espCache[v]) do d:Remove() end
        espCache[v] = nil
    end
end)
for _, v in pairs(Players:GetPlayers()) do createESP(v) end

-- [[ Functions ]] --
local function getPlayerList()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Players.LocalPlayer then
            table.insert(list, v.Name)
        end
    end
    return list
end

local function rebuildDropdown()
    if pDropdown then
        pDropdown:Refresh(getPlayerList())
        if selectedPlayer and not table.find(getPlayerList(), selectedPlayer) then
            selectedPlayer = nil
        end
    end
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
local MainTab = Window:Tab({ Title = "เมนูหลัก", Icon = "star" , Opened = true})
local TeleportTab = Window:Tab({ Title = "เทเลพอร์ต", Icon = "navigation" })
local PlayerVisible = Window:Tab({ Title = "การมองเห็น", Icon = "eye" }) 
local FlingLuck = Window:Tab({ Title = "ฟังก์ชั่นเถื่อน", Icon = "geist:warning" }) 

local murderermystery2 = Window:Tab({ Title = "MM2", Icon = "geist:slash-forward" }) 

local discordBTN = Window:Tab({ Title = "Discord Server", Icon = "geist:discord" }) 

-- --- [ เมนูหลัก ] --- --
MainTab:Toggle({
    Title = "เปิด/ปิด วิ่งเร็ว",
    Value = false,
    Callback = function(state)
        _G.SpeedEnabled = state 
		updateMovement()
     --   if player.Character and player.Character:FindFirstChild("Humanoid") then
       --     player.Character.Humanoid.WalkSpeed = state and WALK_SPEED or 16
     --   end
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
local pDropdown = TeleportTab:Dropdown({
    Title = "เลือกผู้เล่น",
    Desc = "ดึงรายชื่อผู้เล่นทั้งหมดในเซิร์ฟเวอร์",
    Multi = false,
    Values = getPlayerList(),
    Callback = function(name)
        selectedPlayer = name 
    end
})

TeleportTab:Button({
    Title = "อัปเดตรายชื่อ (Refresh)",
    Desc = "กดเมื่อมีคนเข้าหรือออกจากเซิร์ฟเวอร์",
    Callback = function()
        pDropdown:Refresh(getPlayerList())
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
Players.PlayerAdded:Connect(function()
    task.wait(1)
    rebuildDropdown()
end)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    task.wait(0.1)
    if selectedPlayer == leavingPlayer.Name then
        selectedPlayer = nil
    end
    rebuildDropdown()
end)

-- [[ ESP ]] --
PlayerVisible:Toggle({
    Title = "เปิด/ปิด แสดงชื่อ (ESP Name)",
    Value = false,
    Callback = function(state) 
		espSettings.Names = state 
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
        for _, drawings in pairs(espCache) do
            if drawings.Box then drawings.Box.Color = color end
            if drawings.Name then drawings.Name.Color = color end
            if drawings.Line then drawings.Line.Color = color end
        end
    end
})

-- [[ ฟังก์ชั่นเถื่อน ]] --
FlingLuck:Toggle({
    Title = "Anti-Fling",
    Desc = "คนอื่นจะทะลุตัวคุณ ไม่สามารถ Fling คุณได้",
    Value = false,
    Callback = function(state)
        _G.AntiFling = state
        local lp = game.Players.LocalPlayer
        local runService = game:GetService("RunService")
        
        if state then
            _G.AntiFlingConnection = runService.Stepped:Connect(function()
                if not _G.AntiFling then 
                    if _G.AntiFlingConnection then 
                        _G.AntiFlingConnection:Disconnect() 
                    end 
                    return 
                end
                
                local char = lp.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
            task.spawn(function()
                while _G.AntiFling do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp.Velocity.Magnitude > 75 then
                            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                            hrp.RotVelocity = Vector3.zero
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if _G.AntiFlingConnection then
                _G.AntiFlingConnection:Disconnect()
                _G.AntiFlingConnection = nil
            end
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

FlingLuck:Toggle({
    Title = "Fling Player",
    Desc = "เตะผู้เล่นออกจากแมพ > เลือกจากเมณูค้นหา Teleport",
    Value = false,
    Callback = function(state)
        flingEnabled = state
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if flingEnabled then
            if selectedPlayer == "" or selectedPlayer == nil then
                WindUI:Notify({Title = "Error!", Content = "กรุณาเลือกผู้เล่นก่อน!", Type = "Error"})
                return
            end

            local target = game.Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local originalCFrame = hrp.CFrame
					
                -- [[ ส่วนหนึ่งของลูปในฟังก์ชัน Fling ]] --
				task.spawn(function()
				    local angle = 0 
				    while flingEnabled and char and hrp and target and target.Character do
				        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
				        if not targetHrp then break end
				
				        if targetHrp.AssemblyLinearVelocity.Magnitude > 300 then 
				            break 
				        end
				        
				 --       for _, part in pairs(char:GetDescendants()) do
				     --       if part:IsA("BasePart") then part.CanCollide = false end
				 --       end
				
				        hrp.Velocity = Vector3.new(0, 25000, 0) 
					 	hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
				
				        angle = angle + 0.8  -- ปรับความเร็วการหมุนที่นี่
				        local radius = 0.8   -- ระยะห่าง (ยิ่งน้อยยิ่งชิดและแรง)
				        local offset = Vector3.new(math.cos(angle) * radius, -1.2, math.sin(angle) * radius)
				        
				        hrp.CFrame = targetHrp.CFrame * CFrame.new(offset)
				        
				        task.wait() 
				    end
				    
				    if hrp then
				        hrp.Velocity = Vector3.zero
				        hrp.RotVelocity = Vector3.zero
				        hrp.CFrame = originalCFrame -- คืนตำแหน่งเดิม
				  --      for _, part in pairs(char:GetDescendants()) do
				     --       if part:IsA("BasePart") then part.CanCollide = true end
				   --     end
				    end
				end)
            end
        end
    end
})

FlingLuck:Toggle({
    Title = "Safe Aim-Bot",
    Desc = "ล็อคเป้าหมาย มีโอกาศแบนสูง",
    Default = false,
    Callback = function(state)
        getgenv().AimbotEnabled = state
        
        if state and not getgenv().AimbotInitialized then
            getgenv().AimbotInitialized = true
            getgenv().FOV = 150
            
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = Players.LocalPlayer

            local fovCircle = Drawing.new("Circle")
            fovCircle.Color = Color3.new(1, 1, 1)
            fovCircle.Thickness = 1
            fovCircle.NumSides = 100
            fovCircle.Radius = getgenv().FOV
            fovCircle.Visible = false
            fovCircle.Transparency = 1

            local tracer = Drawing.new("Line")
            tracer.Color = Color3.fromRGB(255, 0, 0)
            tracer.Thickness = 2
            tracer.Visible = false

            -- ฟังก์ชันหาเป้าหมาย (ถ้าอยากให้ทะลุกำแพง ไม่ต้องใส่ Raycast)
            local function getClosest()
                local closest = nil
                local shortest = getgenv().FOV
                local center = Camera.ViewportSize / 2
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        -- ตรวจสอบว่ายังมีชีวิตอยู่
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local hrp = p.Character.HumanoidRootPart
                            local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                            if on then
                                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                if d < shortest then
                                    shortest = d
                                    closest = hrp
                                end
                            end
                        end
                    end
                end
                return closest
            end

            RunService.RenderStepped:Connect(function()
                if getgenv().AimbotEnabled then
                    fovCircle.Position = Camera.ViewportSize / 2
                    fovCircle.Radius = getgenv().FOV
                    fovCircle.Visible = true
                    
                    local hrp = getClosest()
                    if hrp then
                        local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                        if on then
                            tracer.From = Camera.ViewportSize / 2
                            tracer.To = Vector2.new(pos.X, pos.Y)
                            tracer.Visible = true
                            getgenv().TargetPosition = hrp.CFrame 
                            return
                        end
                    end
                else
                    fovCircle.Visible = false
                end
                tracer.Visible = false
                getgenv().TargetPosition = nil
            end)

            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)

            mt.__namecall = newcclosure(function(...)
                local m = getnamecallmethod()
                local a = {...}
                
                if getgenv().AimbotEnabled and getgenv().TargetPosition then
                    if m == "FireServer" or m == "InvokeServer" then
                        for i, v in pairs(a) do
                            if typeof(v) == "Vector3" then
                                a[i] = getgenv().TargetPosition.Position
                            elseif typeof(v) == "CFrame" then
                                a[i] = getgenv().TargetPosition
                            end
                        end
                        return old(unpack(a))
                    end
                end
                return old(unpack(a))
            end)
            setreadonly(mt, true)
        end
    end
})

local runService = game:GetService("RunService")
local cam = workspace.CurrentCamera

local ghostChar = nil 
local ghostConnection = nil
local originalCFrame = nil

local function cleanUpGhost()
    if ghostConnection then ghostConnection:Disconnect(); ghostConnection = nil end
    if ghostChar then
        ghostChar:Destroy()
        ghostChar = nil
    end
end

FlingLuck:Toggle({
    Title = "Ghost Mode V1",
    Desc = "of god of year of regenzy",
    Value = false,
    Callback = function(state)
        _G.AstralMode = state
        local char = lp.Character
        
        if state then
            if char and char:FindFirstChild("HumanoidRootPart") then
                originalCFrame = char.HumanoidRootPart.CFrame
                char.Archivable = true
                
                -- 1. สร้างร่างแยก
                ghostChar = char:Clone()
                ghostChar.Name = "Ghost_Spirit"
                ghostChar.Parent = workspace
                
                -- [[ แก้ปัญหาร่างแข็ง & กล่องขาว ]] --
                local ghostHum = ghostChar:FindFirstChildOfClass("Humanoid")
                local realHum = char:FindFirstChildOfClass("Humanoid")
                
                for _, obj in pairs(ghostChar:GetDescendants()) do
                    -- ลบกล่องขาวๆ และพวก Mesh ที่แสดงผลผิดปกติ
                    if obj:IsA("SelectionBox") or obj:IsA("BoxHandleAdornment") then
                        obj:Destroy()
                    end
                    
                    -- ลบ Script ออกให้หมด
                    if obj:IsA("LocalScript") or obj:IsA("Script") then 
                        obj:Destroy() 
                    end
                    
                    -- ทำให้ "หายตัว" (ทั้งตัวละครและเครื่องประดับ)
                    if obj:IsA("BasePart") or obj:IsA("Decal") then
                        obj.Transparency = 0.5
                        obj.CanCollide = true -- ให้ชนกำแพงได้ปกติ
                    end
                end

                -- 2. ย้ายมุมกล้อง
                cam.CameraSubject = ghostHum

                -- 3. ระบบ Sync แบบ Real-time (ไม่ให้แข็ง)
                ghostConnection = runService.RenderStepped:Connect(function()
                    if _G.AstralMode and ghostChar and char then
                        -- บังคับร่างแยกเดิน (ลื่นๆ ไม่แข็ง)
                        ghostHum:Move(realHum.MoveDirection, false)
                        
                        -- Sync Animation (ทำให้ร่างแยกหายใจ/เดิน/ขยับท่าทางตามตัวจริง)
                        if realHum.ActiveAnimationLauncher then
                             -- ปกติ Roblox จะเล่น Anim ให้อัตโนมัติถ้า Humanoid ขยับ
                        end

                        -- หันหน้าตามกล้อง
                        ghostChar.HumanoidRootPart.CFrame = CFrame.new(ghostChar.HumanoidRootPart.Position) * CFrame.Angles(0, select(2, cam.CFrame:ToEulerAnglesYXZ()), 0)
                        
                        -- ล็อคร่างจริงไว้ที่จุดเกิด (ไม่ให้หายตัว)
                        char.HumanoidRootPart.CFrame = originalCFrame
                        char.HumanoidRootPart.Velocity = Vector3.zero
                        
                        -- Sync Tool & Action
                        local realTool = char:FindFirstChildOfClass("Tool")
                        if realTool then
                            if not ghostChar:FindFirstChild(realTool.Name) then
                                local cloneTool = realTool:Clone()
                                -- ลบกล่องขาวที่ติดมากับ Tool (ถ้ามี)
                                for _, part in pairs(cloneTool:GetDescendants()) do
                                    if part:IsA("BasePart") then part.Transparency = 0.5 end
                                end
                                cloneTool.Parent = ghostChar
                            end
                            -- ระบบกดยิง/ตี
                            if game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local t = ghostChar:FindFirstChild(realTool.Name)
                                if t then t:Activate() end
                            end
                        else
                            for _, t in pairs(ghostChar:GetChildren()) do
                                if t:IsA("Tool") then t:Destroy() end
                            end
                        end
                    end
                end)
            end
        else
            -- 4. สลับกลับร่างปกติ
            if ghostChar and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = ghostChar.HumanoidRootPart.CFrame
                cam.CameraSubject = char.Humanoid
            end
            cleanUpGhost()
            _G.AstralMode = false
        end
    end
})

discordBTN:Button({
    Title = "เข้าร่วม Discord",
    Desc = "กดเพื่อดูลิงก์เชิญเข้าร่วมกลุ่ม",
    Callback = function()
        WindUI:Popup({
            Title = "Discord Invitation",
            Icon = "message-square", 
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

-- [[ function ]] -- 
if remote then
    remote.OnClientEvent:Connect(function(data)
        playerData = data
        if _G.ShowRolesMM2 then
            updateHighlights() 
        end
    end)
end
local function getMM2Role(v)
    if playerData and playerData[v.Name] then
        local data = playerData[v.Name]
        
        local role = tostring(data.Role)
        
        if role == "Murderer" then
            return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
        elseif role == "Sheriff" then
            return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
        elseif role == "Hero" then
            return {Type = "Hero", Color = Color3.fromRGB(255, 255, 0)}
        end
        -- Innocent ไม่ต้องแสดง
    end

    if v.Backpack:FindFirstChild("Knife") then
        return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
    end
    if v.Backpack:FindFirstChild("Gun") then
        return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
    end

    local char = v.Character
    if char then
        if char:FindFirstChild("Knife") then
            return {Type = "Murderer", Color = Color3.fromRGB(255, 0, 0)}
        end
        if char:FindFirstChild("Gun") then
            return {Type = "Sheriff", Color = Color3.fromRGB(0, 150, 255)}
        end
    end
    return nil
end
local function updateHighlights()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then continue end
        local char = v.Character
        if char then
            local roleInfo = getMM2Role(v)
            local highlight = char:FindFirstChild("RoleHighlight")
            if _G.ShowRolesMM2 and roleInfo then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "RoleHighlight"
                end
                highlight.FillColor = roleInfo.Color
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Enabled = true
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

local function getMurderer()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local isMurd = false
            if _G.playerData and _G.playerData[v.Name] then
                if tostring(_G.playerData[v.Name].Role) == "Murderer" and not _G.playerData[v.Name].Dead then
                    isMurd = true
                end
            elseif v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                isMurd = true
            end
            if isMurd then return v.Character end
        end
    end
    return nil
end

-- [[ ส่วนของ Toggle ]] --
murderermystery2:Toggle({
    Title = "แสดงบทบาทของผู้เล่น (Chams)",
    Desc = "สแกนทุกคน (แดง=ฆาตกร, ฟ้า=มือปืน)",
    Value = false,
    Callback = function(state)
        _G.ShowRolesMM2 = state
        if not state then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("RoleHighlight") then
                    v.Character.RoleHighlight:Destroy()
                end
            end
        else
            task.spawn(function()
                while _G.ShowRolesMM2 do
                    updateHighlights()
                    task.wait(0.1)
                end
            end)
        end
    end
})

local gunDropHighlight = nil
local gunDropAddedConnection = nil
local gunDropRemovedConnection = nil
murderermystery2:Toggle({
    Title = "แสดงปืนที่ตกพื้น",
    Desc = "ไฮไลท์ปืนที่ถูกทิ้งไว้บนพื้น",
    Value = false,
    Callback = function(state)
        _G.ShowGunDrop = state

        local function createGunHighlight(obj)
            if gunDropHighlight then
                gunDropHighlight:Destroy()
                gunDropHighlight = nil
            end
            gunDropHighlight = Instance.new("Highlight")
            gunDropHighlight.Name = "GunDropHighlight"
            gunDropHighlight.FillColor = Color3.fromRGB(255, 255, 0)
            gunDropHighlight.FillTransparency = 0.3
            gunDropHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            gunDropHighlight.OutlineTransparency = 0
            gunDropHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            gunDropHighlight.Adornee = obj
            gunDropHighlight.Parent = game:GetService("CoreGui")
        end

        if not state then
            -- ปิด
            if gunDropAddedConnection then
                gunDropAddedConnection:Disconnect()
                gunDropAddedConnection = nil
            end
            if gunDropRemovedConnection then
                gunDropRemovedConnection:Disconnect()
                gunDropRemovedConnection = nil
            end
            if gunDropHighlight then
                gunDropHighlight:Destroy()
                gunDropHighlight = nil
            end
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" then
                    createGunHighlight(obj)
                    break
                end
            end

            gunDropAddedConnection = workspace.DescendantAdded:Connect(function(obj)
                if obj.Name == "GunDrop" and _G.ShowGunDrop then
                    createGunHighlight(obj)
                end
            end)

            gunDropRemovedConnection = workspace.DescendantRemoving:Connect(function(obj)
                if obj.Name == "GunDrop" and _G.ShowGunDrop then
                    if gunDropHighlight then
                        gunDropHighlight:Destroy()
                        gunDropHighlight = nil
                    end
                end
            end)
        end
    end
})
murderermystery2:Toggle({
    Title = "Fling Murderer",
    Desc = "วาร์ปไปสะบัดฆาตกรให้กระเด็น",
    Value = false,
    Callback = function(state)
        _G.AutoFlingMurderer = state
        
        local lp = game.Players.LocalPlayer
        
        if state then
            task.spawn(function()
                while _G.AutoFlingMurderer do
                    task.wait(0.5)
                    
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end

                    local targetPlayer = nil
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v == lp or not v.Character or not v.Character:FindFirstChild("HumanoidRootPart") then continue end
                        
                        local isMurd = false
                        if _G.playerData and _G.playerData[v.Name] then
                            if tostring(_G.playerData[v.Name].Role) == "Murderer" and not _G.playerData[v.Name].Dead then
                                isMurd = true
                            end
                        elseif v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                            isMurd = true
                        end

                        if isMurd then
                            targetPlayer = v
                            break
                        end
                    end

                    if targetPlayer then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        local originalCFrame = hrp.CFrame
                                                
                        local startTime = tick()
                        while _G.AutoFlingMurderer and targetHrp.Parent and (tick() - startTime < 3) do
                            task.wait()
                            
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end

                            hrp.Velocity = Vector3.new(0, 35000, 0)
                            hrp.RotVelocity = Vector3.new(20000, 20000, 20000)
									
                            local jitter = Vector3.new(math.random(-2,2)/100, 0, math.random(-2,2)/100)
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, -1.5, 0) * CFrame.new(jitter)

                            if targetHrp.AssemblyLinearVelocity.Magnitude > 200 then break end
                        end

                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        hrp.CFrame = originalCFrame
                        
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = true end
                        end
                        
                        task.wait(1.5)
                    end
                end
            end)
        end
    end
})
murderermystery2:Toggle({
    Title = "Fling Sheriff",
    Desc = "วาร์ปไปสะบัดนายอำเภอให้กระเด็น",
    Value = false,
    Callback = function(state)
        _G.AutoFlingMurderer = state
        
        local lp = game.Players.LocalPlayer
        
        if state then
            task.spawn(function()
                while _G.AutoFlingMurderer do
                    task.wait(0.5)
                    
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end

                    local targetPlayer = nil
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v == lp or not v.Character or not v.Character:FindFirstChild("HumanoidRootPart") then continue end
                        
                        local isMurd = false
                        if _G.playerData and _G.playerData[v.Name] then
                            if tostring(_G.playerData[v.Name].Role) == "Sheriff" and not _G.playerData[v.Name].Dead then
                                isMurd = true
                            end
                        elseif v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") then
                            isMurd = true
                        end

                        if isMurd then
                            targetPlayer = v
                            break
                        end
                    end

                    if targetPlayer then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        local originalCFrame = hrp.CFrame
                                                
                        local startTime = tick()
                        while _G.AutoFlingMurderer and targetHrp.Parent and (tick() - startTime < 3) do
                            task.wait()
                            
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end

                            hrp.Velocity = Vector3.new(0, 35000, 0)
                            hrp.RotVelocity = Vector3.new(20000, 20000, 20000)

                            local jitter = Vector3.new(math.random(-2,2)/100, 0, math.random(-2,2)/100)
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, -1.5, 0) * CFrame.new(jitter)

                            if targetHrp.AssemblyLinearVelocity.Magnitude > 200 then break end
                        end

                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        hrp.CFrame = originalCFrame
                        
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = true end
                        end
                        
                        task.wait(1.5) -- พักก่อนเริ่มหาใหม่
                    end
                end
            end)
        end
    end
})
local killAllConnection = nil
murderermystery2:Toggle({
    Title = "สังหารทุกคน (Murderer Only)",
    Desc = "เมื่อเป็นฆาตกร จะฆ่าทุกคนอัตโนมัติ",
    Value = false,
    Callback = function(state)
        _G.KillAllMM2 = state
        if not state then
            if killAllConnection then
                killAllConnection:Disconnect()
                killAllConnection = nil
            end
        else
            local function isMurderer()
                local lp = game.Players.LocalPlayer
                if playerData and playerData[lp.Name] then
                    if tostring(playerData[lp.Name].Role) == "Murderer" then
                        return true
                    end
                end
                if lp.Backpack:FindFirstChild("Knife") then return true end
                if lp.Character and lp.Character:FindFirstChild("Knife") then return true end
                return false
            end

            local function killAll()
                local lp = game.Players.LocalPlayer
                local char = lp.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if not char:FindFirstChild("Knife") then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if lp.Backpack:FindFirstChild("Knife") then
                        hum:EquipTool(lp.Backpack:FindFirstChild("Knife"))
                        task.wait(0.1)
                    else
                        return
                    end
                end

                local knife = char:FindFirstChild("Knife")
                if not knife then return end

                for _, v in pairs(game.Players:GetPlayers()) do
				    if not _G.KillAllMM2 then break end
				    if v == lp then continue end
				    if not v.Character then continue end
				
				    local targetHRP = v.Character:FindFirstChild("HumanoidRootPart")
				    if not targetHRP then continue end
				
				    if playerData and playerData[v.Name] then
				        if playerData[v.Name].Dead == true then continue end
				        local role = tostring(playerData[v.Name].Role)
				        if role == "Murderer" then continue end
				    else
				        if v.Backpack:FindFirstChild("Knife") or
				           (v.Character and v.Character:FindFirstChild("Knife")) then
				            continue
				        end
				    end
				
				    local oldPos = hrp.CFrame
				
				    pcall(function()
				        targetHRP.Anchored = true
				        hrp.CFrame = CFrame.new(targetHRP.Position) * CFrame.new(0, 0, 2)
				        task.wait(0.1)
				        knife.Stab:FireServer("Slash")
				        task.wait(0.1)
				    end)
				
				    pcall(function()
				        targetHRP.Anchored = false
				    end)
				
				    hrp.CFrame = oldPos
				    task.wait(0.3)
				end
            end

            task.spawn(function()
                while _G.KillAllMM2 do
                    task.wait(1)
                    if isMurderer() then
                        killAll()
                    end
                end
            end)
        end
    end
})

murderermystery2:Toggle({
    Title = "สังหาร Murderer V3 (Sheriff ooly)",
    Desc = "วาร์ปไปสิงร่างฆาตกรแล้วยิง",
    Value = false,
    Callback = function(state)
        _G.KillMurdererOnlyV3 = state
        if state then
            task.spawn(function()
                while _G.KillMurdererOnlyV3 do
                    local target = getMurderer()
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local gun = char and (char:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun"))
                    
                    if target and hrp and gun and target:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = target.HumanoidRootPart
                        local oldPos = hrp.CFrame
                        
                        if gun.Parent ~= char then
                            char.Humanoid:EquipTool(gun)
                            task.wait(0.2)
                        end
                        
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1)
                        task.wait(0.1)
                        
                        gun:Activate()
                        
                        task.wait(0.1)
                        hrp.CFrame = oldPos
                        
                        task.wait(3.5) 
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

murderermystery2:Toggle({
    Title = "Silent Aim (ล็อคเป้าฆาตกร)",
    Desc = "ล็อคเป้าฆาตกร 100% (ต้องมีปืน)",
    Value = false,
    Callback = function(state)
        _G.KillMurdererOnly = state
    end
})

local function secureGun()
    local gunDrop = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            gunDrop = obj
            break
        end
    end
    if gunDrop then
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local currentPos = root.CFrame
            if gunDrop:IsA("Model") then
                root.CFrame = gunDrop:GetPivot() * CFrame.new(0, 1, 0)
            else
                root.CFrame = gunDrop.CFrame * CFrame.new(0, 1, 0)
            end
            task.wait(0.3) 
            root.CFrame = currentPos
        end
    end
end

murderermystery2:Toggle({
    Title = "เก็บปืนอัตโนมัติ (Auto Collect Gun)",
    Desc = "วาร์ปไปเก็บปืนที่ตกแล้วกลับมาที่เดิมทันที",
    Value = false,
    Callback = function(state)
        _G.AutoCollectGun = state
        if state then
            task.spawn(function()
                while _G.AutoCollectGun do
                    secureGun()
                    task.wait(0.5)
                end
            end)
        end
    end
})

local OldNameCall
OldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.KillMurdererOnly and method == "FireServer" and tostring(self) == "GunFired" then
        local targetChar = getMurderer()
        if targetChar and targetChar:FindFirstChild("Head") then
            local targetHead = targetChar.Head
            local gun = lp.Character and lp.Character:FindFirstChild("Gun")
            
            if gun and gun:FindFirstChild("Handle") then
                args[2] = tostring(gun.Handle.Position)
                args[3] = tostring(targetHead.Position)
                args[4] = targetHead
                return OldNameCall(self, unpack(args))
            end
        end
    end
    return OldNameCall(self, ...)
end)


-- [[ Notification & Start ]] --
WindUI:Notify({
    Title = "HG HUB V1",
    Content = "โปรดใช้ด้วยความระมัดระวัง บางฟังก์ชั่นอาจจะมีการแบนได้!",
    Duration = 10, -- 3 seconds
    Icon = "bird",
})
