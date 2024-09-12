local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local ReconcileTable = require(Shared.ExtPackages.ReconcileTable)

local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local CONTROLLERS = {"UIController", "EmotesController", "ItemsController"}
local SERVICES = {"UserProfileService", "WorldsService", "ItemsService", "PlayerDataService", "EmotesService"}

local States = {
  TopbarIcons = {},
  Prompts = Value({}),
  CurrentMenu = Value(),
  TopbarBottomPos = Value(0),
  TopbarVisible = Value(true),
  ScreenSize = Value(Vector2.new()),
  EquippedItems = Value({}),
  ItemsMenu = {
    Open = Value(false),
    FocusedCategory = Value(nil),
  },
  ItemsMenuOpen = Value(false),
  LocalPlayerData = Value({}),
  UserSettings = {
    MuteMusic = Value(false),
    HideUI = Value(false),
  },
}

function States:PushPrompt(Prompt: table)
  local PromptTemplate = {
    Title = "",
    Text = "",
    Buttons = {
      {
        Primary = true,
        Content = {"Confirm"},
        Callback = function()
          
        end
      },
      {
        Primary = false,
        Content = {"Cancel"},
        Callback = function()
          
        end
      }
    },
  }
  local NewPrompts = States.Prompts:get()
  ReconcileTable(Prompt, PromptTemplate)
  for _, ExistingPrompt in ipairs(NewPrompts) do
    if ExistingPrompt.Text == Prompt.Text then
      return      
    end
  end
  table.insert(NewPrompts, Prompt)
  States.Prompts:set(NewPrompts)
end

function States:Start()
  for _, ControllerName in ipairs(CONTROLLERS) do
    self[ControllerName] = Knit.GetController(ControllerName)
  end
  for _, ServiceName in ipairs(SERVICES) do
    task.spawn(function()
      self[ServiceName] = Knit.GetService(ServiceName)
    end)
  end
  
  Hydrate(workspace.CurrentCamera) {
    [Out "ViewportSize"] = States.ScreenSize
  }
  
  Knit.OnStart():andThen(function()
    States.ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
      States.EquippedItems:set(EquippedItems)
    end)

    States.PlayerDataService.Level:Observe(function(Level)
      local LocalPlayerData = States.LocalPlayerData:get()
      LocalPlayerData.Level = Level
      States.LocalPlayerData:set(LocalPlayerData)
    end)
  end)
end

return States