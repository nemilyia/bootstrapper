local highlighted: { [Instance]: Highlight } = {}

--[[local function isButton(instance: Instance): boolean
	return instance.Name == "Button"
end
]]

local function isButton(instance: Instance): boolean
	if not instance.Name:lower():find("button") then return false end
	local parent = instance.Parent
	return parent == workspace or parent:IsA("Folder")
end

local function addHighlight(instance: Instance): ()
	if highlighted[instance] then return end
	if not instance:IsA("BasePart") and not instance:IsA("Model") then return end

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

local function scanDescendants(root: Instance): ()
	for _, instance in root:GetDescendants() do
		if isButton(instance) then
			addHighlight(instance)
		end
	end
end

scanDescendants(workspace)

workspace.DescendantAdded:Connect(function(instance: Instance)
	if isButton(instance) then
		addHighlight(instance)
	end
end)

workspace.DescendantRemoving:Connect(function(instance: Instance)
	removeHighlight(instance)
end)
