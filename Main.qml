import QtQuick
import QtWebEngine

Window {
    width: 1024; height: 768
    visible: true
    title: "Nicol Browser"

    WebEngineView {
        anchors.fill: parent
        url: "https://google.com"
    }
}