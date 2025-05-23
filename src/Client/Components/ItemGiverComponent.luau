local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Component = require(Rorooms.Parent.Component)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local ItemsController = require(Rorooms.SourceCode.Client.Items.ItemsController)
local Config = require(Rorooms.Config).Config
local AttributeBind = require(Rorooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(Rorooms.Parent.Trove)

local Peek = Fusion.peek

local ItemGiverComponent = Component.new {
	Tag = "RR_ItemGiver",
}

function ItemGiverComponent:GiveItem(Player: Player)
	if Player == Players.LocalPlayer then
		ItemsController:ToggleEquipItem(Peek(self.ItemId), true)
	end
end

function ItemGiverComponent:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_ItemGiverPrompt")
	if not ProximityPrompt then
		ProximityPrompt = self.Scope:New "ProximityPrompt" {
			Name = "RR_ItemGiverPrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
	end

	self.Scope:Hydrate(ProximityPrompt) {
		Enabled = self.Scope:Computed(function(Use)
			return Use(self.Item) ~= nil
		end),
		ActionText = self.Scope:Computed(function(Use)
			if Use(self.Item) then
				if Use(self.Equipped) then
					return "Unequip"
				else
					return "Equip"
				end
			else
				return Use(self.ItemId)
			end
		end),
		ObjectText = self.Scope:Computed(function(Use)
			local ItemValue = Use(self.Item)
			local ItemIdValue = Use(self.ItemId)

			if ItemValue and ItemValue.Name then
				return ItemValue.Name
			elseif ItemIdValue then
				return ItemIdValue
			else
				return "Invalid item"
			end
		end),
	}

	return ProximityPrompt
end

function ItemGiverComponent:Start()
	self.ProximityPrompt = self:GetProximityPrompt()

	self.ProximityPrompt.Triggered:Connect(function(Player: Player)
		self:GiveItem(Player)
	end)
end

function ItemGiverComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.ItemId = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_ItemId")):Observe(function(Value)
		self.ItemId:set(Value)
	end)

	self.Item = self.Scope:Computed(function(Use)
		return Config.Systems.Items.Items[Use(self.ItemId)]
	end)
	self.Equipped = self.Scope:Computed(function(Use)
		return table.find(Use(States.Items.Equipped), Use(self.ItemId)) ~= nil
	end)

	if not Peek(self.ItemId) then
		warn("No RR_ItemId attribute defined for ItemGiver", self.Instance)
	end
	if not Peek(self.Item) then
		warn("Could not find item from RR_ItemId", Peek(self.ItemId), self.Instance)
	end
end

function ItemGiverComponent:Stop()
	self.Trove:Destroy()
end

return ItemGiverComponent
