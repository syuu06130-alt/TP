-- Orion UIライブラリの読み込み
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- ウィンドウの作成
local Window = OrionLib:MakeWindow({
    Name = "360° ランダムテレポート",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TeleportConfig",
    IntroEnabled = true,
    IntroText = "テレポートスクリプト"
})

-- サービスの取得
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- 設定値
local Settings = {
    Radius = 7.5,
    Delay = 0.1,
    TeleportCount = 1,
    SelectedPlayer = nil,  -- nil = 自分自身
    IsTeleporting = false,
    AutoTeleport = false,
    TeleportInterval = 1.0
}

-- プレイヤー関連関数
local function GetPlayerList()
    local playerList = {"自分"}
    local currentPlayers = Players:GetPlayers()
    
    for _, player in pairs(currentPlayers) do
        if player ~= Players.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    
    return playerList
end

local function UpdateSelectedPlayer(playerName)
    if playerName == "自分" or playerName == "" then
        Settings.SelectedPlayer = nil
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == playerName then
            Settings.SelectedPlayer = player
            return
        end
    end
end

-- テレポート機能
local function TeleportToRandomPosition()
    if Settings.IsTeleporting then return end
    
    local targetPlayer = Settings.SelectedPlayer or Players.LocalPlayer
    local character = targetPlayer.Character
    
    if not character then
        OrionLib:MakeNotification({
            Name = "エラー",
            Content = "キャラクターが見つかりません",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        return false
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        OrionLib:MakeNotification({
            Name = "エラー",
            Content = "HumanoidRootPartが見つかりません",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        return false
    end
    
    -- ランダムな角度を生成
    local angle = math.rad(math.random(0, 360))
    local offset = Vector3.new(
        math.cos(angle) * Settings.Radius,
        0,
        math.sin(angle) * Settings.Radius
    )
    
    local newPosition = humanoidRootPart.Position + offset
    
    -- 地面の検出
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = Workspace:Raycast(
        newPosition + Vector3.new(0, 50, 0),
        Vector3.new(0, -100, 0),
        raycastParams
    )
    
    if raycastResult then
        newPosition = Vector3.new(newPosition.X, raycastResult.Position.Y + 3, newPosition.Z)
    end
    
    -- テレポート実行
    Settings.IsTeleporting = true
    
    if Settings.Delay > 0 then
        task.wait(Settings.Delay)
    end
    
    humanoidRootPart.CFrame = CFrame.new(newPosition)
    
    Settings.IsTeleporting = false
    return true
end

-- 自動テレポート機能
local autoTeleportConnection
local function ToggleAutoTeleport()
    Settings.AutoTeleport = not Settings.AutoTeleport
    
    if autoTeleportConnection then
        autoTeleportConnection:Disconnect()
        autoTeleportConnection = nil
    end
    
    if Settings.AutoTeleport then
        autoTeleportConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            if not Settings.IsTeleporting then
                TeleportToRandomPosition()
                task.wait(Settings.TeleportInterval)
            end
        end)
        
        OrionLib:MakeNotification({
            Name = "自動テレポート",
            Content = "自動テレポートを開始しました",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    else
        OrionLib:MakeNotification({
            Name = "自動テレポート",
            Content = "自動テレポートを停止しました",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
end

-- タブの作成
local MainTab = Window:MakeTab({
    Name = "メイン機能",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "設定",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualTab = Window:MakeTab({
    Name = "視覚効果",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- メイン機能タブ
MainTab:AddSection({
    Name = "プレイヤー選択"
})

local PlayerDropdown = MainTab:AddDropdown({
    Name = "テレポート対象",
    Default = "自分",
    Options = GetPlayerList(),
    Callback = function(value)
        UpdateSelectedPlayer(value)
    end
})

-- プレイヤーリストの更新
game:GetService("Players").PlayerAdded:Connect(function()
    PlayerDropdown:Refresh(GetPlayerList())
end)

game:GetService("Players").PlayerRemoving:Connect(function()
    task.wait(0.1)
    PlayerDropdown:Refresh(GetPlayerList())
end)

MainTab:AddSection({
    Name = "テレポート制御"
})

MainTab:AddButton({
    Name = "1回テレポート",
    Callback = function()
        local success = TeleportToRandomPosition()
        if success then
            OrionLib:MakeNotification({
                Name = "成功",
                Content = "テレポートを実行しました",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

MainTab:AddButton({
    Name = "複数回テレポート",
    Callback = function()
        for i = 1, Settings.TeleportCount do
            TeleportToRandomPosition()
            if i < Settings.TeleportCount then
                task.wait(0.1)
            end
        end
        OrionLib:MakeNotification({
            Name = "成功",
            Content = string.format("%d回テレポートを実行しました", Settings.TeleportCount),
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

MainTab:AddToggle({
    Name = "自動テレポート",
    Default = false,
    Callback = function(value)
        Settings.AutoTeleport = value
        if value then
            ToggleAutoTeleport()
        elseif autoTeleportConnection then
            autoTeleportConnection:Disconnect()
            autoTeleportConnection = nil
        end
    end
})

-- 設定タブ
SettingsTab:AddSection({
    Name = "基本設定"
})

SettingsTab:AddSlider({
    Name = "テレポート半径",
    Min = 1,
    Max = 50,
    Default = 7.5,
    Color = Color3.fromRGB(80, 120, 200),
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(value)
        Settings.Radius = value
    end
})

SettingsTab:AddSlider({
    Name = "テレポート遅延",
    Min = 0,
    Max = 5,
    Default = 0.1,
    Color = Color3.fromRGB(80, 120, 200),
    Increment = 0.1,
    ValueName = "秒",
    Callback = function(value)
        Settings.Delay = value
    end
})

SettingsTab:AddSlider({
    Name = "自動テレポート間隔",
    Min = 0.1,
    Max = 5,
    Default = 1.0,
    Color = Color3.fromRGB(80, 120, 200),
    Increment = 0.1,
    ValueName = "秒",
    Callback = function(value)
        Settings.TeleportInterval = value
    end
})

SettingsTab:AddSlider({
    Name = "複数テレポート回数",
    Min = 1,
    Max = 50,
    Default = 1,
    Color = Color3.fromRGB(80, 120, 200),
    Increment = 1,
    ValueName = "回",
    Callback = function(value)
        Settings.TeleportCount = value
    end
})

-- 視覚効果タブ
VisualTab:AddSection({
    Name = "テレポート効果"
})

local showParticle = false
local particleFolder

VisualTab:AddToggle({
    Name = "テレポートエフェクト表示",
    Default = false,
    Callback = function(value)
        showParticle = value
        if not value and particleFolder then
            particleFolder:Destroy()
            particleFolder = nil
        end
    end
})

VisualTab:AddColorpicker({
    Name = "エフェクト色",
    Default = Color3.fromRGB(0, 170, 255),
    Callback = function(value)
        if particleFolder then
            for _, particle in pairs(particleFolder:GetChildren()) do
                if particle:IsA("ParticleEmitter") then
                    particle.Color = ColorSequence.new(value)
                end
            end
        end
    end
})

-- テレポート時のエフェクト関数
local function CreateTeleportEffect(position)
    if not showParticle then return end
    
    if particleFolder then
        particleFolder:Destroy()
    end
    
    particleFolder = Instance.new("Folder")
    particleFolder.Name = "TeleportEffects"
    particleFolder.Parent = Workspace
    
    -- パーティクルエフェクト
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = particleFolder
    particle.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0)
    })
    particle.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    particle.Lifetime = NumberRange.new(1, 2)
    particle.Rate = 50
    particle.Rotation = NumberRange.new(0, 360)
    particle.RotSpeed = NumberRange.new(-50, 50)
    particle.Speed = NumberRange.new(5, 10)
    particle.VelocitySpread = 180
    particle.Shape = Enum.ParticleEmitterShape.Sphere
    particle.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
    particle.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
    particle.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
    
    -- パーティクルの位置設定
    local attachment = Instance.new("Attachment")
    attachment.Parent = particleFolder
    attachment.Position = position
    particle.Parent = attachment
    
    -- 5秒後に消去
    task.delay(5, function()
        if particleFolder then
            particleFolder:Destroy()
            particleFolder = nil
        end
    end)
end

-- テレポート関数にエフェクトを追加
local originalTeleport = TeleportToRandomPosition
TeleportToRandomPosition = function()
    local success = originalTeleport()
    if success and showParticle then
        local targetPlayer = Settings.SelectedPlayer or Players.LocalPlayer
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            CreateTeleportEffect(targetPlayer.Character.HumanoidRootPart.Position)
        end
    end
    return success
end

-- 情報タブ
local InfoTab = Window:MakeTab({
    Name = "情報",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddParagraph("使い方", [[
1. 「プレイヤー選択」でテレポート対象を選びます
2. 「設定」タブで半径や間隔を調整します
3. 「メイン機能」タブでテレポートを実行します
4. 「自動テレポート」で連続実行も可能です
]])

InfoTab:AddParagraph("注意事項", [[
• ゲームのルールに違反しないように使用してください
• 過剰な使用は他のプレイヤーの迷惑になります
• 一部のゲームでは機能しない場合があります
]])

-- 初期化完了通知
OrionLib:MakeNotification({
    Name = "読み込み完了",
    Content = "360° ランダムテレポートスクリプトが正常に読み込まれました！",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- 設定の保存/読み込み機能
Window:MakeNotification({
    Name = "設定を保存",
    Content = "設定は自動的に保存されます",
    Image = "rbxassetid://4483345998",
    Time = 3
})

-- クリーンアップ関数
local function Cleanup()
    if autoTeleportConnection then
        autoTeleportConnection:Disconnect()
    end
    if particleFolder then
        particleFolder:Destroy()
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    -- キャラクターが再スポーンしたときにエフェクトをクリーンアップ
    if particleFolder then
        particleFolder:Destroy()
        particleFolder = nil
    end
end)

-- ゲーム終了時のクリーンアップ
game:BindToClose(function()
    Cleanup()
end)

print("360° ランダムテレポートスクリプトが初期化されました")
