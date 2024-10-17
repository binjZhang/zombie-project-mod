local onCutCorpse = function(player, corpseList)
    print(corpseList)
    for i=1,corpseList:size() do
        player:getInventory():AddItems("VacModExt2.RottedMeat",2)
        player:getInventory():Remove(corpseList:get(i-1))
    end
end

local AddOptionOnFillCorpse = function(player, context, corpseList)
    if corpseList:isEmpty() then
        return
    end
    if corpseList:size() == 1 then
        context:addOption(getText("ContextMenu_Cut_Corpse"), player, onCutCorpse, corpseList)
        return
    end
    context:addOption(getText("ContextMenu_Cut_Corpse_Count", corpseList:size()), player, onCutCorpse, corpseList)
end

Events.OnGameStart.Add(function()
    Events.OnFillInventoryObjectContextMenu.Add(function(playerNum, context, items)
        local selectItems = ISInventoryPane.getActualItems(items)
        local player = getSpecificPlayer(playerNum)
        if not player or not selectItems then
            return
        end
        local corpseList = ArrayList:new()
        for _, item in pairs(selectItems) do
            if item:getFullType() == "Base.CorpseMale" or item:getFullType() == "Base.CorpseFemale" then
                corpseList:add(item)
            end
        end
        if corpseList:isEmpty() then
            return
        end
        AddOptionOnFillCorpse(player, context, corpseList)
    end
    )
    -- Events.OnFillWorldObjectContextMenu.Add(function(playerNum, context, worldItems)
    --     local player = getSpecificPlayer(playerNum)
    --     local corpseList = ArrayList:new()
    --     for i, object in ipairs(worldItems) do
    --         if i > 1 then
    --             print(object)
    --             local body=nil
    --             if instanceof(object, "IsoDeadBody") then
    --                 body = object
    --             end
    --             if not body then
    --                 local square=object:getSquare()
    --                 body = square:getDeadBody()
    --                 print(body)
    --             end
    --             if body then
    --                 corpseList:add(body)
    --             end
    --         end
    --     end

    --     if corpseList:isEmpty() then
    --         return
    --     end
    --     AddOptionOnFillCorpse(player, context, corpseList)
    -- end
    -- )
end)
