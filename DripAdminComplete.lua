--// Drip Admin COMPLETO - Arceus X Neo
--// BaseScripterTv Studios
--// VERSÃO INTEGRADA - TODAS FUNCIONALIDADES

print("=" .. string.rep("=", 70))
print("🎮 Drip Admin - Arceus X Neo (VERSÃO COMPLETA)")
print("=" .. string.rep("=", 70))

--// SERVICES
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// VARIÁVEIS ESSENCIAIS PRIMEIRO
local OwnerUserId = 3552133515
local IsOwner = LocalPlayer.UserId == OwnerUserId

--// FUNÇÕES DE VALIDAÇÃO (INTEGRADAS)
local function IsValidPlayer(player)
    if not player then return false end
    if typeof(player) ~= "Instance" then return false end
    if not player:IsA("Player") then return false end
    if player.Parent == nil then return false end
    return true
end

local function IsValidInstance(obj)
    return obj and typeof(obj) == "Instance" and obj.Parent ~= nil
end

local function SafeDestroy(obj)
    if IsValidInstance(obj) then
        pcall(function()
            obj:Destroy()
        end)
        return true
    end
    return false
end

--// VERIFICAÇÃO INICIAL CRÍTICA
if not LocalPlayer or not IsValidPlayer(LocalPlayer) then
    warn("❌ LocalPlayer inválido ou não encontrado!")
    return
end

--// WHITELIST SIMPLES PARA VERIFICAÇÃO INICIAL
local WhitelistSimple = {
    [3552133515] = true,  -- Marcosagx39
    [8479271135] = true   -- SOUxz_002
}

local IsWhitelistedSimple = WhitelistSimple[LocalPlayer.UserId] == true

if not IsWhitelistedSimple then
    warn("=" .. string.rep("=", 50))
    warn("❌ ACESSO NEGADO!")
    warn("👤 Jogador: " .. LocalPlayer.Name)
    warn("🔢 UserId: " .. LocalPlayer.UserId)
    warn("ℹ️  Você não está na whitelist")
    warn("=" .. string.rep("=", 50))
    
    StarterGui:SetCore("SendNotification", {
        Title = "❌ ACESSO NEGADO",
        Text = "Você não está na whitelist",
        Duration = 5
    })
    return
end

print("✅ Whitelist verificada com sucesso!")

--// LOG DE EXECUÇÃO
local ExecutionLog = {
    Time = os.date("%d/%m/%Y %H:%M:%S"),
    Player = LocalPlayer.Name,
    UserId = LocalPlayer.UserId,
    AccountAge = LocalPlayer.AccountAge
}

local function SendExecutionLog()
    print("📋 LOG DE EXECUÇÃO:")
    print("⏰ Hora: " .. ExecutionLog.Time)
    print("👤 Jogador: " .. ExecutionLog.Player)
    print("🔢 UserId: " .. ExecutionLog.UserId)
    print("📅 Idade da Conta: " .. ExecutionLog.AccountAge .. " dias")
    print("📍 Server: " .. game.JobId)
end

SendExecutionLog()

--// VARIÁVEIS GLOBAIS DO SISTEMA
local SelectedPlayer = nil
local JailedPlayers = {}
local FrozenPlayers = {}
local AdminEnabled = true
local NoclipActive = false
local NoclipConnection
local stopTagLoop = false
local tagUpdateThread

--// WHITELIST SISTEMA COMPLETO (COMBINADO)
local Whitelist = {
    [3552133515] = {
        Nome = "Marcosagx39", 
        Permitido = true,
        Rank = "Owner",
        Permissions = {"all"},
        Tag = "👑 DONO",
        Power = 100,
        DataRegistro = "2024",
        UserId = 3552133515
    },
    [8479271135] = {
        Nome = "SOUxz_002", 
        Permitido = true,
        Rank = "Admin",
        Permissions = {"basic", "moderate", "admin"},
        Tag = "🛡️ ADMIN",
        Power = 80,
        DataRegistro = "2024",
        UserId = 8479271135
    }
}

local MyData = Whitelist[LocalPlayer.UserId]

if not MyData then
    print("\n❌ ACESSO NEGADO!")
    print("Você não está na whitelist")
    
    StarterGui:SetCore("SendNotification", {
        Title = "❌ ACESSO NEGADO",
        Text = "Você não está na whitelist",
        Duration = 5
    })
    return
end

print("\n✅ ACESSO PERMITIDO!")
print("🎖️  Rank: " .. MyData.Rank)
print("👑 Tag: " .. MyData.Tag)
print("⚡ Power: " .. MyData.Power)

--// BLACKLIST MANAGER
local Blacklist = {
    [10320799679] = {
        Nome = "LiperLit", 
        Motivo = "Test", 
        UserId = 10320799679,
        Data = os.date("%d/%m/%Y %H:%M:%S")
    }
}

local BlacklistManager = {
    IsBlacklisted = function(userId)
        if type(userId) == "string" then
            userId = tonumber(userId) or 0
        end
        return Blacklist[userId] ~= nil
    end,

    GetBlacklistInfo = function(userId)
        if type(userId) == "string" then
            userId = tonumber(userId) or 0
        end
        return Blacklist[userId]
    end,

    AddToBlacklist = function(userId, playerName, motivo)
        if type(userId) == "string" then
            userId = tonumber(userId) or 0
        end

        if userId > 0 then
            Blacklist[userId] = {
                Nome = playerName,
                Motivo = motivo or "Banido por staff",
                Data = os.date("%d/%m/%Y %H:%M:%S"),
                Staff = LocalPlayer.Name,
                UserId = userId
            }
            return true
        end
        return false
    end
}

--// SISTEMA DE PERMISSÕES HIERÁRQUICAS
local PermissionSystem = {
    PermissionLevels = {
        NONE = 0,
        HELPER = 1,
        MODERATOR = 2,
        ADMIN = 3,
        OWNER = 4
    },

    RankLevels = {
        Helper = 1,
        Moderator = 2,
        Admin = 3,
        Owner = 4
    },

    HasRankPermission = function(userId, requiredRank)
        local data = Whitelist[userId]
        if not data or not data.Permitido then
            return false
        end

        local userLevel = PermissionSystem.RankLevels[data.Rank] or 0
        local requiredLevel = PermissionSystem.RankLevels[requiredRank] or 0

        return userLevel >= requiredLevel
    end
}

--// FUNÇÕES AUXILIARES
local function GetPlayerByName(name)
    return Players:FindFirstChild(name)
end

local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Notify(title, message, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 3
    })
end

--// FUNÇÃO SENDCHAT (INTEGRADA)
local function SendChat(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("TextChannels")
            if channel then
                local rbxGeneral = channel:FindFirstChild("RBXGeneral")
                if rbxGeneral then
                    rbxGeneral:SendAsync(msg)
                end
            end
        else
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents then
                local sayMessage = chatEvents:FindFirstChild("SayMessageRequest")
                if sayMessage then
                    sayMessage:FireServer(msg, "All")
                end
            end
        end
    end)
end

--// FUNÇÕES PRINCIPAIS DO DRIP (COM VALIDAÇÕES)

-- 1. BRING PLAYER (Vai até o jogador)
local function BringPlayer(targetName)
    if not targetName or type(targetName) ~= "string" then
        warn("⚠️ BringPlayer: Nome inválido")
        return false
    end

    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then
        warn("⚠️ BringPlayer: Jogador não encontrado - " .. targetName)
        return false
    end

    local targetHRP = GetHRP(target)
    local myHRP = GetHRP(LocalPlayer)

    if targetHRP and myHRP then
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        Notify("✅ Bring", "Você foi até " .. targetName, 2)
        return true
    end
    return false
end

-- 2. BRING TO ME (INTEGRADA COM VALIDAÇÕES)
local function BringToMe(targetName)
    if not targetName or type(targetName) ~= "string" then
        warn("⚠️ BringToMe: Nome inválido")
        return false
    end

    local target = Players:FindFirstChild(targetName)
    if not IsValidPlayer(target) then
        warn("⚠️ BringToMe: Jogador não encontrado - " .. tostring(targetName))
        return false
    end

    local targetChar = target.Character
    local myChar = LocalPlayer.Character

    if not targetChar then
        Notify("⚠️ Character não carregado", targetName .. " não tem character", 2)
        return false
    end

    if not myChar then
        Notify("⚠️ Seu character não carregado", "Aguarde seu character carregar", 2)
        return false
    end

    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")

    if not targetHRP or not myHRP then
        warn("⚠️ BringToMe: HumanoidRootPart não encontrado")
        return false
    end

    targetHRP.CFrame = myHRP.CFrame + Vector3.new(0, 3, 0)
    Notify("✅ BringToMe", targetName .. " trazido para você", 2)
    return true
end

-- 3. FREEZE PLAYER
local function FreezePlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local humanoid = GetHumanoid(target)
    if humanoid then
        FrozenPlayers[target] = {
            WalkSpeed = humanoid.WalkSpeed,
            JumpPower = humanoid.JumpPower
        }
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        Notify("❄️ Freeze", targetName .. " congelado", 2)
        return true
    end
    return false
end

-- 4. UNFREEZE PLAYER
local function UnfreezePlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local humanoid = GetHumanoid(target)
    if humanoid and FrozenPlayers[target] then
        humanoid.WalkSpeed = FrozenPlayers[target].WalkSpeed or 16
        humanoid.JumpPower = FrozenPlayers[target].JumpPower or 50
        FrozenPlayers[target] = nil
        Notify("🔥 Unfreeze", targetName .. " descongelado", 2)
        return true
    end
    return false
end

-- 5. JAIL PLAYER (Sistema de prisão)
local function JailPlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    if JailedPlayers[target] then
        if JailedPlayers[target].Model then
            SafeDestroy(JailedPlayers[target].Model)
        end
        JailedPlayers[target] = nil
        Notify("🚪 Unjail", targetName .. " solto da prisão", 2)
        return true
    end
    
    local hrp = GetHRP(target)
    if not hrp then return false end
    
    local jailModel = Instance.new("Model")
    jailModel.Name = "DripJail_" .. target.Name
    
    local size = Vector3.new(10, 10, 10)
    local thickness = 1
    
    local function CreateWall(pos, size)
        local part = Instance.new("Part")
        part.Size = size
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 0.3
        part.Color = Color3.fromRGB(100, 0, 200)
        part.Material = Enum.Material.Neon
        part.CFrame = hrp.CFrame * CFrame.new(pos)
        part.Parent = jailModel
        return part
    end
    
    CreateWall(Vector3.new(0, 0, -size.Z/2), Vector3.new(size.X, size.Y, thickness))
    CreateWall(Vector3.new(0, 0, size.Z/2), Vector3.new(size.X, size.Y, thickness))
    CreateWall(Vector3.new(-size.X/2, 0, 0), Vector3.new(thickness, size.Y, size.Z))
    CreateWall(Vector3.new(size.X/2, 0, 0), Vector3.new(thickness, size.Y, size.Z))
    CreateWall(Vector3.new(0, size.Y/2, 0), Vector3.new(size.X, thickness, size.Z))
    CreateWall(Vector3.new(0, -size.Y/2, 0), Vector3.new(size.X, thickness, size.Z))
    
    jailModel.Parent = Workspace
    JailedPlayers[target] = {Model = jailModel, Position = hrp.Position}
    
    Notify("🔒 Jail", targetName .. " preso", 2)
    return true
end

-- 6. UNJAIL PLAYER
local function UnjailPlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    if JailedPlayers[target] then
        if JailedPlayers[target].Model then
            SafeDestroy(JailedPlayers[target].Model)
        end
        JailedPlayers[target] = nil
        Notify("🚪 Unjail", targetName .. " solto da prisão", 2)
        return true
    end
    return false
end

-- 7. EXPLODE PLAYER
local function ExplodePlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local hrp = GetHRP(target)
    if not hrp then return false end
    
    local explosion = Instance.new("Explosion")
    explosion.Position = hrp.Position
    explosion.BlastRadius = 15
    explosion.BlastPressure = 100000
    explosion.Parent = Workspace
    
    for i = 1, 10 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.5, 0.5, 0.5)
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromHSV(i/10, 1, 1)
        part.CFrame = hrp.CFrame
        part.Velocity = Vector3.new(
            math.random(-50, 50),
            math.random(20, 50),
            math.random(-50, 50)
        )
        part.Parent = Workspace
        game:GetService("Debris"):AddItem(part, 2)
    end
    
    Notify("💥 Explode", targetName .. " explodido", 2)
    return true
end

-- 8. KILL PLAYER
local function KillPlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local humanoid = GetHumanoid(target)
    if humanoid then
        humanoid.Health = 0
        Notify("💀 Kill", targetName .. " morto", 2)
        return true
    end
    return false
end

-- 9. KICK PLAYER (via chat integrada)
local function KickPlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    SendChat("/kick " .. targetName)
    Notify("👢 Kick", targetName .. " kickado", 2)
    return true
end

-- 10. COOLKID AVATAR
local function CoolkidAvatar(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local character = GetCharacter(target)
    if not character then return false end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.BrickColor = BrickColor.new("Bright violet")
            part.Material = Enum.Material.Neon
        end
    end
    
    Notify("🌈 Coolkid", "Avatar de " .. targetName .. " colorido", 2)
    return true
end

-- 11. JUMPSCARE
local function JumpscarePlayer(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://911847229"
    sound.Volume = 1
    sound.Parent = Workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
    
    Notify("👻 Jumpscare", targetName .. " assustado", 2)
    return true
end

-- 12. BACKROOMS
local function SendToBackrooms(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local hrp = GetHRP(target)
    if hrp then
        hrp.CFrame = CFrame.new(0, -10000, 0)
        Notify("🏚️ Backrooms", targetName .. " enviado às Backrooms", 2)
        return true
    end
    return false
end

-- 13. MESSI JUMPSCARE
local function MessiJumpscare(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9134281833"
    sound.Volume = 1
    sound.Parent = Workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 5)
    
    Notify("⚽ Messi", "Messi jumpscare em " .. targetName, 2)
    return true
end

-- 14. TP TO SPAWN
local function TPtoSpawn(targetName)
    local target = GetPlayerByName(targetName)
    if not IsValidPlayer(target) then return false end
    
    local hrp = GetHRP(target)
    if hrp then
        hrp.CFrame = CFrame.new(0, 5, 0)
        Notify("🏠 Spawn", targetName .. " teleportado para o spawn", 2)
        return true
    end
    return false
end

-- 15. NOCLIP
local function ToggleNoclip()
    NoclipActive = not NoclipActive
    
    if NoclipActive then
        print("✅ Noclip ATIVADO")
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Notify("🚫 Noclip", "Noclip ATIVADO", 2)
    else
        print("❌ Noclip DESATIVADO")
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        Notify("🚫 Noclip", "Noclip DESATIVADO", 2)
    end
end

-- 16. TOGGLE FLY (NOVA FUNÇÃO)
local FlyActive = false
local FlyConnection
local function ToggleFly()
    FlyActive = not FlyActive
    
    if FlyActive then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "DripFly"
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        end
        
        FlyConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                bodyVelocity.Velocity = Vector3.new(0, 50, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                bodyVelocity.Velocity = Vector3.new(0, -50, 0)
            end
        end)
        
        Notify("✈️ Fly", "Fly ATIVADO (Espaço=Subir, Shift=Descer)", 3)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        if LocalPlayer.Character then
            local flyPart = LocalPlayer.Character:FindFirstChild("DripFly")
            if flyPart then
                SafeDestroy(flyPart)
            end
        end
        Notify("✈️ Fly", "Fly DESATIVADO", 2)
    end
end

--// FUNÇÃO GRADIENT (INTEGRADA)
local function gradient(text, startColor, endColor)
    local result = ""
    local length = #text
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end
    return result
end

--// CRIAR INTERFACE COMPLETA COM TODAS TABS
print("\n🛠️ Criando interface Drip Admin COMPLETA...")

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DripAdminArceusX_Complete"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Arredondar bordas
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Sombra/Contorno
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎮 DRIP ADMIN - " .. MyData.Tag
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Botão fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(1, 0)
CloseButtonCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    AdminEnabled = false
    Notify("🔒 Admin", "Interface fechada", 2)
end)

-- Área de conteúdo
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Tabs
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = ContentFrame

local Tabs = {"Home", "Players", "Staff", "Chat", "World", "Fun", "Settings"}
local CurrentTab = "Home"
local TabButtons = {}

-- Função para mostrar tab
local function ShowTab(tabName)
    for _, tabContent in ipairs(ContentFrame:GetChildren()) do
        if tabContent.Name == "TabContent_" .. CurrentTab then
            tabContent.Visible = false
        end
    end
    
    for btnName, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    end
    
    CurrentTab = tabName
    
    local tabContent = ContentFrame:FindFirstChild("TabContent_" .. tabName)
    if tabContent then
        tabContent.Visible = true
    end
    
    if TabButtons[tabName] then
        TabButtons[tabName].BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end

-- Criar botões de tab
for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = "Tab_" .. tabName
    TabButton.Size = UDim2.new(1 / #Tabs, 0, 1, 0)
    TabButton.Position = UDim2.new((i-1) / #Tabs, 0, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.Parent = TabsFrame
    
    if tabName == "Home" then
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
    
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 6)
    TabButtonCorner.Parent = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        ShowTab(tabName)
    end)
    
    TabButtons[tabName] = TabButton
end

-- Criar conteúdo das tabs
local function CreateTabContent(tabName)
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent_" .. tabName
    TabContent.Size = UDim2.new(1, 0, 1, -40)
    TabContent.Position = UDim2.new(0, 0, 0, 45)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    TabContent.Visible = (tabName == "Home")
    TabContent.Parent = ContentFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = TabContent
    
    return TabContent
end

-- Função para criar seção
local function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section_" .. title
    SectionFrame.Size = UDim2.new(1, -20, 0, 0)
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    SectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Position = UDim2.new(0, 10, 0, 0)
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = SectionFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, 0, 0, 30)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 16
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Position = UDim2.new(0, 15, 0, 0)
    SectionTitle.Parent = SectionFrame
    
    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "Content"
    SectionContent.Size = UDim2.new(1, 0, 0, 0)
    SectionContent.AutomaticSize = Enum.AutomaticSize.Y
    SectionContent.BackgroundTransparency = 1
    SectionContent.Position = UDim2.new(0, 0, 0, 35)
    SectionContent.Parent = SectionFrame
    
    local SectionList = Instance.new("UIListLayout")
    SectionList.Padding = UDim.new(0, 8)
    SectionList.Parent = SectionContent
    
    return SectionContent
end

-- Função para criar botão
local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = "Btn_" .. text
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(70, 70, 80)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button
    
    Button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
        task.wait(0.1)
        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
        
        if callback then
            callback()
        end
    end)
    
    return Button
end

-- Função para criar toggle
local function CreateToggle(parent, text, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle_" .. text
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Name = "Text"
    ToggleText.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.GothamMedium
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Position = UDim2.new(0, 0, 0, 0)
    ToggleText.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0, 5)
    ToggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 80)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 21, 0, 21)
    ToggleCircle.Position = defaultValue and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local toggleState = defaultValue
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        
        if toggleState then
            game:GetService("TweenService"):Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)}):Play()
            game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -26, 0, 2)}):Play()
        else
            game:GetService("TweenService"):Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
            game:GetService("TweenService"):Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
        
        if callback then
            callback(toggleState)
        end
    end)
    
    return ToggleFrame, function() return toggleState end
end

-- Função para criar input
local function CreateInput(parent, placeholder, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "Input_" .. placeholder
    InputFrame.Size = UDim2.new(1, -20, 0, 35)
    InputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    InputFrame.Parent = parent
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.Name = "TextBox"
    TextBox.Size = UDim2.new(1, -10, 1, 0)
    TextBox.Position = UDim2.new(0, 5, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.Parent = InputFrame
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback and TextBox.Text ~= "" then
            callback(TextBox.Text)
            TextBox.Text = ""
        end
    end)
    
    return InputFrame
end

-- TAB 1: HOME
local HomeTab = CreateTabContent("Home")
local HomeSection1 = CreateSection(HomeTab, "STATUS DO ADMIN")

CreateButton(HomeSection1, "👤 Nome: " .. LocalPlayer.Name, function()
    Notify("👤 Seu Nome", LocalPlayer.Name, 2)
end)

CreateButton(HomeSection1, "🎖️  Rank: " .. MyData.Rank, function()
    Notify("🎖️ Seu Rank", MyData.Rank, 2)
end)

CreateButton(HomeSection1, "👑 Tag: " .. MyData.Tag, function()
    Notify("👑 Sua Tag", MyData.Tag, 2)
end)

CreateButton(HomeSection1, "⚡ Power: " .. MyData.Power, function()
    Notify("⚡ Seu Power", tostring(MyData.Power), 2)
end)

CreateToggle(HomeSection1, "✅ Admin Ativo", true, function(state)
    AdminEnabled = state
    Notify("🔧 Admin", state and "ATIVADO" or "DESATIVADO", 2)
end)

local HomeSection2 = CreateSection(HomeTab, "LOG DE EXECUÇÃO")

CreateButton(HomeSection2, "⏰ Hora: " .. ExecutionLog.Time, function()
    Notify("⏰ Hora de Execução", ExecutionLog.Time, 3)
end)

CreateButton(HomeSection2, "🔢 UserId: " .. ExecutionLog.UserId, function()
    setclipboard(tostring(ExecutionLog.UserId))
    Notify("📋 Copiado", "UserId copiado para clipboard", 2)
end)

CreateButton(HomeSection2, "📅 Idade da Conta: " .. ExecutionLog.AccountAge .. " dias", function()
    Notify("📅 Idade da Conta", ExecutionLog.AccountAge .. " dias", 2)
end)

CreateButton(HomeSection2, "📍 Server: " .. game.JobId, function()
    setclipboard(game.JobId)
    Notify("📋 Copiado", "JobId copiado para clipboard", 2)
end)

CreateButton(HomeSection2, "📊 Mostrar Whitelist Completa", function()
    print("=" .. string.rep("=", 50))
    print("📋 WHITELIST COMPLETA:")
    print("=" .. string.rep("=", 50))

    for userId, data in pairs(Whitelist) do
        if data.Permitido then
            print("👤 " .. data.Nome .. " (ID: " .. userId .. ")")
            print("   🎖️  Rank: " .. data.Rank)
            print("   🏷️  Tag: " .. (data.Tag or "Nenhuma"))
            print("   🔑 Permissões: " .. table.concat(data.Permissions, ", "))
            print("   📅 Data: " .. data.DataRegistro)
            print("-" .. string.rep("-", 45))
        end
    end
    Notify("📋 Whitelist", "Verifique o console", 3)
end)

-- TAB 2: PLAYERS
local PlayersTab = CreateTabContent("Players")

-- Seção de seleção
local SelectSection = CreateSection(PlayersTab, "SELECIONAR JOGADOR")

local PlayerDropdown = Instance.new("TextButton")
PlayerDropdown.Name = "PlayerDropdown"
PlayerDropdown.Size = UDim2.new(1, -20, 0, 35)
PlayerDropdown.Position = UDim2.new(0, 10, 0, 0)
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
PlayerDropdown.Text = "Clique para selecionar jogador"
PlayerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerDropdown.TextSize = 14
PlayerDropdown.Font = Enum.Font.GothamMedium
PlayerDropdown.AutoButtonColor = false
PlayerDropdown.Parent = SelectSection

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = PlayerDropdown

local SelectedPlayerLabel = Instance.new("TextLabel")
SelectedPlayerLabel.Name = "SelectedPlayerLabel"
SelectedPlayerLabel.Size = UDim2.new(1, -20, 0, 30)
SelectedPlayerLabel.Position = UDim2.new(0, 10, 0, 45)
SelectedPlayerLabel.BackgroundTransparency = 1
SelectedPlayerLabel.Text = "Nenhum jogador selecionado"
SelectedPlayerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SelectedPlayerLabel.TextSize = 14
SelectedPlayerLabel.Font = Enum.Font.GothamMedium
SelectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedPlayerLabel.Parent = SelectSection

-- Atualizar lista de jogadores
local function UpdatePlayerList()
    local players = Players:GetPlayers()
    PlayerDropdown.Text = "Selecionar Jogador (" .. #players .. " online)"
    
    PlayerDropdown.MouseButton1Click:Connect(function()
        local playerNames = {}
        for _, player in ipairs(players) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        
        -- Simular dropdown
        if #playerNames > 0 then
            local randomPlayer = playerNames[math.random(1, #playerNames)]
            SelectedPlayer = randomPlayer
            SelectedPlayerLabel.Text = "Selecionado: " .. randomPlayer
            Notify("🎯 Jogador Selecionado", randomPlayer, 2)
        else
            Notify("⚠️ Sem Jogadores", "Nenhum outro jogador online", 2)
        end
    end)
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

CreateButton(SelectSection, "🎯 Selecionar a Mim Mesmo", function()
    SelectedPlayer = LocalPlayer.Name
    SelectedPlayerLabel.Text = "Selecionado: " .. LocalPlayer.Name .. " (Você)"
    Notify("🎯 Selecionado", "Você mesmo", 2)
end)

-- Seção de controle básico
local ControlSection = CreateSection(PlayersTab, "CONTROLE BÁSICO")

CreateButton(ControlSection, "🚀 Bring (Ir até jogador)", function()
    if SelectedPlayer then
        BringPlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "📥 BringToMe (Trazer para você)", function()
    if SelectedPlayer then
        BringToMe(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "❄️ Freeze Player", function()
    if SelectedPlayer then
        FreezePlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "🔥 Unfreeze Player", function()
    if SelectedPlayer then
        UnfreezePlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "🔒 Jail Player", function()
    if SelectedPlayer then
        JailPlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "🚪 Unjail Player", function()
    if SelectedPlayer then
        UnjailPlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(ControlSection, "💀 Kill Player", function()
    if SelectedPlayer then
        KillPlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

-- Seção avançada
local AdvancedSection = CreateSection(PlayersTab, "AÇÕES AVANÇADAS")

CreateButton(AdvancedSection, "💥 Explode Player", function()
    if SelectedPlayer then
        ExplodePlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(AdvancedSection, "👢 Kick Player (Chat)", function()
    if SelectedPlayer then
        KickPlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(AdvancedSection, "🌈 Coolkid Avatar", function()
    if SelectedPlayer then
        CoolkidAvatar(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(AdvancedSection, "🏠 TP to Spawn", function()
    if SelectedPlayer then
        TPtoSpawn(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

-- Toggles especiais
local TogglesSection = CreateSection(PlayersTab, "ESPECIAIS")

CreateToggle(TogglesSection, "🚫 Noclip", false, function(state)
    if state then
        ToggleNoclip()
    else
        ToggleNoclip()
    end
end)

CreateToggle(TogglesSection, "✈️ Fly", false, function(state)
    if state then
        ToggleFly()
    else
        ToggleFly()
    end
end)

-- TAB 3: STAFF (apenas para dono)
local StaffTab = CreateTabContent("Staff")
StaffTab.Visible = IsOwner

if IsOwner then
    local StaffSection1 = CreateSection(StaffTab, "GERENCIAR WHITELIST")
    
    CreateButton(StaffSection1, "📋 Ver Whitelist Completa", function()
        print("=" .. string.rep("=", 50))
        print("📋 WHITELIST GERENCIÁVEL:")
        for userId, data in pairs(Whitelist) do
            print("ID: " .. userId .. " | Nome: " .. data.Nome .. " | Rank: " .. data.Rank)
        end
        Notify("📋 Whitelist", "Verifique o console", 3)
    end)
    
    local AddInput = CreateInput(StaffSection1, "UserId,Nome,Rank (ex: 123456,Player,Helper)", function(text)
        local parts = {}
        for part in text:gmatch("[^,]+") do
            table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
        end
        
        if #parts >= 3 then
            local userId = tonumber(parts[1])
            local playerName = parts[2]
            local rank = parts[3]
            
            if userId then
                Whitelist[userId] = {
                    Nome = playerName,
                    Permitido = true,
                    Rank = rank,
                    Permissions = {"basic"},
                    Tag = "",
                    DataRegistro = os.date("%d/%m/%Y"),
                    UserId = userId,
                    Power = rank == "Owner" and 100 or rank == "Admin" and 80 or rank == "Moderator" and 60 or 40
                }
                Notify("✅ Whitelist", playerName .. " adicionado", 2)
            end
        end
    end)
    
    CreateButton(StaffSection1, "🗑️ Remover da Whitelist", function()
        if SelectedPlayer then
            local target = GetPlayerByName(SelectedPlayer)
            if target then
                Whitelist[target.UserId] = nil
                Notify("🗑️ Whitelist", SelectedPlayer .. " removido", 2)
            end
        end
    end)
    
    local StaffSection2 = CreateSection(StaffTab, "GERENCIAR BLACKLIST")
    
    CreateButton(StaffSection2, "📋 Ver Blacklist", function()
        print("=" .. string.rep("=", 50))
        print("🚫 BLACKLIST:")
        for userId, data in pairs(Blacklist) do
            print("ID: " .. userId .. " | Nome: " .. data.Nome .. " | Motivo: " .. data.Motivo)
        end
        Notify("🚫 Blacklist", "Verifique o console", 3)
    end)
    
    CreateInput(StaffSection2, "UserId,Motivo para banir", function(text)
        if IsOwner then
            local parts = {}
            for part in text:gmatch("[^,]+") do
                table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
            end
            
            if #parts >= 2 then
                local userId = tonumber(parts[1])
                local motivo = parts[2]
                
                if userId then
                    BlacklistManager.AddToBlacklist(userId, "ManualBan", motivo)
                    Notify("🚫 Blacklist", "Usuário " .. userId .. " banido", 2)
                end
            end
        end
    end)
    
    local StaffSection3 = CreateSection(StaffTab, "TAGS DE STAFF")
    
    CreateInput(StaffSection3, "UserId,NovaTag", function(text)
        if IsOwner then
            local parts = {}
            for part in text:gmatch("[^,]+") do
                table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
            end
            
            if #parts >= 2 then
                local userId = tonumber(parts[1])
                local newTag = parts[2]
                
                if userId and Whitelist[userId] then
                    Whitelist[userId].Tag = newTag
                    Notify("🏷️ Tag Atualizada", "Tag de " .. Whitelist[userId].Nome .. " atualizada", 2)
                end
            end
        end
    end)
else
    local NoAccessSection = CreateSection(StaffTab, "ACESSO RESTRITO")
    
    local NoAccessText = Instance.new("TextLabel")
    NoAccessText.Size = UDim2.new(1, -20, 0, 100)
    NoAccessText.Position = UDim2.new(0, 10, 0, 0)
    NoAccessText.BackgroundTransparency = 1
    NoAccessText.Text = "⚠️ ACESSO RESTRITO ⚠️\n\nEsta aba está disponível apenas para o DONO do script.\n\nUser ID do Dono: " .. OwnerUserId
    NoAccessText.TextColor3 = Color3.fromRGB(255, 100, 100)
    NoAccessText.TextSize = 16
    NoAccessText.Font = Enum.Font.GothamBold
    NoAccessText.TextWrapped = true
    NoAccessText.Parent = NoAccessSection
end

-- TAB 4: CHAT
local ChatTab = CreateTabContent("Chat")

local ChatSection1 = CreateSection(ChatTab, "ENVIAR MENSAGEM")

local ChatInput = CreateInput(ChatSection1, "Digite sua mensagem...", function(text)
    SendChat(text)
    Notify("💬 Chat", "Mensagem enviada: " .. text, 2)
end)

CreateButton(ChatSection1, "📢 Enviar Mensagem Teste", function()
    SendChat("🚀 Drip Admin ativo! | BaseScripterTv Studios")
    Notify("💬 Chat", "Mensagem teste enviada", 2)
end)

local ChatSection2 = CreateSection(ChatTab, "COMANDOS DE CHAT")

CreateButton(ChatSection2, "👢 Kick via Chat", function()
    if SelectedPlayer then
        SendChat("/kick " .. SelectedPlayer)
        Notify("👢 Kick", "Comando enviado para " .. SelectedPlayer, 2)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

local spamActive = false
local spamThread

CreateToggle(ChatSection2, "🔁 Spam Chat", false, function(state)
    spamActive = state
    
    if state then
        spamThread = task.spawn(function()
            while spamActive do
                SendChat("⚠️ Drip Admin - Sistema Ativo ⚠️")
                task.wait(5)
            end
        end)
        Notify("🔁 Spam", "Spam ATIVADO", 2)
    else
        if spamThread then
            task.cancel(spamThread)
        end
        Notify("🔁 Spam", "Spam DESATIVADO", 2)
    end
end)

-- TAB 5: WORLD
local WorldTab = CreateTabContent("World")

local WorldSection1 = CreateSection(WorldTab, "ILUMINAÇÃO")

CreateToggle(WorldSection1, "💡 Luz Neon", false, function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 100, 255)
        Lighting.Brightness = 2
        Notify("💡 Iluminação", "Luz Neon ATIVADA", 2)
    else
        Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        Lighting.Brightness = 1
        Notify("💡 Iluminação", "Luz Neon DESATIVADA", 2)
    end
end)

CreateButton(WorldSection1, "🌅 Resetar Iluminação", function()
    Lighting.Ambient = Color3.fromRGB(100, 100, 100)
    Lighting.Brightness = 1
    Notify("🌅 Iluminação", "Configurações resetadas", 2)
end)

local WorldSection2 = CreateSection(WorldTab, "EFEITOS VISUAIS")

CreateButton(WorldSection2, "✨ Criar Partículas", function()
    local part = Instance.new("Part")
    part.Size = Vector3.new(5, 5, 5)
    part.Position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                   LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0) or Vector3.new(0, 5, 0)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    part.Parent = Workspace
    
    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(part.Color)
    particle.Size = NumberSequence.new(0.5)
    particle.Parent = part
    
    game:GetService("Debris"):AddItem(part, 10)
    Notify("✨ Partículas", "Partículas criadas", 2)
end)

local fogValue = 0.5
local FogSliderFrame = Instance.new("Frame")
FogSliderFrame.Name = "FogSlider"
FogSliderFrame.Size = UDim2.new(1, -20, 0, 50)
FogSliderFrame.BackgroundTransparency = 1
FogSliderFrame.Parent = WorldSection2

local FogText = Instance.new("TextLabel")
FogText.Size = UDim2.new(1, 0, 0, 20)
FogText.BackgroundTransparency = 1
FogText.Text = "🌫️ Fog Density: " .. fogValue
FogText.TextColor3 = Color3.fromRGB(255, 255, 255)
FogText.TextSize = 14
FogText.Font = Enum.Font.GothamMedium
FogText.TextXAlignment = Enum.TextXAlignment.Left
FogText.Parent = FogSliderFrame

local FogSlider = Instance.new("Slider")
FogSlider.Name = "Slider"
FogSlider.Size = UDim2.new(1, 0, 0, 20)
FogSlider.Position = UDim2.new(0, 0, 0, 25)
FogSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
FogSlider.Parent = FogSliderFrame

local FogSliderCorner = Instance.new("UICorner")
FogSliderCorner.CornerRadius = UDim.new(0, 6)
FogSliderCorner.Parent = FogSlider

local FogSliderFill = Instance.new("Frame")
FogSliderFill.Name = "Fill"
FogSliderFill.Size = UDim2.new(fogValue, 0, 1, 0)
FogSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FogSliderFill.Parent = FogSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 6)
FillCorner.Parent = FogSliderFill

FogSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position.X
        local sliderPos = FogSlider.AbsolutePosition.X
        local sliderSize = FogSlider.AbsoluteSize.X
        
        local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        fogValue = relativePos
        FogSliderFill.Size = UDim2.new(fogValue, 0, 1, 0)
        FogText.Text = "🌫️ Fog Density: " .. string.format("%.2f", fogValue)
        
        Lighting.FogEnd = 1000 * fogValue
    end
end)

-- TAB 6: FUN
local FunTab = CreateTabContent("Fun")

local FunSection1 = CreateSection(FunTab, "JUMPSCARES & EFEITOS")

CreateButton(FunSection1, "👻 Jumpscare Player", function()
    if SelectedPlayer then
        JumpscarePlayer(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(FunSection1, "⚽ Messi Jumpscare", function()
    if SelectedPlayer then
        MessiJumpscare(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

CreateButton(FunSection1, "🏚️ Enviar para Backrooms", function()
    if SelectedPlayer then
        SendToBackrooms(SelectedPlayer)
    else
        Notify("⚠️ Atenção", "Selecione um jogador primeiro", 2)
    end
end)

local FunSection2 = CreateSection(FunTab, "EFEITOS ESPECIAIS")

CreateButton(FunSection2, "🎵 Tocar Som Global", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://911847229"
    sound.Volume = 1
    sound.Parent = Workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
    Notify("🎵 Som", "Som global tocado", 2)
end)

CreateButton(FunSection2, "🌈 Rainbow World", function()
    task.spawn(function()
        for i = 1, 50 do
            Lighting.Ambient = Color3.fromHSV(i/50, 1, 1)
            task.wait(0.1)
        end
    end)
    Notify("🌈 Rainbow", "Mundo colorido ativado", 2)
end)

-- TAB 7: SETTINGS
local SettingsTab = CreateTabContent("Settings")

local SettingsSection1 = CreateSection(SettingsTab, "INTERFACE")

local uiTransparent = false
CreateToggle(SettingsSection1, "🎨 UI Transparente", false, function(state)
    uiTransparent = state
    MainFrame.BackgroundTransparency = state and 0.5 or 0
    Notify("🎨 UI", state and "Transparente ATIVADO" or "Transparente DESATIVADO", 2)
end)

local themeDark = true
CreateToggle(SettingsSection1, "🌙 Tema Dark/Light", true, function(state)
    themeDark = state
    MainFrame.BackgroundColor3 = state and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(240, 240, 245)
    TitleBar.BackgroundColor3 = state and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(220, 220, 225)
    TitleText.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
    Notify("🌙 Tema", state and "Dark ATIVADO" or "Light ATIVADO", 2)
end)

local SettingsSection2 = CreateSection(SettingsTab, "CONFIGURAÇÕES")

CreateButton(SettingsSection2, "📁 Exportar Configuração", function()
    if setclipboard and HttpService then
        local configData = {
            Whitelist = Whitelist,
            Settings = {
                AdminEnabled = AdminEnabled,
                UITheme = themeDark and "Dark" or "Light",
                UITransparent = uiTransparent
            }
        }
        setclipboard(HttpService:JSONEncode(configData))
        Notify("📁 Configuração", "Configuração copiada para clipboard!", 3)
    end
end)

CreateButton(SettingsSection2, "🌐 Discord Server", function()
    if setclipboard then
        setclipboard("Discord em breve aguarde atualizações")
        Notify("🌐 Discord", "Link copiado para clipboard!", 3)
    end
end)

CreateButton(SettingsSection2, "🔄 Atualizar Lista de Jogadores", function()
    UpdatePlayerList()
    Notify("🔄 Atualizado", "Lista de jogadores atualizada", 2)
end)

CreateButton(SettingsSection2, "🚪 Sair do Admin", function()
    ScreenGui:Destroy()
    AdminEnabled = false
    Notify("👋 Adeus", "Admin desativado", 2)
end)

--// SISTEMA DE ARRASTAR A JANELA
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--// INICIALIZAÇÃO FINAL
print("\n" .. string.rep("=", 70))
print("✅ DRIP ADMIN COMPLETO INICIALIZADO!")
print("👤 Usuário: " .. LocalPlayer.Name .. " (" .. MyData.Rank .. ")")
print("📊 Tabs Disponíveis: " .. #Tabs)
print("🔧 Funcionalidades: Sistema de Staff, Blacklist, Whitelist, Permissões")
print("🎮 Comandos: Bring, Freeze, Jail, Kill, Explode, Jumpscares, e muito mais!")
print(string.rep("=", 70))

Notify("🎮 Drip Admin", "Interface carregada com sucesso!\nBem-vindo, " .. MyData.Rank .. " " .. LocalPlayer.Name, 5)

--// CONEXÕES DE ATUALIZAÇÃO
task.spawn(function()
    while ScreenGui.Parent do
        if SelectedPlayer then
            SelectedPlayerLabel.Text = "Selecionado: " .. SelectedPlayer
        end
        task.wait(1)
    end
end)
