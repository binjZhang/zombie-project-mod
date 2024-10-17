require("recipecode")
require("Camping/camping_fuel")

campingFuelType["ClothFuel"] = 50.0 * 15 / 60
campingFuelType["BrokenCloth"] = 15.0 / 60

VacExt2Recipe = {}
VacExt2Recipe.GetItemTypes = {}
VacExt2Recipe.OnCanPerform = {}
VacExt2Recipe.OnCreate = {}
VacExt2Recipe.OnGiveXP = {}
VacExt2Recipe.OnTest = {}

function VacExt2Recipe.GetItemTypes.CanBeBroken(scriptItems)
    local allItems = getScriptManager():getAllItems()
    for i = 1, allItems:size() do
        local item = allItems:get(i - 1)
        if (item:getFabricType() or item:getBodyLocation() == "Shoes") then
        scriptItems:add(item)
        end
    end
end
