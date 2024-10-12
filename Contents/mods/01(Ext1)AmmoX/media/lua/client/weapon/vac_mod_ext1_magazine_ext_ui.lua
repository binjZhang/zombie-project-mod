
local NewFindBestMagazine = function(weapon, player)
    -- when press reload Key ，will find all magazine with the ammoType and gunType
    local ammoType = weapon:getAmmoType()
    local bestMagazine = nil
    for i in player:getInventory():getItems() do
        if i:getAmmoType() == ammoType and i:getGunType() == weapon:getFullType()
                and i:getMaxAmmo() > 0 and i:getCurrentAmmoCount() > 0 then
            if bestMagazine == nil then
                bestMagazine = i
            elseif bestMagazine:getCurrentAmmoCount() < i:getCurrentAmmoCount() then
                bestMagazine = i
            end
        end
    end
    return bestMagazine
end

local ReplaceBestMagazine = function(_, weapon)
    if not instanceof(weapon, "HandWeapon") then
        return
    end
    weapon.getBestMagazine = NewFindBestMagazine
end

-- replace getBestMagazine method
Events.OnGameStart.Add(function()
    Events.OnEquipPrimary.Add(ReplaceBestMagazine)
end)