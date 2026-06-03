-- Server Universal Finder

-- Made by Drek

-- Modified: Quick button, AI Tab, Settings model selector

local Players          = game:GetService("Players")

local TweenService     = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local HttpService      = game:GetService("HttpService")

local RunService       = game:GetService("RunService")

local MarketplaceService = game:GetService("MarketplaceService")

local lp               = Players.LocalPlayer

local ASSETS = {

    Planet   = "rbxassetid://104250728130629",

    Search   = "rbxassetid://131390251426226",

    Player   = "rbxassetid://84017303554479",

    Favorite = "rbxassetid://86428083049230",

    History  = "rbxassetid://103187533139656",

    Setting  = "rbxassetid://92812785035714",

    About    = "rbxassetid://71516058837773",

    Scripts  = "rbxassetid://119690016147737",

    AI       = "rbxassetid://84373284889085",

    Send     = "rbxassetid://78844898949322",

    SettingBtn = "rbxassetid://92812785035714",

    Quick    = "rbxassetid://138420715305299",

}

local C = {

    BG        = Color3.fromRGB(18, 18, 24),

    Sidebar   = Color3.fromRGB(22, 22, 30),

    Panel     = Color3.fromRGB(26, 26, 36),

    Card      = Color3.fromRGB(32, 32, 44),

    Border    = Color3.fromRGB(55, 55, 80),

    Purple    = Color3.fromRGB(120, 80, 220),

    PurpleHov = Color3.fromRGB(140, 100, 240),

    PurpleDim = Color3.fromRGB(60, 40, 110),

    Text      = Color3.fromRGB(230, 230, 245),

    Sub       = Color3.fromRGB(140, 140, 170),

    Green     = Color3.fromRGB(80, 220, 120),

    Yellow    = Color3.fromRGB(220, 180, 40),

    Red       = Color3.fromRGB(220, 70, 70),

    Input     = Color3.fromRGB(20, 20, 30),

    RowAlt    = Color3.fromRGB(28, 28, 40),

    White     = Color3.fromRGB(255, 255, 255),

    SliderBG  = Color3.fromRGB(40, 40, 58),

    JoinBtn   = Color3.fromRGB(100, 60, 200),

    JoinHov   = Color3.fromRGB(130, 90, 240),

    Bubble    = Color3.fromRGB(34, 34, 50),

    BubbleHov = Color3.fromRGB(44, 44, 65),

}

local POLLINATION_KEY = "sk_KQrxFBNvsoKyMgbGN8vanm20BmvumP6w"

local AI_MODEL = "openai"

local state = {

    page           = "ServerFinder",

    walkSpeed      = 100,

    jumpPower      = 100,

    matchGame      = true,

    excludeFull    = true,

    recentSearches = {},

    results        = {},

    favorites      = {},

    history        = {},

    scriptResults  = {},

    scriptQuery    = "",

    scriptPage     = 1,

    scriptTotalPages = 1,

    aiMessages     = {},

    aiModel        = AI_MODEL,

}

local function new(cls, props, parent)

    local o = Instance.new(cls)

    for k, v in pairs(props) do o[k] = v end

    if parent then o.Parent = parent end

    return o

end

local function corner(r, p)

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r); c.Parent = p

end

local function pad(t, b, l, r, p)

    local u = Instance.new("UIPadding")

    u.PaddingTop=UDim.new(0,t); u.PaddingBottom=UDim.new(0,b)

    u.PaddingLeft=UDim.new(0,l); u.PaddingRight=UDim.new(0,r); u.Parent=p

end

local function icon(asset, size, parent, pos, col)

    local img = new("ImageLabel",{

        Image=asset, Size=UDim2.new(0,size,0,size),

        BackgroundTransparency=1, ImageColor3=col or C.Text,

    }, parent)

    if pos then img.Position = pos end

    return img

end

local function tw(obj, props, t)

    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()

end

local function hov(btn, norm, h)

    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=h},0.1) end)

    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=norm},0.1) end)

end

local function httpGet(url)

    local fn = (syn and syn.request) or (http and http.request) or request

    local r = fn({Url=url, Method="GET"})

    return r.Body

end

local function httpPost(url, body, headers)

    local fn = (syn and syn.request) or (http and http.request) or request

    local r = fn({

        Url=url, Method="POST",

        Headers=headers or {},

        Body=body,

    })

    return r.Body

end

local function yesNo(v)

    if v == true or v == 1 then return "Yes" end

    if v == false or v == 0 then return "No" end

    return tostring(v or "?")

end

local function tagLabel(parent, text, col, xpos, ypos)

    local bg = new("Frame",{

        Size=UDim2.new(0,0,0,16), Position=UDim2.new(0,xpos,0,ypos),

        BackgroundColor3=col, BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.X,

    }, parent)

    corner(4,bg)

    local lbl = new("TextLabel",{

        Size=UDim2.new(0,0,1,0), BackgroundTransparency=1,

        Text=text, TextColor3=C.White, TextSize=8,

        Font=Enum.Font.GothamBold, AutomaticSize=Enum.AutomaticSize.X,

    }, bg)

    pad(0,0,4,4,lbl)

    return bg

end

local gui = Instance.new("ScreenGui")

gui.Name="ServerUniversalFinder"; gui.ResetOnSpawn=false

gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.DisplayOrder=999

gui.Parent = (gethui and gethui()) or lp.PlayerGui

local restoreBtn = new("TextButton",{

    Size=UDim2.new(0,56,0,56),

    Position=UDim2.new(0,10,0.5,-28),

    BackgroundColor3=Color3.fromRGB(20,60,200), Text="",

    BorderSizePixel=0, Visible=false, ZIndex=999,

}, gui)

corner(99, restoreBtn)

local rainbowStroke = Instance.new("UIStroke")

rainbowStroke.Thickness = 3

rainbowStroke.Color = Color3.fromRGB(160,80,255)

rainbowStroke.Parent = restoreBtn

local sufLabel = new("TextLabel",{

    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,

    Text="SUF", TextSize=14, Font=Enum.Font.GothamBold,

    TextColor3=Color3.fromRGB(255,255,255), ZIndex=1000,

}, restoreBtn)

local rainbowColors = {

    Color3.fromRGB(255,80,80),

    Color3.fromRGB(255,160,40),

    Color3.fromRGB(255,240,40),

    Color3.fromRGB(80,255,100),

    Color3.fromRGB(40,180,255),

    Color3.fromRGB(160,80,255),

    Color3.fromRGB(255,80,200),

}

local rainbowIdx = 0

RunService.Heartbeat:Connect(function()

    if not restoreBtn.Visible then return end

    rainbowIdx = (rainbowIdx + 0.05) % #rainbowColors

    local i = math.floor(rainbowIdx) + 1

    local j = (i % #rainbowColors) + 1

    local t = rainbowIdx - math.floor(rainbowIdx)

    local col = rainbowColors[i]:Lerp(rainbowColors[j], t)

    sufLabel.TextColor3 = col

    rainbowStroke.Color = col

end)

local main = new("Frame",{

    Size=UDim2.new(0,700,0,480), Position=UDim2.new(0.5,-350,0.5,-240),

    BackgroundColor3=C.BG, BorderSizePixel=0, ClipsDescendants=true,

}, gui)

corner(12, main)

local topBar = new("Frame",{

    Size=UDim2.new(1,0,0,32), BackgroundColor3=C.Sidebar,

    BorderSizePixel=0, ZIndex=5,

}, main)

local function dot(xpos, col, action)

    local d = new("TextButton",{

        Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,xpos,0.5,-6),

        BackgroundColor3=col, Text="", BorderSizePixel=0, ZIndex=6,

    }, topBar)

    corner(99,d)

    if action then d.MouseButton1Click:Connect(action) end

    return d

end

dot(10, Color3.fromRGB(255,95,87),  function() gui:Destroy() end)

dot(26, Color3.fromRGB(255,189,46), function()

    main.Visible = false

    restoreBtn.Visible = true

end)

dot(42, Color3.fromRGB(39,201,63),  nil)

local minBtn = new("TextButton",{

    Size=UDim2.new(0,22,0,18), Position=UDim2.new(1,-38,0.5,-9),

    BackgroundColor3=C.Card, Text="_", TextColor3=C.Sub,

    TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0, ZIndex=6,

}, topBar)

corner(4, minBtn)

minBtn.MouseButton1Click:Connect(function()

    main.Visible = false

    restoreBtn.Visible = true

end)

restoreBtn.MouseButton1Click:Connect(function()

    main.Visible = true

    restoreBtn.Visible = false

end)

new("TextLabel",{

    Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,60,0,0),

    BackgroundTransparency=1, Text="Server Universal Finder",

    TextColor3=C.Sub, TextSize=11, Font=Enum.Font.GothamSemibold,

    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,

}, topBar)

local sidebar = new("Frame",{

    Size=UDim2.new(0,120,1,0), BackgroundColor3=C.Sidebar, BorderSizePixel=0,

}, main)

new("Frame",{

    Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),

    BackgroundColor3=C.Border, BorderSizePixel=0,

}, sidebar)

local logoArea = new("Frame",{

    Size=UDim2.new(1,0,0,54), Position=UDim2.new(0,0,0,36),

    BackgroundTransparency=1,

}, sidebar)

icon(ASSETS.Planet,22,logoArea,UDim2.new(0,12,0.5,-11),C.Purple)

new("TextLabel",{

    Size=UDim2.new(1,-44,0,14), Position=UDim2.new(0,40,0.5,-14),

    BackgroundTransparency=1, Text="SUF", TextColor3=C.Text,

    TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, logoArea)

new("TextLabel",{

    Size=UDim2.new(1,-44,0,12), Position=UDim2.new(0,40,0.5,2),

    BackgroundTransparency=1, Text="Server Finder", TextColor3=C.Sub,

    TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

}, logoArea)

local NAV = {

    {label="Server Finder", iconAsset=ASSETS.Search,   page="ServerFinder"},

    {label="Scripts",       iconAsset=ASSETS.Scripts,  page="Scripts"},

    {label="AI",            iconAsset=ASSETS.AI,       page="AI"},

    {label="Favorites",     iconAsset=ASSETS.Favorite, page="Favorites"},

    {label="History",       iconAsset=ASSETS.History,  page="History"},

    {label="Settings",      iconAsset=ASSETS.Setting,  page="Settings"},

    {label="About",         iconAsset=ASSETS.About,    page="About"},

}

local navBtns = {}

local function setNav(pg)

    state.page = pg

    for _, nb in pairs(navBtns) do

        local a = (nb.page == pg)

        tw(nb.btn,{BackgroundColor3=a and C.PurpleDim or C.Sidebar},0.12)

        nb.lbl.TextColor3  = a and C.White or C.Sub

        nb.ico.ImageColor3 = a and C.Purple or C.Sub

    end

end

for i, item in ipairs(NAV) do

    local btn = new("TextButton",{

        Size=UDim2.new(1,-14,0,30), Position=UDim2.new(0,7,0,96+(i-1)*36),

        BackgroundColor3=C.Sidebar, Text="", BorderSizePixel=0,

    }, sidebar)

    corner(7,btn)

    local ico = icon(item.iconAsset,14,btn,UDim2.new(0,9,0.5,-7),C.Sub)

    local lbl = new("TextLabel",{

        Size=UDim2.new(1,-32,1,0), Position=UDim2.new(0,28,0,0),

        BackgroundTransparency=1, Text=item.label, TextColor3=C.Sub,

        TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

    }, btn)

    navBtns[i] = {btn=btn, ico=ico, lbl=lbl, page=item.page}

    btn.MouseEnter:Connect(function()

        if state.page~=item.page then tw(btn,{BackgroundColor3=Color3.fromRGB(35,35,50)},0.1) end

    end)

    btn.MouseLeave:Connect(function()

        if state.page~=item.page then tw(btn,{BackgroundColor3=C.Sidebar},0.1) end

    end)

end

local sc = new("Frame",{

    Size=UDim2.new(1,-14,0,50), Position=UDim2.new(0,7,1,-58),

    BackgroundColor3=C.Card, BorderSizePixel=0,

}, sidebar)

corner(8,sc)

new("TextLabel",{

    Size=UDim2.new(1,-14,0,13), Position=UDim2.new(0,10,0,7),

    BackgroundTransparency=1, Text="Status", TextColor3=C.Text,

    TextSize=10, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, sc)

local sdot = new("Frame",{

    Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,10,0,26),

    BackgroundColor3=C.Green, BorderSizePixel=0,

}, sc)

corner(99,sdot)

new("TextLabel",{

    Size=UDim2.new(1,-22,0,12), Position=UDim2.new(0,20,0,24),

    BackgroundTransparency=1, Text="Connected", TextColor3=C.Green,

    TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

}, sc)

new("TextLabel",{

    Size=UDim2.new(1,-14,0,11), Position=UDim2.new(0,10,0,38),

    BackgroundTransparency=1, Text="PlaceId: "..tostring(game.PlaceId),

    TextColor3=C.Sub, TextSize=8, Font=Enum.Font.Gotham,

    TextXAlignment=Enum.TextXAlignment.Left,

}, sc)

local content = new("Frame",{

    Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,120,0,0),

    BackgroundTransparency=1,

}, main)

local sfPage = new("Frame",{

    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=true,

}, content)

local tabsBar = new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1}, sfPage)

new("Frame",{

    Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),

    BackgroundColor3=C.Border, BorderSizePixel=0,

}, tabsBar)

local TABS = {"JobID","Player"}

local tabBtns = {}

local function setTab(t)

    for _, tb in pairs(tabBtns) do

        local a = (tb.tab==t)

        tb.lbl.TextColor3  = a and C.Purple or C.Sub

        tb.ico.ImageColor3 = a and C.Purple or C.Sub

        tb.ul.Visible      = a

    end

end

for i, tname in ipairs(TABS) do

    local tb = new("TextButton",{

        Size=UDim2.new(0,80,1,0), Position=UDim2.new(0,(i-1)*84+6,0,0),

        BackgroundTransparency=1, Text="", BorderSizePixel=0,

    }, tabsBar)

    local tabIcon = tname=="JobID" and ASSETS.Search or ASSETS.Player

    local ico = icon(tabIcon,12,tb,UDim2.new(0,8,0.5,-6),C.Sub)

    local lbl = new("TextLabel",{

        Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,22,0,0),

        BackgroundTransparency=1, Text=tname, TextColor3=C.Sub,

        TextSize=11, Font=Enum.Font.GothamSemibold,

        TextXAlignment=Enum.TextXAlignment.Left,

    }, tb)

    local ul = new("Frame",{

        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),

        BackgroundColor3=C.Purple, BorderSizePixel=0, Visible=tname=="JobID",

    }, tb)

    tabBtns[i] = {btn=tb,lbl=lbl,ico=ico,ul=ul,tab=tname}

    tb.MouseButton1Click:Connect(function() setTab(tname) end)

end

local leftP = new("Frame",{

    Size=UDim2.new(0,420,1,-36), Position=UDim2.new(0,0,0,36),

    BackgroundTransparency=1,

}, sfPage)

local rightP = new("Frame",{

    Size=UDim2.new(1,-428,1,-36), Position=UDim2.new(0,428,0,36),

    BackgroundTransparency=1,

}, sfPage)

local searchSec = new("Frame",{

    Size=UDim2.new(1,-12,0,64), Position=UDim2.new(0,6,0,6),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

}, leftP)

corner(9,searchSec)

new("TextLabel",{

    Size=UDim2.new(1,-16,0,16), Position=UDim2.new(0,10,0,7),

    BackgroundTransparency=1, Text="Search JobID", TextColor3=C.Purple,

    TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, searchSec)

local inputRow = new("Frame",{

    Size=UDim2.new(1,-16,0,28), Position=UDim2.new(0,8,0,28),

    BackgroundTransparency=1,

}, searchSec)

local searchInput = new("TextBox",{

    Size=UDim2.new(1,-78,1,0), BackgroundColor3=C.Input, BorderSizePixel=0,

    PlaceholderText="Enter JobID...", PlaceholderColor3=C.Sub,

    Text=game.JobId, TextColor3=C.Text, TextSize=10,

    Font=Enum.Font.Code, ClearTextOnFocus=false,

}, inputRow)

corner(6,searchInput); pad(0,0,8,0,searchInput)

local searchBtn = new("TextButton",{

    Size=UDim2.new(0,70,1,0), Position=UDim2.new(1,-70,0,0),

    BackgroundColor3=C.Purple, Text="Search", TextColor3=C.White,

    TextSize=11, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

}, inputRow)

corner(6,searchBtn); hov(searchBtn,C.Purple,C.PurpleHov)

local recentSec = new("Frame",{

    Size=UDim2.new(1,-12,0,42), Position=UDim2.new(0,6,0,78),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

}, leftP)

corner(9,recentSec)

new("TextLabel",{

    Size=UDim2.new(0,110,0,14), Position=UDim2.new(0,10,0,7),

    BackgroundTransparency=1, Text="Recent Searches", TextColor3=C.Text,

    TextSize=10, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left,

}, recentSec)

local clearRecentBtn = new("TextButton",{

    Size=UDim2.new(0,60,0,18), Position=UDim2.new(1,-66,0,5),

    BackgroundColor3=C.Card, Text="Clear All", TextColor3=C.Sub,

    TextSize=9, Font=Enum.Font.Gotham, BorderSizePixel=0,

}, recentSec)

corner(5,clearRecentBtn)

local chipsScroll = new("ScrollingFrame",{

    Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,28),

    BackgroundTransparency=1, BorderSizePixel=0,

    ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0),

    ClipsDescendants=true,

}, recentSec)

local optSec

local function updateRecentHeight()

    local count = 0

    for _, r in pairs(state.recentSearches) do

        if r.chip and r.chip.Parent then count=count+1 end

    end

    local h = count==0 and 42 or (42+count*28)

    recentSec.Size = UDim2.new(1,-12,0,h)

    chipsScroll.CanvasSize = UDim2.new(0,0,0,count*28)

    chipsScroll.Size = UDim2.new(1,-16,0,count*28)

    if optSec then optSec.Position = UDim2.new(0,6,0,86+h) end

end

local function addRecentChip(jobid)

    for _, r in pairs(state.recentSearches) do

        if r.jobid==jobid and r.chip and r.chip.Parent then return end

    end

    local idx = #state.recentSearches+1

    local chip = new("Frame",{

        Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0,(idx-1)*28),

        BackgroundColor3=C.Card, BorderSizePixel=0,

    }, chipsScroll)

    corner(5,chip)

    local ct = new("TextButton",{

        Size=UDim2.new(1,-26,1,0), Position=UDim2.new(0,7,0,0),

        BackgroundTransparency=1, Text=jobid, TextColor3=C.Sub,

        TextSize=9, Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left,

        TextTruncate=Enum.TextTruncate.AtEnd,

    }, chip)

    ct.MouseButton1Click:Connect(function() searchInput.Text=jobid end)

    local xb = new("TextButton",{

        Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,-22,0.5,-9),

        BackgroundTransparency=1, Text="×", TextColor3=C.Sub,

        TextSize=13, Font=Enum.Font.GothamBold,

    }, chip)

    xb.MouseButton1Click:Connect(function()

        chip:Destroy()

        for i2, r in pairs(state.recentSearches) do

            if r.jobid==jobid then table.remove(state.recentSearches,i2); break end

        end

        local y=0

        for _, r in pairs(state.recentSearches) do

            if r.chip and r.chip.Parent then r.chip.Position=UDim2.new(0,0,0,y); y=y+28 end

        end

        updateRecentHeight()

    end)

    state.recentSearches[idx] = {jobid=jobid, chip=chip}

    updateRecentHeight()

end

clearRecentBtn.MouseButton1Click:Connect(function()

    for _, r in pairs(state.recentSearches) do

        if r.chip and r.chip.Parent then r.chip:Destroy() end

    end

    state.recentSearches={}; updateRecentHeight()

end)

optSec = new("Frame",{

    Size=UDim2.new(1,-12,0,102), Position=UDim2.new(0,6,0,128),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

}, leftP)

corner(9,optSec)

new("TextLabel",{

    Size=UDim2.new(1,-16,0,16), Position=UDim2.new(0,10,0,7),

    BackgroundTransparency=1, Text="Search Options", TextColor3=C.Purple,

    TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, optSec)

local OPTS = {

    {lbl="Match Game",           sub="Only show servers from this game",  key="matchGame"},

    {lbl="Exclude Full Servers", sub="Hide servers at max players",        key="excludeFull"},

}

for i, opt in ipairs(OPTS) do

    local row = new("Frame",{

        Size=UDim2.new(1,-16,0,36), Position=UDim2.new(0,8,0,26+(i-1)*36),

        BackgroundTransparency=1,

    }, optSec)

    if i<#OPTS then

        new("Frame",{

            Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),

            BackgroundColor3=C.Border, BackgroundTransparency=0.6, BorderSizePixel=0,

        }, row)

    end

    new("TextLabel",{

        Size=UDim2.new(0,180,0,13), Position=UDim2.new(0,0,0,4),

        BackgroundTransparency=1, Text=opt.lbl, TextColor3=C.Text,

        TextSize=10, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left,

    }, row)

    new("TextLabel",{

        Size=UDim2.new(0,210,0,11), Position=UDim2.new(0,0,0,19),

        BackgroundTransparency=1, Text=opt.sub, TextColor3=C.Sub,

        TextSize=8, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

    }, row)

    local tbg = new("Frame",{

        Size=UDim2.new(0,36,0,20), Position=UDim2.new(1,-38,0.5,-10),

        BackgroundColor3=state[opt.key] and C.Purple or C.Border, BorderSizePixel=0,

    }, row)

    corner(99,tbg)

    local tkn = new("Frame",{

        Size=UDim2.new(0,14,0,14),

        Position=UDim2.new(0,state[opt.key] and 19 or 3,0.5,-7),

        BackgroundColor3=C.White, BorderSizePixel=0,

    }, tbg)

    corner(99,tkn)

    local tbtn = new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}, tbg)

    tbtn.MouseButton1Click:Connect(function()

        state[opt.key] = not state[opt.key]

        tw(tbg,{BackgroundColor3=state[opt.key] and C.Purple or C.Border},0.15)

        tw(tkn,{Position=UDim2.new(0,state[opt.key] and 19 or 3,0.5,-7)},0.15)

    end)

end

local resultsSec = new("Frame",{

    Size=UDim2.new(1,-12,1,-238), Position=UDim2.new(0,6,0,238),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

}, leftP)

corner(9,resultsSec)

local resHdr = new("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1}, resultsSec)

new("TextLabel",{

    Size=UDim2.new(0,55,1,0), Position=UDim2.new(0,10,0,0),

    BackgroundTransparency=1, Text="Results", TextColor3=C.Purple,

    TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, resHdr)

local resBadge = new("Frame",{

    Size=UDim2.new(0,22,0,15), Position=UDim2.new(0,58,0.5,-7),

    BackgroundColor3=C.Card, BorderSizePixel=0,

}, resHdr)

corner(4,resBadge)

local resBadgeLbl = new("TextLabel",{

    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,

    Text="0", TextColor3=C.Sub, TextSize=9, Font=Enum.Font.GothamSemibold,

}, resBadge)

local refreshBtn = new("TextButton",{

    Size=UDim2.new(0,64,0,20), Position=UDim2.new(1,-70,0.5,-10),

    BackgroundColor3=C.Card, Text="Refresh", TextColor3=C.Sub,

    TextSize=9, Font=Enum.Font.Gotham, BorderSizePixel=0,

}, resHdr)

corner(4,refreshBtn); hov(refreshBtn,C.Card,Color3.fromRGB(42,42,60))

local tblHdr = new("Frame",{

    Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,30),

    BackgroundColor3=C.RowAlt, BorderSizePixel=0,

}, resultsSec)

for _, col in ipairs({

    {t="★",x=8,w=16},{t="JobID",x=28,w=140},{t="Players",x=174,w=48},

    {t="Max",x=224,w=38},{t="Ping",x=264,w=40},{t="Type",x=306,w=54},{t="Join",x=362,w=36},

}) do

    new("TextLabel",{

        Size=UDim2.new(0,col.w,1,0), Position=UDim2.new(0,col.x,0,0),

        BackgroundTransparency=1, Text=col.t, TextColor3=C.Sub,

        TextSize=8, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left,

    }, tblHdr)

end

local rowScroll = new("ScrollingFrame",{

    Size=UDim2.new(1,0,1,-50), Position=UDim2.new(0,0,0,50),

    BackgroundTransparency=1, BorderSizePixel=0,

    ScrollBarThickness=3, ScrollBarImageColor3=C.Purple,

    CanvasSize=UDim2.new(0,0,0,0),

}, resultsSec)

local emptyLbl = new("TextLabel",{

    Size=UDim2.new(1,0,1,-50), Position=UDim2.new(0,0,0,50),

    BackgroundTransparency=1, Text="No results.\nEnter a JobID and press Search.",

    TextColor3=C.Sub, TextSize=10, Font=Enum.Font.Gotham, TextWrapped=true,

}, resultsSec)

local rebuildFav, rebuildHist

local function makeListPage(iconAsset, title, dataKey, showTime)

    local pg = new("Frame",{

        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false,

    }, content)

    local hdrF = new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1}, pg)

    icon(iconAsset,16,hdrF,UDim2.new(0,10,0.5,-8),C.Purple)

    new("TextLabel",{

        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,32,0,0),

        BackgroundTransparency=1, Text=title, TextColor3=C.Purple,

        TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

    }, hdrF)

    local clrBtn = new("TextButton",{

        Size=UDim2.new(0,70,0,22), Position=UDim2.new(1,-76,0.5,-11),

        BackgroundColor3=C.Card, Text="Clear All", TextColor3=C.Sub,

        TextSize=10, Font=Enum.Font.Gotham, BorderSizePixel=0,

    }, hdrF)

    corner(5,clrBtn)

    local tHdr = new("Frame",{

        Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,44),

        BackgroundColor3=C.RowAlt, BorderSizePixel=0,

    }, pg)

    local cols = showTime and {

        {t="JobID",x=10,w=190},{t="Players",x=208,w=50},{t="Max",x=262,w=40},

        {t="Ping",x=306,w=44},{t="Time",x=354,w=90},{t="Join",x=448,w=36},

    } or {

        {t="★",x=8,w=16},{t="JobID",x=28,w=200},{t="Players",x=234,w=50},

        {t="Max",x=288,w=40},{t="Ping",x=332,w=44},{t="Join",x=380,w=36},

    }

    for _, col in ipairs(cols) do

        new("TextLabel",{

            Size=UDim2.new(0,col.w,1,0), Position=UDim2.new(0,col.x,0,0),

            BackgroundTransparency=1, Text=col.t, TextColor3=C.Sub,

            TextSize=8, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left,

        }, tHdr)

    end

    local scroll = new("ScrollingFrame",{

        Size=UDim2.new(1,0,1,-64), Position=UDim2.new(0,0,0,64),

        BackgroundTransparency=1, BorderSizePixel=0,

        ScrollBarThickness=3, ScrollBarImageColor3=C.Purple,

        CanvasSize=UDim2.new(0,0,0,0),

    }, pg)

    local emptyL = new("TextLabel",{

        Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,10),

        BackgroundTransparency=1, Text="",

        TextColor3=C.Sub, TextSize=11, Font=Enum.Font.Gotham,

    }, pg)

    local rowFs = {}

    local function rebuild()

        for _, f in pairs(rowFs) do f:Destroy() end

        rowFs={}

        local list = state[dataKey]

        emptyL.Visible = #list==0

        scroll.CanvasSize = UDim2.new(0,0,0,#list*31)

        for i, d in ipairs(list) do

            local rf = new("Frame",{

                Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,0,0,(i-1)*31),

                BackgroundColor3=i%2==0 and C.RowAlt or C.BG, BorderSizePixel=0,

            }, scroll)

            if not showTime then

                local sb = new("TextButton",{

                    Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,6,0.5,-9),

                    BackgroundTransparency=1, Text="★", TextColor3=C.Yellow,

                    TextSize=13, Font=Enum.Font.GothamBold, BorderSizePixel=0,

                }, rf)

                sb.MouseButton1Click:Connect(function()

                    for j,v in ipairs(state.favorites) do

                        if v.jobid==d.jobid then table.remove(state.favorites,j); break end

                    end

                    rebuild()

                end)

            end

            local jx = showTime and 10 or 28

            new("TextLabel",{

                Size=UDim2.new(0,showTime and 190 or 200,1,0), Position=UDim2.new(0,jx,0,0),

                BackgroundTransparency=1, Text=d.jobid, TextColor3=C.Purple,

                TextSize=8, Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left,

                TextTruncate=Enum.TextTruncate.AtEnd,

            }, rf)

            new("TextLabel",{

                Size=UDim2.new(0,46,1,0), Position=UDim2.new(0,showTime and 208 or 234,0,0),

                BackgroundTransparency=1, Text=tostring(d.players), TextColor3=C.Text,

                TextSize=9, Font=Enum.Font.Gotham,

            }, rf)

            new("TextLabel",{

                Size=UDim2.new(0,36,1,0), Position=UDim2.new(0,showTime and 262 or 288,0,0),

                BackgroundTransparency=1, Text=tostring(d.max), TextColor3=C.Text,

                TextSize=9, Font=Enum.Font.Gotham,

            }, rf)

            local pnum=tonumber(d.ping)

            local pcol=(d.ping=="?") and C.Sub or (pnum<80 and C.Green or C.Yellow)

            new("TextLabel",{

                Size=UDim2.new(0,40,1,0), Position=UDim2.new(0,showTime and 306 or 332,0,0),

                BackgroundTransparency=1,

                Text=(d.ping=="?") and "?" or (d.ping.."ms"),

                TextColor3=pcol, TextSize=9, Font=Enum.Font.Gotham,

            }, rf)

            if showTime then

                new("TextLabel",{

                    Size=UDim2.new(0,88,1,0), Position=UDim2.new(0,354,0,0),

                    BackgroundTransparency=1, Text=d.time or "", TextColor3=C.Sub,

                    TextSize=8, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

                }, rf)

            end

            local jbx = showTime and 448 or 380

            local jb = new("TextButton",{

                Size=UDim2.new(0,38,0,20), Position=UDim2.new(0,jbx,0.5,-10),

                BackgroundColor3=C.JoinBtn, Text="Join", TextColor3=C.White,

                TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

            }, rf)

            corner(5,jb); hov(jb,C.JoinBtn,C.JoinHov)

            local cap=d

            jb.MouseButton1Click:Connect(function()

                pcall(function()

                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,cap.jobid,lp)

                end)

            end)

            rowFs[i]=rf

        end

    end

    clrBtn.MouseButton1Click:Connect(function() state[dataKey]={} ; rebuild() end)

    rebuild()

    return pg, rebuild

end

local favPage, _rebuildFav = makeListPage(ASSETS.Favorite,"Favorites","favorites",false)

local histPage, _rebuildHist = makeListPage(ASSETS.History,"History","history",true)

rebuildFav  = _rebuildFav

rebuildHist = _rebuildHist

local function addHistory(d)

    for i,v in ipairs(state.history) do

        if v.jobid==d.jobid then table.remove(state.history,i); break end

    end

    table.insert(state.history,1,{

        jobid=d.jobid, players=d.players, max=d.max,

        ping=d.ping, stype=d.stype, time=os.date("%H:%M %m/%d"),

    })

    if #state.history>50 then table.remove(state.history) end

    rebuildHist()

end

local function isFavorited(jobid)

    for _,v in ipairs(state.favorites) do if v.jobid==jobid then return true end end

    return false

end

local function addFavorite(d)

    if isFavorited(d.jobid) then return end

    table.insert(state.favorites,{

        jobid=d.jobid, players=d.players, max=d.max, ping=d.ping, stype=d.stype,

    })

    rebuildFav()

end

local function removeFavorite(jobid)

    for i,v in ipairs(state.favorites) do

        if v.jobid==jobid then table.remove(state.favorites,i); rebuildFav(); return end

    end

end

local rowFrames = {}

local buildResultRow

buildResultRow = function(i, data)

    local rf = new("Frame",{

        Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,0,0,(i-1)*31),

        BackgroundColor3=i%2==0 and C.RowAlt or C.BG, BorderSizePixel=0,

    }, rowScroll)

    local favBtn = new("TextButton",{

        Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,5,0.5,-9),

        BackgroundTransparency=1, Text="★",

        TextColor3=isFavorited(data.jobid) and C.Yellow or C.Sub,

        TextSize=13, Font=Enum.Font.GothamBold, BorderSizePixel=0,

    }, rf)

    favBtn.MouseButton1Click:Connect(function()

        if isFavorited(data.jobid) then

            removeFavorite(data.jobid); favBtn.TextColor3=C.Sub

        else

            addFavorite(data); favBtn.TextColor3=C.Yellow

        end

    end)

    new("TextLabel",{

        Size=UDim2.new(0,144,1,0), Position=UDim2.new(0,26,0,0),

        BackgroundTransparency=1, Text=data.jobid, TextColor3=C.Purple,

        TextSize=8, Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left,

        TextTruncate=Enum.TextTruncate.AtEnd,

    }, rf)

    new("TextLabel",{

        Size=UDim2.new(0,40,1,0), Position=UDim2.new(0,174,0,0),

        BackgroundTransparency=1, Text=tostring(data.players), TextColor3=C.Text,

        TextSize=9, Font=Enum.Font.Gotham,

    }, rf)

    new("TextLabel",{

        Size=UDim2.new(0,32,1,0), Position=UDim2.new(0,224,0,0),

        BackgroundTransparency=1, Text=tostring(data.max), TextColor3=C.Text,

        TextSize=9, Font=Enum.Font.Gotham,

    }, rf)

    local pingNum=tonumber(data.ping)

    local pingCol=(data.ping=="?") and C.Sub or (pingNum<80 and C.Green or C.Yellow)

    new("TextLabel",{

        Size=UDim2.new(0,38,1,0), Position=UDim2.new(0,264,0,0),

        BackgroundTransparency=1,

        Text=(data.ping=="?") and "?" or (data.ping.."ms"),

        TextColor3=pingCol, TextSize=9, Font=Enum.Font.Gotham,

    }, rf)

    new("TextLabel",{

        Size=UDim2.new(0,50,1,0), Position=UDim2.new(0,306,0,0),

        BackgroundTransparency=1, Text=data.stype, TextColor3=C.Sub,

        TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

    }, rf)

    local jb = new("TextButton",{

        Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-44,0.5,-10),

        BackgroundColor3=C.JoinBtn, Text="Join", TextColor3=C.White,

        TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

    }, rf)

    corner(5,jb); hov(jb,C.JoinBtn,C.JoinHov)

    jb.MouseButton1Click:Connect(function()

        addHistory(data)

        pcall(function()

            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,data.jobid,lp)

        end)

    end)

    return rf

end

local function renderResults()

    for _,f in pairs(rowFrames) do f:Destroy() end

    rowFrames={}

    resBadgeLbl.Text = tostring(#state.results)

    rowScroll.CanvasSize = UDim2.new(0,0,0,#state.results*31)

    emptyLbl.Visible = #state.results==0

    for i,d in ipairs(state.results) do rowFrames[i]=buildResultRow(i,d) end

end

local function doSearch()

    local jobid = searchInput.Text:match("^%s*(.-)%s*$")

    if jobid=="" then return end

    addRecentChip(jobid)

    state.results={}

    local ok = pcall(function()

        local excl = tostring(state.excludeFull)

        local body = httpGet(

            "https://games.roblox.com/v1/games/"..game.PlaceId

            .."/servers/Public?limit=100&excludeFullGames="..excl

        )

        local decoded = HttpService:JSONDecode(body)

        for _, sv in ipairs(decoded.data or {}) do

            if sv.id then

                table.insert(state.results,{

                    jobid=sv.id, players=sv.playing or 0,

                    max=sv.maxPlayers or 0, ping=sv.ping or 0, stype="Public",

                })

            end

        end

    end)

    if not ok or #state.results==0 then

        state.results = {{jobid=jobid,players="?",max="?",ping="?",stype="Public"}}

    end

    renderResults()

    searchInput.Text=""

end

searchBtn.MouseButton1Click:Connect(doSearch)

searchInput.FocusLost:Connect(function(enter) if enter then doSearch() end end)

refreshBtn.MouseButton1Click:Connect(function() if #state.results>0 then renderResults() end end)

renderResults()

local modSec = new("Frame",{

    Size=UDim2.new(1,-6,0,308), Position=UDim2.new(0,0,0,6),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

}, rightP)

corner(9,modSec)

local modHdrRow = new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1}, modSec)

icon(ASSETS.Player,13,modHdrRow,UDim2.new(0,10,0.5,-6),C.Purple)

new("TextLabel",{

    Size=UDim2.new(1,-30,1,0), Position=UDim2.new(0,27,0,0),

    BackgroundTransparency=1, Text="Player Modifiers", TextColor3=C.Purple,

    TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, modHdrRow)

local function makeSliderBlock(parent, ypos, blockTitle, lbl1, val1, key1, lbl2, val2, key2)

    local blk = new("Frame",{

        Size=UDim2.new(1,-16,0,122), Position=UDim2.new(0,8,0,ypos),

        BackgroundColor3=C.Card, BorderSizePixel=0,

    }, parent)

    corner(7,blk)

    new("TextLabel",{

        Size=UDim2.new(1,-14,0,14), Position=UDim2.new(0,8,0,6),

        BackgroundTransparency=1, Text=blockTitle, TextColor3=C.Text,

        TextSize=10, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left,

    }, blk)

    local function mkSlider(lbl, val, key, yo)

        new("TextLabel",{

            Size=UDim2.new(0,90,0,12), Position=UDim2.new(0,8,0,yo),

            BackgroundTransparency=1, Text=lbl, TextColor3=C.Sub,

            TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

        }, blk)

        local vbox = new("TextLabel",{

            Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-42,0,yo-2),

            BackgroundColor3=C.Input, Text=tostring(val), TextColor3=C.Text,

            TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

        }, blk)

        corner(4,vbox)

        local track = new("Frame",{

            Size=UDim2.new(1,-16,0,4), Position=UDim2.new(0,8,0,yo+16),

            BackgroundColor3=C.SliderBG, BorderSizePixel=0,

        }, blk)

        corner(99,track)

        local fill = new("Frame",{

            Size=UDim2.new(val/200,0,1,0), BackgroundColor3=C.Purple, BorderSizePixel=0,

        }, track)

        corner(99,fill)

        local knob = new("Frame",{

            Size=UDim2.new(0,12,0,12), Position=UDim2.new(val/200,-6,0.5,-6),

            BackgroundColor3=C.White, BorderSizePixel=0,

        }, track)

        corner(99,knob)

        local ds=false

        local function updateSlider(xpos)

            local rel=math.clamp((xpos-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)

            local nv=math.floor(rel*200)

            state[key]=nv; vbox.Text=tostring(nv)

            fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,-6,0.5,-6)

        end

        track.InputBegan:Connect(function(i)

            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then

                ds=true; updateSlider(i.Position.X)

            end

        end)

        knob.InputBegan:Connect(function(i)

            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then

                ds=true; updateSlider(i.Position.X)

            end

        end)

        UserInputService.InputChanged:Connect(function(i)

            if ds and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then

                updateSlider(i.Position.X)

            end

        end)

        UserInputService.InputEnded:Connect(function(i)

            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then ds=false end

        end)

    end

    mkSlider(lbl1,val1,key1,24)

    mkSlider(lbl2,val2,key2,74)

end

makeSliderBlock(modSec,32,"WalkSpeed","WalkSpeed",100,"walkSpeed","Slide Power",50,"slidePower1")

makeSliderBlock(modSec,162,"JumpPower","JumpPower",100,"jumpPower","Slide Power",50,"slidePower2")

local applyBtn = new("TextButton",{

    Size=UDim2.new(1,-16,0,34), Position=UDim2.new(0,8,0,292),

    BackgroundColor3=C.Purple, Text="Apply to Player", TextColor3=C.White,

    TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0,

}, modSec)

corner(8,applyBtn); hov(applyBtn,C.Purple,C.PurpleHov)

applyBtn.MouseButton1Click:Connect(function()

    local char=lp.Character

    if char then

        local hum=char:FindFirstChildOfClass("Humanoid")

        if hum then hum.WalkSpeed=state.walkSpeed; hum.JumpPower=state.jumpPower end

    end

    tw(applyBtn,{BackgroundColor3=C.Green},0.1)

    task.delay(0.7,function() tw(applyBtn,{BackgroundColor3=C.Purple},0.2) end)

end)

-- ══════════════════════════════════════════════════════════════════════════════
--  PAGE: Scripts Finder
-- ══════════════════════════════════════════════════════════════════════════════

local scriptPage = new("Frame",{

    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false,

}, content)

local spHdr = new("Frame",{

    Size=UDim2.new(1,0,0,36), BackgroundTransparency=1,

}, scriptPage)

icon(ASSETS.Scripts,18,spHdr,UDim2.new(0,10,0.5,-9),C.Purple)

new("TextLabel",{

    Size=UDim2.new(0,140,0,14), Position=UDim2.new(0,34,0,4),

    BackgroundTransparency=1, Text="Script Finder", TextColor3=C.Purple,

    TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, spHdr)

new("TextLabel",{

    Size=UDim2.new(0,200,0,11), Position=UDim2.new(0,34,0,20),

    BackgroundTransparency=1, Text="Powered by ScriptBlox", TextColor3=C.Sub,

    TextSize=8, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

}, spHdr)

local spSearchRow = new("Frame",{

    Size=UDim2.new(1,-12,0,28), Position=UDim2.new(0,6,0,38),

    BackgroundTransparency=1,

}, scriptPage)

local spSearchInput = new("TextBox",{

    Size=UDim2.new(1,-120,1,0), BackgroundColor3=C.Input, BorderSizePixel=0,

    PlaceholderText="Search scripts...", PlaceholderColor3=C.Sub,

    Text="", TextColor3=C.Text, TextSize=11, Font=Enum.Font.Gotham,

    ClearTextOnFocus=false,

}, spSearchRow)

corner(6,spSearchInput); pad(0,0,10,0,spSearchInput)

local spQuickBtn = new("TextButton",{

    Size=UDim2.new(0,38,1,0), Position=UDim2.new(1,-118,0,0),

    BackgroundColor3=C.Card, Text="", BorderSizePixel=0,

}, spSearchRow)

corner(6,spQuickBtn)

icon(ASSETS.Quick, 20, spQuickBtn, UDim2.new(0.5,-10,0.5,-10), C.Purple)

hov(spQuickBtn, C.Card, Color3.fromRGB(50,50,72))

local spSearchBtn = new("TextButton",{

    Size=UDim2.new(0,74,1,0), Position=UDim2.new(1,-74,0,0),

    BackgroundColor3=C.Purple, Text="Search", TextColor3=C.White,

    TextSize=11, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

}, spSearchRow)

corner(6,spSearchBtn); hov(spSearchBtn,C.Purple,C.PurpleHov)

spQuickBtn.MouseButton1Click:Connect(function()

    local ok, info = pcall(function()

        return MarketplaceService:GetProductInfo(game.PlaceId)

    end)

    if ok and info and info.Name then

        spSearchInput.Text = info.Name

    else

        spSearchInput.Text = tostring(game.PlaceId)

    end

end)

local pageBar = new("Frame",{

    Size=UDim2.new(1,-12,0,26), Position=UDim2.new(0,6,0,70),

    BackgroundTransparency=1,

}, scriptPage)

local prevBtn = new("TextButton",{

    Size=UDim2.new(0,28,1,0), Position=UDim2.new(0,0,0,0),

    BackgroundColor3=C.Card, Text="<", TextColor3=C.Text,

    TextSize=13, Font=Enum.Font.GothamBold, BorderSizePixel=0,

}, pageBar)

corner(6, prevBtn); hov(prevBtn, C.Card, C.PurpleDim)

local pageLbl = new("TextLabel",{

    Size=UDim2.new(0,40,1,0), Position=UDim2.new(0,32,0,0),

    BackgroundColor3=C.Card, Text="1", TextColor3=C.Purple,

    TextSize=11, Font=Enum.Font.GothamBold, BorderSizePixel=0,

}, pageBar)

corner(6, pageLbl)

local nextBtn = new("TextButton",{

    Size=UDim2.new(0,28,1,0), Position=UDim2.new(0,76,0,0),

    BackgroundColor3=C.Card, Text=">", TextColor3=C.Text,

    TextSize=13, Font=Enum.Font.GothamBold, BorderSizePixel=0,

}, pageBar)

corner(6, nextBtn); hov(nextBtn, C.Card, C.PurpleDim)

local spScroll = new("ScrollingFrame",{

    Size=UDim2.new(1,0,1,-100), Position=UDim2.new(0,0,0,100),

    BackgroundTransparency=1, BorderSizePixel=0,

    ScrollBarThickness=3, ScrollBarImageColor3=C.Purple,

    CanvasSize=UDim2.new(0,0,0,0),

}, scriptPage)

local spEmpty = new("TextLabel",{

    Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,10),

    BackgroundTransparency=1, Text="Search for scripts above.",

    TextColor3=C.Sub, TextSize=11, Font=Enum.Font.Gotham,

}, spScroll)

local spLoading = new("TextLabel",{

    Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0,10),

    BackgroundTransparency=1, Text="Loading...",

    TextColor3=C.Sub, TextSize=11, Font=Enum.Font.Gotham, Visible=false,

}, spScroll)

local spBubbles = {}

local function clearBubbles()

    for _, b in pairs(spBubbles) do b:Destroy() end

    spBubbles={}

end

local function buildScriptBubble(idx, s, yOff)

    -- ── bubble height is now 168 to fit the new Author row ──
    local bub = new("Frame",{

        Size=UDim2.new(1,-16,0,168), Position=UDim2.new(0,8,0,yOff),

        BackgroundColor3=C.Bubble, BorderSizePixel=0,

    }, spScroll)

    corner(10,bub)

    local accentLine = new("Frame",{

        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,0),

        BackgroundColor3=C.Purple, BorderSizePixel=0,

    }, bub)

    corner(10, accentLine)

    -- ── Thumbnail (90×90) ──────────────────────────────────────────────────

    local thumb = new("ImageLabel",{

        Size=UDim2.new(0,90,0,90), Position=UDim2.new(0,10,0,12),

        BackgroundColor3=C.Card, BorderSizePixel=0,

        Image="", ScaleType=Enum.ScaleType.Crop,

    }, bub)

    corner(7, thumb)

    local placeId = s.game and s.game.gameId

    if placeId then

        thumb.Image = "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid="

            ..tostring(placeId).."&fmt=png&wd=420&ht=420"

    end

    -- ── "Key System" label — bottom-right of thumbnail, yellow (only if s.key == true) ──
    if s.key == true then

        new("TextLabel",{

            Size=UDim2.new(0,88,0,14),

            Position=UDim2.new(0,12,0,88),

            BackgroundTransparency=1,

            Text="Key System",

            TextColor3=C.Yellow,

            TextSize=8,

            Font=Enum.Font.GothamBold,

            TextXAlignment=Enum.TextXAlignment.Right,

            ZIndex=3,

        }, bub)

    end

    -- ── Title ──────────────────────────────────────────────────────────────

    new("TextLabel",{

        Size=UDim2.new(1,-116,0,16), Position=UDim2.new(0,108,0,10),

        BackgroundTransparency=1,

        Text=s.title or "Untitled",

        TextColor3=C.Text, TextSize=12, Font=Enum.Font.GothamBold,

        TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,

    }, bub)

    -- ── Game name ──────────────────────────────────────────────────────────

    local gameName = (s.game and s.game.name) or "Unknown"

    new("TextLabel",{

        Size=UDim2.new(1,-116,0,11), Position=UDim2.new(0,108,0,28),

        BackgroundTransparency=1, Text="Game: "..gameName,

        TextColor3=C.Sub, TextSize=9, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,

    }, bub)

    -- ── Author ─────────────────────────────────────────────────────────────
    local authorLbl = new("TextLabel",{

        Size=UDim2.new(1,-116,0,11), Position=UDim2.new(0,108,0,41),

        BackgroundTransparency=1, Text="Author: ...",

        TextColor3=C.Sub, TextSize=9, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,

    }, bub)

    -- fetch owner from individual script endpoint using slug
    if s.slug then

        task.spawn(function()

            local ok, body = pcall(httpGet, "https://scriptblox.com/api/script/"..s.slug)

            if ok and body then

                local decoded

                pcall(function() decoded = HttpService:JSONDecode(body) end)

                local owner = decoded and decoded.script and decoded.script.owner

                local name = owner and owner.username

                if name and name ~= "" then

                    authorLbl.Text = "Author: "..name

                else

                    authorLbl.Text = "Author: Unknown"

                end

            else

                authorLbl.Text = "Author: Unknown"

            end

        end)

    else

        authorLbl.Text = "Author: Unknown"

    end

    -- ── Views / Type ───────────────────────────────────────────────────────

    local scriptType = s.scriptType or "free"

    new("TextLabel",{

        Size=UDim2.new(1,-116,0,11), Position=UDim2.new(0,108,0,54),

        BackgroundTransparency=1,

        Text="Views: "..(s.views or "0").."   Type: "..scriptType,

        TextColor3=C.Sub, TextSize=9, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left,

    }, bub)

    -- ── Matched ────────────────────────────────────────────────────────────

    local matchedVal

    if type(s.matched) == "table" then

        matchedVal = #s.matched > 0 and table.concat(s.matched, ", ") or "None"

    else

        matchedVal = tostring(s.matched or "N/A")

    end

    new("TextLabel",{

        Size=UDim2.new(1,-116,0,11), Position=UDim2.new(0,108,0,67),

        BackgroundTransparency=1,

        Text="Matched: "..matchedVal,

        TextColor3=C.Sub, TextSize=9, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left,

    }, bub)

    -- ── Status chips ───────────────────────────────────────────────────────

    local isPatched   = s.isPatched == true

    local isUniversal = s.isUniversal == true

    local isPrivate   = s.visibility == "private"

    local isVerified  = s.verified == true

    local tagX = 108

    local function addChip(label, val, trueCol)

        local bg = val and trueCol or Color3.fromRGB(40,40,58)

        local tc = val and C.White or Color3.fromRGB(90,90,110)

        local f = new("Frame",{

            Size=UDim2.new(0,0,0,14), Position=UDim2.new(0,tagX,0,80),

            BackgroundColor3=bg, BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.X,

        }, bub)

        corner(99,f)

        local l = new("TextLabel",{

            Size=UDim2.new(0,0,1,0), BackgroundTransparency=1,

            Text=label, TextColor3=tc, TextSize=8,

            Font=Enum.Font.GothamBold, AutomaticSize=Enum.AutomaticSize.X,

        }, f)

        pad(0,0,5,5,l)

        tagX = tagX + (#label * 5) + 18

    end

    addChip("Patched",   isPatched,   C.Red)

    addChip("Universal", isUniversal, C.Green)

    addChip("Private",   isPrivate,   C.Yellow)

    addChip("Verified",  isVerified,  C.Purple)

    new("TextLabel",{

        Size=UDim2.new(1,-116,0,11), Position=UDim2.new(0,108,0,97),

        BackgroundTransparency=1,

        Text="Patched: "..yesNo(isPatched).."  Universal: "..yesNo(isUniversal)

             .."  Private: "..yesNo(isPrivate).."  Verified: "..yesNo(isVerified),

        TextColor3=C.Sub, TextSize=8, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left,

    }, bub)

    -- ── Copy / Execute buttons ─────────────────────────────────────────────

    local copyBtn = new("TextButton",{

        Size=UDim2.new(0,72,0,24), Position=UDim2.new(1,-158,1,-32),

        BackgroundColor3=C.Card, Text="Copy", TextColor3=C.Text,

        TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

    }, bub)

    corner(6,copyBtn); hov(copyBtn,C.Card,Color3.fromRGB(50,50,72))

    local execBtn = new("TextButton",{

        Size=UDim2.new(0,76,0,24), Position=UDim2.new(1,-76,1,-32),

        BackgroundColor3=C.Purple, Text="Execute", TextColor3=C.White,

        TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

    }, bub)

    corner(6,execBtn); hov(execBtn,C.Purple,C.PurpleHov)

    local function getScript()

        if s.rawScript and s.rawScript~="" then return s.rawScript end

        if s.script and s.script~="" then return s.script end

        if s.slug then

            local ok3, body3 = pcall(httpGet, "https://rawscripts.net/raw/"..s.slug)

            if ok3 then return body3 end

        end

        return nil

    end

    copyBtn.MouseButton1Click:Connect(function()

        local raw = getScript()

        if raw and raw~="" then

            pcall(function()

                if setclipboard then setclipboard(raw)

                elseif toclipboard then toclipboard(raw) end

            end)

            copyBtn.Text = "Copied!"

            tw(copyBtn,{BackgroundColor3=C.Green},0.1)

            task.delay(1.5,function()

                copyBtn.Text = "Copy"

                tw(copyBtn,{BackgroundColor3=C.Card},0.2)

            end)

        else

            copyBtn.Text = "No script"

            task.delay(1.5,function() copyBtn.Text="Copy" end)

        end

    end)

    execBtn.MouseButton1Click:Connect(function()

        local raw = getScript()

        if raw and raw~="" then

            execBtn.Text = "Running..."

            tw(execBtn,{BackgroundColor3=C.Green},0.1)

            pcall(function()

                if loadstring then loadstring(raw)()

                elseif syn and syn.execute then syn.execute(raw) end

            end)

            task.delay(1.5,function()

                execBtn.Text = "Execute"

                tw(execBtn,{BackgroundColor3=C.Purple},0.2)

            end)

        else

            execBtn.Text = "No script"

            task.delay(1.5,function() execBtn.Text="Run Script" end)

        end

    end)

    spBubbles[idx] = bub

    return bub

end

local function renderScripts(list)

    clearBubbles()

    spEmpty.Visible = #list==0

    spLoading.Visible = false

    local totalH = 8

    for i, s in ipairs(list) do

        buildScriptBubble(i, s, totalH)

        totalH = totalH + 176  -- updated spacing for taller bubble

    end

    spScroll.CanvasSize = UDim2.new(0,0,0,math.max(totalH, 50))

end

local function doScriptSearch(pageOverride)

    local q = spSearchInput.Text:match("^%s*(.-)%s*$")

    if q=="" then return end

    state.scriptQuery = q

    local page = pageOverride or 1

    state.scriptPage = page

    pageLbl.Text = tostring(page)

    spLoading.Visible=true; spEmpty.Visible=false

    clearBubbles()

    task.spawn(function()

        local ok, body = pcall(httpGet,

            "https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(q).."&page="..page.."&max=20"

        )

        spLoading.Visible=false

        if not ok then spEmpty.Text="Search failed."; spEmpty.Visible=true; return end

        local decoded

        local ok2,err = pcall(function() decoded=HttpService:JSONDecode(body) end)

        if not ok2 or not decoded then spEmpty.Text="Parse error."; spEmpty.Visible=true; return end

        local scripts = (decoded.result and decoded.result.scripts) or decoded.scripts or {}

        state.scriptResults = scripts

        state.scriptTotalPages = (decoded.result and decoded.result.totalPages) or decoded.totalPages or page

        renderScripts(scripts)

    end)

end

spSearchBtn.MouseButton1Click:Connect(function() doScriptSearch(1) end)

spSearchInput.FocusLost:Connect(function(enter) if enter then doScriptSearch(1) end end)

prevBtn.MouseButton1Click:Connect(function()

    if state.scriptPage > 1 then doScriptSearch(state.scriptPage - 1) end

end)

nextBtn.MouseButton1Click:Connect(function()

    doScriptSearch(state.scriptPage + 1)

end)

-- ══════════════════════════════════════════════════════════════════════════════
--  PAGE: AI Chat
-- ══════════════════════════════════════════════════════════════════════════════

local aiPage = new("Frame",{

    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false,

}, content)

local aiHdr = new("Frame",{

    Size=UDim2.new(1,0,0,44), Position=UDim2.new(0,0,0,32),

    BackgroundTransparency=1,

}, aiPage)

icon(ASSETS.AI,18,aiHdr,UDim2.new(0,10,0.5,-9),C.Purple)

new("TextLabel",{

    Size=UDim2.new(0,140,0,14), Position=UDim2.new(0,34,0,6),

    BackgroundTransparency=1, Text="AI Assistant", TextColor3=C.Purple,

    TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

}, aiHdr)

local aiModelLbl = new("TextLabel",{

    Size=UDim2.new(0,200,0,11), Position=UDim2.new(0,34,0,22),

    BackgroundTransparency=1, Text="Model: "..state.aiModel, TextColor3=C.Sub,

    TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

}, aiHdr)

local profileThumb = new("ImageLabel",{

    Size=UDim2.new(0,36,0,36), Position=UDim2.new(1,-46,0.5,-18),

    BackgroundColor3=C.Card, BorderSizePixel=0,

    Image="",

    ScaleType=Enum.ScaleType.Crop,

}, aiHdr)

corner(99,profileThumb)

task.spawn(function()

    local ok, img = pcall(function()

        return game:GetService("Players"):GetUserThumbnailAsync(

            lp.UserId,

            Enum.ThumbnailType.HeadShot,

            Enum.ThumbnailSize.Size150x150

        )

    end)

    if ok and img then profileThumb.Image = img end

end)

local aiSettingBtn = new("TextButton",{

    Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-84,0.5,-14),

    BackgroundColor3=C.Card, Text="", BorderSizePixel=0,

}, aiHdr)

corner(6,aiSettingBtn)

icon(ASSETS.SettingBtn, 18, aiSettingBtn, UDim2.new(0.5,-9,0.5,-9), C.Sub)

hov(aiSettingBtn,C.Card,Color3.fromRGB(50,50,72))

local aiSettingPanel = new("ScrollingFrame",{

    Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,76),

    BackgroundColor3=C.Panel, BorderSizePixel=0,

    Visible=false, ZIndex=10,

    ScrollBarThickness=3, ScrollBarImageColor3=C.Purple,

    CanvasSize=UDim2.new(0,0,0,0),

    AutomaticCanvasSize=Enum.AutomaticSize.Y,

}, aiPage)

corner(8,aiSettingPanel)

local settingPanelOpen = false

local MODELS = {

    "openai",

}

local modelBtns = {}

local selectedModelLbl

local function buildSettingsPanel()

    new("TextLabel",{

        Size=UDim2.new(1,-20,0,18), Position=UDim2.new(0,10,0,8),

        BackgroundTransparency=1, Text="Select AI Model", TextColor3=C.Purple,

        TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,

    }, aiSettingPanel)

    selectedModelLbl = new("TextLabel",{

        Size=UDim2.new(1,-20,0,11), Position=UDim2.new(0,10,0,28),

        BackgroundTransparency=1, Text="Active: "..state.aiModel, TextColor3=C.Green,

        TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

    }, aiSettingPanel)

    for i, mdl in ipairs(MODELS) do

        local row = new("Frame",{

            Size=UDim2.new(1,-20,0,28), Position=UDim2.new(0,10,0,42+(i-1)*32),

            BackgroundColor3=state.aiModel==mdl and C.PurpleDim or C.Card,

            BorderSizePixel=0,

        }, aiSettingPanel)

        corner(6,row)

        new("TextLabel",{

            Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,10,0,0),

            BackgroundTransparency=1, Text=mdl, TextColor3=C.Text,

            TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,

        }, row)

        local selBtn = new("TextButton",{

            Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-66,0.5,-10),

            BackgroundColor3=state.aiModel==mdl and C.Purple or C.PurpleDim,

            Text="Select", TextColor3=C.White, TextSize=9,

            Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

        }, row)

        corner(5,selBtn)

        modelBtns[i] = {row=row, btn=selBtn, model=mdl}

        selBtn.MouseButton1Click:Connect(function()

            state.aiModel = mdl

            aiModelLbl.Text = "Model: "..mdl

            selectedModelLbl.Text = "Active: "..mdl

            for _, mb in pairs(modelBtns) do

                local isThis = mb.model == mdl

                tw(mb.row,{BackgroundColor3=isThis and C.PurpleDim or C.Card},0.1)

                tw(mb.btn,{BackgroundColor3=isThis and C.Purple or C.PurpleDim},0.1)

            end

            selBtn.Text = "Active!"

            tw(selBtn,{BackgroundColor3=C.Green},0.1)

            task.delay(1.5,function()

                selBtn.Text = "Select"

                local isNow = state.aiModel == mdl

                tw(selBtn,{BackgroundColor3=isNow and C.Purple or C.PurpleDim},0.2)

            end)

        end)

    end

    local panelH = 42 + #MODELS*32 + 8

    aiSettingPanel.Size = UDim2.new(1,-20,0,panelH)

end

buildSettingsPanel()

aiSettingBtn.MouseButton1Click:Connect(function()

    settingPanelOpen = not settingPanelOpen

    aiSettingPanel.Visible = settingPanelOpen

    if settingPanelOpen then

        local panelH = math.min(42 + #MODELS*32 + 8, 200)

        aiSettingPanel.Size = UDim2.new(1,-20,0,panelH)

    end

end)

local aiChatScroll = new("ScrollingFrame",{

    Size=UDim2.new(1,-20,0,316), Position=UDim2.new(0,10,0,88),

    BackgroundTransparency=1, BorderSizePixel=0,

    ScrollBarThickness=3, ScrollBarImageColor3=C.Purple,

    CanvasSize=UDim2.new(0,0,0,0),

    AutomaticCanvasSize=Enum.AutomaticSize.Y,

}, aiPage)

local aiChatLayout = Instance.new("UIListLayout")

aiChatLayout.SortOrder = Enum.SortOrder.LayoutOrder

aiChatLayout.Padding = UDim.new(0,6)

aiChatLayout.Parent = aiChatScroll

local aiInputRow = new("Frame",{

    Size=UDim2.new(1,-20,0,36), Position=UDim2.new(0,10,0,390),

    BackgroundTransparency=1,

}, aiPage)

local aiClearBtn = new("TextButton",{

    Size=UDim2.new(0,30,0,36), Position=UDim2.new(0,0,0,0),

    BackgroundColor3=C.Card, Text="C", TextColor3=C.Sub,

    TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0,

}, aiInputRow)

corner(8,aiClearBtn)

hov(aiClearBtn,C.Card,Color3.fromRGB(50,50,72))

local aiInput = new("TextBox",{

    Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,36,0,0),

    BackgroundColor3=C.Input, BorderSizePixel=0,

    PlaceholderText="Ask AI or request Lua code...", PlaceholderColor3=C.Sub,

    Text="", TextColor3=C.Text, TextSize=11, Font=Enum.Font.Gotham,

    ClearTextOnFocus=false, TextWrapped=false,

}, aiInputRow)

corner(8,aiInput); pad(0,0,10,0,aiInput)

local aiSendBtn = new("ImageButton",{

    Size=UDim2.new(0,38,0,36), Position=UDim2.new(1,-38,0,0),

    BackgroundColor3=C.Purple, Image="", BorderSizePixel=0,

}, aiInputRow)

corner(8,aiSendBtn)

icon(ASSETS.Send, 22, aiSendBtn, UDim2.new(0.5,-11,0.5,-11), C.White)

hov(aiSendBtn,C.Purple,C.PurpleHov)

local msgOrder = 0

local function extractLuaCode(text)

    local code = text:match("```lua%s*\n(.-)\n```") or text:match("```%s*\n(.-)\n```")

    return code

end

local function addChatBubble(text, isUser)

    msgOrder = msgOrder + 1

    local bubbleWrap = new("Frame",{

        Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,

        AutomaticSize=Enum.AutomaticSize.Y,

        LayoutOrder=msgOrder,

    }, aiChatScroll)

    local maxW = 400

    local bubble = new("Frame",{

        Size=UDim2.new(0,maxW,0,0), BackgroundColor3=isUser and C.Purple or C.Card,

        BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.Y,

        Position=isUser and UDim2.new(1,-maxW,0,0) or UDim2.new(0,0,0,0),

    }, bubbleWrap)

    corner(10,bubble)

    pad(8,8,10,10,bubble)

    local bubbleLayout = Instance.new("UIListLayout")

    bubbleLayout.SortOrder = Enum.SortOrder.LayoutOrder

    bubbleLayout.Padding = UDim.new(0, 6)

    bubbleLayout.FillDirection = Enum.FillDirection.Vertical

    bubbleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    bubbleLayout.Parent = bubble

    local lbl = new("TextLabel",{

        Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,

        Text=text, TextColor3=isUser and C.White or C.Text,

        TextSize=10, Font=Enum.Font.Gotham,

        TextXAlignment=Enum.TextXAlignment.Left,

        TextWrapped=true, AutomaticSize=Enum.AutomaticSize.Y,

        LayoutOrder=1,

    }, bubble)

    task.defer(function()

        aiChatScroll.CanvasPosition = Vector2.new(0, math.huge)

    end)

    return lbl, bubble

end

local function addCodeButtons(bubble, luaCode)

    local btnRow = new("Frame",{

        Size=UDim2.new(1,0,0,30),

        BackgroundTransparency=1,

        AutomaticSize=Enum.AutomaticSize.None,

        LayoutOrder=2,

    }, bubble)

    local copyBtn = new("TextButton",{

        Size=UDim2.new(0,92,0,24), Position=UDim2.new(0,0,0.5,-12),

        BackgroundColor3=C.Card, Text="Copy Code", TextColor3=C.Text,

        TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

    }, btnRow)

    corner(6,copyBtn); hov(copyBtn,C.Card,Color3.fromRGB(50,50,72))

    local runBtn = new("TextButton",{

        Size=UDim2.new(0,92,0,24), Position=UDim2.new(0,98,0.5,-12),

        BackgroundColor3=C.Purple, Text="Run Script", TextColor3=C.White,

        TextSize=10, Font=Enum.Font.GothamSemibold, BorderSizePixel=0,

    }, btnRow)

    corner(6,runBtn); hov(runBtn,C.Purple,C.PurpleHov)

    copyBtn.MouseButton1Click:Connect(function()

        pcall(function()

            if setclipboard then setclipboard(luaCode)

            elseif toclipboard then toclipboard(luaCode) end

        end)

        copyBtn.Text = "Copied!"

        tw(copyBtn,{BackgroundColor3=C.Green},0.1)

        task.delay(1.5,function()

            copyBtn.Text = "Copy Code"

            tw(copyBtn,{BackgroundColor3=C.Card},0.2)

        end)

    end)

    runBtn.MouseButton1Click:Connect(function()

        runBtn.Text = "Done!"

        tw(runBtn,{BackgroundColor3=C.Green},0.1)

        pcall(function()

            if loadstring then loadstring(luaCode)()

            elseif syn and syn.execute then syn.execute(luaCode) end

        end)

        task.delay(1.5,function()

            runBtn.Text = "Run Script"

            tw(runBtn,{BackgroundColor3=C.Purple},0.2)

        end)

    end)

end

local aiThinking = false

local function sendAIMessage()

    if aiThinking then return end

    local userText = aiInput.Text:match("^%s*(.-)%s*$")

    if userText == "" then return end

    aiInput.Text = ""

    addChatBubble(userText, true)

    table.insert(state.aiMessages, {role="user", content=userText})

    aiThinking = true

    for _, ch in ipairs(aiSendBtn:GetChildren()) do

        if ch:IsA("ImageLabel") then ch.ImageColor3 = C.Sub end

    end

    local thinkLbl, thinkBubble = addChatBubble("...", false)

    task.spawn(function()

        local ok, respBody = pcall(httpPost,

            "https://text.pollinations.ai/openai",

            HttpService:JSONEncode({

                model = "openai",

                messages = state.aiMessages,

                stream = false,

            }),

            {

                ["Content-Type"] = "application/json",

            }

        )

        if ok and respBody and respBody ~= "" then

            local aiText

            local decoded

            pcall(function() decoded = HttpService:JSONDecode(respBody) end)

            if decoded and decoded.choices and decoded.choices[1] then

                aiText = decoded.choices[1].message and decoded.choices[1].message.content

            elseif decoded and decoded.content then

                aiText = decoded.content

            elseif decoded and decoded.text then

                aiText = decoded.text

            elseif type(respBody) == "string" and not respBody:find("<!DOCTYPE") then

                aiText = respBody:match("^%s*(.-)%s*$")

            end

            aiText = aiText or "Sorry, I couldn't get a response."

            thinkLbl.Text = aiText

            table.insert(state.aiMessages, {role="assistant", content=aiText})

            local luaCode = extractLuaCode(aiText)

            if luaCode then

                addCodeButtons(thinkBubble, luaCode)

            end

        else

            thinkLbl.Text = "Error: " .. tostring(respBody)

        end

        aiThinking = false

        for _, ch in ipairs(aiSendBtn:GetChildren()) do

            if ch:IsA("ImageLabel") then ch.ImageColor3 = C.White end

        end

        task.defer(function()

            aiChatScroll.CanvasPosition = Vector2.new(0, math.huge)

        end)

    end)

end

aiSendBtn.MouseButton1Click:Connect(sendAIMessage)

aiInput.FocusLost:Connect(function(enter) if enter then sendAIMessage() end end)

aiClearBtn.MouseButton1Click:Connect(function()

    for _, ch in pairs(aiChatScroll:GetChildren()) do

        if ch:IsA("Frame") then ch:Destroy() end

    end

    state.aiMessages = {}

    msgOrder = 0

end)

local function makeSimplePage(iconAsset, title, body)

    local pg = new("Frame",{

        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false,

    }, content)

    icon(iconAsset,32,pg,UDim2.new(0.5,-16,0.35,-16),C.Purple)

    new("TextLabel",{

        Size=UDim2.new(0.8,0,0,26), Position=UDim2.new(0.1,0,0.46,0),

        BackgroundTransparency=1, Text=title, TextColor3=C.Text,

        TextSize=17, Font=Enum.Font.GothamBold,

    }, pg)

    new("TextLabel",{

        Size=UDim2.new(0.7,0,0,50), Position=UDim2.new(0.15,0,0.56,0),

        BackgroundTransparency=1, Text=body, TextColor3=C.Sub,

        TextSize=11, Font=Enum.Font.Gotham, TextWrapped=true,

    }, pg)

    return pg

end

local setPage   = makeSimplePage(ASSETS.Setting,"Settings","Settings coming soon.")

local aboutPage = makeSimplePage(ASSETS.About,"About","Finds and joins Roblox servers.\nScript finder powered by ScriptBlox.\n\nMade by Drek")

local PAGES = {

    ServerFinder = sfPage,

    Scripts      = scriptPage,

    AI           = aiPage,

    Favorites    = favPage,

    History      = histPage,

    Settings     = setPage,

    About        = aboutPage,

}

for _, nb in pairs(navBtns) do

    nb.btn.MouseButton1Click:Connect(function()

        for _, pg in pairs(PAGES) do pg.Visible=false end

        local pg = PAGES[nb.page]

        if pg then pg.Visible=true end

        setNav(nb.page)

    end)

end

setNav("ServerFinder")
