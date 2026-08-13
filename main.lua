repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local Config = {
    BossDistance = 8,
    RefreshRate = 0.5,
    AutoFollow = false,
    ItemESP = false
}

local Bosses = {}
local Items = {}

local SelectedBoss = nil
local SelectedItem = nil

--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local function Character()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    return char, root
end

--------------------------------------------------
-- THEME
--------------------------------------------------

local Theme = {
    Background = Color3.fromRGB(14,13,18),
    Inline = Color3.fromRGB(22,21,28),
    Border = Color3.fromRGB(42,40,52),
    Text = Color3.fromRGB(242,240,248),
    Muted = Color3.fromRGB(148,144,162),
    Accent = Color3.fromRGB(215,40,114),
    Element = Color3.fromRGB(32,30,40)
}

--------------------------------------------------
-- CLEAN OLD HUB
--------------------------------------------------

local Parent =
    (gethui and gethui())
    or CoreGui

local Old = Parent:FindFirstChild("SoloShindoHub")

if Old then
    Old:Destroy()
end

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function Corner(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r or 5)
    c.Parent = obj
end

local function Stroke(obj)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Border
    s.Thickness = 1
    s.Parent = obj
end

local function Tween(obj,goal,time)
    TweenService:Create(
        obj,
        TweenInfo.new(
            time or .2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        goal
    ):Play()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "SoloShindoHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = Parent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,620,0,430)
Main.Position = UDim2.new(.5,-310,.5,-215)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = Gui

Corner(Main,7)
Stroke(Main)

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,55)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0,250,1,0)
Title.Position = UDim2.new(0,18,0,0)
Title.BackgroundTransparency = 1
Title.Text = "solo"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(0,150,1,0)
HubTitle.Position = UDim2.new(0,55,0,0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "hub"
HubTitle.TextColor3 = Theme.Accent
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 19
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = Header

--------------------------------------------------
-- CLOSE
--------------------------------------------------

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,32,0,32)
Close.Position = UDim2.new(1,-42,0,11)
Close.BackgroundColor3 = Theme.Element
Close.Text = "×"
Close.TextSize = 23
Close.TextColor3 = Theme.Muted
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = Header

Corner(Close,5)

Close.MouseEnter:Connect(function()
    Tween(Close,{
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Inline
    })
end)

Close.MouseLeave:Connect(function()
    Tween(Close,{
        TextColor3 = Theme.Muted,
        BackgroundColor3 = Theme.Element
    })
end)

Close.MouseButton1Click:Connect(function()
    Config.AutoFollow = false
    Gui:Destroy()
end)

--------------------------------------------------
-- DRAG
--------------------------------------------------

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.MouseMovement then
        return
    end

    local delta =
        input.Position - dragStart

    Main.Position =
        UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = false

    end

end)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,145,1,-65)
Sidebar.Position = UDim2.new(0,10,0,55)
Sidebar.BackgroundColor3 = Theme.Inline
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

Corner(Sidebar,6)
Stroke(Sidebar)

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-175,1,-65)
Content.Position = UDim2.new(0,165,0,55)
Content.BackgroundColor3 = Theme.Inline
Content.BorderSizePixel = 0
Content.Parent = Main

Corner(Content,6)
Stroke(Content)

--------------------------------------------------
-- PAGES
--------------------------------------------------

local Pages = {}

local function MakePage(name)

    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1,-20,1,-20)
    page.Position = UDim2.new(0,10,0,10)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content

    Pages[name] = page

    return page
end

local BossPage = MakePage("BOSS")
local ItemPage = MakePage("ITEMS")
local FarmPage = MakePage("FARM")
local TPPage = MakePage("TELEPORT")
local SettingsPage = MakePage("SETTINGS")

--------------------------------------------------
-- TAB SYSTEM
--------------------------------------------------

local buttons = {}

local function SelectPage(name)

    for n,page in pairs(Pages) do
        page.Visible = n == name
    end

    for n,b in pairs(buttons) do

        if n == name then

            Tween(b,{
                BackgroundColor3 =
                    Theme.Accent
            })

        else

            Tween(b,{
                BackgroundColor3 =
                    Theme.Element
            })

        end
    end
end

local tabY = 12

local function Tab(name)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(1,-16,0,38)
    b.Position = UDim2.new(0,8,0,tabY)

    b.BackgroundColor3 = Theme.Element
    b.BorderSizePixel = 0

    b.Text = name
    b.TextColor3 = Theme.Text
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold

    b.Parent = Sidebar

    Corner(b,5)

    tabY += 46

    buttons[name] = b

    b.MouseButton1Click:Connect(function()
        SelectPage(name)
    end)
end

Tab("BOSS")
Tab("ITEMS")
Tab("FARM")
Tab("TELEPORT")
Tab("SETTINGS")

--------------------------------------------------
-- BUTTON HELPER
--------------------------------------------------

local function Button(parent,text,y)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.new(0,10,0,y)

    b.BackgroundColor3 = Theme.Element
    b.BorderSizePixel = 0

    b.Text = text
    b.TextColor3 = Theme.Text

    b.TextSize = 13
    b.Font = Enum.Font.GothamBold

    b.Parent = parent

    Corner(b,5)

    b.MouseEnter:Connect(function()

        Tween(b,{
            BackgroundColor3 =
                Theme.Background
        })

    end)

    b.MouseLeave:Connect(function()

        Tween(b,{
            BackgroundColor3 =
                Theme.Element
        })

    end)

    return b
end

--------------------------------------------------
-- LABEL
--------------------------------------------------

local function Label(parent,text,y)

    local l = Instance.new("TextLabel")

    l.Size = UDim2.new(1,-20,0,35)
    l.Position = UDim2.new(0,10,0,y)

    l.BackgroundColor3 = Theme.Element
    l.BorderSizePixel = 0

    l.Text = text

    l.TextColor3 = Theme.Text
    l.TextSize = 13

    l.Font = Enum.Font.Gotham

    l.Parent = parent

    Corner(l,5)

    return l
end

--------------------------------------------------
-- BOSS SCANNER
--------------------------------------------------

local BossLabel =
    Label(
        BossPage,
        "Selected Boss : none",
        10
    )

local function ScanBosses()

    Bosses = {}

    local char =
        Player.Character

    for _,obj in ipairs(
        workspace:GetDescendants()
    ) do

        if obj:IsA("Model")
        and obj ~= char then

            local hum =
                obj:
                FindFirstChildOfClass(
                    "Humanoid"
                )

            local root =
                obj:
                FindFirstChild(
                    "HumanoidRootPart"
                )
                or
                obj:
                FindFirstChild(
                    "UpperTorso"
                )

            if hum
            and root
            and hum.Health > 0 then

                local playerCharacter =
                    false

                for _,p in ipairs(
                    Players:GetPlayers()
                ) do

                    if p.Character ==
                        obj then

                        playerCharacter =
                            true

                        break
                    end
                end

                if not
                    playerCharacter then

                    table.insert(
                        Bosses,
                        obj
                    )
                end
            end
        end
    end

    table.sort(
        Bosses,
        function(a,b)
            return
                a.Name:lower()
                <
                b.Name:lower()
        end
    )

    if #Bosses > 0 then

        SelectedBoss =
            Bosses[1]

        BossLabel.Text =
            "Selected Boss : "
            ..SelectedBoss.Name

    else

        SelectedBoss = nil

        BossLabel.Text =
            "No Boss/NPC found"

    end
end

--------------------------------------------------
-- BOSS INDEX
--------------------------------------------------

local BossIndex = 1

local NextBoss =
    Button(
        BossPage,
        "NEXT BOSS ▶",
        60
    )

NextBoss.MouseButton1Click:
Connect(function()

    ScanBosses()

    if #Bosses == 0 then
        return
    end

    BossIndex += 1

    if BossIndex >
        #Bosses then

        BossIndex = 1
    end

    SelectedBoss =
        Bosses[BossIndex]

    BossLabel.Text =
        "Selected Boss : "
        ..SelectedBoss.Name
        .." ["
        ..BossIndex
        .."/"
        ..#Bosses
        .."]"

end)

--------------------------------------------------
-- TP BOSS
--------------------------------------------------

local TpBoss =
    Button(
        BossPage,
        "⚡ TELEPORT TO BOSS",
        110
    )

TpBoss.MouseButton1Click:
Connect(function()

    if not SelectedBoss then
        return
    end

    local bossRoot =
        SelectedBoss:
        FindFirstChild(
            "HumanoidRootPart"
        )
        or
        SelectedBoss:
        FindFirstChild(
            "UpperTorso"
        )

    if not bossRoot then
        return
    end

    local _,root =
        Character()

    root.CFrame =
        bossRoot.CFrame
        *
        CFrame.new(
            0,
            3,
            Config.BossDistance
        )

end)

--------------------------------------------------
-- FOLLOW
--------------------------------------------------

local Follow =
    Button(
        BossPage,
        "AUTO FOLLOW : OFF",
        160
    )

Follow.MouseButton1Click:
Connect(function()

    Config.AutoFollow =
        not Config.AutoFollow

    Follow.Text =
        Config.AutoFollow
        and
        "AUTO FOLLOW : ON"
        or
        "AUTO FOLLOW : OFF"

    Follow.BackgroundColor3 =
        Config.AutoFollow
        and
        Theme.Accent
        or
        Theme.Element

end)

task.spawn(function()

    while Gui.Parent do

        task.wait(.2)

        if Config.AutoFollow
        and SelectedBoss
        and SelectedBoss.Parent then

            local hum =
                SelectedBoss:
                FindFirstChildOfClass(
                    "Humanoid"
                )

            local bossRoot =
                SelectedBoss:
                FindFirstChild(
                    "HumanoidRootPart"
                )

            if hum
            and hum.Health > 0
            and bossRoot then

                local _,root =
                    Character()

                root.CFrame =
                    bossRoot.CFrame
                    *
                    CFrame.new(
                        0,
                        3,
                        Config.BossDistance
                    )
            end
        end
    end
end)

--------------------------------------------------
-- ITEM SCAN
--------------------------------------------------

local ItemLabel =
    Label(
        ItemPage,
        "Selected Item : none",
        10
    )

local function ScanItems()

    Items = {}

    for _,obj in ipairs(
        workspace:GetDescendants()
    ) do

        if obj:IsA("BasePart") then

            local n =
                obj.Name:lower()

            if
                n:find("scroll")
                or
                n:find("drop")
                or
                n:find("item")
                or
                n:find("spawn")
            then

                table.insert(
                    Items,
                    obj
                )
            end
        end
    end

    if #Items > 0 then

        SelectedItem =
            Items[1]

        ItemLabel.Text =
            "Selected Item : "
            ..SelectedItem.Name

    else

        ItemLabel.Text =
            "No item found"

        SelectedItem = nil

    end
end

local RefreshItems =
    Button(
        ItemPage,
        "🔍 SCAN ITEMS",
        60
    )

RefreshItems.MouseButton1Click:
Connect(function()

    ScanItems()

end)

local NextItem =
    Button(
        ItemPage,
        "NEXT ITEM ▶",
        110
    )

local ItemIndex = 1

NextItem.MouseButton1Click:
Connect(function()

    if #Items == 0 then
        ScanItems()
    end

    if #Items == 0 then
        return
    end

    ItemIndex += 1

    if ItemIndex >
        #Items then

        ItemIndex = 1
    end

    SelectedItem =
        Items[ItemIndex]

    ItemLabel.Text =
        "Selected Item : "
        ..SelectedItem.Name

end)

local TPItem =
    Button(
        ItemPage,
        "⚡ TELEPORT ITEM",
        160
    )

TPItem.MouseButton1Click:
Connect(function()

    if not SelectedItem
    or not SelectedItem.Parent then
        return
    end

    local _,root =
        Character()

    root.CFrame =
        SelectedItem.CFrame
        +
        Vector3.new(
            0,
            3,
            0
        )

end)

--------------------------------------------------
-- FARM PAGE
--------------------------------------------------

Label(
    FarmPage,
    "Solo Farm Controller",
    10
)

Label(
    FarmPage,
    "Use BOSS → Auto Follow",
    55
)

Label(
    FarmPage,
    "Distance currently : "
    ..Config.BossDistance,
    100
)

--------------------------------------------------
-- TELEPORT SAVE
--------------------------------------------------

local SavedPosition = nil

local SavePos =
    Button(
        TPPage,
        "SAVE POSITION",
        10
    )

SavePos.MouseButton1Click:
Connect(function()

    local _,root =
        Character()

    SavedPosition =
        root.CFrame

    SavePos.Text =
        "POSITION SAVED ✓"

end)

local ReturnPos =
    Button(
        TPPage,
        "RETURN TO POSITION",
        60
    )

ReturnPos.MouseButton1Click:
Connect(function()

    if SavedPosition then

        local _,root =
            Character()

        root.CFrame =
            SavedPosition

    end
end)

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local DistanceLabel =
    Label(
        SettingsPage,
        "Boss Distance : "
        ..Config.BossDistance,
        10
    )

local DistancePlus =
    Button(
        SettingsPage,
        "DISTANCE +",
        60
    )

DistancePlus.MouseButton1Click:
Connect(function()

    Config.BossDistance += 1

    DistanceLabel.Text =
        "Boss Distance : "
        ..Config.BossDistance

end)

local DistanceMinus =
    Button(
        SettingsPage,
        "DISTANCE -",
        110
    )

DistanceMinus.MouseButton1Click:
Connect(function()

    Config.BossDistance =
        math.max(
            2,
            Config.BossDistance - 1
        )

    DistanceLabel.Text =
        "Boss Distance : "
        ..Config.BossDistance

end)

--------------------------------------------------
-- INITIAL
--------------------------------------------------

ScanBosses()
SelectPage("BOSS")

Main.Size =
    UDim2.new(0,0,0,0)

Tween(
    Main,
    {
        Size =
            UDim2.new(
                0,
                620,
                0,
                430
            )
    },
    .3
)

print(
    "SOLO SHINDO HUB LOADED"
)
