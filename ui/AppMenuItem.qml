import QtQuick
import QtQuick.Controls

MenuItem {
    id: control

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 32
        radius: 3
        color: control.highlighted ? "#3d3d3d" : "transparent"
    }

    contentItem: Row {
        spacing: 10
        leftPadding: 10
        rightPadding: 10
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: icon

            source: control.icon.source
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: control.icon.source != ""
        }

        Text {
            text: control.text
            font: control.font
            color: "#fafafa"
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
