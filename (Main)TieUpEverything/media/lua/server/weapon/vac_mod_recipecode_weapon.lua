require("recipecode")

function Recipe.OnCreate.OnMakeClip(items, result, player)
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item:getGunType() then
            local ammoType = item:getAmmonType()
            local count = item:getCurrentAmmoCount()
            if ammoType and count > 0 then
                player:getInventory():AddItems(ammoType:getFullType(), count)
            end
        end
    end
end

function Recipe.OnTest.ReloadMagazine(item)
    if not item then
        return true
    end
    if not item:getGunType() then
        return true
    end
    return item:getCurrentAmmoCount() < item:getMaxAmmo()
end

function Recipe.OnCreate.ReloadMagazine(items, result, player)
    for i=0,items:size() - 1 do
        local item=items:get(i)
        if  item and item:getGunType() then

        end
    end

end