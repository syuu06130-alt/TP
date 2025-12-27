-- Blind Shoot Script (360° ランダムテレポート) - Orion UI Library版
-- 機能がきちんと分離され、見やすいUIに変更しました。
-- 現在の安定版Orion Libraryを使用（https://raw.githubusercontent.com/shlexware/Orion/main/source）

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

-- 設定値（OrionのFlagで保存可能に）
local Settings = {
    Radius = 7.5,
    SelectedPlayer = nil  -- nil = 自分自身
}

-- Orion Library読み込み（最新の安定版を使用）
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "Blind Shoot Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BlindShootConfig",
    IntroEnabled = true,
    IntroText = "360° ランダムテレポート"
})

-- 通知関数
local function Notify(title, content, duration)
    OrionLib:MakeNotification({
        Name = title,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = duration or 5
    })
end

-- メインTab
local MainTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- プレイヤー選択セクション
local PlayerSection = MainTab:AddSection({
    Name = "対象プレイヤー選択"
})

local PlayerDropdown = MainTab:AddDropdown({
    Name = "対象プレイヤー",
    Default = "自分自身",
    Options = {"自分自身"},  -- 初期値
    Save = true,
    Flag = "SelectedPlayerDropdown",
    Callback = function(Value)
        if Value == "自分自身" then
            Settings.SelectedPlayer = nil
            Notify("対象変更", "自分自身に設定しました", 3)
        else
            local selectedPlr = Players:FindFirstChild(Value)
            if selectedPlr then
                Settings.SelectedPlayer = selectedPlr
                Notify("対象変更", Value .. " に設定しました", 3)
            end
        end
    end
})

-- プレイヤーリスト更新関数
local function UpdatePlayerList()
    local options = {"自分自身"}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(options, plr.DisplayName or plr.Name)
        end
    end
    PlayerDropdown:Refresh(options, true)
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- 半径調整セクション
local RadiusSection = MainTab:AddSection({
    Name = "テレポート半径設定 (5 ~ 10 studs)"
})

MainTab:AddSlider({
    Name = "テレポート半径",
    Min = 5,
    Max = 10,
    Default = 7.5,
    Increment = 0.1,
    Save = true,
    Flag = "TeleportRadius",
    Callback = function(Value)
        Settings.Radius = Value
        Notify("半径変更", string.format("半径: %.1f studs", Value), 3)
    end
})

-- ステータス表示用ラベル
local StatusLabel = MainTab:AddLabel("ステータス: 準備完了")

-- テレポート実行ボタン
MainTab:AddButton({
    Name = "テレポート実行 (1回)",
    Callback = function()
        local targetPlr = Settings.SelectedPlayer or Player
        local char = targetPlr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            StatusLabel:Set("ステータス: キャラクターが見つかりません")
            Notify("エラー", "対象のキャラクターが見つかりません", 5)
            return
        end

        local hrp = char.HumanoidRootPart
        local angle = math.rad(math.random(0, 360))
        local offset = Vector3.new(math.cos(angle) * Settings.Radius, 0, math.sin(angle) * Settings.Radius)
        local newPos = hrp.Position + offset

        -- 地面調整（Raycastで少し上に着地）
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local ray = Workspace:Raycast(newPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), rayParams)
        if ray then
            newPos = Vector3.new(newPos.X, ray.Position.Y + 3, newPos.Z)
        end

        hrp.CFrame = CFrame.new(newPos)

        local targetName = targetPlr == Player and "自分自身" or targetPlr.DisplayName
        StatusLabel:Set("ステータス: " .. targetName .. " にテレポート成功！")
        Notify("成功", "360° ランダムテレポート完了！", 5)
    end
})

-- 初期ステータス
StatusLabel:Set("ステータス: 自分自身を選択中 (半径: " .. Settings.Radius .. " studs)")

-- 読み込み完了通知
Notify("スクリプト読み込み完了", "Blind Shoot Script が正常に起動しました！", 6)

print("Blind Shoot Script (Orion版) が正常に読み込まれました！")
