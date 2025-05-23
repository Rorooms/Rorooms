local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Component = require(Rorooms.Parent.Component)
local Fusion = require(Rorooms.Parent.Fusion)
local AttributeBind = require(Rorooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(Rorooms.Parent.Trove)

local Peek = Fusion.peek

local AnimatedSeatComponent = Component.new {
	Tag = "RR_AnimatedSeat",
}

function AnimatedSeatComponent:UpdateOccupant()
	if self.LastAnimationTrack then
		self.LastAnimationTrack:Stop()
		self.LastAnimationTrack = nil
	end

	if self.Instance.Occupant then
		local Humanoid = self.Instance.Occupant
		local Character = Humanoid:FindFirstAncestorOfClass("Model")

		if Character then
			self.Occupant:set(Players:GetPlayerFromCharacter(Character))
		end

		if Peek(self.Occupant) == Players.LocalPlayer then
			local Animator = Humanoid:FindFirstChild("Animator")
			if Animator then
				local AnimationTrack = Animator:LoadAnimation(self.Animation)
				AnimationTrack:Play()
				self.LastAnimationTrack = AnimationTrack
			end
		end
	else
		self.Occupant:set(nil)
	end
end

function AnimatedSeatComponent:OnPromptTriggered(Player: Player)
	if Player == Players.LocalPlayer then
		local Char = Players.LocalPlayer.Character
		if Char then
			local Humanoid = Char:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				self.Instance:Sit(Humanoid)
			end
		end
	end
end

function AnimatedSeatComponent:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_SitPrompt")
	if not ProximityPrompt then
		ProximityPrompt = self.Scope:New "ProximityPrompt" {
			Name = "RR_SitPrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
	end

	self.Scope:Hydrate(ProximityPrompt) {
		Enabled = self.Scope:Computed(function(Use)
			return Use(self.Occupant) == nil
		end),
	}

	return ProximityPrompt
end

function AnimatedSeatComponent:Start()
	self.Instance.Disabled = not Peek(self.SitOnTouch)

	if Peek(self.PromptToSit) then
		self.ProximityPrompt = self:GetProximityPrompt()

		self.ProximityPrompt.Triggered:Connect(function(Player: Player)
			self:OnPromptTriggered(Player)
		end)
	end

	self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:UpdateOccupant()
	end)
end

function AnimatedSeatComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.PromptToSit = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_PromptToSit", true)):Observe(function(Value)
		self.PromptToSit:set(Value)
	end)

	self.SitOnTouch = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_PromptToSit", true)):Observe(function(Value)
		self.SitOnTouch:set(Value)
	end)

	self.Occupant = self.Scope:Value(nil)

	if not self.Instance:IsA("Seat") then
		warn("AnimatedSeat must be a Seat object", self.Instance)
		return
	end

	local Animation = self.Instance:WaitForChild("Animation")
	if Animation then
		self.Animation = Animation
	else
		warn("No Animation inside AnimatedSeat", self.Instance)
		return
	end
end

function AnimatedSeatComponent:Stop()
	self.Trove:Destroy()
end

return AnimatedSeatComponent
