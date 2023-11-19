local isShooting = false
local spawnedPed = false
local officerDead = false
local respawnDelay = 60000
local officerPed = nil
local vehicle = nil -- Declare the vehicle variable outside the functions

RegisterNetEvent('police_chase:playerIsShooting')
AddEventHandler('police_chase:playerIsShooting', function(shooting)
    isShooting = shooting
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)

        local playerPed = GetPlayerPed(-1)

        if IsPedShooting(playerPed) then
            isShooting = true
        else
            isShooting = false
        end

        if isShooting and not spawnedPed and not officerDead then
            local pos = GetEntityCoords(playerPed, true)
            local spawnPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 100.0, 0.0)

            -- Check if any player with the job "police" is on duty
            SpawnPolice(pos.x, pos.y, pos.z)
            isShooting = false
            spawnedPed = true
            Wait(1000)  -- Wait to avoid spawning multiple times in quick succession
        end

        if officerDead and not isShooting then
            Wait(respawnDelay)
            CleanupAndRespawn()
        end
    end
end)

function SpawnPolice(x, y, z)
    print('Spawning Police Car and Officer at:', x, y, z)

    local playerID = PlayerId()
    local playerPed = GetPlayerPed(playerID)

    local spawnPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 100.0, 0.0)

    local vehicleHash = GetHashKey('fbi')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(500)
    end

    vehicle = CreateVehicle(vehicleHash, 407.5, -1005.32, 29.27, 124.79, true, false)

    -- Start the siren and lights
    SetVehicleSiren(vehicle, true)

    officerPed = CreatePedInsideVehicle(vehicle, 4, GetHashKey("u_m_m_fibarchitect"), -1, true, false)
    
    TaskWarpPedIntoVehicle(officerPed, vehicle, -1)

    GiveWeaponToPed(officerPed, GetHashKey("weapon_smg"), 200, false, true)

    SetPedArmour(officerPed, 75)

    TaskVehicleDriveToCoord(officerPed, vehicle, x, y, z, 30.0, 1.0, GetEntityModel(vehicle), 786603, 10.0)

    local blip = AddBlipForEntity(vehicle)
    SetBlipSprite(blip, 56)
    SetBlipColour(blip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police ChasingCar")
    EndTextCommandSetBlipName(blip)

    while not IsVehicleStopped(vehicle) do
        Wait(500)
    end

    TaskLeaveVehicle(officerPed, vehicle, 0)
    TaskCombatPed(officerPed, playerPed, 0, 16)

    while not IsEntityDead(officerPed) do
        Wait(500)
    end

    -- Stop the siren and lights when the officer is dead
    SetVehicleSiren(vehicle, false)

    officerDead = true
end


function CleanupAndRespawn()
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end

    if DoesEntityExist(officerPed) then
        SetEntityAsMissionEntity(officerPed, true, true)
        DeleteEntity(officerPed)
    end

    officerDead = false
    spawnedPed = false
end
