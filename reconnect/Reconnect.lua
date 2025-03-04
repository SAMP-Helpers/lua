script_name('Reconnect')
script_version('1.0')
script_version_number(1)
script_author('The MonetLoader Team')
script_description('Reconnect to server with /rec command.')

local sf = require('sampfuncs')

function main()
    if not isSampLoaded() then script.this:unload() end
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand('rec', function(arg)
        lua_thread.create(function()
            msg("Скрипт может работать нестабильно, либо вовсе не работать! Фикса - нету!")
            arg = tonumber(arg) or 3
            local ms = 500 + arg * 1000
            if ms <= 0 then
                ms = 100
            end
            while ms > 0 do
                if ms <= 500 then
                local bs = raknetNewBitStream()
                raknetBitStreamWriteInt8(bs, sf.PACKET_DISCONNECTION_NOTIFICATION)
                raknetSendBitStreamEx(bs, sf.SYSTEM_PRIORITY, sf.RELIABLE, 0)
                raknetDeleteBitStream(bs)
                end

                printStringNow("wait: ~r~" .. tostring(ms) .. "ms", 100)
                wait(100)
                ms = ms - 100
            end

            bs = raknetNewBitStream()
            raknetEmulPacketReceiveBitStream(sf.PACKET_CONNECTION_LOST, bs)
            raknetDeleteBitStream(bs)

            printStringNow("~g~reconnect", 3000)
        end)
    end)

    repeat wait(0) until sampIsLocalPlayerSpawned()
    msg('Перезайти на сервер можно командой {00ccff}/rec [время ожидания]')

    wait(-1)
end

function msg(text)
    sampAddChatMessage('{00ccff}[Reconnect] {ffffff}' .. text, -1)
end
