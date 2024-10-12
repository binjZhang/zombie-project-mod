require("recipecode")

function getReloadKitMaxAmmoCount()
    -- TODO get from sandbox variable
    return 200
end

function Recipe.OnCreate.OnMakeReloadKit(items, result)
    local bulletInMag = 0

    for i = 1, items:size() do
        local item = items:get(i - 1)
        if item:getCurrentAmmoCount() > 0 then
            bulletInMag = bulletInMag + item:getCurrentAmmoCount()
        end
    end
    if result then
        result:getModData()["_MaxAmmo"] = getReloadKitMaxAmmoCount()
        result:setCurrentAmmoCount(bulletInMag)
    end
end

function Recipe.OnCreate.OnExpandClip(items, result, player)
    local ammoCount = 0
    for mag in items do
        if mag:getCurrentAmmoCount() > 0 then
            if mag:getAmmoType() == result:getAmmoType() then
                ammoCount = ammoCount + mag:getCurrentAmmoCount()
            else
                for i = 1, i:getCurrentAmmoCount() do
                    local newBullet = InventoryItemFactory.CreateItem(item:getAmmoType())
                    player:getInventory():AddItem(newBullet)
                end
            end
        end
    end
    if ammoCount > 0 then
        if ammoCount <= result:getMaxAmmo() then
            result:setCurrentAmmoCount(ammoCount)
        else
            result:setCurrentAmmoCount(result:getMaxAmmo())
            for i = 1, ammoCount - result:getMaxAmmo() do
                local newBullet = InventoryItemFactory.CreateItem(result:getAmmoType())
                player:getInventory():AddItem(newBullet)
            end
        end
    end
end
