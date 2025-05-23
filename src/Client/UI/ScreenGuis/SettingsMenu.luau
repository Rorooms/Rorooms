local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Version = require(Rorooms.Version)
local Components = require(Rorooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList }

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	Scope:Observer(States.UserSettings.HideUI):onChange(function()
		for _, CoreGuiType in ipairs(TOGGLEABLE_CORE_GUIS) do
			StarterGui:SetCoreGuiEnabled(CoreGuiType, not Peek(States.UserSettings.HideUI))
		end
		States.Topbar.Visible:set(not Peek(States.UserSettings.HideUI))
		if Peek(States.UserSettings.HideUI) then
			States.Menus.CurrentMenu:set(nil)
		end
	end)
	if Players.LocalPlayer then
		Players.LocalPlayer.CharacterAdded:Connect(function()
			States.UserSettings.HideUI:set(false)
		end)
	end

	local SettingsMenu = Scope:Menu {
		Name = script.Name,
		Parent = Props.Parent,
		Size = UDim2.fromOffset(305, 0),
		Open = MenuOpen,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Scroller {
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
				AutomaticSize = Enum.AutomaticSize.None,
				ScrollBarThickness = Theme.StrokeThickness["1"],
				ListEnabled = true,
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:SettingToggle {
						Label = "Mute music",
						Switched = States.UserSettings.MuteMusic,
					},
					Scope:SettingToggle {
						Label = "Hide UI",
						Switched = States.UserSettings.HideUI,
					},

					Scope:Text {
						Text = Scope:Computed(function(Use)
							local UpToDateValue = Use(States.Rorooms.UpToDate)
							local VersionStamp = `[Rorooms v{Version}]`

							if UpToDateValue == false then
								return `{VersionStamp} - Out of date`
							else
								return VersionStamp
							end
						end),
						TextColor3 = Scope:Computed(function(Use)
							local UpToDateValue = Use(States.Rorooms.UpToDate)
							if UpToDateValue == false then
								return Use(Theme.Colors.Warning.Main)
							else
								return Use(Theme.Colors.NeutralContent.Dark)
							end
						end),
					},
				},
			},
		},
	}

	return SettingsMenu
end
