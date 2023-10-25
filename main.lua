game_api = require("lib")
spells = require ("spells")
talents = require ("talents")
auras = require ("auras")
settings = require ("settings")
utils = require ("utils")

state = {}

--[[
    Create your variable and toggle here
]]
function OnInit()
    settings.createSettings()
    print("0x33 Augmentation Evoker Rotation Loaded !")
end


function PrescienceActive(unit)
    local ret = false
    if game_api.unitHasAura(unit,auras.Prescience,true) and game_api.unitAuraRemainingTime(unit,auras.Prescience,true) > 2000 then
        ret = true
    end
    return ret
end

function PrescienceToBeRefreshCondition(unit)
    local ret = false
    if game_api.unitHasAura(unit,auras.Prescience,true) and game_api.unitAuraRemainingTime(unit,auras.Prescience,true) < 2000 and game_api.distanceToUnit(unit) < 25 then
        ret = true
    end
    return ret
end

function AnyUnitWithoutPrescienceCondition(unit)
    local ret = false
    if not game_api.unitHasAura(unit,auras.Prescience,true) and game_api.distanceToUnit(unit) < 25 then
        ret = true
    end
    return ret
end

function DpsWithoutPrescienceCondition(unit)
    local ret = false
    if AnyUnitWithoutPrescienceCondition(unit) and game_api.unitIsRole(unit,"DPS") then
        ret = true
    end
    return ret
end

function TankWithBlisteringScaleCondition(unit)
    local ret = false
    if game_api.unitIsRole(unit,"TANK") and game_api.unitHasAura(unit,auras.BlisteringScales,true) and game_api.distanceToUnit(unit) < 25 then
        ret = true
    end
    return ret
end

function TankWithoutBlisteringScaleCondition(unit)
    local ret = false
    if game_api.unitIsRole(unit,"TANK") and not game_api.unitHasAura(unit,auras.BlisteringScales,true) and game_api.distanceToUnit(unit) < 25 then
        ret = true
    end
    return ret
end

function BlisteringScales(party)
    if game_api.canCast(spells.BlisteringScales) then
        local unitWithBlisteringScaleActive = utils.CheckConditionOnUnitList(party,TankWithBlisteringScaleCondition)
        if #unitWithBlisteringScaleActive > 0 then
            return false
        end

        local unitWithoutBlisteringScale = utils.CheckConditionOnUnitList(party,TankWithoutBlisteringScaleCondition)
        if #unitWithoutBlisteringScale > 0 then
            game_api.castSpellOnTarget(spells.BlisteringScales,unitWithoutBlisteringScale[1])
            return true
        end

        game_api.castSpellOnTarget(spells.BlisteringScales,game_api.getCurrentPlayer())
        return true
    end
    return false
end


function Prescience(party)

    if game_api.canCast(spells.Prescience) then
        local unitWithPrescienceActive = utils.CheckConditionOnUnitList(party,PrescienceActive)
        if #unitWithPrescienceActive >= 2 then
            return false
        end
        
        local unitWithPrescienceNeedRefresh = utils.CheckConditionOnUnitList(party,PrescienceToBeRefreshCondition)
        if #unitWithPrescienceNeedRefresh > 0 then
            game_api.castSpellOnTarget(spells.Prescience,unitWithPrescienceNeedRefresh[1])
            return true
        end

        local unitDpsWithoutPrescience = utils.CheckConditionOnUnitList(party,DpsWithoutPrescienceCondition)
        if #unitDpsWithoutPrescience > 0 then
            game_api.castSpellOnTarget(spells.Prescience,unitDpsWithoutPrescience[1])
            return true
        end

        local unitWithoutPrescience = utils.CheckConditionOnUnitList(party,AnyUnitWithoutPrescienceCondition)
        if #unitWithoutPrescience > 0 then
            game_api.castSpellOnTarget(spells.Prescience,unitWithoutPrescience[1])
            return true
        end
    end
    return false
end


function StateUpdate()

    state.currentMana = game_api.getPower(0)
    state.currentEssence = game_api.getPower(2)
    state.maxEssence = game_api.getMaxPower(2)

    state.currentTarget = game_api.getCurrentUnitTarget()
    state.currentPlayer = game_api.getCurrentPlayer()
    state.FontOfMagic = game_api.hasTalent(talents.FontOfMagic)

    state.currentHpPercent = game_api.unitHealthPercent(state.currentPlayer)

    state.party = game_api.getPartyUnits()

    state.chargedSpellsMaxRank = 3
 
end


function Affix()
    if game_api.getToggle(settings.Dispel) then

        if (#state.afflictedUnits > 0) and (game_api.canCast(spells.Naturalize) or game_api.canCast(spells.CauterizingFlame)) then
            for _, unit in ipairs(state.afflictedUnits) do
                if (game_api.distanceToUnit(unit) < 30.0) and (game_api.unitIsCasting(unit) or game_api.unitIsChanneling(unit)) then

                    if game_api.canCast(spells.Naturalize) then
                        game_api.castSpellOnTarget(spells.Naturalize,unit)
                        return true

                    end

                    if game_api.canCast(spells.CauterizingFlame) then
                        game_api.castSpellOnTarget(spells.CauterizingFlame,unit)
                        return true

                    end
                end
            end
        end
    
    end
    return false
end

function Dps()

    if state.currentTarget == "00" or not game_api.isTargetHostile(true) then
        return false
    end

    if Prescience(state.party) then
        return true
    end

    if BlisteringScales(state.party) then
        return true
    end

    if ( game_api.canCast(spells.FireBreath) and not game_api.isOnCooldown(spells.FireBreathFOM) ) and state.currentMana >= 6500 and game_api.currentPlayerDistanceFromTarget() <= 25.0  then
        game_api.castSpell(spells.FireBreath)
        return true
    end
    if game_api.currentPlayerHasAura(auras.EssenceBurst,true) and game_api.canCast(spells.Eruption) and game_api.currentPlayerDistanceFromTarget() <= 25.0 then
        game_api.castSpellOnTarget(spells.Eruption,state.currentTarget)
        return true
    end

    if game_api.canCast(spells.LivingFlame) and game_api.currentPlayerDistanceFromTarget() <= 25.0 then
        game_api.castSpellOnTarget(spells.LivingFlame,state.currentTarget)
        return true
    end

    return false
end


function Empower()

    if game_api.currentPlayerIsChanneling() then
        if ( game_api.getCurrentPlayerChannelID() == spells.FireBreath ) and utils.EmpowerRank(game_api.getCurrentPlayerChannelPercentage(),state.chargedSpellsMaxRank) > 0 then
            game_api.castSpell(spells.FireBreath);
            return true
        end

        if ( game_api.getCurrentPlayerChannelID() == spells.Upheaval ) and utils.EmpowerRank(game_api.getCurrentPlayerChannelPercentage(),state.chargedSpellsMaxRank) > 0 then
            game_api.castSpell(spells.Upheaval);
            return true
        end

    end

    return false
end

function Defensive()

    if game_api.hasTalent(talents.RenewingBlaze) and game_api.canCast(spells.RenewingBlaze) and state.currentHpPercent < game_api.getSetting(settings.RenewingBlazePercent) then
        game_api.castSpell(spells.RenewingBlaze)
        return true
    end

    if game_api.hasTalent(talents.ObsidianScales) and game_api.canCast(spells.ObsidianScales) and state.currentHpPercent < game_api.getSetting(settings.ObsidianScalePercent) then
        game_api.castSpell(spells.ObsidianScales)
        return true
    end

    if game_api.getToggle(settings.Dispel) then

        local unitToDispelNaturalize = utils.UnitToDispel("MAGIC","POISON","ALL")
        local unitToDispelCauterizingFlame = utils.UnitToDispel("CURSE","POISON","DISEASE","ALL")

        if (unitToDispelNaturalize) and (game_api.canCast(spells.Naturalize)) then
            game_api.castSpellOnTarget(spells.Naturalize,unitToDispelNaturalize)
            return true
        end
    
        if (unitToDispelCauterizingFlame) and (game_api.canCast(spells.CauterizingFlame)) then
            game_api.castSpellOnTarget(spells.CauterizingFlame,unitToDispelCauterizingFlame)
            return true
        end
    end

    return false
end

--[[
    Run on eatch engine tick if game has focus and is not loading
]]
function OnUpdate()
    
    
    --Augmentation Evoker
    if not game_api.isSpec(396186) then
        return true
    end
    if game_api.getToggle(settings.Pause) then
        return true
    end
    

    StateUpdate()
    
    
    if game_api.currentPlayerIsCasting() or game_api.currentPlayerIsMounted() or game_api.currentPlayerIsChanneling() or game_api.isAOECursor() then
        return
    end

    --BlessingOfTheBronze auto buff
    --if game_api.canCast(spells.BlessingOfTheBronze) and (utils.PartyUnitsCountWithoutAura(auras.BlessingOfTheBronze,40,false) > 0) then
       -- game_api.castSpell(spells.BlessingOfTheBronze);
       -- return true
   -- end

   if Empower() then
        return true
   end

    if Affix() then
        return true
    end

    if Defensive() then
        return true
    end

    if Dps() then
        return true
    end
   

end