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
    if AnyUnitWithoutPrescienceCondition(unit) and game_api.unitIsRole(unit,"DPS") and game_api.getCurrentPlayer() ~= unit then
        ret = true
    end
    return ret
end

function TankWithoutPrescienceCondition(unit)
    local ret = false
    if AnyUnitWithoutPrescienceCondition(unit) and game_api.unitIsRole(unit,"TANK") and game_api.getCurrentPlayer() ~= unit then
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

        if not game_api.currentPlayerHasAura(auras.BlisteringScales,true) then
            game_api.castSpellOnTarget(spells.BlisteringScales,game_api.getCurrentPlayer())
            return true
        end

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

        local unitTankWithoutPrescience = utils.CheckConditionOnUnitList(party,TankWithoutPrescienceCondition)
        if #unitTankWithoutPrescience > 0 then
            game_api.castSpellOnTarget(spells.Prescience,unitTankWithoutPrescience[1])
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

    state.currentHpPercent = game_api.unitHealthPercent(state.currentPlayer)

    state.party = game_api.getPartyUnits()

    state.UpheavalMaxRank = 3
    state.FirebreathMaxRank = 3
    if game_api.hasTalent(talents.FontOfMagic) then
        state.UpheavalMaxRank = 4
        state.FirebreathMaxRank = 4
    end


end


function Affix()
    if game_api.getToggle(settings.Dispel) then
        state.afflictedUnits = game_api.getUnitsByNpcId(204773)

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

function UseTrinkets()
    -- TODO: if current player is moving, skip and continue with rotation till can cast again
    -- TODO: don't cast on end of fight
    if not game_api.isOnCooldown(193743) and not game_api.currentPlayerIsMoving() then
        game_api.castSpell(193743)
        return true
    end

    return false
end

state.FireBreathEmpowerLevel = 1
state.UpheavalEmpowerLevel = 1
function Dps()

    if Prescience(state.party) then
        return true
    end

    if BlisteringScales(state.party) then
        return true
    end

    if state.currentTarget == "00" or not game_api.isTargetHostile(true) or game_api.unitHealthPercent(state.currentTarget) <= 0 then
        return false
    end

    if (game_api.canCast(spells.EbonMight) or game_api.getCooldownRemainingTime(spells.EbonMight) < 5000 ) and not game_api.currentPlayerHasAura(auras.TipTheScales,true) and game_api.canCast(spells.TipTheScales) then
        game_api.castSpell(spells.TipTheScales)
        return true
    end

    if ( game_api.canCast(spells.EbonMight) and ((not game_api.currentPlayerHasAura(auras.EbonMight,true)) or game_api.unitAuraRemainingTime(state.currentPlayer,auras.EbonMight,true) < 4000 )) then
        game_api.castSpell(spells.EbonMight)
        return true
    end

    if ( game_api.canCast(spells.FireBreathFOM) and game_api.currentPlayerHasAura(auras.EbonMight,true) ) and game_api.currentPlayerDistanceFromTarget() <= 25.0  then
        state.FireBreathEmpowerLevel = 4
        game_api.castSpell(spells.FireBreathFOM)
        return true
    end

    if ( game_api.canCast(spells.UpheavalFOM) and game_api.currentPlayerHasAura(auras.EbonMight,true) )  and game_api.currentPlayerDistanceFromTarget() <= 25.0  then
        local rank = 0
        local nbUnit = 0
        for i = 3, 12, 3 do
            local unitCheck = game_api.getUnitCountInRangeFromUnit(state.currentTarget,i,false) + 1
            if unitCheck > nbUnit then
                nbUnit = unitCheck
                rank = i/3
            end
        end

        state.UpheavalEmpowerLevel = rank
        game_api.castSpellOnTarget(spells.UpheavalFOM,state.currentTarget)
        return true
    end

    if game_api.getToggle(settings.Cooldown) then

        --if UseTrinkets() then
            --return true
        --end

        if (game_api.canCast(spells.DeepBreath) and not game_api.isOnCooldown(spells.BreathOfEons)) and game_api.currentPlayerHasAura(auras.EbonMight,true) and game_api.currentPlayerDistanceFromTarget() <= 50.0 then
            game_api.castAOESpellOnTarget(spells.DeepBreath,state.currentTarget)
            return true
        end
    end

    if (not game_api.hasTalent(talents.InterwovenThreads) and game_api.hasTalent(talents.TimeSkip) and game_api.canCast(spells.TimeSkip) and game_api.currentPlayerHasAura(auras.EbonMight,true) ) then
        if (game_api.isOnCooldown(spells.FireBreath) or game_api.isOnCooldown(spells.FireBreathFOM))and (game_api.isOnCooldown(spells.Upheaval) or game_api.isOnCooldown(spells.UpheavalFOM)) and game_api.isOnCooldown(spells.EbonMight) then
            game_api.castSpell(spells.TimeSkip)
            return true
        end
    end

    if game_api.currentPlayerHasAura(auras.LeapingFlames,true) and game_api.canCast(spells.LivingFlame) and game_api.currentPlayerDistanceFromTarget() <= 25.0 then
        game_api.castSpellOnTarget(spells.LivingFlame,state.currentTarget)
        return true
    end

    if game_api.canCast(spells.Disintegrate) and not game_api.isOnCooldown(spells.Eruption) and game_api.currentPlayerHasAura(auras.EbonMight,true) and game_api.currentPlayerDistanceFromTarget() <= 25.0 and ((game_api.currentPlayerHasAura(auras.EssenceBurst,true)) or (state.currentEssence >= 2) ) then
        game_api.castSpellOnTarget(spells.Disintegrate,state.currentTarget)
        return true
    end

    if false and game_api.hasTalent(talents.AncientFlame) and game_api.hasTalent(talents.ScarletAdaptation) and not game_api.currentPlayerHasAura(auras.AncientFlame,true) and not game_api.currentPlayerHasAura(auras.EbonMight,true) then

        if game_api.canCast(spells.VerdantEmbrace) then
            game_api.castSpellOnTarget(spells.VerdantEmbrace,state.currentPlayer)
            return true
        end

        if game_api.canCast(spells.EmeraldBlossom) and state.currentEssence >= 3 then
            game_api.castSpell(spells.EmeraldBlossom)
            return true
        end

    end


    if game_api.canCast(spells.LivingFlame) and game_api.currentPlayerDistanceFromTarget() <= 25.0 then
        game_api.castSpellOnTarget(spells.LivingFlame,state.currentTarget)
        return true
    end

    return false
end


function Empower()

    if game_api.currentPlayerIsChanneling() then
        if ( game_api.getCurrentPlayerChannelID() == spells.FireBreath or game_api.getCurrentPlayerChannelID() == spells.FireBreathFOM ) and utils.EmpowerRank(game_api.getCurrentPlayerChannelPercentage(),state.FirebreathMaxRank) > (state.FireBreathEmpowerLevel - 1) then
            game_api.castSpell(spells.FireBreathFOM);
            return true
        end

        if ( game_api.getCurrentPlayerChannelID() == spells.Upheaval or game_api.getCurrentPlayerChannelID() == spells.UpheavalFOM ) and utils.EmpowerRank(game_api.getCurrentPlayerChannelPercentage(),state.UpheavalMaxRank) > (state.UpheavalEmpowerLevel - 1) then
            game_api.castSpell(spells.UpheavalFOM);
            return true
        end

    end

    return false
end

function Defensive()

    if not game_api.currentPlayerHasAura(auras.BlackAttunement,true) and game_api.canCast(spells.BlackAttunement) and not game_api.isOnCooldown(spells.BronzeAttunement) then
        game_api.castSpell(spells.BlackAttunement);
        return true
    end

    if game_api.hasTalent(talents.RenewingBlaze) and game_api.canCast(spells.RenewingBlaze) and state.currentHpPercent < game_api.getSetting(settings.RenewingBlazePercent) then
        game_api.castSpell(spells.RenewingBlaze)
        return true
    end


    if game_api.hasTalent(talents.ObsidianScales) then
        local canCastObsi = false
        local obsiCharge = game_api.hasTalent(talents.ObsidianBulwark)
        if obsiCharge then
            canCastObsi = game_api.canCastCharge(spells.ObsidianScales,2)
        else
            canCastObsi = game_api.canCast(spells.ObsidianScales)
        end

        if canCastObsi and state.currentHpPercent < game_api.getSetting(settings.ObsidianScalePercent) then
            game_api.castSpell(spells.ObsidianScales)
            return true
        end

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
    --if not game_api.isSpec(396186) then
        --return true
    --end

    --print("--------")
    --print("TRINKET 1 :", game_api.isOnCooldown(193773), game_api.getChargeCountOnCooldown(193773))
    --print("TRINKET 2 :", game_api.isOnCooldown(193791), game_api.getChargeCountOnCooldown(193791))

    if game_api.getToggle(settings.Pause) then
        return true
    end
    

    StateUpdate()
    
    if Empower() then
        return true
    end
    
    if game_api.currentPlayerIsCasting() or game_api.currentPlayerIsMounted() or game_api.currentPlayerIsChanneling() or game_api.isAOECursor() then
        return
    end


    -- BlessingOfTheBronze auto buff
    if game_api.canCast(spells.BlessingOfTheBronze) and not game_api.currentPlayerHasAura(auras.BlessingOfTheBronze,false) then
        game_api.castSpell(spells.BlessingOfTheBronze)
        return true
    end

    --BlessingOfTheBronze auto buff
    --if game_api.canCast(spells.BlessingOfTheBronze) and (utils.PartyUnitsCountWithoutAura(auras.BlessingOfTheBronze,40,false) > 0) then
       -- game_api.castSpell(spells.BlessingOfTheBronze);
       -- return true
   -- end



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