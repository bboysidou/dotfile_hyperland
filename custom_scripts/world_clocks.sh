#!/bin/bash
algiers=$(TZ='Africa/Algiers' date +'%H:%M %Z')
montreal=$(TZ='America/Montreal' date +'%H:%M %Z')
alberta=$(TZ='America/Edmonton' date +'%H:%M %Z')
sanfran=$(TZ='America/Los_Angeles' date +'%H:%M %Z')

notify-send -a "World Clocks" "World Clocks" "\n<b>🇩🇿 Algiers</b>\n    ${algiers}\n\n<b>🇨🇦 Montreal</b>\n    ${montreal}\n\n<b>🇨🇦 Alberta</b>\n    ${alberta}\n\n<b>🇺🇸 San Francisco</b>\n    ${sanfran}" -t 5000
