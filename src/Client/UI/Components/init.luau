local STORY_EXTENSION = ".story"

local Components = {
	CategoriesSidebar = require(script.CategoriesSidebar),
	CategoryButton = require(script.CategoryButton),
	CustomButton = require(script.CustomButton),
	EmoteButton = require(script.EmoteButton),
	EmoteCategoriesSidebar = require(script.EmoteCategoriesSidebar),
	EmotesCategory = require(script.EmotesCategory),
	FriendButton = require(script.FriendButton),
	ItemButton = require(script.ItemButton),
	ItemCategoriesSidebar = require(script.ItemCategoriesSidebar),
	ItemsCategory = require(script.ItemsCategory),
	SettingToggle = require(script.SettingToggle),
	TopbarButton = require(script.TopbarButton),
	WorldButton = require(script.WorldButton),
	WorldsCategory = require(script.WorldsCategory),
	Menu = require(script.Menu),
	EditableText = require(script.EditableText),
	PlayerAvatar = require(script.PlayerAvatar),
	ProfileBadges = require(script.ProfileBadges),
	LevelBadge = require(script.LevelBadge),
	RoroomsLogo = require(script.RoroomsLogo),
}

for _, Child in ipairs(script:GetChildren()) do
	local LastCharacters = string.sub(Child.Name, -string.len(STORY_EXTENSION))
	if LastCharacters ~= STORY_EXTENSION then
		local Success, Result = pcall(function()
			return require(Child)
		end)
		if Success then
			if Components[Child.Name] ~= Result then
				warn(`Component`, Child, `is not listed.`)
			end
		else
			warn(Child, "errored during require.")
		end
	end
end

return Components
