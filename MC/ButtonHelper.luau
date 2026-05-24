local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local SEEN_ATTR = HttpService:GenerateGUID(false)

local highlighted: { [Instance]: Highlight } = {}

local function isButton(instance: Instance): boolean
	if not instance.Name:lower():find("button") then return false end
	if not instance:IsA("BasePart") and not instance:IsA("Model") then return false end
	if instance:FindFirstChildWhichIsA("Humanoid") then return false end
	local ancestorModel = instance:FindFirstAncestorWhichIsA("Model")
	if ancestorModel and ancestorModel:FindFirstChildWhichIsA("Humanoid") then return false end
	return true
end

local function getRoot(instance: Instance): BasePart?
	if instance:IsA("BasePart") then return instance end
	if instance:IsA("Model") then
		return instance.PrimaryPart
			or instance:FindFirstChildWhichIsA("BasePart")
			or instance:FindFirstDescendantWhichIsA("BasePart")
	end
	return nil
end

local function isInLineOfSight(instance: Instance): boolean
	local root = getRoot(instance)
	if not root then return false end

	local origin = camera.CFrame.Position
	local target = root.Position

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local excludes: { Instance } = { instance }
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(excludes, player.Character)
		end
	end
	raycastParams.FilterDescendantsInstances = excludes

	local result = workspace:Raycast(origin, target - origin, raycastParams)
	return result == nil
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

RunService.RenderStepped:Connect(function(dt: number)
	for instance, highlight in highlighted do
		if instance:GetAttribute(SEEN_ATTR) then continue end

		if isInLineOfSight(instance) then
			instance:SetAttribute(SEEN_ATTR, true)
		end

		local isSeen = instance:GetAttribute(SEEN_ATTR) == true
		local fillTarget = if isSeen then 1 else 0.5
		local outlineTarget = if isSeen then 1 else 0
		local speed = math.min(dt * 8, 1)

		highlight.FillTransparency += (fillTarget - highlight.FillTransparency) * speed
		highlight.OutlineTransparency += (outlineTarget - highlight.OutlineTransparency) * speed
	end
end)
