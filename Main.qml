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
    property url ntpUrl: Qt.resolvedUrl("chrome/ntp/index.html")
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
        height: 36
        Repeater {
            model: tabsModel
            TabButton {
                id: tabBtn
                text: model.title
                width: implicitWidth + 42
                checked: bar.currentIndex === index

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
                    text: "×"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 6
                    anchors.leftMargin: 6
                    background: Rectangle {
                        color: "#3d3d3d"
                        radius: 2
                    }
                    flat: true
                    width: 24
                    height: 24
                    onClicked: { closeTab(index) }
                    visible: bar.currentIndex == index
                }
            }
        }
        TabButton {
            text: "+"
            width: 46
            onClicked: { addTab() }
        }
    }
    Rectangle {
        height: 32
        Layout.fillWidth: true
        color: "#1e1e1e"
        RowLayout {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            ToolbarButton {
                Layout.leftMargin: 16
                text: "<"
                onClicked: currentWebView.goBack()
            }
            ToolbarButton {
                text: ">"
                onClicked: currentWebView.goForward()
            }
            ToolbarButton {
                text: currentWebView && currentWebView.loading ? "✕" : "⟳"
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
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
                    text: currentWebView && currentWebView.url ? currentWebView.url : ""
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
                            currentWebView.url = urlInput.text
                        }
                        else {
                            currentWebView.url = "https://google.com/search?q=%1".arg(urlInput.text)
                        }
                        currentWebView.forceActiveFocus()
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
            onIconChanged: model.icon = icon.toString() || ""
            lifecycleState: visible ? WebEngineView.LifecycleState.Active : WebEngineView.LifecycleState.Frozen
        }
    }
}
}