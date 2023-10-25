local settings = {}
game_api = require("lib")

--Toogles
settings.Cooldown = "Cooldown"
settings.Dispel = "Dispel"
settings.Pause = "Pause"


--Settings
settings.ObsidianScalePercent = "ObsidianScale Life Percent"
settings.RenewingBlazePercent = "RenewingBlaze Life Percent"

function settings.createSettings()

    game_api.createSetting(settings.DispelDelay,settings.DispelDelay,1500,{0,3000})

    game_api.createSetting(settings.ObsidianScalePercent,settings.ObsidianScalePercent,70,{0,100})
    game_api.createSetting(settings.RenewingBlazePercent,settings.RenewingBlazePercent,97,{0,100})

    game_api.createToggle(settings.Cooldown, settings.Cooldown,true,0);
    game_api.createToggle(settings.Dispel, settings.Dispel,true,0);
    game_api.createToggle(settings.Pause, settings.Pause,false,0);

    
end

return settings