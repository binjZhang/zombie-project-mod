require "Context/ISContextManager"
print("load vac_mod_ext1_reload_kit_ui script")

local InertIntoReloadKitAction = function(player, reloadKit)
    local ammoCount = reloadKit:getCurrentAmmoCount()
    local ammoType = reloadKit:getModData()["_AmmoType"]
    local maxAmmoCount = reloadKit:getModData()["_MaxAmmo"]
    local bulletsInInventory = player:getInventory():getItemCountRecurse(ammoType);
    local needToInsertCount = maxAmmoCount - ammoCount
    if needToInsertCount > 0 and bulletsInInventory > 0 then
        local actInsertCount = math.min(needToInsertCount, bulletsInInventory)
        reloadKit:setCurrentAmmoCount(ammoCount + actInsertCount)
        for i = 1, actInsertCount, 1 do
            player:getInventory():RemoveOneOf(ammoType)
        end
    end

end

local TransferBulletToMagazineAction = function(player, reloadKit, magazine)
    if reloadKit:getModData()["_AmmoType"] == magazine:getAmmoType()
            and reloadKit:getCurrentAmmoCount() > 0
            and magazine:getCurrentAmmoCount() < magazine:getMaxAmmo()
    then
        if reloadKit:hasTag("ReloadKit") then
            -- do transfer
            local ammoCountInKit = reloadKit:getCurrentAmmoCount()
            local magazineNeed = magazine:getMaxAmmo() - magazine:getCurrentAmmoCount()
            local needToTransferCount = math.min(magazineNeed, ammoCountInKit)
            reloadKit:setCurrentAmmoCount(reloadKit:getCurrentAmmoCount() - needToTransferCount)
            magazine:setCurrentAmmoCount(magazine:getCurrentAmmoCount() + needToTransferCount)
            print(reloadKit:getModData()["_MaxAmmo"])
            print(reloadKit:getCurrentAmmoCount())
        end
    end
end

local TransferBulletToAllMagazineAction = function(player, reloadKit, magazines)
    for i = 1, magazines:size() do
        local mag = magazines:get(i - 1)
        TransferBulletToMagazineAction(player, reloadKit, mag)
    end
end

local UnloadFromKitAction = function(player, reloadKit)
    local ammoCount = reloadKit:getCurrentAmmoCount()
    local ammoType = reloadKit:getModData()["_AmmoType"]
    if ammoCount <= 0 or not ammoType then
        return
    end
    reloadKit:setCurrentAmmoCount(0)
    for i = 1, ammoCount do
        local newBullet = InventoryItemFactory.CreateItem(ammoType)
        player:getInventory():AddItem(newBullet)
    end
end

-- Add Event


Events.OnGameStart.Add(function()
    Events.OnFillInventoryObjectContextMenu.Add(function(playerNum, context, items)
        --print(item:getFullType())
        --- print(selectItems:getFullType())
        local selectItems = ISInventoryPane.getActualItems(items)
        local player = getSpecificPlayer(playerNum)
        if not player or not selectItems then
            return
        end
        for _, v in pairs(selectItems) do
            if v:hasTag("ReloadKit") then
                local reloadKit = v
                local maxAmmoCount = reloadKit:getModData()["_MaxAmmo"]
                local ammoCount = reloadKit:getCurrentAmmoCount()
                local ammoType = reloadKit:getModData()["_AmmoType"]
                print(ammoType)
                print(maxAmmoCount)
                local bulletsInInventory = player:getInventory():getItemCountRecurse(ammoType);
                print("bullets count " .. tostring(bulletsInInventory))
                local needToInsertCount = maxAmmoCount - ammoCount
                if needToInsertCount > 0 and bulletsInInventory > 0 then
                    local actInsertCount = math.min(needToInsertCount, bulletsInInventory)
                    local text = getText("ContextMenu_Reload_Kit_Bullets", actInsertCount)
                    context:addOption(text, player, InertIntoReloadKitAction, reloadKit)
                end
                if ammoCount > 0 then
                    local text = getText("ContextMenu_Remove_From_Kit", ammoCount)
                    context:addOption(text, player, UnloadFromKitAction, reloadKit)
                end
                local notEmptyMag = ArrayList:new()
                -- same ammoType magazine
                for i = 1, player:getInventory():getItems():size() do
                    local invItem = player:getInventory():getItems():get(i - 1)
                    if invItem:getAmmoType() and invItem:getAmmoType() == ammoType
                            and invItem:getGunType() then
                        if not invItem:hasTag("ReloadKit") then
                            -- avoid loading between two reloadKit
                            local needToTrans = invItem:getMaxAmmo() - invItem:getCurrentAmmoCount()
                            if needToTrans > 0 and reloadKit:getCurrentAmmoCount() > 0 then
                                local transCount = math.min(needToTrans, reloadKit:getCurrentAmmoCount())
                                local text = getText("ContextMenu_Transfer_Kit_2_Mag", transCount)
                                context:addOption(text, player, TransferBulletToMagazineAction, reloadKit, invItem)
                                notEmptyMag:add(invItem)
                            end
                        end
                    end
                end
                if notEmptyMag:size() > 1 then
                    context:addOptionOnTop(getText("ContextMenu_Transfer_Kit_2_Mag_All"), player, TransferBulletToAllMagazineAction, reloadKit, notEmptyMag)
                end
                context:addOptionOnTop(getText("ContextMenu_Reload_kit_Current_Count",reloadKit:getCurrentAmmoCount()),nil)
            end
        end
    end)
end)