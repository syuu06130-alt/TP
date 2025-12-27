local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Blind shoot script", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- サービス定義
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 変数管理
local Settings = {
    Target = nil,        -- ターゲットプレイヤー
    Radius = 7.5,        -- 半径
    Height = 0,          -- 高さ調整
    Loop = false,        -- ループ有効化
    LoopDelay = 0.1      -- ループ遅延
}

local LoopConnection = nil

-- プレイヤーリスト取得関数
local function GetPlayerNames()
    local names = {}
    table.insert(names, "LocalPlayer (自分)") -- 自分自身も選択可能に
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- テレポート実行ロジック
local function TeleportToTarget()
    local targetChar = nil
    
    -- ターゲットの特定
    if Settings.Target == "LocalPlayer (自分)" or Settings.Target == nil then
        targetChar = LocalPlayer.Character
    else
        local targetPlayer = Players:FindFirstChild(Settings.Target)
        if targetPlayer then
            targetChar = targetPlayer.Character
        end
    end

    -- ターゲットが存在し、生きている場合
    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetChar.HumanoidRootPart
        local myHRP = LocalPlayer.Character.HumanoidRootPart
        
        -- ランダムな角度を計算
        local angle = math.rad(math.random(0, 360))
        
        -- 位置計算 (ターゲットを中心に円周上へ)
        local offsetX = math.cos(angle) * Settings.Radius
        local offsetZ = math.sin(angle) * Settings.Radius
        
        -- 新しい位置 (ターゲットの高さ + 設定した高さ補正)
        local newPos = Vector3.new(targetHRP.Position.X + offsetX, targetHRP.Position.Y + Settings.Height, targetHRP.Position.Z + offsetZ)
        
        -- テレポート実行 (CFrame.lookAtを使って、常にターゲットの方を向くように設定 = Blind Shootしやすく)
        myHRP.CFrame = CFrame.lookAt(newPos, targetHRP.Position)
    else
        OrionLib:MakeNotification({
            Name = "エラー",
            Content = "ターゲットまたはキャラクターが見つかりません。",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
end

-- ==============================
-- UI構築 (タブ分け)
-- ==============================

-- [メインタブ] ターゲット選択と実行
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TargetSection = MainTab:AddSection({
    Name = "ターゲット設定"
})

local PlayerDropdown = TargetSection:AddDropdown({
    Name = "プレイヤー選択",
    Default = "選択してください",
    Options = GetPlayerNames(),
    Callback = function(Value)
        Settings.Target = Value
    end    
})

TargetSection:AddButton({
    Name = "プレイヤーリスト更新",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerNames(), true)
    end    
})

local ActionSection = MainTab:AddSection({
    Name = "アクション"
})

ActionSection:AddButton({
    Name = "1回テレポート (Blind Shoot)",
    Callback = function()
        TeleportToTarget()
    end    
})

ActionSection:AddToggle({
    Name = "ループテレポート (連続移動)",
    Default = false,
    Callback = function(Value)
        Settings.Loop = Value
        if Value then
            -- ループ開始
            task.spawn(function()
                while Settings.Loop do
                    TeleportToTarget()
                    task.wait(Settings.LoopDelay)
                end
            end)
        end
    end    
})

-- [設定タブ] 数値調整
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddSlider({
    Name = "半径 (距離)",
    Min = 2,
    Max = 20,
    Default = 7.5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(Value)
        Settings.Radius = Value
    end    
})

SettingsTab:AddSlider({
    Name = "高さ調整 (Y軸)",
    Min = -10,
    Max = 10,
    Default = 0,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(Value)
        Settings.Height = Value
    end    
})

SettingsTab:AddSlider({
    Name = "ループ遅延 (秒)",
    Min = 0.05,
    Max = 2.0,
    Default = 0.5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    ValueName = "sec",
    Callback = function(Value)
        Settings.LoopDelay = Value
    end    
})

-- 初期化通知
OrionLib:Init()
