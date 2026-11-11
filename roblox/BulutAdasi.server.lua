-- Bulut Adasi: drop this Script into ServerScriptService in a new Roblox place.
-- The map, checkpoints, crystals, scoreboard, and finish portal are built at runtime.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

Workspace.FallenPartsDestroyHeight = -80
local previous = Workspace:FindFirstChild("BulutAdasi")
if previous then previous:Destroy() end
local map = Instance.new("Folder")
map.Name = "BulutAdasi"
map.Parent = Workspace

local palette = {
    Color3.fromRGB(89, 217, 177), Color3.fromRGB(119, 164, 255),
    Color3.fromRGB(255, 133, 195), Color3.fromRGB(93, 220, 207),
    Color3.fromRGB(164, 139, 255), Color3.fromRGB(255, 191, 111),
    Color3.fromRGB(112, 231, 185),
}
local levels = {
    {x=0, z=0, w=18, d=18, y=12, kind="start"},
    {x=2, z=-18, w=10, d=10, y=13},
    {x=-4, z=-31, w=9, d=9, y=15},
    {x=4, z=-44, w=10, d=10, y=17, checkpoint=true},
    {x=-4, z=-57, w=9, d=9, y=19},
    {x=3, z=-70, w=10, d=10, y=21, checkpoint=true},
    {x=0, z=-85, w=16, d=16, y=23, finish=true},
}
local function part(name, size, cf, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or map
    return p
end

local function addSign(parent, text, color)
    local board = part("Wayfinding", Vector3.new(10, 3, 0.35), parent.CFrame * CFrame.new(0, 5, 5), Color3.fromRGB(26, 38, 72), Enum.Material.SmoothPlastic)
    board.CanCollide = false
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.CanvasSize = Vector2.new(500, 150)
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local spawnPoints = {}
for i, level in ipairs(levels) do
    local top = part("CloudPlatform_" .. i, Vector3.new(level.w, 2, level.d), CFrame.new(level.x, level.y, level.z), palette[i], Enum.Material.SmoothPlastic)
    top:SetAttribute("LevelIndex", i)
    part("GlowEdge_" .. i, Vector3.new(level.w - 0.35, 0.16, level.d - 0.35), CFrame.new(level.x, level.y + 1.08, level.z), palette[i], Enum.Material.Neon).CanCollide = false
    if i == 1 then addSign(top, "BULUT ADASI  •  KRİSTALLERİ TOPLA", Color3.fromRGB(117, 245, 200)) end

    if level.checkpoint or level.kind == "start" then
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = level.kind == "start" and "StartSpawn" or "Checkpoint_" .. i
        spawn.Size = Vector3.new(5, 0.4, 5)
        spawn.CFrame = CFrame.new(level.x, level.y + 1.25, level.z)
        spawn.Anchored = true
        spawn.Transparency = 1
        spawn.CanCollide = false
        spawn.Neutral = true
        spawn.Duration = 0
        spawn.Parent = map
        spawnPoints[i] = spawn
    end
    if level.checkpoint then
        local marker = part("CheckpointGlow", Vector3.new(6, 0.22, 6), CFrame.new(level.x, level.y + 1.2, level.z), Color3.fromRGB(183, 255, 236), Enum.Material.Neon)
        marker.Shape = Enum.PartType.Cylinder
        marker.CanCollide = false
    end
end

local crystalCount = 6
local crystalLocations = {
    {2, -18, 15}, {-4, -31, 17}, {4, -44, 19},
    {-4, -57, 21}, {3, -70, 23}, {0, -85, 25},
}
local collectedByPlayer = {}
local function setupPlayer(player)
    collectedByPlayer[player] = {}
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local crystals = Instance.new("IntValue")
    crystals.Name = "Kristal"
    crystals.Value = 0
    crystals.Parent = stats
    local falls = Instance.new("IntValue")
    falls.Name = "Dusus"
    falls.Value = 0
    falls.Parent = stats
    player.RespawnLocation = spawnPoints[1]
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.Died:Connect(function() falls.Value += 1 end)
        end
    end)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) collectedByPlayer[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

for index, point in ipairs(crystalLocations) do
    local crystal = part("StarCrystal_" .. index, Vector3.new(2.2, 2.2, 2.2), CFrame.new(point[1], point[3], point[2]) * CFrame.Angles(math.rad(45), math.rad(45), math.rad(45)), Color3.fromRGB(255, 231, 120), Enum.Material.Neon)
    crystal.Shape = Enum.PartType.Block
    crystal.CanCollide = false
    crystal:SetAttribute("CrystalIndex", index)
    local light = Instance.new("PointLight")
    light.Color = crystal.Color
    light.Brightness = 1.3
    light.Range = 9
    light.Parent = crystal
    crystal.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if not player or collectedByPlayer[player][index] then return end
        collectedByPlayer[player][index] = true
        player.leaderstats.Kristal.Value += 1
    end)
end

for index, level in ipairs(levels) do
    if level.checkpoint then
        local platform = map:FindFirstChild("CloudPlatform_" .. index)
        platform.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if player and player.RespawnLocation ~= spawnPoints[index] then
                player.RespawnLocation = spawnPoints[index]
            end
        end)
    end
end

local finish = levels[#levels]
local portalFolder = Instance.new("Folder")
portalFolder.Name = "CloudPortal"
portalFolder.Parent = map
for i = 1, 12 do
    local angle = (i / 12) * math.pi * 2
    local piece = part("PortalRing", Vector3.new(0.65, 0.65, 0.65), CFrame.new(finish.x + math.cos(angle) * 3, finish.y + 5 + math.sin(angle) * 5, finish.z - 2), Color3.fromRGB(112, 255, 219), Enum.Material.Neon, portalFolder)
    piece.Shape = Enum.PartType.Ball
    piece.CanCollide = false
end
local trigger = part("PortalTrigger", Vector3.new(7, 9, 3), CFrame.new(finish.x, finish.y + 5, finish.z - 2), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, portalFolder)
trigger.Transparency = 1
trigger.CanCollide = false
local finishDebounce = {}
trigger.Touched:Connect(function(hit)
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player or finishDebounce[player] then return end
    if player.leaderstats.Kristal.Value < crystalCount then return end
    finishDebounce[player] = true
    local message = Instance.new("Message")
    message.Text = "Bulutların şampiyonu! " .. player.DisplayName .. " adayı tamamladı!"
    message.Parent = Workspace
    task.delay(4, function() message:Destroy(); finishDebounce[player] = nil end)
end)

-- A few decorative clouds make the floating route readable from above.
for i = 1, 18 do
    local z = -i * 5
    local x = math.sin(i * 2.4) * 12
    local cloud = part("CloudPuff", Vector3.new(5, 2, 4), CFrame.new(x, 2 + math.sin(i) * 2, z), Color3.fromRGB(218, 234, 255), Enum.Material.SmoothPlastic)
    cloud.Shape = Enum.PartType.Ball
    cloud.Transparency = 0.22
    cloud.CanCollide = false
end
