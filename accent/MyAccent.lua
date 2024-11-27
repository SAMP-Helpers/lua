script_name("{7ef3fa}MyAccent")
script_author("{7ef3fa}MTG MODS")
script_version("1.0.0")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
require "lib.moonloader"
local sampev = require "samp.events"
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local inicfg = require 'inicfg'
local local_ini = "MyAccent.ini"
local accent_ini = inicfg.load( {

	settings = {
		
		my_accent = '[Иностранный акцент]:',
		my_accent_enable = true
			
	}
	
}, local_ini)
if not doesFileExist("moonloader/config/MyAccent.ini") then 
	inicfg.save(accent_ini, local_ini)
	thisScript():reload()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local imgui = require "imgui"
local togglebut = require 'imgui_addons'
local main_window = imgui.ImBool(false)
local AccentEnable = imgui.ImBool(accent_ini.settings.my_accent_enable)
imgui.ToggleButton = require('imgui_addons').ToggleButton 
local ex, ey = getScreenResolution()
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 
	
	sampAddChatMessage('{ff0000}[INFO] {ffffff}Скрипт "MyAccent" загружен и готов к работе! Автор: MTG MODS | Версия: 1.0 | Используйте {00ccff}/acc',-1)
	
	sampRegisterChatCommand("acc", function()
		main_window.v = not main_window.v
		imgui.Process = main_window.v
	end)
	
	while true do wait(0) end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function sampev.onSendChat(message)

    if AccentEnable.v then

		if message == ")" or message == "))" or message == "(" or message == "((" or message == "xD" or message == "q" then else
			return {accent_ini.settings.my_accent..' '..message}
		end

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function imgui.OnDrawFrame()
	
	imgui_theme()
	
	local text_my_accent = imgui.ImBuffer(u8(accent_ini.settings.my_accent),256)
	
	if not main_window.v then
		imgui.Process = false
	end
	
	if main_window.v then
		
		imgui.SetNextWindowPos(imgui.ImVec2(ex / 2, ey / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(350, 140), imgui.Cond.FirstUseEver)
		imgui.Begin(u8("MyAccent | Автор скрипта: MTG MODS | Версия: 1.0"),main_window, imgui.WindowFlags.NoCollapse)
	
		if imgui.BeginChild("1",imgui.ImVec2(338, 60),true) then
		
			imgui.Text(u8" Использовать акцент вашего персонажа в чате ") imgui.SameLine()
			if imgui.ToggleButton("###1",AccentEnable) then
				accent_ini.settings.my_accent_enable = AccentEnable.v
				inicfg.save(accent_ini, local_ini)
			end 
			
			imgui.PushItemWidth(240) imgui.SetCursorPosX(10)
			
			if imgui.InputText('',text_my_accent) then
				temp = u8:decode(text_my_accent.v)
			end
			
			imgui.SameLine()
			
			if imgui.Button(u8" Сохранить ") then
				accent_ini.settings.my_accent = temp
				inicfg.save(accent_ini, local_ini)
			end
		
		end imgui.EndChild()
		
		if imgui.BeginChild("2",imgui.ImVec2(338, 45),true) then
		
			imgui.CenterText(u8"Связь с автором (для оказания тех. поддержки):")
			imgui.CenterText(u8"https://discord.gg/qBPEYjfNhv")
		
		end imgui.EndChild()
		
		imgui.End()
		
	end
	
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui_theme()
	imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col 
		local ImVec4 = imgui.ImVec4
		local ImVec2 = imgui.ImVec2

		style.WindowTitleAlign = ImVec2(0.5, 0.5)
		style.WindowPadding = ImVec2(6, 4)
		style.WindowRounding = 5.0
		style.FramePadding = ImVec2(4, 3)
		style.FrameRounding = 6.0
		style.ItemSpacing = ImVec2(5, 6)
		style.ItemInnerSpacing = ImVec2(1, 1)
		style.IndentSpacing = 25.0
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 10.0
		style.GrabMinSize = 100.0
		style.GrabRounding = 3.0

		colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] = ImVec4(0.5, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.10, 0.09, 0.12, 0.60)
		colors[clr.CloseButtonHovered] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.CloseButtonActive] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.0)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
