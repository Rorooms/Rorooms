local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local RoRooms = script.Parent.Parent.Parent.Parent
local t = require(RoRooms.Parent.t)

local WorldsService = {
	Name = script.Name,
	Client = {},
}

function WorldsService.Client:TeleportToWorld(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return self.Server:TeleportPlayerToWorld(Player, PlaceId)
end

function WorldsService:TeleportPlayerToWorld(Player: Player, PlaceId: number)
	if RunService:IsStudio() == false then
		TeleportService:Teleport(PlaceId, Player)
	end

	return true
end

return WorldsService
