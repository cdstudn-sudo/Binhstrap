local FFlags_Default = {
    ["DebugLimitMinTextureResolutionWhenSkipMips"] = "2147483647",
    ["DoNotSkipMipsBasedOnSystemMemoryPS"] = "True",
    ["TM2SkipMipsForUnstreamable2"] = "True",
    ["RenderUseTextureManager224"] = "False",
    ["DebugTextureManagerSkipMips"] = "8",
    ["EnablePowerTraceModule"] = "True",
    ["DisablePostFx"] = "True",
    ["FIntCameraMaxZoomDistance"] = "120",
    ["IncludePowerSaverMode"] = "True",
    ["DebugFRMQualityLevelOverride"] = "1",
    ["DFIntDebugDynamicRenderKiloPixels"] = "2000",
    ["DebugDisplayFPS"] = "True",
    ["DFIntDebugFRMQualityLevelOverride"] = "1",
    ["FFlagRenderNoLowFrmBloom"] = "False",
    ["FLogNetwork"] = "7",
    ["FFlagRenderNoParticleEmitter"] = "True",
    ["FFlagDisableParticleEmitter"] = "True",
    ["FIntRenderParticleEmitterMaxCount"] = "0",
    ["FFlagRenderNoTrail"] = "True",
    ["FFlagRenderNoBeam"] = "True",
    ["FFlagRenderNoSmoke"] = "True",
    ["FFlagRenderNoFire"] = "True",
    ["FFlagRenderNoSparkles"] = "True",
    ["FFlagRenderNoExplosion"] = "True",
    ["FFlagRenderNoDecal"] = "True",
    ["FFlagRenderNoTexture"] = "True",
    ["FFlagRenderNoHighlight"] = "True",
    ["FFlagDisableTextures"] = "True",
    ["FFlagDisableDecals"] = "True",
    ["FFlagDisableParticle"] = "True",
    ["FFlagDisableTrails"] = "True",
    ["DFIntParticleEmitterMaxCount"] = "0",
    ["DFIntTrailMaxCount"] = "0",
    ["DFIntBeamMaxCount"] = "0",
    ["DebugSkyGray"] = "True",
    ["FIntRenderShadowIntensity"] = "0",
    ["DFIntTaskSchedulerTargetFps"] = "99999999",
    ["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
    ["FFlagGameBasicSettingsFramerateCap5"] = "True",
    ["FFlagTaskSchedulerBlockingWait"] = "True",
}

local function applyFlags(tbl)
    local n = 0
    if setfflag then
        for k, v in pairs(tbl) do
            if pcall(setfflag, k, tostring(v)) then n = n + 1 end
        end
    end
    if n == 0 and getrawmetatable and setreadonly and newcclosure then
        pcall(function()
            local mt = getrawmetatable(game)
            if mt and mt.__index then
                local oldIndex = mt.__index
                setreadonly(mt, false)
                mt.__index = newcclosure(function(self, key)
                    if tbl[key] ~= nil then
                        local v = tbl[key]
                        if v == "True" then return true end
                        if v == "False" then return false end
                        return tonumber(v) or v
                    end
                    return oldIndex(self, key)
                end)
                setreadonly(mt, true)
                for _ in pairs(tbl) do n = n + 1 end
            end
        end)
    end
    if writefile then
        pcall(function()
            writefile("ClientAppSettings.json", game:GetService("HttpService"):JSONEncode(tbl))
        end)
    end
    if setfpscap then pcall(setfpscap, 99999999) end
    if setfps then pcall(setfps, 99999999) end
    return n
end

local function removeAllEffects()
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")
                or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles")
                or v:IsA("Explosion") or v:IsA("Highlight") then
                v.Enabled = false
                pcall(function() v:Destroy() end)
            end
            if v:IsA("Texture") or v:IsA("Decal") then
                v.Transparency = 1
                pcall(function() v:Destroy() end)
            end
            if v:IsA("PostEffect") then v.Enabled = false end
            if v:IsA("Sound") then v.Volume = 0 end
        end
    end)
    pcall(function()
        local L = game:GetService("Lighting")
        L.GlobalShadows = false
        L.FogEnd = 100000
        L.Brightness = 1
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
        for _, v in ipairs(L:GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
            if v:IsA("Atmosphere") then v.Density = 0 end
            if v:IsA("Sky") then
                v.SkyboxBk = "" v.SkyboxDn = "" v.SkyboxFt = ""
                v.SkyboxLf = "" v.SkyboxRt = "" v.SkyboxUp = ""
                v.StarCount = 0
            end
        end
    end)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

local function removeAllGraphics()
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("Part") then
                if v.Name:lower():match("decor") or v.Name:lower():match("tree")
                    or v.Name:lower():match("grass") or v.Name:lower():match("bush")
                    or v.Name:lower():match("flower") or v.Name:lower():match("rock") then
                    v.Transparency = 1
                    v.CanCollide = false
                    v.CanTouch = false
                    v.CanQuery = false
                end
            end
            if v:IsA("Terrain") then
                v.Decoration = false
            end
        end
    end)
end

local function removeJunkObjects()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") or v:IsA("Folder") then
                if v.Name:lower():match("junk") or v.Name:lower():match("trash")
                    or v.Name:lower():match("debris") or v.Name:lower():match("garbage") then
                    pcall(function() v:Destroy() end)
                end
            end
            if v:IsA("Part") or v:IsA("MeshPart") then
                if v.Name:lower():match("junk") or v.Name:lower():match("trash")
                    or v.Name:lower():match("r%C3%A1c") then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end)
end

local function removeUnreachableObjects()
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(char) then
                if v.CanCollide and v.Transparency < 1 then
                    if v.Name:lower():match("crate") or v.Name:lower():match("box")
                        or v.Name:lower():match("barrel") or v.Name:lower():match("fence") then
                        v.CanCollide = false
                        v.CanTouch = false
                        v.Transparency = 1
                    end
                end
            end
        end
    end)
end

local function playMusic()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.Name = "BINHSTRAP_Music"
        sound.SoundId = "rbxassetid://1837879082"
        sound.Volume = 1
        sound.Looped = true
        sound.Parent = game:GetService("SoundService")
        sound:Play()
    end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BINHSTRAP_" .. tostring(math.random(1000, 9999))
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 300)
main.Position = UDim2.new(0.5, -120, 0.4, -150)
main.BackgroundColor3 = Color3.fromRGB(30, 15, 45)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 10)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(160, 80, 220)
ms.Thickness = 2
ms.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(45, 20, 65)
title.Text = "  BINHSTRAP"
title.TextColor3 = Color3.fromRGB(200, 140, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 10)
tc.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(140, 50, 160)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.Parent = title

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = closeBtn

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.new(0, 10, 0, 42)
status.BackgroundTransparency = 1
status.Text = "Status: not running"
status.TextColor3 = Color3.fromRGB(180, 160, 200)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Code
status.TextSize = 10
status.Parent = main

local function makeButton(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local applyBtn = makeButton("APPLY ALL", 72, Color3.fromRGB(120, 60, 180), function()
    local n = applyFlags(FFlags_Default)
    removeAllEffects()
    removeAllGraphics()
    removeJunkObjects()
    removeUnreachableObjects()
    status.Text = "Applied " .. n .. " flags + clean all"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "BINHSTRAP",
        Text = "Applied " .. n .. " flags + clean. Rejoin!",
        Duration = 5,
    })
end)

local fxBtn = makeButton("REMOVE EFFECTS", 106, Color3.fromRGB(140, 60, 60), function()
    removeAllEffects()
    status.Text = "Effects removed"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
end)

local gfxBtn = makeButton("REMOVE GRAPHICS", 140, Color3.fromRGB(140, 100, 60), function()
    removeAllGraphics()
    status.Text = "Graphics removed"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
end)

local junkBtn = makeButton("REMOVE JUNK", 174, Color3.fromRGB(100, 60, 140), function()
    removeJunkObjects()
    removeUnreachableObjects()
    status.Text = "Junk removed"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
end)

local fpsBtn = makeButton("UNLOCK FPS", 208, Color3.fromRGB(60, 100, 180), function()
    if setfpscap then pcall(setfpscap, 99999999) end
    if setfps then pcall(setfps, 99999999) end
    pcall(setfflag, "DFIntTaskSchedulerTargetFps", "99999999")
    status.Text = "FPS unlocked"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
end)

local rejoinBtn = makeButton("REJOIN", 242, Color3.fromRGB(80, 30, 60), function()
    status.Text = "Rejoining..."
    task.wait(0.3)
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

playMusic()

task.spawn(function()
    while task.wait(2) do
        removeAllEffects()
    end
end)

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    removeAllEffects()
end)

print("[BINHSTRAP] Loaded. RightShift toggle.")
