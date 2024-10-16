require("recipecode")
VacModRecipe={}
VacModRecipe.GetItemTypes = {}
VacModRecipe.OnCanPerform = {}
VacModRecipe.OnCreate = {}
VacModRecipe.OnGiveXP = {}
VacModRecipe.OnTest = {}

function VacModRecipe.OnCreate.OnCrateMagazine(items, result, player)
    for i = 1, items:size() do
        local mag = items:get(i - 1)
        if mag:getCurrentAmmoCount() > 0 then
            local ammoType = mag:getAmmoType()
            for j = 1, mag:getCurrentAmmoCount() do
                local newBullet = InventoryItemFactory.CreateItem(ammoType)
                player:getInventory():AddItem(newBullet)
            end
        end
    end
end