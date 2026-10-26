import QtQuick

QtObject {
    readonly property int width: 1400
    readonly property int height: 700
    readonly property int spacing: 24
    readonly property int calendarWidth: 330
    readonly property int sideWidth: 360
    readonly property int refreshMinutes: 30
    readonly property int agendaMinutes: 15
    readonly property int minuteMs: 60000
    readonly property real staleRatio: 0.9
    readonly property int saveDebounce: 500
    readonly property int days: 7
    readonly property var slotHours: [2, 5, 8, 11, 14, 17, 20, 23]
    readonly property int slotStep: 3
    readonly property int clockSize: 96
    readonly property int secondsSize: 34
    readonly property int dateSize: 15
    readonly property int clockSpacing: 6
    readonly property real orbitWidthRatio: 0.9
    readonly property real orbitHeightRatio: 0.62
    readonly property int orbitDash: 6
    readonly property real orbitOpacity: 0.35
    readonly property real orbitStartAngle: 90
    readonly property real frontAngle: 90
    readonly property int pillWidth: 58
    readonly property int pillHeight: 84
    readonly property real pillActiveScale: 1.35
    readonly property real depthScale: 0.18
    readonly property real depthFade: 0.45
    readonly property int pillTimeSize: 10
    readonly property int pillGlyphSize: 18
    readonly property int pillTempSize: 13
    readonly property int pillSpacing: 4
    readonly property int dayNavSize: 13
    readonly property real dayLetterSpacing: 2
    readonly property int tempSize: 92
    readonly property int conditionSize: 16
    readonly property int ringSize: 66
    readonly property real ringRadiusRatio: 0.44
    readonly property real ringThicknessRatio: 0.05
    readonly property int ringValueSize: 13
    readonly property int ringLabelSize: 10
    readonly property int ringSpacing: 8
    readonly property int ringRowSpacing: 18
    readonly property real windScaleMax: 20
    readonly property real feelsScaleMin: -10
    readonly property real feelsScaleMax: 45
    readonly property int agendaHeaderHeight: 44
    readonly property int agendaCardHeight: 96
    readonly property int agendaCardWidth: 300
    readonly property int agendaPadding: 16
    readonly property int agendaTitleSize: 15
    readonly property int agendaDetailSize: 12
    readonly property int agendaRuleWidth: 1
    readonly property int agendaSpacing: 6
    readonly property int urlFieldWidth: 520
    readonly property string stateFile: "weather.json"
    readonly property string agendaFile: "agenda.json"
    readonly property string clockFormat: "HH:mm"
    readonly property string secondsFormat: ":ss"
    readonly property string dateFormat: "dddd, MMMM dd"
    readonly property string dayFormat: "dddd"
    readonly property string agendaDateFormat: "dddd, dd MMM"
    readonly property string slotTimeFormat: "HH:00"
    readonly property string eventTimeFormat: "HH:mm"
    readonly property string tempTemplate: "%1°"
    readonly property string tempDecimalTemplate: "%1°"
    readonly property string windTemplate: "%1%2"
    readonly property string percentTemplate: "%1%"
    readonly property string rangeTemplate: "%1-%2"
    readonly property string todayTemplate: "%1 (Today)"
    readonly property string labelWind: "WIND"
    readonly property string labelHumidity: "HUMID"
    readonly property string labelRain: "RAIN"
    readonly property string labelFeels: "FEELS"
    readonly property string labelOpenWeb: "Open Web"
    readonly property string labelAllDay: "All day"
    readonly property string labelNoEvents: "Nothing scheduled."
    readonly property string labelNoWeather: "Weather unavailable"
    readonly property string labelUrl: "Paste your Google Calendar secret iCal address, then Enter"
    readonly property string labelWeather: "Weather"
    readonly property var codes: ({
            "0": ["Clear sky", "clear"],
            "1": ["Mainly clear", "clear"],
            "2": ["Partly cloudy", "partly"],
            "3": ["Overcast", "cloudy"],
            "45": ["Fog", "fog"],
            "48": ["Rime fog", "fog"],
            "51": ["Light drizzle", "drizzle"],
            "53": ["Drizzle", "drizzle"],
            "55": ["Dense drizzle", "drizzle"],
            "56": ["Freezing drizzle", "sleet"],
            "57": ["Freezing drizzle", "sleet"],
            "61": ["Light rain", "rain"],
            "63": ["Rain", "rain"],
            "65": ["Heavy rain", "pouring"],
            "66": ["Freezing rain", "sleet"],
            "67": ["Freezing rain", "sleet"],
            "71": ["Light snow", "snow"],
            "73": ["Snow", "snow"],
            "75": ["Heavy snow", "heavySnow"],
            "77": ["Snow grains", "snow"],
            "80": ["Rain showers", "rain"],
            "81": ["Rain showers", "rain"],
            "82": ["Violent showers", "pouring"],
            "85": ["Snow showers", "snow"],
            "86": ["Heavy snow showers", "heavySnow"],
            "95": ["Thunderstorm", "storm"],
            "96": ["Thunderstorm, hail", "hail"],
            "99": ["Thunderstorm, hail", "hail"]
        })
}
