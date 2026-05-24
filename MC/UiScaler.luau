local Players = game:GetService("Players")

local baseResolution = Vector2.new(1280, 720)

local function applyScale(gui: ScreenGui): ()
	gui.IgnoreGuiInset = true

	local scale = Instance.new("UIScale")
	scale.Parent = gui

	local function updateScale(): ()
		local viewport = workspace.CurrentCamera.ViewportSize
		local scaleX = viewport.X / baseResolution.X
		local scaleY = viewport.Y / baseResolution.Y
		scale.Scale = math.min(scaleX, scaleY)
	end

	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	updateScale()
end

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("ScreenGui") :: ScreenGui

applyScale(gui)
