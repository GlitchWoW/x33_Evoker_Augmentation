local api_functions = {} -- The main table

function api_functions.currentPlayerName()
    return "PlayerNameTest"
end

function api_functions.currentPlayerIsMoving()
    return false
end

function api_functions.currentPlayerIsMounted()
    return false
end

function api_functions.currentPlayerDistanceFromTarget()
    return 10.0
end

function api_functions.distanceToUnit(unitGuid)
    return 10.0
end

function api_functions.currentPlayerIsCasting()
    return false
end

function api_functions.currentPlayerIsChanneling()
    return false
end

function api_functions.isAOECursor()
    return false
end

function api_functions.currentPlayerCastSpellId()
    return 133
end

function api_functions.isOnCooldown(spellID)
    return false
end

function api_functions.spellIsKnown(spellID)
    return false
end

function api_functions.hasTalent(talentID)
    return false
end

function api_functions.isSpec(specID)
    return false
end

function api_functions.canCast(spellID)
    return false
end

function api_functions.canCastCharge(spellID,maxCharge)
    return false
end

function api_functions.castSpell(spellID)
    return false
end

function api_functions.castSpellOnTarget(spellID,target)
    return false
end

function api_functions.castAOESpellOnTarget(spellID,target)
    return false
end

function api_functions.getUnitCountInRange(range,checkPlayer)
    return 0
end

function api_functions.getUnitCountInRangeFromUnit(unitGuid,range,checkPlayer)
    return 0
end

function api_functions.currentPlayerHasAura(spellID,isLocalPlayerSource)
    return 0
end

function api_functions.currentPlayerAuraRemainingTime(spellID,isLocalPlayerSource)
    return 0
end

function api_functions.unitHasAura(unitGuid,spellID,isLocalPlayerSource)
    return 0
end

function api_functions.unitHealthPercent(unitGuid)
    return 0
end

function api_functions.unitAuraRemainingTime(unitGuid,spellID,isLocalPlayerSource)
    return 0
end

function api_functions.unitAuraElapsedTime(unitGuid,spellID,isLocalPlayerSource)
    return 0
end

function api_functions.unitIsRole(unitGuid,roleName)
    return false
end

function api_functions.getUnitRole(unitGuid)
    return "TANK"
end

function api_functions.getSetting(name)
    return 0
end

function api_functions.createSetting(name,description,value,options)
    return 0
end

function api_functions.createToggle(name,description,value,hotkey)
    return 0
end

function api_functions.getToggle(name)
    return true
end

function api_functions.setToggle(name,value)
    return 0
end

function api_functions.log(message)
    return 0
end

function api_functions.getCurrentUnitTarget()
    return ""
end

function api_functions.getCurrentPlayer()
    return ""
end

function api_functions.getCurrentUnitFocus()
    return ""
end

function api_functions.getCurrentUnitMouseOver()
    return ""
end

function api_functions.getCurrentPlayerCastID()
    return 0
end

function api_functions.getCurrentPlayerCastPercentage()
    return 0.0
end

function api_functions.getCurrentPlayerChannelID()
    return 0
end

function api_functions.getCurrentPlayerChannelPercentage()
    return 0.0
end

function api_functions.getPower(powerIndex)
    return 0
end

function api_functions.getMaxPower(powerIndex)
    return 0
end

function api_functions.getUnitPower(unitGuid,powerIndex)
    return 0
end

function api_functions.getUnitMaxPower(unitGuid,powerIndex)
    return 0
end

function api_functions.isUnitHostile(unitGuid,includeNeutral)
    return false
end

function api_functions.isTargetHostile(includeNeutral)
    return false
end

function api_functions.mousePosition()
    return {}
end

function api_functions.targetPosition()
    return {}
end

function api_functions.isFacing()
    return false
end

function api_functions.getPartyUnits()
    return {}
end

function api_functions.getPartySize()
    return 0
end

function api_functions.isInParty()
    return false
end

function api_functions.unitInCombat(unitGuid)
    return false
end

function api_functions.getPartyUnitsByRole(type)
    return {}
end

function api_functions.getPartyUnitBelowHealthPercent(health,range)
    return {}
end

function api_functions.getPartyUnitAboveHealthPercent(health,range)
    return {}
end

function api_functions.getPartyUnitWithRoleBelowHealthPercent(health,range,role)
    return {}
end

function api_functions.getPartyUnitWithRoleAboveHealthPercent(health,range,role)
    return {}
end

function api_functions.totemExist(iconId)
    return false
end

function api_functions.distanceBetweenUnits(unitGuid1,unitGuid2)
    return 0.0
end

function api_functions.unitAuraStackCount(unitGuid,spellId,isSource)
    return 0
end

function api_functions.unitDebuffRemainingTime(unitGuid,spellId)
    return 0
end

function api_functions.unitDebuffListWithDispelType(unitGuid,dispelType)
    return {}
end

function api_functions.unitDebuffList(unitGuid)
    return {}
end

function api_functions.unitIsSpec(unitGuid,specId)
    return false
end

function api_functions.unitIsCC(unitGuid)
    return false
end

function api_functions.getChargeCountOnCooldown(spellId)
    return 0
end

function api_functions.getCooldownRemainingTime(spellId)
    return 0
end

function api_functions.getUnitsByNpcId(npcId)
    return {}
end

function api_functions.unitIsCasting(unitGuid)
    return false
end

function api_functions.unitCastingSpellID(unitGuid)
    return 0
end

function api_functions.unitIsChanneling(unitGuid)
    return false
end

function api_functions.unitChannelingSpellID(unitGuid)
    return 0
end



return api_functions