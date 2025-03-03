script_name('AutoSell Fish & Items')
script_author('MTG MODS')

local se = require "samp.events"

function se.onShowDialog(id, style, title, but_1, but_2, text)
	if string.find(title, "Продажа рыбы") then
		-- if string.find(text, ".+\n{%x+}%s%-%s{%x+}Стоимость%s1%sшт:%s{%x+}.+\n{%x+}%s%-%s{%x+}У%sвас%sв%sналичии:%s{%x+}(%d+)%sшт%.") then
		-- 	local count = string.match(text, ".+\n{%x+}%s%-%s{%x+}Стоимость%s1%sшт:%s{%x+}.+\n{%x+}%s%-%s{%x+}У%sвас%sв%sналичии:%s{%x+}(%d+)%sшт%.")
		-- 	if tonumber(count) > 0 then
		-- 		if tonumber(count) > 100 then
		-- 			count = '100'
		-- 		end
		-- 		sampSendDialogResponse(id, 1, 0, count)
		-- 		return false
		-- 	end
		-- end
		if string.find(text, "Рыба(.+)Рыба(.+)Рыба(.+)Рыба") then
			local index = -1
			local finded_fish = false
			for line in text:gmatch('[^\n]+') do
				if line:find('Продать всю рыбу') then
					if not line:find('0 шт') then
						sampSendDialogResponse(id, 1, index, 0)
						finded_fish = true
					else
						sampSendDialogResponse(id, 2, index, 0)
						sampAddChatMessage('[AutoSell Fish Items] У вас нету рыбы для продажи!', -1)
						finded_fish = true
					end
				else
					index = index + 1
				end
			end
			if finded_fish then
				return false
			end
		end
	end
	if string.find(title, "Продажа редких вещей") then
		if string.find(text, ".+\n{%x+}%s%-%s{%x+}Стоимость%s1%sшт:%s{%x+}.+\n{%x+}%s%-%s{%x+}У%sвас%sв%sналичии:%s{%x+}(%d+)%sшт%.") then
			local count = string.match(text, ".+\n{%x+}%s%-%s{%x+}Стоимость%s1%sшт:%s{%x+}.+\n{%x+}%s%-%s{%x+}У%sвас%sв%sналичии:%s{%x+}(%d+)%sшт%.")
			if tonumber(count) > 0 then
				if tonumber(count) > 100 then
					count = '100'
				end
				sampSendDialogResponse(id, 1, 0, count)
				return false
			end
		end
		if string.find(text, "Брошь(.+)Кулон(.+)Череп(.+)Шляпа") then
			local index = -1
			local finded_artef = false
			for line in text:gmatch('[^\n]+') do
				if line:find('%{ffff00%}') then
					sampSendDialogResponse(id, 1, index, 0)
					finded_artef = true
				else
					index = index + 1
				end
			end
			if finded_artef then
				return false
			else
				sampAddChatMessage('[AutoSell Fish Items] У вас нету редких вещей для продажи!', -1)
				sampSendDialogResponse(id, 2, index, 0)
				return false
			end
			
		end
	end
	if string.find(title, "Продажа всей рыбы") then
		sampSendDialogResponse(id, 1, 0, 0)
		return false
	end
end