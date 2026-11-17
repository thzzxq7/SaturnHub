--[[
╔══════════════════════════════════════════════════════╗
║           SATURN HUB v1.0  |  Blox Fruits           ║
║           Créditos: @matheuz.z7                      ║
╚══════════════════════════════════════════════════════╝

  ► ÚNICO PASSO: troca YOUR_USER e YOUR_REPO abaixo
    pelo seu usuário e nome do repositório do GitHub.

  Depois execute no Delta:
  loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/SaturnHub.lua"))()
]]

-- ══════════════════════════════════════════════════════
--  ★ EDITE APENAS ESTA LINHA ★
local GITHUB = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/"
-- ══════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera
local GuiParent = (typeof(gethui) == "function" and gethui()) or PlayerGui

local IMG_URL = GITHUB .. "saturn.jpg"

local CFG = {
    Key        = "Saturn777",
    Version    = "v1.0",
    Credits    = "@matheuz.z7",
    BG         = Color3.fromRGB(3,   3,  12),
    TopBar     = Color3.fromRGB(0,   8,  35),
    Accent     = Color3.fromRGB(0,  90, 245),
    AccentDark = Color3.fromRGB(0,  35, 120),
    Text       = Color3.fromRGB(210, 230, 255),
    TextDim    = Color3.fromRGB(70, 110, 190),
    Element    = Color3.fromRGB(0,  12,  45),
    Stroke     = Color3.fromRGB(0,  50, 160),
}

local function Char() return LP.Character end
local function HRP()  local c = Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c = Char(); return c and c:FindFirstChildOfClass("Humanoid") end

_G.Saturn = {
    AutoFarm=false, AutoQuest=false, AutoBoss=false, AutoChest=false,
    AutoEvent=false, AutoMastery=false, AutoStats=false,
    KillAura=false, FlyEnabled=false, NoClip=false,
    InfiniteJump=false, InfiniteEnergy=false, FastAttack=false,
    FruitESP=false, PlayerESP=false, FruitSniper=false, FruitNotify=false,
    AntiAFK=true,
    Speed=50, FlySpeed=100, KillAuraRange=30,
    StatType="Melee", FarmTarget="Automatic (By Level)",
    TargetPlayer=nil, SelectedIsland=nil,
}

-- cleanup
local old = GuiParent:FindFirstChild("SaturnHub")
if old then old:Destroy() end

-- ─── HELPERS ───────────────────────────────────────────
local function Make(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do pcall(function() o[k] = v end) end
    return o
end
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(t or .2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end
local function Corner(p, r) return Make("UICorner", {CornerRadius=UDim.new(0, r or 8), Parent=p}) end
local function Stroke(p, c, t) return Make("UIStroke", {Color=c or CFG.Stroke, Thickness=t or 1.5, Parent=p}) end

-- ─── SCREENGUI ─────────────────────────────────────────
local ScreenGui = Make("ScreenGui", {
    Name="SaturnHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=GuiParent,
})

-- ─── NOTIFICATIONS ─────────────────────────────────────
local NH = Make("Frame", {
    Size=UDim2.new(0,230,1,0), Position=UDim2.new(1,-240,0,20),
    BackgroundTransparency=1, Parent=ScreenGui,
})
Make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6), Parent=NH})

local function Notify(title, msg, dur)
    local f = Make("Frame", {Size=UDim2.new(1,0,0,58), BackgroundColor3=CFG.Element, Parent=NH})
    Corner(f,6); Stroke(f, CFG.Accent, 1.5)
    Make("TextLabel", {
        Size=UDim2.new(1,-12,0,18), Position=UDim2.new(0,10,0,6),
        BackgroundTransparency=1, Text=title, TextColor3=CFG.Accent,
        TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
    })
    Make("TextLabel", {
        Size=UDim2.new(1,-12,0,26), Position=UDim2.new(0,10,0,24),
        BackgroundTransparency=1, Text=msg, TextColor3=CFG.Text,
        TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, Parent=f,
    })
    f.Position = UDim2.new(1,10,0,0)
    Tween(f, {Position=UDim2.new(0,0,0,0)}, .3, Enum.EasingStyle.Back)
    task.delay(dur or 4, function()
        Tween(f, {Position=UDim2.new(1,10,0,0)}, .3)
        task.wait(.4); pcall(function() f:Destroy() end)
    end)
end

-- ─── FLOATING BUTTON ───────────────────────────────────
local FloatBtn = Make("ImageButton", {
    Size=UDim2.new(0,64,0,64), Position=UDim2.new(0,20,0.5,-32),
    BackgroundColor3=CFG.BG, Image="", ScaleType=Enum.ScaleType.Fit,
    Parent=ScreenGui,
})
Corner(FloatBtn, 10); Stroke(FloatBtn, CFG.Accent, 2)

local Glow = Make("Frame", {
    Size=UDim2.new(1,16,1,16), Position=UDim2.new(0,-8,0,-8),
    BackgroundColor3=CFG.Accent, BackgroundTransparency=0.6,
    ZIndex=FloatBtn.ZIndex-1, Parent=FloatBtn,
})
Corner(Glow, 16)
task.spawn(function()
    while FloatBtn.Parent do
        Tween(Glow, {BackgroundTransparency=0.4}, 0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
        Tween(Glow, {BackgroundTransparency=0.78}, 0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
    end
end)

do -- drag float
    local drag, ds, sp = false
    FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=FloatBtn.Position
        end
    end)
    FloatBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag=false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            FloatBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ─── KEY PANEL ─────────────────────────────────────────
local KeyPanel = Make("Frame", {
    Size=UDim2.new(0,320,0,315), Position=UDim2.new(0.5,-160,0.5,-157),
    BackgroundColor3=CFG.BG, Visible=false, Parent=ScreenGui,
})
Corner(KeyPanel, 12); Stroke(KeyPanel, CFG.Accent, 2)
Make("UIGradient", {Color=ColorSequence.new(CFG.BG, Color3.fromRGB(0,5,25)), Rotation=120, Parent=KeyPanel})

local KTop = Make("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=CFG.TopBar, Parent=KeyPanel})
Corner(KTop, 12)
Make("Frame", {Size=UDim2.new(1,0,.5,0), Position=UDim2.new(0,0,.5,0), BackgroundColor3=CFG.TopBar, BorderSizePixel=0, Parent=KTop})
Make("TextLabel", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="🪐  SATURN HUB — KEY SYSTEM",
    TextColor3=CFG.Accent, TextSize=12, Font=Enum.Font.GothamBold, Parent=KTop,
})
local KClose = Make("TextButton", {
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13),
    BackgroundColor3=Color3.fromRGB(160,20,20), Text="✕",
    TextColor3=Color3.new(1,1,1), TextSize=11, Font=Enum.Font.GothamBold, Parent=KTop,
})
Corner(KClose, 5)
KClose.MouseButton1Click:Connect(function()
    Tween(KeyPanel, {Position=UDim2.new(0.5,-160,0.6,-157), BackgroundTransparency=1}, .25)
    task.wait(.3); KeyPanel.Visible=false; KeyPanel.BackgroundTransparency=0
end)

local KImg = Make("ImageLabel", {
    Size=UDim2.new(0,76,0,76), Position=UDim2.new(0.5,-38,0,46),
    BackgroundTransparency=1, Image="", ScaleType=Enum.ScaleType.Fit, Parent=KeyPanel,
})
Corner(KImg, 38); Stroke(KImg, CFG.Accent, 2)

Make("TextLabel", {
    Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,130),
    BackgroundTransparency=1, Text="SATURN HUB",
    TextColor3=CFG.Text, TextSize=16, Font=Enum.Font.GothamBold, Parent=KeyPanel,
})
Make("TextLabel", {
    Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,152),
    BackgroundTransparency=1, Text="Insira a chave de acesso",
    TextColor3=CFG.TextDim, TextSize=11, Font=Enum.Font.Gotham, Parent=KeyPanel,
})

local KInput = Make("TextBox", {
    Size=UDim2.new(1,-40,0,36), Position=UDim2.new(0,20,0,174),
    BackgroundColor3=CFG.Element, Text="", PlaceholderText="Chave...",
    TextColor3=CFG.Text, PlaceholderColor3=CFG.TextDim,
    TextSize=13, Font=Enum.Font.Gotham, ClearTextOnFocus=false, Parent=KeyPanel,
})
Corner(KInput, 6); Stroke(KInput, CFG.Stroke, 1.5)

local KBtn = Make("TextButton", {
    Size=UDim2.new(1,-40,0,36), Position=UDim2.new(0,20,0,218),
    BackgroundColor3=CFG.AccentDark, Text="VERIFICAR",
    TextColor3=Color3.new(1,1,1), TextSize=13, Font=Enum.Font.GothamBold, Parent=KeyPanel,
})
Corner(KBtn, 6); Stroke(KBtn, CFG.Accent, 1.5)

local KErr = Make("TextLabel", {
    Size=UDim2.new(1,-40,0,16), Position=UDim2.new(0,20,0,262),
    BackgroundTransparency=1, Text="",
    TextColor3=Color3.fromRGB(255,70,70), TextSize=11, Font=Enum.Font.Gotham, Parent=KeyPanel,
})
Make("TextLabel", {
    Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-18),
    BackgroundTransparency=1, Text="créditos: "..CFG.Credits,
    TextColor3=CFG.TextDim, TextSize=10, Font=Enum.Font.Gotham, Parent=KeyPanel,
})

-- ─── MAIN HUB ──────────────────────────────────────────
local Hub = Make("Frame", {
    Size=UDim2.new(0,600,0,420), Position=UDim2.new(0.5,-300,0.5,-210),
    BackgroundColor3=CFG.BG, Visible=false, Parent=ScreenGui,
})
Corner(Hub, 12); Stroke(Hub, CFG.Accent, 2)
Make("UIGradient", {Color=ColorSequence.new(CFG.BG, Color3.fromRGB(0,4,20)), Rotation=130, Parent=Hub})

local HTop = Make("Frame", {Size=UDim2.new(1,0,0,46), BackgroundColor3=CFG.TopBar, Parent=Hub})
Corner(HTop, 12)
Make("Frame", {Size=UDim2.new(1,0,.5,0), Position=UDim2.new(0,0,.5,0), BackgroundColor3=CFG.TopBar, BorderSizePixel=0, Parent=HTop})

local TopLogo = Make("ImageLabel", {
    Size=UDim2.new(0,32,0,32), Position=UDim2.new(0,8,0.5,-16),
    BackgroundTransparency=1, Image="", ScaleType=Enum.ScaleType.Fit, Parent=HTop,
})
Corner(TopLogo, 16); Stroke(TopLogo, CFG.Accent, 1.5)

Make("TextLabel", {
    Size=UDim2.new(0,180,0,20), Position=UDim2.new(0,46,0,6),
    BackgroundTransparency=1, Text="SATURN HUB",
    TextColor3=CFG.Text, TextSize=14, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=HTop,
})
Make("TextLabel", {
    Size=UDim2.new(0,220,0,14), Position=UDim2.new(0,46,0,27),
    BackgroundTransparency=1, Text=CFG.Version.." | Blox Fruits | "..CFG.Credits,
    TextColor3=CFG.TextDim, TextSize=10, Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=HTop,
})

local HClose = Make("TextButton", {
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-34,0.5,-13),
    BackgroundColor3=Color3.fromRGB(160,20,20), Text="✕",
    TextColor3=Color3.new(1,1,1), TextSize=11, Font=Enum.Font.GothamBold, Parent=HTop,
})
Corner(HClose, 5)
local HMin = Make("TextButton", {
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-66,0.5,-13),
    BackgroundColor3=Color3.fromRGB(150,100,0), Text="−",
    TextColor3=Color3.new(1,1,1), TextSize=14, Font=Enum.Font.GothamBold, Parent=HTop,
})
Corner(HMin, 5)

local minimized = false
HMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tween(Hub, {Size=minimized and UDim2.new(0,600,0,46) or UDim2.new(0,600,0,420)}, .25, Enum.EasingStyle.Back)
end)
HClose.MouseButton1Click:Connect(function()
    Tween(Hub, {Size=UDim2.new(0,0,0,0)}, .2)
    task.wait(.25); Hub.Visible=false
    Hub.Size = UDim2.new(0,600,0,420)
    FloatBtn.Visible = true
end)

do -- drag hub
    local drag, ds, sp = false
    HTop.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=Hub.Position end
    end)
    HTop.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            Hub.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

Make("Frame", {
    Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,46),
    BackgroundColor3=CFG.Accent, BorderSizePixel=0, Parent=Hub,
})

-- ─── TAB SYSTEM ────────────────────────────────────────
local TabBar = Make("Frame", {
    Size=UDim2.new(0,136,1,-48), Position=UDim2.new(0,0,0,48),
    BackgroundColor3=Color3.fromRGB(0,4,18), BorderSizePixel=0, Parent=Hub,
})
Make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2), Parent=TabBar})
Make("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6), Parent=TabBar})
Make("TextLabel", {
    Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-18),
    BackgroundTransparency=1, Text=CFG.Credits,
    TextColor3=CFG.TextDim, TextSize=10, Font=Enum.Font.Gotham, Parent=TabBar,
})
Make("Frame", {
    Size=UDim2.new(0,1,1,-48), Position=UDim2.new(0,136,0,48),
    BackgroundColor3=CFG.Stroke, BorderSizePixel=0, Parent=Hub,
})

local ContentArea = Make("Frame", {
    Size=UDim2.new(1,-138,1,-48), Position=UDim2.new(0,138,0,48),
    BackgroundTransparency=1, Parent=Hub,
})

local function MakeScroll(parent)
    local sf = Make("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=CFG.Accent,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=parent,
    })
    Make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5), Parent=sf})
    Make("UIPadding", {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,14), PaddingBottom=UDim.new(0,10), Parent=sf})
    return sf
end

local function MakeSection(parent, text)
    local f = Make("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Parent=parent})
    Make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=text,
        TextColor3=CFG.Accent, TextSize=11, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
    })
    Make("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=CFG.Stroke, BorderSizePixel=0, Parent=f})
end

local function MakeToggle(parent, label, default, cb)
    local state = default or false
    local f = Make("Frame", {Size=UDim2.new(1,0,0,36), BackgroundColor3=CFG.Element, Parent=parent})
    Corner(f,6); Stroke(f, CFG.Stroke, 1)
    Make("TextLabel", {
        Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=label, TextColor3=CFG.Text,
        TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
    })
    local bg = Make("Frame", {
        Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-46,0.5,-10),
        BackgroundColor3=state and CFG.Accent or CFG.AccentDark, Parent=f,
    })
    Corner(bg, 10)
    local circle = Make("Frame", {
        Size=UDim2.new(0,14,0,14),
        Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
        BackgroundColor3=Color3.new(1,1,1), Parent=bg,
    })
    Corner(circle, 7)
    local ov = Make("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=f})
    ov.MouseButton1Click:Connect(function()
        state = not state
        Tween(bg, {BackgroundColor3=state and CFG.Accent or CFG.AccentDark}, .18)
        Tween(circle, {Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, .18)
        cb(state)
    end)
end

local function MakeButton(parent, label, cb)
    local b = Make("TextButton", {
        Size=UDim2.new(1,0,0,34), BackgroundColor3=CFG.AccentDark,
        Text=label, TextColor3=CFG.Text, TextSize=12, Font=Enum.Font.GothamBold, Parent=parent,
    })
    Corner(b,6); Stroke(b, CFG.Accent, 1.5)
    b.MouseButton1Click:Connect(function()
        Tween(b, {BackgroundColor3=CFG.Accent}, .08)
        task.wait(.08); Tween(b, {BackgroundColor3=CFG.AccentDark}, .18)
        cb()
    end)
end

local function MakeSlider(parent, label, mn, mx, def, suf, cb)
    local f = Make("Frame", {Size=UDim2.new(1,0,0,52), BackgroundColor3=CFG.Element, Parent=parent})
    Corner(f,6); Stroke(f, CFG.Stroke, 1)
    local vl = Make("TextLabel", {
        Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,10,0,4),
        BackgroundTransparency=1, Text=label..": "..def..(suf or ""),
        TextColor3=CFG.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
    })
    local track = Make("Frame", {
        Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,33),
        BackgroundColor3=CFG.AccentDark, Parent=f,
    })
    Corner(track, 3)
    local r0 = (def-mn)/(mx-mn)
    local fill = Make("Frame", {Size=UDim2.new(r0,0,1,0), BackgroundColor3=CFG.Accent, Parent=track})
    Corner(fill, 3)
    local thumb = Make("Frame", {
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(r0,-7,0.5,-7),
        BackgroundColor3=Color3.new(1,1,1), Parent=track,
    })
    Corner(thumb, 7)
    local sliding = false
    local function upd(x)
        local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + r*(mx-mn) + .5)
        fill.Size=UDim2.new(r,0,1,0); thumb.Position=UDim2.new(r,-7,.5,-7)
        vl.Text=label..": "..v..(suf or ""); cb(v)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; upd(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)
end

local function MakeDropdown(parent, label, opts, def, cb)
    local open, cur = false, def or opts[1] or ""
    local f = Make("Frame", {Size=UDim2.new(1,0,0,34), BackgroundColor3=CFG.Element, ClipsDescendants=false, Parent=parent})
    Corner(f,6); Stroke(f, CFG.Stroke, 1)
    local lbl = Make("TextLabel", {
        Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=label..": "..cur, TextColor3=CFG.Text,
        TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=f,
    })
    local arr = Make("TextLabel", {
        Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-30,.5,-11),
        BackgroundTransparency=1, Text="▾", TextColor3=CFG.Accent, TextSize=13, Font=Enum.Font.GothamBold, Parent=f,
    })
    local df = Make("Frame", {
        Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,2),
        BackgroundColor3=CFG.Element, ClipsDescendants=true, ZIndex=20, Parent=f,
    })
    Corner(df, 6); Stroke(df, CFG.Stroke, 1)
    Make("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Parent=df})
    for _, opt in ipairs(opts) do
        local ob = Make("TextButton", {
            Size=UDim2.new(1,0,0,28), BackgroundTransparency=1,
            Text=opt, TextColor3=CFG.Text, TextSize=11, Font=Enum.Font.Gotham, ZIndex=21, Parent=df,
        })
        ob.MouseEnter:Connect(function() Tween(ob, {BackgroundTransparency=0, BackgroundColor3=CFG.AccentDark}, .1) end)
        ob.MouseLeave:Connect(function() Tween(ob, {BackgroundTransparency=1}, .1) end)
        ob.MouseButton1Click:Connect(function()
            cur=opt; lbl.Text=label..": "..opt; cb(opt)
            Tween(df, {Size=UDim2.new(1,0,0,0)}, .18); arr.Text="▾"; open=false
        end)
    end
    local th = #opts * 28
    Make("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", Parent=f}).MouseButton1Click:Connect(function()
        open = not open
        Tween(df, {Size=UDim2.new(1,0,0, open and th or 0)}, .2)
        arr.Text = open and "▴" or "▾"
    end)
end

-- ─── BUILD TABS ────────────────────────────────────────
local TabBtns, Pages = {}, {}
local ActiveTab = nil

local TabDefs = {
    {icon="⚔️", name="Combat"},
    {icon="🌾", name="Farm"},
    {icon="🍎", name="Fruit"},
    {icon="👤", name="Player"},
    {icon="🚀", name="Movement"},
    {icon="⚙️", name="Misc"},
}

local function SelectTab(name)
    for n, btn in pairs(TabBtns) do
        Tween(btn, {BackgroundColor3=n==name and CFG.AccentDark or CFG.BG, BackgroundTransparency=n==name and 0 or 1}, .15)
        local tl = btn:FindFirstChildOfClass("TextLabel")
        if tl then Tween(tl, {TextColor3=n==name and CFG.Text or CFG.TextDim}, .15) end
    end
    for n, pg in pairs(Pages) do pg.Visible = (n==name) end
    ActiveTab = name
end

for _, def in ipairs(TabDefs) do
    local btn = Make("TextButton", {
        Size=UDim2.new(1,0,0,36), BackgroundColor3=CFG.BG,
        BackgroundTransparency=1, Text="", Parent=TabBar,
    })
    Corner(btn, 6)
    local tl = Make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=def.icon.."  "..def.name, TextColor3=CFG.TextDim,
        TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=btn,
    })
    Make("UIPadding", {PaddingLeft=UDim.new(0,8), Parent=tl})
    local page   = Make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false, Parent=ContentArea})
    local scroll = MakeScroll(page)
    TabBtns[def.name]=btn; Pages[def.name]=page; Pages[def.name.."_S"]=scroll
    btn.MouseButton1Click:Connect(function() SelectTab(def.name) end)
    btn.MouseEnter:Connect(function() if ActiveTab~=def.name then Tween(btn, {BackgroundTransparency=0.6, BackgroundColor3=CFG.AccentDark}, .1) end end)
    btn.MouseLeave:Connect(function() if ActiveTab~=def.name then Tween(btn, {BackgroundTransparency=1}, .1) end end)
end

-- ══════════════════════════════════════════════════════
--  COMBAT
-- ══════════════════════════════════════════════════════
local cs = Pages["Combat_S"]
MakeSection(cs, "Kill Aura")
MakeToggle(cs, "Kill Aura", false, function(v) _G.Saturn.KillAura = v end)
MakeSlider(cs, "Range", 10, 100, 30, " studs", function(v) _G.Saturn.KillAuraRange = v end)
MakeSection(cs, "Combat Mods")
MakeToggle(cs, "Infinite Energy", false, function(v) _G.Saturn.InfiniteEnergy = v end)
MakeToggle(cs, "Fast Attack", false, function(v)
    _G.Saturn.FastAttack = v
    local h = Hum(); if not h then return end
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, anim in ipairs(tool:GetDescendants()) do
                if anim:IsA("Animation") then
                    local t = h:LoadAnimation(anim)
                    if t then t:AdjustSpeed(v and 2.5 or 1) end
                end
            end
        end
    end
end)
MakeToggle(cs, "Auto Parry", false, function(v) _G.Saturn.AutoParry = v end)

-- ══════════════════════════════════════════════════════
--  FARM
-- ══════════════════════════════════════════════════════
local fs = Pages["Farm_S"]
MakeSection(fs, "Auto Farm")
MakeDropdown(fs, "Alvo", {
    "Automatic (By Level)","Bandits","Pirates","Monkey","Gorilla",
    "Sword Master","Black Beard","Swan","Wysper","Thunder God",
    "Diamante","Pica","Rip_Indra","Sea Beast","Dragon",
}, "Automatic (By Level)", function(v) _G.Saturn.FarmTarget = v end)
MakeToggle(fs, "Auto Farm", false, function(v)
    _G.Saturn.AutoFarm = v
    if v then Notify("🌾 Auto Farm", "Ativado — ".._G.Saturn.FarmTarget, 3) end
end)
MakeToggle(fs, "Auto Quest", false, function(v) _G.Saturn.AutoQuest = v end)
MakeSection(fs, "Boss & Baús")
MakeToggle(fs, "Auto Boss Farm", false, function(v) _G.Saturn.AutoBoss = v end)
MakeToggle(fs, "Auto Chest Farm", false, function(v) _G.Saturn.AutoChest = v end)
MakeSection(fs, "Sea Events")
MakeToggle(fs, "Auto Sea Event", false, function(v) _G.Saturn.AutoEvent = v end)

-- ══════════════════════════════════════════════════════
--  FRUIT
-- ══════════════════════════════════════════════════════
local frs = Pages["Fruit_S"]
MakeSection(frs, "ESP & Radar")
MakeToggle(frs, "Fruit ESP", false, function(v)
    _G.Saturn.FruitESP = v
    if not v then
        for _, h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatFruitESP" then h:Destroy() end
        end
    end
end)
MakeToggle(frs, "Fruit Notifier", false, function(v) _G.Saturn.FruitNotify = v end)
MakeSection(frs, "Sniper")
MakeToggle(frs, "Fruit Sniper (Auto TP)", false, function(v) _G.Saturn.FruitSniper = v end)

-- ══════════════════════════════════════════════════════
--  PLAYER
-- ══════════════════════════════════════════════════════
local ps = Pages["Player_S"]
MakeSection(ps, "ESP")
MakeToggle(ps, "Player ESP", false, function(v)
    _G.Saturn.PlayerESP = v
    if not v then
        for _, h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatPlayerESP" then h:Destroy() end
        end
    end
end)
MakeSection(ps, "Teleporte para Jogador")
local pNames = {}
for _, p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(pNames, p.Name) end end
if #pNames > 0 then
    MakeDropdown(ps, "Jogador", pNames, pNames[1], function(v) _G.Saturn.TargetPlayer = v end)
end
MakeButton(ps, "Teleportar ➜ Jogador", function()
    local n = _G.Saturn.TargetPlayer
    if not n then Notify("⚠️","Selecione um jogador.",3) return end
    local p = Players:FindFirstChild(n)
    if p and p.Character then
        local th = p.Character:FindFirstChild("HumanoidRootPart"); local mh = HRP()
        if th and mh then mh.CFrame = th.CFrame + Vector3.new(3,0,0) end
    end
end)

-- ══════════════════════════════════════════════════════
--  MOVEMENT
-- ══════════════════════════════════════════════════════
local mv = Pages["Movement_S"]
MakeSection(mv, "Speed & Jump")
MakeSlider(mv, "Walk Speed", 16, 500, 50, " ws", function(v)
    _G.Saturn.Speed = v; local h = Hum(); if h then h.WalkSpeed = v end
end)
MakeSlider(mv, "Jump Height", 7, 300, 7, " jp", function(v)
    local h = Hum(); if h then h.JumpHeight = v end
end)
MakeToggle(mv, "Infinite Jump", false, function(v) _G.Saturn.InfiniteJump = v end)
MakeSection(mv, "Fly")
MakeToggle(mv, "Fly", false, function(v) _G.Saturn.FlyEnabled = v end)
MakeSlider(mv, "Fly Speed", 20, 500, 100, " ws", function(v) _G.Saturn.FlySpeed = v end)
MakeSection(mv, "Misc")
MakeToggle(mv, "No Clip", false, function(v) _G.Saturn.NoClip = v end)
MakeSection(mv, "Teleporte — Ilhas")
local Islands = {
    ["Starter Island"]=CFrame.new(-1203,4,400), ["Marine Starter"]=CFrame.new(930,4,1310),
    ["Jungle"]=CFrame.new(-1600,70,400), ["Pirate Village"]=CFrame.new(-1000,4,3700),
    ["Desert"]=CFrame.new(940,4,4075), ["Frozen Village"]=CFrame.new(1050,4,100),
    ["Marine Fortress"]=CFrame.new(4600,220,-600), ["Skylands"]=CFrame.new(-4900,1800,500),
    ["Colosseum"]=CFrame.new(1050,4,-750), ["Magma Village"]=CFrame.new(-2360,4,-560),
    ["Underwater City"]=CFrame.new(-6000,-800,-1300), ["Fountain City"]=CFrame.new(-2000,4,-2000),
    ["Kingdom of Rose"]=CFrame.new(-263,10,-634), ["Green Zone"]=CFrame.new(-1750,100,-175),
    ["Graveyard"]=CFrame.new(530,4,-1680), ["Snow Mountain"]=CFrame.new(-1115,335,-545),
    ["Hot & Cold"]=CFrame.new(-2730,300,350), ["Cursed Ship"]=CFrame.new(680,10,1700),
    ["Zombie Island"]=CFrame.new(-2600,4,-2600), ["Port Town"]=CFrame.new(-2800,7,500),
    ["Hydra Island"]=CFrame.new(4300,15,-600), ["Floating Turtle"]=CFrame.new(6200,100,850),
    ["Castle on the Sea"]=CFrame.new(5300,580,100), ["Haunted Castle"]=CFrame.new(4300,300,-600),
    ["Sea of Treats"]=CFrame.new(7900,50,-100),
}
local iList = {}; for k in pairs(Islands) do table.insert(iList, k) end; table.sort(iList)
MakeDropdown(mv, "Ilha", iList, iList[1], function(v) _G.Saturn.SelectedIsland = v end)
MakeButton(mv, "Teleportar ➜ Ilha", function()
    local n = _G.Saturn.SelectedIsland
    if n and Islands[n] then local h = HRP(); if h then h.CFrame = Islands[n] end
    else Notify("⚠️","Selecione uma ilha.",3) end
end)

-- ══════════════════════════════════════════════════════
--  MISC
-- ══════════════════════════════════════════════════════
local misc = Pages["Misc_S"]
MakeSection(misc, "Auto Stats")
MakeToggle(misc, "Auto Stats", false, function(v) _G.Saturn.AutoStats = v end)
MakeDropdown(misc, "Stat", {"Melee","Defense","Sword","Gun","Blox Fruit"}, "Melee", function(v) _G.Saturn.StatType = v end)
MakeSection(misc, "Mastery")
MakeToggle(misc, "Auto Mastery Farm", false, function(v) _G.Saturn.AutoMastery = v end)
MakeSection(misc, "Servidor")
MakeButton(misc, "Server Hop", function()
    local TS = game:GetService("TeleportService")
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and res and res.data then
        local valid = {}
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(valid, s.id) end
        end
        if #valid > 0 then TS:TeleportToPlaceInstance(game.PlaceId, valid[math.random(1,#valid)], LP)
        else Notify("⚠️","Sem servidores disponíveis.",3) end
    end
end)
MakeButton(misc, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
MakeSection(misc, "Anti AFK")
MakeToggle(misc, "Anti AFK", true, function(v) _G.Saturn.AntiAFK = v end)

SelectTab("Combat")

-- ─── FLOAT → KEY → HUB FLOW ────────────────────────────
local verified = false

FloatBtn.MouseButton1Click:Connect(function()
    if verified then
        Hub.Visible = not Hub.Visible
        if Hub.Visible then
            Hub.Size = UDim2.new(0,0,0,0)
            Tween(Hub, {Size=UDim2.new(0,600,0,420)}, .3, Enum.EasingStyle.Back)
            FloatBtn.Visible = false
        end
    else
        KeyPanel.Visible = true
        KeyPanel.BackgroundTransparency = 1
        KeyPanel.Position = UDim2.new(0.5,-160,0.6,-157)
        Tween(KeyPanel, {Position=UDim2.new(0.5,-160,0.5,-157), BackgroundTransparency=0}, .3, Enum.EasingStyle.Back)
    end
end)

local function DoVerify()
    local k = KInput.Text:gsub("%s","")
    if k == CFG.Key then
        verified = true
        Tween(KeyPanel, {Position=UDim2.new(0.5,-160,0.4,-157), BackgroundTransparency=1}, .25)
        task.wait(.3); KeyPanel.Visible = false
        FloatBtn.Visible = false
        Hub.Visible = true; Hub.Size = UDim2.new(0,0,0,0)
        Tween(Hub, {Size=UDim2.new(0,600,0,420)}, .4, Enum.EasingStyle.Back)
        task.wait(.5)
        Notify("🪐 Saturn Hub", "Bem-vindo! Créditos: "..CFG.Credits, 5)
    else
        KErr.Text = "❌ Chave incorreta."
        for _ = 1, 2 do
            Tween(KeyPanel, {Position=UDim2.new(0.5,-170,0.5,-157)}, .04); task.wait(.04)
            Tween(KeyPanel, {Position=UDim2.new(0.5,-150,0.5,-157)}, .04); task.wait(.04)
        end
        Tween(KeyPanel, {Position=UDim2.new(0.5,-160,0.5,-157)}, .04)
        task.delay(2.5, function() KErr.Text = "" end)
    end
end

KBtn.MouseButton1Click:Connect(DoVerify)
KInput.FocusLost:Connect(function(enter) if enter then DoVerify() end end)

-- ─── FLY ───────────────────────────────────────────────
local FlyBV, FlyBG
local function StartFly()
    local h = HRP(); if not h then return end
    FlyBV = Instance.new("BodyVelocity"); FlyBV.MaxForce=Vector3.new(1e5,1e5,1e5); FlyBV.Velocity=Vector3.zero; FlyBV.Parent=h
    FlyBG = Instance.new("BodyGyro"); FlyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); FlyBG.P=1e4; FlyBG.Parent=h
end
local function StopFly()
    if FlyBV then FlyBV:Destroy(); FlyBV=nil end
    if FlyBG then FlyBG:Destroy(); FlyBG=nil end
end

-- ─── ENEMY / FRUIT HELPERS ─────────────────────────────
local EF = {"Enemies","NPCs","Mobs","SeaEnemies","Bosses"}
local FK = {
    "Chop","Bomb","Spike","Flame","Ice","Sand","Dark","Diamond","Light","Rubber",
    "Barrier","Magma","Quake","Human","Bird","Phoenix","Rumble","Paw","Gravity",
    "Dough","Shadow","Venom","Control","Dragon","Spider","Sound","Blizzard",
    "Smoke","Revive","Spring","Leopard","Kilo","Love","String","Fruit",
}
local function FindEnemy(range)
    local h = HRP(); if not h then return end
    local best, bd = nil, range or math.huge
    for _, fn in ipairs(EF) do
        local f = workspace:FindFirstChild(fn)
        if f then
            for _, e in ipairs(f:GetChildren()) do
                local eH = e:FindFirstChild("HumanoidRootPart"); local eM = e:FindFirstChildOfClass("Humanoid")
                if eH and eM and eM.Health > 0 then
                    local match = _G.Saturn.FarmTarget=="Automatic (By Level)" or e.Name:find(_G.Saturn.FarmTarget)
                    if match then local d=(h.Position-eH.Position).Magnitude; if d<bd then best=e; bd=d end end
                end
            end
        end
    end
    return best
end
local function FindFruits()
    local out = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, kw in ipairs(FK) do
                if obj.Name:find(kw) and not obj:FindFirstAncestorOfClass("Character") then
                    table.insert(out, obj); break
                end
            end
        end
    end
    return out
end

-- ─── CONNECTIONS ───────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if _G.Saturn.InfiniteJump then local h=Hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
LP.Idled:Connect(function()
    if _G.Saturn.AntiAFK then
        VirtualUser:Button2Down(Vector2.zero, Camera.CFrame)
        task.wait(.1)
        VirtualUser:Button2Up(Vector2.zero, Camera.CFrame)
    end
end)
LP.CharacterAdded:Connect(function(char)
    task.wait(1); local h=char:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = _G.Saturn.Speed end
end)

-- ─── MAIN HEARTBEAT ────────────────────────────────────
local _t = 0
RunService.Heartbeat:Connect(function(dt)
    _t += dt
    local hrp = HRP(); local hum = Hum()
    if not hrp or not hum then return end

    if _G.Saturn.FlyEnabled then
        if not FlyBV then StartFly() end
        if FlyBV and FlyBG then
            local dir=Vector3.zero; local spd=_G.Saturn.FlySpeed; local cf=Camera.CFrame; local UIS=UserInputService
            if UIS:IsKeyDown(Enum.KeyCode.W)           then dir+=cf.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.S)           then dir-=cf.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.A)           then dir-=cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D)           then dir+=cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)       then dir+=Vector3.yAxis  end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.yAxis  end
            FlyBV.Velocity=dir.Magnitude>0 and dir.Unit*spd or Vector3.zero; FlyBG.CFrame=cf
        end
    else if FlyBV then StopFly() end end

    if _G.Saturn.NoClip then
        for _, p in ipairs(Char():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end

    if _G.Saturn.InfiniteEnergy then
        for _, obj in ipairs({Char(), LP}) do
            if obj then for _, vn in ipairs({"Energy","Mana","Stamina"}) do
                local val=obj:FindFirstChild(vn)
                if val and val:IsA("NumberValue") then val.Value=999999 end
            end end
        end
    end

    if _G.Saturn.KillAura and _t%0.1<dt then
        for _, fn in ipairs(EF) do local f=workspace:FindFirstChild(fn)
            if f then for _, e in ipairs(f:GetChildren()) do
                local eH=e:FindFirstChild("HumanoidRootPart"); local eM=e:FindFirstChildOfClass("Humanoid")
                if eH and eM and eM.Health>0 and (hrp.Position-eH.Position).Magnitude<=_G.Saturn.KillAuraRange then
                    local tool=Char():FindFirstChildOfClass("Tool")
                    if tool then local re=tool:FindFirstChildOfClass("RemoteEvent")
                        if re then pcall(function() re:FireServer(eH.Position,eH) end) end end
                    local rem=ReplicatedStorage:FindFirstChild("Remotes")
                    if rem then local dmg=rem:FindFirstChild("DamageRemote") or rem:FindFirstChild("Combat")
                        if dmg then pcall(function() dmg:FireServer(e) end) end end
                end
            end end
        end
    end

    if _G.Saturn.AutoFarm and _t%0.15<dt then
        local e=FindEnemy(2000)
        if e then local eH=e:FindFirstChild("HumanoidRootPart"); local eM=e:FindFirstChildOfClass("Humanoid")
            if eH and eM and eM.Health>0 then
                hrp.CFrame=CFrame.new(eH.Position+Vector3.new(5,0,0))
                local tool=Char():FindFirstChildOfClass("Tool")
                if tool then local re=tool:FindFirstChild("R") or tool:FindFirstChildOfClass("RemoteEvent")
                    if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(eH.Position,eH) end) end end
            end
        end
    end

    if _G.Saturn.AutoQuest and _t%1<dt then
        local stats=LP:FindFirstChild("leaderstats") or LP:FindFirstChild("Data")
        if stats then local lv=stats:FindFirstChild("Level") or stats:FindFirstChild("Lv")
            local rem=ReplicatedStorage:FindFirstChild("Remotes")
            if lv and rem then local qr=rem:FindFirstChild("Management") or rem:FindFirstChild("Quest")
                if qr then pcall(function() qr:FireServer("Quest",lv.Value) end) end end
        end
    end

    if _G.Saturn.AutoStats and _t%2<dt then
        local rem=ReplicatedStorage:FindFirstChild("Remotes")
        if rem then local ir=rem:FindFirstChild("Invest_Stats")
            if ir then pcall(function() ir:FireServer(_G.Saturn.StatType) end) end end
    end

    if _G.Saturn.FruitESP and _t%1<dt then
        for _, h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatFruitESP" then h:Destroy() end
        end
        for _, fruit in ipairs(FindFruits()) do
            if not fruit:FindFirstChild("_SatFruitESP") then
                local hl=Instance.new("Highlight"); hl.Name="_SatFruitESP"
                hl.FillColor=Color3.fromRGB(0,70,220); hl.OutlineColor=Color3.fromRGB(0,180,255)
                hl.FillTransparency=0.3; hl.Parent=fruit
            end
        end
    end

    if _G.Saturn.FruitNotify and _t%1<dt then
        for _, fruit in ipairs(FindFruits()) do
            if not fruit:FindFirstChild("_SatNotified") then
                Instance.new("BoolValue", fruit).Name="_SatNotified"
                Notify("🍎 Fruit Spawnada!", fruit.Name.." detectada!", 8)
            end
        end
    end

    if _G.Saturn.FruitSniper and _t%0.5<dt then
        local fruits=FindFruits()
        if #fruits>0 then
            local f=fruits[1]; local pos=f:IsA("Model") and f:GetModelCFrame().Position or f.Position
            if (hrp.Position-pos).Magnitude>10 then hrp.CFrame=CFrame.new(pos+Vector3.new(3,2,0)) end
        end
    end

    if _G.Saturn.PlayerESP and _t%1<dt then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl~=LP and pl.Character and not pl.Character:FindFirstChild("_SatPlayerESP") then
                local hl=Instance.new("Highlight"); hl.Name="_SatPlayerESP"
                hl.FillColor=Color3.fromRGB(0,40,190); hl.OutlineColor=Color3.fromRGB(0,150,255)
                hl.FillTransparency=0.5; hl.Parent=pl.Character
            end
        end
    end
end)

-- ─── LOAD SATURN IMAGE (Delta: getcustomasset) ─────────
task.spawn(function()
    local loaded = false
    pcall(function()
        if typeof(request) == "function" then
            local res = request({Url=IMG_URL, Method="GET"})
            if res and res.Body and #res.Body > 100 then
                writefile("_sat.jpg", res.Body)
                local path = getcustomasset("_sat.jpg")
                FloatBtn.Image  = path
                KImg.Image      = path
                TopLogo.Image   = path
                loaded = true
            end
        end
    end)
    if not loaded then
        local fb = "rbxassetid://6031907432"
        FloatBtn.Image=fb; KImg.Image=fb; TopLogo.Image=fb
    end
end)

print("[Saturn Hub] ✓ Online | "..CFG.Credits)
