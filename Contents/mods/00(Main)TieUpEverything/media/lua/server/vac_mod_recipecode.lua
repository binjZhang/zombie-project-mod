require("recipecode")
require("Camping/camping_fuel")

camping_fuel["VacMod.ClothFuel"] = 50 * 15

VacModRecipe = {}
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

function VacModRecipe.GetItemTypes.CanBeBroken(scriptItems)
    local Cotton = "Cotton"
    local Denim = "Denim"
    local Leather = "Leather"
    if (scriptItem:getType() == Type.Clothing) then
        if (scriptItem:getFabricType() == Cotton or scriptItem:getFabricType() == Denim or scriptItem:getFabricType() == Leather) then
            if ClothingRecipesDefinitions[scriptItem:getName()] then
                -- ignore
            else
                scriptItems:add(scriptItem)
            end
        elseif (scriptItem:getBodyLocation() == "Shoes") then
            scriptItems:add(scriptItem)
        end
    end
end
