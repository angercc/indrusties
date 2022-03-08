

local Settings = {
    Aimlock = {
        AimPart = "UpperTorso",
        AimlockKey = nil,
        Prediction = 0.136,
AimPart2 = "RightFoot",
        FOVEnabled = true,
        FOVShow = false,
        FOVSize = 60,
        FOVTransparency = 0.24,
        FOVColour = Color3.fromRGB(255, 255, 0),
        FOVFilled = false,
        FOVSides = 8,

        Enabled = false
    },
    SilentAim = {
        Key = nil,
        AimAt = "LowerTorso",
        AimAt2 = "RightFoot",
        PredictionAmount = 0.139,
        FOVColour = Color3.fromRGB(200, 255, 128),
        FOVEnabled = true,
        FOVShow = false,
        FOVSize = 60,
        FOVTransparency = 0.24,
        FOVFilled = false,
        FOVSides = 8,

        Enabled = false,
        KeyToLockOn = true,
    },
    CFSpeed = {
        Speed = 2,

        Enabled = false,
        Toggled = false,

        Key = "Z"
    }
}

getgenv().Cij = true

--// Variables (Service)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local GS = game:GetService("GuiService")
local SG = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")

--// Variables (regular)

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = WS.CurrentCamera
local GetGuiInset = GS.GetGuiInset

local AimlockState = false
local aimLocked
local lockVictim

--// Anti-Cheat

repeat wait() until LP.Character:FindFirstChild("FULLY_LOADED_CHAR");

for _,ac in pairs(LP.Character:GetChildren()) do
    if (ac:IsA("Script") and ac.Name ~= "Animate" and ac.Name ~= "Health") then
        ac:Destroy();
    end;
end;

LP.Character.ChildAdded:Connect(function(child)
    if (child:IsA("Script") and child.Name ~= "Animate" and ac.Name ~= "Health") then
        child:Destroy();
    end;
end);

--// CFrame Speed

local userInput = game:GetService('UserInputService')
local runService = game:GetService('RunService')


Mouse.KeyDown:connect(function(Key)
    local cfKey = Settings.CFSpeed.Key:lower()
    if (Key == cfKey) then
        if (Settings.CFSpeed.Toggled) then
            Settings.CFSpeed.Enabled = not Settings.CFSpeed.Enabled
            if (Settings.CFSpeed.Enabled == true) then
                repeat
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * Settings.CFSpeed.Speed
                    game:GetService("RunService").Stepped:wait()
                until Settings.CFSpeed.Enabled == false
            end
        end
    end
end)

--// FOV Circle

local fov = Drawing.new("Circle")
fov.Filled = false
fov.Transparency = 1
fov.Thickness = 1


--// Functions

function updateLock()
    if Settings.Aimlock.FOVEnabled == true and Settings.Aimlock.FOVShow == true then
        if fov then
            fov.Color = Settings.Aimlock.FOVColour
            fov.Radius = Settings.Aimlock.FOVSize * 2
            fov.Visible = Settings.Aimlock.FOVShow
            fov.Position = Vector2.new(Mouse.X, Mouse.Y + GetGuiInset(GS).Y)
            fov.Transparency = Settings.Aimlock.FOVTransparency
            fov.NumSides = Settings.Aimlock.FOVSides
            fov.Filled = Settings.Aimlock.FOVFilled
            return fov
        end
    else
        Settings.Aimlock.FOVShow = false
        fov.Visible = false
    end
end

function WTVP(arg)
    return Camera:WorldToViewportPoint(arg)
end

function WTSP(arg)
    return Camera.WorldToScreenPoint(Camera, arg)
end

function getClosest()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        local notKO = v.Character:WaitForChild("BodyEffects")["K.O"].Value ~= true
        local notGrabbed = v.Character:FindFirstChild("GRABBING_COINSTRAINT") == nil

        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild(Settings.Aimlock.AimPart) and notKO and notGrabbed then
            local pos = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude

            if (Settings.Aimlock.FOVEnabled) then
                if (fov.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

function sendNotification(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Headshot.me",
        Text = text,
        Duration = 5
    })
end

--// Checks if key is down


local UserInputService = game:GetService("UserInputService")

    UserInputService.InputBegan:Connect(function(keygo,ok)
           if (not ok) then
           if (keygo.KeyCode == Settings.Aimlock.AimlockKey) then
        if Settings.Aimlock.Enabled == true then
            aimLocked = not aimLocked
            if aimLocked then
                lockVictim = getClosest()
if Notffa then
                sendNotification(tostring(lockVictim.Character.Humanoid.DisplayName))
end
            else
                if lockVictim ~= nil then
                    lockVictim = nil
                    if Notffa then

                    sendNotification("No Target!")
                    end
                end
            end
        end
    end
end
end)





RS.RenderStepped:Connect(function()

    if lockVictim.Character.Humanoid.Jump == true and lockVictim.Character.Humanoid.FloorMaterial == Enum.Material.Air then
        Settings.Aimlock.AimPart = Settings.Aimlock.AimPart2
    else
        lockVictim.Character:WaitForChild("Humanoid").StateChanged:Connect(function(old,new)
            if new == Enum.HumanoidStateType.Freefall then
                Settings.Aimlock.AimPart = Settings.Aimlock.AimPart2
            else
                Settings.Aimlock.AimPart = getgenv().oldaimpart
            end
        end)
    end
end
)

--// Loop update FOV and loop camera lock onto target

local localPlayer = game:GetService("Players").LocalPlayer
local currentCamera = game:GetService("Workspace").CurrentCamera
local guiService = game:GetService("GuiService")
local runService = game:GetService("RunService")

local getGuiInset = guiService.GetGuiInset
local mouse = localPlayer:GetMouse()

local silentAimed = false
local silentVictim
local victimMan

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Transparency = 0.24
FOVCircle.Thickness = 2

function updateFOV()
    if (FOVCircle) then
        if (Settings.SilentAim.FOVEnabled) then
            FOVCircle.Radius = Settings.SilentAim.FOVSize * 2
            FOVCircle.Visible = Settings.SilentAim.FOVShow
            FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + getGuiInset(guiService).Y)
            FOVCircle.Color = Settings.SilentAim.FOVColour
FOVCircle.Transparency = Settings.SilentAim.FOVTransparency
FOVCircle.NumSides = Settings.SilentAim.FOVSides
FOVCircle.Filled = Settings.SilentAim.FOVFilled
            return FOVCircle
        elseif (not Settings.SilentAim.FOVEnabled) then
            FOVCircle.Visible = false
        end
    end
end

function getClosestPlayerToCursor()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild(Settings.SilentAim.AimAt) then
            local pos = currentCamera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude

            if (Settings.SilentAim.FOVEnabled == true) then
                if (FOVCircle.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end






local UserInputService = game:GetService("UserInputService")

    UserInputService.InputBegan:Connect(function(keygo,ok)
           if (not ok) then
           if (keygo.KeyCode == Settings.SilentAim.Key) then
        if (Settings.SilentAim.KeyToLockOn == false) then
            return
        end
        if (Settings.SilentAim.Enabled) then
            silentAimed = not silentAimed

            if silentAimed then
                silentVictim = getClosestPlayerToCursor()
                if sexbruh then
                sendNotification(tostring(silentVictim.Character.Humanoid.DisplayName))
                end
            elseif not silentAimed and silentVictim ~= nil then

                silentVictim = nil
if sexbruh then
                sendNotification('No Target!')
end
            end
        end
    end
end
end)

runService.RenderStepped:Connect(function()
    updateFOV()
    updateLock()
    victimMan = getClosestPlayerToCursor()
    if Settings.Aimlock.Enabled == true then
        if lockVictim ~= nil then
            Camera.CFrame = CFrame.new(Camera.CFrame.p, lockVictim.Character[Settings.Aimlock.AimPart].Position + lockVictim.Character[Settings.Aimlock.AimPart].Velocity*Settings.Aimlock.Prediction)
        end
    end
end)



RS.RenderStepped:Connect(function()
if silentVictim.Character.Humanoid.Jump == true and silentVictim.Character.Humanoid.FloorMaterial == Enum.Material.Air then
    Settings.SilentAim.AimAt = Settings.SilentAim.AimAt2
else
    silentVictim.Character:WaitForChild("Humanoid").StateChanged:Connect(function(old,new)
        if new == Enum.HumanoidStateType.Freefall then
            Settings.SilentAim.AimAt = Settings.SilentAim.AimAt2
        else
            Settings.SilentAim.AimAt = getgenv().oldaimpart
        end
    end)
end
end)


-- // Metatable vars



local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}

    if Settings.SilentAim.Enabled and Settings.SilentAim.KeyToLockOn and silentAimed and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" and getgenv().flf == true then
        args[3] = silentVictim.Character[Settings.SilentAim.AimAt].Position+(silentVictim.Character[Settings.SilentAim.AimAt].Velocity*Settings.SilentAim.PredictionAmount)
        return old(unpack(args))
    end

    return old(...)
end)


--Miscs

gv = false
game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameprocess)
	    if (inputObject.KeyCode == getgenv().keyylol) and (not gameprocess) and gv == false and bitches == true then
	        gv = true
	        			game.Players.LocalPlayer.Character.Humanoid.Name = "Humz"
			game.Players.LocalPlayer.Character.Humz.WalkSpeed = getgenv().speed
			game.Players.LocalPlayer.Character.Humz.JumpPower = 50
	    else
	        	    if (inputObject.KeyCode == getgenv().keyylol) and (not gameprocess) and gv == true and bitches == true then
gv = false
			game.Players.LocalPlayer.Character.Humz.WalkSpeed = 16
			game.Players.LocalPlayer.Character.Humz.JumpPower = 50
			game.Players.LocalPlayer.Character.Humz.Name = "Humanoid"
			end end
	end)

    if bitches == false then
        game.Players.LocalPlayer.Character.Humz.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humz.JumpPower = 50
        game.Players.LocalPlayer.Character.Humz.Name = "Humanoid"
        getgenv().speed = 16
    end


    local rS = game:service('RunService')

    game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameprocess)

        if (inputObject.KeyCode == getgenv().antilockkk) and (not gameprocess) and antilock == true then
            Enabled = not Enabled
            if Enabled == true then
                repeat
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * getgenv().Ml
                    rS.Stepped:wait()
                until Enabled == false
            end
        end
    end)





    game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameprocess)

        if (inputObject.KeyCode == getgenv().lower) and (not gameprocess) and niggu == true then
                    Clicking = not Clicking
                    if Clicking == true then
                        repeat
                            mouse1click()
                            wait(0.001)
                        until Clicking == false
                    end
                end
            end)




            game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameprocess)

                local Player = game:GetService("Players").LocalPlayer
            local Wallet = Player.Backpack:FindFirstChild("Wallet")

            local UniversalAnimation = Instance.new("Animation")

            function stopTracks()
                for _, v in next, game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks() do
                    if (v.Animation.AnimationId:match("rbxassetid")) then
                        v:Stop()
                    end
                end
            end

            function loadAnimation(id)
                if UniversalAnimation.AnimationId == id then
                    stopTracks()
                    UniversalAnimation.AnimationId = "1"
                else
                    UniversalAnimation.AnimationId = id
                    local animationTrack = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(UniversalAnimation)
                    animationTrack:Play()
                end
            end

            if (inputObject.KeyCode == getgenv().fake) and (not gameprocess) and macroolol == true then
                Fake = not Fake
                if Fake == true then
                        stopTracks()
                        loadAnimation("rbxassetid://3189777795")
                        wait(1.5)
                        Wallet.Parent = Player.Character
                        wait(0.15)
                        Player.Character:FindFirstChild("Wallet").Parent = Player.Backpack
                        wait(0.05)
                        repeat game:GetService("RunService").Heartbeat:wait()
                            keypress(0x49)
                            game:GetService("RunService").Heartbeat:wait()
                            keypress(0x4F)
                            game:GetService("RunService").Heartbeat:wait()
                            keyrelease(0x49)
                            game:GetService("RunService").Heartbeat:wait()
                            keyrelease(0x4F)
                            game:GetService("RunService").Heartbeat:wait()
                        until Fake == false
                    end
                end
            end)

            autostomp = false
            game:GetService("RunService").Stepped:connect(function()
                if autostomp then
                    game.ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end)



            hff = false
            if silentaimnoti == true and hff == false then
                    Aiming.Enabled = true
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Headshot.me",
                            Text = "Enabled",
                            Duration = 5
                        })
                        hff = true
                    else
                        if silentaimnoti == true and hff == true then
                            Aiming.Enabled = false
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Headshot.me",
                                Text = "False",
                                Duration = 5
                            })
                            hff = false
                        end

                            end

--Settings--
local ESP = {
    Enabled = false,
    Boxes = false,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
    Color = Color3.fromRGB(255, 170, 0),
    FaceCamera = false,
    Names = false,
    TeamColor = true,
    Thickness = 0.7,
    AttachShift = 1,
    TeamMates = true,
    Players = true,

    Objects = setmetatable({}, {__mode="kv"}),
    Overrides = {}
}

--Declarations--
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

--Functions--
local function Draw(obj, props)
	local new = Drawing.new(obj)

	props = props or {}
	for i,v in pairs(props) do
		new[i] = v
	end
	return new
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end

	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end

    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
	return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end

	return plrs:GetPlayerFromCharacter(char)
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                if v.Temporary then
                    v:Remove()
                else
                    for i,v in pairs(v.Components) do
                        v.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    --TODO: add a better way of passing options
                    if options.OnAdded then
                        coroutine.wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Components) do
        v.Visible = false
        v:Remove()
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        --warn("not supposed to print", self.Object)
        return self:Remove()
    end

    local color
    if ESP.Highlighted == self.Object then
       color = ESP.HighlightColor
    else
        color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
    end

    local allow = true
    if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
        allow = false
    end
    if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
        allow = false
    end
    if self.Player and not ESP.Players then
        allow = false
    end
    if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
        allow = false
    end

    if not allow then
        for i,v in pairs(self.Components) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
    end

    --calculations--
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = CFrame.new(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }

    if ESP.Boxes then
        local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
        local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
        local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
        local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

        if self.Components.Quad then
            if Vis1 or Vis2 or Vis3 or Vis4 then
                self.Components.Quad.Visible = true
                self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                self.Components.Quad.Color = color
            else
                self.Components.Quad.Visible = false
            end
        end
    else
        self.Components.Quad.Visible = false
    end

    if ESP.Names then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)

        if Vis5 then
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
            self.Components.Name.Text = self.Name
            self.Components.Name.Color = color

            self.Components.Distance.Visible = true
            self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
            self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
            self.Components.Distance.Color = color
        else
            self.Components.Name.Visible = false
            self.Components.Distance.Visible = false
        end
    else
        self.Components.Name.Visible = false
        self.Components.Distance.Visible = false
    end

    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end
end

function ESP:Add(obj, options)
    if not obj.Parent and not options.RenderInNil then
        return warn(obj, "has no parent")
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color --[[or self:GetColor(obj)]],
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end

    box.Components["Quad"] = Draw("Quad", {
        Thickness = self.Thickness,
        Color = color,
        Transparency = 1,
        Filled = false,
        Visible = self.Enabled and self.Boxes
    })
    box.Components["Name"] = Draw("Text", {
		Text = box.Name,
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 12,
        Visible = self.Enabled and self.Names
	})


	box.Components["Tracer"] = Draw("Line", {
		Thickness = ESP.Thickness,
		Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box

    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)


local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/angercc/silent/main/script2.lua"))()
Aiming.TeamCheck(false)

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Vars
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local DaHoodSettings = {
    Prediction = 0.165,

    SilentAim = true,
    AimLock = false,
    AimLockKeybind = Enum.KeyCode.E,
    BeizerLock = {
        Enabled = true,
        Smoothness = 0.05,
        CurvePoints = {
            Vector2.new(0.83, 0),
            Vector2.new(0.17, 1)
        }
    }
}
getgenv().DaHoodSettings = DaHoodSettings

-- // Overwrite to account downed
function Aiming.Check()
    -- // Check A
    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end

    -- // Check if downed
    local Character = Aiming.Character(Aiming.Selected)
    local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value
    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    -- // Check B
    if (KOd or Grabbed) then
        return false
    end

    -- //
    return true
end




loadstring(game:HttpGet("https://pastebin.com/raw/Hw5WYUUD"))()

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops
local PepsisWorld = library:CreateWindow({
Name = "Headshot.me",

Themeable = {
    Credit = false,
Info = {"Created by anger#2089", "Discord is in your clipboard"}
}
})




local GeneralTab = PepsisWorld:CreateTab({
Name = "Aiming"
})
local Miscs = PepsisWorld:CreateTab({
    Name = "Miscellaneous"
    })
local FarmingSection = GeneralTab:CreateSection({
Name = "Aimlock"
})
FarmingSection:AddToggle({
Name = "Enable",
Flag = "EnableAimlock",
Callback = function(fov)
    Settings.Aimlock.Enabled = fov
end
})
FarmingSection:AddKeybind({
    Name = "Keybind",
    Flag = "KeybindAimlock",
    Callback = function(key)
        Settings.Aimlock.AimlockKey = key
    end
    })
    FarmingSection:AddToggle({
        Name = "Notifications",
        Flag = "NotificationAimlock",
        Callback = function(k)
            Notffa  = k
        end
        })
        FarmingSection:AddToggle({
            Name = "FOV Circle",
            Flag = "FOVCircleAimlock",
            Callback = function(f)
                Settings.Aimlock.FOVShow = f
            end
            })
            FarmingSection:AddToggle({
                Name = "FOV Filled",
                Flag = "FOVFilledAimlock",
                Callback = function(f)
                    Settings.Aimlock.FOVFilled= f
                end
                })
              

            FarmingSection:AddSlider({
                Name = "Prediction",
                Flag = "AimlockPrediction",
                Value = 0.136,
                Min = 0,
                Max = 0.25,
                Precise = 3,
                Textbox = true,
                Callback = function(Value)
                Settings.Aimlock.Prediction = Value
                end
                })

                        FarmingSection:AddSlider({
                            Name = "FOV Size",
                            Flag = "FOVSizeAimlock",
                            Value = 60,
                            Min = 0,
                            Max = 350,

                            Textbox = true,
                            Callback = function(Value)
                                Settings.Aimlock.FOVSize = Value
                            end
                            })
                            FarmingSection:AddSlider({
                                Name = "FOV Sides",
                                Flag = "FOVSidesAimlock",
                                Value = 8,
                                Min = 0,
                                Max = 100,
                                Textbox = true,
                                Callback = function(Value)
                                    Settings.Aimlock.FOVSides = Value
                                end
                                })
                                FarmingSection:AddSlider({
                                    Name = "FOV Transparency",
                                    Flag = "FOVTranspAimlock",
                                    Value = 0.4,
                                    Min = 0,
                                    Max = 1,
                                    Precise = 2,
                                    Textbox = true,
                                    Callback = function(Value)
                                        Settings.Aimlock.FOVTransparency = Value
                                    end
                                    })


                                    FarmingSection:AddColorpicker({
                                        Name = "FOV Colour",
                                        Flag = "FOVColourAimlock",
                                        Value = Color3.new(255, 255, 0),
                                        Callback=function(value)
                                            Settings.Aimlock.FOVColour = value
                                            end
                                     })
                                    FarmingSection:AddDropdown({
                                        Name = "Body Parts",
                                        Flag = "BodyPartAimlock",
                                        Value = "UpperTorso",
                                        List = {'Head','HumanoidRootPart',"UpperTorso","RightArm", "LeftArm", "LowerTorso","RightFoot","LeftFoot"},                                        Callback=function(value)
                                            Settings.Aimlock.AimPart = value
getgenv().oldpart65 = value
                                        end
                                     })
                                     FarmingSection:AddDropdown({
                                        Name = "Airshot Part",
                                        Flag = "AirshotPartAimlock",
                                        Value = "RightFoot",
                                        List = {'Head','HumanoidRootPart',"UpperTorso","RightArm", "LeftArm", "LowerTorso","RightFoot","LeftFoot"},
                                        Callback=function(value)
                                            Settings.Aimlock.AimPart2 = value
                                        end
                                     })




                local BoardControlSection = GeneralTab:CreateSection({
                    Name = "Silent FOV",
                    })

                    BoardControlSection:AddToggle({
                        Name = "Enable",
                        Flag = "EnableSilentAim",
                        Keybind = {
                        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
                        },
                        Callback = function(f)
                            if f then
                                Aiming.Enabled = true
                                if getgenv().noti then
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Headshot.me",
                                    Text = "Enabled",
                                    Duration = 5
                                })
                            end
                        else
                            Aiming.Enabled = false
                            if getgenv().noti then
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "Headshot.me",
                                Text = "Disabled",
                                Duration = 5
                            })
                        end
                        end
                        end
                        })
                        BoardControlSection:AddToggle({
                            Name = "Notifications",
                            Flag = "SilentAimNotif",
                            Callback = function(f)
                                getgenv().noti = f
                            end
                            })
                            BoardControlSection:AddToggle({
                            Name = "FOV Circle",
                             Flag = "FOVCircleSilentAim",
                                Callback = function(f)
                                    Aiming.ShowFOV = f
                                end
                                })
                                BoardControlSection:AddToggle({
                                    Name = "FOV Filled",
                                    Flag = "FOVFilledSilentAim",
                                    Callback = function(f)
                                        Aiming.Filled = f
                                    end
                                    })

                                    BoardControlSection:AddSlider({
                                        Name = "Prediction",
                                        Flag = "SilentAimPrediction",
                                        Value =  0.157,
                                        Min = 0,
                                        Max = 1,
                                        Precise = 4,
                                        Textbox = true,
                                        Callback = function(Value)
                                        DaHoodSettings.Prediction = Value
                                        end
                                        })
                                    BoardControlSection:AddSlider({
                                        Name = "FOV Size",
                                        Flag = "FOVSizeSilentAim",
                                        Value = 60,
                                        Min = 0,
                                        Max = 350,

                                        Textbox = true,
                                        Callback = function(Value)
                                            Aiming.FOV = Value
                                        end
                                        })
                                        BoardControlSection:AddSlider({
                                            Name = "FOV Sides",
                                            Flag = "FOVSidesSilentAim",
                                            Value = 8,
                                            Min = 0,
                                            Max = 100,
                                            Textbox = true,
                                            Callback = function(Value)
                                                Aiming.FOVSides = Value
                                            end
                                            })
                                            BoardControlSection:AddSlider({
                                                Name = "FOV Transparency",
                                                Flag = "FOVTransSilentAim",
                                                Value = 0.4,
                                                Min = 0,
                                                Max = 1,
                                                Precise = 2,
                                                Textbox = true,
                                                Callback = function(Value)
                                                    Aiming.Transparency = Value
                                                end
                                                })
                                                BoardControlSection:AddColorpicker({
                                                    Name = "FOV Colour",
                                                    Flag = "FOVColourSilentAim",
                                                    Value = Color3.new(255, 0, 0),
                                                    Callback=function(value)
                                                        Aiming.FOVColour = value
                                                        end
                                                 })
                                                 BoardControlSection:AddDropdown({
                                                    Name = "Body Parts",
                                                    Flag = "BodyPartSilentFOV",
                                                    Value = "Head",
                                                    List = {'Head','HumanoidRootPart',"UpperTorso","RightArm", "LeftArm", "LowerTorso","RightFoot","LeftFoot"},
                                                    Callback=function(value)
                                                        Aiming.TargetPart = value
                                                    end
                                                 })
                                              
                                                local SilentAimbot = GeneralTab:CreateSection({
                                                    Name = "Silent Aimbot",
                                                    Side = "Right"

                                                    })
                                                    SilentAimbot:AddToggle({
                                                        Name = "Enable",
Flag = "EnableSilentAimbot",
                                                        Callback = function(k)
                                                           Settings.SilentAim.Enabled = k
                                                           getgenv().flf = k
                                                        end
                                                        })
                                                        SilentAimbot:AddKeybind({
                                                            Name = "Keybind",
                                                            Flag = "SilentAimbotKeybind",
                                                            Callback = function(key)
                                                                Settings.SilentAim.Key = key
                                                            end
                                                            })
                                                            SilentAimbot:AddToggle({
                                                                Name = "Notifications",
                                                                Flag = "SiletAimbotNotif",
                                                                Callback = function(f)
                                                                    sexbruh = f
                                                                end
                                                                })
                                                                SilentAimbot:AddToggle({
                                                                    Name = "FOV Circle",
                                                                    Flag = "FOVCircleSilentAimbot",
                                                                    Callback = function(f)
                                                                        Settings.SilentAim.FOVShow = f
                                                                    end
                                                                    })
                                                                    SilentAimbot:AddToggle({
                                                                        Name = "FOV Filled",
                                                                        Flag = "FOVFilledSilentAimbot",
                                                                        Callback = function(f)
                                                                            Settings.SilentAim.FOVFilled = f
                                                                        end
                                                                        })

                                                                       
                                                                        SilentAimbot:AddSlider({
                                                                            Name = "Prediction",
                                                                            Flag = "SilentAimbotPrediction",
                                                                            Value = 0.139,
                                                                            Min = 0,
                                                                            Max = 0.25,
                                                                            Precise = 3,
                                                                            Textbox = true,
                                                                            Callback = function(Value)
                                                                            Settings.SilentAim.PredictionAmount = Value
                                                                            end
                                                                            })
                                                                        SilentAimbot:AddSlider({
                                                                            Name = "FOV Size",
                                                                            Flag = "FOVSizeSilentAimbot",
                                                                            Value = 60,
                                                                            Min = 0,
                                                                            Max = 350,

                                                                            Textbox = true,
                                                                            Callback = function(Value)
                                                                                Settings.SilentAim.FOVSize = Value
                                                                            end
                                                                            })
                                                                            SilentAimbot:AddSlider({
                                                                                Name = "FOV Sides",
                                                                                Flag = "FOVSidesSilentAimbot",
                                                                                Value = 8,
                                                                                Min = 0,
                                                                                Max = 100,
                                                                                Textbox = true,
                                                                                Callback = function(Value)
                                                                                    Settings.SilentAim.FOVSides = Value
                                                                                end
                                                                                })
                                                                                SilentAimbot:AddSlider({
                                                                                    Name = "FOV Transparency",
                                                                                    Flag = "FOVTransparSilentAimbot",
                                                                                    Value = 0.24,
                                                                                    Min = 0,
                                                                                    Max = 1,
                                                                                    Precise = 2,
                                                                                    Textbox = true,
                                                                                    Callback = function(Value)
                                                                                        Settings.SilentAim.FOVTransparency = Value
                                                                                    end
                                                                                    })

                                                                                    SilentAimbot:AddColorpicker({
                                                                                        Name = "FOV Colour",
                                                                                        Flag = "FOVColourSilentAimbot",
                                                                                        Value = Color3.new(200, 255, 128),
                                                                                        Callback=function(value)
                                                                                            Settings.SilentAim.FOVColour = value
                                                                                            end
                                                                                     })

                                                                                     SilentAimbot:AddDropdown({
                                                                                        Name = "Body Parts",
                                                                                        Flag = "BodyPartSilentAimbot",
                                                                                        Value = "LowerTorso",
                                                                                        List = {'Head','HumanoidRootPart',"UpperTorso","RightArm", "LeftArm", "LowerTorso","RightFoot","LeftFoot"},
                                                                                        Callback=function(value)
                                                                                            Settings.SilentAim.AimAt = value
                                                                                            getgenv().oldaimpart = value
                                                                                        end
                                                                                     })
                                                                                     SilentAimbot:AddDropdown({
                                                                                        Name = "Airshot Part",
                                                                                        Flag = "AirshotPartAimlock",
                                                                                        Value = "RightFoot",
                                                                                        List = {'Head','HumanoidRootPart',"UpperTorso","RightArm", "LeftArm", "LowerTorso","RightFoot","LeftFoot"},
                                                                                        Callback=function(value)
                                                                                            Settings.SilentAim.AimAt2 = value
                                                                                             
                                                                                        end
                                                                                     })





local Walspeedd = Miscs:CreateSection({
Name = "Walkspeed"
})
Walspeedd:AddToggle({
    Name = "Enable",
    Flag = "EnableWalkspeed",
    Callback = function(t)
        bitches = t
    end
    })
    Walspeedd:AddKeybind({
        Name = "Keybind",
        Flag = "WalkspeedKeybind",
        Callback = function(state)
            getgenv().keyylol = state
        end
        })
        Walspeedd:AddSlider({
        Name = "Speed Amount",
        Flag = "WalkspeedAmount",
        Value =  16,
        Min = 0,
        Max = 1000,
        Textbox = true,
        Callback = function(Text)
            getgenv().speed = Text
        end
        })


        local Cfram = Miscs:CreateSection({
            Name = "CFrame Speed"
            })
            Cfram:AddToggle({
                Name = "Enable",
                Flag = "EnableCFrame",
                Callback = function(browhna)
                    antilock = browhna

                  
                end
                })
                Cfram:AddKeybind({
                    Name = "Keybind",
                    Flag = "EnableCFrame",
                    Callback = function(state)
                        getgenv().antilockkk = state
                    end
                    })
                    Cfram:AddSlider({
                    Name = "Speed Amount",
                    Flag = "CFrameSpeed",
                    Value =  -0.25,
                    Min = -2,
                    Max = 12,
                    Precise = 2,
                    Textbox = true,
                    Callback = function(state)
                        getgenv().Ml = state
                    end
                    })
                    local Rasd = Miscs:CreateSection({
                        Name = "Fake Macro"
                        })
                        Rasd:AddToggle({
                            Name = "Enable",
                            Flag = "EnableMacro",
                            Callback = function(t)
                                macroolol = t
                            end
                            })
                            Rasd:AddKeybind({
                                Name = "Keybind",
                                Flag = "MacroKeybind",
                                Callback = function(state)
                                    getgenv().fake = state

                                end
                                })
                                local rhnv = Miscs:CreateSection({
                                    Name = "Auto Clicker"
                                    })
                                    rhnv:AddToggle({
                                        Name = "Enable",
                                        Flag = "EnableAutoClick",
                                        Callback = function(t)
                                            niggu = t
                                        end
                                        })
                                        rhnv:AddKeybind({
                                            Name = "Keybind",
                                            Flag = "AutoClickerKeybind",
                                            Callback = function(state)
                                                getgenv().lower = state
                                            end
                                            })

                    local Spin = Miscs:CreateSection({
                        Name = "Spin Bot"
                        })
                        Spin:AddToggle({
                            Name = "Enable",
                            Flag = "EnableSpinbot",
                            Callback = function(t)
                                function getRoot(char)
                                    local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('UpperTorso')
                                    return rootPart
                                end

                                if t == true then
                                    local Spin = Instance.new("BodyAngularVelocity")
                                    Spin.Name = "Spinning"
                                    Spin.Parent = getRoot(game.Players.LocalPlayer.Character)
                                    Spin.MaxTorque = Vector3.new(0, math.huge, 0)
                                    Spin.AngularVelocity = Vector3.new(0,getgenv().SBS,0)
                                else
                                    for i,v in pairs(getRoot(game.Players.LocalPlayer.Character):GetChildren()) do
                                        if v.Name == "Spinning" then
                                            v:Destroy()
                                        end
                                    end
                                end                        end
                            })

                                Spin:AddSlider({
                                Name = "Speed Amount",
                                Flag = "SpinBotAmount",
                                Value =  0,
                                Min = 0,
                                Max = 50,
                                Precise = 1,
                                Textbox = true,
                                Callback = function(Text)
                                    getgenv().SBS = Text
                                end
                                })

                                local Miscwap = Miscs:CreateSection({
                                    Name = "Toggles",
                                    Side = "Right"
                                    })
                                    Miscwap:AddToggle({
                                        Name = "Auto Stomp",
                                        Flag = "FarmingSection_EXPGrinder",
                                        Callback = function(t)
                                            autostomp = t
                                        end
                                        })
                                        Miscwap:AddToggle({
                                            Name = "Auto Reload",
                                            Flag = "FarmingSection_EXPGrinder",
                                            Callback = function(t)
                                                antilolxd = t
                                            end
                                            })
                                            Miscwap:AddToggle({
                                                Name = "Auto Armor",
                                                Flag = "FarmingSection_EXPGrinder",
                                                Callback = function(t)
                                                    antilolxd = t
                                                end
                                                })
                                            Miscwap:AddToggle({
                                                Name = "Auto Block",
                                                Flag = "FarmingSection_EXPGrinder",
                                                Callback = function(t)
                                                    antilolxd = t
                                                end
                                                })
                                        Miscwap:AddToggle({
                                            Name = "Anti Stomp",
                                            Flag = "FarmingSection_EXPGrinder",
                                            Callback = function(antistompbruhwhy)

                                            end
                                            })


                                                    Miscwap:AddToggle({
                                                        Name = "Anti Fling",
                                                        Flag = "FarmingSection_EXPGrinder",
                                                        Callback = function(t)
                                                            antilolxd = t
                                                        end
                                                        })
                                                        Miscwap:AddToggle({
                                                            Name = "Anti Slow",
                                                            Flag = "FarmingSection_EXPGrinder",
                                                            Callback = function(t)
                                                                antilolxd = t
                                                            end
                                                            })
                                                            Miscwap:AddToggle({
                                                                Name = "Anti Bag",
                                                                Flag = "FarmingSection_EXPGrinder",
                                                                Callback = function(t)
                                                                    antibag = t
                                                                end
                                                                })

                                                                local bruhwahy = Miscs:CreateSection({
                                                                    Name = "Visuals",
                                                                    Side = "Right"
                                                                    })
                                                                    bruhwahy:AddToggle({
                                                                        Name = "Enable",
                                                                        Keybind = {
                                                                        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
                                                                        },
                                                                        Callback = function(f)
                                                                            ESP:Toggle(f)
                                                                        end
                                                                        })


                                                                        bruhwahy:AddToggle({
                                                                            Name = "Boxes",
                                                                            Flag = "FarmingSection_EXPGrinder",
                                                                            Callback = function(fov)
                                                                                ESP.Boxes = fov
                                                                            end
                                                                            })
                                                                            bruhwahy:AddToggle({
                                                                                Name = "Names",
                                                                                Flag = "FarmingSection_EXPGrinder",
                                                                                Callback = function(fov)
                                                                                    ESP.Names = fov
                                                                                end
                                                                                })
                                                                                bruhwahy:AddToggle({
                                                                                    Name = "Tracers",
                                                                                    Flag = "FarmingSection_EXPGrinder",
                                                                                    Callback = function(fov)
                                                                                        ESP.Tracers = fov
                                                                                    end
                                                                                    })
                                                                                    bruhwahy:AddColorpicker({
                                                                                        Name = "ESP Colour",
                                                                                        Value = Color3.new(255, 170, 0),
                                                                                        Callback=function(value)
                                                                                        ESP.Color = value                                                      end
                                                                                     })

local Animations = {
    Nigga = 123
}	local Animate = game.Players.LocalPlayer.Character.Animate

                                                                                     local shop = Miscs:CreateSection({
                                                                                        Name = "Animations",
                                                                                        Side = "Right"
                                                                                        })


                                                                                        shop:AddDropdown({
                                                                                            Name = "Idle",
                                                                                            Flag = "AnimationIdle",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)
                                                                                                if value == "Astronaut" then
                                                                                                    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
                                                                                                    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"

                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=910009958"

                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
                                                                                                            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"

                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
                                                                                                                Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"

                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
                                                                                                                    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"

                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
                                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"

                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
                                                                                                                            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"

                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
                                                                                                                                Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"

                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
                                                                                                                                    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"

                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616088211"
                                                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616089559"


                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
                                                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"


                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
                                                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"


                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
                                                                                                                                        Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"


                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
                                                                                                                                            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"


                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
                                                                                                                                            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"


                                                                                                                                        else if value == "Zombie" then
                                                                                                                                            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
                                                                                                                                            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"


                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                                end
                                                                                         })


                                                                                         shop:AddDropdown({
                                                                                            Name = "Walk",
                                                                                            Flag = "AnimationWalk",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)
                                                                                                if value == "Astronaut" then
                                                                                                    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616095330"

                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"

                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"

                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"

                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"

                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"

                                                                                                                                        else if value == "Zombie" then
                                                                                                                                            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                                end
                                                                                         })

                                                                                         shop:AddDropdown({
                                                                                            Name = "Run",
                                                                                            Flag = "AnimationRun",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)


                                                                                                if value == "Astronaut" then
                                                                                                    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616091570"

                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"

                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"

                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"

                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"

                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"

                                                                                                                                        else if value == "Zombie" then

                                                                                                                                            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end



                                                                                    end
                                                                                         })



                                                                                         shop:AddDropdown({
                                                                                            Name = "Jump",
                                                                                            Flag = "AnimationJump",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)



                                                                                                if value == "Astronaut" then
                                                                                                    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616090535"

                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"

                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"

                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"

                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"

                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"

                                                                                                                                        else if value == "Zombie" then
                                                                                                                                            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            end
                                                                                         })

                                                                                         shop:AddDropdown({
                                                                                            Name = "Climb",
                                                                                            Flag = "AnimationClimb",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)

                                                                                                if value == "Astronaut" then
                                                                                                    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889"
                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616086039"

                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"

                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"

                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"

                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"

                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"

                                                                                                                                        else if value == "Zombie" then
                                                                                                                                            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                                end

                                                                                         })



                                                                                        shop:AddDropdown({
                                                                                            Name = "Fall",
                                                                                            Flag = "AnimationFall",
                                                                                            Value = "Default",
                                                                                            List = {"Astronaut",
                                                                                            "Bubbly",

                                                                                            "Cartoony",
                                                                                            "Elder",
                                                                                            "Knight",
                                                                                            "Levitation",
                                                                                            "Mage",
                                                                                            "Ninja",


                                                                                            "Pirate",


                                                                                            "Robot",

                                                                                            "Stylish",

                                                                                            "Superhero",
                                                                                            "Toy",
                                                                                            "Vampire",
                                                                                            "Werewolf",
                                                                                            "Zombie",},
                                                                                            Callback=function(value)

                                                                                                if value == "Astronaut" then
                                                                                                    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
                                                                                                else
                                                                                                    if value == "Bubbly" then
                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
                                                                                                    else
                                                                                                        if value == "Cartoony" then
                                                                                                            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
                                                                                                        else
                                                                                                            if value == "Elder" then
                                                                                                                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
                                                                                                            else
                                                                                                                if value == "Knight" then
                                                                                                                    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
                                                                                                                else
                                                                                                                    if value == "Levitation" then
                                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
                                                                                                                    else
                                                                                                                        if value == "Mage" then
                                                                                                                            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
                                                                                                                        else
                                                                                                                            if value == "Ninja" then
                                                                                                                                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
                                                                                                                            else
                                                                                                                                if value == "Pirate" then
                                                                                                                                    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
                                                                                                                                else
                                                                                                                                    if value == "Robot" then
                                                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616087089"

                                                                                                                                    else if value == "Stylish" then
                                                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"

                                                                                                                                    else if value == "Superhero" then
                                                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"

                                                                                                                                    else if value == "Toy" then
                                                                                                                                        Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"

                                                                                                                                    else
                                                                                                                                        if value == "Vampire" then
                                                                                                                                            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"

                                                                                                                                        else if value == "Werewolf" then
                                                                                                                                            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"

                                                                                                                                        else if value == "Zombie" then
                                                                                                                                            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                                        end
                                                                                                                                    end
                                                                                                                            end
                                                                                                                            end
                                                                                                                    end
                                                                                                            end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                                end

                                                                                         })
                                                                                        
                                                                           
                                                           


                                                                      
