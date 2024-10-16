require("recipecode")

VacExt1Recipe = {}
VacExt1Recipe.GetItemTypes = {}
VacExt1Recipe.OnCanPerform = {}
VacExt1Recipe.OnCreate = {}
VacExt1Recipe.OnGiveXP = {}
VacExt1Recipe.OnTest = {}

function getMaxAmmo()
    return 200
end

function VacExt1Recipe.OnCreate.OnMakeReloadKit(items, result, player)
    local count = 0
    local ammoType = result:getModData()["_AmmoType"]
    for i = 1, items:size() do
        local item = items:get(i - 1)
        local curr = item:getCurrentAmmoCount()
        if curr > 0 then
            if item:getAmmoType() == ammoType then
                count = count + curr
            else
                for j = 0, curr do
                    local newBullet = InventoryItemFactory.CreateItem(item:getAmmoType())
                    player:getInventory():AddItem(newBullet)
                end
            end
        end
    end
    if count > 0 then
        result:setCurrentAmmoCount(count)
    end
    result:getModData()["_MaxAmmo"] = getMaxAmmo()
    result:setTooltip(getText("Tooltip_weapon_AmmoCount") ..
    ": " .. result:getCurrentAmmoCount() .. "/" .. result:getModData()["_MaxAmmo"])
end

function VacExt1Recipe.OnCreate.OnExpandClip(items, result, player)
    local count = 0
    local ammoType = result:getAmmoType()
    for i = 1, items:size() do
        local item = items:get(i - 1)
        local curr = item:getCurrentAmmoCount()
        if curr > 0 then
            if item:getAmmoType() == ammoType then
                count = count + curr
            else
                for j = 0, curr do
                    local newBullet = InventoryItemFactory.CreateItem(item:getAmmoType())
                    player:getInventory():AddItem(newBullet)
                end
            end
        end
    end
    if count > 0 then
        result:setCurrentAmmoCount(count)
    end
end
