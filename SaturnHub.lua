--[[
╔══════════════════════════════════════════════════════╗
║           SATURN HUB v2.0  |  Blox Fruits           ║
║           Creditos: @matheuz.z7                      ║
╚══════════════════════════════════════════════════════╝
  loadstring(game:HttpGet("https://raw.githubusercontent.com/thzzxq7/SaturnHub/main/SaturnHub.lua"))()
]]

-- ══════════════════════════════════════════════════════
local GITHUB = "https://raw.githubusercontent.com/thzzxq7/SaturnHub/main/"
-- ══════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera
local GuiParent = (typeof(gethui)=="function" and gethui()) or PlayerGui

local IMG_URL = GITHUB.."saturn.jpg"

-- COLORS
local C = {
    BG          = Color3.fromRGB(5,    5,  18),
    BG2         = Color3.fromRGB(8,    8,  28),
    Panel       = Color3.fromRGB(10,  10,  35),
    TopBar      = Color3.fromRGB(0,    6,  28),
    Accent      = Color3.fromRGB(30, 100, 255),
    AccentBright= Color3.fromRGB(80, 160, 255),
    AccentDark  = Color3.fromRGB(0,   30, 100),
    AccentGlow  = Color3.fromRGB(0,   60, 200),
    Text        = Color3.fromRGB(220, 235, 255),
    TextDim     = Color3.fromRGB(90,  120, 180),
    TextDark    = Color3.fromRGB(50,   70, 120),
    Element     = Color3.fromRGB(12,  14,  42),
    Element2    = Color3.fromRGB(15,  18,  52),
    Stroke      = Color3.fromRGB(30,  60, 160),
    StrokeDim   = Color3.fromRGB(15,  30,  80),
    Green       = Color3.fromRGB(40, 220, 100),
    Red         = Color3.fromRGB(220,  50,  50),
    White       = Color3.new(1,1,1),
}

-- HELPERS
local function Make(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do pcall(function() o[k]=v end) end
    return o
end

local function Tween(obj, goal, t, style, dir)
    local ti = TweenInfo.new(t or .2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, goal):Play()
end

local function Spring(obj, goal, t)
    Tween(obj, goal, t or .35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Corner(p, r)
    return Make("UICorner",{CornerRadius=UDim.new(0, r or 8), Parent=p})
end

local function Stroke_(p, c, t)
    return Make("UIStroke",{Color=c or C.Stroke, Thickness=t or 1.5, Parent=p})
end

local function Pad(p, top, left, right, bot)
    return Make("UIPadding",{
        PaddingTop=UDim.new(0,top or 0), PaddingLeft=UDim.new(0,left or 0),
        PaddingRight=UDim.new(0,right or 0), PaddingBottom=UDim.new(0,bot or 0),
        Parent=p
    })
end

local function Gradient(p, c1, c2, rot)
    return Make("UIGradient",{
        Color=ColorSequence.new(c1,c2), Rotation=rot or 90, Parent=p
    })
end

-- CHARACTER REFS
local function Char()  return LP.Character end
local function HRP()   local c=Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()   local c=Char(); return c and c:FindFirstChildOfClass("Humanoid") end

-- STATE
_G.Saturn = {
    -- toggles
    AutoFarm=false, AutoQuest=false, AutoBoss=false, AutoChest=false,
    AutoRaid=false, AutoEvent=false, AutoStats=false,
    AutoMasterySword=false, AutoMasteryGun=false, AutoMasteryFruit=false,
    KillAura=false, HitboxExpand=false, GodMode=false, AutoHaki=false,
    FlyEnabled=false, NoClip=false, InfiniteJump=false,
    InfiniteEnergy=false, FastAttack=false,
    FruitESP=false, PlayerESP=false, FruitSniper=false, FruitNotify=false,
    AutoEatFruit=false, BringPlayer=false,
    AntiAFK=true, AntiLag=false, ReJoinOnDeath=false,
    -- values
    Speed=50, FlySpeed=100, KillAuraRange=30, HitboxSize=10,
    StatType="Melee", FarmTarget="Automatic (By Level)",
    TargetPlayer=nil, SelectedIsland=nil,
}

-- CLEANUP
local old = GuiParent:FindFirstChild("SaturnHub_v2")
if old then old:Destroy() end

-- ══════════════════════════════════════════════════════
-- ROOT GUI
-- ══════════════════════════════════════════════════════
local SG = Make("ScreenGui",{
    Name="SaturnHub_v2", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=GuiParent,
})

-- ══════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ══════════════════════════════════════════════════════
local NH = Make("Frame",{
    Size=UDim2.new(0,240,1,0), Position=UDim2.new(1,-252,0,16),
    BackgroundTransparency=1, Parent=SG, ZIndex=100,
})
Make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8), Parent=NH})

local function Notify(title, msg, dur, ntype)
    local color = ntype=="warn" and C.Red or C.Accent
    local f = Make("Frame",{
        Size=UDim2.new(1,0,0,62), BackgroundColor3=C.BG2,
        BackgroundTransparency=0, ZIndex=101, Parent=NH,
    })
    Corner(f,8)
    -- left color bar
    local bar = Make("Frame",{
        Size=UDim2.new(0,3,1,0), BackgroundColor3=color,
        BorderSizePixel=0, ZIndex=102, Parent=f,
    })
    Corner(bar,2)
    Make("TextLabel",{
        Size=UDim2.new(1,-16,0,20), Position=UDim2.new(0,12,0,8),
        BackgroundTransparency=1, Text=title,
        TextColor3=color, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=102, Parent=f,
    })
    Make("TextLabel",{
        Size=UDim2.new(1,-16,0,26), Position=UDim2.new(0,12,0,28),
        BackgroundTransparency=1, Text=msg, TextColor3=C.Text,
        TextSize=11, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
        ZIndex=102, Parent=f,
    })
    f.Position = UDim2.new(1,10,0,0)
    Spring(f, {Position=UDim2.new(0,0,0,0)}, .4)
    task.delay(dur or 4, function()
        Tween(f,{Position=UDim2.new(1,10,0,0)}, .3)
        task.wait(.35); pcall(function() f:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════
-- FLOATING BUTTON
-- ══════════════════════════════════════════════════════
local FloatBtn = Make("ImageButton",{
    Size=UDim2.new(0,60,0,60),
    Position=UDim2.new(0,24,0.5,-30),
    BackgroundColor3=C.BG2, Image="",
    ScaleType=Enum.ScaleType.Fit, Parent=SG, ZIndex=10,
})
Corner(FloatBtn,10)
Stroke_(FloatBtn, C.Accent, 2)

-- glow layers
local function MakeGlow(parent, size, alpha, color)
    local g = Make("Frame",{
        Size=UDim2.new(1,size,1,size),
        Position=UDim2.new(0,-size/2,0,-size/2),
        BackgroundColor3=color or C.Accent,
        BackgroundTransparency=alpha, ZIndex=parent.ZIndex-1, Parent=parent,
    })
    Corner(g, 10+size/2)
    return g
end
local glow1 = MakeGlow(FloatBtn, 10, 0.65, C.Accent)
local glow2 = MakeGlow(FloatBtn, 20, 0.80, C.AccentGlow)

task.spawn(function()
    while FloatBtn.Parent do
        Tween(glow1,{BackgroundTransparency=0.45},1,Enum.EasingStyle.Sine)
        Tween(glow2,{BackgroundTransparency=0.65},1,Enum.EasingStyle.Sine)
        task.wait(1)
        Tween(glow1,{BackgroundTransparency=0.75},1,Enum.EasingStyle.Sine)
        Tween(glow2,{BackgroundTransparency=0.88},1,Enum.EasingStyle.Sine)
        task.wait(1)
    end
end)

-- float drag
do
    local drag,ds,sp=false
    FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=FloatBtn.Position
        end
    end)
    FloatBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            FloatBtn.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════
-- KEY PANEL
-- ══════════════════════════════════════════════════════
local KP = Make("Frame",{
    Size=UDim2.new(0,300,0,300),
    Position=UDim2.new(0.5,-150,0.5,-150),
    BackgroundColor3=C.BG, Visible=false, Parent=SG, ZIndex=20,
})
Corner(KP,14)
Stroke_(KP, C.Accent, 2)
Gradient(KP, C.BG, C.BG2, 135)

-- topbar KP
local KT = Make("Frame",{Size=UDim2.new(1,0,0,40), BackgroundColor3=C.TopBar, Parent=KP, ZIndex=21})
Corner(KT,14)
Make("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=C.TopBar,BorderSizePixel=0,ZIndex=21,Parent=KT})
Make("TextLabel",{
    Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,14,0,0),
    BackgroundTransparency=1, Text="SATURN HUB  -  LOGIN",
    TextColor3=C.Accent, TextSize=12, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22, Parent=KT,
})
local KX = Make("TextButton",{
    Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-30,.5,-12),
    BackgroundColor3=C.Red, Text="x", TextColor3=C.White,
    TextSize=11, Font=Enum.Font.GothamBold, ZIndex=22, Parent=KT,
})
Corner(KX,5)
KX.MouseButton1Click:Connect(function()
    Tween(KP,{Position=UDim2.new(.5,-150,.65,-150),BackgroundTransparency=1},.2)
    task.wait(.25); KP.Visible=false; KP.BackgroundTransparency=0
end)

-- image
local KImg = Make("ImageLabel",{
    Size=UDim2.new(0,72,0,72),Position=UDim2.new(.5,-36,0,50),
    BackgroundColor3=C.BG, Image="", ScaleType=Enum.ScaleType.Fit,
    ZIndex=22, Parent=KP,
})
Corner(KImg,36)
Stroke_(KImg, C.Accent, 2)

Make("TextLabel",{
    Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,130),
    BackgroundTransparency=1, Text="SATURN HUB",
    TextColor3=C.Text, TextSize=15, Font=Enum.Font.GothamBold,
    ZIndex=22, Parent=KP,
})
Make("TextLabel",{
    Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,150),
    BackgroundTransparency=1, Text="Blox Fruits | @matheuz.z7",
    TextColor3=C.TextDim, TextSize=11, Font=Enum.Font.Gotham,
    ZIndex=22, Parent=KP,
})

local KInp = Make("TextBox",{
    Size=UDim2.new(1,-40,0,36),Position=UDim2.new(0,20,0,172),
    BackgroundColor3=C.Element, Text="", PlaceholderText="Digite a chave...",
    TextColor3=C.Text, PlaceholderColor3=C.TextDim,
    TextSize=12, Font=Enum.Font.Gotham, ClearTextOnFocus=false,
    ZIndex=22, Parent=KP,
})
Corner(KInp,7)
Stroke_(KInp, C.Stroke, 1.5)

local KBtn = Make("TextButton",{
    Size=UDim2.new(1,-40,0,36),Position=UDim2.new(0,20,0,216),
    BackgroundColor3=C.AccentDark, Text="ENTRAR",
    TextColor3=C.White, TextSize=12, Font=Enum.Font.GothamBold,
    ZIndex=22, Parent=KP,
})
Corner(KBtn,7)
Stroke_(KBtn, C.Accent, 1.5)

local KErr = Make("TextLabel",{
    Size=UDim2.new(1,-40,0,14),Position=UDim2.new(0,20,0,258),
    BackgroundTransparency=1, Text="",
    TextColor3=C.Red, TextSize=11, Font=Enum.Font.Gotham,
    ZIndex=22, Parent=KP,
})
Make("TextLabel",{
    Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-18),
    BackgroundTransparency=1, Text="creditos: @matheuz.z7",
    TextColor3=C.TextDark, TextSize=10, Font=Enum.Font.Gotham,
    ZIndex=22, Parent=KP,
})

-- ══════════════════════════════════════════════════════
-- MAIN HUB
-- ══════════════════════════════════════════════════════
local Hub = Make("Frame",{
    Size=UDim2.new(0,620,0,440),
    Position=UDim2.new(.5,-310,.5,-220),
    BackgroundColor3=C.BG, Visible=false, Parent=SG, ZIndex=5,
})
Corner(Hub,14)
Stroke_(Hub, C.Accent, 2)
Gradient(Hub, C.BG, C.BG2, 160)

-- top bar
local HBar = Make("Frame",{Size=UDim2.new(1,0,0,48), BackgroundColor3=C.TopBar, ZIndex=6, Parent=Hub})
Corner(HBar,14)
Make("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=C.TopBar,BorderSizePixel=0,ZIndex=6,Parent=HBar})
-- accent line
Make("Frame",{
    Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-1),
    BackgroundColor3=C.Accent, BorderSizePixel=0, ZIndex=7, Parent=HBar,
})

local TLogo = Make("ImageLabel",{
    Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,.5,-15),
    BackgroundColor3=C.BG, Image="", ScaleType=Enum.ScaleType.Fit,
    ZIndex=7, Parent=HBar,
})
Corner(TLogo,15)
Stroke_(TLogo, C.Accent, 1.5)

Make("TextLabel",{
    Size=UDim2.new(0,160,0,18),Position=UDim2.new(0,46,0,8),
    BackgroundTransparency=1, Text="SATURN HUB",
    TextColor3=C.Text, TextSize=14, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7, Parent=HBar,
})
Make("TextLabel",{
    Size=UDim2.new(0,220,0,13),Position=UDim2.new(0,46,0,27),
    BackgroundTransparency=1, Text="v2.0  |  Blox Fruits  |  @matheuz.z7",
    TextColor3=C.TextDim, TextSize=10, Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7, Parent=HBar,
})

-- minimize / close
local HMin = Make("TextButton",{
    Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-62,.5,-12),
    BackgroundColor3=Color3.fromRGB(180,130,0), Text="-",
    TextColor3=C.White, TextSize=14, Font=Enum.Font.GothamBold,
    ZIndex=7, Parent=HBar,
})
Corner(HMin,5)
local HClose = Make("TextButton",{
    Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,.5,-12),
    BackgroundColor3=C.Red, Text="x",
    TextColor3=C.White, TextSize=11, Font=Enum.Font.GothamBold,
    ZIndex=7, Parent=HBar,
})
Corner(HClose,5)

local minimized=false
HMin.MouseButton1Click:Connect(function()
    minimized=not minimized
    Spring(Hub,{Size=minimized and UDim2.new(0,620,0,48) or UDim2.new(0,620,0,440)},.3)
end)
HClose.MouseButton1Click:Connect(function()
    Tween(Hub,{Size=UDim2.new(0,0,0,0)},.2)
    task.wait(.25); Hub.Visible=false
    Hub.Size=UDim2.new(0,620,0,440)
    FloatBtn.Visible=true
end)

-- drag
do
    local drag,ds,sp=false
    HBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=Hub.Position end
    end)
    HBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Hub.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ── SIDEBAR ────────────────────────────────────────────
local Sidebar = Make("Frame",{
    Size=UDim2.new(0,138,1,-50),Position=UDim2.new(0,0,0,50),
    BackgroundColor3=Color3.fromRGB(3,3,15), BorderSizePixel=0, ZIndex=6, Parent=Hub,
})
Make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=Sidebar})
Pad(Sidebar,8,6,6,8)
Make("TextLabel",{
    Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-18),
    BackgroundTransparency=1,Text="@matheuz.z7",
    TextColor3=C.TextDark,TextSize=10,Font=Enum.Font.Gotham,
    ZIndex=7,Parent=Sidebar,
})

-- sidebar divider
Make("Frame",{
    Size=UDim2.new(0,1,1,-50),Position=UDim2.new(0,138,0,50),
    BackgroundColor3=C.StrokeDim, BorderSizePixel=0, ZIndex=6, Parent=Hub,
})

-- ── CONTENT ────────────────────────────────────────────
local Content = Make("Frame",{
    Size=UDim2.new(1,-140,1,-50),Position=UDim2.new(0,140,0,50),
    BackgroundTransparency=1, ClipsDescendants=true, ZIndex=6, Parent=Hub,
})

-- ══════════════════════════════════════════════════════
-- ELEMENT BUILDERS
-- ══════════════════════════════════════════════════════

-- Scroll frame that actually works in executor context
local function MakeScroll(parent)
    local sf = Make("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.new(0,0,0,2000), -- large fixed size; updated after build
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ZIndex=7, Parent=parent,
    })
    local layout = Make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=sf})
    Pad(sf,10,10,14,10)
    return sf, layout
end

local function FixCanvas(sf, layout)
    -- call after all elements added
    task.wait()
    sf.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+30)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+30)
    end)
end

local function Section(parent, text)
    local f = Make("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,ZIndex=8,Parent=parent})
    Make("TextLabel",{
        Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,5),
        BackgroundTransparency=1, Text=string.upper(text),
        TextColor3=C.Accent, TextSize=10, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9, Parent=f,
    })
    Make("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.StrokeDim, BorderSizePixel=0, ZIndex=9, Parent=f,
    })
    return f
end

local function Toggle(parent, label, default, cb)
    local state = default or false
    local f = Make("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.Element,ZIndex=8,Parent=parent})
    Corner(f,8)
    -- hover effect
    local ov=Make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10,Parent=f})
    ov.MouseEnter:Connect(function() Tween(f,{BackgroundColor3=C.Element2},.12) end)
    ov.MouseLeave:Connect(function() Tween(f,{BackgroundColor3=C.Element},.12) end)
    Make("TextLabel",{
        Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, Text=label, TextColor3=C.Text,
        TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=9, Parent=f,
    })
    local bg=Make("Frame",{
        Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-46,.5,-10),
        BackgroundColor3=state and C.Accent or C.AccentDark, ZIndex=9, Parent=f,
    })
    Corner(bg,10)
    Gradient(bg, state and C.AccentBright or C.AccentDark, state and C.Accent or C.AccentDark)
    local dot=Make("Frame",{
        Size=UDim2.new(0,14,0,14),
        Position=state and UDim2.new(1,-17,.5,-7) or UDim2.new(0,3,.5,-7),
        BackgroundColor3=C.White, ZIndex=10, Parent=bg,
    })
    Corner(dot,7)
    -- shadow on dot
    Make("UIStroke",{Color=Color3.fromRGB(0,0,0),Transparency=0.6,Thickness=1,Parent=dot})
    ov.MouseButton1Click:Connect(function()
        state=not state
        Tween(bg,{BackgroundColor3=state and C.Accent or C.AccentDark},.2)
        Spring(dot,{Position=state and UDim2.new(1,-17,.5,-7) or UDim2.new(0,3,.5,-7)},.3)
        -- update gradient
        local g=bg:FindFirstChildOfClass("UIGradient")
        if g then Tween(g,{Color=ColorSequence.new(state and C.AccentBright or C.AccentDark, state and C.Accent or C.AccentDark)},.2) end
        cb(state)
    end)
    return f
end

local function Button(parent, label, cb)
    local f=Make("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.Element,ZIndex=8,Parent=parent})
    Corner(f,8)
    -- inner glow line top
    Make("Frame",{
        Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),
        BackgroundColor3=C.Stroke, BorderSizePixel=0, ZIndex=9, Parent=f,
    })
    local lbl=Make("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=label, TextColor3=C.TextDim, TextSize=12, Font=Enum.Font.GothamBold,
        ZIndex=9, Parent=f,
    })
    local b=Make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10,Parent=f})
    b.MouseEnter:Connect(function()
        Tween(f,{BackgroundColor3=C.AccentDark},.15)
        Tween(lbl,{TextColor3=C.AccentBright},.15)
    end)
    b.MouseLeave:Connect(function()
        Tween(f,{BackgroundColor3=C.Element},.15)
        Tween(lbl,{TextColor3=C.TextDim},.15)
    end)
    b.MouseButton1Click:Connect(function()
        Tween(f,{BackgroundColor3=C.Accent},.08)
        task.wait(.08); Tween(f,{BackgroundColor3=C.AccentDark},.2)
        cb()
    end)
    return f
end

local function Slider(parent, label, mn, mx, def, suf, cb)
    local f=Make("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=C.Element,ZIndex=8,Parent=parent})
    Corner(f,8)
    local vl=Make("TextLabel",{
        Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,12,0,5),
        BackgroundTransparency=1, Text=label..":  "..def..(suf or ""),
        TextColor3=C.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9, Parent=f,
    })
    local valDisp=Make("TextLabel",{
        Size=UDim2.new(0,60,0,18),Position=UDim2.new(1,-70,0,5),
        BackgroundTransparency=1, Text=tostring(def)..(suf or ""),
        TextColor3=C.Accent, TextSize=11, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=9, Parent=f,
    })
    local track=Make("Frame",{
        Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,34),
        BackgroundColor3=C.AccentDark, ZIndex=9, Parent=f,
    })
    Corner(track,3)
    local r0=(def-mn)/(mx-mn)
    local fill=Make("Frame",{Size=UDim2.new(r0,0,1,0),BackgroundColor3=C.Accent,ZIndex=10,Parent=track})
    Corner(fill,3)
    Gradient(fill, C.AccentBright, C.Accent)
    local thumb=Make("Frame",{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(r0,-8,.5,-8),
        BackgroundColor3=C.White, ZIndex=11, Parent=track,
    })
    Corner(thumb,8)
    Make("UIStroke",{Color=C.Accent,Thickness=2,Parent=thumb})
    local sliding=false
    local function upd(x)
        local r=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor(mn+r*(mx-mn)+.5)
        fill.Size=UDim2.new(r,0,1,0)
        thumb.Position=UDim2.new(r,-8,.5,-8)
        valDisp.Text=v..(suf or "")
        cb(v)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true;upd(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)
    return f
end

local function Dropdown(parent, label, opts, def, cb)
    local open=false; local cur=def or opts[1] or ""
    local f=Make("Frame",{
        Size=UDim2.new(1,0,0,38),BackgroundColor3=C.Element,
        ClipsDescendants=false, ZIndex=8, Parent=parent,
    })
    Corner(f,8)
    local shown=Make("TextLabel",{
        Size=UDim2.new(1,-42,1,0),Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, Text=label..":  "..cur,
        TextColor3=C.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,
        ZIndex=9, Parent=f,
    })
    local arr=Make("TextLabel",{
        Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-30,0,0),
        BackgroundTransparency=1, Text="v",
        TextColor3=C.Accent, TextSize=11, Font=Enum.Font.GothamBold,
        ZIndex=9, Parent=f,
    })
    local list=Make("Frame",{
        Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,4),
        BackgroundColor3=C.Element2, ClipsDescendants=true,
        ZIndex=15, Parent=f,
    })
    Corner(list,8)
    Stroke_(list,C.Stroke,1)
    Make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=list})
    for _,opt in ipairs(opts) do
        local ob=Make("TextButton",{
            Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,
            Text="  "..opt, TextColor3=C.TextDim, TextSize=11, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=16, Parent=list,
        })
        ob.MouseEnter:Connect(function() Tween(ob,{BackgroundTransparency=0,BackgroundColor3=C.AccentDark},.1) end)
        ob.MouseLeave:Connect(function() Tween(ob,{BackgroundTransparency=1},.1) end)
        ob.MouseButton1Click:Connect(function()
            cur=opt; shown.Text=label..":  "..opt; cb(opt)
            Tween(list,{Size=UDim2.new(1,0,0,0)},.2)
            Tween(arr,{Rotation=0},.2); open=false
        end)
    end
    local th=#opts*30
    Make("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10,Parent=f
    }).MouseButton1Click:Connect(function()
        open=not open
        Tween(list,{Size=UDim2.new(1,0,0,open and math.min(th,180) or 0)},.2)
        Tween(arr,{Rotation=open and 180 or 0},.2)
    end)
    return f
end

-- ══════════════════════════════════════════════════════
-- TAB SYSTEM
-- ══════════════════════════════════════════════════════
local TabBtns, Pages, Scrolls, Layouts = {},{},{},{}
local ActiveTab=nil

local TabDefs={
    {name="Combat",  icon="[ C ]"},
    {name="Farm",    icon="[ F ]"},
    {name="Fruit",   icon="[ Fr]"},
    {name="Player",  icon="[ P ]"},
    {name="Movement",icon="[ M ]"},
    {name="Misc",    icon="[ X ]"},
}

-- indicator bar
local SelBar=Make("Frame",{
    Size=UDim2.new(0,3,0,36),Position=UDim2.new(0,0,0,8),
    BackgroundColor3=C.Accent, BorderSizePixel=0, ZIndex=8, Parent=Sidebar,
})
Corner(SelBar,2)

local function SelectTab(name)
    for n,btn in pairs(TabBtns) do
        local sel=(n==name)
        Tween(btn,{BackgroundColor3=sel and C.AccentDark or C.BG, BackgroundTransparency=sel and 0 or 1},.2)
        local tl=btn:FindFirstChildOfClass("TextLabel")
        if tl then Tween(tl,{TextColor3=sel and C.Text or C.TextDim},.2) end
    end
    for n,pg in pairs(Pages) do pg.Visible=(n==name) end
    ActiveTab=name

    -- animate indicator bar to selected button
    local btn=TabBtns[name]
    if btn then
        local idx=0
        for i,def in ipairs(TabDefs) do if def.name==name then idx=i break end end
        local yPos=8+(idx-1)*40
        Spring(SelBar,{Position=UDim2.new(0,0,0,yPos)},.35)
    end
end

for idx, def in ipairs(TabDefs) do
    local btn=Make("TextButton",{
        Size=UDim2.new(1,0,0,36), BackgroundColor3=C.BG,
        BackgroundTransparency=1, Text="", ZIndex=7, Parent=Sidebar,
    })
    Corner(btn,7)
    Make("TextLabel",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=def.name, TextColor3=C.TextDim,
        TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8, Parent=btn,
    })
    Pad(btn:FindFirstChildOfClass("TextLabel"),0,14,0,0)

    local pg=Make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,ZIndex=7,Parent=Content})
    local sf,ly=MakeScroll(pg)
    TabBtns[def.name]=btn; Pages[def.name]=pg
    Scrolls[def.name]=sf; Layouts[def.name]=ly

    btn.MouseButton1Click:Connect(function()
        -- slide animation
        local prev=Pages[ActiveTab]
        if prev then
            Tween(prev,{Position=UDim2.new(-0.08,0,0,0)},.18)
            task.wait(.12); prev.Visible=false; prev.Position=UDim2.new(0,0,0,0)
        end
        pg.Position=UDim2.new(0.08,0,0,0)
        pg.Visible=true
        Tween(pg,{Position=UDim2.new(0,0,0,0)},.22)
        SelectTab(def.name)
    end)
    btn.MouseEnter:Connect(function()
        if ActiveTab~=def.name then Tween(btn,{BackgroundTransparency=0.6,BackgroundColor3=C.AccentDark},.12) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab~=def.name then Tween(btn,{BackgroundTransparency=1},.12) end
    end)
end

-- ══════════════════════════════════════════════════════
-- COMBAT
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Combat"]; local ly=Layouts["Combat"]
    Section(sf,"Kill Aura")
    Toggle(sf,"Kill Aura",false,function(v) _G.Saturn.KillAura=v end)
    Slider(sf,"Alcance",10,100,30," st",function(v) _G.Saturn.KillAuraRange=v end)
    Section(sf,"Hitbox")
    Toggle(sf,"Hitbox Expander",false,function(v) _G.Saturn.HitboxExpand=v end)
    Slider(sf,"Tamanho do Hitbox",5,50,10," st",function(v) _G.Saturn.HitboxSize=v end)
    Section(sf,"Defesa")
    Toggle(sf,"God Mode (Max HP)",false,function(v) _G.Saturn.GodMode=v end)
    Toggle(sf,"Infinite Energy / Mana",false,function(v) _G.Saturn.InfiniteEnergy=v end)
    Section(sf,"Ataque")
    Toggle(sf,"Fast Attack (2.5x)",false,function(v)
        _G.Saturn.FastAttack=v
        local h=Hum(); if not h then return end
        for _,t in ipairs(LP.Backpack:GetChildren()) do
            if t:IsA("Tool") then for _,a in ipairs(t:GetDescendants()) do
                if a:IsA("Animation") then local tr=h:LoadAnimation(a); if tr then tr:AdjustSpeed(v and 2.5 or 1) end end
            end end
        end
    end)
    Toggle(sf,"Auto Haki",false,function(v) _G.Saturn.AutoHaki=v end)
    FixCanvas(sf,ly)
end

-- ══════════════════════════════════════════════════════
-- FARM
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Farm"]; local ly=Layouts["Farm"]
    Section(sf,"Auto Farm")
    Dropdown(sf,"Alvo",{
        "Automatic (By Level)","Bandits","Pirates","Monkey","Gorilla",
        "Sword Master","Black Beard","Swan","Wysper","Thunder God",
        "Diamante","Pica","Rip_Indra","Sea Beast","Dragon",
    },"Automatic (By Level)",function(v) _G.Saturn.FarmTarget=v end)
    Toggle(sf,"Auto Farm",false,function(v)
        _G.Saturn.AutoFarm=v
        if v then Notify("Auto Farm","Ativado: ".._G.Saturn.FarmTarget,4) end
    end)
    Toggle(sf,"Auto Quest",false,function(v) _G.Saturn.AutoQuest=v end)
    Section(sf,"Boss & Baús")
    Toggle(sf,"Auto Boss Farm",false,function(v) _G.Saturn.AutoBoss=v end)
    Toggle(sf,"Auto Chest Farm",false,function(v) _G.Saturn.AutoChest=v end)
    Section(sf,"Raid & Events")
    Toggle(sf,"Auto Raid",false,function(v) _G.Saturn.AutoRaid=v end)
    Toggle(sf,"Auto Sea Event",false,function(v) _G.Saturn.AutoEvent=v end)
    Section(sf,"Mastery Farm")
    Toggle(sf,"Auto Mastery - Espada",false,function(v) _G.Saturn.AutoMasterySword=v end)
    Toggle(sf,"Auto Mastery - Gun",false,function(v) _G.Saturn.AutoMasteryGun=v end)
    Toggle(sf,"Auto Mastery - Fruta",false,function(v) _G.Saturn.AutoMasteryFruit=v end)
    FixCanvas(sf,ly)
end

-- ══════════════════════════════════════════════════════
-- FRUIT
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Fruit"]; local ly=Layouts["Fruit"]
    Section(sf,"ESP & Radar")
    Toggle(sf,"Fruit ESP",false,function(v)
        _G.Saturn.FruitESP=v
        if not v then for _,h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatFruitESP" then h:Destroy() end
        end end
    end)
    Toggle(sf,"Fruit Notifier",false,function(v) _G.Saturn.FruitNotify=v end)
    Section(sf,"Sniper & Auto")
    Toggle(sf,"Fruit Sniper (Auto TP)",false,function(v) _G.Saturn.FruitSniper=v end)
    Toggle(sf,"Auto Comer Fruta",false,function(v) _G.Saturn.AutoEatFruit=v end)
    Button(sf,"Listar Frutas no Chat",function()
        local fruits={}
        for _,obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:find("Fruit") then
                table.insert(fruits,obj.Name)
            end
        end
        Notify("Frutas no Mapa",#fruits>0 and table.concat(fruits,", ") or "Nenhuma encontrada",6)
    end)
    FixCanvas(sf,ly)
end

-- ══════════════════════════════════════════════════════
-- PLAYER
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Player"]; local ly=Layouts["Player"]
    Section(sf,"ESP")
    Toggle(sf,"Player ESP",false,function(v)
        _G.Saturn.PlayerESP=v
        if not v then for _,h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatPlayerESP" then h:Destroy() end
        end end
    end)
    Section(sf,"Teleporte")
    local pNames={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(pNames,p.Name) end end
    if #pNames>0 then
        Dropdown(sf,"Jogador",pNames,pNames[1],function(v) _G.Saturn.TargetPlayer=v end)
    else
        Dropdown(sf,"Jogador",{"(nenhum)"},"(nenhum)",function() end)
    end
    Button(sf,"Teleportar para Jogador",function()
        local n=_G.Saturn.TargetPlayer; if not n then Notify("Aviso","Selecione um jogador.",3,"warn") return end
        local p=Players:FindFirstChild(n)
        if p and p.Character then
            local th=p.Character:FindFirstChild("HumanoidRootPart"); local mh=HRP()
            if th and mh then mh.CFrame=th.CFrame+Vector3.new(3,0,0) end
        end
    end)
    Toggle(sf,"Bring Player (TP para mim)",false,function(v) _G.Saturn.BringPlayer=v end)
    Button(sf,"Bring Jogador Selecionado",function()
        local n=_G.Saturn.TargetPlayer; if not n then Notify("Aviso","Selecione um jogador.",3,"warn") return end
        local p=Players:FindFirstChild(n)
        if p and p.Character then
            local th=p.Character:FindFirstChild("HumanoidRootPart"); local mh=HRP()
            if mh and th then th.CFrame=mh.CFrame+Vector3.new(3,0,0) end
        end
    end)
    FixCanvas(sf,ly)
end

-- ══════════════════════════════════════════════════════
-- MOVEMENT
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Movement"]; local ly=Layouts["Movement"]
    Section(sf,"Speed & Jump")
    Slider(sf,"Walk Speed",16,500,50," ws",function(v)
        _G.Saturn.Speed=v; local h=Hum(); if h then h.WalkSpeed=v end
    end)
    Slider(sf,"Jump Height",7,300,7," jp",function(v)
        local h=Hum(); if h then h.JumpHeight=v end
    end)
    Toggle(sf,"Infinite Jump",false,function(v) _G.Saturn.InfiniteJump=v end)
    Section(sf,"Fly")
    Toggle(sf,"Fly (W/A/S/D + Space/Ctrl)",false,function(v) _G.Saturn.FlyEnabled=v end)
    Slider(sf,"Fly Speed",20,500,100," ws",function(v) _G.Saturn.FlySpeed=v end)
    Section(sf,"Misc")
    Toggle(sf,"No Clip",false,function(v) _G.Saturn.NoClip=v end)
    Toggle(sf,"Rejoin ao Morrer",false,function(v) _G.Saturn.ReJoinOnDeath=v end)
    Section(sf,"Teleporte - Ilhas")
    local Islands={
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
    local iList={}; for k in pairs(Islands) do table.insert(iList,k) end; table.sort(iList)
    Dropdown(sf,"Ilha",iList,iList[1],function(v) _G.Saturn.SelectedIsland=v end)
    Button(sf,"Teleportar para Ilha",function()
        local n=_G.Saturn.SelectedIsland
        if n and Islands[n] then local h=HRP(); if h then h.CFrame=Islands[n] end
        else Notify("Aviso","Selecione uma ilha.",3,"warn") end
    end)
    FixCanvas(sf,ly)
end

-- ══════════════════════════════════════════════════════
-- MISC
-- ══════════════════════════════════════════════════════
do
    local sf=Scrolls["Misc"]; local ly=Layouts["Misc"]
    Section(sf,"Auto Stats")
    Toggle(sf,"Auto Stats",false,function(v) _G.Saturn.AutoStats=v end)
    Dropdown(sf,"Stat Priority",{"Melee","Defense","Sword","Gun","Blox Fruit"},"Melee",function(v) _G.Saturn.StatType=v end)
    Section(sf,"Performance")
    Toggle(sf,"Anti Lag",false,function(v)
        _G.Saturn.AntiLag=v
        if v then
            Lighting.GlobalShadows=false
            workspace.StreamingEnabled=pcall(function() workspace.StreamingEnabled=false end)
            for _,p in ipairs(workspace:GetDescendants()) do
                if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam") then
                    p.Enabled=false
                end
            end
            Notify("Anti Lag","Particulas e sombras desativadas.",3)
        else
            Lighting.GlobalShadows=true
        end
    end)
    Section(sf,"Servidor")
    Button(sf,"Server Hop",function()
        local TS=game:GetService("TeleportService")
        local ok,res=pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and res and res.data then
            local valid={}
            for _,s in ipairs(res.data) do
                if s.id~=game.JobId and s.playing<s.maxPlayers then table.insert(valid,s.id) end
            end
            if #valid>0 then TS:TeleportToPlaceInstance(game.PlaceId,valid[math.random(1,#valid)],LP)
            else Notify("Server Hop","Sem servidores disponiveis.",3,"warn") end
        end
    end)
    Button(sf,"Rejoin",function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
    end)
    Section(sf,"AFK")
    Toggle(sf,"Anti AFK",true,function(v) _G.Saturn.AntiAFK=v end)
    FixCanvas(sf,ly)
end

-- select first tab
SelectTab("Combat")
Pages["Combat"].Visible=true

-- ══════════════════════════════════════════════════════
-- FLOAT -> KEY -> HUB
-- ══════════════════════════════════════════════════════
local verified=false

FloatBtn.MouseButton1Click:Connect(function()
    if verified then
        Hub.Visible=not Hub.Visible
        if Hub.Visible then
            Hub.Size=UDim2.new(0,0,0,0)
            Spring(Hub,{Size=UDim2.new(0,620,0,440)},.4)
            FloatBtn.Visible=false
        end
    else
        KP.Visible=true; KP.BackgroundTransparency=1
        KP.Position=UDim2.new(.5,-150,.62,-150)
        Spring(KP,{Position=UDim2.new(.5,-150,.5,-150)},.4)
        Tween(KP,{BackgroundTransparency=0},.25)
    end
end)

local function DoVerify()
    local k=KInp.Text:gsub("%s","")
    if k=="Saturn777" then
        verified=true
        Tween(KP,{Position=UDim2.new(.5,-150,.38,-150),BackgroundTransparency=1},.25)
        task.wait(.3); KP.Visible=false
        FloatBtn.Visible=false
        Hub.Visible=true; Hub.Size=UDim2.new(0,0,0,0)
        Spring(Hub,{Size=UDim2.new(0,620,0,440)},.5)
        task.wait(.6); Notify("Saturn Hub","Bem-vindo! Creditos: @matheuz.z7",5)
    else
        KErr.Text="Chave incorreta."
        for _=1,2 do
            Tween(KP,{Position=UDim2.new(.5,-162,.5,-150)},.04); task.wait(.04)
            Tween(KP,{Position=UDim2.new(.5,-138,.5,-150)},.04); task.wait(.04)
        end
        Tween(KP,{Position=UDim2.new(.5,-150,.5,-150)},.04)
        task.delay(2.5,function() KErr.Text="" end)
    end
end
KBtn.MouseButton1Click:Connect(DoVerify)
KInp.FocusLost:Connect(function(e) if e then DoVerify() end end)

-- ══════════════════════════════════════════════════════
-- FLY
-- ══════════════════════════════════════════════════════
local FlyBV,FlyBG
local function StartFly()
    local h=HRP(); if not h then return end
    FlyBV=Instance.new("BodyVelocity"); FlyBV.MaxForce=Vector3.new(1e5,1e5,1e5); FlyBV.Velocity=Vector3.zero; FlyBV.Parent=h
    FlyBG=Instance.new("BodyGyro"); FlyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); FlyBG.P=1e4; FlyBG.Parent=h
end
local function StopFly()
    if FlyBV then FlyBV:Destroy(); FlyBV=nil end
    if FlyBG then FlyBG:Destroy(); FlyBG=nil end
end

-- ══════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════
local EF={"Enemies","NPCs","Mobs","SeaEnemies","Bosses"}
local FK={"Chop","Bomb","Spike","Flame","Ice","Sand","Dark","Diamond","Light","Rubber",
    "Barrier","Magma","Quake","Human","Bird","Phoenix","Rumble","Paw","Gravity",
    "Dough","Shadow","Venom","Control","Dragon","Spider","Sound","Blizzard",
    "Smoke","Revive","Spring","Leopard","Kilo","Love","String","Fruit"}

local function FindEnemy(range)
    local h=HRP(); if not h then return end
    local best,bd=nil,range or math.huge
    for _,fn in ipairs(EF) do local f=workspace:FindFirstChild(fn)
        if f then for _,e in ipairs(f:GetChildren()) do
            local eH=e:FindFirstChild("HumanoidRootPart"); local eM=e:FindFirstChildOfClass("Humanoid")
            if eH and eM and eM.Health>0 then
                local match=_G.Saturn.FarmTarget=="Automatic (By Level)" or e.Name:find(_G.Saturn.FarmTarget)
                if match then local d=(h.Position-eH.Position).Magnitude; if d<bd then best=e;bd=d end end
            end
        end end
    end
    return best
end

local function FindFruits()
    local out={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _,kw in ipairs(FK) do
                if obj.Name:find(kw) and not obj:FindFirstAncestorOfClass("Character") then
                    table.insert(out,obj); break
                end
            end
        end
    end
    return out
end

-- ══════════════════════════════════════════════════════
-- CONNECTIONS
-- ══════════════════════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if _G.Saturn.InfiniteJump then local h=Hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
LP.Idled:Connect(function()
    if _G.Saturn.AntiAFK then VirtualUser:Button2Down(Vector2.zero,Camera.CFrame); task.wait(.1); VirtualUser:Button2Up(Vector2.zero,Camera.CFrame) end
end)
LP.CharacterAdded:Connect(function(char)
    task.wait(1); local h=char:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=_G.Saturn.Speed end
    if _G.Saturn.ReJoinOnDeath then
        local hum2=char:WaitForChild("Humanoid")
        hum2.Died:Connect(function()
            task.wait(1); game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
        end)
    end
end)

-- ══════════════════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════════════════
local _t=0
RunService.Heartbeat:Connect(function(dt)
    _t+=dt
    local hrp=HRP(); local hum=Hum()
    if not hrp or not hum then return end

    -- Fly
    if _G.Saturn.FlyEnabled then
        if not FlyBV then StartFly() end
        if FlyBV and FlyBG then
            local dir=Vector3.zero; local spd=_G.Saturn.FlySpeed; local cf=Camera.CFrame; local UIS=UserInputService
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.yAxis end
            FlyBV.Velocity=dir.Magnitude>0 and dir.Unit*spd or Vector3.zero; FlyBG.CFrame=cf
        end
    else if FlyBV then StopFly() end end

    -- No Clip
    if _G.Saturn.NoClip then
        for _,p in ipairs(Char():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end

    -- Infinite Energy
    if _G.Saturn.InfiniteEnergy then
        for _,obj in ipairs({Char(),LP}) do
            if obj then for _,vn in ipairs({"Energy","Mana","Stamina"}) do
                local val=obj:FindFirstChild(vn)
                if val and val:IsA("NumberValue") then val.Value=999999 end
            end end
        end
    end

    -- God Mode
    if _G.Saturn.GodMode and _t%0.3<dt then
        if hum then
            hum.Health=hum.MaxHealth
            -- fire server to try to prevent damage
            local rem=ReplicatedStorage:FindFirstChild("Remotes")
            if rem then local gm=rem:FindFirstChild("GodMode") or rem:FindFirstChild("Revive")
                if gm then pcall(function() gm:FireServer() end) end
            end
        end
    end

    -- Auto Haki
    if _G.Saturn.AutoHaki and _t%1<dt then
        local rem=ReplicatedStorage:FindFirstChild("Remotes")
        if rem then
            local hk=rem:FindFirstChild("Haki") or rem:FindFirstChild("BusoHaki") or rem:FindFirstChild("UseHaki")
            if hk then pcall(function() hk:FireServer(true) end) end
        end
    end

    -- Kill Aura
    if _G.Saturn.KillAura and _t%0.1<dt then
        for _,fn in ipairs(EF) do local f=workspace:FindFirstChild(fn)
            if f then for _,e in ipairs(f:GetChildren()) do
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

    -- Hitbox Expand
    if _G.Saturn.HitboxExpand and _t%0.5<dt then
        for _,fn in ipairs(EF) do local f=workspace:FindFirstChild(fn)
            if f then for _,e in ipairs(f:GetChildren()) do
                local eH=e:FindFirstChild("HumanoidRootPart")
                if eH then eH.Size=Vector3.new(_G.Saturn.HitboxSize,_G.Saturn.HitboxSize,_G.Saturn.HitboxSize) end
            end end
        end
    end

    -- Auto Farm
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

    -- Auto Quest
    if _G.Saturn.AutoQuest and _t%1<dt then
        local stats=LP:FindFirstChild("leaderstats") or LP:FindFirstChild("Data")
        if stats then local lv=stats:FindFirstChild("Level") or stats:FindFirstChild("Lv")
            local rem=ReplicatedStorage:FindFirstChild("Remotes")
            if lv and rem then local qr=rem:FindFirstChild("Management") or rem:FindFirstChild("Quest")
                if qr then pcall(function() qr:FireServer("Quest",lv.Value) end) end end
        end
    end

    -- Auto Stats
    if _G.Saturn.AutoStats and _t%2<dt then
        local rem=ReplicatedStorage:FindFirstChild("Remotes")
        if rem then local ir=rem:FindFirstChild("Invest_Stats")
            if ir then pcall(function() ir:FireServer(_G.Saturn.StatType) end) end end
    end

    -- Fruit ESP
    if _G.Saturn.FruitESP and _t%1.5<dt then
        for _,h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name=="_SatFruitESP" then h:Destroy() end
        end
        for _,fruit in ipairs(FindFruits()) do
            if not fruit:FindFirstChild("_SatFruitESP") then
                local hl=Instance.new("Highlight"); hl.Name="_SatFruitESP"
                hl.FillColor=Color3.fromRGB(0,70,220); hl.OutlineColor=C.AccentBright
                hl.FillTransparency=0.3; hl.Parent=fruit
            end
        end
    end

    -- Fruit Notify
    if _G.Saturn.FruitNotify and _t%1<dt then
        for _,fruit in ipairs(FindFruits()) do
            if not fruit:FindFirstChild("_SatNotified") then
                Instance.new("BoolValue",fruit).Name="_SatNotified"
                Notify("Fruit Spawnada!",fruit.Name.." detectada no mapa!",8)
            end
        end
    end

    -- Fruit Sniper
    if _G.Saturn.FruitSniper and _t%0.5<dt then
        local fruits=FindFruits()
        if #fruits>0 then
            local f=fruits[1]; local pos=f:IsA("Model") and f:GetModelCFrame().Position or f.Position
            if (hrp.Position-pos).Magnitude>10 then hrp.CFrame=CFrame.new(pos+Vector3.new(3,2,0)) end
        end
    end

    -- Player ESP
    if _G.Saturn.PlayerESP and _t%1.5<dt then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP and pl.Character and not pl.Character:FindFirstChild("_SatPlayerESP") then
                local hl=Instance.new("Highlight"); hl.Name="_SatPlayerESP"
                hl.FillColor=Color3.fromRGB(0,40,190); hl.OutlineColor=C.AccentBright
                hl.FillTransparency=0.5; hl.Parent=pl.Character
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════
-- LOAD IMAGE
-- ══════════════════════════════════════════════════════
task.spawn(function()
    local ok=false
    pcall(function()
        if typeof(request)=="function" then
            local res=request({Url=IMG_URL,Method="GET"})
            if res and res.Body and #res.Body>100 then
                writefile("_sat2.jpg",res.Body)
                local path=getcustomasset("_sat2.jpg")
                FloatBtn.Image=path; KImg.Image=path; TLogo.Image=path
                ok=true
            end
        end
    end)
    if not ok then
        local fb="rbxassetid://6031907432"
        FloatBtn.Image=fb; KImg.Image=fb; TLogo.Image=fb
    end
end)

print("[Saturn Hub v2] carregado | @matheuz.z7")
