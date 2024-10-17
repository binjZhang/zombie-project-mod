-- override load/reload  magazine action
local replaceMagType = function(player)
    for i = 1, player:getInventory():getItems():size() do
        local wea = player:getInventory():getItems():get(i - 1)
        if instanceof(wea, "HandWeapon") then
            --print("handweapon"..tostring(wea))
            local currMag = wea:getModData()['_MagazineType']
            --print("magazine"..currMag)
            if currMag then
                wea:setMagazineType(currMag)
            end
            local maxAmmo=wea:getModData()['_MaxAmmo']
            if maxAmmo then
             wea:setMaxAmmo(maxAmmo)
            end
        end
    end
end

local doOverwrite =function ()
    print("orverride unloadAmmo")
    require("TimedActions/ISEjectMagazine")
    function findBestMagzine(player, weapon)
        local bestMag = nil
        for i = 1, player:getInventory():getItems():size() do
            local mag = player:getInventory():getItems():get(i - 1)
            if mag:getGunType() == weapon:getFullType() then
                if not bestMag then
                    bestMag = mag
                elseif bestMag:getCurrentAmmoCount() < mag:getCurrentAmmoCount() then
                    bestMag = mag
                end
            end
        end
        return bestMag
    end

    function ISEjectMagazine:unloadAmmo()
        -- get back the magazine if there was one in the gun
        if self.gun:isContainsClip() then
            local magType =  self.gun:getModData()["_MagazineType"]
            if not magType then
                magType=self.gun:getMagazineType()
            end
           
            local newMag = InventoryItemFactory.CreateItem(magType)
            newMag:setCurrentAmmoCount(self.gun:getCurrentAmmoCount())
            self.character:getInventory():AddItem(newMag)
            self.gun:setContainsClip(false)
            self.gun:setCurrentAmmoCount(0)
        
        end
    end

    require("ISUI/ISInventoryPaneContextMenu")

    print("orverride doReloadMenuForWeapon")

    ISInventoryPaneContextMenu.doReloadMenuForWeapon = function(playerObj, weapon, context)
        if weapon:getMagazineType() then
            if weapon:isContainsClip() then -- eject current clip
                context:addOption(getText("ContextMenu_EjectMagazine"), playerObj,
                    ISInventoryPaneContextMenu.onEjectMagazine, weapon);
            else                        -- insert a new clip
                local clip = findBestMagzine(playerObj, weapon);
                local insertOption = context:addOption(getText("ContextMenu_InsertMagazine"), playerObj,
                    ISInventoryPaneContextMenu.onInsertMagazine, weapon, clip);
                if not clip then
                    local clip = InventoryItemFactory.CreateItem(weapon:getMagazineType());
                    insertOption.notAvailable = true;
                    local tooltip = ISInventoryPaneContextMenu.addToolTip();
                    tooltip.description = getText("ContextMenu_NoMagazineFound", clip:getDisplayName());
                    insertOption.toolTip = tooltip;
                else
                    local tooltip = ISInventoryPaneContextMenu.addToolTip();
                    tooltip.description = (getText("ContextMenu_Magazine") .. ": " .. getText(clip:getDisplayName()));
                    insertOption.toolTip = tooltip
                end
            end
        elseif weapon:getAmmoType() then
            ISInventoryPaneContextMenu.doBulletMenu(playerObj, weapon, context)
        end
        if weapon:isJammed() then -- unjam
            context:addOption(getText("ContextMenu_Unjam", weapon:getDisplayName()), playerObj,
                ISInventoryPaneContextMenu.onRackGun, weapon);
        elseif ISReloadWeaponAction.canRack(weapon) then
            local text = weapon:haveChamber() and "ContextMenu_Rack" or "ContextMenu_UnloadRoundFrom"
            context:addOption(getText(text, weapon:getDisplayName()), playerObj, ISInventoryPaneContextMenu.onRackGun,
                weapon);
        end
    end

    print("orverride doReloadMenuForMagazine")

    ISInventoryPaneContextMenu.doReloadMenuForMagazine = function(playerObj, magazine, context)
        local weapons = playerObj:getInventory():getItemsFromCategory("Weapon");
        for i = 1, weapons:size() do
            local weapon = weapons:get(i - 1)
            if weapon:getFullType() == magazine:getGunType() and not weapon:isContainsClip() then
                local insertOption = context:addOption(getText("ContextMenu_InsertMagazine"), playerObj,
                    ISInventoryPaneContextMenu.onInsertMagazine, weapon, magazine);
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = (getText("ContextMenu_GunType") .. ": " .. getText(weapon:getDisplayName()));
                insertOption.toolTip = tooltip;
            end
        end
    end

    require("TimedActions/ISInsertMagazine")

    print("override ISInsertMagazine")
    function ISInsertMagazine:loadAmmo()
        -- we insert a new clip only if we're in the motion of loading
        self.character:getInventory():Remove(self.magazine)
        self.character:removeFromHands(self.magazine)
        self.gun:setCurrentAmmoCount(self.magazine:getCurrentAmmoCount())
        self.gun:setContainsClip(true)
        self.gun:setMagazineType(self.magazine:getFullType())
        -- in case of reload game
        self.gun:getModData()["_MagazineType"]=self.magazine:getFullType()
 
        self.gun:setMaxAmmo(self.magazine:getMaxAmmo())
        self.gun:getModData()['_MaxAmmo']=self.magazine:getMaxAmmo()
        self.character:clearVariable("isLoading")
        -- we rack only if no round is chambered
        if not self.gun:isRoundChambered() and self.gun:getCurrentAmmoCount() >= self.gun:getAmmoPerShoot() then
            ISTimedActionQueue.addAfter(self, ISRackFirearm:new(self.character, self.gun))
        end
        self:forceComplete()
    end

    require("TimedActions/ISReloadWeaponAction")

    print("override BeginAutomaticReload")

    ISReloadWeaponAction.BeginAutomaticReload = function(playerObj, gun)
        if gun:getMagazineType() then
            -- clip inside, pressing R will remove it, other wise we load another
            -- other best magazine
            local bestMag=findBestMagzine(playerObj,gun)
            if gun:isContainsClip() then
                ISTimedActionQueue.add(ISEjectMagazine:new(playerObj, gun))
                -- insert a different non-empty magazine
            end
            if bestMag then
                ISInventoryPaneContextMenu.transferIfNeeded(playerObj, bestMag)
                ISTimedActionQueue.add(ISInsertMagazine:new(playerObj, gun, bestMag))
                return
            end
        else
            -- if can't have more bullets, we don't do anything, this doesn't apply for magazine-type guns (you'll still remove the current clip)
            if gun:getCurrentAmmoCount() >= gun:getMaxAmmo() then
                return
            end
            -- can't load bullet into a jammed gun, clip works tho
            if gun:isJammed() then
                return
            end
            local ammoCount = ISInventoryPaneContextMenu.transferBullets(playerObj, gun:getAmmoType(), gun:getCurrentAmmoCount(), gun:getMaxAmmo())
            if ammoCount == 0 then
                return
            end
            ISTimedActionQueue.add(ISReloadWeaponAction:new(playerObj, gun))
        end
    end
end



Events.OnGameStart.Add(function()
    local p=getPlayer()
    replaceMagType(p)
   doOverwrite()
end)
