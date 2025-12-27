-- LocalScript (ScreenGui内)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "RandomCircleTPGui"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(200, 200, 200)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.8
uiStroke.Parent = mainFrame

-- タイトルバー（ドラッグ用 + 最小化ボタン）
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Random Circle Teleport"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeBtn

-- コンテンツエリア（最小化時に隠す）
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- ScrollingFrameで縦スクロール対応
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = contentFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = scrollingFrame

-- ドラッグ機能
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 最小化機能
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minimizeBtn.Text = minimized and "+" or "-"
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 400)
end)

-- 設定項目
local function createLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scrollingFrame
    return label
end

-- 半径設定
createLabel("半径 (5-10 studs)")
local radiusSliderFrame = Instance.new("Frame")
radiusSliderFrame.Size = UDim2.new(1, 0, 0, 30)
radiusSliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusSliderFrame.Parent = scrollingFrame

local radiusCorner = Instance.new("UICorner")
radiusCorner.CornerRadius = UDim.new(0, 8)
radiusCorner.Parent = radiusSliderFrame

local radiusHandle = Instance.new("Frame")
radiusHandle.Size = UDim2.new(0, 20, 1, 0)
radiusHandle.BackgroundColor3 = Color3.fromRGB(100,100,255)
radiusHandle.Position = UDim2.new(0.4, 0, 0, 0) -- デフォルト7
radiusHandle.Parent = radiusSliderFrame

local radiusHandleCorner = Instance.new("UICorner")
radiusHandleCorner.CornerRadius = UDim.new(0, 8)
radiusHandleCorner.Parent = radiusHandle

local radiusValue = 7

-- テレポート間隔設定
createLabel("テレポート間隔 (秒)")
local delaySliderFrame = Instance.new("Frame")
delaySliderFrame.Size = UDim2.new(1, 0, 0, 30)
delaySliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
delaySliderFrame.Parent = scrollingFrame

local delayCorner = Instance.new("UICorner")
delayCorner.CornerRadius = UDim.new(0, 8)
delayCorner.Parent = delaySliderFrame

local delayHandle = Instance.new("Frame")
delayHandle.Size = UDim2.new(0, 20, 1, 0)
delayHandle.BackgroundColor3 = Color3.fromRGB(100,255,100)
delayHandle.Position = UDim2.new(0.4, 0, 0, 0) -- デフォルト0.5
delayHandle.Parent = delaySliderFrame

local delayHandleCorner = Instance.new("UICorner")
delayHandleCorner.CornerRadius = UDim.new(0, 8)
delayHandleCorner.Parent = delayHandle

local delayValue = 0.5

-- 手動入力TextBox
createLabel("手動間隔入力 (0.01-10)")
local delayTextBox = Instance.new("TextBox")
delayTextBox.Size = UDim2.new(1, 0, 0, 30)
delayTextBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
delayTextBox.Text = "0.5"
delayTextBox.TextColor3 = Color3.new(1,1,1)
delayTextBox.Parent = scrollingFrame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 8)
tbCorner.Parent = delayTextBox

-- 数字のみ制限
delayTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local text = delayTextBox.Text:gsub("[^%d%.]", "")
    if text ~= "" then
        local num = tonumber(text)
        if num then
            num = math.clamp(num, 0.01, 10)
            text = tostring(num)
        end
    end
    delayTextBox.Text = text
end)

delayTextBox.FocusLost:Connect(function()
    if delayTextBox.Text ~= "" then
        delayValue = tonumber(delayTextBox.Text) or delayValue
        delayTextBox.Text = string.format("%.3f", delayValue)
        -- スライダー同期
        delayHandle.Position = UDim2.new((delayValue - 0.1)/(1-0.1), 0, 0, 0)
    end
end)

-- スタートボタン
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 40)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
startBtn.Text = "スタート"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = scrollingFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 10)
startCorner.Parent = startBtn

-- スライダー操作
local function setupSlider(sliderFrame, handle, minVal, maxVal, defaultVal, callback)
    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(relX, 0, 0, 0)
            local value = minVal + (maxVal - minVal) * relX
            callback(value)
        end
    end)
end

setupSlider(radiusSliderFrame, radiusHandle, 5, 10, 7, function(val)
    radiusValue = val
end)

setupSlider(delaySliderFrame, delayHandle, 0.1, 1, 0.5, function(val)
    delayValue = val
    delayTextBox.Text = string.format("%.3f", val)
end)

-- テレポートロジック
local running = false
local connection = nil

local function teleportLoop()
    while running do
        local angle = math.random() * 2 * math.pi
        local offset = Vector3.new(math.cos(angle) * radiusValue, 0, math.sin(angle) * radiusValue)
        local newPos = humanoidRootPart.Position + offset
        humanoidRootPart.CFrame = CFrame.new(newPos)
        task.wait(delayValue)
    end
end

startBtn.MouseButton1Click:Connect(function()
    running = not running
    startBtn.Text = running and "ストップ" or "スタート"
    startBtn.BackgroundColor3 = running and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(0, 170, 255)
    
    if running then
        if connection then connection:Disconnect() end
        connection = RunService.Heartbeat:Connect(function() end) -- dummy
        task.spawn(teleportLoop)
    end
end)

-- プレイヤー再生成対応
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end)
