
--[[RegisterServerEvent('npc_kill:checkForNPCDeath')
AddEventHandler('npc_kill:checkForNPCDeath', function(npcPed)
    local playerPed = GetPlayerPed(source)
    local originalWantedLevel = GetPlayerWantedLevel(source)

    Wait(5000)  -- Adjust the wait time based on your needs

    local newWantedLevel = GetPlayerWantedLevel(source)

    if newWantedLevel > originalWantedLevel then
        local pos = GetEntityCoords(playerPed)
        TriggerClientEvent('police_chase:spawnPolice', -1, pos.x, pos.y, pos.z)
    end
end)
]]

