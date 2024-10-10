require("recipecode")

--随机发六包薯片
function Recipe.OnCreate.OpenSixPackChip(items, result, player)
   -- print(items)
   --- print(result)
    for i = 1, 6,1 do
        --local r = result.get(i)
        local ind = ZombRand(4)
        if ind  > 0 then
            local chipName = "Base.Crisps" .. tostring(ind+1)
            player:getInventory():AddItem(chipName)
        else
            player:getInventory():AddItem("Base.Crisps")
        end
    -- remove randCrisps   
    end
end