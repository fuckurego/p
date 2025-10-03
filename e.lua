local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = game:GetService('Players').LocalPlayer
local VirtualUser = game:GetService('VirtualUser')
local RunService = game:GetService('RunService')
local workspace = game:GetService('Workspace')

-- Stats tracking
local stats = {
    candies_collected = 0,
    total_points_earned = 0,
    last_points = nil,
    session_start_points = nil
}

-- Level calculation constants
local XP_POWER = 1.0501716659439975

-- Convert points to XP
local function pointsToXP(pts)
    return 0.5 * math.pow(pts, XP_POWER)
end

-- Convert XP to points
local function xpToPoints(xp)
    return 2 * math.pow(xp, 1 / XP_POWER)
end

-- Calculate XP between levels
local function calculateXPBetweenLevels(startLvl, endLvl)
    local totalXP = 0
    local x = startLvl
    while x < endLvl do
        local f = math.floor(x)
        totalXP = totalXP + (10 + f * f) * 0.01
        x = x + 0.01
    end
    return math.floor(totalXP * 30 + 0.5)
end

-- Calculate level from points
local function calculateLevelFromPoints(baseLvl, pts)
    local xp = pointsToXP(pts)
    local currXP = 0
    local lvl = baseLvl
    
    while true do
        local nextXP = calculateXPBetweenLevels(lvl, lvl + 1)
        if currXP + nextXP > xp then
            return lvl + (xp - currXP) / nextXP
        end
        currXP = currXP + nextXP
        lvl = lvl + 1
        
        -- Safety break to prevent infinite loop
        if lvl > 10000 then break end
    end
    return lvl
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CandyStatsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 170)
MainFrame.Position = UDim2.new(0.01, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.BorderSizePixel = 0
Title.Text = "🍬 Candy Farm Stats"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local CandiesLabel = Instance.new("TextLabel")
CandiesLabel.Size = UDim2.new(1, -20, 0, 22)
CandiesLabel.Position = UDim2.new(0, 10, 0, 35)
CandiesLabel.BackgroundTransparency = 1
CandiesLabel.Text = "Candies Collected: 0"
CandiesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
CandiesLabel.TextSize = 13
CandiesLabel.Font = Enum.Font.Gotham
CandiesLabel.TextXAlignment = Enum.TextXAlignment.Left
CandiesLabel.Parent = MainFrame

local CurrentPointsLabel = Instance.new("TextLabel")
CurrentPointsLabel.Size = UDim2.new(1, -20, 0, 22)
CurrentPointsLabel.Position = UDim2.new(0, 10, 0, 57)
CurrentPointsLabel.BackgroundTransparency = 1
CurrentPointsLabel.Text = "Current Points: 0"
CurrentPointsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
CurrentPointsLabel.TextSize = 13
CurrentPointsLabel.Font = Enum.Font.Gotham
CurrentPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentPointsLabel.Parent = MainFrame

local TotalPointsLabel = Instance.new("TextLabel")
TotalPointsLabel.Size = UDim2.new(1, -20, 0, 22)
TotalPointsLabel.Position = UDim2.new(0, 10, 0, 79)
TotalPointsLabel.BackgroundTransparency = 1
TotalPointsLabel.Text = "Total Points Earned: 0"
TotalPointsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TotalPointsLabel.TextSize = 13
TotalPointsLabel.Font = Enum.Font.Gotham
TotalPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
TotalPointsLabel.Parent = MainFrame

local CurrentLevelLabel = Instance.new("TextLabel")
CurrentLevelLabel.Size = UDim2.new(1, -20, 0, 22)
CurrentLevelLabel.Position = UDim2.new(0, 10, 0, 101)
CurrentLevelLabel.BackgroundTransparency = 1
CurrentLevelLabel.Text = "Current Level: 0.00"
CurrentLevelLabel.TextColor3 = Color3.fromRGB(255, 150, 255)
CurrentLevelLabel.TextSize = 13
CurrentLevelLabel.Font = Enum.Font.Gotham
CurrentLevelLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentLevelLabel.Parent = MainFrame

local PotentialLevelLabel = Instance.new("TextLabel")
PotentialLevelLabel.Size = UDim2.new(1, -20, 0, 22)
PotentialLevelLabel.Position = UDim2.new(0, 10, 0, 123)
PotentialLevelLabel.BackgroundTransparency = 1
PotentialLevelLabel.Text = "If Turn In: Lvl 0.00 (+0.00)"
PotentialLevelLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
PotentialLevelLabel.TextSize = 13
PotentialLevelLabel.Font = Enum.Font.Gotham
PotentialLevelLabel.TextXAlignment = Enum.TextXAlignment.Left
PotentialLevelLabel.Parent = MainFrame

local LevelGainLabel = Instance.new("TextLabel")
LevelGainLabel.Size = UDim2.new(1, -20, 0, 22)
LevelGainLabel.Position = UDim2.new(0, 10, 0, 145)
LevelGainLabel.BackgroundTransparency = 1
LevelGainLabel.Text = "Session Gain: +0.00 levels"
LevelGainLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
LevelGainLabel.TextSize = 13
LevelGainLabel.Font = Enum.Font.Gotham
LevelGainLabel.TextXAlignment = Enum.TextXAlignment.Left
LevelGainLabel.Parent = MainFrame

-- Make GUI draggable
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Function to format numbers with commas
local function formatNumber(num)
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Function to get current level from player data
local function getCurrentLevel()
    local player_data = ReplicatedStorage.PlayerData:FindFirstChild(LocalPlayer.Name)
    if player_data and player_data:FindFirstChild("Generic") then
        local level_value = player_data.Generic:FindFirstChild("Level")
        if level_value then
            return tonumber(level_value.Value) or 1
        end
    end
    return 1
end

local session_start_level = nil

-- Function to update stats
local function updateStats()
    local player_data = ReplicatedStorage.PlayerData:FindFirstChild(LocalPlayer.Name)
    if player_data and player_data:FindFirstChild("Generic") then
        local points_value = player_data.Generic:FindFirstChild("Points")
        if points_value then
            local current_points = tonumber(points_value.Value) or 0
            
            -- Set starting points on first run
            if stats.session_start_points == nil then
                stats.session_start_points = current_points
                stats.last_points = current_points
                session_start_level = getCurrentLevel()
            end
            
            -- Calculate points earned since session started
            if current_points >= stats.last_points then
                stats.total_points_earned = current_points - stats.session_start_points
            else
                stats.session_start_points = current_points
                stats.total_points_earned = 0
            end
            
            stats.last_points = current_points
            
            -- Get current level
            local current_level = getCurrentLevel()
            
            -- Calculate potential level if points are turned in
            local potential_level = calculateLevelFromPoints(current_level, current_points)
            local level_gain = potential_level - current_level
            local session_level_gain = current_level - (session_start_level or current_level)
            
            -- Update GUI
            CandiesLabel.Text = "Candies Collected: " .. formatNumber(stats.candies_collected)
            CurrentPointsLabel.Text = "Current Points: " .. formatNumber(current_points)
            TotalPointsLabel.Text = "Total Points Earned: " .. formatNumber(stats.total_points_earned)
            CurrentLevelLabel.Text = string.format("Current Level: %.2f", current_level)
            PotentialLevelLabel.Text = string.format("If Turn In: Lvl %.2f (+%.2f)", potential_level, level_gain)
            LevelGainLabel.Text = string.format("Session Gain: +%.2f levels", session_level_gain)
        end
    end
end

local function find_best_candy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild('HumanoidRootPart') then
        return
    end
    
    local hrp = char.HumanoidRootPart
    local best_candy = nil
    local max_dist = math.huge
    local found_high_value = false
    
    for _, obj in workspace:GetChildren() do
        if obj:IsA('BasePart') and obj:FindFirstChild('CandyCornScript') then
            local dist = (hrp.Position - obj.Position).Magnitude
            
            local is_high_value = obj.Size.Magnitude > 6 or obj:FindFirstChildOfClass("ParticleEmitter")
            
            if is_high_value then
                if not found_high_value or dist < max_dist then
                    best_candy = obj
                    max_dist = dist
                    found_high_value = true
                end
            elseif not found_high_value then
                if dist < max_dist then
                    best_candy = obj
                    max_dist = dist
                end
            end
        end
    end
    
    return best_candy
end

local last_candy = nil
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    if not hrp or not hum or hum.Health <= 0 then return end
    
    local candy = find_best_candy()
    if not candy then return end
    
    if last_candy and last_candy ~= candy and not last_candy.Parent then
        stats.candies_collected = stats.candies_collected + 1
    end
    last_candy = candy
    
    local t = tick()
    local cosinus = math.cos(t * 20) * 0.5
    local offset = Vector3.new(0, cosinus, 0)
    local angle = math.rad(t * 2000 % 360)
    
    hrp.CFrame = candy.CFrame * CFrame.Angles(angle, 0, 0) + offset
    hrp.Velocity = Vector3.zero
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    updateStats()
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end)
