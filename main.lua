-- StarterGui/TeleportUIClient.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
end)

-- リモートイベント（サーバーへの通知用）
local TeleportEvent
if ReplicatedStorage:FindFirstChild("TeleportNotification") then
	TeleportEvent = ReplicatedStorage:FindFirstChild("TeleportNotification")
else
	TeleportEvent = Instance.new("RemoteEvent")
	TeleportEvent.Name = "TeleportNotification"
	TeleportEvent.Parent = ReplicatedStorage
end

-- UI要素の作成関数
local function CreateUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TeleportUIClient"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- メインフレーム
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 300, 0, 200)
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	MainFrame.BorderSizePixel = 2
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame
	
	-- タイトルバー
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 30)
	TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame
	
	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	TitleBarCorner.Parent = TitleBar
	
	local TitleText = Instance.new("TextLabel")
	TitleText.Text = "360° ランダムテレポート"
	TitleText.Size = UDim2.new(1, -60, 1, 0)
	TitleText.Position = UDim2.new(0, 10, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.TextColor3 = Color3.fromRGB(230, 230, 230)
	TitleText.Font = Enum.Font.Gotham
	TitleText.TextSize = 14
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar
	
	-- 最小化ボタン
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Text = "-"
	MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
	MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	MinimizeButton.Font = Enum.Font.Gotham
	MinimizeButton.TextSize = 16
	MinimizeButton.Parent = TitleBar
	
	-- 設定ボタン
	local SettingsButton = Instance.new("TextButton")
	SettingsButton.Name = "SettingsButton"
	SettingsButton.Text = "⚙"
	SettingsButton.Size = UDim2.new(0, 30, 0, 30)
	SettingsButton.Position = UDim2.new(1, -30, 0, 0)
	SettingsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SettingsButton.BorderSizePixel = 0
	SettingsButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	SettingsButton.Font = Enum.Font.Gotham
	SettingsButton.TextSize = 16
	SettingsButton.Parent = TitleBar
	
	-- スクロール可能なコンテンツエリア
	local Content = Instance.new("ScrollingFrame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, 0, 1, -30)
	Content.Position = UDim2.new(0, 0, 0, 30)
	Content.BackgroundTransparency = 1
	Content.BorderSizePixel = 0
	Content.ScrollBarThickness = 6
	Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Content.CanvasSize = UDim2.new(0, 0, 0, 350)
	Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Content.Parent = MainFrame
	
	-- 半径設定セクション
	local RadiusSection = Instance.new("Frame")
	RadiusSection.Name = "RadiusSection"
	RadiusSection.Size = UDim2.new(1, -20, 0, 80)
	RadiusSection.Position = UDim2.new(0, 10, 0, 10)
	RadiusSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	RadiusSection.BorderSizePixel = 0
	RadiusSection.Parent = Content
	
	local RadiusSectionCorner = Instance.new("UICorner")
	RadiusSectionCorner.CornerRadius = UDim.new(0, 8)
	RadiusSectionCorner.Parent = RadiusSection
	
	local RadiusLabel = Instance.new("TextLabel")
	RadiusLabel.Text = "テレポート半径 (5-10 スタッド)"
	RadiusLabel.Size = UDim2.new(1, -20, 0, 20)
	RadiusLabel.Position = UDim2.new(0, 10, 0, 5)
	RadiusLabel.BackgroundTransparency = 1
	RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	RadiusLabel.Font = Enum.Font.Gotham
	RadiusLabel.TextSize = 12
	RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
	RadiusLabel.Parent = RadiusSection
	
	-- 半径スライダー
	local RadiusSlider = Instance.new("Frame")
	RadiusSlider.Name = "RadiusSlider"
	RadiusSlider.Size = UDim2.new(1, -20, 0, 20)
	RadiusSlider.Position = UDim2.new(0, 10, 0, 30)
	RadiusSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	RadiusSlider.BorderSizePixel = 0
	RadiusSlider.Parent = RadiusSection
	
	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 10)
	SliderCorner.Parent = RadiusSlider
	
	local Fill = Instance.new("Frame")
	Fill.Name = "Fill"
	Fill.Size = UDim2.new(0.5, 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
	Fill.BorderSizePixel = 0
	Fill.Parent = RadiusSlider
	
	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(0, 10)
	FillCorner.Parent = Fill
	
	local SliderButton = Instance.new("TextButton")
	SliderButton.Name = "Button"
	SliderButton.Size = UDim2.new(0, 20, 0, 20)
	SliderButton.Position = UDim2.new(0.5, -10, 0, 0)
	SliderButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	SliderButton.BorderSizePixel = 2
	SliderButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
	SliderButton.Text = ""
	SliderButton.Parent = RadiusSlider
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 10)
	ButtonCorner.Parent = SliderButton
	
	-- 半径値表示
	local RadiusValue = Instance.new("TextLabel")
	RadiusValue.Name = "RadiusValue"
	RadiusValue.Text = "7.5"
	RadiusValue.Size = UDim2.new(0, 50, 0, 20)
	RadiusValue.Position = UDim2.new(1, -60, 0, 55)
	RadiusValue.BackgroundTransparency = 1
	RadiusValue.TextColor3 = Color3.fromRGB(200, 200, 200)
	RadiusValue.Font = Enum.Font.Gotham
	RadiusValue.TextSize = 14
	RadiusValue.TextXAlignment = Enum.TextXAlignment.Right
	RadiusValue.Parent = RadiusSection
	
	local StudsLabel = Instance.new("TextLabel")
	StudsLabel.Text = "スタッド"
	StudsLabel.Size = UDim2.new(0, 40, 0, 20)
	StudsLabel.Position = UDim2.new(1, -15, 0, 55)
	StudsLabel.BackgroundTransparency = 1
	StudsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	StudsLabel.Font = Enum.Font.Gotham
	StudsLabel.TextSize = 12
	StudsLabel.TextXAlignment = Enum.TextXAlignment.Left
	StudsLabel.Parent = RadiusSection
	
	-- テレポートボタン
	local TeleportButton = Instance.new("TextButton")
	TeleportButton.Name = "TeleportButton"
	TeleportButton.Text = "テレポート!"
	TeleportButton.Size = UDim2.new(1, -20, 0, 50)
	TeleportButton.Position = UDim2.new(0, 10, 0, 100)
	TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	TeleportButton.BorderSizePixel = 0
	TeleportButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	TeleportButton.Font = Enum.Font.Gotham
	TeleportButton.TextSize = 18
	TeleportButton.Parent = Content
	
	local TeleportButtonCorner = Instance.new("UICorner")
	TeleportButtonCorner.CornerRadius = UDim.new(0, 8)
	TeleportButtonCorner.Parent = TeleportButton
	
	-- 説明テキスト
	local Description = Instance.new("TextLabel")
	Description.Text = "プレイヤーの周囲を円形にランダムテレポートします。"
	Description.Size = UDim2.new(1, -20, 0, 60)
	Description.Position = UDim2.new(0, 10, 0, 160)
	Description.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Description.BorderSizePixel = 0
	Description.TextColor3 = Color3.fromRGB(180, 180, 180)
	Description.Font = Enum.Font.Gotham
	Description.TextSize = 12
	Description.TextWrapped = true
	Description.Parent = Content
	
	local DescriptionCorner = Instance.new("UICorner")
	DescriptionCorner.CornerRadius = UDim.new(0, 8)
	DescriptionCorner.Parent = Description
	
	-- 設定フレーム
	local SettingsFrame = Instance.new("Frame")
	SettingsFrame.Name = "SettingsFrame"
	SettingsFrame.Visible = false
	SettingsFrame.Size = UDim2.new(0, 350, 0, 400)
	SettingsFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
	SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	SettingsFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	SettingsFrame.BorderSizePixel = 2
	SettingsFrame.Parent = ScreenGui
	
	local SettingsCorner = Instance.new("UICorner")
	SettingsCorner.CornerRadius = UDim.new(0, 12)
	SettingsCorner.Parent = SettingsFrame
	
	-- 設定ヘッダー
	local SettingsHeader = Instance.new("Frame")
	SettingsHeader.Name = "SettingsHeader"
	SettingsHeader.Size = UDim2.new(1, 0, 0, 40)
	SettingsHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	SettingsHeader.BorderSizePixel = 0
	SettingsHeader.Parent = SettingsFrame
	
	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	HeaderCorner.Parent = SettingsHeader
	
	local SettingsTitle = Instance.new("TextLabel")
	SettingsTitle.Text = "設定"
	SettingsTitle.Size = UDim2.new(1, -40, 1, 0)
	SettingsTitle.Position = UDim2.new(0, 20, 0, 0)
	SettingsTitle.BackgroundTransparency = 1
	SettingsTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
	SettingsTitle.Font = Enum.Font.GothamBold
	SettingsTitle.TextSize = 18
	SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
	SettingsTitle.Parent = SettingsHeader
	
	local CloseSettings = Instance.new("TextButton")
	CloseSettings.Name = "CloseSettings"
	CloseSettings.Text = "×"
	CloseSettings.Size = UDim2.new(0, 40, 0, 40)
	CloseSettings.Position = UDim2.new(1, -40, 0, 0)
	CloseSettings.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	CloseSettings.BorderSizePixel = 0
	CloseSettings.TextColor3 = Color3.fromRGB(230, 230, 230)
	CloseSettings.Font = Enum.Font.Gotham
	CloseSettings.TextSize = 20
	CloseSettings.Parent = SettingsHeader
	
	-- 設定コンテンツ
	local SettingsContent = Instance.new("ScrollingFrame")
	SettingsContent.Name = "SettingsContent"
	SettingsContent.Size = UDim2.new(1, 0, 1, -40)
	SettingsContent.Position = UDim2.new(0, 0, 0, 40)
	SettingsContent.BackgroundTransparency = 1
	SettingsContent.BorderSizePixel = 0
	SettingsContent.ScrollBarThickness = 6
	SettingsContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
	SettingsContent.Parent = SettingsFrame
	
	-- 遅延時間セクション
	local DelaySection = Instance.new("Frame")
	DelaySection.Name = "DelaySection"
	DelaySection.Size = UDim2.new(1, -20, 0, 100)
	DelaySection.Position = UDim2.new(0, 10, 0, 10)
	DelaySection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	DelaySection.BorderSizePixel = 0
	DelaySection.Parent = SettingsContent
	
	local DelayCorner = Instance.new("UICorner")
	DelayCorner.CornerRadius = UDim.new(0, 8)
	DelayCorner.Parent = DelaySection
	
	local DelayLabel = Instance.new("TextLabel")
	DelayLabel.Text = "テレポート遅延時間 (0.1-1秒)"
	DelayLabel.Size = UDim2.new(1, -20, 0, 20)
	DelayLabel.Position = UDim2.new(0, 10, 0, 5)
	DelayLabel.BackgroundTransparency = 1
	DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	DelayLabel.Font = Enum.Font.Gotham
	DelayLabel.TextSize = 12
	DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
	DelayLabel.Parent = DelaySection
	
	-- 遅延スライダー
	local DelaySlider = Instance.new("Frame")
	DelaySlider.Name = "DelaySlider"
	DelaySlider.Size = UDim2.new(1, -20, 0, 20)
	DelaySlider.Position = UDim2.new(0, 10, 0, 30)
	DelaySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	DelaySlider.BorderSizePixel = 0
	DelaySlider.Parent = DelaySection
	
	local DelaySliderCorner = Instance.new("UICorner")
	DelaySliderCorner.CornerRadius = UDim.new(0, 10)
	DelaySliderCorner.Parent = DelaySlider
	
	local DelayFill = Instance.new("Frame")
	DelayFill.Name = "Fill"
	DelayFill.Size = UDim2.new(0.5, 0, 1, 0)
	DelayFill.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
	DelayFill.BorderSizePixel = 0
	DelayFill.Parent = DelaySlider
	
	local DelayFillCorner = Instance.new("UICorner")
	DelayFillCorner.CornerRadius = UDim.new(0, 10)
	DelayFillCorner.Parent = DelayFill
	
	local DelayButton = Instance.new("TextButton")
	DelayButton.Name = "Button"
	DelayButton.Size = UDim2.new(0, 20, 0, 20)
	DelayButton.Position = UDim2.new(0.5, -10, 0, 0)
	DelayButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	DelayButton.BorderSizePixel = 2
	DelayButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
	DelayButton.Text = ""
	DelayButton.Parent = DelaySlider
	
	local DelayButtonCorner = Instance.new("UICorner")
	DelayButtonCorner.CornerRadius = UDim.new(0, 10)
	DelayButtonCorner.Parent = DelayButton
	
	-- 遅延値表示
	local DelayValue = Instance.new("TextLabel")
	DelayValue.Name = "DelayValue"
	DelayValue.Text = "0.5"
	DelayValue.Size = UDim2.new(0, 50, 0, 20)
	DelayValue.Position = UDim2.new(1, -60, 0, 55)
	DelayValue.BackgroundTransparency = 1
	DelayValue.TextColor3 = Color3.fromRGB(200, 200, 200)
	DelayValue.Font = Enum.Font.Gotham
	DelayValue.TextSize = 14
	DelayValue.TextXAlignment = Enum.TextXAlignment.Right
	DelayValue.Parent = DelaySection
	
	local SecondsLabel = Instance.new("TextLabel")
	SecondsLabel.Text = "秒"
	SecondsLabel.Size = UDim2.new(0, 20, 0, 20)
	SecondsLabel.Position = UDim2.new(1, -15, 0, 55)
	SecondsLabel.BackgroundTransparency = 1
	SecondsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	SecondsLabel.Font = Enum.Font.Gotham
	SecondsLabel.TextSize = 12
	SecondsLabel.TextXAlignment = Enum.TextXAlignment.Left
	SecondsLabel.Parent = DelaySection
	
	-- カスタム遅延入力
	local CustomDelay = Instance.new("Frame")
	CustomDelay.Name = "CustomDelay"
	CustomDelay.Size = UDim2.new(1, -20, 0, 120)
	CustomDelay.Position = UDim2.new(0, 10, 0, 120)
	CustomDelay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	CustomDelay.BorderSizePixel = 0
	CustomDelay.Parent = SettingsContent
	
	local CustomDelayCorner = Instance.new("UICorner")
	CustomDelayCorner.CornerRadius = UDim.new(0, 8)
	CustomDelayCorner.Parent = CustomDelay
	
	local CustomDelayLabel = Instance.new("TextLabel")
	CustomDelayLabel.Text = "カスタム遅延時間 (0.01-10秒)"
	CustomDelayLabel.Size = UDim2.new(1, -20, 0, 20)
	CustomDelayLabel.Position = UDim2.new(0, 10, 0, 5)
	CustomDelayLabel.BackgroundTransparency = 1
	CustomDelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	CustomDelayLabel.Font = Enum.Font.Gotham
	CustomDelayLabel.TextSize = 12
	CustomDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
	CustomDelayLabel.Parent = CustomDelay
	
	local CustomDelayDesc = Instance.new("TextLabel")
	CustomDelayDesc.Text = "直接数値を入力してください:"
	CustomDelayDesc.Size = UDim2.new(1, -20, 0, 20)
	CustomDelayDesc.Position = UDim2.new(0, 10, 0, 30)
	CustomDelayDesc.BackgroundTransparency = 1
	CustomDelayDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
	CustomDelayDesc.Font = Enum.Font.Gotham
	CustomDelayDesc.TextSize = 11
	CustomDelayDesc.TextXAlignment = Enum.TextXAlignment.Left
	CustomDelayDesc.Parent = CustomDelay
	
	local InputBox = Instance.new("TextBox")
	InputBox.Name = "InputBox"
	InputBox.Size = UDim2.new(1, -20, 0, 30)
	InputBox.Position = UDim2.new(0, 10, 0, 55)
	InputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	InputBox.BorderSizePixel = 0
	InputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	InputBox.Font = Enum.Font.Gotham
	InputBox.TextSize = 14
	InputBox.PlaceholderText = "例: 0.05 または 2.5"
	InputBox.ClearTextOnFocus = false
	InputBox.Parent = CustomDelay
	
	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 6)
	InputCorner.Parent = InputBox
	
	local ApplyButton = Instance.new("TextButton")
	ApplyButton.Name = "ApplyButton"
	ApplyButton.Text = "適用"
	ApplyButton.Size = UDim2.new(0.5, -15, 0, 30)
	ApplyButton.Position = UDim2.new(0, 10, 0, 90)
	ApplyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
	ApplyButton.BorderSizePixel = 0
	ApplyButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	ApplyButton.Font = Enum.Font.Gotham
	ApplyButton.TextSize = 14
	ApplyButton.Parent = CustomDelay
	
	local ApplyCorner = Instance.new("UICorner")
	ApplyCorner.CornerRadius = UDim.new(0, 6)
	ApplyCorner.Parent = ApplyButton
	
	-- UIを最前面に
	ScreenGui.DisplayOrder = 10
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	
	return ScreenGui, {
		MainFrame = MainFrame,
		TitleBar = TitleBar,
		MinimizeButton = MinimizeButton,
		SettingsButton = SettingsButton,
		TeleportButton = TeleportButton,
		RadiusSlider = RadiusSlider,
		RadiusValue = RadiusValue,
		SettingsFrame = SettingsFrame,
		CloseSettings = CloseSettings,
		DelaySlider = DelaySlider,
		DelayValue = DelayValue,
		CustomDelay = CustomDelay,
		CustomDelayInput = InputBox,
		ApplyButton = ApplyButton
	}
end

-- UIを作成
local UI = CreateUI()
local Elements = UI[2]

-- 設定値
local Settings = {
	Radius = 7.5,
	Delay = 0.5,
	IsTeleporting = false
}

-- UIドラッグ機能
local function MakeDraggable(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function Update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			Update(input)
		end
	end)
end

-- スライダー作成関数
local function SetupSlider(sliderFrame, valueLabel, min, max, defaultValue, callback)
	local slider = sliderFrame
	local fill = slider:FindFirstChild("Fill")
	local button = slider:FindFirstChild("Button")
	
	local isDragging = false
	
	-- 値の更新関数
	local function UpdateValue(value)
		value = math.clamp(value, min, max)
		local percent = (value - min) / (max - min)
		
		-- UI更新
		fill.Size = UDim2.new(percent, 0, 1, 0)
		valueLabel.Text = string.format("%.2f", value)
		
		-- コールバック実行
		if callback then
			callback(value)
		end
		
		return value
	end
	
	-- 初期値設定
	UpdateValue(defaultValue)
	
	-- ドラッグ機能
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
		end
	end)
	
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	return {
		Update = UpdateValue,
		GetValue = function() return tonumber(valueLabel.Text) end
	}
end

-- メインテレポート関数（クライアント側で動作）
local function TeleportPlayer(radius, delayTime)
	if Settings.IsTeleporting then
		return false
	end
	
	if not Character then
		Character = Player.Character
		if not Character then
			warn("キャラクターが見つかりません")
			return false
		end
	end
	
	local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		warn("HumanoidRootPartが見つかりません")
		return false
	end
	
	Settings.IsTeleporting = true
	
	-- サーバーに通知（オプション）
	TeleportEvent:FireServer("TeleportStarted", {
		Player = Player.Name,
		Radius = radius,
		Delay = delayTime,
		Position = humanoidRootPart.Position
	})
	
	-- 遅延がある場合は待機
	if delayTime and delayTime > 0 then
		task.wait(delayTime)
	end
	
	-- ランダムな角度を生成 (0-360度)
	local randomAngle = math.random() * 2 * math.pi
	
	-- 円形の座標を計算
	local offsetX = math.cos(randomAngle) * radius
	local offsetZ = math.sin(randomAngle) * radius
	
	-- 現在位置からオフセットを加算
	local currentPosition = humanoidRootPart.Position
	local newPosition = Vector3.new(
		currentPosition.X + offsetX,
		currentPosition.Y, -- Yは変更しない（高さを維持）
		currentPosition.Z + offsetZ
	)
	
	-- 地面検出のためにRaycast
	local rayOrigin = Vector3.new(newPosition.X, currentPosition.Y + 5, newPosition.Z)
	local rayDirection = Vector3.new(0, -10, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {Character}
	
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if raycastResult then
		newPosition = Vector3.new(
			newPosition.X,
			raycastResult.Position.Y + 3, -- 地面から少し上
			newPosition.Z
		)
	end
	
	-- テレポート実行
	humanoidRootPart.CFrame = CFrame.new(newPosition)
	
	-- サーバーに通知（オプション）
	TeleportEvent:FireServer("TeleportCompleted", {
		Player = Player.Name,
		Radius = radius,
		Delay = delayTime,
		FromPosition = currentPosition,
		ToPosition = newPosition
	})
	
	-- デバッグ用に円形のビジュアルを作成（オプション）
	if false then -- 必要に応じてtrueに変更
		local visualize = Instance.new("Part")
		visualize.Shape = Enum.PartType.Ball
		visualize.Size = Vector3.new(2, 2, 2)
		visualize.Position = newPosition
		visualize.Anchored = true
		visualize.CanCollide = false
		visualize.Transparency = 0.5
		visualize.BrickColor = BrickColor.new("Bright green")
		visualize.Parent = workspace
		
		game:GetService("Debris"):AddItem(visualize, 5)
	end
	
	Settings.IsTeleporting = false
	return true
end

-- UI初期化
MakeDraggable(Elements.MainFrame, Elements.TitleBar)

-- スライダー設定
local radiusControl = SetupSlider(Elements.RadiusSlider, Elements.RadiusValue, 5, 10, 7.5, function(value)
	Settings.Radius = value
end)

local delayControl = SetupSlider(Elements.DelaySlider, Elements.DelayValue, 0.1, 1, 0.5, function(value)
	Settings.Delay = value
end)

-- テレポートボタン
Elements.TeleportButton.MouseButton1Click:Connect(function()
	-- ボタンの視覚的フィードバック
	Elements.TeleportButton.Text = "テレポート中..."
	Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	
	-- テレポート実行
	local success = TeleportPlayer(Settings.Radius, Settings.Delay)
	
	-- 結果に応じたフィードバック
	if success then
		Elements.TeleportButton.Text = "成功!"
		Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
		task.wait(0.5)
	else
		Elements.TeleportButton.Text = "失敗"
		Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
		task.wait(0.5)
	end
	
	Elements.TeleportButton.Text = "テレポート!"
	Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- 最小化ボタン
local isMinimized = false
Elements.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	
	if isMinimized then
		Elements.MainFrame.Size = UDim2.new(0, 300, 0, 40)
		Elements.MinimizeButton.Text = "+"
	else
		Elements.MainFrame.Size = UDim2.new(0, 300, 0, 200)
		Elements.MinimizeButton.Text = "-"
	end
end)

-- 設定ボタン
Elements.SettingsButton.MouseButton1Click:Connect(function()
	Elements.SettingsFrame.Visible = true
end)

-- 設定を閉じる
Elements.CloseSettings.MouseButton1Click:Connect(function()
	Elements.SettingsFrame.Visible = false
end)

-- カスタム遅延時間入力
Elements.ApplyButton.MouseButton1Click:Connect(function()
	local inputText = Elements.CustomDelayInput.Text
	local delayTime = tonumber(inputText)
	
	if delayTime then
		delayTime = math.clamp(delayTime, 0.01, 10)
		delayControl.Update(delayTime)
		Elements.CustomDelayInput.Text = ""
		
		print("カスタム遅延時間を " .. delayTime .. " 秒に設定しました")
	end
end)

-- エンターキーでも適用
Elements.CustomDelayInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		Elements.ApplyButton:Activate()
	end
end)

-- キーバインド（オプション：例：Tキーでテレポート）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.T then
		-- Tキーでテレポート
		Elements.TeleportButton:Activate()
	end
end)

print("360° ランダムテレポートUIが読み込まれました！")
print("半径: " .. Settings.Radius .. " スタッド, 遅延: " .. Settings.Delay .. " 秒")
