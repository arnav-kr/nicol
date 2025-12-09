import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui"
import QtWebEngine

Window {
    width: 1024; height: 768
    visible: true
    title: "Nicol Browser"

    Rectangle {
        height: 32
        width: parent.width
        color: "#1e1e1e"
        RowLayout {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            ToolbarButton {
                Layout.leftMargin: 16
                text: "<"
                onClicked: webView.goBack()
            }
            ToolbarButton {
                text: ">"
                onClicked: webView.goForward()
            }
            ToolbarButton {
                text: "⟳"
                onClicked: webView.reload()
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 32
                Layout.maximumWidth: 84
                Layout.minimumWidth: 32
            }
            Rectangle {
                Layout.minimumWidth: 320
                Layout.preferredWidth: 420
                Layout.maximumWidth: parent.width - 480
                Layout.fillWidth: true
                height: 24
                color: "#2e2e2e"
                radius: 4
                TextInput {
                    id: urlInput
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignLeft
                    padding: 6
                    topPadding: 4
                    bottomPadding: 4
                    color: "#fafafa"
                    font.pixelSize: 14
                    clip: true
                    property string placeholderText: "Search or enter address"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: 8
                            text: urlInput.placeholderText
                            color: "#5d5d5d"
                            visible: !urlInput.text
                        }
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                        {
                            cursorPosition = 0
                        }
                    }
                    Keys.onReturnPressed: {
                        if (["http:", "https:", "blob:", "data:"].some(prefix => urlInput.text.startsWith(prefix)))
                        {
                            webView.url = urlInput.text
                        }
                        else {
                            webView.url = "https://google.com/search?q=%1".arg(urlInput.text)
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32
                    Layout.maximumWidth: 84
                    Layout.minimumWidth: 32
                }
                ToolbarButton {
                    text: "✕"
                    onClicked: Qt.quit()
                }
            }
        }
        WebEngineView {
            id: webView
            anchors.fill: parent
            anchors.topMargin: 32
            url: "https://www.google.com"
        }
    }