-- Real mpv, local audio and null output: no YouTube/network or Unix socket needed.
local utils = require 'mp.utils'
local path = os.getenv('CASSETTE_MPV_EVENT_LOG')
local first = '/tmp/cassette-test-audio/01 été.wav'
local second = '/tmp/cassette-test-audio/02.wav'
local loaded = 0
local function emit(event)
    local file = assert(io.open(path, 'a'))
    file:write(utils.format_json(event), '\n'); file:close()
end
mp.register_event('start-file', function(event) emit(event) end)
mp.register_event('file-loaded', function()
    loaded = loaded + 1
    emit({event='file-loaded'})
    if loaded == 1 then
        mp.add_timeout(0.15, function()
            emit({event='test-replace'})
            mp.commandv('loadfile', second, 'replace')
        end)
    end
end)
mp.register_event('end-file', function(event)
    emit(event)
    if event.reason == 'eof' then
        if loaded == 2 then
            emit({event='test-replace'})
            mp.commandv('loadfile', first, 'replace')
        elseif loaded == 3 then mp.commandv('quit', '0') end
    end
end)
mp.add_timeout(0.05, function() emit({event='test-replace'}); mp.commandv('loadfile', first, 'replace') end)
