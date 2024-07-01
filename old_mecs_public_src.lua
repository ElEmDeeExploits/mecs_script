local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua", true))()
local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

if isfolder('ElEmDeeHub/Dev') then
    loadstring(readfile('ElEmDeeHub/Dev/verify.lua'))() -- getgenv().Owner = true
end

local guiTitle = 'ElEmDee Hub | MECS'

if Owner then
    guiTitle = 'ElEmDee Hub | MECS | Developer Build'
end

local Window = Library:CreateWindow({
    Title = guiTitle,
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Player = Window:AddTab('Player'),
    Visuals = Window:AddTab('Visuals'),
    Weapon = Window:AddTab('Weapon'),
    Utility = Window:AddTab('Utility'),
    Blatant = Window:AddTab('Blatant'),
    Info = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local maxDistance = 2500
local admins = {'Admin','Moderator','Weare','Contributor'}
local playerLevel = game.Players.LocalPlayer:GetAttribute('Level')

getgenv().pfov = 70
getgenv().cframeValue = 0
getgenv().walkspeedValue = 20
getgenv().jumpPowerValue = 35
getgenv().killAuraRange = 15
getgenv().vehicleAuraRange = 15
getgenv().distance = maxDistance
getgenv().playerToKill = nil
getgenv().gunToMod = 'All Guns'
getgenv().vehicletype = 'Both'
getgenv().weapontype = nil
getgenv().gunToGrab = nil
getgenv().objTeleport = nil
getgenv().plrTeleport = nil
getgenv().annoyType = 'Normal'
getgenv().espTeamCheck = false
getgenv().unloaded = false
getgenv().modsEnabled1 = false
getgenv().modsEnabled2 = false
getgenv().modsEnabled3 = false
getgenv().modsEnabled4 = false
getgenv().modsEnabled5 = false
getgenv().plrExplode = nil
getgenv().gunESPEnabled = false
getgenv().chamsTransparency = 0.5
getgenv().chamsColor = Color3.new(1,1,1)
getgenv().chatSpamText = 'ElEmDee Hub on Top'
getgenv().adminMethod = 'Kick'
getgenv().weakenPlayer = nil

local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

pcall(function()
	getgenv().Aimbot.Functions:Exit()
end)

getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

Environment.Settings = {
	Enabled = false,
	TeamCheck = false,
	AliveCheck = false,
	WallCheck = false, -- Laggy
	Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
	ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
	ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head"
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = false,
	Amount = 90,
	Color = Color3.fromRGB(255, 255, 255),
	LockedColor = Color3.fromRGB(255, 70, 70),
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

getgenv().Sense = {}

local espSettings = Sense
espSettings.teamSettings.enemy.boxFill = false
espSettings.teamSettings.friendly.boxFill = false

local utilityBoxDev
local blatantBoxDev

local playerBoxLeft = Tabs.Player:AddLeftGroupbox('Player Options')
local playerBoxRight = Tabs.Player:AddRightGroupbox('Player Settings')
local weaponBoxLeft = Tabs.Weapon:AddLeftGroupbox('Weapon Options')
local weaponBoxRight = Tabs.Weapon:AddRightGroupbox('Weapon Settings')
local utilityBoxLeft = Tabs.Utility:AddLeftGroupbox('Utilities')
local utilityBoxRight = Tabs.Utility:AddRightGroupbox('Trolling')
local blatantBoxLeft = Tabs.Blatant:AddLeftGroupbox('Blatant Options')
local blatantBoxTeleport = Tabs.Blatant:AddLeftGroupbox('Teleport Options')
local blatantBoxRight = Tabs.Blatant:AddRightGroupbox('Blatant Settings')
local blatantBoxTPSettings = Tabs.Blatant:AddRightGroupbox('Teleport Settings')
local infoBoxLeft = Tabs.Info:AddLeftGroupbox('Socials')

if Owner then
    utilityBoxDev = Tabs.Utility:AddLeftGroupbox('Developer Utilities')
    blatantBoxDev = Tabs.Blatant:AddLeftGroupbox('Developer Options')
end

weapons = {}
killWeapons = {}
hiddenweapons = {}
plrs = {}
allPlrs = {}
objectives = {}

getgenv().foundUsers = {}

local function isTableEmpty(input)
    for i,v in pairs(input) do
        if v then
            return false
        end
    end
    return true
end

local function refreshweapontable()
    table.clear(weapons)
    task.wait()
    table.insert(weapons,'All Guns')
    for i,v in pairs(game.Players.LocalPlayer:WaitForChild('Backpack'):GetChildren()) do
        table.insert(weapons, v.Name)
    end
end

local function refreshweapontable2()
    table.clear(killWeapons)
    task.wait()
    for i,v in pairs(game.Players.LocalPlayer:WaitForChild('Backpack'):GetChildren()) do
        if require(v.ACS_Settings).Type ~= 'Grenade' then
            table.insert(killWeapons, v.Name)
        end
    end
end

function refreshhiddenweapontable()
    table.clear(hiddenweapons)
    task.wait()
    for i,v in pairs(game:GetService("Workspace").Map.GAME:GetChildren()) do
        if v.Name == 'Weapons' then
            if not isTableEmpty(v:GetChildren()) then
                for i,v in pairs(v:GetChildren()) do
                    if not table.find(hiddenweapons,v.Name) then
                        table.insert(hiddenweapons,v.Name)
                    end
                end
            else
                table.insert(hiddenweapons,'No Weapons Found')
            end
        end
    end
end

function refreshplrtable()
    table.clear(plrs)
    task.wait()
    for i,v in pairs(game.Players:GetChildren()) do
        if v ~= game.Players.LocalPlayer and v.Team ~= game.Players.LocalPlayer.Team then
            table.insert(plrs,v.DisplayName)
        end
    end
end

function refreshallplrstable()
    table.clear(allPlrs)
    task.wait()
    for i,v in pairs(game.Players:GetChildren()) do
        if v ~= game.Players.LocalPlayer then
            table.insert(allPlrs,v.DisplayName)
        end
    end
end

function refreshobjectivestable()
    table.clear(objectives)
    task.wait()
    for i,v in pairs(game:GetService("Workspace").Map.GAME:GetDescendants()) do
        if v.Name == 'CaptureArea' or v.Name == 'CapturePart' then
            table.insert(objectives,v.Parent.Name)
        end
    end
end

local function getRole(player)
    if player:IsInGroup(15469685) then
        return player:GetRoleInGroup(15469685)
    end
end

function equipGun()
    local tool = nil
    
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:FindFirstChild("ACS_Settings") then
            tool = v
            break
        end
    end
    
    game.Players.LocalPlayer.Backpack[tool.Name].Parent = game.Players.LocalPlayer.Character
end

function whizz(plr)
    game:GetService("ReplicatedStorage").ACS_Engine.Events.Whizz:FireServer(plr)
end

function getIndex(table, value)
    for i,v in pairs(table) do
        if v == value then
            return i
        end
    end
end

local function canTarget(plr)
    if plr.Character ~= nil and plr.Team ~= game.Players.LocalPlayer.Team then
        if plr.Character.Humanoid.Health > 0 then
            return true
        end
    end

    return false
end

local function getPlayerByName(name)
    for i,v in pairs(game.Players:GetChildren()) do
        if v.Name == name then
            return v
        end
    end
    return nil
end

local function getWeaponByName(gun)
    local foundGun

    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v.Name == gun then
            foundGun = v
        end
    end

    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == gun then
            foundGun = v
        end
    end

    return foundGun
end

local function isOneShot(gun)
    local gang = require(gun.ACS_Settings)

    if gang.HeadDamage[1] < 100 then
        return false
    end
    return true
end

local function getHeadDamage(gun)
    return require(gun.ACS_Settings).HeadDamage[1]
end

local function getGreatestDamageWeapon()
    local bestGun
    local greatestDMG = 0
    local modScript
    local mod

    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetDescendants()) do
        if v.Name == 'ACS_Settings' then
            modScript = v
            mod = require(v)
            
            if mod.HeadDamage[1] > greatestDMG then
                greatestDMG = mod.HeadDamage[1]
                bestGun = modScript.Parent
            end
        end
    end

    for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v.Name == 'ACS_Settings' then
            modScript = v
            mod = require(v)

            if mod.HeadDamage[1] > greatestDMG then
                greatestDMG = mod.HeadDamage[1]
                bestGun = modScript.Parent
            end
        end
    end

    return bestGun
end

local function getLeastDamageWeapon()
    local leastDMG = math.huge
    local bestGun
    local modScript
    local mod
    
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetDescendants()) do
        if v.Name == 'ACS_Settings' then
            modScript = v
            mod = require(v)
            
            if mod.HeadDamage[1] < leastDMG and mod.Type == 'Gun' then
                leastDMG = mod.HeadDamage[1]
                bestGun = modScript.Parent
            end
        end
    end

    for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v.Name == 'ACS_Settings' then
            modScript = v
            mod = require(v)
            
            if mod.HeadDamage[1] < leastDMG and mod.Type == 'Gun' then
                leastDMG = mod.HeadDamage[1]
                bestGun = modScript.Parent
            end
        end
    end
    
    return bestGun
end

local function getLeastDamage()
    local leastDMG = math.huge
    local bestGun
    
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetDescendants()) do
        if v.Name == 'ACS_Settings' then
            local modScript = v
            local mod = require(v)
            
            if mod.LimbDamage[1] < leastDMG and mod.Type == 'Gun' then
                leastDMG = mod.LimbDamage[1]
                bestGun = modScript.Parent
            end
        end
    end
    
    return leastDMG
end

local function setAmmo(gun, ammoCount)
    if require(gun.ACS_Settings).Ammo ~= ammoCount then
        local oldReload
        local oldReload2

        if gun.Parent == game.Players.LocalPlayer.Character then
            gun.Parent = game.Players.LocalPlayer.Backpack
        end

        local animations = require(gun.ACS_Animations)
        local gunSettings = require(gun.ACS_Settings)

        oldReload = animations.ReloadAnim
        oldReload2 = animations.TacticalReloadAnim

        gunSettings.Ammo = ammoCount
        gunSettings.StoredAmmo = ammoCount

        animations.ReloadAnim = function() return end
        animations.TacticalReloadAnim = function() return end

        gun.Parent = game.Players.LocalPlayer.Character

        getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Reload()

        animations.ReloadAnim = oldReload
        animations.TacticalReloadAnim = oldReload2
    end
end

local function setSemi()
    if game:GetService("Players").LocalPlayer.PlayerGui.StatusUI.GunHUD.FText.Text == 'Auto' then
        getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Firemode()
    end
end

local function killPlayer(plr)
    local tool = getGreatestDamageWeapon()
    
    if weapontype ~= nil then
        tool = getWeaponByName(weapontype)
    end

    if tool.Parent ~= game.Players.LocalPlayer.Character then
        tool.Parent = game.Players.LocalPlayer.Character
    end
    
    task.wait()
    setSemi()

    if plr.Character:FindFirstChild('HumanoidRootPart') then
        local distance = (plr.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].Position).Magnitude

        local args = {
            [1] = tool,
            [2] = plr.Character.Humanoid,
            [3] = distance,
            [4] = 1,
            [6] = plr.Character.Head,
            [7] = true,
            [8] = UDim2.new({1, 5}, {1, 5}),
        }

        if not isOneShot(tool) and plr.Character.Humanoid.Health > getHeadDamage(tool) then
            for i = 1, 2 do
                game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("WeaponDamage"):FireServer(unpack(args))
            end
        else
            game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("WeaponDamage"):FireServer(unpack(args))
        end
    end
end

local function damagePlayer(plr)
    local tool = getLeastDamageWeapon()

    if tool.Parent ~= game.Players.LocalPlayer.Character then
        tool.Parent = game.Players.LocalPlayer.Character
    end

    task.wait()
    setSemi()

    local distance = (plr.Character["HumanoidRootPart"].Position - game:GetService("Players").LocalPlayer.Character["HumanoidRootPart"].Position).Magnitude
    
    local args = {
        [1] = tool,
        [2] = plr.Character.Humanoid,
        [3] = distance,
        [4] = 3,
        [6] = plr.Character.Head,
        [7] = true,
        [8] = UDim2.new({1, 5}, {1, 5})
    }

    game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("WeaponDamage"):FireServer(unpack(args))
end

local function explode(plr)
    local args = {
        [1] = game.Players.LocalPlayer.Backpack.Impact,
        [2] = {
            ["Ammo"] = 0,
            ["ShootRate"] = 0,
            ["IgnoreProtection"] = false,
            ["EnableZeroing"] = false,
            ["WalkSpeed"] = 1,
            ["MinRecoilPower"] = 1,
            ["Zoom"] = 70,
            ["MaxRecoilPower"] = 1,
            ["SightAtt"] = "",
            ["BulletPenetration"] = 0,
            ["CanCheckMag"] = false,
            ["WeaponType"] = "Grenade",
            ["MuzzleVelocity"] = 0,
            ["CanBreachDoor"] = false,
            ["AmmoInGun"] = 0,
            ["camRecoil"] = {
                ["camRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["gunName"] = "Impact",
            ["HeadDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["Zoom2"] = 70,
            ["MagCount"] = false,
            ["InfraRed"] = false,
            ["DropOffEnd"] = 1000,
            ["CurrentZero"] = 0,
            ["RainbowMode"] = false,
            ["CrosshairOffset"] = 0,
            ["AimSpreadReduction"] = 1,
            ["ShootType"] = 0,
            ["Bullets"] = 0,
            ["EnableHUD"] = false,
            ["SlideEx"] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            ["Tracer"] = false,
            ["LimbDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["MaxStoredAmmo"] = 0,
            ["UnderBarrelAtt"] = "",
            ["Jammed"] = false,
            ["TracerEveryXShots"] = 0,
            ["ZoomType"] = 1,
            ["CanBreak"] = false,
            ["TorsoDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["ShellInsert"] = false,
            ["gunRecoil"] = {
                ["gunRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["BurstShot"] = 0,
            ["Type"] = "Grenade",
            ["RecoilPowerStepAmount"] = 1,
            ["FireModes"] = {
                ["Auto"] = false,
                ["ChangeFiremode"] = false,
                ["Burst"] = false,
                ["Semi"] = false
            },
            ["BulletDrop"] = 0,
            ["CenterDot"] = true,
            ["MaxSpread"] = 0,
            ["CrossHair"] = false,
            ["SlideLock"] = false,
            ["BarrelAtt"] = "",
            ["OtherAtt"] = "",
            ["AimRecoilReduction"] = 1,
            ["BulletType"] = "",
            ["canAim"] = false,
            ["AimInaccuracyDecrease"] = 0,
            ["IncludeChamberedBullet"] = false,
            ["MaxZero"] = 0,
            ["AimInaccuracyStepAmount"] = 0,
            ["adsTime"] = 1,
            ["BulletFlare"] = false,
            ["StoredAmmo"] = 0,
            ["WalkMult"] = 0,
            ["MinSpread"] = 0,
            ["ZeroIncrement"] = 0,
            ["DropOffStart"] = 1000,
            ["TracerColor"] = Color3.new(1, 1, 1),
            ["RandomTracer"] = {
                ["Enabled"] = false,
                ["Chance"] = 25
            }
        },
        [3] = plr.Character.HumanoidRootPart.CFrame,
        [4] = Vector3.new(0,-0.3,0),
        [5] = 150
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("Grenade"):FireServer(unpack(args))
end

local function burn(plr)
    local args = {
        [1] = game.Players.LocalPlayer.Backpack.Molotov,
        [2] = {
            ["Ammo"] = 0,
            ["ShootRate"] = 0,
            ["IgnoreProtection"] = false,
            ["EnableZeroing"] = false,
            ["WalkSpeed"] = 1,
            ["MinRecoilPower"] = 1,
            ["Zoom"] = 70,
            ["MaxRecoilPower"] = 1,
            ["SightAtt"] = "",
            ["BulletPenetration"] = 0,
            ["CanCheckMag"] = false,
            ["WeaponType"] = "Grenade",
            ["MuzzleVelocity"] = 0,
            ["CanBreachDoor"] = false,
            ["AmmoInGun"] = 0,
            ["camRecoil"] = {
                ["camRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["gunName"] = "Molotov",
            ["HeadDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["Zoom2"] = 70,
            ["MagCount"] = false,
            ["InfraRed"] = false,
            ["DropOffEnd"] = 1000,
            ["CurrentZero"] = 0,
            ["RainbowMode"] = false,
            ["CrosshairOffset"] = 0,
            ["AimSpreadReduction"] = 1,
            ["ShootType"] = 0,
            ["Bullets"] = 0,
            ["EnableHUD"] = false,
            ["SlideEx"] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            ["Tracer"] = false,
            ["LimbDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["MaxStoredAmmo"] = 0,
            ["UnderBarrelAtt"] = "",
            ["Jammed"] = false,
            ["TracerEveryXShots"] = 0,
            ["ZoomType"] = 1,
            ["CanBreak"] = false,
            ["TorsoDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["ShellInsert"] = false,
            ["gunRecoil"] = {
                ["gunRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["BurstShot"] = 0,
            ["Type"] = "Grenade",
            ["RecoilPowerStepAmount"] = 1,
            ["FireModes"] = {
                ["Auto"] = false,
                ["ChangeFiremode"] = false,
                ["Burst"] = false,
                ["Semi"] = false
            },
            ["BulletDrop"] = 0,
            ["CenterDot"] = true,
            ["MaxSpread"] = 0,
            ["CrossHair"] = false,
            ["SlideLock"] = false,
            ["BarrelAtt"] = "",
            ["OtherAtt"] = "",
            ["AimRecoilReduction"] = 1,
            ["BulletType"] = "",
            ["canAim"] = false,
            ["AimInaccuracyDecrease"] = 0,
            ["IncludeChamberedBullet"] = false,
            ["MaxZero"] = 0,
            ["AimInaccuracyStepAmount"] = 0,
            ["adsTime"] = 1,
            ["BulletFlare"] = false,
            ["StoredAmmo"] = 0,
            ["WalkMult"] = 0,
            ["MinSpread"] = 0,
            ["ZeroIncrement"] = 0,
            ["DropOffStart"] = 1000,
            ["TracerColor"] = Color3.new(1, 1, 1),
            ["RandomTracer"] = {
                ["Enabled"] = false,
                ["Chance"] = 25
            }
        },
        [3] = plr.Character.HumanoidRootPart.CFrame,
        [4] = Vector3.new(0,0,0),
        [5] = 150
    }

    game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("Grenade"):FireServer(unpack(args))
end

local function grenadeExplode(plr)
    local args = {
        [1] = game.Players.LocalPlayer.Backpack.Grenade,
        [2] = {
            ["Ammo"] = 0,
            ["ShootRate"] = 0,
            ["IgnoreProtection"] = false,
            ["EnableZeroing"] = false,
            ["WalkSpeed"] = 1,
            ["MinRecoilPower"] = 1,
            ["Zoom"] = 70,
            ["MaxRecoilPower"] = 1,
            ["SightAtt"] = "",
            ["BulletPenetration"] = 0,
            ["CanCheckMag"] = false,
            ["WeaponType"] = "Grenade",
            ["MuzzleVelocity"] = 0,
            ["CanBreachDoor"] = false,
            ["AmmoInGun"] = 0,
            ["camRecoil"] = {
                ["camRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["camRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["gunName"] = "Grenade",
            ["HeadDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["Zoom2"] = 70,
            ["MagCount"] = false,
            ["InfraRed"] = false,
            ["DropOffEnd"] = 1000,
            ["CurrentZero"] = 0,
            ["RainbowMode"] = false,
            ["CrosshairOffset"] = 0,
            ["AimSpreadReduction"] = 1,
            ["ShootType"] = 0,
            ["Bullets"] = 0,
            ["EnableHUD"] = false,
            ["SlideEx"] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            ["Tracer"] = false,
            ["LimbDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["MaxStoredAmmo"] = 0,
            ["UnderBarrelAtt"] = "",
            ["Jammed"] = false,
            ["TracerEveryXShots"] = 0,
            ["ZoomType"] = 1,
            ["CanBreak"] = false,
            ["TorsoDamage"] = {
                [1] = 0,
                [2] = 0
            },
            ["ShellInsert"] = false,
            ["gunRecoil"] = {
                ["gunRecoilTilt"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilUp"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilLeft"] = {
                    [1] = 0,
                    [2] = 0
                },
                ["gunRecoilRight"] = {
                    [1] = 0,
                    [2] = 0
                }
            },
            ["BurstShot"] = 0,
            ["Type"] = "Grenade",
            ["RecoilPowerStepAmount"] = 1,
            ["FireModes"] = {
                ["Auto"] = false,
                ["ChangeFiremode"] = false,
                ["Burst"] = false,
                ["Semi"] = false
            },
            ["BulletDrop"] = 0,
            ["CenterDot"] = true,
            ["MaxSpread"] = 0,
            ["CrossHair"] = false,
            ["SlideLock"] = false,
            ["BarrelAtt"] = "",
            ["OtherAtt"] = "",
            ["AimRecoilReduction"] = 1,
            ["BulletType"] = "",
            ["canAim"] = false,
            ["AimInaccuracyDecrease"] = 0,
            ["IncludeChamberedBullet"] = false,
            ["MaxZero"] = 0,
            ["AimInaccuracyStepAmount"] = 0,
            ["adsTime"] = 1,
            ["BulletFlare"] = false,
            ["StoredAmmo"] = 0,
            ["WalkMult"] = 0,
            ["MinSpread"] = 0,
            ["ZeroIncrement"] = 0,
            ["DropOffStart"] = 1000,
            ["TracerColor"] = Color3.new(1, 1, 1),
            ["RandomTracer"] = {
                ["Enabled"] = false,
                ["Chance"] = 25
            }
        },
        [3] = plr.Character.HumanoidRootPart.CFrame,
        [4] = Vector3.new(0,0,0),
        [5] = 150
    }

    game:GetService("ReplicatedStorage"):WaitForChild("ACS_Engine"):WaitForChild("Events"):WaitForChild("Grenade"):FireServer(unpack(args))
end

local function teleport(part)
    local folder = game:GetService("Workspace").Map.GAME:FindFirstChild('Bases')
    local canTeleport = false
    local vehicleSpawn = nil
    local t = tostring(game.Players.LocalPlayer.Team)

    local invaderPrefix = "Invader"
    local nativePrefix = "Native"
    local base = nil

    for i,v in pairs(game:GetService("Workspace").Map.GAME:GetDescendants()) do
        if v.Name == 'VehicleSpawn' then
            canTeleport = true
            vehicleSpawn = v
        end
    end

    if folder then
        if t == 'Invaders' then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:sub(1, #invaderPrefix) == invaderPrefix and child:FindFirstChild('VehicleSpawn') then
                    base = child.Name
                    break
                end
            end
        elseif t == 'Natives' then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:sub(1, #nativePrefix) == nativePrefix and child:FindFirstChild('VehicleSpawn') then
                    base = child.Name
                    break
                end
            end
        end
    elseif not folder and canTeleport then
        local args = {
            [1] = "Pickup",
            [2] = vehicleSpawn
        }

        game:GetService("ReplicatedStorage").VehicleReplicated.RequestSpawn:InvokeServer(unpack(args))

        task.wait(0.2)

        game.Players.LocalPlayer.Character.Humanoid.Jump = true

        local args = {
            [2] = true
        }

        game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

        task.wait(0.1)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
        print(vehicleSpawn.Parent,vehicleSpawn)
    else
        local seatFound = false

        for i,v in pairs(game:GetService("Workspace").ActiveVehicles:GetDescendants()) do
            if v:IsA('Folder') and v.Name == 'Body' then
                if v:FindFirstChild('EnterPromptPart') then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.EnterPromptPart.CFrame
                    fireproximityprompt(v.EnterPromptPart.ProximityPrompt)
                    seatFound = true
                end
            end
        end

        if not seatFound then
            local notif = Notification.new("warning", "Teleport","Failed Teleport / No Vehicles")
            notif:deleteTimeout(3)
        else
            task.wait(0.4)

            game.Players.LocalPlayer.Character.Humanoid.Jump = true

            local args = {
                [2] = true
            }

            game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
        end
    end

    if workspace.Map.GAME:FindFirstChild('Bases') ~= nil then

        local args = {
            [1] = "Pickup",
            [2] = workspace.Map.GAME.Bases[base].VehicleSpawn
        }

        game:GetService("ReplicatedStorage").VehicleReplicated.RequestSpawn:InvokeServer(unpack(args))

        task.wait(0.2)

        game.Players.LocalPlayer.Character.Humanoid.Jump = true

        local args = {
            [2] = true
        }

        game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

        task.wait(0.1)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
    end
end

local function CFrameteleport(part)
    local folder = game:GetService("Workspace").Map.GAME:FindFirstChild('Bases')
    local canTeleport = false
    local vehicleSpawn = nil
    local t = tostring(game.Players.LocalPlayer.Team)

    local invaderPrefix = "Invader"
    local nativePrefix = "Native"
    local base = nil

    for i,v in pairs(game:GetService("Workspace").Map.GAME:GetDescendants()) do
        if v.Name == 'VehicleSpawn' then
            canTeleport = true
            vehicleSpawn = v
        end
    end

    if folder then
        if t == 'Invaders' then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:sub(1, #invaderPrefix) == invaderPrefix and child:FindFirstChild('VehicleSpawn') then
                    base = child.Name
                    break
                end
            end
        elseif t == 'Natives' then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:sub(1, #nativePrefix) == nativePrefix and child:FindFirstChild('VehicleSpawn') then
                    base = child.Name
                    break
                end
            end
        end
    elseif not folder and canTeleport then
        local args = {
            [1] = "Pickup",
            [2] = vehicleSpawn
        }

        game:GetService("ReplicatedStorage").VehicleReplicated.RequestSpawn:InvokeServer(unpack(args))

        task.wait(0.2)

        game.Players.LocalPlayer.Character.Humanoid.Jump = true

        local args = {
            [2] = true
        }

        game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

        task.wait(0.1)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part
    else
        local seatFound = false

        for i,v in pairs(game:GetService("Workspace").ActiveVehicles:GetDescendants()) do
            if v:IsA('Folder') and v.Name == 'Body' then
                if v:FindFirstChild('EnterPromptPart') then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.EnterPromptPart.CFrame
                    fireproximityprompt(v.EnterPromptPart.ProximityPrompt)
                    seatFound = true
                end
            end
        end

        if not seatFound then
            local notif = Notification.new("warning", "Teleport","Failed Teleport / No Vehicles")
            notif:deleteTimeout(3)
        else
            task.wait(0.4)

            game.Players.LocalPlayer.Character.Humanoid.Jump = true

            local args = {
                [2] = true
            }

            game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part
        end
    end

    if workspace.Map.GAME:FindFirstChild('Bases') then

        local args = {
            [1] = "Pickup",
            [2] = workspace.Map.GAME.Bases[base].VehicleSpawn
        }

        game:GetService("ReplicatedStorage").VehicleReplicated.RequestSpawn:InvokeServer(unpack(args))

        task.wait(0.2)

        game.Players.LocalPlayer.Character.Humanoid.Jump = true

        local args = {
            [2] = true
        }

        game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer(unpack(args))

        task.wait(0.1)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part
    end
end

function destroyVehicleGround(part)
    if part.Parent.Parent.Name == 'Invaders_Ground' or part.Parent.Parent.Name == 'Natives_Ground' then
        local args = {
            [1] = part,
            [2] = 10000,
            [3] = "Gun"
        }

        game:GetService("ReplicatedStorage"):WaitForChild("VehicleDmg_Remotes"):WaitForChild("VehicleDamage"):FireServer(unpack(args))
    end
end

function destroyVehicleAir(part)
    if part.Parent.Parent.Name == 'Invaders_Air' or part.Parent.Parent.Name == 'Natives_Air' then
        local args2 = {
            [1] = part,
            [2] = 10000,
            [3] = "Gun"
        }

        game:GetService("ReplicatedStorage"):WaitForChild("VehicleDmg_Remotes"):WaitForChild("HeliDamage"):FireServer(unpack(args2))
    end
end

function gunEsp(drop)
    local camera = workspace.CurrentCamera
    local runservice = game:GetService("RunService")

    local dropesp = Drawing.new("Text")
    dropesp.Visible = false
    dropesp.Center = true
    dropesp.Outline = true
    dropesp.Font = 2
    dropesp.Color = Color3.fromRGB(255,255,255)
    dropesp.Size = 13

    if not unloaded then
        local renderstepped
        renderstepped = runservice.RenderStepped:Connect(function()
            if workspace.Map.GAME:FindFirstChild('Weapons') then
                if drop and gunESPEnabled then
                    local drop_pos, drop_onscreen = camera:WorldToViewportPoint(drop.Position)

                    if drop_onscreen then
                        dropesp.Position = Vector2(drop_pos.X, drop_pos.Y)
                        dropesp.Text = drop.Parent.Name..'\n'..'Distance:'..tostring(math.floor(game.Players.LocalPlayer:DistanceFromCharacter(drop.Position)))
                        dropesp.Visible = true
                    else
                        dropesp.Visible = false
                    end
                else
                    dropesp.Visible = false
                    dropesp:Remove()
                    renderstepped:Disconnect()
                end
            else
                dropesp.Visible = false
                dropesp:Remove()
                renderstepped:Disconnect()
            end
        end)
    end
end

function partESP(part)
    local ESPPartparent = part
    local Box = Instance.new("BoxHandleAdornment")
    
    Box.Name = "esp"
    Box.Adornee = ESPPartparent
    Box.Color3 = Color3.new(1,1,1)
    Box.AlwaysOnTop = true
    Box.Transparency = 0.5
    Box.Parent = part
    Box.Size = part.Size
    Box.ZIndex = 10
end

playerBoxLeft:AddToggle('fovToggle', {
    Text = 'Change FOV',
    Default = false,
    Tooltip = 'Changes your FOV (You have to hold a gun)',
})

Toggles.fovToggle:OnChanged(function(Value)
    if not Value then
        pfov = 70
        return
    end

    task.spawn(function()
        while Value do
            local f = require(game:GetService("Players").LocalPlayer.PlayerScripts.settingsConfig)
            f.FOV = pfov
            task.wait()
        end
    end)
end)

playerBoxLeft:AddToggle('cframeToggle', {
    Text = 'CFrame Speed',
    Default = false,
    Tooltip = 'Changes your CFrame speed',
})

Toggles.cframeToggle:OnChanged(function(Value)
    if not Value then
        cframeValue = 0
        return
    end
    task.spawn(function()
        while Value do
            if game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.lookVector * cframeValue
            end
        task.wait()
        end
    end)
end)

playerBoxLeft:AddToggle('walkspeedToggle', {
    Text = 'Walkspeed',
    Default = false,
    Tooltip = 'Changes your walkspeed (press shift to update)',
})

Toggles.walkspeedToggle:OnChanged(function(Value)
    local s = require(game:GetService("ReplicatedStorage").Modules.Shared.Useful)
    s.isUserExcluded = function() return true end

    if not Value then
        local q = require(game:GetService("ReplicatedStorage")["ACS_Engine"].GameRules.Config)
        q.RunWalkSpeed = 23
        q.NormalWalkSpeed = 15
        q.SlowPaceWalkSpeed = 10
        walkspeedValue = 23
        return
    end
    task.spawn(function()
        while Value do
            local q = require(game:GetService("ReplicatedStorage")["ACS_Engine"].GameRules.Config)
            q.RunWalkSpeed = walkspeedValue
            q.NormalWalkSpeed = walkspeedValue
            q.SlowPaceWalkSpeed = walkspeedValue
            game:GetService("ReplicatedStorage").Parachutes.ChuteRem:InvokeServer()
            task.wait()
        end
    end)
end)

playerBoxLeft:AddToggle('jumpPowerToggle', {
    Text = 'Jump Power',
    Default = false,
    Tooltip = 'Change your jump power (Press shift to update)',

    Callback = function(Value)
        getgenv().jumpPowerBool = Value
    end
})

Toggles.jumpPowerToggle:OnChanged(function()
    task.spawn(function()
        rjumpthing = require(game:GetService("ReplicatedStorage").ACS_Engine.GameRules.Config)
        if jumpPowerBool then
            while jumpPowerBool do
                rjumpthing.JumpPower = jumpPowerValue
                task.wait()
            end
        else
            rjumpthing.JumpPower = 35
        end
    end)
end)

playerBoxLeft:AddToggle('bhopToggle', {
    Text = 'Bunny Hop',
    Default = false,
    Tooltip = 'Remove the jump cooldown',

    Callback = function(Value)
        local gang = require(game:GetService("ReplicatedStorage").ACS_Engine.GameRules.Config)

        if Value then
            gang.JumpCoolDown = 0
        else
            gang.JumpCoolDown = 0.65
        end
    end
})

--[[

    local godmodeButton = playerBoxLeft:AddButton({
        Text = 'Godmode Glitch',
        Func = function()
            game:GetService("ReplicatedStorage").ACS_Engine.Events.WeaponDamage:FireServer(nil, nil, nil, nil, (0/0), nil, nil, Vector2(1, 5))
            local notif = Notification.new("info", "Godmode", "Godmode Enabled!")
            notif:deleteTimeout(2)
        end,
        DoubleClick = false,
        Tooltip = "It's finally back after all this time (You cant die or use guns sorry)"
    })

]]--

playerBoxRight:AddSlider('fovSlider', {
    Text = 'FOV Scale',
    Default = 70,
    Min = 50,
    Max = 120,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        if Toggles.fovToggle.Value then
            pfov = Value
        end
    end
})

playerBoxRight:AddSlider('cframeSlider', {
    Text = 'CFrame Speed',
    Default = 0,
    Min = 0,
    Max = 0.5,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        if Toggles.cframeToggle.Value then
            cframeValue = Value
        end
    end
})

playerBoxRight:AddSlider('walkspeedSlider', {
    Text = 'Walkspeed Value',
    Default = 20,
    Min = 20,
    Max = 55,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        if Toggles.walkspeedToggle.Value then
            walkspeedValue = Value
        end
    end
})

playerBoxRight:AddSlider('jumpPowerSlider', {
    Text = 'Jump Power Value',
    Default = 35,
    Min = 35,
    Max = 100,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        if Toggles.jumpPowerToggle.Value then
            jumpPowerValue = Value
        end
    end
})

local playerLabel = Tabs.Player:AddLeftGroupbox('Player Tab Info');
playerLabel:AddLabel('You can edit your FOV or speed in this tab\n\nNote that editing speed is very blatant and you can get called out', true)

local visualsTabBox = Tabs.Visuals:AddLeftTabbox()

local visualsToggleTab = visualsTabBox:AddTab('ESP Toggles')
local visualsSettingsTab = visualsTabBox:AddTab('ESP Settings')

visualsToggleTab:AddToggle('plrEspToggle', {
    Text = 'Player Esp',
    Default = false,
    Tooltip = 'See players through walls and stuff',

    Callback = function(Value)
        espSettings.teamSettings.enemy.enabled = Value
		espSettings.teamSettings.enemy.boxColor[1] = Color3.new(1.0, 0.0, 0.0)
        
        if not espTeamCheck then
        	espSettings.teamSettings.friendly.enabled = Value
			espSettings.teamSettings.friendly.boxColor[1] = Color3.new(0.0, 0.0, 1.0)
            espSettings.teamSettings.friendly.tracerColor[1] = Color3.new(0.0, 0.0, 1.0)
       	end
    end
})

visualsToggleTab:AddToggle('wpnEspToggle', {
    Text = 'Map Gun ESP',
    Default = false,
    Tooltip = 'An ESP for the guns that spawn around the map',

    Callback = function(Value)
        if game:GetService("Workspace").Map.GAME:FindFirstChild('Weapons') ~= nil then
            getgenv().wpnEspBool = Value
        end
    end
})

visualsSettingsTab:AddToggle('plrEspBoxes', {
    Text = 'Boxes',
    Default = false,
    Tooltip = 'Draw boxes around the players',

    Callback = function(Value)
        espSettings.teamSettings.friendly.box = Value
        espSettings.teamSettings.enemy.box = Value
    end
})

visualsSettingsTab:AddToggle('plrEspChams', {
    Text = 'Chams',
    Default = false,
    Tooltip = 'Draw an outline around players',

    Callback = function(Value)
        getgenv().chamsEnabled = Value
    end
})

Toggles.plrEspChams:OnChanged(function()
    task.spawn(function()
        if chamsEnabled and espSettings.teamSettings.enemy.enabled then
            while chamsEnabled do
                task.spawn(function()
                    if espSettings.teamSettings.friendly.enabled then
                        for i,v in pairs(workspace.Characters:GetDescendants()) do
                            if v.Parent ~= game.Players.LocalPlayer.Character then
                                if v:IsA('MeshPart') and not v:FindFirstChild('esp') then
                                    if v.Name ~= 'HumanoidRootPart' then
                                        partESP(v)
                                    end
                                end
                            end
                        end
                    else
                        for i,v in pairs(workspace.Characters:GetDescendants()) do
                            if v.Parent == workspace.Characters then
                                if getPlayerByName(v.Name).Team ~= game.Players.LocalPlayer.Team then
                                    for i,v in pairs(v:GetChildren()) do
                                        if v:IsA('MeshPart') and not v:FindFirstChild('esp') then
                                            if v.Name ~= 'HumanoidRootPart' then
                                                partESP(v)
                                            end
                                        end
                                    end
                                else
                                    for i,v in pairs(v:GetDescendants()) do
                                        if v.Name == 'esp' then
                                            v:Destroy()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        else
            for i,v in pairs(workspace.Characters:GetDescendants()) do
                if v.Name == 'esp' then
                    v:Destroy()
                end
            end
        end
    end)
end)

visualsSettingsTab:AddToggle('plrEspTracers', {
    Text = 'Tracers',
    Default = false,
    Tooltip = 'Draw lines from the bottom of the screen to players',

    Callback = function(Value)
        espSettings.teamSettings.friendly.tracer = Value
        espSettings.teamSettings.enemy.tracer = Value
    end
})

visualsSettingsTab:AddToggle('plrEspTeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Show all players or just enemies',

    Callback = function(Value)
        espTeamCheck = Value
        
        if Value then
        	espSettings.teamSettings.friendly.enabled = false
        else
        	espSettings.teamSettings.friendly.enabled = true
        end
    end
})

visualsSettingsTab:AddToggle('plrEspNameCheck', {
    Text = 'Show Name',
    Default = false,
    Tooltip = 'Show player names',

    Callback = function(Value)
        espSettings.teamSettings.enemy.name = Value
        espSettings.teamSettings.friendly.name = Value
    end
})

visualsSettingsTab:AddToggle('plrEspHealth', {
    Text = 'Show Health',
    Default = false,
    Tooltip = 'Show player health',

    Callback = function(Value)
        espSettings.teamSettings.enemy.healthBar = Value
        espSettings.teamSettings.friendly.healthBar = Value
    end
})

visualsSettingsTab:AddToggle('plrEspTeamColor', {
    Text = 'Use Team Colors',
    Default = false,
    Tooltip = 'The esp colors will be the team colors',

    Callback = function(Value)
        if Value then
            getgenv().useTeamColor = true
            espSettings.teamSettings.enemy.boxColor = { "Team Color", 1 }
            espSettings.teamSettings.friendly.boxColor = { "Team Color", 1 }

            espSettings.teamSettings.enemy.tracerColor = { "Team Color", 1 }
            espSettings.teamSettings.friendly.tracerColor = { "Team Color", 1 }
        else
            getgenv().useTeamColor = false
            espSettings.teamSettings.enemy.boxColor = { Color3.new(1,0,0), 1 }
            espSettings.teamSettings.friendly.boxColor = { Color3.new(0,0,1), 1 }

            espSettings.teamSettings.enemy.tracerColor = { Color3.new(1,0,0), 1 }
            espSettings.teamSettings.friendly.tracerColor = { Color3.new(0,0,1), 1 }
        end
    end
})

Toggles.wpnEspToggle:OnChanged(function(Value)
    task.spawn(function()
        if wpnEspBool then
            gunESPEnabled = true

            if workspace.Map.GAME:FindFirstChild('Weapons') and not unloaded then
                for i,v in next, workspace.Map.GAME.Weapons:GetChildren() do
                    gunEsp(v.Part)
                    for i,v in pairs(v:GetDescendants()) do
                        if v:IsA('MeshPart') or v:IsA('UnionOperation') then
                            partESP(v)
                        end
                    end
                end
                
                workspace.Map.GAME.Weapons.ChildAdded:Connect(function()
                    gunESPEnabled = false
                    for i,v in next, workspace.Map.GAME.Weapons:GetDescendants() do
                        if v.Name == 'esp' then
                            v:Destroy()
                        end
                    end
                    task.wait()
                    gunEsp()
                    task.wait()
                    gunESPEnabled = true
                    for i,v in next, workspace.Map.GAME.Weapons:GetChildren() do
                        gunEsp(v.Part)
                        for i,v in pairs(v:GetDescendants()) do
                            if v:IsA('MeshPart') or v:IsA('UnionOperation') then
                                partESP(v)
                            end
                        end
                    end
                end)

                workspace.Map.GAME.Weapons.ChildRemoved:Connect(function()
                    gunESPEnabled = false
                    for i,v in next, workspace.Map.GAME.Weapons:GetDescendants() do
                        if v.Name == 'esp' then
                            v:Destroy()
                        end
                    end
                    task.wait()
                    gunEsp()
                    task.wait()
                    gunESPEnabled = true
                    for i,v in next, workspace.Map.GAME.Weapons:GetChildren() do
                        gunEsp(v.Part)
                        for i,v in pairs(v:GetDescendants()) do
                            if v:IsA('MeshPart') or v:IsA('UnionOperation') then
                                partESP(v)
                            end
                        end
                    end
                end)
            else
                gunEsp()
            end
        else
            gunESPEnabled = false
            if workspace.Map.GAME:FindFirstChild('Weapons') then
                for i,v in next, workspace.Map.GAME.Weapons:GetDescendants() do
                    if v.Name == 'esp' then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end)

local visualsLabel = Tabs.Visuals:AddLeftGroupbox('Visuals Tab Info');
visualsLabel:AddLabel('See either enemies or the hidden weapons around the map through walls\n\nBecause of some new game changes, the Enemy ESP might be a bit buggy', true)

weaponBoxRight:AddDropdown('gunModDropDown', {
    Values = {'All Guns',unpack(weapons)},
    Default = 1,
    Multi = false,

    Text = 'Gun to Mod',
    Tooltip = 'Select which gun to modify',

    Callback = function(Value)
        gunToMod = Value
    end
})

weaponBoxLeft:AddToggle('recoilToggle', {
    Text = 'Remove Recoil',
    Default = false,
    Tooltip = 'Takes recoil away from your guns',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild('ACS_Settings') then
                v.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        getgenv().recoilBool = Value
        getgenv().modsEnabled1 = Value
    end
})

Toggles.recoilToggle:OnChanged(function()
    task.spawn(function()
        while recoilBool do
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild("ACS_Settings") and gunToMod == 'All Guns' then
                    local settings = require(v.ACS_Settings)

                    settings.camRecoil = {
                        camRecoilUp = {0, 0},
                        camRecoilTilt = {0, 0},
                        camRecoilLeft = {0, 0},
                        camRecoilRight = {0, 0}
                    }
                    settings.gunRecoil = {
                        gunRecoilUp = {0, 0},
                        gunRecoilTilt = {0, 0},
                        gunRecoilLeft = {0, 0},
                        gunRecoilRight = {0, 0}
                    }
                        settings.MinRecoilPower = 0
                        settings.MaxRecoilPower = 0
                        settings.MinSpread = 0
                        settings.MaxSpread = 0
                elseif v:FindFirstChild("ACS_Settings") and v.Name == gunToMod then
                    local settings = require(v.ACS_Settings)

                    settings.camRecoil = {
                        camRecoilUp = {0, 0},
                        camRecoilTilt = {0, 0},
                        camRecoilLeft = {0, 0},
                        camRecoilRight = {0, 0}
                    }
                    settings.gunRecoil = {
                        gunRecoilUp = {0, 0},
                        gunRecoilTilt = {0, 0},
                        gunRecoilLeft = {0, 0},
                        gunRecoilRight = {0, 0}
                    }
                        settings.MinRecoilPower = 0
                        settings.MaxRecoilPower = 0
                        settings.MinSpread = 0
                        settings.MaxSpread = 0
                    end
                end
            task.wait()
        end
    end)
end)

weaponBoxLeft:AddToggle('reloadToggle', {
    Text = 'Instant Reload',
    Default = false,
    Tooltip = 'Reloads your gun instantly',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild('ACS_Settings') then
                v.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        getgenv().reloadBool = Value
        getgenv().modsEnabled2 = Value
    end
})

Toggles.reloadToggle:OnChanged(function()
    task.spawn(function()
        while reloadBool do
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild('ACS_Animations') and gunToMod == 'All Guns' then
                    local animations = require(v.ACS_Animations)
                    animations.ReloadAnim = function() return end
                    animations.TacticalReloadAnim = function() return end
                elseif v:FindFirstChild("ACS_Settings") and v.Name == gunToMod then
                    local animations = require(v.ACS_Animations)
                    animations.ReloadAnim = function() return end
                    animations.TacticalReloadAnim = function() return end
                end
            end
            task.wait()
        end
    end)
end)

weaponBoxLeft:AddToggle('ammoToggle', {
    Text = 'Infinite Ammo',
    Default = false,
    Tooltip = 'Gives your guns infinite ammo',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild('ACS_Settings') then
                v.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        getgenv().ammoBool = Value
        getgenv().modsEnabled3 = Value
    end
})

Toggles.ammoToggle:OnChanged(function()
    task.spawn(function()
        while ammoBool do
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild("ACS_Settings") and gunToMod == 'All Guns' then
                    local s = require(v["ACS_Settings"])
                    s.Ammo = 200
                    s.StoredAmmo = 200
                elseif v:FindFirstChild("ACS_Settings") and v.Name == gunToMod then
                    local s = require(v["ACS_Settings"])
                    s.Ammo = 200
                    s.StoredAmmo = 200
                end
            end

            local ammoCounter = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild('StatusUI').GunHUD.Ammo.AText
            if ammoCounter.Text == '0 / 0' then
                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v:FindFirstChild('ACS_Settings') then
                        local gun = v
                        v.Parent = game.Players.LocalPlayer.Backpack
                        task.wait(0.75)
                        v.Parent = game.Players.LocalPlayer.Character
                        task.wait(0.65)
                    end
                end
            end
            task.wait()
        end
    end)
end)

--[[

Toggles.ammoToggle:OnChanged(function()
    task.spawn(function()
        while ammoBool do
            local ammoCounter = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild('StatusUI'):FindFirstChild('GunHUD').Ammo.AText
            if ammoCounter.Text == '0 / 0' then
                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v:FindFirstChild('ACS_Settings') then
                        local gun = v
                        v.Parent = game.Players.LocalPlayer.Backpack
                        task.wait()
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
            end
            task.wait()
        end
    end)
end)

weaponBoxLeft:AddToggle('instantKillToggle', {
    Text = 'Instant Kill',
    Default = false,
    Tooltip = 'Allows your guns to instantly kill enemies',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild('ACS_Settings') then
                v.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        getgenv().instantKillBool = Value
        getgenv().modsEnabled4 = Value
    end
})

Toggles.instantKillToggle:OnChanged(function()
    task.spawn(function()
        while instantKillBool do
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild("ACS_Settings") and gunToMod == 'All Guns' then
                    local s = require(v.ACS_Settings)
                    s.LimbDamage = {100,100}
                    s.TorsoDamage = {100,100}
                    s.HeadDamage = {100,100}
                elseif v:FindFirstChild("ACS_Settings") and v.Name == gunToMod then
                    local s = require(v.ACS_Settings)
                    s.LimbDamage = {100,100}
                    s.TorsoDamage = {100,100}
                    s.HeadDamage = {100,100}
                end
            end
            task.wait()
        end
    end)
end)

]]--

weaponBoxLeft:AddToggle('allowAutoToggle', {
    Text = 'Allow Full Auto',
    Default = false,
    Tooltip = 'Allows your guns to go automatic (press V to switch between semi and auto)',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:FindFirstChild('ACS_Settings') then
                v.Parent = game.Players.LocalPlayer.Backpack
            end
        end
        getgenv().allowAutoBool = Value
        getgenv().modsEnabled5 = Value
    end
})

Toggles.allowAutoToggle:OnChanged(function()
    task.spawn(function()
        while allowAutoBool do
            for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v:FindFirstChild("ACS_Settings") and gunToMod == 'All Guns' then
                    local s = require(v["ACS_Settings"])
                    s.FireModes.Auto = true
                    s.FireModes.ChangeFiremode = true
                elseif v:FindFirstChild("ACS_Settings") and v.Name == gunToMod then
                    local s = require(v["ACS_Settings"])
                    s.FireModes.Auto = true
                    s.FireModes.ChangeFiremode = true
                end
            end
            task.wait()
        end
    end)
end)

task.spawn(function()
    while not unloaded do
        if modsEnabled1 or modsEnabled2 or modsEnabled3 or modsEnabled4 or modsEnabled5 then
            game.Players.LocalPlayer.Character:FindFirstChild('Humanoid').Died:Connect(function()
                local spawnButton = game:GetService("Players").LocalPlayer.PlayerGui.MENU.SpawnScreen
                local killFeed = game:GetService("Players").LocalPlayer.PlayerGui.KillFeed

                while killFeed.Enabled do
                    killFeed = game:GetService("Players").LocalPlayer.PlayerGui.KillFeed
                    task.wait()
                end

                task.wait(0.2)

                while spawnButton.Visible do
                    spawnButton = game:GetService("Players").LocalPlayer.PlayerGui.MENU.SpawnScreen
                    task.wait()
                end

                task.wait(0.45)

                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v:FindFirstChild('ACS_Settings') then
                        v.Parent = game.Players.LocalPlayer.Backpack
                        task.wait()
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
            end)
        end
        task.wait()
    end
end)

weaponBoxLeft:AddSlider('aimFovSlider', {
    Text = 'Aim FOV',
    Default = 60,
    Min = 0,
    Max = 120,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Adjust your FOV when aiming down sight',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            local s = require(v["ACS_Settings"])
            s.Zoom = Value
        end
    end
})

weaponBoxLeft:AddSlider('firerateSlider', {
    Text = 'Firerate',
    Default = 120,
    Min = 120,
    Max = 1500,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Adjust the firerate of your guns',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            local s = require(v["ACS_Settings"])
            s.ShootRate = Value
        end
    end
})

weaponBoxLeft:AddSlider('bulletAmountSlider', {
    Text = 'Bullet Amount',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Adjust the amount of bullets fired from your guns at once',

    Callback = function(Value)
        for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            local s = require(v["ACS_Settings"])
            s.Bullets = Value
        end
    end
})

weaponBoxLeft:AddDivider()

weaponBoxLeft:AddDropdown('hiddenWeaponDropDown', {
    Values = {unpack(hiddenweapons)},
    Default = 0,
    Multi = false,

    Text = 'Weapon to pick up',
    Tooltip = 'Teleports you to a map weapon and picks it up',

    Callback = function(mob)
        gunToGrab = mob
    end
})

local getGunButton = weaponBoxLeft:AddButton({
    Text = 'Get Weapon',
    Func = function()
        local ogcframe = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        
        if gunToGrab == nil then
            local notif = Notification.new("warning", "Get Weapon", "Select a weapon to grab")
            notif:deleteTimeout(2)
            return
        end
        
        for i,v in pairs(game:GetService("Workspace").Map.GAME:FindFirstChild('Weapons'):GetDescendants()) do
            if v:IsA('ClickDetector') and v.Parent.Parent.Name == tostring(gunToGrab) then
                if v.Parent.Parent.Name:find('Gold') then
                    local code = nil

                    for i,v in pairs(workspace.Map.clocs:GetDescendants()) do
                        if v:IsA('TextLabel') and v.Text ~= '' then
                            code = tonumber(v.Text)
                        end
                    end

                    game:GetService("ReplicatedStorage").LooseRemotes.cRemote:InvokeServer(code)
                end
	            teleport(v.Parent)
	            task.wait(0.6)
	            fireclickdetector(v)
	            task.wait(0.1)
	            CFrameteleport(ogcframe)
            elseif v:IsA('ProximityPrompt') and v.Parent.Parent.Name == tostring(gunToGrab) then
                teleport(v.Parent)
                task.wait(0.6)
                fireproximityprompt(v)
                task.wait()
                CFrameteleport(ogcframe)
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Pick up the weapon that you selected'
})

local TabBox = Tabs.Weapon:AddLeftTabbox()

local aimbotTab = TabBox:AddTab('Aimbot')

aimbotTab:AddToggle('aimbotToggle', {
    Text = 'Aimbot',
    Default = false,
    Tooltip = 'Lock on to players (idk its an aimbot)',

    Callback = function(Value)
    	if not Value then
    		Environment.FOVSettings.Visible = false
    		task.wait(0.1)
    	end
    
        Environment.Settings.Enabled = Value
    end
})

Toggles.aimbotToggle:OnChanged(function()	
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local Camera = workspace.CurrentCamera
	local LocalPlayer = Players.LocalPlayer
	
	local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}
	
	Environment.FOVCircle = Drawing.new("Circle")
	
	local function CancelLock()
		Environment.Locked = nil
		if Animation then Animation:Cancel() end
		Environment.FOVCircle.Color = Environment.FOVSettings.Color
	end
	
	local function GetClosestPlayer()
		if not Environment.Locked then
			RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)
	
			for _, v in next, Players:GetPlayers() do
				if v ~= LocalPlayer then
					if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
						if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then  end
						if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then  end
						if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end
	
						local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
						local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude
	
						if Distance < RequiredDistance and OnScreen then
							RequiredDistance = Distance
							Environment.Locked = v
						end
					end
				end
			end
		elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
			CancelLock()
		end
	end
	
	--// Typing Check
	
	ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
		Typing = true
	end)
	
	ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
		Typing = false
	end)
	
	--// Main
	
	local function Load()
		ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
			if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
				Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
				Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
				Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
				Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
				Environment.FOVCircle.Color = Environment.FOVSettings.Color
				Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
				Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
				Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
			else
				Environment.FOVCircle.Visible = false
			end
	
			if Running and Environment.Settings.Enabled then
				GetClosestPlayer()
	
				if Environment.Locked then
					if Environment.Settings.ThirdPerson then
						Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
	
						local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
						mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
					else
						if Environment.Settings.Sensitivity > 0 then
							Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
							Animation:Play()
						else
							Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
						end
					end
	
				Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
	
				end
			end
		end)
	
		ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
			if not Typing then
				pcall(function()
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						if Environment.Settings.Toggle then
							Running = not Running
	
							if not Running then
								CancelLock()
							end
						else
							Running = true
						end
					end
				end)
	
				pcall(function()
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						if Environment.Settings.Toggle then
							Running = not Running
	
							if not Running then
								CancelLock()
							end
						else
							Running = true
						end
					end
				end)
			end
		end)
	
		ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
			if not Typing then
				if not Environment.Settings.Toggle then
					pcall(function()
						if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
							Running = false; CancelLock()
						end
					end)
	
					pcall(function()
						if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
							Running = false; CancelLock()
						end
					end)
				end
			end
		end)
	end
	
	--// Functions
	
	Environment.Functions = {}
	
	function Environment.Functions:Exit()
		for _, v in next, ServiceConnections do
			v:Disconnect()
		end
	
		if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end
	
		getgenv().Aimbot.Functions = nil
		getgenv().Aimbot = nil
		
		Load = nil; GetClosestPlayer = nil; CancelLock = nil
	end
	
	function Environment.Functions:Restart()
		for _, v in next, ServiceConnections do
			v:Disconnect()
		end
	
		Load()
	end
	
	function Environment.Functions:ResetSettings()
		Environment.Settings = {
			Enabled = true,
			TeamCheck = false,
			AliveCheck = true,
			WallCheck = false,
			Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
			ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
			ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
			TriggerKey = "MouseButton2",
			Toggle = false,
			LockPart = "Head" -- Body part to lock on
		}
	
		Environment.FOVSettings = {
			Enabled = true,
			Visible = true,
			Amount = 90,
			Color = Color3.fromRGB(255, 255, 255),
			LockedColor = Color3.fromRGB(255, 70, 70),
			Transparency = 0.5,
			Sides = 60,
			Thickness = 1,
			Filled = false
		}
	end
	Load()
end)

local aimbotSettingsTab = TabBox:AddTab('Aimbot Settings')

aimbotSettingsTab:AddToggle('aimbotFOVToggle', {
    Text = 'Show FOV',
    Default = false,
    Tooltip = 'Show or Hide FOV',

    Callback = function(Value)
		Environment.FOVSettings.Visible = Value
    end
})

aimbotSettingsTab:AddToggle('teamcheckToggle', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'If enabled, aimbot will only target enemies',

    Callback = function(Value)
		Environment.Settings.TeamCheck = Value
    end
})

aimbotSettingsTab:AddToggle('alivecheckToggle', {
    Text = 'Alive Check',
    Default = false,
    Tooltip = 'Check if target is alive',

    Callback = function(Value)
		Environment.Settings.AliveCheck = Value
    end
})

aimbotSettingsTab:AddToggle('fillFOVToggle', {
    Text = 'Fill FOV Circle',
    Default = false,
    Tooltip = 'Fill the FOV circle',

    Callback = function(Value)
		Environment.FOVSettings.Filled = Value
    end
})

aimbotSettingsTab:AddToggle('wallcheckToggle', {
    Text = 'Wallcheck',
    Default = false,
    Tooltip = 'Check to lock on through wall or not(kinda laggy sorry)',

    Callback = function(Value)
		Environment.Settings.WallCheck = Value
    end
})

aimbotSettingsTab:AddDropdown('aimpartDropDown', {
    Values = {'Head','HumanoidRootPart'},
    Default = 1,
    Multi = false,

    Text = 'AimPart',
    Tooltip = 'Which part of the player the aimbot locks onto',

    Callback = function(Value)
        Environment.Settings.LockPart = Value
    end
})

aimbotSettingsTab:AddSlider('aimbotSmoothingSlider', {
    Text = 'Smoothing',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = 'How many seconds it takes to lock on',

    Callback = function(Value)
        Environment.Settings.Sensitivity = Value
    end
})

aimbotSettingsTab:AddDivider()

aimbotSettingsTab:AddSlider('aimbotFOVRadiusSlider', {
    Text = 'Aimbot Fov Radius',
    Default = 80,
    Min = 20,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Tooltip = 'The size of the aimbot FOV',

    Callback = function(Value)
        Environment.FOVSettings.Amount = Value
    end
})

aimbotSettingsTab:AddSlider('aimbotFOVThicknessSlider', {
    Text = 'Aimbot Fov Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
    Tooltip = 'The thickness of the aimbot FOV',

    Callback = function(Value)
        Environment.FOVSettings.Thickness = Value
    end
})

aimbotSettingsTab:AddSlider('aimbotFOVTransparencySlider', {
    Text = 'Aimbot Fov Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = 'The transparency of the aimbot FOV',

    Callback = function(Value)
        Environment.FOVSettings.Transparency = Value
    end
})

local weaponLabel = Tabs.Weapon:AddLeftGroupbox('Weapon Tab Info');
weaponLabel:AddLabel('You can change weapon stats or \ngrap guns from across the map\nPick the gun you want to mod\nusing the left side', true)

utilityBoxLeft:AddToggle('instantInteractToggle', {
    Text = 'Instant Interact',
    Default = false,
    Tooltip = 'Instantly interact with all proximity prompts',

    Callback = function(Value)
        getgenv().instantInteractBool = Value
    end
})

Toggles.instantInteractToggle:OnChanged(function()
    task.spawn(function()
        while instantInteractBool do
            for i,v in pairs(game.workspace:GetDescendants()) do
                if v:IsA('ProximityPrompt') then
                    v.HoldDuration = 0
                end
            end
            task.wait(1)
        end
    end)
end)

utilityBoxLeft:AddToggle('fullbrightToggle', {
    Text = 'Fullbright',
    Default = false,
    Tooltip = 'Lighten up the world (kinda mid ngl)',

    Callback = function(bool)
        if bool then
            game:GetService("Lighting").Brightness = 20
            game:GetService("Lighting").ClockTime = 14
        else
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 0
        end
    end
})

utilityBoxLeft:AddToggle('cosmeticsToggle', {
    Text = 'Unlock Cosmetics',
    Default = false,
    Tooltip = 'Unlocks most cosmetics',

    Callback = function(Value)
        if Value then
            game.Players.LocalPlayer:SetAttribute('Level', 200)
        else
            game.Players.LocalPlayer:SetAttribute('Level', playerLevel)
        end
    end
})

utilityBoxLeft:AddToggle('afkToggle', {
    Text = 'Anti AFK',
    Default = false,
    Tooltip = 'No kick when idle',

    Callback = function(Value)
        getgenv().afkBool = Value
    end
})

Toggles.afkToggle:OnChanged(function()
    task.spawn(function()
        if afkBool then
            local GC = getconnections or get_signal_cons
            if GC then
                for i,v in pairs(GC(game.Players.LocalPlayer.Idled)) do
                    if v["Disable"] then
                        v["Disable"](v)
                    elseif v["Disconnect"] then
                        v["Disconnect"](v)
                    end
                end
            else
                Players.LocalPlayer.Idled:Connect(function()
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2())
                end)
            end
        end
    end)
end)

utilityBoxLeft:AddButton({
    Text = 'Get Box Code',
    Func = function()
        for i,v in pairs(workspace.Map.clocs:GetDescendants()) do
            if v:IsA('TextLabel') and v.Text ~= '' then
                setclipboard(v.Text)
            end
        end

        local notif = Notification.new("info", "INFO", "Code copied to clipboard")
        notif:deleteTimeout(3)
    end,
    DoubleClick = false,
    Tooltip = 'Set the code for the gold gun to your clipboard'
})

utilityBoxLeft:AddDivider()

utilityBoxLeft:AddToggle('adminDetectToggle', {
    Text = 'Admin Detector',
    Default = false,
    Tooltip = 'Will kick or notify you if an admin is in game',

    Callback = function(Value)
        getgenv().adminDetectBool = Value
    end
})

Toggles.adminDetectToggle:OnChanged(function()
    task.spawn(function()
        local adminFound = false
        while adminDetectBool and not adminFound do
            for i,v in pairs(game.Players:GetChildren()) do
                if v ~= nil then
                    local a = getRole(v)
                    if adminMethod == 'Kick' then
                        if table.find(admins,a) then
                            local message = 'Admin Detected:'..v.DisplayName
                            game.Players.LocalPlayer:Kick(message)
                        end
                    else
                        if table.find(admins,a) then
                            local message = 'Admin Detected:'..v.DisplayName
                            local notif = Notification.new("warning", "Admin Detector", message)
                            notif:deleteTimeout(3)
                            adminFound = true
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end)

utilityBoxLeft:AddDropdown('adminDropDown', {
    Values = {'Kick','Notify'},
    Default = 1,
    Multi = false,

    Text = 'Admin Detect Method',
    Tooltip = 'Choose if you get kicked or notified if an admin is in game',

    Callback = function(Value)
        getgenv().adminMethod = Value
    end
})

utilityBoxLeft:AddDropdown('spectateDropDown', {
    Values = {unpack(allPlrs)},
    Default = 0,
    Multi = false,

    Text = 'Spectate Player',
    Tooltip = 'View a player idk',

    Callback = function(Value)
        local camera = workspace.CurrentCamera

        for i,v in pairs(game.Players:GetChildren()) do
            if v.DisplayName == Value then
                camera.CameraSubject = v.Character.Humanoid
            end
        end
    end
})

utilityBoxLeft:AddButton({
    Text = 'Stop Spectating',
    Func = function()
        local camera = workspace.CurrentCamera
        camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
    end,
    DoubleClick = false,
    Tooltip = 'Stop spectating a player'
})

if Owner then

    utilityBoxDev:AddButton({
        Text = 'Spoof Leaderboard', 
        Func = function() 
            local localFrame
            local colorFrame

            for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Leaderboard.Main:GetDescendants()) do
                if v:IsA('Frame') and v.Name == game.Players.LocalPlayer.Name then
                    localFrame = v
                end
            end

            for i,v in pairs(localFrame.Parent:GetChildren()) do
                if v:IsA('Frame') and v.Name ~= game.Players.LocalPlayer.Name    then
                    colorFrame = v
                    break
                end
            end

            localFrame.UIGradient.Color = colorFrame.UIGradient.Color
            localFrame.DisplayName.TextColor3 = Color3.fromRGB(255,255,255)
        end,
        DoubleClick = false,
        Tooltip = 'Spoof your leaderboard name color'
    })

end

utilityBoxRight:AddToggle('lagToggle', {
    Text = 'Lag Server',
    Default = false,
    Tooltip = 'Attempts to lag the game (This can fail or crash you)',

    Callback = function(Value)
        getgenv().lagBool = Value
    end
})

Toggles.lagToggle:OnChanged(function()
    task.spawn(function()
        shared.TeleportToSky = false
    
        if shared.TeleportToSky then
        local char = game:GetService('Players').LocalPlayer.Character
        char.HumanoidRootPart.CFrame = CFrame.new(0,9e9,0)
        task.wait(0.5)
        char.HumanoidRootPart.Anchored = true
        end
        while lagBool do
        game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge * math.huge)
        local function getmaxvalue(val)
           local mainvalueifonetable = 499999
           if type(val) ~= "number" then
               return nil
           end
           local calculateperfectval = (mainvalueifonetable/(val+2))
           return calculateperfectval
        end
         
        local function bomb(tableincrease, tries)
        local maintable = {}
        local spammedtable = {}
         
        table.insert(spammedtable, {})
        z = spammedtable[1]
         
        for i = 1, tableincrease do
            local tableins = {}
            table.insert(z, tableins)
            z = tableins
        end
         
        local calculatemax = getmaxvalue(tableincrease)
        local maximum
         
        if calculatemax then
             maximum = calculatemax
             else
             maximum = 999999
        end
         
        for i = 1, maximum do
             table.insert(maintable, spammedtable)
        end
         
        for i = 1, tries do
            game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(maintable)
        end
        end
         
        bomb(289, 5)
        task.wait(1.5)
        end
    end)
end)

utilityBoxRight:AddToggle('annoyToggle', {
    Text = 'Annoy Server',
    Default = false,
    Tooltip = 'Plays a bullet whizz sound for everyone (Has a chance to kick you)',

    Callback = function(Value)
        if Value then
            equipGun()
            whizz(game.Players.LocalPlayer)
        end

        getgenv().annoyBool = Value
    end
})

Toggles.annoyToggle:OnChanged(function()
    task.spawn(function()
        while annoyBool do
            if annoyType == 'Normal' then
                for i,v in pairs(game.Players:GetChildren()) do
                    game:GetService("ReplicatedStorage").ACS_Engine.Events.Whizz:FireServer(v)
                end
            elseif annoyType == 'Silent' then
                for i,v in pairs(game.Players:GetChildren()) do
                    if v ~= game.Players.LocalPlayer then
                        game:GetService("ReplicatedStorage").ACS_Engine.Events.Whizz:FireServer(v)
                    end
                end
            end
            task.wait(0.21)
        end
    end)
end)

utilityBoxRight:AddDropdown('annoyTypeDropDown', {
    Values = {'Normal','Silent'},
    Default = 1,
    Multi = false,

    Text = 'Annoy Type',
    Tooltip = 'Normal means you and everyone hear it, Silent means just everyone else, not you',

    Callback = function(Value)
        annoyType = Value
    end
})

local utilityLabel = Tabs.Utility:AddLeftGroupbox('Utility Tab Info');
utilityLabel:AddLabel('This tab has modules that can help you out a bit\n\nThe trolling section is for annoying and messing with the other people in the server', true)

--[[

local explodePlayerButton = blatantBoxLeft:AddButton({
    Text = 'Explode Player',
    Func = function()
        if plrExplode ~= nil then
            if game.Players.LocalPlayer.Backpack:FindFirstChild('Impact') ~= nil then
                if plrExplode.Character ~= nil then
                    explode(plrExplode)
                else
                    local notif = Notification.new("warning", "Explode Player", "Player character not found")
                    notif:deleteTimeout(3)
                end
            elseif game.Players.LocalPlayer.Backpack:FindFirstChild('Grenade') ~= nil then
                if plrExplode.Character ~= nil then
                    grenadeExplode(plrExplode)
                    task.wait(3)
                    if plrExplode.Character.Humanoid.Health > 0 then
                        local notif = Notification.new("warning", "Burn Player", "Failed to kill player")
                        notif:deleteTimeout(3)
                    end
                else
                    local notif = Notification.new("warning", "Explode Player", "Player character not found")
                    notif:deleteTimeout(3)
                end
            else
                local notif = Notification.new("warning", "Explode Player", "Impact or normal grenade not found")
                notif:deleteTimeout(3)
            end
        else
            local notif = Notification.new("warning", "Explode Player", "Please pick a player to blow up")
            notif:deleteTimeout(3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Attempts to explode a player (Requires an impact grenade or a normal grenade)'
})

local burnPlayerButton = blatantBoxLeft:AddButton({
    Text = 'Burn Player',
    Func = function()
        if plrExplode ~= nil then
            if game.Players.LocalPlayer.Backpack:FindFirstChild('Molotov') ~= nil then
                if plrExplode.Character ~= nil then
                    burn(plrExplode)
                    task.wait(3)
                    if plrExplode.Character.Humanoid.Health > 0 then
                        local notif = Notification.new("warning", "Burn Player", "Failed to kill player")
                        notif:deleteTimeout(3)
                    end
                else
                    local notif = Notification.new("warning", "Burn Player", "Player character not found")
                    notif:deleteTimeout(3)
                end
            else
                local notif = Notification.new("warning", "Burn Player", "Molotov not found")
                notif:deleteTimeout(3)
            end
        else
            local notif = Notification.new("warning", "Burn Player", "Please pick a player to burn")
            notif:deleteTimeout(3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Attempts to start a fire on a player (Requires a molotov)'
})

local explodeAllButton = blatantBoxLeft:AddButton({
    Text = 'Explode All',
    Func = function()
        local ammoBox = nil

        if workspace.Map.GAME:FindFirstChild('Bases') ~= nil then
            for i,v in pairs(workspace.Map.GAME:FindFirstChild('Bases'):GetDescendants()) do
                if v.Name == 'AmmoEquipmentRefil' and v.Parent.Name:find(tostring(game.Players.LocalPlayer.Team.Name)) then
                    teleport(v)
                    ammoBox = v
                end
            end
        end
        
        for i,player in pairs(game.Players:GetChildren()) do
            if canTarget(player) then
                if ammoBox ~= nil then
                    if game.Players.LocalPlayer.Backpack:FindFirstChild('Impact') ~= nil then
                        fireproximityprompt(ammoBox.ProximityPrompt)
                        task.wait()
                        explode(player)
                        task.wait()
                        ammoBox.ProximityPrompt.Enabled = false
                        task.wait()
                        ammoBox.ProximityPrompt.Enabled = true
                        task.wait()
                        fireproximityprompt(ammoBox.ProximityPrompt)
                    elseif game.Players.LocalPlayer.Backpack:FindFirstChild('Grenade') ~= nil then
                        fireproximityprompt(ammoBox.ProximityPrompt)
                        task.wait()
                        grenadeExplode(player)
                        task.wait()
                        ammoBox.ProximityPrompt.Enabled = false
                        task.wait()
                        ammoBox.ProximityPrompt.Enabled = true
                        task.wait()
                        fireproximityprompt(ammoBox.ProximityPrompt)
                    else
                        local notif = Notification.new("warning", "Explode Player", "Impact or normal grenade not found")
                        notif:deleteTimeout(3)
                        break
                    end
                else
                    local notif = Notification.new("warning", "Explode All", "Ammo Box not found")
                    notif:deleteTimeout(3)
                    break
                end
            end
            task.wait(0.3)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Attempts to explode everyone on the opposite team'
})

blatantBoxRight:AddDropdown('explodePlayerDropDown', {
    Values = {unpack(plrs)},
    Default = 0,
    Multi = false,

    Text = 'Player to Explode/Burn',
    Tooltip = 'Select a player to blow up or cook alive',

    Callback = function(Value)
        for i,v in pairs(game.Players:GetChildren()) do
            if v.DisplayName == Value then
                plrExplode = v
            end
        end
    end
})

]]--

local killAllButton = blatantBoxLeft:AddButton({
    Text = 'Kill All',
    Func = function()
        --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()

        for i,v in pairs(game.Players:GetChildren()) do
            if v.Team ~= game.Players.LocalPlayer.Team and v.Character:FindFirstChild('HumanoidRootPart') ~= nil and game.Players.LocalPlayer.Character.PrimaryPart then
                killPlayer(v)
            end
            task.wait()
        end
    end,
    DoubleClick = false,
    Tooltip = 'Kills everyone on the opposite team'
})

local killPlrButton = killAllButton:AddButton({
    Text = 'Kill Player',
    Func = function()
        if playerToKill ~= nil then 
            if playerToKill.Character and game.Players.LocalPlayer.Character.PrimaryPart then
                --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()
                killPlayer(playerToKill)
            else
                local notif = Notification.new("warning", "Kill Player", "Player character not found")
                notif:deleteTimeout(2)
            end
        else
            local notif = Notification.new("warning", "Kill Player", "Please select player to kill")
            notif:deleteTimeout(2)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Kill a single player from the opposite team'
})

blatantBoxLeft:AddToggle('loopKillAll', {
    Text = 'Loop Kill All',
    Default = false,
    Tooltip = 'While active, will kill everyone from the opposite team constantly',

    Callback = function(Value)
        getgenv().killAllLoop = Value
    end
})

Toggles.loopKillAll:OnChanged(function()
    task.spawn(function()
        local runFunc = true

        while killAllLoop do
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Team ~= game.Players.LocalPlayer.Team and v.Character ~= nil and v.Character:FindFirstChild('HumanoidRootPart') and v.Character.Humanoid.Health > 0 and game.Players.LocalPlayer.Character.PrimaryPart then
                    if runFunc then
                        --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()
                    end
                    killPlayer(v)
                end
                task.wait()
                runFunc = false
            end
            task.wait(2)
            runFunc = true
        end
    end)
end)

blatantBoxLeft:AddToggle('loopKillPlr', {
    Text = 'Loop Kill Player',
    Default = false,
    Tooltip = 'Constantly kills a player that you choose',

    Callback = function(Value)
        getgenv().killPlrLoop = Value
    end
})

Toggles.loopKillPlr:OnChanged(function()
    task.spawn(function()
        while killPlrLoop do
            --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Character ~= nil and v.Character:FindFirstChild('HumanoidRootPart') ~= nil and v == playerToKill and game.Players.LocalPlayer.Character.PrimaryPart then
                    killPlayer(v)
                end
            end
            task.wait(2)
        end
    end)
end)

blatantBoxLeft:AddToggle('killAuraToggle', {
    Text = 'Kill Aura',
    Default = false,
    Tooltip = 'Kills enemies within a certain range of you',

    Callback = function(Value)
        getgenv().killAuraBool = Value
    end
})

Toggles.killAuraToggle:OnChanged(function()
    task.spawn(function()
        while killAuraBool do 
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Team ~= game.Players.LocalPlayer.Team and v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild('HumanoidRootPart') and game.Players.LocalPlayer.Character.PrimaryPart then 
                    if game.Players.LocalPlayer:DistanceFromCharacter(v.Character.HumanoidRootPart.Position) <= killAuraRange then
                        killPlayer(v)
                    end
                end
            end
            task.wait()
        end
    end)
end)

blatantBoxLeft:AddDivider()

blatantBoxLeft:AddToggle('assistKillToggle', {
    Text = 'Assist Farm',
    Default = false,
    Tooltip = 'Uses assists to slowly and less blatantly farm exp, still kinda blatant tho',

    Callback = function(Value)
        getgenv().assistFarmLoop = Value
    end
})

Toggles.assistKillToggle:OnChanged(function()
    task.spawn(function()
        while assistFarmLoop do
            --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()
            if unloaded or not assistFarmLoop then
                break
            end
            for i,v in pairs(game.Players:GetChildren()) do
                if v ~= game.Players.LocalPlayer and v.Character ~= nil and v.Character.PrimaryPart and v.Team ~= game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Character.PrimaryPart then
                    if v.Character.Humanoid.Health >= 90 then
                        damagePlayer(v)
                    end
                end
                task.wait()
            end
            task.wait(10)
        end
    end)
end)

--[[

local destroyVehicles = blatantBoxLeft:AddButton({
    Text = 'Destroy Vehicles',
    Func = function()
        for i,v in next, workspace.ActiveVehicles:GetDescendants() do
            if v.Name == 'Body' and vehicletype == 'Car' then
                destroyVehicleGround(v)
                task.wait()
            elseif v.Name == 'Body' and vehicletype == 'Heli' then
                destroyVehicleAir(v)
                task.wait()
            elseif v.Name == 'Body' and vehicletype == 'Both' then
                destroyVehicleGround(v)
                task.wait()
                destroyVehicleAir(v)
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Destroy all or only select vehicles in the game'
})

blatantBoxLeft:AddToggle('loopDestroyVehicles', {
    Text = 'Loop Destroy Vehicles',
    Default = false,
    Tooltip = 'Constantly destroys the vehicles on the map',

    Callback = function(Value)
        getgenv().destroyVehiclesLoop = Value
    end
})

Toggles.loopDestroyVehicles:OnChanged(function()
    task.spawn(function()
        while destroyVehiclesLoop do 
            for i,v in next, workspace.ActiveVehicles:GetDescendants() do
                if v.Name == 'Body' and vehicletype == 'Car' then
                    destroyVehicleGround(v)
                    task.wait()
                elseif v.Name == 'Body' and vehicletype == 'Heli' then
                    destroyVehicleAir(v)
                    task.wait()
                elseif v.Name == 'Body' and vehicletype == 'Both' then
                    destroyVehicleGround(v)
                    task.wait()
                    destroyVehicleAir(v)
                end
            end
            task.wait(0.8)
        end
    end)
end)

]]--

blatantBoxTPSettings:AddDivider()

--[[

blatantBoxLeft:AddToggle('vehicleAuraToggle', {
    Text = 'Vehicle Aura',
    Default = false,
    Tooltip = 'Destroys vehicles within a certain range of you',

    Callback = function(Value)
        getgenv().vehicleAuraBool = Value
    end
})

Toggles.vehicleAuraToggle:OnChanged(function()
    task.spawn(function()
        while vehicleAuraBool do 
            for i,v in pairs(workspace.ActiveVehicles:GetDescendants()) do
                if v.Name == 'Body' then
                    if game.Players.LocalPlayer:DistanceFromCharacter(v.Base.Position) <= vehicleAuraRange then
                        if v.Name == 'Body' and vehicletype == 'Car' then
                            destroyVehicleGround(v)
                            task.wait()
                        elseif v.Name == 'Body' and vehicletype == 'Heli' then
                            destroyVehicleAir(v)
                            task.wait()
                        elseif v.Name == 'Body' and vehicletype == 'Both' then
                            destroyVehicleGround(v)
                            task.wait()
                            destroyVehicleAir(v)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

]]--

local objectiveTeleportButton = blatantBoxTeleport:AddButton({
    Text = 'TP to Objective',
    Func = function()
        if objTeleport ~= nil then
            teleport(objTeleport)
        else
            local notif = Notification.new("warning", "Teleport", 'Select an objective to teleport to')
            notif:deleteTimeout(2)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to selected objective'
})

blatantBoxTPSettings:AddDropdown('objectiveTeleportDropDown', {
    Values = {unpack(objectives)},
    Default = 0,
    Multi = false,

    Text = '\nTeleport to Objective',
    Tooltip = 'Select an objective to teleport to',

    Callback = function(Value)
        for i,v in pairs(game:GetService("Workspace").Map.GAME:GetDescendants()) do
            if v.Name == 'CaptureArea' and v.Parent.Name == Value then
                objTeleport = v
            elseif v.Name == 'CapturePart' and v.Parent.Name == Value then
                objTeleport = v
            end
        end
    end
})

local playerTeleportButton = objectiveTeleportButton:AddButton({
    Text = 'TP to Player',
    Func = function()
        if plrTeleport ~= nil then
            teleport(plrTeleport)
        else
            local notif = Notification.new("warning", "Teleport", 'Select a player to teleport to')
            notif:deleteTimeout(2)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to selected player'
})

blatantBoxTPSettings:AddDropdown('tpPlayerDropDown', {
    Values = {unpack(allPlrs)},
    Default = 0,
    Multi = false,

    Text = 'Teleport to Player',
    Tooltip = 'Select a player to teleport to',

    Callback = function(Value)
        for i,v in pairs(game.Players:GetChildren()) do
            if v.DisplayName == Value then
                plrTeleport = v.Character.HumanoidRootPart
            end
        end
    end
})

if Owner then

    blatantBoxDev:AddToggle('weakenToggle', {
        Text = 'Weaken Enemies',
        Default = false,
        Tooltip = 'Get all enemies down to one shot',

        Callback = function(Value)
            getgenv().weakenBool = Value
        end
    })

    Toggles.weakenToggle:OnChanged(function()
        task.spawn(function()
            local runFunc = true
            local neededHealth = (getLeastDamage() + 2)

            while weakenBool do
                for i,v in pairs(game.Players:GetChildren()) do
                    if v.Character and v.Character:FindFirstChild('HumanoidRootPart') and v.Team ~= game.Players.LocalPlayer.Team and v.Character.Humanoid.Health >= neededHealth then
                        local loopAmount = math.floor(v.Character.Humanoid.Health / getLeastDamage())

                        if runFunc then
                            --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()
                        end

                        for i = 1, loopAmount do
                            damagePlayer(v)
                        end
                    end
                    runFunc = false
                end
                task.wait(1)
                runFunc = true
            end
        end)
    end)

    blatantBoxDev:AddToggle('weakenPlayerToggle', {
        Text = 'Loop Weaken Player',
        Default = false,
        Tooltip = 'Get one enemy to one shot',

        Callback = function(Value)
            if not weakenPlayer and Value then
                local notif = Notification.new("warning", "Weaken Player", 'Select a player to weaken')
                notif:deleteTimeout(2)
            end
            
            getgenv().weakenPlayerBool = Value
        end
    })

    Toggles.weakenPlayerToggle:OnChanged(function()
        task.spawn(function()
            local neededHealth = (getLeastDamage() + 2)

            if weakenPlayer ~= nil then
                while weakenPlayerBool do
                    for i,v in pairs(game.Players:GetChildren()) do
                        if v.Character and v.Character:FindFirstChild('HumanoidRootPart') and v.Team ~= game.Players.LocalPlayer.Team and v.Character.Humanoid.Health >= neededHealth and v == weakenPlayer then
                            local loopAmount = math.floor(v.Character.Humanoid.Health / getLeastDamage())
                            --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()

                            for i = 1, loopAmount do
                                damagePlayer(v)
                            end
                        end
                    end
                    task.wait(1)
                end
            end
        end)
    end)

    blatantBoxDev:AddButton({
        Text = 'Weaken Enemies',
        Func = function()
            local neededHealth = (getLeastDamage() + 1)
            --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()

            for i,v in pairs(game.Players:GetChildren()) do
                if v.Character and v.Character:FindFirstChild('HumanoidRootPart') and v.Team ~= game.Players.LocalPlayer.Team and v.Character.Humanoid.Health >= neededHealth then
                    local loopAmount = math.floor(v.Character.Humanoid.Health / getLeastDamage())

                    for i = 1, loopAmount do
                        damagePlayer(v)
                    end
                end
            end
        end,
        DoubleClick = false,
        Tooltip = 'Same as loop but a button'
    })

    blatantBoxDev:AddButton({
        Text = 'Weaken Player',
        Func = function()
            local neededHealth = (getLeastDamage() + 1)

            if weakenPlayer then
                for i,v in pairs(game.Players:GetChildren()) do
                    if v.Character and v.Character:FindFirstChild('HumanoidRootPart') and v.Team ~= game.Players.LocalPlayer.Team and v.Character.Humanoid.Health >= neededHealth and v == weakenPlayer then
                        local loopAmount = math.floor(v.Character.Humanoid.Health / getLeastDamage())
                        --getsenv(game.Players.LocalPlayer.Character.ACS_Client.ACS_Framework).Shoot()

                        for i = 1, loopAmount do
                            damagePlayer(v)
                        end
                    end
                end
            else
                local notif = Notification.new("warning", "Weaken Player", 'Select a player to weaken')
                notif:deleteTimeout(2)
            end
        end,
        DoubleClick = false,
        Tooltip = 'Weaken a specific player'
    })

    blatantBoxDev:AddDropdown('weakenDropDown', {
        Values = {unpack(plrs)},
        Default = 0,
        Multi = false,
    
        Text = 'Select Player to Weaken',
        Tooltip = 'Select a single player from the opposite team to weaken',
    
        Callback = function(Value)
            for i,v in pairs(game.Players:GetChildren()) do
                if v.DisplayName == Value then
                    getgenv().weakenPlayer = v
                end
            end
        end
    })
end

blatantBoxRight:AddDropdown('playerToKillDropDown', {
    Values = {unpack(plrs)},
    Default = 0,
    Multi = false,

    Text = 'Select Player to Kill',
    Tooltip = 'Select a single player from the opposite team to kill',

    Callback = function(Value)
        for i,v in pairs(game.Players:GetChildren()) do
            if v.DisplayName == Value then
                playerToKill = v    
            end
        end
    end
})

blatantBoxRight:AddDropdown('killWeaponDropDown', {
    Values = {unpack(killWeapons)},
    Default = 0,
    Multi = false,

    Text = 'Weapon for Killing',
    Tooltip = 'Select a weapon from your inventory to kill players with',

    Callback = function(Value)
        weapontype = Value
    end
})

--[[

blatantBoxRight:AddInput('distanceTextBox', {
    Default = 2500,
    Numeric = true,
    Finished = true,

    Text = 'Kill Distance',
    Tooltip = 'The number that appears in the kill feed showing how far you killed them from',

    Placeholder = 'penis',

    Callback = function(value)
        if tonumber(value) >= maxDistance then
            local notif = Notification.new("info", "INFO", "Value must be lower than "..tostring(maxDistance))
            notif:deleteTimeout(2)
            getgenv().distance = maxDistance
        else
            getgenv().distance = tonumber(value)
        end
    end
})

blatantBoxRight:AddDropdown('destroyVehicleDropDown', {
    Values = {'Both','Car','Heli'},
    Default = 1,
    Multi = false,

    Text = 'Destoy Vehicle Type',
    Tooltip = 'Select which type of vehicle to destroy, or destroy both',

    Callback = function(Value)
        vehicletype = Value
    end
})

blatantBoxRight:AddDivider()

]]--

blatantBoxRight:AddSlider('killAuraSlider', {
    Text = 'Kill Aura Range',
    Default = 15,
    Min = 15,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Tooltip = 'How far the kill aura works from',

    Callback = function(Value)
        killAuraRange = Value
    end
})

--[[

blatantBoxRight:AddSlider('vehicleAuraSlider', {
    Text = 'Vehicle Aura Range',
    Default = 15,
    Min = 15,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Tooltip = 'How far the vehicle aura works from',

    Callback = function(Value)
        vehicleAuraRange = Value
    end
})

]]--

local blatantLabel = Tabs.Blatant:AddLeftGroupbox('Blatant Tab Info');
blatantLabel:AddLabel('Tab for blatant settings and what not\nidk what to write, this tab isnt what it used to be', true)

local discordButton = infoBoxLeft:AddButton({
    Text = 'Copy Discord Invite',
    Func = function()
        setclipboard('https://discord.gg/nM9B3ysEWz')
    end,
    DoubleClick = false,
    Tooltip = 'Join the Discord Server for update news and other stuff please im begging you'
})

local youtubeButton = infoBoxLeft:AddButton({
    Text = 'Copy Youtbe Channel Link',
    Func = function()
        setclipboard('https://www.youtube.com/@ElEmDeeScripts')
    end,
    DoubleClick = false,
    Tooltip = 'Please watch and subscribe to my channel please im begging i need this'
})

local infoLabel = Tabs.Info:AddLeftGroupbox('General Information');
infoLabel:AddLabel('Thank you for using my Script!\n\nI will use this box as a way to communicate with you guys\n\nUpdates will slow down as a result of byfron, sorry\n\nThe new UI is cool, right', true)

task.spawn(function()
    while not unloaded do
        refreshweapontable()
        Options.gunModDropDown:SetValues(weapons)
        task.wait(1)
    end
end)

task.spawn(function()
    while not unloaded do
        refreshweapontable2()
        Options.killWeaponDropDown:SetValues(killWeapons)
        task.wait(1)
    end
end)

task.spawn(function()
    while not unloaded do
        refreshhiddenweapontable()
        Options.hiddenWeaponDropDown:SetValues(hiddenweapons)
        task.wait(1)
    end
end)

task.spawn(function()
    while not unloaded do
        refreshplrtable()
        Options.playerToKillDropDown:SetValues(plrs)
        if Owner then
            Options.weakenDropDown:SetValues(plrs)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while not unloaded do
        refreshallplrstable()
        Options.tpPlayerDropDown:SetValues(allPlrs)
        Options.spectateDropDown:SetValues(allPlrs)
        task.wait(1)
    end
end)

task.spawn(function()
    while not unloaded do
        refreshobjectivestable()
        Options.objectiveTeleportDropDown:SetValues(objectives)
        task.wait(1)
    end
end)

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
FrameCounter = FrameCounter + 1;

if (tick() - FrameTimer) >= 1 then
    FPS = FrameCounter;
    FrameTimer = tick();
    FrameCounter = 0;
end;

Library:SetWatermark(('ElEmDee Hub | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
	WatermarkConnection:Disconnect()

	print('Unloaded!')
    Library.Unloaded = true
    unloaded = true
    Sense.Unload()

    gunESPEnabled = false
    gunEsp()

    chamsEnabled = false

    for i,v in pairs(workspace.Characters:GetDescendants()) do
        if v.Name == 'esp' then
            v:Destroy()
        end
    end
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind 

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('ElEmDeeHub')
SaveManager:SetFolder('ElEmDeeHub/mecs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
Sense.Load()
