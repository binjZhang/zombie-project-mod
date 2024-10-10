require("recipecode")

--随机发六包薯片
function Recipe.OnCreate.OpenSixPackChip(items, result, player)
    -- print(items)
    --- print(result)
    for i = 1, 6, 1 do
        --local r = result.get(i)
        local ind = ZombRand(4)
        if ind > 0 then
            local chipName = "Base.Crisps" .. tostring(ind + 1)
            player:getInventory():AddItem(chipName)
        else
            player:getInventory():AddItem("Base.Crisps")
        end
        -- remove randCrisps
    end
end

function Recipe.OnCreate.OnPackChips(items, result, player)
    local modData = result:getModData()
    --- record crisps count
    local _counter = {}
    for i=0,items:size() - 1 do
        local item = items:get(i)
        print(item:getFullType())
        if not _counter[item:getFullType()] then
            _counter[item:getFullType()] = 1
        else
            _counter[item:getFullType()] = _counter[item:getFullType()] + 1
        end
    end
    print(_counter)
    modData._counter = _counter
end

function Recipe.OnCreate.OnOpenChipPack(items, result, player)
    local modData = result:getModData()
    --- find crisps count
    local _counter = modData._counter
    if not _counter then
        return
    end
    print(_counter)
    for k, v in pairs(_counter) do
        player:getInventory():AddItems(k, v)
    end
end
