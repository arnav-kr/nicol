import QtQuick
import QtQuick.Controls

Button {
  id: closeButton
  implicitWidth: 30
  implicitHeight: 30
  flat: true

  property string tooltipText: ""

    ToolTip.visible: hovered && tooltipText.length > 0
    ToolTip.delay: 1000
    ToolTip.text: tooltipText

    background: Rectangle {
      height: parent.height
      width: parent.width
      color: parent.enabled ? (parent.down ? "#3e3e3e" : (parent.hovered ? "#2e2e2e" : "transparent")) : "transparent"
      radius: 4
      Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
      text: parent.text
      font.pixelSize: 16
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      color: parent.enabled ? "#dadada" : "#7a7a7a"
    }
  }