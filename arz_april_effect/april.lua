function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while (not isSampAvailable() and not sampIsLocalPlayerSpawned()) do wait(0) end 
    
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 131)
    raknetBitStreamWriteInt8(bs, 0)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)

end