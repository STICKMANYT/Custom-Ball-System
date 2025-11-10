local BallSystem = {}
BallSystem.__index = BallSystem

local RS = game:GetService("RunService")

type Ball = {Position : Vector3,
	Velocity : Vector3,
	Bounciness : number,
	Display : Instance
}

local RunFuncs : {{Ball : Ball, Run : RBXScriptConnection}} = {}

local function Update(dt : number, self : Ball)
	self.Velocity = self.Velocity - Vector3.new(0,workspace.Gravity * dt,0)
	
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {self.Display}
	Params.RespectCanCollide = true
	Params.IgnoreWater = true
	local RaycastResult = workspace:Raycast(self.Position - self.Velocity.Unit * .1, self.Velocity * dt + (self.Velocity.Unit * .1), Params)
	
	if RaycastResult then
		self.Position = RaycastResult.Position
		
		local ReflectedDirection = self.Velocity - 2 * (self.Velocity:Dot(RaycastResult.Normal)* RaycastResult.Normal)
		self.Velocity = ReflectedDirection * self.Bounciness
	end
	
	self.Position = self.Position + self.Velocity * dt
end

local function SetDisplayPosition(self : Ball)
	self.Display.Position = self.Position
end

-- Creates a new ball instance
function BallSystem.new() : Ball
	local Ball = setmetatable({
		Position = Vector3.new(0,0,0),
		Velocity = Vector3.new(0,0,0),
		Bounciness = 1,
		Display = nil
	}, BallSystem)
	
	local Display = Instance.new("Part")
	Display.Size = Vector3.new(1,1,1)
	Display.Anchored = true
	Display.CanCollide = false
	Display.Shape = Enum.PartType.Ball
	Display.Parent = workspace
	Ball.Display = Display
		
	local Run = RS.Stepped:Connect(function(_, delta)
		Update(delta, Ball)
		SetDisplayPosition(Ball)
	end)
	
	table.insert(RunFuncs, {Ball, Run})
	
	return Ball
end

-- Destroys the ball
function BallSystem:Destroy()
	self.Display:Destroy()
	
	for i,v in RunFuncs do
		if v[1] == self then
			v[2]:Disconnect()
			table.remove(RunFuncs, i)
			break
		end
	end
	
	self = nil
end

return BallSystem
