import QtQuick
import QtQuick.Controls

Rectangle {
    id: zoomOverlay

    property real zoom: 1
    property int displayDuration: 1000

    function show() {
        opacity = 1;
        hideTimer.restart();
    }

    radius: 6
    z: 50
    color: "#ce1f1f1f"
    border.color: "#2c2c2c"
    width: 64
    height: 32
    anchors.top: parent.top
    anchors.topMargin: 24
    anchors.horizontalCenter: parent.horizontalCenter
    visible: opacity > 0
    opacity: 0

    Timer {
        id: hideTimer

        interval: zoomOverlay.displayDuration
        onTriggered: zoomOverlay.opacity = 0
    }

    Text {
        text: Math.round(zoom * 100) + "%" || "100%"
        anchors.centerIn: parent
        color: "#fafafa"
        font.pixelSize: 14
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }

    }

}
