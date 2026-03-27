// modules/clock/Clock.qml  — BACKEND ONLY
// Custom module: vertical layout splits hours/minutes into separate fields.
// Will also anchor the notification center data layer when that is built.
pragma Singleton

import QtQuick
import qs.globals

QtObject {
    readonly property string moduleType: "custom"
    readonly property string time: Time.time
    readonly property string date: Time.date
}
