import QtQuick
import QtQuick.Controls

Rectangle {
    id: fullScreenNotification

    property real zoom: 1
    property int displayDuration: 1500

    function show() {
        opacity = 1;
        hideTimer.restart();
    }

    radius: 6
    z: 50
    color: "#ce1f1f1f"
    border.color: "#2c2c2c"
    width: 256
    height: 36
    anchors.top: parent.top
    anchors.topMargin: 24
    anchors.horizontalCenter: parent.horizontalCenter
    visible: opacity > 0
    opacity: 0

    Timer {
        id: hideTimer

        interval: fullScreenNotification.displayDuration
        onTriggered: fullScreenNotification.opacity = 0
    }

    Text {
        text: "Toggling Fullscreen. ESC to exit."
        anchors.centerIn: parent
        elide: Text.ElideRight
        clip: true
        color: "#fafafa"
        font.pixelSize: 14
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }

    }

}
