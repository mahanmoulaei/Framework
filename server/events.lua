function onPlayerConnecting(name, setKickReason, deferrals)
    local src = source
    local license = Framework.GetIdentifier(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'frameworkadmin.join') then
            deferrals.done(Config.Server.ClosedReason)
        end
    end

    deferrals.update(_Locale('checking_ban', name))

    -- Mandatory wait
    Wait(2500)

	deferrals.update(_Locale('checking_whitelisted', name))

    local isBanned, Reason = Framework.IsPlayerBanned(src)
    local isLicenseAlreadyInUse = Framework.IsLicenseInUse(license)
    local isWhitelist, whitelisted = Config.Server.Whitelist, Framework.IsWhitelisted(src)

    Wait(2500)

	deferrals.update(_Locale('join_server', name, Config.Server.Name))

    if not license then
	  deferrals.done(_Locale('no_valid_license'))
    elseif isBanned then
        deferrals.done(Reason)
    elseif isLicenseAlreadyInUse and Config.Server.CheckDuplicateLicense then
		deferrals.done(_Locale('duplicate_license'))
    elseif isWhitelist and not whitelisted then 
		deferrals.done(_Locale('not_whitelisted'))
    else
        RemoveCommmandPermissionForPlayer(src)
        deferrals.done()
        if Config.Server.UseConnectQueue then
            Wait(1000)
            TriggerEvent('connectqueue:playerConnect', name, setKickReason, deferrals)
        end
    end
end

AddEventHandler('playerConnecting', onPlayerConnecting) -- Default FiveM Event

function RemoveCommmandPermissionForPlayer(source)
	local identifiers = GetPlayerIdentifiers(source)
    for i in ipairs(identifiers) do
        ExecuteCommand(('remove_ace identifier.%s command allow'):format(identifiers[i]))
		ExecuteCommand(('add_ace identifier.%s command deny'):format(identifiers[i]))
    end
end

if Config.MultiCharacter then
	--[[Would not be implemented for now]]
else
	RegisterNetEvent('Framework:onPlayerJoined')
	AddEventHandler('Framework:onPlayerJoined', function()
		while not next(Framework.Jobs) do Wait(50) end
		if not Framework.Players[source] then
			onPlayerJoined(source)
		end
	end)
end

function onPlayerJoined(source)
	local identifier = Framework.GetIdentifier(source)
	if identifier then
		if Framework.IsLicenseInUse(identifier) then
            Framework.Kick(source, _Locale('duplicate_license'), nil, nil)
        else
            Core.Player.Login(source, identifier)
		end
	else
        Framework.Kick(source, _Locale('no_valid_license'), nil, nil)
	end
end

RegisterNetEvent('Framework:updateCoords')
AddEventHandler('Framework:updateCoords', function(coords, src)
    local _source = src or source
	local xPlayer = Framework.GetPlayerFromId(_source)
	if xPlayer then
		xPlayer.updatePosition(coords)
	end
end)

RegisterNetEvent('Framework:setJob')
AddEventHandler('Framework:setJob', function(source, newJob, lastJob)
    
end)

RegisterNetEvent('Framework:setGang')
AddEventHandler('Framework:setGang', function(source, newGang, lastGang)
    
end)

RegisterNetEvent('Framework:onAddInventoryItem')
AddEventHandler('Framework:onAddInventoryItem', function(source, itemName, itemCount)
    
end)

RegisterNetEvent('Framework:onRemoveInventoryItem')
AddEventHandler('Framework:onRemoveInventoryItem', function(source, itemName, itemCount)
    
end)

RegisterNetEvent('Framework:setDuty')
AddEventHandler('Framework:setDuty', function(bool)
    local xPlayer = Framework.GetPlayerFromId(source)
    if xPlayer.job.onDuty == bool then return end
    
    if bool then
        xPlayer.setDuty(true)
        xPlayer.triggerEvent('Framework:showNotification', _Locale('started_duty'))
    else
        xPlayer.setDuty(false)
        xPlayer.triggerEvent('Framework:showNotification', _Locale('stopped_duty'))
    end
    TriggerClientEvent('Framework:setJob', xPlayer.source, xPlayer.job)
end)

RegisterNetEvent('Framework:playerLoaded')
AddEventHandler('Framework:playerLoaded', function(source, xPlayer, isNew)
    Framework.Players[source] = xPlayer
end)

AddEventHandler('playerDropped', function(reason)
	local _source = source
	local xPlayer = Framework.GetPlayerFromId(_source)

	if xPlayer then
		TriggerEvent('Framework:playerDropped', _source, reason)

		Core.SavePlayer(xPlayer, function()
			Framework.Players[_source] = nil
		end)
	end
end)

RegisterNetEvent('Framework:playerDropped')
AddEventHandler('Framework:playerDropped', function(source, reason)
    
end)

RegisterServerEvent('Framework:triggerServerCallback')
AddEventHandler('Framework:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	Framework.TriggerServerCallback(name, requestId, _source, function(...)
		TriggerClientEvent('Framework:serverCallback', _source, requestId, ...)
	end, ...)
end)
