require("recipecode")

--随机发六包薯片
function Recipe.OnCreate.OpenSixPackChip(items, result, player, selectedItem)
    for i = 1, 6 do
        local ind = ZombRand(4)
        local chipName = "Crisps"
        if ind  > 0 then
            chipName = chipName + (ind+1)
        end
        player:getInventory():AddItem("Base." + chipName);
    end
end