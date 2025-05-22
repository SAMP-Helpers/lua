script_name("Probiv Player")
script_author("MTG MODS")
script_version(1)

require('lib.moonloader')
require('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local imgui = require('mimgui')
local ffi = require('ffi')
local fa = require('fAwesome6_solid')
local sizeX, sizeY = getScreenResolution()
local ProbivMenu = imgui.new.bool()
local input_probiv = imgui.new.char[128]()
local input = imgui.new.char[128]()
local probiv = nil
local message_color = 0x009EFF
local message_color_hex = '{009EFF}'
---------------------------------------------------------------------------------------------------------
local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/config"
local settings = {general = {probiv_api_key = '', custom_dpi = 1, autofind_dpi = false}}
function load_settings()
    local file = io.open(configDirectory .. "/probiv.json", 'r')
	if file then
		local contents = file:read('*a')
		file:close()
		if #contents ~= 0 then
			local result, loaded = pcall(decodeJson, contents)
			if result then
				settings = loaded
			end
		end
	end
end
function save_settings()
    local file, errstr = io.open(configDirectory .. "/probiv.json", 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print('[Probiv] Настройки хелпера сохранены!')
        return result
    end
end
load_settings()
---------------------------------------------------------------------------------------------------------
function isMonetLoader() return MONET_VERSION ~= nil end
if not settings.general.autofind_dpi then
	print('[Probiv] Применение авто-размера менюшек...')
	if isMonetLoader() then
		settings.general.custom_dpi = MONET_DPI_SCALE
	else
		local width_scale = sizeX / 1366
		local height_scale = sizeY / 768
		settings.general.custom_dpi = (width_scale + height_scale) / 2
	end
	settings.general.autofind_dpi = true
	local format_dpi = tostring(settings.general.custom_dpi):match("^%d+%.%d%d%d")
	settings.general.custom_dpi = tonumber(format_dpi)
	print('[Probiv] Установлено значение: ' .. settings.general.custom_dpi)
	print('[Probiv] Вы в любой момент можете изменить значение в настройках!')
	save_settings()
end
if isMonetLoader() then
	gta = ffi.load('GTASA') 
	ffi.cdef[[ void _Z12AND_OpenLinkPKc(const char* link); ]] -- функция для открытия ссылок
end
---------------------------------------------------------------------------------------------------------
function getARZServerNumber()
		local servers = {
		{name = 'Phoenix', number = '01'},
		{name = 'Tucson', number = '02'},
		{name = 'Scottdale', number = '03'},
		{name = 'Chandler', number = '04'},
		{name = 'Brainburg', number = '05'},
		{name = 'SaintRose', number = '06'},
		{name = 'Mesa', number = '07'},
		{name = 'Red Rock', number = '08'},
		{name = 'Yuma', number = '09'},
		{name = 'Surprise', number = '10'},
		{name = 'Prescott', number = '11'},
		{name = 'Glendale', number = '12'},
		{name = 'Kingman', number = '13'},
		{name = 'Winslow', number = '14'},
		{name = 'Payson', number = '15'},
		{name = 'Gilbert', number = '16'},
		{name = 'Show Low', number = '17'},
		{name = 'CasaGrande', number = '18'},
		{name = 'Page', number = '19'},
		{name = 'Sun City', number = '20'},
		{name = 'Queen Creek', number = '21'},
		{name = 'Sedona', number = '22'},
		{name = 'Holiday', number = '23'},
		{name = 'Wednesday', number = '24'},
		{name = 'Yava', number = '25'},
		{name = 'Faraway', number = '26'},
		{name = 'Bumble Bee', number = '27'},
		{name = 'Christmas', number = '28'},
		{name = 'Mirage', number = '29'},
		{name = 'Love', number = '30'},
		{name = 'Drake', number = '31'},
		{name = 'Mobile III', number = '103'},
		{name = 'Mobile II', number = '102'},
		{name = 'Mobile I', number = '101'},
		{name = 'Vice City', number = '200'},
	}
	local server = 0
	for _, s in ipairs(servers) do
		if sampGetCurrentServerName():gsub('%-', ' '):find(s.name) then
			server = s.number
			break
		end
	end
	return server
end
function getPlayerInfo(nickname, serverId)
    local url = string.format("https://api.depscian.tech/v2/player/find?nickname=%s&serverId=%s", nickname, serverId)
    local requests = require 'requests'

    local response, err = requests.get{url = url, headers = {["X-API-Key"] = settings.general.probiv_api_key}}
    if not response then
        sampAddChatMessage('[Probiv] {ffffff}Ошибка запроса: ' .. tostring(err), message_color)
        return nil
    end

    if response.status_code == 200 then
		local contents = u8:decode(response.text)
		local result, loaded = pcall(decodeJson, contents)
		if result then
			return loaded
		end
        return nil
    elseif response.status_code == 422 then
        sampAddChatMessage('[Probiv] {ffffff}Ошибка 422: Никнейм не найден или введен с ошибкой.', message_color)
    elseif response.status_code == 401 then
        sampAddChatMessage('[Probiv] {ffffff}Неверный API ключ.', message_color)
    elseif response.status_code == 429 then
        sampAddChatMessage('[Probiv] {ffffff}Превышен лимит запросов. Повторите чуть позже.', message_color)
    else
        sampAddChatMessage('[Probiv] {ffffff}Ошибка API: ' .. response.status_code, message_color)
    end
    return nil
end
function comma_value(n) -- MoneySeparator by Royan_Millans and YarikVL
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
function openLink(link)
	if isMonetLoader() then
		gta._Z12AND_OpenLinkPKc(link)
	else
		os.execute("explorer " .. link)
	end
end
---------------------------------------------------------------------------------------------------------
function main()

	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 

	sampRegisterChatCommand('probiv', function (id)
		local function isParamSampID(id)
			id = tonumber(id)
			if id ~= nil and tostring(id):find('%d') and not tostring(id):find('%D') and string.len(id) >= 1 and string.len(id) <= 3 then
				if id == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
					return true
				elseif sampIsPlayerConnected(id) then
					return true
				else
					return false
				end
			else
				return false
			end
		end
		if isParamSampID(id) then
			imgui.StrCopy(input, sampGetPlayerNickname(id))
			imgui.StrCopy(input_probiv, u8(settings.general.probiv_api_key))
			probiv = nil
			ProbivMenu[0] = true
		else
			sampAddChatMessage('[Probiv] {ffffff}Используйте /probiv [ID игрока]', message_color)
		end
	end)

    wait(-1)

end
---------------------------------------------------------------------------------------------------------
imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	if isMonetLoader() then
		fa.Init(14 * settings.general.custom_dpi)
	else
		fa.Init(14)
	end
	apply_dark_theme()
end)

imgui.OnFrame(
    function() return ProbivMenu[0] end,
    function(player)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.BUILDING.." Probiv " .. fa.BUILDING .. '##probiv', ProbivMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize)
		if not isMonetLoader() then imgui.SetWindowFontScale(settings.general.custom_dpi) end
		if probiv ~= nil then
			if imgui.BeginChild('##probiv_2', imgui.ImVec2(300 * settings.general.custom_dpi, 330 * settings.general.custom_dpi), true) then
				imgui.CenterText(fa.USER .. " " .. u8(u8:decode(ffi.string(input))) .. ' [UID ' .. (probiv.id or 'nil') .. '] ' .. fa.USER)
				imgui.Separator()
				imgui.Text(fa.CROWN .. u8(' VIP статус: ') ..  (probiv.vip_info and probiv.vip_info.level or "nil"))
				imgui.Text(fa.SIGNAL .. u8(' Уровень: ') ..  (probiv.level and probiv.level.level or "nil") .. ' (' .. (probiv.level and probiv.level.current_exp or 0) .. '/' .. (probiv.level and probiv.level.next_exp or 0) .. ' exp)')
				imgui.Text(fa.CIRCLE .. u8' Отыграно всего: ' .. (probiv.hours_played or "nll") .. u8" часов")
				imgui.Separator()
				imgui.CenterText(fa.MONEY_CHECK_DOLLAR .. u8(' Деньги ') .. fa.MONEY_CHECK_DOLLAR)
				imgui.Text(fa.HAND_HOLDING_DOLLAR .. u8(' На руках: $') .. comma_value(probiv.money and probiv.money.hand or "nil"))
				imgui.Text(fa.LANDMARK .. u8(' На банковском счету: $') .. comma_value(probiv.money and probiv.money.bank or "nil"))
				imgui.Text(fa.VAULT .. u8(' На депозите в банке: $') .. comma_value(probiv.money and probiv.money.deposit or "nil"))
				imgui.Text(fa.VAULT .. u8(' AZ Coin: ') .. comma_value(probiv.money and probiv.money.donate_currency or "nil"))
				imgui.Separator()
				imgui.CenterText(fa.BUILDING .. u8(' Организация ') .. fa.BUILDING)
				imgui.Text(fa.CIRCLE .. u8" Название: " .. u8(probiv.organization and probiv.organization.name or "Нету"))
				imgui.Text(fa.CIRCLE .. u8" Должность: " .. u8(probiv.organization and probiv.organization.rank or "Нету"))
				imgui.Separator()
				imgui.CenterText(fa.HOUSE .. u8(' Личные дома ') .. fa.HOUSE)
				if probiv.property and probiv.property.houses and #probiv.property.houses > 0 then
					local house_ids = {}
					for i, house in ipairs(probiv.property.houses) do
						table.insert(house_ids, tostring(house.id))
					end
					imgui.Text(fa.CIRCLE .. u8(' ') .. table.concat(house_ids, ", "))
				else
					imgui.Text(fa.CIRCLE .. u8(' Нет домов'))
				end
				imgui.Separator()
				imgui.CenterText(fa.BUSINESS_TIME .. u8(' Личные бизнесы ') .. fa.BUSINESS_TIME)
				if probiv.property and probiv.property.businesses and #probiv.property.businesses > 0 then
					local business_ids = {}
					for i, biz in ipairs(probiv.property.businesses) do
						table.insert(business_ids, tostring(biz.id))
					end
					imgui.Text(fa.CIRCLE .. u8(' ') .. table.concat(business_ids, ", "))
				else
					imgui.Text(fa.CIRCLE .. u8(' Нет бизнесов'))
				end
				imgui.EndChild()
			end
			
		else
			if imgui.BeginChild('##probiv_1', imgui.ImVec2(300 * settings.general.custom_dpi, 205 * settings.general.custom_dpi), true) then
				imgui.CenterText(fa.KEY .. u8(' API key для пробива'))
				imgui.PushItemWidth(290 * settings.general.custom_dpi)
				if imgui.InputText(u8'##probiv_apikey', input_probiv, 256) then
					settings.general.probiv_api_key = u8:decode(ffi.string(input_probiv))
					save_settings()
				end
				imgui.Separator()
				imgui.CenterText(u8('Получение API ключа - БЕСПЛАТНОЕ!'))
				imgui.CenterText(u8('Отправьте боту команду /new'))
				if imgui.CenterButton(u8('https://t.me/DepsAPI_bot')) then
					openLink('https://t.me/DepsAPI_bot')
				end
				imgui.CenterText(fa.USER .. u8(' Ник игрока для пробива'))
				imgui.PushItemWidth(290 * settings.general.custom_dpi)
				imgui.InputText(u8'##probiv_nick', input, 256)
				imgui.Separator()
				if imgui.CenterButton(fa.CIRCLE_ARROW_RIGHT .. u8(' Узнать инфу об игроке ') .. fa.CIRCLE_ARROW_LEFT) then
					probiv = getPlayerInfo(u8:decode(ffi.string(input)), getARZServerNumber())
				end
				imgui.EndChild()
			end
		end
		imgui.End()
    end
)

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterButton(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if imgui.Button(text) then
		return true
	else
		return false
	end
end
function apply_dark_theme()
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * settings.general.custom_dpi, 5 * settings.general.custom_dpi)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * settings.general.custom_dpi, 5 * settings.general.custom_dpi)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * settings.general.custom_dpi, 5 * settings.general.custom_dpi)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * settings.general.custom_dpi, 2 * settings.general.custom_dpi)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * settings.general.custom_dpi
    imgui.GetStyle().GrabMinSize = 10 * settings.general.custom_dpi
    imgui.GetStyle().WindowBorderSize = 1 * settings.general.custom_dpi
    imgui.GetStyle().ChildBorderSize = 1 * settings.general.custom_dpi
    imgui.GetStyle().PopupBorderSize = 1 * settings.general.custom_dpi
    imgui.GetStyle().FrameBorderSize = 1 * settings.general.custom_dpi
    imgui.GetStyle().TabBorderSize = 1 * settings.general.custom_dpi
	imgui.GetStyle().WindowRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().ChildRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().FrameRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().PopupRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().ScrollbarRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().GrabRounding = 8 * settings.general.custom_dpi
    imgui.GetStyle().TabRounding = 8 * settings.general.custom_dpi
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