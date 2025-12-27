-- プレイヤー周囲360°ランダムテレポートシステム (クライアントサイド)
-- StarterGui以下にScreenGuiを作成し、その中にこのLocalScriptを配置してください。

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- UI構築関数
local function CreateUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TeleportUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- メインフレーム
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 300, 0, 200)
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150) -- 薄白の枠線
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

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = "360° ランダムテレポート"
	TitleLabel.Size = UDim2.new(1, -60, 1, 0)
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	TitleLabel.Font = Enum.Font.Gotham
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar

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

	-- コンテンツエリア (スクロール可能)
	local ContentScrollingFrame = Instance.new("ScrollingFrame")
	ContentScrollingFrame.Name = "Content"
	ContentScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
	ContentScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
	ContentScrollingFrame.BackgroundTransparency = 1
	ContentScrollingFrame.BorderSizePixel = 0
	ContentScrollingFrame.ScrollBarThickness = 6
	ContentScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	ContentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
	ContentScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ContentScrollingFrame.Parent = MainFrame

	-- 半径スライダーセクション
	local RadiusSection = Instance.new("Frame")
	RadiusSection.Name = "RadiusSection"
	RadiusSection.Size = UDim2.new(1, -20, 0, 80)
	RadiusSection.Position = UDim2.new(0, 10, 0, 10)
	RadiusSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	RadiusSection.BorderSizePixel = 0
	RadiusSection.Parent = ContentScrollingFrame

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

	local RadiusSliderFrame = Instance.new("Frame")
	RadiusSliderFrame.Name = "RadiusSlider"
	RadiusSliderFrame.Size = UDim2.new(1, -20, 0, 20)
	RadiusSliderFrame.Position = UDim2.new(0, 10, 0, 30)
	RadiusSliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	RadiusSliderFrame.BorderSizePixel = 0
	RadiusSliderFrame.Parent = RadiusSection

	local RadiusSliderCorner = Instance.new("UICorner")
	RadiusSliderCorner.CornerRadius = UDim.new(0, 10)
	RadiusSliderCorner.Parent = RadiusSliderFrame

	local RadiusFill = Instance.new("Frame")
	RadiusFill.Name = "Fill"
	RadiusFill.Size = UDim2.new(0.5, 0, 1, 0)
	RadiusFill.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
	RadiusFill.BorderSizePixel = 0
	RadiusFill.Parent = RadiusSliderFrame

	local RadiusFillCorner = Instance.new("UICorner")
	RadiusFillCorner.CornerRadius = UDim.new(0, 10)
	RadiusFillCorner.Parent = RadiusFill

	local RadiusButton = Instance.new("TextButton")
	RadiusButton.Name = "Button"
	RadiusButton.Size = UDim2.new(0, 20, 0, 20)
	RadiusButton.Position = UDim2.new(0.5, -10, 0, 0)
	RadiusButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
	RadiusButton.BorderSizePixel = 2
	RadiusButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
	RadiusButton.Text = ""
	RadiusButton.Parent = RadiusSliderFrame

	local RadiusButtonCorner = Instance.new("UICorner")
	RadiusButtonCorner.CornerRadius = UDim.new(0, 10)
	RadiusButtonCorner.Parent = RadiusButton

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

	local RadiusUnit = Instance.new("TextLabel")
	RadiusUnit.Text = "スタッド"
	RadiusUnit.Size = UDim2.new(0, 40, 0, 20)
	RadiusUnit.Position = UDim2.new(1, -15, 0, 55)
	RadiusUnit.BackgroundTransparency = 1
	RadiusUnit.TextColor3 = Color3.fromRGB(150, 150, 150)
	RadiusUnit.Font = Enum.Font.Gotham
	RadiusUnit.TextSize = 12
	RadiusUnit.TextXAlignment = Enum.TextXAlignment.Left
	RadiusUnit.Parent = RadiusSection

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
	TeleportButton.Parent = ContentScrollingFrame

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
	Description.Parent = ContentScrollingFrame

	local DescriptionCorner = Instance.new("UICorner")
	DescriptionCorner.CornerRadius = UDim.new(0, 8)
	DescriptionCorner.Parent = Description

	-- 設定フレーム (最初は非表示)
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

	local SettingsHeaderCorner = Instance.new("UICorner")
	SettingsHeaderCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	SettingsHeaderCorner.Parent = SettingsHeader

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

	-- 設定コンテンツ (スクロール可能)
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

	-- 遅延時間スライダーセクション
	local DelaySection = Instance.new("Frame")
	DelaySection.Name = "DelaySection"
	DelaySection.Size = UDim2.new(1, -20, 0, 100)
	DelaySection.Position = UDim2.new(0, 10, 0, 10)
	DelaySection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	DelaySection.BorderSizePixel = 0
	DelaySection.Parent = SettingsContent

	local DelaySectionCorner = Instance.new("UICorner")
	DelaySectionCorner.CornerRadius = UDim.new(0, 8)
	DelaySectionCorner.Parent = DelaySection

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

	local DelaySliderFrame = Instance.new("Frame")
	DelaySliderFrame.Name = "DelaySlider"
	DelaySliderFrame.Size = UDim2.new(1, -20, 0, 20)
	DelaySliderFrame.Position = UDim2.new(0, 10, 0, 30)
	DelaySliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	DelaySliderFrame.BorderSizePixel = 0
	DelaySliderFrame.Parent = DelaySection

	local DelaySliderCorner = Instance.new("UICorner")
	DelaySliderCorner.CornerRadius = UDim.new(0, 10)
	DelaySliderCorner.Parent = DelaySliderFrame

	local DelayFill = Instance.new("Frame")
	DelayFill.Name = "Fill"
	DelayFill.Size = UDim2.new(0.5, 0, 1, 0)
	DelayFill.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
	DelayFill.BorderSizePixel = 0
	DelayFill.Parent = DelaySliderFrame

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
	DelayButton.Parent = DelaySliderFrame

	local DelayButtonCorner = Instance.new("UICorner")
	DelayButtonCorner.CornerRadius = UDim.new(0, 10)
	DelayButtonCorner.Parent = DelayButton

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

	local DelayUnit = Instance.new("TextLabel")
	DelayUnit.Text = "秒"
	DelayUnit.Size = UDim2.new(0, 20, 0, 20)
	DelayUnit.Position = UDim2.new(1, -15, 0, 55)
	DelayUnit.BackgroundTransparency = 1
	DelayUnit.TextColor3 = Color3.fromRGB(150, 150, 150)
	DelayUnit.Font = Enum.Font.Gotham
	DelayUnit.TextSize = 12
	DelayUnit.TextXAlignment = Enum.TextXAlignment.Left
	DelayUnit.Parent = DelaySection

	-- カスタム遅延時間入力セクション
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

	local CustomDelayInstruction = Instance.new("TextLabel")
	CustomDelayInstruction.Text = "直接数値を入力してください:"
	CustomDelayInstruction.Size = UDim2.new(1, -20, 0, 20)
	CustomDelayInstruction.Position = UDim2.new(0, 10, 0, 30)
	CustomDelayInstruction.BackgroundTransparency = 1
	CustomDelayInstruction.TextColor3 = Color3.fromRGB(180, 180, 180)
	CustomDelayInstruction.Font = Enum.Font.Gotham
	CustomDelayInstruction.TextSize = 11
	CustomDelayInstruction.TextXAlignment = Enum.TextXAlignment.Left
	CustomDelayInstruction.Parent = CustomDelay

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

	local InputBoxCorner = Instance.new("UICorner")
	InputBoxCorner.CornerRadius = UDim.new(0, 6)
	InputBoxCorner.Parent = InputBox

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

	local ApplyButtonCorner = Instance.new("UICorner")
	ApplyButtonCorner.CornerRadius = UDim.new(0, 6)
	ApplyButtonCorner.Parent = ApplyButton

	-- 説明セクション
	local Instructions = Instance.new("Frame")
	Instructions.Name = "Instructions"
	Instructions.Size = UDim2.new(1, -20, 0, 180)
	Instructions.Position = UDim2.new(0, 10, 0, 250)
	Instructions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instructions.BorderSizePixel = 0
	Instructions.Parent = SettingsContent

	local InstructionsCorner = Instance.new("UICorner")
	InstructionsCorner.CornerRadius = UDim.new(0, 8)
	InstructionsCorner.Parent = Instructions

	local InstructionsTitle = Instance.new("TextLabel")
	InstructionsTitle.Text = "使い方説明"
	InstructionsTitle.Size = UDim2.new(1, -20, 0, 30)
	InstructionsTitle.Position = UDim2.new(0, 10, 0, 5)
	InstructionsTitle.BackgroundTransparency = 1
	InstructionsTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
	InstructionsTitle.Font = Enum.Font.GothamBold
	InstructionsTitle.TextSize = 16
	InstructionsTitle.TextXAlignment = Enum.TextXAlignment.Left
	InstructionsTitle.Parent = Instructions

	local Instruction1 = Instance.new("TextLabel")
	Instruction1.Text = "1. 半径スライダーでテレポート範囲を設定 (5-10スタッド)"
	Instruction1.Size = UDim2.new(1, -20, 0, 20)
	Instruction1.Position = UDim2.new(0, 10, 0, 40)
	Instruction1.BackgroundTransparency = 1
	Instruction1.TextColor3 = Color3.fromRGB(200, 200, 200)
	Instruction1.Font = Enum.Font.Gotham
	Instruction1.TextSize = 12
	Instruction1.TextXAlignment = Enum.TextXAlignment.Left
	Instruction1.TextWrapped = true
	Instruction1.Parent = Instructions

	local Instruction2 = Instance.new("TextLabel")
	Instruction2.Text = "2. 設定で遅延時間を調整 (0.1-1秒)"
	Instruction2.Size = UDim2.new(1, -20, 0, 20)
	Instruction2.Position = UDim2.new(0, 10, 0, 65)
	Instruction2.BackgroundTransparency = 1
	Instruction2.TextColor3 = Color3.fromRGB(200, 200, 200)
	Instruction2.Font = Enum.Font.Gotham
	Instruction2.TextSize = 12
	Instruction2.TextXAlignment = Enum.TextXAlignment.Left
	Instruction2.TextWrapped = true
	Instruction2.Parent = Instructions

	local Instruction3 = Instance.new("TextLabel")
	Instruction3.Text = "3. カスタム遅延で0.01-10秒の任意の値を設定可能"
	Instruction3.Size = UDim2.new(1, -20, 0, 20)
	Instruction3.Position = UDim2.new(0, 10, 0, 90)
	Instruction3.BackgroundTransparency = 1
	Instruction3.TextColor3 = Color3.fromRGB(200, 200, 200)
	Instruction3.Font = Enum.Font.Gotham
	Instruction3.TextSize = 12
	Instruction3.TextXAlignment = Enum.TextXAlignment.Left
	Instruction3.TextWrapped = true
	Instruction3.Parent = Instructions

	local Instruction4 = Instance.new("TextLabel")
	Instruction4.Text = "4. テレポートボタンで実行"
	Instruction4.Size = UDim2.new(1, -20, 0, 20)
	Instruction4.Position = UDim2.new(0, 10, 0, 115)
	Instruction4.BackgroundTransparency = 1
	Instruction4.TextColor3 = Color3.fromRGB(200, 200, 200)
	Instruction4.Font = Enum.Font.Gotham
	Instruction4.TextSize = 12
	Instruction4.TextXAlignment = Enum.TextXAlignment.Left
	Instruction4.TextWrapped = true
	Instruction4.Parent = Instructions

	local Note = Instance.new("TextLabel")
	Note.Text = "※ テレポートはプレイヤーを中心とした円形ランダム位置です"
	Note.Size = UDim2.new(1, -20, 0, 30)
	Note.Position = UDim2.new(0, 10, 0, 140)
	Note.BackgroundTransparency = 1
	Note.TextColor3 = Color3.fromRGB(180, 180, 180)
	Note.Font = Enum.Font.Gotham
	Note.TextSize = 11
	Note.TextXAlignment = Enum.TextXAlignment.Left
	Note.TextWrapped = true
	Note.Parent = Instructions

	return ScreenGui, {
		MainFrame = MainFrame,
		TitleBar = TitleBar,
		MinimizeButton = MinimizeButton,
		SettingsButton = SettingsButton,
		ContentScrollingFrame = ContentScrollingFrame,
		TeleportButton = TeleportButton,
		RadiusSliderFrame = RadiusSliderFrame,
		RadiusFill = RadiusFill,
		RadiusButton = RadiusButton,
		RadiusValue = RadiusValue,
		SettingsFrame = SettingsFrame,
		CloseSettings = CloseSettings,
		DelaySliderFrame = DelaySliderFrame,
		DelayFill = DelayFill,
		DelayButton = DelayButton,
		DelayValue = DelayValue,
		InputBox = InputBox,
		ApplyButton = ApplyButton
	}
end

-- UIの作成
local ScreenGui, UI = CreateUI()
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- 設定値
local Settings = {
	Radius = 7.5,
	Delay = 0.5
}

-- ドラッグ機能
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
	end
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			Update(input)
		end
	end)
end

-- スライダー機能
local function SetupSlider(sliderFrame, fill, button, valueLabel, min, max, defaultValue, callback)
	local isDragging = false
	
	local function UpdateValue(value)
		value = math.clamp(value, min, max)
		local percent = (value - min) / (max - min)
		
		-- UIの更新
		fill.Size = UDim2.new(percent, 0, 1, 0)
		button.Position = UDim2.new(percent, -10, 0, 0)
		valueLabel.Text = string.format("%.2f", value)
		
		-- コールバックの実行
		if callback then
			callback(value)
		end
		
		return value
	end
	
	-- 初期値の設定
	UpdateValue(defaultValue)
	
	-- マウス操作
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
	
	sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			local percent = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
			local value = min + (percent * (max - min))
			UpdateValue(value)
		end
	end)
	
	return {
		Update = UpdateValue,
		GetValue = function() return tonumber(valueLabel.Text) end
	}
end

-- テレポート関数
local function TeleportPlayer(radius, delayTime)
	-- キャラクターの取得
	local Character = Player.Character
	if not Character then return false end
	
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then return false end
	
	-- 遅延の適用
	if delayTime and delayTime > 0 then
		task.wait(delayTime)
	end
	
	-- ランダムな角度を生成 (0-360度)
	local randomAngle = math.random() * 2 * math.pi
	
	-- 円形の座標を計算
	local offsetX = math.cos(randomAngle) * radius
	local offsetZ = math.sin(randomAngle) * radius
	
	-- 現在位置からオフセットを加算
	local currentPosition = HumanoidRootPart.Position
	local newPosition = Vector3.new(
		currentPosition.X + offsetX,
		currentPosition.Y, -- Y軸は変更しない
		currentPosition.Z + offsetZ
	)
	
	-- 地面検出のためのRaycast
	local rayOrigin = Vector3.new(newPosition.X, currentPosition.Y + 10, newPosition.Z)
	local rayDirection = Vector3.new(0, -20, 0)
	
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
	else
		-- Raycastが失敗した場合はYを維持
		newPosition = Vector3.new(newPosition.X, currentPosition.Y, newPosition.Z)
	end
	
	-- テレポートの実行
	HumanoidRootPart.CFrame = CFrame.new(newPosition)
	
	return true
end

-- UIの初期化
MakeDraggable(UI.MainFrame, UI.TitleBar)

-- 半径スライダーの設定
local radiusControl = SetupSlider(
	UI.RadiusSliderFrame,
	UI.RadiusFill,
	UI.RadiusButton,
	UI.RadiusValue,
	5, 10, 7.5,
	function(value)
		Settings.Radius = value
	end
)

-- 遅延スライダーの設定
local delayControl = SetupSlider(
	UI.DelaySliderFrame,
	UI.DelayFill,
	UI.DelayButton,
	UI.DelayValue,
	0.1, 1, 0.5,
	function(value)
		Settings.Delay = value
	end
)

-- テレポートボタンのイベント
UI.TeleportButton.MouseButton1Click:Connect(function()
	UI.TeleportButton.Text = "テレポート中..."
	UI.TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	
	-- テレポートの実行
	local success = TeleportPlayer(Settings.Radius, Settings.Delay)
	
	if success then
		print("テレポート成功！ 半径: " .. Settings.Radius .. ", 遅延: " .. Settings.Delay)
	else
		warn("テレポートに失敗しました")
	end
	
	task.wait(0.5)
	
	UI.TeleportButton.Text = "テレポート!"
	UI.TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- 最小化ボタン
local isMinimized = false
UI.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	
	if isMinimized then
		UI.MainFrame.Size = UDim2.new(0, 300, 0, 40)
		UI.MinimizeButton.Text = "+"
	else
		UI.MainFrame.Size = UDim2.new(0, 300, 0, 200)
		UI.MinimizeButton.Text = "-"
	end
end)

-- 設定ボタン
UI.SettingsButton.MouseButton1Click:Connect(function()
	UI.SettingsFrame.Visible = true
end)

-- 設定を閉じる
UI.CloseSettings.MouseButton1Click:Connect(function()
	UI.SettingsFrame.Visible = false
end)

-- カスタム遅延時間の適用
UI.ApplyButton.MouseButton1Click:Connect(function()
	local inputText = UI.InputBox.Text
	local delayTime = tonumber(inputText)
	
	if delayTime then
		delayTime = math.clamp(delayTime, 0.01, 10)
		delayControl.Update(delayTime)
		UI.InputBox.Text = ""
	end
end)

-- エンターキーでも適用
UI.InputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		UI.ApplyButton:Activate()
	end
end)

-- キャラクターの変更に対応
Player.CharacterAdded:Connect(function(character)
	Character = character
	HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)
