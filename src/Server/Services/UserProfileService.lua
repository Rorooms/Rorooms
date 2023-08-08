local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Storage = RoRooms.Storage

local Knit = require(Shared.Packages.Knit)
local SharedData = require(Shared.SharedData)
local FilterString = require(Storage.ExtPackages.FilterString)

local PlayerDataService

local UserProfileService = Knit.CreateService {
  Name = "UserProfileService";
  Client = {};
}

function UserProfileService.Client:SetNickname(Player: Player, Nickname: string)
  if typeof(Nickname) ~= "string" then return end
  if utf8.len(Nickname) > SharedData.NicknameCharLimit then return end
  self.Server:SetPlayerNickname(Player, FilterString(Nickname, Player))
end

function UserProfileService.Client:SetStatus(Player: Player, Status: string)
  if typeof(Status) ~= "string" then return end
  if utf8.len(Status) > SharedData.StatusCharLimit then return end
  self.Server:SetPlayerStatus(Player, FilterString(Status, Player))
end

function UserProfileService:SetPlayerNickname(Player: Player, Nickname: string)
  Player:SetAttribute("RR_Nickname", Nickname)
  PlayerDataService:ChangeProfile(Player, {
    Nickname = Nickname
  })
end

function UserProfileService:SetPlayerStatus(Player: Player, Status: string)
  Player:SetAttribute("RR_Status", Status)
  PlayerDataService:ChangeProfile(Player, {
    Status = Status
  })
end

function UserProfileService:LoadProfileFromData(Player: Player, Profile: table)
  self:SetPlayerNickname(Player, Profile.Data.UserProfile.Nickname)
  self:SetPlayerStatus(Player, Profile.Data.UserProfile.Status)
end

function UserProfileService:KnitStart()
  PlayerDataService = Knit.GetService("PlayerDataService")

  PlayerDataService.ProfileLoaded:Connect(function(Player: Player, Profile: table)
    self:LoadProfileFromData(Player, Profile)
  end)
  for Player, Profile in pairs(PlayerDataService.Profiles) do
    self:LoadProfileFromData(Player, Profile)
  end
end

return UserProfileService