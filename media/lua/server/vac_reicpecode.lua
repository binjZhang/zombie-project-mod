require("recipecode")


function Recipe.GetItemTypes.Shoes(scriptItems)
    local allScriptItems = getScriptManager():getAllItems()
    for i = 1, allScriptItems:size() do
        local scriptItem = allScriptItems:get(i - 1)
        if  (scriptItem:getBodyLocation() == "Shoes") then
                scriptItems:add(scriptItem)
        end
    end
end
