local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local win = Luna:CreateWindow({
	Name = "Lunar X",
	Subtitle = "- Sell Lemons",
	LogoID = "82795327169782",
	LoadingEnabled = true,
	LoadingTitle = "Lunar X",
	LoadingSubtitle = "by nick",
	ConfigSettings = {ConfigFolder = "LunarX-sl"},
	KeySystem = false,
})

win:CreateHomeTab({
	SupportedExecutors = {"Synapse Z", "Krnl", "Real ", "Madium", "Codex", "Delta", "Wave", "Potassium", "Volt", "Yub-X", "Velocity"},
	DiscordInvite = "fjcD5J5hEn",
	Icon = 1
})

local fTab = win:CreateTab({Name = "Farming", Icon = "agriculture", ShowTitle = true})
local mTab = win:CreateTab({Name = "Misc", Icon = "apps", ShowTitle = true})

local cfg = {
	Enabled = false,
	Speed = 0.3,
	MaxDistance = 500,
	TpToTreeMode = false,
	UseRemoteMethod = false,
	ReturnToBase = false,
	cashEnabled = false,
	cashReturnToBase = false,
	cMeth = "FireTouchInterest",
	autoPh = false,
	autoPhDecline = false,
	phDel = 5,
	autoRb = false,
	rbDel = 10,
	autoBuy = false,
	buyDel = 0.1,
	autoUpgrade = false,
	upgDel = 0.1,
}

local lp = game:GetService("Players").LocalPlayer

local function getTyc()
	for _, obj in pairs(workspace:GetChildren()) do
		local ownerVal = obj:FindFirstChild("Owner")
		if ownerVal and ownerVal.Value == lp then
			return obj
		end
	end
end

local function returnToBase()
	local t = getTyc()
	if t then
		local locs = t:FindFirstChild("Locations")
		local spawn = locs and locs:FindFirstChild("Spawn")
		if spawn then
			local char = lp.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = spawn.CFrame end
		end
	end
end

local function setVis(u, v)
	pcall(function() u.Visible = v end)
	pcall(function() u:SetVisible(v) end)
	pcall(function() u.Element.Visible = v end)
end

local function getValidFruits(tree)
	local fruits = {}
	for _, fruit in pairs(tree:GetChildren()) do
		if fruit.Name == "Fruit" then
			local trans = 0
			pcall(function() trans = fruit.Transparency end)
			if trans ~= 1 then
				table.insert(fruits, fruit)
			end
		end
	end
	return fruits
end

local lMethDrop, tpModeDrop, spdSlider, distSlider, baseToggle, cMethDrop, cashBaseToggle, phSlider, rbSlider

fTab:CreateSection("Lemon Farming")

fTab:CreateToggle({
	Name = "Auto Farm Lemons",
	CurrentValue = false,
	Callback = function(Value)
		cfg.Enabled = Value
		setVis(lMethDrop, Value)
		setVis(tpModeDrop, Value)
		setVis(spdSlider, Value)
		setVis(distSlider, Value)
		setVis(baseToggle, Value)
		if cfg.Enabled then
			task.spawn(function()
				local Event = game:GetService("ReplicatedStorage"):WaitForChild("Core"):WaitForChild("RemoteSignal")["ClickFruitService.Clicked"]

				while cfg.Enabled do
					local char = lp.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")

					if hrp then
						local farmedAny = false

						for _, tree in pairs(workspace:GetChildren()) do
							if not cfg.Enabled then break end
							if tree.Name ~= "LemonTree" then continue end

							local dist = (tree:GetPivot().Position - hrp.Position).Magnitude
							if dist > cfg.MaxDistance then continue end

							if cfg.TpToTreeMode then
								local anyFruit = tree:FindFirstChild("Fruit")
								if anyFruit then
									hrp.CFrame = anyFruit.CFrame + Vector3.new(0, 6.5, 0)
									task.wait(0.2)
								end
							end

							local fruits = getValidFruits(tree)
							if #fruits == 0 then continue end

							farmedAny = true

							while cfg.Enabled do
								local current = getValidFruits(tree)
								if #current == 0 then break end

								for _, fruit in pairs(current) do
									if not cfg.Enabled then break end

									local clickPart = fruit:FindFirstChild("ClickPart")

									if not cfg.TpToTreeMode then
										hrp.CFrame = fruit.CFrame
										task.wait(0.2)
									end

									if cfg.UseRemoteMethod then
										if clickPart and clickPart:IsA("BasePart") then
											firesignal(Event.OnClientEvent, 13.460957770776, clickPart.Position, false)
										elseif fruit:IsA("BasePart") then
											firesignal(Event.OnClientEvent, 13.460957770776, fruit.Position, false)
										end
									else
										local cd = clickPart and clickPart:FindFirstChildOfClass("ClickDetector")
										if cd then fireclickdetector(cd) end
									end

									task.wait(cfg.Speed)
								end
							end
						end

						if cfg.ReturnToBase and not farmedAny then
							returnToBase()
						end
					end

					task.wait(0.5)
				end
			end)
		end
	end
})

tpModeDrop = fTab:CreateDropdown({
	Name = "TP Mode",
	Options = {"Individual Lemons", "Lemon Tree"},
	CurrentOption = "Individual Lemons",
	MultipleOptions = false,
	Callback = function(v)
		cfg.TpToTreeMode = v[1] == "Lemon Tree"
	end
})

lMethDrop = fTab:CreateDropdown({
	Name = "Lemon Method",
	Options = {"ClickDetector", "Remote (Alternative)"},
	CurrentOption = "ClickDetector",
	MultipleOptions = false,
	Callback = function(v)
		cfg.UseRemoteMethod = v[1] == "Remote (Alternative)"
	end
})

baseToggle = fTab:CreateToggle({
	Name = "Return to Base",
	CurrentValue = false,
	Callback = function(v) cfg.ReturnToBase = v end
})

spdSlider = fTab:CreateSlider({
	Name = "Speed (delay per click)",
	Range = {0, 2},
	Increment = 0.1,
	CurrentValue = cfg.Speed,
	Callback = function(v) cfg.Speed = v end
})

distSlider = fTab:CreateSlider({
	Name = "Max Distance",
	Range = {100, 5000},
	Increment = 100,
	CurrentValue = cfg.MaxDistance,
	Callback = function(v) cfg.MaxDistance = v end
})

fTab:CreateDivider()
fTab:CreateSection("Cash Farming")

fTab:CreateToggle({
	Name = "Auto Farm Cash",
	CurrentValue = false,
	Callback = function(v)
		cfg.cashEnabled = v
		setVis(cMethDrop, v)
		setVis(cashBaseToggle, v)
		if not v then return end
		task.spawn(function()
			while cfg.cashEnabled do
				local char = lp.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, d in pairs(workspace.CashDrops:GetChildren()) do
						if not cfg.cashEnabled then break end
						if cfg.cMeth == "FireTouchInterest" then
							local ti = d:FindFirstChild("TouchInterest")
							if ti and ti.Parent then
								firetouchinterest(ti.Parent, hrp, 0)
								task.wait()
								firetouchinterest(ti.Parent, hrp, 1)
							end
						else
							local b = d:FindFirstChild("Bag")
							if b and b:IsA("BasePart") then
								hrp.CFrame = b.CFrame
								task.wait(0.2)
							end
						end
					end
					if cfg.cashReturnToBase and cfg.cMeth ~= "FireTouchInterest" then
						returnToBase()
					end
				end
				task.wait(0.5)
			end
		end)
	end
})

cMethDrop = fTab:CreateDropdown({
	Name = "Cash Method",
	Options = {"FireTouchInterest", "Teleport to Bag (Alt)"},
	CurrentOption = "FireTouchInterest",
	MultipleOptions = false,
	Callback = function(v) cfg.cMeth = v[1] end
})

cashBaseToggle = fTab:CreateToggle({
	Name = "Return to Base",
	CurrentValue = false,
	Callback = function(v) cfg.cashReturnToBase = v end
})

fTab:CreateDivider()
fTab:CreateSection("Tycoon")

fTab:CreateToggle({
	Name = "Auto Phone (Accept)",
	CurrentValue = false,
	Callback = function(v)
		cfg.autoPh = v
		setVis(phSlider, v)
		if not v then return end
		task.spawn(function()
			while cfg.autoPh do
				local t = getTyc()
				if t then
					local remotes = t:FindFirstChild("Remotes")
					if remotes then
						local phone = remotes:FindFirstChild("PhoneOffer")
						if phone then
							firesignal(phone.OnClientEvent, true)
						end
					end
				end
				task.wait(cfg.phDel)
			end
		end)
	end
})

fTab:CreateToggle({
	Name = "Auto Phone (Decline)",
	CurrentValue = false,
	Callback = function(v)
		cfg.autoPhDecline = v
		if not v then return end
		task.spawn(function()
			while cfg.autoPhDecline do
				local t = getTyc()
				if t then
					local remotes = t:FindFirstChild("Remotes")
					if remotes then
						local phone = remotes:FindFirstChild("PhoneOffer")
						if phone then
							firesignal(phone.OnClientEvent, false)
						end
					end
				end
				task.wait(cfg.phDel)
			end
		end)
	end
})

phSlider = fTab:CreateSlider({
	Name = "Phone Delay",
	Range = {1, 60},
	Increment = 1,
	CurrentValue = cfg.phDel,
	Callback = function(v) cfg.phDel = v end
})

fTab:CreateToggle({
	Name = "Auto Rebirth",
	CurrentValue = false,
	Callback = function(v)
		cfg.autoRb = v
		setVis(rbSlider, v)
		if not v then return end
		task.spawn(function()
			while cfg.autoRb do
				local t = getTyc()
				if t then
					local remotes = t:FindFirstChild("Remotes")
					if remotes then
						local rebirth = remotes:FindFirstChild("Rebirth")
						if rebirth then
							rebirth:InvokeServer(nil)
						end
					end
				end
				task.wait(cfg.rbDel)
			end
		end)
	end
})

rbSlider = fTab:CreateSlider({
	Name = "Rebirth Delay",
	Range = {1, 300},
	Increment = 1,
	CurrentValue = cfg.rbDel,
	Callback = function(v) cfg.rbDel = v end
})

fTab:CreateDivider()
fTab:CreateSection("Purchases")

fTab:CreateToggle({
	Name = "Auto Buy",
	CurrentValue = false,
	Callback = function(v)
		cfg.autoBuy = v
		if not v then return end
		task.spawn(function()
			while cfg.autoBuy do
				local t = getTyc()
				if t then
					local purchases = t:FindFirstChild("Purchases")
					if purchases then
						for _, group in pairs(purchases:GetChildren()) do
							if not cfg.autoBuy then break end
							local buttons = group:FindFirstChild("Buttons")
							if not buttons then continue end
							for _, subfolder in pairs(buttons:GetChildren()) do
								if not cfg.autoBuy then break end
								for _, item in pairs(subfolder:GetChildren()) do
									if not cfg.autoBuy then break end
									local existing = group:FindFirstChild(item.Name)
									if existing and #existing:GetChildren() > 2 then continue end
									local remote = item:FindFirstChild("Purchase")
									if remote and remote:IsA("RemoteFunction") then
										pcall(function() remote:InvokeServer(false) end)
										task.wait(cfg.buyDel)
									end
								end
							end
						end
					end
				end
				task.wait(cfg.buyDel)
			end
		end)
	end
})

fTab:CreateSlider({
	Name = "Buy Delay",
	Range = {0, 2},
	Increment = 0.1,
	CurrentValue = cfg.buyDel,
	Callback = function(v) cfg.buyDel = v end
})

fTab:CreateToggle({
	Name = "Auto Upgrade",
	CurrentValue = false,
	Callback = function(v)
		cfg.autoUpgrade = v
		if not v then return end
		task.spawn(function()
			while cfg.autoUpgrade do
				local t = getTyc()
				if t then
					local purchases = t:FindFirstChild("Purchases")
					if purchases then
						for _, group in pairs(purchases:GetChildren()) do
							if not cfg.autoUpgrade then break end
							local ownedGroup = group:FindFirstChild(group.Name)
							if not ownedGroup then continue end
							if #group:GetChildren() <= 2 then continue end
							local innerGroup = ownedGroup:FindFirstChild(group.Name)
							if not innerGroup then continue end
							local remote = innerGroup:FindFirstChild("Upgrade")
							if remote and remote:IsA("RemoteFunction") then
								pcall(function() remote:InvokeServer(1) end)
								task.wait(cfg.upgDel)
							end
						end
					end
				end
				task.wait(cfg.upgDel)
			end
		end)
	end
})

fTab:CreateSlider({
	Name = "Upgrade Delay",
	Range = {0, 2},
	Increment = 0.1,
	CurrentValue = cfg.upgDel,
	Callback = function(v) cfg.upgDel = v end
})

setVis(lMethDrop, false) setVis(tpModeDrop, false) setVis(spdSlider, false)
setVis(distSlider, false) setVis(baseToggle, false)
setVis(cMethDrop, false) setVis(cashBaseToggle, false) setVis(phSlider, false) setVis(rbSlider, false)

mTab:CreateSection("Tools")
mTab:CreateButton({
	Name = "Open Cobalt",
	Callback = function()
		loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
	end
})
mTab:CreateButton({
	Name = "Open Dex++",
	Callback = function()
		loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
	end
})
mTab:CreateButton({
	Name = "Open Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end
})
mTab:CreateSection("Other")
mTab:CreateButton({
	Name = "Teleport to Sewer Alien",
	Callback = function()
		local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = CFrame.new(-39.4568138, -45.1886978, 176.875824, -0.964999676, 0, 0.262251675, 0, 1, 0, -0.262251675, 0, -0.964999676)
	end
})
mTab:CreateButton({
	Name = "Collect Cash Vines",
	Callback = function()
		local Event = workspace.Map.Sewer.CashVine.CashVine.Use
		Event:InvokeServer()
	end
})
mTab:CreateButton({
	Name = "Pull Red Lever",
	Callback = function()
		local p = workspace.Map.Sewer.DoorsRed["Lever (Red)"].Root.Attachment.PullPrompt
		fireproximityprompt(p)
	end
})
local themeTab = win:CreateTab({Name = "Theme", Icon = "palette", ShowTitle = true})
local themeColors = {
	c1 = Color3.fromRGB(117, 164, 206),
	c2 = Color3.fromRGB(123, 201, 201),
	c3 = Color3.fromRGB(224, 138, 175),
}

local function applyTheme()
	Luna.ThemeGradient = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, themeColors.c1),
		ColorSequenceKeypoint.new(0.50, themeColors.c2),
		ColorSequenceKeypoint.new(1.00, themeColors.c3),
	}
end

themeTab:CreateSection("Custom Editor")
themeTab:CreateColorPicker({
	Name = "Color 1",
	Color = themeColors.c1,
	Flag = "LunarXColor1",
	Callback = function(v)
		if typeof(v) == "Color3" then
			themeColors.c1 = v
			applyTheme()
		end
	end
})
themeTab:CreateColorPicker({
	Name = "Color 2",
	Color = themeColors.c2,
	Flag = "LunarXColor2",
	Callback = function(v)
		if typeof(v) == "Color3" then
			themeColors.c2 = v
			applyTheme()
		end
	end
})
themeTab:CreateColorPicker({
	Name = "Color 3",
	Color = themeColors.c3,
	Flag = "LunarXColor3",
	Callback = function(v)
		if typeof(v) == "Color3" then
			themeColors.c3 = v
			applyTheme()
		end
	end
})

win:CreateTab({Name = "Config", Icon = "settings", ShowTitle = false}):BuildConfigSection()
