local Players = game:GetService("Players")
local RoRooms = script.Parent.Parent.Parent.Parent
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Knit = require(RoRooms.Parent.Knit)
local AvatarSelector = require(script.Parent.AvatarSelector)

local Scoped = Fusion.scoped
local Peek = Fusion.peek

local ProfilesController = {
	Name = "ProfilesController",

	Scope = Scoped(Fusion),
}

function ProfilesController:_WatchProfile()
	self.Scope:Observer(States.Profile.Nickname):onChange(function()
		local NicknameValue = Peek(States.Profile.Nickname)

		if next(States.Services.WorldsService) ~= nil then
			States.Services.ProfilesService:SetNickname(NicknameValue)
		end
	end)
	self.Scope:Observer(States.Profile.Status):onChange(function()
		local StatusValue = Peek(States.Profile.Status)

		if next(States.Services.WorldsService) ~= nil then
			States.Services.ProfilesService:SetStatus(StatusValue)
		end
	end)

	local ProfilesService = Knit.GetService("ProfilesService")

	ProfilesService.Nickname:Observe(function(Nickname: string)
		States.Profile.Nickname:set(Nickname)
	end)
	ProfilesService.Status:Observe(function(Status: string)
		States.Profile.Status:set(Status)
	end)
end

function ProfilesController:KnitStart()
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.ProfileMenu))

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)

	self:_WatchProfile()

	AvatarSelector:Start()

	AvatarSelector.AvatarSelected:Connect(function(Character: Model?)
		local Player = Players:GetPlayerFromCharacter(Character)
		if Player then
			if
				(Player.UserId ~= Peek(States.Menus.ProfileMenu.UserId))
				or (Peek(States.Menus.CurrentMenu) ~= "ProfileMenu")
			then
				States.Menus.ProfileMenu.UserId:set(Player.UserId)
				States.Menus.CurrentMenu:set("ProfileMenu")
			else
				States.Menus.ProfileMenu.UserId:set(nil)
				States.Menus.CurrentMenu:set(nil)
			end
		end
	end)

	AvatarSelector.AvatarDeselected:Connect(function()
		States.Menus.ProfileMenu.UserId:set(nil)

		if Peek(States.Menus.CurrentMenu) == "ProfileMenu" then
			States.Menus.CurrentMenu:set(nil)
		end
	end)
end

return ProfilesController
