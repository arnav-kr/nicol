import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui"
import QtWebEngine

ApplicationWindow {
    id: window
    width: 1024; height: 768
    visible: true
    title: currentWebView && currentWebView.title ? currentWebView.title : "Nicol Browser"
    property url ntpUrl: "nicol://new-tab/"
        color: "#1e1e1e"

        function addTab(url = ntpUrl.toString())
        {
            tabsModel.append({ "title": "New Tab", "address": url, "icon": "" })
            bar.currentIndex = tabsModel.count - 1
        }

        function closeTab(index)
        {
            if (tabsModel.count > 1)
            {
                tabsModel.remove(index)
            } else {
            Qt.quit()
        }
    }


    ListModel { id: tabsModel }
    Component.onCompleted: tabsModel.append({ "title": "Google", "address": ntpUrl.toString(), "icon": "" })

    property Item currentWebView: webviewStack.children[bar.currentIndex]

    header:
    ColumnLayout {
        spacing: 0
        TabBar {
            id: bar
            Layout.fillWidth: true
            padding: 4
            spacing: 4
            Repeater {
                model: tabsModel
                TabButton {
                    id: tabBtn
                    text: model.title
                    property real calculatedWidth: (bar.width - 55) / (tabsModel.count || 1)
                    width: Math.min(240, Math.max(48, calculatedWidth))
                    // checked: bar.currentIndex === index
                    font.pixelSize: 14

                    ToolTip.visible: hovered
                    ToolTip.text: model.title
                    ToolTip.delay: 500

                    background: Rectangle {
                        color: tabBtn.checked ? "#2a2a2a" : (tabBtn.hovered ? "#252525" : "transparent")
                        radius: 4
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    contentItem: RowLayout {
                        spacing: 8
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 32

                        Image {
                            source: model.icon
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            sourceSize: Qt.size(16, 16)
                            fillMode: Image.PreserveAspectFit
                            visible: model.icon !== ""
                        }

                        Text {
                            text: model.title
                            color: tabBtn.checked ? "#ffffff" : "#a0a0a0"
                            font: tabBtn.font
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: closeButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 6
                        anchors.leftMargin: 4

                        background: Rectangle {
                            color: closeButton.hovered ? "#3d3d3d" : "transparent"
                            radius: 4
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        contentItem: Text {
                            text: "✕"
                            font.pixelSize: 16
                            color: "#dadada"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        flat: true
                        width: 24
                        height: 24
                        onClicked: { closeTab(index) }
                        visible: tabBtn.hovered || tabBtn.checked
                    }
                }
            }
            TabButton {
                id: newTabButton
                width: 28
                height: 28
                Layout.leftMargin: 8
                font.pixelSize: 18

                background: Rectangle {
                    color: newTabButton.hovered ? "#3d3d3d" : "#2f2f2f"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: "+"
                    font: newTabButton.font
                    color: "#dadada"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: { addTab() }
            }
        }
        Rectangle {
            height: 40
            Layout.fillWidth: true
            color: "#1e1e1e"

            Rectangle {
                width: parent.width
                height: 1
                color: "#4d4d4d"
                opacity: 0.6
                anchors.bottom: parent.bottom
            }
            RowLayout {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                ToolbarButton {
                    Layout.leftMargin: 16
                    text: "<"
                    enabled: currentWebView && currentWebView.canGoBack ? currentWebView.canGoBack : false
                    onClicked: currentWebView.goBack()
                }
                ToolbarButton {
                    text: ">"
                    enabled: currentWebView && currentWebView.canGoForward ? currentWebView.canGoForward : false
                    onClicked: currentWebView.goForward()
                }
                ToolbarButton {
                    text: currentWebView && currentWebView.loading ? "✕" : "⟳"
                    onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32
                }
                TextField {
                    id: urlInput
                    Layout.fillWidth: true
                    Layout.preferredWidth: 420
                    Layout.maximumWidth: 800
                    Layout.preferredHeight: parent.height
                    placeholderText: "Search or enter address"
                    padding: 4

                    text: currentWebView && currentWebView.url ? currentWebView.url : ""

                    onActiveFocusChanged: {
                        if (!activeFocus) cursorPosition = 0
                    }

                    background: Rectangle {
                        color: parent.activeFocus ? "#333333" : "#2a2a2a"
                        radius: 4
                    }
                    color: "#fafafa"
                    font.pixelSize: 15
                    selectByMouse: true

                    onAccepted: {
                        let input = text.trim()
                        let targetUrl = ""
                        if (["http", "https", "file", "view-source", "data", "blob", "about", "nicol"].some(p => input.startsWith(p)))
                        {
                            targetUrl = input
                            cursorPosition = 0
                        }
                        else if (input.includes(".") && !input.includes(" ")) {targetUrl = "https://" + input}
                            else { targetUrl = "https://google.com/search?q=" + input }
                            console.log("Navigating to: " + targetUrl)

                            if (currentWebView)
                            {
                                currentWebView.url = targetUrl
                                currentWebView.forceActiveFocus()
                                cursorPosition = 0
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 32
                    }
                    ToolbarButton {
                        Layout.rightMargin: 16
                        text: "☰"
                        onClicked: {
                            menu.popup()
                        }
                        Menu {
                            id: menu
                            MenuItem {
                                text: "New Tab"
                                onTriggered: { addTab() }
                            }
                            MenuItem {
                                text: "Close Tab"
                                onTriggered: { closeTab(bar.currentIndex) }
                            }
                            MenuItem {
                                text: "Quit"
                                onTriggered: { Qt.quit() }
                            }
                        }
                    }
                }
            }
        }
        StackLayout {
            id: webviewStack
            anchors.fill: parent
            currentIndex: bar.currentIndex || 0
            Repeater {
                model: tabsModel
                WebEngineView {
                    Component.onCompleted: {
                        if (model.address)
                        {
                            url = model.address
                        } else {
                        url = ntpUrl
                    }
                }
                onUrlChanged: {
                    if (model.address !== url.toString())
                    {
                        model.address = url.toString()
                    }
                }
                onTitleChanged: model.title = title || ""
                onLoadingChanged: {
                    urlInput.cursorPosition = 0
                }
                onIconChanged: model.icon = icon.toString() || ""
                lifecycleState: visible ? WebEngineView.LifecycleState.Active : WebEngineView.LifecycleState.Frozen
                onNewWindowRequested: function(request) {
                addTab(request.requestedUrl.toString());
                let newTabWebView = webviewStack.children[webviewStack.children.length - 1];
                request.openIn(newTabWebView);
            }
        }
    }
}
}