-- LocalScript (ScreenGui内)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RandomCircleTPGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(220, 220, 220)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.7
uiStroke.Parent = mainFrame

-- タイトルバー
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
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
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

-- コンテンツエリア
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = contentFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 12)
uiListLayout.Parent = scrollingFrame

-- ドラッグ機能（タイトルバー全体でドラッグ可能）
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- 最小化機能
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minimizeBtn.Text = minimized and "+" or "−"
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 480)
end)

-- ラベル作成ヘルパー
local function createLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Parent = scrollingFrame
    return label
end

-- プレイヤー選択ドロップダウン
createLabel("対象プレイヤー")
local playerDropdownFrame = Instance.new("Frame")
playerDropdownFrame.Size = UDim2.new(1, 0, 0, 40)
playerDropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerDropdownFrame.Parent = scrollingFrame

local pdCorner = Instance.new("UICorner")
pdCorner.CornerRadius = UDim.new(0, 8)
pdCorner.Parent = playerDropdownFrame

local pdButton = Instance.new("TextButton")
pdButton.Size = UDim2.new(1, -10, 1, -10)
pdButton.Position = UDim2.new(0, 5, 0, 5)
pdButton.BackgroundTransparency = 1
pdButton.Text = "選択してください"
pdButton.TextColor3 = Color3.new(1,1,1)
pdButton.Font = Enum.Font.Gotham
pdButton.TextXAlignment = Enum.TextXAlignment.Left
pdButton.Parent = playerDropdownFrame

local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(1, 0, 0, 200)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropdownList.Visible = false
dropdownList.Parent = playerDropdownFrame

local dlCorner = Instance.new("UICorner")
dlCorner.CornerRadius = UDim.new(0, 8)
dlCorner.Parent = dropdownList

local dlList = Instance.new("UIListLayout")
dlList.Parent = dropdownList

local selectedPlayer = Players.LocalPlayer  -- デフォルトは自分

local function refreshPlayerList()
    for _, child in pairs(dropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundTransparency = 1
        btn.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = dropdownList
        
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = plr
            pdButton.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
            dropdownList.Visible = false
        end)
    end
    
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, dlList.AbsoluteContentSize.Y)
end

pdButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
    refreshPlayerList()
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- 半径スライダー
createLabel("半径 (5〜10 studs)")
local radiusSliderBg = Instance.new("Frame")
radiusSliderBg.Size = UDim2.new(1, 0, 0, 30)
radiusSliderBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
radiusSliderBg.Parent = scrollingFrame

local rCorner = Instance.new("UICorner")
rCorner.CornerRadius = UDim.new(0, 8)
rCorner.Parent = radiusSliderBg

local radiusHandle = Instance.new("Frame")
radiusHandle.Size = UDim2.new(0, 20, 1, 0)
radiusHandle.Position = UDim2.new(0.4, 0, 0, 0)  -- デフォルト 7
radiusHandle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
radiusHandle.Parent = radiusSliderBg

local rhCorner = Instance.new("UICorner")
rhCorner.CornerRadius = UDim.new(0, 8)
rhCorner.Parent = radiusHandle

local radiusValue = 7

-- テレポート間隔スライダー
createLabel("テレポート間隔 (0.1〜1秒)")
local delaySliderBg = Instance.new("Frame")
delaySliderBg.Size = UDim2.new(1, 0, 0, 30)
delaySliderBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
delaySliderBg.Parent = scrollingFrame

local dCorner = Instance.new("UICorner")
dCorner.CornerRadius = UDim.new(0, 8)
dCorner.Parent = delaySliderBg

local delayHandle = Instance.new("Frame")
delayHandle.Size = UDim2.new(0, 20, 1, 0)
delayHandle.Position = UDim2.new(0.444, 0, 0, 0)  -- 0.5秒
delayHandle.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
delayHandle.Parent = delaySliderBg

local dhCorner = Instance.new("UICorner")
dhCorner.CornerRadius = UDim.new(0, 8)
dhCorner.Parent = delayHandle

local delayValue = 0.5

-- 手動入力
createLabel("手動間隔入力 (0.01〜10秒)")
local delayTextBox = Instance.new("TextBox")
delayTextBox.Size = UDim2.new(1, 0, 0, 35)
delayTextBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
delayTextBox.Text = "0.5"
delayTextBox.TextColor3 = Color3.new(1,1,1)
delayTextBox.Font = Enum.Font.Gotham
delayTextBox.Parent = scrollingFrame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 8)
tbCorner.Parent = delayTextBox

delayTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(delayTextBox.Text)
        if num then
            delayValue = math.clamp(num, 0.01, 10)
            delayTextBox.Text = string.format("%.3f", delayValue)
            -- スライダー同期（0.1〜1の範囲外も考慮）
            if delayValue <= 1 then
                delayHandle.Position = UDim2.new((delayValue - 0.1)/0.9, 0, 0, 0)
            end
        end
    end
end)

-- スライダー汎用関数
local function makeSlider(bg, handle, minVal, maxVal, callback)
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
            local relX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(relX, 0, 0, 0)
            local val = minVal + (maxVal - minVal) * relX
            callback(val)
        end
    end)
end

makeSlider(radiusSliderBg, radiusHandle, 5, 10, function(v)
    radiusValue = math.floor(v * 100 + 0.5) / 100  -- 小数点2桁
end)

makeSlider(delaySliderBg, delayHandle, 0.1, 1, function(v)
    delayValue = math.floor(v * 1000 + 0.5) / 1000
    delayTextBox.Text = string.format("%.3f", delayValue)
end)

-- スタート/ストップボタン
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 50)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
startBtn.Text = "スタート"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 20
startBtn.Parent = scrollingFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 12)
startCorner.Parent = startBtn

-- テレポート実行部分
local running = false
local teleportTask = nil

local function getTargetHRP()
    if selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return selectedPlayer.Character.HumanoidRootPart
    end
    return nil
end

local function teleportLoop()
    while running do
        local hrp = getTargetHRP()
        if hrp then
            local angle = math.random() * 2 * math.pi
            local offset = Vector3.new(math.cos(angle) * radiusValue, 0, math.sin(angle) * radiusValue)
            hrp.CFrame = CFrame.new(hrp.Position + offset)
        end
        task.wait(delayValue)
    end
end

startBtn.MouseButton1Click:Connect(function()
    running = not running
    startBtn.Text = running and "ストップ" or "スタート"
    startBtn.BackgroundColor3 = running and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(0, 170, 255)
    
    if running then
        teleportTask = task.spawn(teleportLoop)
    else
        if teleportTask then
            task.cancel(teleportTask)
            teleportTask = nil
        end
    end
end)

-- CanvasSize自動調整
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
end)
