script_properties('work-in-pause', 'forced-reloading-only')

local weapons = {}
local currentWeaponSlot = 0
local currentWeapon = 0
require("widgets")

function main()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if isWidgetSwipedLeft(WIDGET_PLAYER_INFO) then
            currentWeaponSlot = findNextMeleeSlot(currentWeaponSlot, 1)
            currentWeapon = 0
            for k, v in ipairs(weapons) do
                if v.slot == currentWeaponSlot then
                    currentWeapon = v.id
                end
            end
        end
        if isWidgetSwipedRight(WIDGET_PLAYER_INFO) then
            currentWeaponSlot = findNextMeleeSlot(currentWeaponSlot, -1)
            currentWeapon = 0
            for k, v in ipairs(weapons) do
                if v.slot == currentWeaponSlot then
                    currentWeapon = v.id
                end
            end
        end
        
        if currentWeapon ~= 0 and getCurrentCharWeapon(PLAYER_PED) ~= 0 and getAmmoInCharWeapon(PLAYER_PED, getCurrentCharWeapon(PLAYER_PED)) <= 0 then removeWeaponById(currentWeapon) end
        if getWeapontypeSlot(getCurrentCharWeapon(PLAYER_PED)) ~= getWeapontypeSlot(currentWeapon) then
            giveWeaponToChar(PLAYER_PED, currentWeapon, 0)
        end
    end
end

local MIN_SLOT, MAX_SLOT = 0, 12

function hasWeaponInSlot(slotIndex)
	for _, w in ipairs(weapons) do
		if w.slot == slotIndex then
			return true
		end
	end
	return slotIndex == 0
end

function findNextMeleeSlot(currentSlot, dir)
	local total = (MAX_SLOT - MIN_SLOT + 1)
	for i = 1, total do
		local s = ((currentSlot - MIN_SLOT + dir * i) % total) + MIN_SLOT
		if hasWeaponInSlot(s) then
			return s
		end
	end
	return currentSlot
end

function removeWeaponById(weaponId)
    local newWeapons = {}
    for _, v in ipairs(weapons) do
        if v.id ~= weaponId then
            table.insert(newWeapons, v)
        end
    end
    weapons = newWeapons
    currentWeapon = 0
end

require('lib.samp.events').onGivePlayerWeapon = function(weaponId, ammo)
    local replaced = false
    for k, v in ipairs(weapons) do
        if v.slot == getWeapontypeSlot(weaponId) then
            v.id, v.slot = weaponId, getWeapontypeSlot(weaponId)
            replaced = true
        end
    end
    if not replaced then table.insert(weapons, {id = weaponId, slot = getWeapontypeSlot(weaponId)}) end
    currentWeapon = weaponId
    currentWeaponSlot = getWeapontypeSlot(weaponId)
end

require('lib.samp.events').onResetPlayerWeapons = function()
    weapons = {}
end

