script_name('Casino/Bar Helper')
script_author('MTG MODS')
script_version(1)
 
require('lib.moonloader')
require ('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')
------------------------------------------ Mobile Support --------------------------------------------------
if not MONET_DPI_SCALE then MONET_DPI_SCALE = 1.0 end
---------------------------------------------- Settings -----------------------------------------------------
local inicfg = require 'inicfg'
local mainIni = inicfg.load({
    settings = {
        use_time = true,
        use_notify = true,
        use_cancel_stavka = true,
        min_stavka_kazik = 1000,
        max_stavka_kazik = 800000,
        min_stavka_bar = 1000,
        max_stavka_bar = 800000,
    }
})
---------------------------------------------- Mimgui -----------------------------------------------------
local imgui = require('mimgui')
local sizeX, sizeY = getScreenResolution()
local MainWindow = imgui.new.bool()
local checkboxone = imgui.new.bool(mainIni.settings.use_time)
local checkboxtwo = imgui.new.bool(mainIni.settings.use_notify)
local checkboxthree = imgui.new.bool(mainIni.settings.use_cancel_stavka)
local input_min_stavka_kaz = imgui.new.char[256](tostring(mainIni.settings.min_stavka_kazik))
local input_max_stavka_kaz = imgui.new.char[256](tostring(mainIni.settings.max_stavka_kazik))
local input_min_stavka_bar = imgui.new.char[256](tostring(mainIni.settings.min_stavka_bar))
local input_max_stavka_bar = imgui.new.char[256](tostring(mainIni.settings.max_stavka_bar))
---------------------------------------------- Main -----------------------------------------------------
function main()
    
    if ((not isSampLoaded()) or (not isSampfuncsLoaded())) then return end
    while (not isSampAvailable()) do wait(0) end

    sampAddChatMessage('{F34444}[Casino/Bar Helper] {ffffff}Скрипт успешно загружен! Используйте {F34444}/kazbar {ffffff}для настройки скрипта.', -1)

    sampRegisterChatCommand('kazbar', function ()
        MainWindow[0] = not MainWindow[0]
    end)

    wait(-1)

end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	apply_dark_theme()
end)

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(video)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400 * MONET_DPI_SCALE, 245	* MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Casino/Bar Helper', MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
        if imgui.Checkbox(u8' Таймить перед принятием ставки', checkboxone) then
            mainIni.settings.use_time = checkboxone[0]
            inicfg.save(mainIni)
        end
        if imgui.Checkbox(u8' Уведомления при принятии ставки', checkboxtwo) then
            mainIni.settings.use_notify = checkboxtwo[0]
            inicfg.save(mainIni)
        end
        if imgui.Checkbox(u8' Отказываться от ставки если сумма < min или > max', checkboxthree) then
            mainIni.settings.use_cancel_stavka = checkboxthree[0]
            inicfg.save(mainIni)
        end
        imgui.Separator()
        imgui.PushItemWidth(100)
        if imgui.InputText(u8" Минимальная сумма ставки ($) в баре", input_min_stavka_bar, 256) then
            mainIni.settings.min_stavka_bar = u8:decode(ffi.string(input_min_stavka_bar))
            inicfg.save(mainIni)
        end
        if imgui.InputText(u8" Максимальная сумма ставки ($) в баре", input_max_stavka_bar, 256) then
            mainIni.settings.max_stavka_bar = u8:decode(ffi.string(input_max_stavka_bar))
            inicfg.save(mainIni)
        end
        imgui.Separator()
        if imgui.InputText(u8" Минимальная сумма ставки (фишки) в казино", input_min_stavka_kaz, 256) then
            mainIni.settings.min_stavka_kaz = u8:decode(ffi.string(input_min_stavka_kaz))
            inicfg.save(mainIni)
        end
        if imgui.InputText(u8" Максимальная сумма ставки (фишки) в казино", input_max_stavka_kaz, 256) then
            mainIni.settings.max_stavka_kaz = u8:decode(ffi.string(input_max_stavka_kaz))
            inicfg.save(mainIni)
        end
        imgui.End()
    end
)

function apply_dark_theme()
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
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
end

local accept_stavka = false
local cancel_stavka = false
require('lib.samp.events').onShowDialog = function(id, style, title, button1, button2, text)
    if title:find('Активные предложения') and accept_stavka then
		if text:find('Дата') then
			sampSendDialogResponse(id, 1, 0, 0)
			return false
		end
		if text:find('Принять предложение') then
			sampSendDialogResponse(id, 1, 5, 0)
			return false
		end
        accept_stavka = false
	end
    if title:find('Активные предложения') and cancel_stavka then
		if text:find('Дата') then
			sampSendDialogResponse(id, 1, 0, 0)
			return false
		end
		if text:find('Отклонить предложение') then
			sampSendDialogResponse(id, 1, 6, 0)
			return false
		end
        cancel_stavka = false
	end
end

require('lib.samp.events').onServerMessage = function(color, text)
    if text:find('%[Новое предложение%]%{ffffff%} Игрок (.+) предлагает сыграть Вам в кости, ставка (%d+) фишек%.') then
        local player, stavka =  text:match('%[Новое предложение%]%{ffffff%} Игрок (.+) предлагает сыграть Вам в кости, ставка (%d+) фишек%.')
        if (tonumber(stavka) >= tonumber(mainIni.settings.min_stavka_kazik) and tonumber(stavka) <= tonumber(mainIni.settings.max_stavka_kazik)) then
            if mainIni.settings.use_notify then
                show_arz_notify('info', 'Casino/Bar Helper', 'Принимаю ставку ' .. stavka .. ' фишек', 2000)
            end
            lua_thread.create(function ()
                if mainIni.settings.use_time then
                    sampSendChat('/time')
                    wait(500)
                    accept_stavka = true
                    sampSendChat('/offer')
                else
                    accept_stavka = true
                    sampSendChat('/offer')
                end
            end)
        elseif mainIni.settings.use_cancel_stavka then
            if mainIni.settings.use_notify then
                show_arz_notify('info', 'Casino/Bar Helper', 'Отказываюсь от ставки ' .. stavka .. ' фишек', 2000)
            end
            cancel_stavka = true
            sampSendChat('/offer')
        end
    end
    if text:find('%[Оповещение%] %{ffffff%}Ставка%: %{ffff00%}%$(%d+)%, %{ffffff%}игрок выбрал сторону(.+)') then
        local stavka = text:match('%[Оповещение%] %{ffffff%}Ставка%: %{ffff00%}%$(%d+)%, %{ffffff%}игрок выбрал сторону(.+)')
        if (tonumber(stavka) >= tonumber(mainIni.settings.min_stavka_bar) and tonumber(stavka) <= tonumber(mainIni.settings.max_stavka_bar)) then
            if mainIni.settings.use_notify then
                show_arz_notify('info', 'Casino/Bar Helper', 'Принимаю ставку ' .. stavka .. '$', 2000)
            end
            lua_thread.create(function ()
                if mainIni.settings.use_time then
                    sampSendChat('/time')
                    wait(500)
                    sampSendChat('/oyes')
                else
                    sampSendChat('/oyes')
                end
            end)
        elseif mainIni.settings.use_cancel_stavka then
            if mainIni.settings.use_notify then
                show_arz_notify('info', 'Casino/Bar Helper', 'Отказываюсь от ставки ' .. stavka .. '$', 2000)
            end
            sampSendChat('/ono')
        end
    end

end

function show_arz_notify(type, title, text, time)
    if MONET_VERSION ~= nil then
        if type == 'info' then
            type = 3
        elseif type == 'error' then
            type = 2
        elseif type == 'success' then
            type = 1
        end
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 62)
        raknetBitStreamWriteInt8(bs, 6)
        raknetBitStreamWriteBool(bs, true)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
        local json = encodeJson({
            styleInt = type,
            title = title,
            text = text,
            duration = time
        })
        local interfaceid = 6
        local subid = 0
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 84)
        raknetBitStreamWriteInt8(bs, interfaceid)
        raknetBitStreamWriteInt8(bs, subid)
        raknetBitStreamWriteInt32(bs, #json)
        raknetBitStreamWriteString(bs, json)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
    else
        local str = ('window.executeEvent(\'event.notify.initialize\', \'["%s", "%s", "%s", "%s"]\');'):format(type, title, text, time)
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, 17)
        raknetBitStreamWriteInt32(bs, 0)
        raknetBitStreamWriteInt32(bs, #str)
        raknetBitStreamWriteString(bs, str)
        raknetEmulPacketReceiveBitStream(220, bs)
        raknetDeleteBitStream(bs)
    end
end