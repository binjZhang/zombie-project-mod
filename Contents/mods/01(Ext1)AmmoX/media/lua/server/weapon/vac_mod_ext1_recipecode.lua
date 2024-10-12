require("recipecode")

function getReloadKitMaxAmmoCount()
    -- TODO get from sandbox variable
    return 200
end

function Recipe.OnCreate.OnMakeReloadKit(items, result)
    local bulletInMag = 0

    for i = 1, items:size() do
        local item=items:get(i-1)
        if item:getCurrentAmmoCount() > 0 then
            bulletInMag=bulletInMag+item:getCurrentAmmoCount()
        end
    end
    if result then
        result:getModData()["_MaxAmmo"]=getReloadKitMaxAmmoCount()
        result:setCurrentAmmoCount(bulletInMag)
    end
end