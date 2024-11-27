require("ArizonaAPI")

local u8 = require("u8")
local sex = 'Мужчина'
-- Если вам нужны женские отыгровки то смените на 'Женщина'

local weapons = {
	FIST = 0,
	BRASSKNUCKLES = 1,
	GOLFCLUB = 2,
	NIGHTSTICK = 3,
	KNIFE = 4,
	BASEBALLBAT = 5,
	SHOVEL = 6,
	POOLCUE = 7,
	KATANA = 8,
	CHAINSAW = 9,
	PURPLEDILDO = 10,
	WHITEDILDO = 11,
	WHITEVIBRATOR = 12,
	SILVERVIBRATOR = 13,
	FLOWERS = 14,
	CANE = 15,
	GRENADE = 16,
	TEARGAS = 17,
	MOLOTOV = 18,
	COLT45 = 22,
	SILENCED = 23,
	DESERTEAGLE = 24,
	SHOTGUN = 25,
	SAWNOFFSHOTGUN = 26,
	COMBATSHOTGUN = 27,
	UZI = 28,
	MP5 = 29,
	AK47 = 30,
	M4 = 31,
	TEC9 = 32,
	RIFLE = 33,
	SNIPERRIFLE = 34,
	ROCKETLAUNCHER = 35,
	HEATSEEKER = 36,
	FLAMETHROWER = 37,
	MINIGUN = 38,
	SATCHELCHARGE = 39,
	DETONATOR = 40,
	SPRAYCAN = 41,
	FIREEXTINGUISHER = 42,
	CAMERA = 43,
	NIGHTVISION = 44,
	THERMALVISION = 45,
	PARACHUTE = 46,
	WEAPON_VEHICLE = 49,
	HELI = 50,
	BOMB = 51,
	COLLISION = 54,
	-- ARZ CUSTOM GUN
	DEAGLE_STEEL = 71,
	DEAGLE_GOLD = 72,
	GLOCK_GRADIENT = 73,
	DEAGLE_FLAME = 74,
	PYTHON_ROYAL = 75,
	PYTHON_SILVER = 76,
	AK47_ROSES = 77,
	AK47_GOLD = 78,
	M249_GRAFFITI = 79,
	SAIGA_GOLD = 80,
	PPSH_STANDART = 81,
	M249_STANDART = 82,
	SKORP_STANDART = 83,
	AKS74_CAMOUFLAGE1 = 84,
	AK47_CAMOUFLAGE1 = 85,
	REBECCA_SHOTGUN = 86,
	OBJ58_PORTALGUN = 87,
	ICE_SWORD = 88,
	PORTALGUN = 89,
	SOUND_GRENADE = 90,
	EYE_GRENADE = 91,
	MCMILLIAN_TAC50 = 92
}
local id = weapons
weapons.names = {
	[id.FIST] = 'кулаки',
	[id.BRASSKNUCKLES] = 'кастеты',
	[id.GOLFCLUB] = 'клюшку для гольфа',
	[id.NIGHTSTICK] = 'дубинку',
	[id.KNIFE] = 'острый нож',
	[id.BASEBALLBAT] = 'биту',
	[id.SHOVEL] = 'лопату',
	[id.POOLCUE] = 'кий',
	[id.KATANA] = 'катану',
	[id.CHAINSAW] = 'бензопилу',
	[id.PURPLEDILDO] = 'дидло',
	[id.WHITEDILDO] = 'дидло',
	[id.WHITEVIBRATOR] = 'вибратор',
	[id.SILVERVIBRATOR] = 'вибратор',
	[id.FLOWERS] = 'букет цветов',
	[id.CANE] = 'трость',
	[id.GRENADE] = 'осколочную гранату',
	[id.TEARGAS] = 'дымовую гранату',
	[id.MOLOTOV] = 'коктейль Молотова',
	[id.COLT45] = 'пистолет Colt45',
	[id.SILENCED] = "электрошокер Taser-X26P",
	[id.DESERTEAGLE] = 'пистолет Desert Eagle',
	[id.SHOTGUN] = 'дробовик',
	[id.SAWNOFFSHOTGUN] = 'обрез',
	[id.COMBATSHOTGUN] = 'улучшенный обрез',
	[id.UZI] = 'пистолет-пулемёт Micro Uzi',
	[id.MP5] = 'пистолет-пулемёт MP5',
	[id.AK47] = 'автомат AK-47',
	[id.M4] = 'автомат M4',
	[id.TEC9] = 'пистолет-пулемёт Tec-9',
	[id.RIFLE] = 'винтовку Rifle',
	[id.SNIPERRIFLE] = 'снайперскую винтовку Rifle',
	[id.ROCKETLAUNCHER] = 'ручную противотанковую ракету',
	[id.HEATSEEKER] = 'устройство для запуска ракет',
	[id.FLAMETHROWER] = 'огнемёт',
	[id.MINIGUN] = 'миниган',
	[id.SATCHELCHARGE] = 'динамит',
	[id.DETONATOR] = 'детонатор',
	[id.SPRAYCAN] = 'перцовый баланчик',
	[id.FIREEXTINGUISHER] = 'огнетушитель',
	[id.CAMERA] = 'фотоапарат Canon',
	[id.NIGHTVISION] = 'прибор ночного видения',
	[id.THERMALVISION] = 'тепловизор',
	[id.PARACHUTE] = 'ручной парашут',
	[id.WEAPON_VEHICLE] = 'автомобиль',
	[id.HELI] = 'лопасти вертолёта',
	[id.BOMB] = 'взрыв',
	[id.COLLISION] = 'коллизию',
	-- ARZ LAUNCHER GUNS
	[id.DEAGLE_STEEL] = 'пистолет Desert Eagle Steel',
	[id.DEAGLE_GOLD] = 'пистолет Desert Eagle Gold',
	[id.GLOCK_GRADIENT] = 'пистолет Glock',
	[id.DEAGLE_FLAME] = 'пистолет Desert Eagle Flame',
	[id.PYTHON_ROYAL] = 'пистолет Colt Python',
	[id.PYTHON_SILVER] = 'пистолет Colt Python Silver',
	[id.AK47_ROSES] = 'автомат AK-47 Roses',
	[id.AK47_GOLD] = 'автомат AK-47 Gold',
	[id.M249_GRAFFITI] = 'пулемёт M249 Graffiti',	
	[id.SAIGA_GOLD] = 'золотую Сайгу',
	[id.PPSH_STANDART] = 'пистолет-пулемёт Standart',
	[id.M249_STANDART] = 'пулемёт M249',
	[id.SKORP_STANDART] = 'пистолет-пулемёт Skorp',
	[id.AKS74_CAMOUFLAGE1] = 'автомат AKS-74 камуфляжный',
	[id.AK47_CAMOUFLAGE1] = 'автомат AK-47 камуфляжный',
	[id.REBECCA_SHOTGUN] = 'дробовик Rebecca',
	[id.OBJ58_PORTALGUN] = 'портальную пушку',
	[id.PORTALGUN] = 'портальную пушку',
	[id.ICE_SWORD] = 'ледяной меч',
	[id.SOUND_GRENADE] = 'оглушающую граната',
	[id.EYE_GRENADE] = 'ослепляющую граната',
	[id.MCMILLIAN_TAC50] = 'снайперскую винтовку McMillian TAC-50'
}
function weapons.get_name(id) 
	return weapons.names[id]
end
local gunOn = {}
local gunOff = {}
local gunPartOn = {}
local gunPartOff = {}
local oldGun = nil
local nowGun = 0
local rpTakeNames = {{"из-за спины", "за спину"}, {"из кармана", "в карман"}, {"из пояса", "на пояс"}, {"из кобуры", "в кобуру"}}
local rpTake = {
	[2]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [14]=1, [15]=1, [25]=1, [26]=1, [27]=1, [28]=1, [29]=1, [30]=1, [31]=1, [32]=1, [33]=1, [34]=1, [35]=1, [36]=1, [37]=1, [38]=1, [42]=1, [77]=1, [78]=1, [78]=1, [79]=1, [80]=1, [81]=1, [82]=1, [83]=1, [84]=1, [85]=1, [86]=1, [92]=1, [87]=1, [88]=1, [49]=1, [50]=1, [51]=1, [54]=1,
	[1]=2, [4]=2, [10]=2, [11]=2, [12]=2, [13]=2, [41]=2, [43]=2, [44]=2, [45]=2, [46]=2,
	[16]=3, [17]=3, [18]=3, [39]=3, [40]=3, [90]=3, [91]=3, [3]=3,
	[22]=4, [23]=4, [24]=4, [71]=4, [72]=4, [73]=4, [74]=4, [75]=4, [76]=4, [89]=4,
}
for id, weapon in pairs(weapons.names) do
	if (id == 3 or (id > 15 and id < 19) or (id == 90 or id == 91)) then -- 3 16 17 18 (for gunOn)
		if sex == "Мужчина" then
			gunOn[id] = 'снял'
		elseif sex == "Женщина" then
			gunOn[id] = 'снялa'
		end
	else
		if sex == "Мужчина" then
			gunOn[id] = 'достал'
		elseif sex == "Женщина" then
			gunOn[id] = 'досталa'
		end
	end
	if (id == 3 or (id > 15 and id < 19) or (id > 38 and id < 41) or (id == 90 or id == 91)) then -- 3 16 17 18 39 40 (for gunOff)
		if sex == "Мужчина" then
			gunOff[id] = 'повесил'
		elseif sex == "Женщина" then
			gunOff[id] = 'повесилa'
		end
	else
		if sex == "Мужчина" then
			gunOff[id] = 'убрал'
		elseif sex == "Женщина" then
			gunOff[id] = 'убралa'
		end
	end
	if id > 0 then
		gunPartOn[id] = rpTakeNames[rpTake[id]][1]
		gunPartOff[id] = rpTakeNames[rpTake[id]][2]
	end
end

function onUpdate()

	if nowGun ~= getCurrentCharWeapon(PLAYER_PED) then
		oldGun = nowGun
		nowGun = getCurrentCharWeapon(PLAYER_PED)
		if oldGun == 0 then
			sampSendCommand("/me " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
		elseif nowGun == 0 then
			sampSendCommand("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun])
		else
			sampSendCommand("/me " .. gunOff[oldGun] .. " " .. weapons.get_name(oldGun) .. " " .. gunPartOff[oldGun] .. ", после чего " .. gunOn[nowGun] .. " " .. weapons.get_name(nowGun) .. " " .. gunPartOn[nowGun])
		end
	end

end
