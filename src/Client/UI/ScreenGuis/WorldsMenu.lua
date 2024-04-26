local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Spring = Fusion.Spring
local ForValues = Fusion.ForValues

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local WorldButton = require(Client.UI.Components.WorldButton)
local WorldsCategory = require(Client.UI.Components.WorldsCategory)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	local WorldsMenu = New "ScreenGui" {
		Name = "WorldsMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						local YPos = States.TopbarBottomPos:get()
						if not MenuOpen:get() then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					37,
					1
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(353, 0),
						GroupTransparency = Spring(
							Computed(function()
								if MenuOpen:get() then
									return 0
								else
									return 1
								end
							end),
							Themer.Theme.SpringSpeed["1"],
							Themer.Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,

						[Children] = {
							Modifier.ListLayout {},

							TitleBar {
								Title = "Worlds",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Name = "WorldsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),
								ScrollBarThickness = Themer.Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Themer.Theme.Colors.NeutralContent.Dark,

								[Children] = {
									Modifier.Padding {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
										end),
									},
									Modifier.ListLayout {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["1"]:get())
										end),
										FillDirection = Enum.FillDirection.Horizontal,
										Wraps = true,
									},

									WorldsCategory {
										Name = "Featured",
										Title = "From creator",
										Icon = "rbxassetid://17292608120",
										Visible = Computed(function()
											return #Config.WorldsSystem.FeaturedWorlds >= 1
										end),

										[Children] = {
											ForValues(Config.WorldsSystem.FeaturedWorlds, function(PlaceId: number)
												return WorldButton {
													PlaceId = PlaceId,
												}
											end, Fusion.cleanup),
										},
									},
									WorldsCategory {
										Name = "Popular",
										Title = "Popular",
										Icon = "rbxassetid://17292608258",

										[Children] = {
											ForValues(States.Worlds.TopWorlds, function(PlaceId: number)
												return WorldButton {
													PlaceId = PlaceId,
												}
											end, Fusion.cleanup),
										},
									},
									WorldsCategory {
										Name = "Random",
										Title = "Random",
										Icon = "rbxassetid://17292608467",

										[Children] = {
											ForValues(States.Worlds.RandomWorlds, function(PlaceId: number)
												return WorldButton {
													PlaceId = PlaceId,
												}
											end, Fusion.cleanup),
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}

	return WorldsMenu
end
