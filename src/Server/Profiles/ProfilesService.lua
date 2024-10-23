local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local FilterString = require(RoRooms.SourceCode.Storage.ExtPackages.FilterString)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local t = require(RoRooms.Parent.t)
local Config = require(RoRooms.Config).Config
local Future = require(RoRooms.Parent.Future)
local Types = require(RoRooms.SourceCode.Shared.Types)

local ProfilesService = {
	Name = "ProfilesService",
	Client = {
		ProfileUpdated = Knit.CreateSignal(),
	},
}

function ProfilesService.Client:GetProfile(Player: Player, UserId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(UserId)))

	return ProfilesService:GetProfile(UserId)
end

function ProfilesService.Client:SetRole(Player: Player, RoleId: string): boolean
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(RoleId)))

	return ProfilesService:SetRole(Player, RoleId)
end

function ProfilesService.Client:SetNickname(Player: Player, Nickname: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Nickname)))
	assert(utf8.len(Nickname) <= Config.Systems.Profiles.NicknameCharacterLimit, "Nickname exceeds character limit")

	ProfilesService:SetNickname(Player, FilterString(Nickname, Player))
end

function ProfilesService.Client:SetBio(Player: Player, Bio: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Bio)))
	assert(utf8.len(Bio) <= Config.Systems.Profiles.BioCharacterLimit, "Bio exceeds character limit")

	ProfilesService:SetBio(Player, FilterString(Bio, Player))
end

function ProfilesService:GetProfile(UserId: number): Types.Profile
	local Profile = {}
	local DataProfile = PlayerDataStoreService:GetProfile(UserId)
	local Player = Players:GetPlayerByUserId(UserId)

	if DataProfile then
		Profile.Nickname = DataProfile.Data.Profile.Nickname
		Profile.Bio = DataProfile.Data.Profile.Bio
		Profile.Role = DataProfile.Data.Profile.Role
		Profile.Level = DataProfile.Data.Level
	end

	if Player then
		Profile.DisplayName = Player.DisplayName
		Profile.Username = Player.Name
	else
		local Success, Result = Future.Try(function()
			return UserService:GetUserInfosByUserIdsAsync({ UserId })[1]
		end):Await()
		if Success and Result then
			Profile.DisplayName = Result.DisplayName
			Profile.Username = Result.Username
		end
	end

	return Profile
end

function ProfilesService:SetRole(Player: Player, RoleId: string): boolean
	if (RoleId == nil) and (Config.Systems.Profiles.DefaultRoleId ~= nil) then
		RoleId = Config.Systems.Profiles.DefaultRoleId
	end

	local RoleToSet = nil
	local Role = Config.Systems.Profiles.Roles[RoleId]

	if Role ~= nil then
		RoleToSet = RoleId
	end

	local Success = PlayerDataStoreService:UpdateData(Player, function(Data)
		Data.Profile.Role = RoleToSet
		return Data
	end)
	if Success then
		Player:SetAttribute("RR_RoleId", RoleToSet)
	end

	return Success
end

function ProfilesService:SetNickname(Player: Player, Nickname: string)
	return PlayerDataStoreService:UpdateData(Player, function(Data)
		Data.Profile.Nickname = Nickname
		return Data
	end)
end

function ProfilesService:SetBio(Player: Player, Bio: string)
	local Success = PlayerDataStoreService:UpdateData(Player, function(Data)
		Data.Profile.Bio = Bio
		return Data
	end)
	if Success then
		Player:SetAttribute("RR_Bio", Bio)
	end

	return Success
end

function ProfilesService:_UpdateFromDataStoreProfile(Player: Player)
	if not Player then
		return
	end

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		self:SetNickname(Player, Profile.Data.Profile.Nickname)
		self:SetBio(Player, Profile.Data.Profile.Bio)
		self:SetRole(Player, Profile.Data.Profile.Role)
	end
end

function ProfilesService:_CheckDefaultRole()
	local DefaultRoleId = Config.Systems.Profiles.DefaultRoleId
	local DefaultRole = Config.Systems.Profiles.Roles[DefaultRoleId]

	if (DefaultRoleId ~= nil) and (DefaultRole == nil) then
		assert(false, "DefaultRoleId is set to a nonexistent role.")
	else
		assert(DefaultRole.CallbackRequirement == nil, "The default role cannot have a CallbackRequirement.")
	end
end

function ProfilesService:KnitStart()
	PlayerDataStoreService.ProfileLoaded:Connect(function(Profile: PlayerDataStoreService.Profile)
		self:_UpdateFromDataStoreProfile(Profile.Player)

		Profile.Player:SetAttribute("RR_Nickname", Profile.Data.Profile.Nickname)
	end)
	for _, Profile in pairs(PlayerDataStoreService:GetProfiles()) do
		self:_UpdateFromDataStoreProfile(Profile.Player)
	end

	self:_CheckDefaultRole()

	PlayerDataStoreService.DataUpdated:Connect(
		function(
			Player: Player,
			OldData: PlayerDataStoreService.ProfileData,
			NewData: PlayerDataStoreService.ProfileData
		)
			if OldData.Profile ~= NewData.Profile then
				self.Client.ProfileUpdated:FireAll(Player.UserId)
			end
		end
	)
end

return ProfilesService
