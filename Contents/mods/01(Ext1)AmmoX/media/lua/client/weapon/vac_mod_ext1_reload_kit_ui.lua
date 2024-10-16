require "Context/ISContextManager"
print("load vac_mod_ext1_reload_kit_ui script")
-- TODO need animation
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
    reloadKit:setTooltip(getText("Tooltip_weapon_AmmoCount") ..
        ": " .. reloadKit:getCurrentAmmoCount() .. "/" .. reloadKit:getModData()["_MaxAmmo"])
end

local TransferBulletToMagazineAction = function(player, reloadKit, magazine)
    if reloadKit:getModData()["_AmmoType"] == magazine:getAmmoType()
        and reloadKit:getCurrentAmmoCount() > 0
        and magazine:getCurrentAmmoCount() < magazine:getMaxAmmo()
    then
        if reloadKit:hasTag("ReloadKit") then
            -- do transfer
            -- TODO take in hands
            local ammoCountInKit = reloadKit:getCurrentAmmoCount()
            local magazineNeed = magazine:getMaxAmmo() - magazine:getCurrentAmmoCount()
            local needToTransferCount = math.min(magazineNeed, ammoCountInKit)
            reloadKit:setCurrentAmmoCount(reloadKit:getCurrentAmmoCount() - needToTransferCount)
            magazine:setCurrentAmmoCount(magazine:getCurrentAmmoCount() + needToTransferCount)
            -- print(reloadKit:getModData()["_MaxAmmo"])
            -- print(reloadKit:getCurrentAmmoCount())
        end
    end

    reloadKit:setTooltip(getText("Tooltip_weapon_AmmoCount") ..
        ": " .. reloadKit:getCurrentAmmoCount() .. "/" .. reloadKit:getModData()["_MaxAmmo"])
end

local TransferBulletToAllMagazineAction = function(player, reloadKit, magazines)
    for i = 1, magazines:size() do
        local mag = magazines:get(i - 1)
        TransferBulletToMagazineAction(player, reloadKit, mag)
    end

    reloadKit:setTooltip(getText("Tooltip_weapon_AmmoCount") ..
        ": " .. reloadKit:getCurrentAmmoCount() .. "/" .. reloadKit:getModData()["_MaxAmmo"])
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

    reloadKit:setTooltip(getText("Tooltip_weapon_AmmoCount") ..
        ": " .. reloadKit:getCurrentAmmoCount() .. "/" .. reloadKit:getModData()["_MaxAmmo"])
end

local AddOptionForReloadKit = function(player, reloadKit, context)
    local maxAmmoCount = reloadKit:getModData()["_MaxAmmo"]
    local ammoCount = reloadKit:getCurrentAmmoCount()
    if not maxAmmoCount or ammoCount >= maxAmmoCount then
        return
    end
    local ammoType = reloadKit:getModData()["_AmmoType"]
    if not ammoType then
        return
    end
    local bulletsInInventory = player:getInventory():getItemCountRecurse(ammoType);
    if bulletsInInventory > 0 then
        local insertCount = math.min(bulletsInInventory, maxAmmoCount - ammoCount)
        local text = getText("ContextMenu_Reload_Kit_Bullets", insertCount)
        context:addOption(text, player, InertIntoReloadKitAction, reloadKit)
    end
    if ammoCount > 0 then
        local text = getText("ContextMenu_Remove_From_Kit", ammoCount)
        context:addOption(text, player, UnloadFromKitAction, reloadKit)
    end
end

local AddOptionForTransBullet = function(player, reloadKit, context)
    local ammoCount = reloadKit:getCurrentAmmoCount()
    if not ammoCount or ammoCount <= 0 then
        return
    end
    local ammoType = reloadKit:getModData()["_AmmoType"]
    local notMaxMags = ArrayList:new()
    -- get magazine
    for i = 1, player:getInventory():getItems():size() do
        local invItem = player:getInventory():getItems():get(i - 1)
        if invItem:getAmmoType() and invItem:getAmmoType() == ammoType
            and invItem:getGunType() and invItem:getCurrentAmmoCount() < invItem:getMaxAmmo() then
            notMaxMags:add(invItem)
        end
    end
    if notMaxMags:size() == 1 then
        local first = notMaxMags:get(0)
        local text = getText("ContextMenu_Transfer_Kit_2_Mag",
            math.min(ammoCount, first:getMaxAmmo() - first:getCurrentAmmoCount()))
        context:addOption(text, player, TransferBulletToMagazineAction, reloadKit, first)
    elseif notMaxMags:size() > 1 then
        context:addOptionOnTop(getText("ContextMenu_Transfer_Kit_2_Mag_All"), player, TransferBulletToAllMagazineAction,
            reloadKit, notMaxMags)
    end
end

local OnFillReloadKitAction = function(playerNum, context, items)
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
            AddOptionForReloadKit(player, reloadKit, context)
            AddOptionForTransBullet(player, reloadKit, context)
            context:addOptionOnTop(getText("ContextMenu_Reload_kit_Current_Count", reloadKit:getCurrentAmmoCount()), nil)
        end
    end
end

-- Add Event


Events.OnGameStart.Add(function()
    Events.OnFillInventoryObjectContextMenu.Add(OnFillReloadKitAction)
end)
