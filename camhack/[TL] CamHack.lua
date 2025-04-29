require("ArizonaAPI")

local lua_thread = require("lts")
local json = require("cjson")
local ffi = require("ffi")

local message_color = 0x009EFFFF

local camhack_active = false
local camhack_speed = 0.2

local posX
local posY
local posZ
local angZ
local angY
local radZ
local radY
local sinZ
local cosZ
local sinY
local cosY
local poiX
local poiY
local poiZ
local curZ
local curY

local settings = {}
local default_settings = {
	general = {
		enable = true,
		hud = true,
		chat_bubble = false,
		hide_nick = false,
		camhack_type = 1
	},
	binds = {
		activate = '[18, 67]',
		disable = '[18, 86]',
		foward = '[87]',
		back = '[83]',
		left = '[65]',
		right = '[68]',
		left_foward = '[81]',
		right_foward = '[69]',
		up = '[16]',
		down = '[17]',
		speed_plus = '[187]',
		speed_minus = '[189]',
		hud = '[121]'
	}
}
local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/config"
local path = configDirectory .. "/CamHack_Settings.json"
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path) then
        settings = default_settings
		print('[CamHack V3] Файл с настройками не найден, использую стандартные настройки!')
    else
        local file = io.open(path, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
			else
				local result, loaded = pcall(json.decode, contents)
				if result then
					settings = loaded
					for category, _ in pairs(default_settings) do
						if settings[category] == nil then
							settings[category] = {}
						end
						for key, value in pairs(default_settings[category]) do
							if settings[category][key] == nil then
								settings[category][key] = value
							end
						end
					end
					print('[CamHack V3] Настройки успешно загружены!')
				else
					print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('[CamHack V3] Не удалось открыть файл с настройками, использую стандартные настройки!')
        end
    end
end
function save_settings()
    local file, errstr = io.open(path, 'w')
    if file then
        local result, encoded = pcall(json.encode, settings)
        file:write(result and encoded or "")
        file:close()
        return result
    else
        print('[CamHack V3] Не удалось сохранить настройки скрипта, ошибка: ', errstr)
        return false
    end
end
load_settings()

function lockPlayerControl(bool)
    freezeCharPosition(playerPed, bool)
end

function IsHotkeyClicked(keys_id)
    local keysArray = json.decode(keys_id)
    if not keysArray or next(keysArray) == nil then
        return false
    end
    local allKeysPressed = true
    for index, element in ipairs(keysArray) do
        if not isKeyDown(element) then
            allKeysPressed = false
            break
        end
    end
    return allKeysPressed
end
function camhack_on()
	posX, posY, posZ = getCharCoordinates(playerPed)
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
	angZ = getCharHeading(playerPed)
	angZ = angZ * -1.0
	angY = 0.0
	lockPlayerControl(true)
	camhack_active = true
    camhack_disable_hud()
end
function camhack_off()
	camhack_active = false
	angPlZ = angZ * -1.0
	setCameraBehindPlayer()
    restoreCameraJumpcut()
	lockPlayerControl(false)
	camhack_enable_hud()
end
function camhack_update()
	radZ, radY = math.rad(angZ), math.rad(angY)
	sinZ, cosZ = math.sin(radZ), math.cos(radZ)
	sinY, cosY = math.sin(radY), math.cos(radY)
	sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
	poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
	pointCameraAtPoint(poiX, poiY, poiZ, 2)
end
function camhack_foward()
	radZ = math.rad(angZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinY = math.sin(radY)
	cosY = math.cos(radY)
	sinZ = sinZ * cosY
	cosZ = cosZ * cosY
	sinZ = sinZ * camhack_speed 
	cosZ = cosZ * camhack_speed 
	sinY = sinY * camhack_speed 
	posX = posX + sinZ
	posY = posY + cosZ
	posZ = posZ + sinY
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_back()
	curZ = angZ + 180.0
	curY = angY * -1.0
	radZ = math.rad(curZ)
	radY = math.rad(curY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinY = math.sin(radY)
	cosY = math.cos(radY)
	sinZ = sinZ * cosY
	cosZ = cosZ * cosY
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	sinY = sinY * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	posZ = posZ + sinY
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left()
	curZ = angZ - 90.0
	radZ = math.rad(curZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right()
	curZ = angZ + 90.0
	radZ = math.rad(curZ)
	radY = math.rad(angY)
	sinZ = math.sin(radZ)
	cosZ = math.cos(radZ)
	sinZ = sinZ * camhack_speed
	cosZ = cosZ * camhack_speed
	posX = posX + sinZ
	posY = posY + cosZ
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_up()
	posZ = posZ + camhack_speed
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_down()
	posZ = posZ - camhack_speed
	setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_foward()
    curZ = angZ - 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_back()
    curZ = angZ - 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_foward()
    curZ = angZ + 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_back()
    curZ = angZ + 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_up()
    curZ = angZ - 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ + camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_left_down()
    curZ = angZ - 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ - camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_up()
    curZ = angZ + 45.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY +cosZ
    posZ = posZ + sinY
	posZ = posZ + camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_right_down()
    curZ = angZ + 135.0  
    radZ = math.rad(curZ)
    radY = math.rad(angY)
    sinZ = math.sin(radZ)
    cosZ = math.cos(radZ)
    sinY = math.sin(radY)
    cosY = math.cos(radY)
    sinZ = sinZ * camhack_speed
    cosZ = cosZ * camhack_speed
    sinY = sinY * camhack_speed
    posX = posX + sinZ
    posY = posY + cosZ
    posZ = posZ + sinY
	posZ = posZ - camhack_speed
    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
end
function camhack_speed_plus()
	camhack_speed = camhack_speed + 0.01
	--printStringNow("[CamHack V3] Speed: ".. camhack_speed, 1000)
end
function camhack_speed_minus()
	camhack_speed = camhack_speed - 0.01
	if camhack_speed < 0.01 then
		camhack_speed = 0.01
	end
	--printStringNow("[CamHack V3] Speed: " .. camhack_speed, 1000)
end
function camhack_enable_hud()
	displayRadar(true)
	displayHud(true)
end
function camhack_disable_hud()
	displayRadar(false)
	displayHud(false)
end
function camhack_angle_left() 
    local angle = 1 + camhack_speed / 10 
    angZ = (angZ - angle) % 360.0
    setFixedCameraPosition(posX, posY, posZ, 0.0, angY, angZ)
end
function camhack_angle_right()
    local angle = 1 + camhack_speed / 10
    angZ = (angZ + angle) % 360.0
    setFixedCameraPosition(posX, posY, posZ, 0.0, angY, angZ)
end

function main()
    sampRegisterChatCommand("cmh", function ()
        settings.general.enable = not settings.general.enable
        sampAddChatMessage('[CamHack] {ffffff}' .. (settings.general.enable and 'Работает!' or 'Отключено!'), message_color)
        if settings.general.enable then
            sampAddChatMessage('[CamHack] {ffffff}Активация: Alt + C | Дективация: Alt + V | Управление: WASD/Мышь/Space/Ctrl', message_color)
        end
        save_settings()
    end)
    -- lua_thread.create(function ()
    --     repeat wait(0) until sampIsLocalPlayerConnected() and isLocalPlayerSpawned()
        sampAddChatMessage('[CamHack] {ffffff}Активация: Alt + C | Дективация: Alt + V | Управление: WASD/Мышь/Space/Ctrl', message_color)
        sampAddChatMessage('[CamHack] {ffffff}Работоспособность скрипта (вкл/выкл реагирование на клавиши): /cmh', message_color)
    -- end)
end

function onUpdate()
    if (settings.general.enable) then
        if (camhack_active) then

            lockPlayerControl(true)

            camhack_update()

            if (settings.general.hud) then
                camhack_enable_hud()
            else
                camhack_disable_hud()
            end

            if (settings.general.camhack_type == 1) then
                if camhack_active --[[and not sampIsChatInputActive() and not isSampfuncsConsoleActive()]] then
                
                    offMouX, offMouY = getPcMouseMovement()
                    angZ = (angZ + offMouX/4.0) % 360.0
                    angY = math.min(89.0, math.max(-89.0, angY - offMouY/4.0))
    
                    camhack_update()
    
                    if IsHotkeyClicked(settings.binds.foward) then
                        camhack_foward()
                    end
    
                    camhack_update()
        
                    if IsHotkeyClicked(settings.binds.back) then
                        camhack_back()
                    end
    
                    camhack_update()
        
                    if IsHotkeyClicked(settings.binds.left) then
                        camhack_left()
                    end
    
                    camhack_update()
        
                    if IsHotkeyClicked(settings.binds.right)then
                        camhack_right()
                    end
    
                    camhack_update()
        
                    if IsHotkeyClicked(settings.binds.right_foward) then
                        camhack_right_foward()
                    end

                    camhack_update()

                    if IsHotkeyClicked(settings.binds.left_foward) then
                        camhack_left_foward()
                    end

                    camhack_update()

                    if (IsHotkeyClicked(settings.binds.up)) then
                        camhack_up()
                    end

                    camhack_update()

                    if (IsHotkeyClicked(settings.binds.down)) then
                        camhack_down()
                    end

                    camhack_update()

                    if (settings.general.hud) then
                        camhack_enable_hud()
                    else
                        camhack_disable_hud()
                    end

                    if (IsHotkeyClicked(settings.binds.speed_plus)) then
                        camhack_speed_plus()
                    end

                    if (IsHotkeyClicked(settings.binds.speed_minus)) then
                        camhack_speed_minus()
                    end

                    if (IsHotkeyClicked(settings.binds.disable)) then
                        camhack_off()
                    end
                end
            end
        elseif ((IsHotkeyClicked(settings.binds.activate)) and (not camhack_active)) then
            camhack_on()
        end 
    end  
end

function onExitScript()
    if camhack_active then
        camhack_off()
    end
end