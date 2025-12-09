import QtQuick
import QtQuick.Controls

ToolButton {
  implicitWidth: 24
  implicitHeight: 24

  property string tooltipText: ""

    ToolTip.visible: hovered && tooltipText.length > 0
    ToolTip.delay: 1500
    ToolTip.text: tooltipText

    background: Rectangle {
      implicitWidth: 24
      implicitHeight: 24
      radius: 4
      color: parent.down ? "#3e3e3e" : (parent.hovered ? "#2e2e2e" : "transparent")
      Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
      text: parent.text
      font.pixelSize: 16
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      color: "#fafafa"
    }
  }