local sampev = require('samp.events')

local day_afk = 30
local reason_day = 30
local uninvite = false

sampRegisterChatCommand('fcleaner', function (arg)
    if arg:find('(%d+)') then
        day_afk = tonumber(arg)
        uninvite = true
        sampSendChat('/lmenu')
    else
        sampAddChatMessage('Используйте /fcleaner [кол-во дней афк]', -1)
    end
end)

function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
    if uninvite and title:find('$') and text:find('Управление членами организации') then
		sampSendDialogResponse(dialogid, 1, 1, 0)
		return false 
	end
    if uninvite and text:find('Игроки онлайн') and text:find("Игроки оффлайн") then
        sampSendDialogResponse(dialogid, 1, 1, 0)
		return false 
    end
    if uninvite and title:find('Увольнение %(оффлайн%)') then
        local counter = -1
        for line in text:gmatch('([^\n\r]+)') do
            counter = counter + 1
            local nick, days, rank, online = line:match("(.+)%s+(%d+)%s+дней.-%[(%d+)%]%s+%[%s+([%d%.]+)%s+час")
            if days and tonumber(days) >= tonumber(day_afk) then
                reason_day = days
                sampSendDialogResponse(dialogid, 1, counter - 1, "")
                return false
            elseif not line:find('Последний вход в игру') then
                sampAddChatMessage('Больше нету игроков которые ' .. day_afk .. " дней не в сети!", -1)
                uninvite = false
                break
            end
       end 
    end
    if uninvite and text:find("Уволить игрока") and text:find("Изменить ранг игроку") then
        sampSendDialogResponse(dialogid, 1, 0, '')  
        return false
    end
    if uninvite and text:find("Укажите причину(.+)увольнения(.+)игрока из фракции") then
        sampSendDialogResponse(dialogid, 1,  0, 'Неактив (' .. reason_day .. ' дней не в игре)')
        return false
    end

end

function sampev.onServerMessage(color, text)
    if uninvite and text:find("(.+) выгнал (.+) из организации. Причина%: Неактив") then
        sampSendChat('/lmenu')
        return false
    end
end