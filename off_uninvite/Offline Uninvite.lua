local sampev = require('samp.events')

local day_afk
local uninvite = false
local reason_day = 'X'

local players_to_kick = {}
function kick_players()
    lua_thread.create(function ()
        for index, value in ipairs(players_to_kick) do
            reason_day = value.day
            sampSendChat('/uninviteoff ' .. value.nickname)
            printStringNow(index .. '/' .. #players_to_kick, 250)
            wait(250)
        end
        uninvite = false
    end)
end

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
            --sampAddChatMessage(line, -1)

            -- {FFFFFF}Alexsander_Martelli 6 дней Старший Гинеколог[6] [ 0.0 часов ]
            -- {FFFFFF}Daisuke_Tachibana 5 дней {90EE90}Старший Гинеколог[6] (24 дней) [ 0.2 часов ]
            -- {FFFFFF}Lina_Samura 0 час(ов) {90EE90}Заведующий Гинеколог[8] (28 дней) [ 6.0 часов ]
            -- if line:find('%{90EE90%}') then
            --     nick, days, rank, rank_number = line:match('{FFFFFF}([%w_]+) (%d+) дней %{90EE90%}([^%[]+)%[(%d+)%]')
            --     print(nick, days, rank, rank_number)
            -- else
            --     nick, days, rank, rank_number = line:match('{FFFFFF}([%w_]+) (%d+) дней ([^%[]+)%[(%d+)%]')
            --     nick, days, rank, rank_number = line:match('%{FFFFFF%}(.+) (%d+) дней (.+)%[(%d+)')
            --     print(nick, days, rank, rank_number)
            -- end
            --local nick, days, rank, online = line:match("(.+)%s+(%d+)%s+дней.-%[(%d+)%]%s+%[%s+([%d%.]+)%s+час")


            local nick, days = line:match("{FFFFFF}(.+)%s+(%d+) дней")
            if days and tonumber(days) >= tonumber(day_afk) then
                -- reason_day = days
                -- sampAddChatMessage(nick .. ', ' .. days, -1)
                -- sampSendDialogResponse(dialogid, 1, counter - 1, "")
                -- return false
                
                table.insert(players_to_kick, {nickname = nick, day = days})
                printStringNow('find ' .. #players_to_kick, 500)
            elseif line:find('{B0E73A}Вперед') then
                sampSendDialogResponse(dialogid, 1, counter - 1, "")
                return false
            elseif ((not text:find('{B0E73A}Вперед'))) then
                sampAddChatMessage('Больше нету игроков которые ' .. day_afk .. " дней не в сети!", -1)
                sampSendDialogResponse(dialogid, 2, 0, 0)
                kick_players()
                return false
            -- elseif not line:find('Последний вход в игру') then
            --     sampAddChatMessage('Больше нету игроков которые ' .. day_afk .. " дней не в сети!", -1)
            --     uninvite = false
            --     sampSendDialogResponse(dialogid, 2, 0, 0)
            --     return false
            end
       end 
    end
    -- if uninvite and text:find("Уволить игрока") and text:find("Изменить ранг игроку") then
    --     sampSendDialogResponse(dialogid, 1, 0, '')  
    --     return false
    -- end
    if uninvite and text:find("Укажите причину(.+)увольнения(.+)игрока из фракции") then
        sampSendDialogResponse(dialogid, 1,  0, 'Неактив (' .. reason_day .. ' дней не в игре)')
        return false
    end

end

-- function sampev.onServerMessage(color, text)
    -- if uninvite and text:find("(.+) выгнал (.+) из организации. Причина%: Неактив") then
    --     sampSendChat('/lmenu')
    --     return false
    -- end
-- end