-- Blind Shoot Script Hub (Orion Library版)
-- ご指定のUI構造・ボタン配置を忠実に再現
-- 360°ランダムテレポート機能は一切入れず、他のスクリプトをロードするボタンのみ

local player = game.Players.LocalPlayer

-- Orion Library読み込み（ご指定のURLを使用）
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- ウィンドウ作成
local Window = OrionLib:MakeWindow({
    Name = "Blind shoot script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false  -- 開けない問題を回避するためイントロ無効化（必要ならtrueに変更可）
})

-- Mainタブ
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddButton({
    Name = "Esp player",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/BlindShot", true))()
    end
})

MainTab:AddButton({
    Name = "Reveal all player",
    Callback = function()
        loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/87cc0bbc35d973c937f7c3cd93a7b5b022af8dc99d41a16ebc6ddbcac7519806/download"))()
    end
})

-- Hubsタブ
local HubsTab = Window:MakeTab({
    Name = "Hubs",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

HubsTab:AddButton({
    Name = "synergy hub",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/vjB2N8PE"))()
    end
})

HubsTab:AddButton({
    Name = "Random hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lattereal/blindshot/refs/heads/main/yes.lua"))()
    end
})

HubsTab:AddButton({
    Name = "foxname hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/afkar-gg/sc/refs/heads/main/blindshot", true))()
    end
})

HubsTab:AddButton({
    Name = "AnonymouHub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/HitAMassy/AnonymousHub/refs/heads/main/loader.lua"))()
    end
})

HubsTab:AddButton({
    Name = "susy hub",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script'))()
    end
})

HubsTab:AddButton({
    Name = "scnpai Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Senpai1997/Scripts/refs/heads/main/SenpaihubTheStrongestBattlegroundsAimlockAutoblock.lua"))()
    end
})

-- 読み込み完了通知（Orion標準機能）
OrionLib:MakeNotification({
    Name = "読み込み完了",
    Content = "Blind Shoot Script Hub が正常に起動しました！",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print("Blind Shoot Script Hub が正常に読み込まれました！")
