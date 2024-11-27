script_name("Clever Sight")
script_description('')
script_author("MTG MODS")
script_version("3.0")

require 'encoding'.default = 'CP1251'
local u8 = require 'encoding'.UTF8

local inicfg = require 'inicfg'
local local_ini = "CleverSight.ini"
local ini = inicfg.load( {

	settings = {
		
		sight_enable = true,
		
		sight_standart_color = '#FFFFFF',
		sight_enemy_color = '#FF0000',
		
		sight_check_weapon_range = true,
		
		sight_info_menu_view = true
			
	}
	
}, local_ini)

local memory = require "memory"
local ffi = require 'ffi'
local imgui = require('mimgui')
local fa = require('fAwesome6_solid')

local sizeX, sizeY = getScreenResolution()
local new = imgui.new
local MainWindow = new.bool()
local InfoMenu = new.bool()
local checkbox_sight_enable = new.bool(ini.settings.sight_enable)
local checkbox_check_weapon_range = new.bool(ini.settings.sight_check_weapon_range)
local checkbox_info_menu_enable = new.bool(ini.settings.sight_info_menu_view)

function hex_to_rgb(hex)
    hex = hex:gsub("#","") -- remove the # if it's included
    return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
end

local color = new.float[3](hex_to_rgb(ini.settings.sight_standart_color))
local color2 = new.float[3](hex_to_rgb(ini.settings.sight_enemy_color))

local sight_player_id = nil
local last_sight_color = nil

local weapons = {

	{name = 'PISTOL', id = 22, range = 35,0},
	{name = 'PISTOL_SILENCED', id = 23, range = 35.0},
	{name = 'DESERT_EAGLE', id = 24, range = 35.0},
	{name = 'SHOTGUN', id = 25, range = 40.0},
	{name = 'SAWNOFF', id = 26, range = 35.0},
	{name = 'SPAS12', id = 27, range = 40.0},
	{name = 'MICRO_UZI', id = 28, range = 35.0},
	{name = 'TEC9', id = 29, range = 35.0},
	{name = 'MP5', id = 30, range = 45.0},
	{name = 'AK47', id = 31, range = 70.0},
	{name = 'M4', id = 32, range = 90.0},
	{name = 'COUNTRYRIFLE', id = 33, range = 100.0},
	{name = 'SNIPERRIFLE', id = 34, range = 100.0},
	{name = 'RLAUNCHER', id = 35, range = 55.0},
	{name = ' RLAUNCHER_HS', id = 36, range = 55.0},
	{name = 'FTHROWER', id = 37, range = 5.1},
	{name = 'MINIGUN', id = 38, range = 75.0},
	
	-- ARZ LAUNCHER GUNS
	{name = 'deagle_steel', id = 71, range = 35.0},
	{name = 'deagle_gold', id = 72, range = 35.0},
	{name = 'glock_gradient', id = 73, range = 35.0},
	{name = 'deagle_flame', id = 74, range = 35.0},
	{name = 'python_royal', id = 75, range = 50.0},
	{name = 'python_silver', id = 76, range = 50.0},
	{name = 'ak47_roses', id = 77, range = 60.5},
	{name = 'ak47_gold', id = 78, range = 60.5},
	{name = 'm249_graffiti', id = 79, range = 90.0},
	{name = 'saiga_gold', id = 80, range = 40.0},
	{name = 'ppsh_standart', id = 81, range = 45.0},
	{name = 'm249_standart', id = 82, range = 90.0},
	{name = 'skorp_standart ', id = 83, range = 35.0},
	{name = 'aks74_camouflage1', id = 84, range = 80.0},
	{name = 'ak47_camouflage1', id = 85, range = 80.0},
	{name = 'rebecca_shotgun', id = 86, range = 40.0},
	{name = 'obj58_portalgun', id = 87, range = 50.0},
	{name = 'portalgun', id = 89, range = 50.0}

}

function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end

	sampAddChatMessage('{ff0000}[INFO] {ffffff}Скрипт "Clever Sight" [V' .. thisScript().version .. '] загружен и готов к работе! Автор: MTG MODS | Используйте {00ccff}/sight',-1)

	sampRegisterChatCommand("sight", function() MainWindow[0] = not MainWindow[0]  end)
	
	while true do
        wait(0)
	  
		if ini.settings.sight_enable and not sampIsDialogActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
	  
			local cam_x, cam_y, cam_z = getActiveCameraCoordinates()
			local width, height = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
			local cross_x, cross_y, cross_z = convertScreenCoordsToWorld3D(width, height, 100)
			local result, pointer = processLineOfSight(cam_x, cam_y, cam_z, cross_x, cross_y, cross_z, false, false, true, false, false, false, false)

			if result then
			
				if isLineOfSightClear(cam_x, cam_y, cam_z, pointer.pos[1], pointer.pos[2], pointer.pos[3], true, true, false, true, true) then
				
					if pointer.entityType == 3 then
					
						if pointer.entity ~= getCharPointer(PLAYER_PED) then
				
							local camMode = memory.getint16(0xB6F1A8, false)
	  
							if camMode == 0x35 or camMode == 0x37 or camMode == 0x7 or camMode == 0x8 or camMode == 0x33 then 
				
								if ini.settings.sight_check_weapon_range then
									local ppx, ppy, ppz = getCharCoordinates(PLAYER_PED)
									local localx, localy, localz = pointer.pos[1], pointer.pos[2], pointer.pos[3]
									local dist = getDistanceBetweenCoords3d(ppx, ppy, ppz, localx, localy, localz)
									local currentWeaponID = getCurrentCharWeapon(PLAYER_PED)
									for _, weapon in ipairs(weapons) do
										if weapon.id == currentWeaponID and dist <= weapon.range then
											sight_player_id = select(2, sampGetPlayerIdByCharHandle(getCharPointerHandle(pointer.entity)))
											break
										else
											sight_player_id = nil
										end
									end
								else
									sight_player_id = select(2, sampGetPlayerIdByCharHandle(getCharPointerHandle(pointer.entity)))
								end
								
								if ini.settings.sight_info_menu_view and sight_player_id then
									showCursor(false, false)
									InfoMenu[0] = true
								else
									InfoMenu[0] = false
								end
			
								if sight_player_id then 
									change_color(ini.settings.sight_enemy_color)
								else
									change_color(ini.settings.sight_standart_color)
								end
								
							else
								InfoMenu[0] = false
								change_color(ini.settings.sight_standart_color)
							end
						
						end
						
					end
					
				end
				
			else
				change_color(ini.settings.sight_standart_color)
				InfoMenu[0] = false
			end

		end

    end

end

imgui.OnInitialize(function()

	imgui.GetIO().IniFilename = nil
	fa.Init()
	
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 , 2 )
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 
    imgui.GetStyle().GrabMinSize = 10 
    imgui.GetStyle().WindowBorderSize = 1 
    imgui.GetStyle().ChildBorderSize = 1 
    imgui.GetStyle().PopupBorderSize = 1 
    imgui.GetStyle().FrameBorderSize = 1 
    imgui.GetStyle().TabBorderSize = 1 
	imgui.GetStyle().WindowRounding = 8 
    imgui.GetStyle().ChildRounding = 8 
    imgui.GetStyle().FrameRounding = 8 
    imgui.GetStyle().PopupRounding = 8 
    imgui.GetStyle().ScrollbarRounding = 8 
    imgui.GetStyle().GrabRounding = 8 
    imgui.GetStyle().TabRounding = 8 
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
	
end)

local MainWindow = imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(340, 115), imgui.Cond.FirstUseEver)
		
		imgui.Begin(fa.EYE.. u8" Clever Sight [V" .. thisScript().version .. ']', MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
		
		if imgui.Checkbox(u8' Использование Clever Sight##checkbox_sight_enable', checkbox_sight_enable) then
			ini.settings.sight_enable = checkbox_sight_enable[0]
			inicfg.save(ini, local_ini)
		end
		
		if checkbox_sight_enable[0] then
		
			imgui.Separator()
			
			imgui.Text(u8' Стандартный цвет прицела (без наведения)')
			imgui.SameLine()
			if imgui.ColorEdit3('## COLOR1', color, imgui.ColorEditFlags.NoInputs) then
						
				local r,g,b = color[0] * 255, color[1] * 255, color[2] * 255
				local clr = '#' .. argbToHexWithoutAlpha(0, r, g, b)
				ini.settings.sight_standart_color = clr
				inicfg.save(ini, local_ini)
				
			end
			
			imgui.Text(u8' Цвет прицела при наведении на игрока/NPC')
			imgui.SameLine()
			if imgui.ColorEdit3('## COLOR2', color2, imgui.ColorEditFlags.NoInputs) then
						
				local r,g,b = color2[0] * 255, color2[1] * 255, color2[2] * 255
				local clr = '#' .. argbToHexWithoutAlpha(0, r, g, b)
				ini.settings.sight_enemy_color = clr
				inicfg.save(ini, local_ini)
				
				
			end
		
			imgui.Separator()
		
			if imgui.Checkbox(u8' Учитывать дальность стрельбы оружия ##checkbox_check_weapon_range', checkbox_check_weapon_range) then
				ini.settings.sight_check_weapon_range = checkbox_check_weapon_range[0]
				inicfg.save(ini, local_ini)
			end
			imgui.SameLine(nil, 5) imgui.TextDisabled("[?]")
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Смена цвета при наведении будет только в случае, если расстояние до цели\nменьше или равно максимальной дальности вашего оружия.\n\nПример:\nДальность Deagle 35м, и если игрок от вас в 37м, цвет меняться не будет")
			end
			
			imgui.Separator()
			
			if imgui.Checkbox(u8' Показывать меню на кого наведён прицел##checkbox_info_menu_enable', checkbox_info_menu_enable) then
				ini.settings.sight_info_menu_view = checkbox_info_menu_enable[0]
				inicfg.save(ini, local_ini)
			end
		
		end
	
		imgui.End()
		
    end
)

local InfoMenu = imgui.OnFrame(
    function() return InfoMenu[0] end,
    function(player)	
	
		player.HideCursor = true
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 10, sizeY / 1.6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(fa.EYE .. ' Clever Sight [V' .. thisScript().version .. ']##info_menu', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize )
	
		if sight_player_id == -1 then
			imgui.Text(u8' В прицеле NPC')
		elseif sight_player_id ~= nil and sight_player_id ~= -1 and sampIsPlayerConnected(sight_player_id) then
			imgui.Text(u8' В прицеле ' .. u8(sampGetPlayerNickname(sight_player_id)) .. ' [' .. sight_player_id .. ']')
		else
			InfoMenu[0] = false
		end
		
		if sampIsDialogActive() or sampIsChatInputActive() or isSampfuncsConsoleActive() then
			InfoMenu[0] = false
		end
		
		imgui.End()
		
    end
)

function change_color(color_hex)

	if last_sight_color ~= nil and color_hex:upper() == last_sight_color:upper() then
	
	else
		last_sight_color = color_hex
		local a, r, g, b = hexToARGB(color_hex)
		local rgba = (a * 0x1000000) + (r * 0x10000) + (g * 0x100) + b
		changeCrosshairColor(rgba)
	end
	
end

function argbToHexWithoutAlpha(alpha, red, green, blue)
    return string.format("%02X%02X%02X", red, green, blue)
end
function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
function hexToARGB(hex)
    hex = hex:gsub("#","")

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = tonumber(hex:sub(7, 8), 16) or 255

    return a, r, g, b
end

function changeCrosshairColor(rgba)
    local r = bit.band(bit.rshift(rgba, 16), 0xFF)
    local g = bit.band(bit.rshift(rgba, 8), 0xFF)
    local b = bit.band(rgba, 0xFF)
    local a = bit.band(bit.rshift(rgba, 24), 0xFF)

    memory.setuint8(0x58E301, r, true)
    memory.setuint8(0x58E3DA, r, true)
    memory.setuint8(0x58E433, r, true)
    memory.setuint8(0x58E47C, r, true)

    memory.setuint8(0x58E2F6, g, true)
    memory.setuint8(0x58E3D1, g, true)
    memory.setuint8(0x58E42A, g, true)
    memory.setuint8(0x58E473, g, true)

    memory.setuint8(0x58E2F1, b, true)
    memory.setuint8(0x58E3C8, b, true)
    memory.setuint8(0x58E425, b, true)
    memory.setuint8(0x58E466, b, true)

    memory.setuint8(0x58E2EC, a, true)
    memory.setuint8(0x58E3BF, a, true)
    memory.setuint8(0x58E420, a, true)
    memory.setuint8(0x58E461, a, true)
end