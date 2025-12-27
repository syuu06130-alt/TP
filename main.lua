-- StarterGui/TeleportUIClient.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
end)

-- 設定値
local Settings = {
	Radius = 7.5,
	Delay = 0.5,
	SelectedPlayer = nil, -- 選択されたプレイヤー
	IsTeleporting = false
}

-- UI要素の作成関数
local function CreateUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TeleportUIClient"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- メインフレーム
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 350, 0, 250)
	MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	MainFrame.BorderSizePixel = 2
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Selectable = true
	MainFrame.Parent = ScreenGui
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame
	
	-- タイトルバー（ドラッグ可能）
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 35)
	TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame
	
	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	TitleBarCorner.Parent = TitleBar
	
	local TitleText = Instance.new("TextLabel")
	TitleText.Text = "360° ランダムテレポート"
	TitleText.Size = UDim2.new(1, -100, 1, 0)
	TitleText.Position = UDim2.new(0, 10, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.TextColor3 = Color3.fromRGB(230, 230, 230)
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextSize = 16
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar
	
	-- 最小化ボタン
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Text = "-"
	MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
	MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	MinimizeButton.Font = Enum.Font.GothamBold
	MinimizeButton.TextSize = 18
	MinimizeButton.TextScaled = true
	MinimizeButton.Parent = TitleBar
	
	local MinimizeCorner = Instance.new("UICorner")
	MinimizeCorner.CornerRadius = UDim.new(0, 8)
	MinimizeCorner.Parent = MinimizeButton
	
	-- 設定ボタン
	local SettingsButton = Instance.new("TextButton")
	SettingsButton.Name = "SettingsButton"
	SettingsButton.Text = "⚙"
	SettingsButton.Size = UDim2.new(0, 35, 0, 35)
	SettingsButton.Position = UDim2.new(1, -35, 0, 0)
	SettingsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SettingsButton.BorderSizePixel = 0
	SettingsButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	SettingsButton.Font = Enum.Font.Gotham
	SettingsButton.TextSize = 18
	SettingsButton.TextScaled = true
	SettingsButton.Parent = TitleBar
	
	local SettingsCorner = Instance.new("UICorner")
	SettingsCorner.CornerRadius = UDim.new(0, 8)
	SettingsCorner.Parent = SettingsButton
	
	-- スクロール可能なコンテンツエリア
	local Content = Instance.new("ScrollingFrame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, 0, 1, -35)
	Content.Position = UDim2.new(0, 0, 0, 35)
	Content.BackgroundTransparency = 1
	Content.BorderSizePixel = 0
	Content.ScrollBarThickness = 6
	Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Content.ScrollBarImageTransparency = 0.5
	Content.CanvasSize = UDim2.new(0, 0, 0, 450)
	Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Content.Parent = MainFrame
	
	-- プレイヤー選択セクション
	local PlayerSection = Instance.new("Frame")
	PlayerSection.Name = "PlayerSection"
	PlayerSection.Size = UDim2.new(1, -20, 0, 90)
	PlayerSection.Position = UDim2.new(0, 10, 0, 10)
	PlayerSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	PlayerSection.BorderSizePixel = 0
	PlayerSection.Parent = Content
	
	local PlayerSectionCorner = Instance.new("UICorner")
	PlayerSectionCorner.CornerRadius = UDim.new(0, 8)
	PlayerSectionCorner.Parent = PlayerSection
	
	local PlayerLabel = Instance.new("TextLabel")
	PlayerLabel.Text = "プレイヤー選択"
	PlayerLabel.Size = UDim2.new(1, -20, 0, 25)
	PlayerLabel.Position = UDim2.new(0, 10, 0, 5)
	PlayerLabel.BackgroundTransparency = 1
	PlayerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	PlayerLabel.Font = Enum.Font.GothamBold
	PlayerLabel.TextSize = 14
	PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
	PlayerLabel.Parent = PlayerSection
	
	-- プレイヤーボタンコンテナ
	local PlayersContainer = Instance.new("ScrollingFrame")
	PlayersContainer.Name = "PlayersContainer"
	PlayersContainer.Size = UDim2.new(1, -20, 0, 50)
	PlayersContainer.Position = UDim2.new(0, 10, 0, 35)
	PlayersContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	PlayersContainer.BorderSizePixel = 0
	PlayersContainer.ScrollBarThickness = 4
	PlayersContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	PlayersContainer.CanvasSize = UDim2.new(2, 0, 0, 0)
	PlayersContainer.Parent = PlayerSection
	
	local ContainerCorner = Instance.new("UICorner")
	ContainerCorner.CornerRadius = UDim.new(0, 6)
	ContainerCorner.Parent = PlayersContainer
	
	-- プレイヤーボタンのUIリスト
	local PlayersList = Instance.new("UIListLayout")
	PlayersList.FillDirection = Enum.FillDirection.Horizontal
	PlayersList.Padding = UDim.new(0, 5)
	PlayersList.SortOrder = Enum.SortOrder.LayoutOrder
	PlayersList.Parent = PlayersContainer
	
	-- 半径設定セクション
	local RadiusSection = Instance.new("Frame")
	RadiusSection.Name = "RadiusSection"
	RadiusSection.Size = UDim2.new(1, -20, 0, 90)
	RadiusSection.Position = UDim2.new(0, 10, 0, 110)
	RadiusSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	RadiusSection.BorderSizePixel = 0
	RadiusSection.Parent = Content
	
	local RadiusSectionCorner = Instance.new("UICorner")
	RadiusSectionCorner.CornerRadius = UDim.new(0, 8)
	RadiusSectionCorner.Parent = RadiusSection
	
	local RadiusLabel = Instance.new("TextLabel")
	RadiusLabel.Text = "テレポート半径 (5-10 スタッド)"
	RadiusLabel.Size = UDim2.new(1, -20, 0, 25)
	RadiusLabel.Position = UDim2.new(0, 10, 0, 5)
	RadiusLabel.BackgroundTransparency = 1
	RadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	RadiusLabel.Font = Enum.Font.Gotham
	RadiusLabel.TextSize = 14
	RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
	RadiusLabel.Parent = RadiusSection
	
	-- 半径スライダー
	local RadiusSlider = Instance.new("Frame")
	RadiusSlider.Name = "RadiusSlider"
	RadiusSlider.Size = UDim2.new(1, -20, 0, 25)
	RadiusSlider.Position = UDim2.new(0, 10, 0, 35)
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
	SliderButton.Size = UDim2.new(0, 25, 0, 25)
	SliderButton.Position = UDim2.new(0.5, -12.5, 0, 0)
	SliderButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	SliderButton.BorderSizePixel = 2
	SliderButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
	SliderButton.Text = ""
	SliderButton.AutoButtonColor = false
	SliderButton.Parent = RadiusSlider
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 12)
	ButtonCorner.Parent = SliderButton
	
	-- 半径値表示
	local RadiusValue = Instance.new("TextLabel")
	RadiusValue.Name = "RadiusValue"
	RadiusValue.Text = "7.5"
	RadiusValue.Size = UDim2.new(0, 60, 0, 25)
	RadiusValue.Position = UDim2.new(1, -70, 0, 60)
	RadiusValue.BackgroundTransparency = 1
	RadiusValue.TextColor3 = Color3.fromRGB(200, 200, 200)
	RadiusValue.Font = Enum.Font.GothamBold
	RadiusValue.TextSize = 16
	RadiusValue.TextXAlignment = Enum.TextXAlignment.Right
	RadiusValue.Parent = RadiusSection
	
	local StudsLabel = Instance.new("TextLabel")
	StudsLabel.Text = "スタッド"
	StudsLabel.Size = UDim2.new(0, 50, 0, 25)
	StudsLabel.Position = UDim2.new(1, -15, 0, 60)
	StudsLabel.BackgroundTransparency = 1
	StudsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	StudsLabel.Font = Enum.Font.Gotham
	StudsLabel.TextSize = 14
	StudsLabel.TextXAlignment = Enum.TextXAlignment.Left
	StudsLabel.Parent = RadiusSection
	
	-- テレポートボタン
	local TeleportButton = Instance.new("TextButton")
	TeleportButton.Name = "TeleportButton"
	TeleportButton.Text = "テレポート実行"
	TeleportButton.Size = UDim2.new(1, -20, 0, 55)
	TeleportButton.Position = UDim2.new(0, 10, 0, 210)
	TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
	TeleportButton.BorderSizePixel = 0
	TeleportButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	TeleportButton.Font = Enum.Font.GothamBold
	TeleportButton.TextSize = 18
	TeleportButton.TextScaled = true
	TeleportButton.Parent = Content
	
	local TeleportButtonCorner = Instance.new("UICorner")
	TeleportButtonCorner.CornerRadius = UDim.new(0, 10)
	TeleportButtonCorner.Parent = TeleportButton
	
	-- 状態表示ラベル
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Text = "準備完了"
	StatusLabel.Size = UDim2.new(1, -20, 0, 30)
	StatusLabel.Position = UDim2.new(0, 10, 0, 275)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 100)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.TextSize = 14
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
	StatusLabel.Parent = Content
	
	-- 設定フレーム
	local SettingsFrame = Instance.new("Frame")
	SettingsFrame.Name = "SettingsFrame"
	SettingsFrame.Visible = false
	SettingsFrame.Size = UDim2.new(0, 400, 0, 450)
	SettingsFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
	SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	SettingsFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	SettingsFrame.BorderSizePixel = 2
	SettingsFrame.Parent = ScreenGui
	
	local SettingsFrameCorner = Instance.new("UICorner")
	SettingsFrameCorner.CornerRadius = UDim.new(0, 12)
	SettingsFrameCorner.Parent = SettingsFrame
	
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
	CloseSettings.Font = Enum.Font.GothamBold
	CloseSettings.TextSize = 24
	CloseSettings.TextScaled = true
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
	SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 650)
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
	DelayLabel.Size = UDim2.new(1, -20, 0, 25)
	DelayLabel.Position = UDim2.new(0, 10, 0, 5)
	DelayLabel.BackgroundTransparency = 1
	DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	DelayLabel.Font = Enum.Font.GothamBold
	DelayLabel.TextSize = 14
	DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
	DelayLabel.Parent = DelaySection
	
	-- 遅延スライダー
	local DelaySlider = Instance.new("Frame")
	DelaySlider.Name = "DelaySlider"
	DelaySlider.Size = UDim2.new(1, -20, 0, 25)
	DelaySlider.Position = UDim2.new(0, 10, 0, 35)
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
	DelayButton.Size = UDim2.new(0, 25, 0, 25)
	DelayButton.Position = UDim2.new(0.5, -12.5, 0, 0)
	DelayButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	DelayButton.BorderSizePixel = 2
	DelayButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
	DelayButton.Text = ""
	DelayButton.AutoButtonColor = false
	DelayButton.Parent = DelaySlider
	
	local DelayButtonCorner = Instance.new("UICorner")
	DelayButtonCorner.CornerRadius = UDim.new(0, 12)
	DelayButtonCorner.Parent = DelayButton
	
	-- 遅延値表示
	local DelayValue = Instance.new("TextLabel")
	DelayValue.Name = "DelayValue"
	DelayValue.Text = "0.5"
	DelayValue.Size = UDim2.new(0, 60, 0, 25)
	DelayValue.Position = UDim2.new(1, -70, 0, 60)
	DelayValue.BackgroundTransparency = 1
	DelayValue.TextColor3 = Color3.fromRGB(200, 200, 200)
	DelayValue.Font = Enum.Font.GothamBold
	DelayValue.TextSize = 16
	DelayValue.TextXAlignment = Enum.TextXAlignment.Right
	DelayValue.Parent = DelaySection
	
	local SecondsLabel = Instance.new("TextLabel")
	SecondsLabel.Text = "秒"
	SecondsLabel.Size = UDim2.new(0, 30, 0, 25)
	SecondsLabel.Position = UDim2.new(1, -15, 0, 60)
	SecondsLabel.BackgroundTransparency = 1
	SecondsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	SecondsLabel.Font = Enum.Font.Gotham
	SecondsLabel.TextSize = 14
	SecondsLabel.TextXAlignment = Enum.TextXAlignment.Left
	SecondsLabel.Parent = DelaySection
	
	-- カスタム遅延入力
	local CustomDelay = Instance.new("Frame")
	CustomDelay.Name = "CustomDelay"
	CustomDelay.Size = UDim2.new(1, -20, 0, 130)
	CustomDelay.Position = UDim2.new(0, 10, 0, 120)
	CustomDelay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	CustomDelay.BorderSizePixel = 0
	CustomDelay.Parent = SettingsContent
	
	local CustomDelayCorner = Instance.new("UICorner")
	CustomDelayCorner.CornerRadius = UDim.new(0, 8)
	CustomDelayCorner.Parent = CustomDelay
	
	local CustomDelayLabel = Instance.new("TextLabel")
	CustomDelayLabel.Text = "カスタム遅延時間 (0.01-10秒)"
	CustomDelayLabel.Size = UDim2.new(1, -20, 0, 25)
	CustomDelayLabel.Position = UDim2.new(0, 10, 0, 5)
	CustomDelayLabel.BackgroundTransparency = 1
	CustomDelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	CustomDelayLabel.Font = Enum.Font.GothamBold
	CustomDelayLabel.TextSize = 14
	CustomDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
	CustomDelayLabel.Parent = CustomDelay
	
	local CustomDelayDesc = Instance.new("TextLabel")
	CustomDelayDesc.Text = "直接数値を入力してください:"
	CustomDelayDesc.Size = UDim2.new(1, -20, 0, 25)
	CustomDelayDesc.Position = UDim2.new(0, 10, 0, 35)
	CustomDelayDesc.BackgroundTransparency = 1
	CustomDelayDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
	CustomDelayDesc.Font = Enum.Font.Gotham
	CustomDelayDesc.TextSize = 12
	CustomDelayDesc.TextXAlignment = Enum.TextXAlignment.Left
	CustomDelayDesc.Parent = CustomDelay
	
	local InputBox = Instance.new("TextBox")
	InputBox.Name = "InputBox"
	InputBox.Size = UDim2.new(1, -20, 0, 35)
	InputBox.Position = UDim2.new(0, 10, 0, 65)
	InputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	InputBox.BorderSizePixel = 0
	InputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	InputBox.Font = Enum.Font.Gotham
	InputBox.TextSize = 16
	InputBox.PlaceholderText = "例: 0.05 または 2.5"
	InputBox.ClearTextOnFocus = false
	InputBox.Text = ""
	InputBox.Parent = CustomDelay
	
	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 8)
	InputCorner.Parent = InputBox
	
	local ApplyButton = Instance.new("TextButton")
	ApplyButton.Name = "ApplyButton"
	ApplyButton.Text = "適用"
	ApplyButton.Size = UDim2.new(0.5, -15, 0, 35)
	ApplyButton.Position = UDim2.new(0, 10, 0, 105)
	ApplyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
	ApplyButton.BorderSizePixel = 0
	ApplyButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	ApplyButton.Font = Enum.Font.GothamBold
	ApplyButton.TextSize = 16
	ApplyButton.TextScaled = true
	ApplyButton.Parent = CustomDelay
	
	local ApplyCorner = Instance.new("UICorner")
	ApplyCorner.CornerRadius = UDim.new(0, 8)
	ApplyCorner.Parent = ApplyButton
	
	-- プレイヤーリストの更新ボタン
	local RefreshButton = Instance.new("TextButton")
	RefreshButton.Name = "RefreshButton"
	RefreshButton.Text = "↻ 更新"
	RefreshButton.Size = UDim2.new(0.5, -15, 0, 35)
	RefreshButton.Position = UDim2.new(0.5, 5, 0, 105)
	RefreshButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
	RefreshButton.BorderSizePixel = 0
	RefreshButton.TextColor3 = Color3.fromRGB(230, 230, 230)
	RefreshButton.Font = Enum.Font.GothamBold
	RefreshButton.TextSize = 16
	RefreshButton.TextScaled = true
	RefreshButton.Parent = CustomDelay
	
	local RefreshCorner = Instance.new("UICorner")
	RefreshCorner.CornerRadius = UDim.new(0, 8)
	RefreshCorner.Parent = RefreshButton
	
	-- UIを最前面に
	ScreenGui.DisplayOrder = 100
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	
	return ScreenGui, {
		MainFrame = MainFrame,
		TitleBar = TitleBar,
		MinimizeButton = MinimizeButton,
		SettingsButton = SettingsButton,
		TeleportButton = TeleportButton,
		StatusLabel = StatusLabel,
		RadiusSlider = RadiusSlider,
		RadiusValue = RadiusValue,
		PlayersContainer = PlayersContainer,
		SettingsFrame = SettingsFrame,
		CloseSettings = CloseSettings,
		DelaySlider = DelaySlider,
		DelayValue = DelayValue,
		CustomDelay = CustomDelay,
		CustomDelayInput = InputBox,
		ApplyButton = ApplyButton,
		RefreshButton = RefreshButton
	}
end

-- UIを作成
local UI = CreateUI()
local Elements = UI[2]

-- プレイヤーボタンの作成
local PlayerButtons = {}

local function CreatePlayerButton(player)
	local button = Instance.new("TextButton")
	button.Name = player.Name
	button.Text = player.Name
	button.Size = UDim2.new(0, 80, 0, 40)
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(230, 230, 230)
	button.Font = Enum.Font.Gotham
	button.TextSize = 12
	button.TextScaled = true
	button.AutoButtonColor = false
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	-- ボタンの状態を更新
	local function UpdateButtonState()
		if Settings.SelectedPlayer == player then
			button.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			button.TextColor3 = Color3.fromRGB(230, 230, 230)
		end
	end
	
	-- ボタンクリックイベント
	button.MouseButton1Click:Connect(function()
		if Settings.SelectedPlayer == player then
			Settings.SelectedPlayer = nil
		else
			Settings.SelectedPlayer = player
		end
		UpdateButtonState()
		
		-- ステータス更新
		if Settings.SelectedPlayer then
			Elements.StatusLabel.Text = "選択: " .. player.Name
			Elements.StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
		else
			Elements.StatusLabel.Text = "自分自身を選択中"
			Elements.StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 100)
		end
	end)
	
	UpdateButtonState()
	button.Parent = Elements.PlayersContainer
	PlayerButtons[player] = button
	
	return button
end

-- プレイヤーリストの更新
local function UpdatePlayerList()
	-- 既存のボタンをクリア
	for _, button in pairs(Elements.PlayersContainer:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
	PlayerButtons = {}
	
	-- 自分のボタンを作成
	local selfButton = Instance.new("TextButton")
	selfButton.Name = Player.Name
	selfButton.Text = "自分 (" .. Player.Name .. ")"
	selfButton.Size = UDim2.new(0, 100, 0, 40)
	selfButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
	selfButton.BorderSizePixel = 0
	selfButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	selfButton.Font = Enum.Font.GothamBold
	selfButton.TextSize = 12
	selfButton.TextScaled = true
	selfButton.AutoButtonColor = false
	
	local selfCorner = Instance.new("UICorner")
	selfCorner.CornerRadius = UDim.new(0, 6)
	selfCorner.Parent = selfButton
	
	selfButton.MouseButton1Click:Connect(function()
		Settings.SelectedPlayer = nil
		Elements.StatusLabel.Text = "自分自身を選択中"
		Elements.StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 100)
		
		-- 他のボタンの状態をリセット
		for _, btn in pairs(PlayerButtons) do
			btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			btn.TextColor3 = Color3.fromRGB(230, 230, 230)
		end
		
		-- 自分のボタンは選択状態を維持
		selfButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
		selfButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	
	selfButton.Parent = Elements.PlayersContainer
	
	-- 他のプレイヤーのボタンを作成
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Player then
			CreatePlayerButton(player)
		end
	end
	
	-- コンテナサイズを調整
	local totalWidth = 0
	for _, child in pairs(Elements.PlayersContainer:GetChildren()) do
		if child:IsA("TextButton") then
			totalWidth = totalWidth + child.AbsoluteSize.X + 5
		end
	end
	
	Elements.PlayersContainer.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
end

-- UIドラッグ機能（修正版）
local function MakeDraggable(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos
	
	-- 入力開始
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			-- ドラッグ中は入力キャプチャ
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	-- 入力変更
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	-- 入力変更（グローバル）
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- スライダー作成関数（修正版）
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
		
		-- ボタン位置更新
		button.Position = UDim2.new(percent, -12.5, 0, 0)
		
		-- コールバック実行
		if callback then
			callback(value)
		end
		
		return value
	end
	
	-- 初期値設定
	UpdateValue(defaultValue)
	
	-- スライダークリック
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			percent = math.clamp(percent, 0, 1)
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	slider.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	
	-- ボタンドラッグ
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
	
	-- マウス移動でドラッグ
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
			percent = math.clamp(percent, 0, 1)
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	return {
		Update = UpdateValue,
		GetValue = function() return tonumber(valueLabel.Text) end
	}
end

-- メインテレポート関数
local function TeleportPlayer(targetPlayer, radius, delayTime)
	if Settings.IsTeleporting then
		return false, "既にテレポート中です"
	end
	
	Settings.IsTeleporting = true
	
	-- ターゲットプレイヤー決定
	local teleportTarget = targetPlayer or Player
	local targetCharacter = teleportTarget.Character
	
	if not targetCharacter then
		Settings.IsTeleporting = false
		return false, "キャラクターが見つかりません"
	end
	
	local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		Settings.IsTeleporting = false
		return false, "HumanoidRootPartが見つかりません"
	end
	
	-- ステータス更新
	Elements.StatusLabel.Text = "テレポート準備中..."
	Elements.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	
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
	local rayDirection = Vector3.new(0, -20, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {targetCharacter}
	
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
	
	Settings.IsTeleporting = false
	return true, "テレポート成功！"
end

-- UI初期化
MakeDraggable(Elements.MainFrame, Elements.TitleBar)
MakeDraggable(Elements.SettingsFrame, Elements.SettingsHeader)

-- スライダー設定
local radiusControl = SetupSlider(Elements.RadiusSlider, Elements.RadiusValue, 5, 10, 7.5, function(value)
	Settings.Radius = value
end)

local delayControl = SetupSlider(Elements.DelaySlider, Elements.DelayValue, 0.1, 1, 0.5, function(value)
	Settings.Delay = value
end)

-- テレポートボタン
Elements.TeleportButton.MouseButton1Click:Connect(function()
	if Settings.IsTeleporting then
		Elements.StatusLabel.Text = "既にテレポート中です"
		Elements.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end
	
	-- ボタンの視覚的フィードバック
	Elements.TeleportButton.Text = "テレポート中..."
	Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	
	-- テレポート実行
	local success, message = TeleportPlayer(Settings.SelectedPlayer, Settings.Radius, Settings.Delay)
	
	-- 結果に応じたフィードバック
	if success then
		Elements.TeleportButton.Text = "成功！"
		Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
		Elements.StatusLabel.Text = message .. " (" .. Settings.Radius .. "スタッド)"
		Elements.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		
		-- 成功エフェクト
		local tween = TweenService:Create(Elements.TeleportButton, TweenInfo.new(0.3), {
			BackgroundColor3 = Color3.fromRGB(50, 100, 200)
		})
		tween:Play()
		
		task.wait(0.8)
	else
		Elements.TeleportButton.Text = "失敗"
		Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		Elements.StatusLabel.Text = message
		Elements.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		
		task.wait(1)
	end
	
	Elements.TeleportButton.Text = "テレポート実行"
	Elements.TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
end)

-- 最小化ボタン
local isMinimized = false
Elements.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	
	if isMinimized then
		Elements.MainFrame.Size = UDim2.new(0, 350, 0, 35)
		Elements.MinimizeButton.Text = "+"
	else
		Elements.MainFrame.Size = UDim2.new(0, 350, 0, 250)
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
		
		Elements.StatusLabel.Text = "遅延時間を " .. delayTime .. " 秒に設定"
		Elements.StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	end
end)

-- プレイヤーリスト更新ボタン
Elements.RefreshButton.MouseButton1Click:Connect(function()
	UpdatePlayerList()
	Elements.StatusLabel.Text = "プレイヤーリストを更新しました"
	Elements.StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	
	-- ボタンの視覚的フィードバック
	local originalColor = Elements.RefreshButton.BackgroundColor3
	Elements.RefreshButton.BackgroundColor3 = Color3.fromRGB(120, 220, 150)
	task.wait(0.2)
	Elements.RefreshButton.BackgroundColor3 = originalColor
end)

-- エンターキーで適用
Elements.CustomDelayInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		Elements.ApplyButton:Activate()
	end
end)

-- プレイヤー参加/退出の監視
Players.PlayerAdded:Connect(function(player)
	CreatePlayerButton(player)
	Elements.StatusLabel.Text = player.Name .. " が参加しました"
	Elements.StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
end)

Players.PlayerRemoving:Connect(function(player)
	if PlayerButtons[player] then
		PlayerButtons[player]:Destroy()
		PlayerButtons[player] = nil
		
		if Settings.SelectedPlayer == player then
			Settings.SelectedPlayer = nil
			Elements.StatusLabel.Text = "選択解除: " .. player.Name .. " が退出"
			Elements.StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
		end
	end
end)

-- 初期プレイヤーリスト作成
UpdatePlayerList()

-- キーバインド（オプション）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Tキーでテレポート
	if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		Elements.TeleportButton:Activate()
	end
	
	-- Rキーでリスト更新
	if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		Elements.RefreshButton:Activate()
	end
end)

print("360° ランダムテレポートUIが読み込まれました！")
print("半径: " .. Settings.Radius .. " スタッド, 遅延: " .. Settings.Delay .. " 秒")
print("Ctrl+T: テレポート, Ctrl+R: プレイヤーリスト更新")
