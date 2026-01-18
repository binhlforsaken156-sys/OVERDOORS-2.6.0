--[[
OVERDOORS FULL ONE FILE (NO CONFLICT)
Entity spawn: random scheduled rooms (no % spam)
Auto c00lkiddSeek (one-time, guarded)
Give PurpleFlashlight at room 1 (one-time)
Guiding Light: ONLY ROOM 45 (ONE TIME)
Intro: IMAGE
Executor-friendly, no conflicts
by chu be te liet
]]

if getgenv().OVERDOORS_LOADED then return end
getgenv().OVERDOORS_LOADED = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local P = Players.LocalPlayer

--------------------------------------------------
-- SAFE HELPERS
--------------------------------------------------
local function safe(f) pcall(f) end

--------------------------------------------------
-- WAIT FOR GAMEDATA
--------------------------------------------------
while not (RS:FindFirstChild("GameData") and RS.GameData:FindFirstChild("LatestRoom")) do
	task.wait(0.5)
end
local LatestRoom = RS.GameData.LatestRoom

--------------------------------------------------
-- SAFE REMOTE LOADER (pcall + loadstring)
--------------------------------------------------
local function safeLoad(url)
	if not url or url == "" then return false, "no_url" end
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if not ok or not body or #body < 8 then
		return false, "fetch_failed"
	end
	local fn, err = loadstring(body)
	if not fn then
		return false, ("loadstring_error: %s"):format(tostring(err))
	end
	local suc, runErr = pcall(fn)
	if not suc then
		return false, ("runtime_error: %s"):format(tostring(runErr))
	end
	return true
end

--------------------------------------------------
-- INTRO IMAGE (NO CONFLICT)
--------------------------------------------------
task.spawn(function()
	task.wait(0.6)
	if not P or not P:FindFirstChild("PlayerGui") then return end

	local gui = Instance.new("ScreenGui", P.PlayerGui)
	gui.Name = "OVERDOORS_INTRO_IMAGE"
	gui.ResetOnSpawn = false

	local img = Instance.new("ImageLabel", gui)
	img.Size = UDim2.fromScale(1,1)
	img.BackgroundTransparency = 1
	-- image asset (use published asset id). fallback blank if inaccessible
	img.Image = "rbxassetid://93664194964832"
	img.ImageTransparency = 1
	img.ScaleType = Enum.ScaleType.Fit

	for i=1,15 do img.ImageTransparency = img.ImageTransparency - 0.06; task.wait(0.04) end
	task.wait(1.8)
	for i=1,15 do img.ImageTransparency = img.ImageTransparency + 0.06; task.wait(0.04) end

	gui:Destroy()
end)

--------------------------------------------------
-- PLAYER STATS (safe)
--------------------------------------------------
task.spawn(function()
	while task.wait(1) do
		safe(function()
			local h = P and P.Character and P.Character:FindFirstChildOfClass("Humanoid")
			if h then
				h.WalkSpeed = 20
				h.JumpPower = 38
			end
		end)
	end
end)

--------------------------------------------------
-- ENTITIES: list (remote URLs)  <- blinkcrux already added earlier
--------------------------------------------------
local ENTITY_URLS = {
	"https://raw.githubusercontent.com/Junbbinopro/Depth-entity/refs/heads/main/Depth",
	"https://raw.githubusercontent.com/Junbbinopro/Guardian-entity/refs/heads/main/Guardian",
	"https://raw.githubusercontent.com/Junbbinopro/Wh1t3/refs/heads/main/Entity",
	"https://raw.githubusercontent.com/Junbbinopro/Greed-entity/refs/heads/main/Greed",
	"https://raw.githubusercontent.com/Junbbinopro/Black-smile/refs/heads/main/Black",
	"https://raw.githubusercontent.com/Zeca130/doors-my-version-nightmareMode./refs/heads/main/Entity6", -- Hungerd
	"https://raw.githubusercontent.com/Idk-lol2/a-60aa/refs/heads/main/---======%20a-60%20agresiv%20spawner%20======---.txt",
	"https://github.com/PABMAXICHAC/doors-monsters-scripts/raw/main/blinkcrux" -- blinkcrux
}

--------------------------------------------------
-- spawnLoop helper (dedupe URLs)
--------------------------------------------------
local _addedEntityURLs = _addedEntityURLs or {}
local function spawnLoop(delayTime, url, waitRoom)
	if not url or url == "" then return end
	if _addedEntityURLs[url] then return end
	_addedEntityURLs[url] = true

	task.spawn(function()
		while true do
			task.wait(delayTime or 60)
			if waitRoom and RS and RS:FindFirstChild("GameData") and RS.GameData:FindFirstChild("LatestRoom") then
				RS.GameData.LatestRoom.Changed:Wait()
			end
			-- safe-load
			safe(function()
				safeLoad(url)
			end)
		end
	end)
end

--------------------------------------------------
-- RANDOM ROOM SCHEDULER (no %)
-- nextSpawnRoom chosen randomly (sparse, non-deterministic)
--------------------------------------------------
local lastRoom = LatestRoom.Value or 0
local function scheduleNext(fromRoom)
	return (fromRoom or lastRoom) + math.random(1, 6)
end

getgenv().OVERDOORS_nextEntityRoom = getgenv().OVERDOORS_nextEntityRoom or scheduleNext(lastRoom)
local nextSpawnRoom = getgenv().OVERDOORS_nextEntityRoom

local function spawnRandomEntity()
	-- pick a random entity URL from list
	local url = ENTITY_URLS[math.random(#ENTITY_URLS)]
	local ok, err = safeLoad(url)
	if ok then
		print("[OVERDOORS] spawned entity from", url)
	else
		warn("[OVERDOORS] failed spawn:", url, err)
	end
end

LatestRoom.Changed:Connect(function()
	local current = LatestRoom.Value or 0
	if current <= lastRoom then
		lastRoom = current
		return
	end
	lastRoom = current

	if current == nextSpawnRoom then
		task.spawn(function()
			spawnRandomEntity()
		end)
		nextSpawnRoom = current + math.random(3, 8)
		getgenv().OVERDOORS_nextEntityRoom = nextSpawnRoom
		print(("[OVERDOORS] next entity scheduled at room %d"):format(nextSpawnRoom))
	end
end)

--------------------------------------------------
-- Give PurpleFlashlight AT ROOM 1 (ONE-TIME)
--------------------------------------------------
do
	local FLASH_URL = "https://raw.githubusercontent.com/thelostw3r/Scripts/refs/heads/main/PurpleFlashlight.lua"
	if not getgenv().PURPLE_FLASHLIGHT_GIVEN then
		getgenv().PURPLE_FLASHLIGHT_GIVEN = false
	end

	LatestRoom.Changed:Connect(function()
		if LatestRoom.Value == 1 and not getgenv().PURPLE_FLASHLIGHT_GIVEN then
			getgenv().PURPLE_FLASHLIGHT_GIVEN = true
			task.spawn(function()
				local ok, err = safeLoad(FLASH_URL)
				if ok then
					pcall(function()
						if P and P:FindFirstChild("PlayerGui") then
							local g = Instance.new("ScreenGui", P.PlayerGui)
							g.Name = "PURPLE_FLASH_NOTIFY"
							g.ResetOnSpawn = false
							local lbl = Instance.new("TextLabel", g)
							lbl.Size = UDim2.fromScale(1,0.06)
							lbl.Position = UDim2.fromScale(0,0.9)
							lbl.BackgroundTransparency = 1
							lbl.TextScaled = true
							lbl.Font = Enum.Font.GothamBold
							lbl.TextColor3 = Color3.fromRGB(170,130,255)
							lbl.Text = "Purple Flashlight granted"
							Debris:AddItem(g, 2.5)
						end
					end)
				else
					warn("[OVERDOORS] PurpleFlashlight load failed:", err)
				end
			end)
		end
	end)
end

--------------------------------------------------
-- GUIDING LIGHT (ROOM 45 ONLY, ONE-TIME)
--------------------------------------------------
do
	local triggered = false
	LatestRoom.Changed:Connect(function()
		if triggered then return end
		if LatestRoom.Value == 45 then
			triggered = true
			task.spawn(function()
				if not P or not P:FindFirstChild("PlayerGui") then return end
				local gui = Instance.new("ScreenGui", P.PlayerGui)
				gui.Name = "GUIDING_45"
				gui.ResetOnSpawn = false
				local t = Instance.new("TextLabel", gui)
				t.Size = UDim2.fromScale(1,0.15)
				t.Position = UDim2.fromScale(0,0.42)
				t.BackgroundTransparency = 1
				t.TextScaled = true
				t.Font = Enum.Font.GothamBold
				t.TextColor3 = Color3.fromRGB(0,210,255)
				t.TextStrokeTransparency = 0.6
				t.Text = "Do you really trust me?"
				Debris:AddItem(gui, 2)
			end)
			print("[OVERDOORS] Guiding Light triggered at room 45")
		end
	end)
end

--------------------------------------------------
-- AUTO LOAD c00lkiddSeek (one-time, guarded)
--------------------------------------------------
do
	local SEEK_URL = "https://raw.githubusercontent.com/IdkMyNameLoll/PublicScripts/refs/heads/main/c00lkiddSeek"
	if not getgenv().COOLKIDD_SEEK_LOADED then
		getgenv().COOLKIDD_SEEK_LOADED = false
	end

	if not getgenv().COOLKIDD_SEEK_LOADED then
		getgenv().COOLKIDD_SEEK_LOADED = true
		task.spawn(function()
			local ok, err = safeLoad(SEEK_URL)
			if ok then
				print("[OVERDOORS] c00lkiddSeek auto-loaded")
			else
				warn("[OVERDOORS] c00lkiddSeek failed to load:", err)
			end
		end)
	end
end

--------------------------------------------------
-- Add Shocker special entity: spawn every 35s (no conflict)
--------------------------------------------------
do
	local SHOCKER_URL = "https://raw.githubusercontent.com/Junbbinopro/Shocker-entity/refs/heads/main/Shocker"
	-- Use spawnLoop which already dedupes by URL (_addedEntityURLs).
	-- waitRoom = false -> spawns on time interval (every 35s)
	spawnLoop(35, SHOCKER_URL, false)
	print("[OVERDOORS] Shocker spawnLoop started (35s interval)")
end

--------------------------------------------------
-- READY
--------------------------------------------------
print(("✅ OVERDOORS LOADED — next entity scheduled at room %d"):format(nextSpawnRoom))
