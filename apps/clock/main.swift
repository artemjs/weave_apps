// Clock App for WeaveOS
// Written in Swift-like syntax

var mode = "clock"
var stopwatchTime = 0
var stopwatchRunning = false
var timerTime = 300
var timerRunning = false

func formatTime(date) {
    return date.toLocaleTimeString()
}

func formatDate(date) {
    return date.toLocaleDateString(nil, {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    })
}

func formatStopwatch(ms) {
    let mins = Math.floor(ms / 60000)
    let secs = Math.floor((ms % 60000) / 1000)
    let centis = Math.floor((ms % 1000) / 10)
    return String(mins).padStart(2, "0") + ":" + String(secs).padStart(2, "0") + "." + String(centis).padStart(2, "0")
}

func formatTimer(secs) {
    let mins = Math.floor(secs / 60)
    let s = secs % 60
    return String(mins).padStart(2, "0") + ":" + String(s).padStart(2, "0")
}

func setMode(newMode) {
    mode = newMode
}

func toggleStopwatch() {
    stopwatchRunning = !stopwatchRunning
}

func resetStopwatch() {
    stopwatchRunning = false
    stopwatchTime = 0
}

func toggleTimer() {
    timerRunning = !timerRunning
}

func resetTimer() {
    timerRunning = false
    timerTime = 300
}

func setTimerPreset(seconds) {
    timerTime = seconds
    timerRunning = false
}

func updateStopwatch() {
    if (stopwatchRunning) {
        stopwatchTime = stopwatchTime + 10
    }
}

func updateTimer() {
    if (timerRunning && timerTime > 0) {
        timerTime = timerTime - 1
        if (timerTime <= 0) {
            timerRunning = false
        }
    }
}

func render() {
    let now = Date()
    print("Clock: " + formatTime(now))
    print("Date: " + formatDate(now))
}
