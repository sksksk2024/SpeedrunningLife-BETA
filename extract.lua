-- extract.lua (Remodel script)
local game = remodel.readPlaceFile("MyGame.rbxlx")

for _, script in ipairs(game.ServerScriptService.Services:GetChildren()) do
    if script:IsA("ModuleScript") or script:IsA("Script") then
        local content = script.Source
        local filename = script.Name .. ".lua"
        remodel.writeFile("src/Services/" .. filename, content)
        print("Extracted:", filename)
    end
end