local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local camera = workspace.CurrentCamera

local highlighted: { [Instance]: Highlight } = {}

local function isButton(instance: Instance): boolean
	if not instance.Name:lower():find("button") then return false end
	if not instance:IsA("BasePart") and not instance:IsA("Model") then return false end
	if instance:FindFirstChildWhichIsA("Humanoid") then return false end
	local ancestorModel = instance:FindFirstAncestorWhichIsA("Model")
	if ancestorModel and ancestorModel:FindFirstChildWhichIsA("Humanoid") then return false end
	return true
end

local function isInLineOfSight(instance: Instance): boolean
	local parts: { BasePart } = {}

	if instance:IsA("BasePart") then
		table.insert(parts, instance)
	else
		for _, desc in instance:GetDescendants() do
			if desc:IsA("BasePart") then
				table.insert(parts, desc)
			end
		end
	end

	if #parts == 0 then return false end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local excludes: { Instance } = { instance }
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(excludes, player.Character)
		end
	end
	raycastParams.FilterDescendantsInstances = excludes

	local origin = camera.CFrame.Position

	for _, part in parts do
		local result = workspace:Raycast(origin, part.Position - origin, raycastParams)
		if result == nil then
			return true
		end
	end

	return false
end

local function addHighlight(instance: Instance): ()
	if highlighted[instance] then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = instance
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = instance

	highlighted[instance] = highlight
end

local function removeHighlight(instance: Instance): ()
	local highlight = highlighted[instance]
	if not highlight then return end
	highlight:Destroy()
	highlighted[instance] = nil
end

task.defer(function()
	for _, instance in workspace:GetDescendants() do
		if isButton(instance) then
			addHighlight(instance)
		end
	end
end)

workspace.DescendantAdded:Connect(function(instance: Instance)
	if isButton(instance) then
		addHighlight(instance)
	end
end)

workspace.DescendantRemoving:Connect(function(instance: Instance)
	removeHighlight(instance)
end)

local seen: { [Instance]: boolean } = {}

RunService.RenderStepped:Connect(function(dt: number)
	for instance, highlight in highlighted do
		if seen[instance] then continue end

		if isInLineOfSight(instance) then
			seen[instance] = true
		end

		local isSeen = seen[instance] == true
		local fillTarget = if isSeen then 1 else 0.5
		local outlineTarget = if isSeen then 1 else 0
		local speed = math.min(dt * 8, 1)

		highlight.FillTransparency += (fillTarget - highlight.FillTransparency) * speed
		highlight.OutlineTransparency += (outlineTarget - highlight.OutlineTransparency) * speed
	end
end)
