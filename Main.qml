import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "ui"

ApplicationWindow {
    id: window

    property url ntpUrl: "nicol://new-tab/"
    property Item currentWebView: webviewStack.children[bar.currentIndex]

    function addTab(url = ntpUrl.toString()) {
        tabsModel.append({
            "title": "New Tab",
            "address": url,
            "icon": ""
        });
        bar.currentIndex = tabsModel.count - 1;
    }

    function closeTab(index) {
        if (tabsModel.count > 1) {
            tabsModel.remove(index);
            bar.currentIndex = tabsModel.count - 1;
        } else {
            Qt.quit();
        }
    }

    width: 1024
    height: 768
    visible: true
    title: currentWebView && currentWebView.title ? currentWebView.title : "Nicol Browser"
    color: "#1e1e1e"
    Component.onCompleted: tabsModel.append({
        "title": "New Tab",
        "address": ntpUrl.toString(),
        "icon": ""
    })

    ListModel {
        id: tabsModel
    }

    StackLayout {
        id: webviewStack

        anchors.fill: parent
        currentIndex: bar.currentIndex || 0

        Repeater {
            id: webViewRepeater

            model: tabsModel

            WebEngineView {
                Component.onCompleted: {
                    if (model.address)
                        url = model.address;
                    else
                        url = ntpUrl;
                }
                onUrlChanged: {
                    if (model.address !== url.toString())
                        model.address = url.toString();

                }
                onTitleChanged: model.title = title || ""
                onLoadingChanged: {
                    urlInput.cursorPosition = 0;
                }
                onIconChanged: model.icon = icon.toString() || ""
                lifecycleState: visible ? WebEngineView.LifecycleState.Active : WebEngineView.LifecycleState.Frozen
                onNewWindowRequested: function(request) {
                    addTab("");
                    const newTabWebView = webViewRepeater.itemAt(tabsModel.count - 1);
                    if (newTabWebView)
                        request.openIn(newTabWebView);

                }
            }

        }

    }

    header: ColumnLayout {
        spacing: 0

        Item {
            id: bar

            property int currentIndex: 0
            property int spacing: 6
            property bool overflowing: tabRow.width > (parent.width - newTabButton.width - (spacing * 3))

            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.topMargin: 4
            Layout.leftMargin: bar.spacing
            Layout.rightMargin: bar.spacing

            Button {
                id: leftScrollBtn

                z: 3
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: bar.overflowing
                width: visible ? 16 : 0
                height: 28
                flat: true
                enabled: tabFlickable.contentX > 1
                opacity: enabled ? 1 : 0.5
                onClicked: {
                    var newPos = Math.max(0, tabFlickable.contentX - 200);
                    tabFlickable.contentX = newPos;
                }

                background: Rectangle {
                    color: leftScrollBtn.hovered && leftScrollBtn.enabled ? "#3d3d3d" : "#003d3d3d"
                    radius: 4
                }

                contentItem: Text {
                    text: "〈"
                    font.pixelSize: 14
                    color: "#dadada"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

            Flickable {
                id: tabFlickable

                Layout.preferredWidth: parent.width - newTabButton.width - (bar.spacing * 4) - (leftScrollBtn.visible ? leftScrollBtn.width : 0) - (rightScrollBtn.visible ? rightScrollBtn.width : 0)
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: leftScrollBtn.visible ? leftScrollBtn.right : parent.left
                anchors.leftMargin: rightScrollBtn.visible ? bar.spacing : 0
                anchors.right: rightScrollBtn.visible ? rightScrollBtn.left : newTabButton.left
                anchors.rightMargin: leftScrollBtn.visible ? bar.spacing : 0
                contentWidth: tabRow.width
                contentHeight: parent.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                onContentWidthChanged: {
                    if (contentWidth > width && !movingHorizontally)
                        contentX = contentWidth - width;

                }

                RowLayout {
                    id: tabRow

                    height: parent.height
                    spacing: 4

                    Repeater {
                        model: tabsModel

                        AbstractButton {
                            id: tabBtn

                            property bool isCurrent: bar.currentIndex === index

                            Layout.preferredHeight: 34
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: {
                                let availableW = bar.width - 64;
                                let calculatedWidth = availableW / (tabsModel.count || 1);
                                return Math.min(240, Math.max(84, calculatedWidth));
                            }
                            onClicked: bar.currentIndex = index

                            background: Rectangle {
                                color: tabBtn.isCurrent ? "#2a2a2a" : (tabBtn.hovered ? "#282828" : "#002a2a2a")
                                radius: 6

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }

                                }

                            }

                            contentItem: RowLayout {
                                spacing: 8
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 6

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
                                    color: tabBtn.isCurrent ? "#ffffff" : "#a0a0a0"
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Button {
                                    id: closeButton

                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    flat: true
                                    visible: tabBtn.hovered || tabBtn.isCurrent
                                    onClicked: closeTab(index)

                                    background: Rectangle {
                                        color: closeButton.hovered ? "#3d3d3d" : "#003d3d3d"
                                        radius: 4

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 100
                                            }

                                        }

                                    }

                                    contentItem: Text {
                                        text: "✕"
                                        font.pixelSize: 16
                                        color: "#dadada"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                }

                            }

                        }

                    }

                }

                Behavior on contentX {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }

                }

            }

            Button {
                id: rightScrollBtn

                z: 3
                anchors.right: newTabButton.left
                anchors.rightMargin: bar.spacing
                anchors.leftMargin: bar.spacing
                anchors.verticalCenter: parent.verticalCenter
                visible: bar.overflowing
                width: visible ? 16 : 0
                height: 28
                flat: true
                enabled: (tabFlickable.contentX + tabFlickable.width) < (tabFlickable.contentWidth - 2)
                opacity: enabled ? 1 : 0.5
                onClicked: {
                    var newPos = Math.min(tabFlickable.contentWidth - tabFlickable.width, tabFlickable.contentX + 200);
                    tabFlickable.contentX = newPos;
                }

                background: Rectangle {
                    color: rightScrollBtn.hovered && rightScrollBtn.enabled ? "#3d3d3d" : "#003d3d3d"
                    radius: 4
                }

                contentItem: Text {
                    text: "〉"
                    font.pixelSize: 14
                    color: "#dadada"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

            Item {
                id: dummyItem

                width: 0
                anchors.left: tabFlickable.right
            }

            Button {
                id: newTabButton

                z: 3
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                x: bar.overflowing ? (parent.width - width) : (tabRow.width + bar.spacing)
                onClicked: addTab()

                background: Rectangle {
                    color: newTabButton.hovered ? "#3d3d3d" : "#2f2f2f"
                    radius: 6

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }

                    }

                }

                contentItem: Text {
                    text: "+"
                    font.pixelSize: 18
                    color: "#dadada"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }

        }

        Rectangle {
            id: urlBar

            height: 44
            Layout.fillWidth: true
            color: "#1e1e1e"

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
                    Layout.preferredHeight: 32
                    placeholderText: "Search or enter address"
                    // padding: 4
                    text: currentWebView && currentWebView.url ? currentWebView.url : ""
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            cursorPosition = 0;

                    }
                    color: "#fafafa"
                    font.pixelSize: 15
                    selectByMouse: true
                    onAccepted: {
                        let input = text.trim();
                        let targetUrl = "";
                        if (["http", "https", "file", "view-source", "data", "blob", "about", "nicol"].some((p) => {
                            return input.startsWith(p);
                        })) {
                            targetUrl = input;
                            cursorPosition = 0;
                        } else if (input.includes(".") && !input.includes(" ")) {
                            targetUrl = "https://" + input;
                        } else {
                            targetUrl = "https://google.com/search?q=" + input;
                        }
                        console.log("Navigating to: " + targetUrl);
                        if (currentWebView) {
                            currentWebView.url = targetUrl;
                            currentWebView.forceActiveFocus();
                            cursorPosition = 0;
                        }
                    }

                    background: Rectangle {
                        color: parent.activeFocus ? "#333333" : "#2a2a2a"
                        radius: 4
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
                        menu.popup();
                    }

                    Menu {
                        id: menu

                        MenuItem {
                            text: "New Tab"
                            onTriggered: {
                                addTab();
                            }
                        }

                        MenuItem {
                            text: "Close Tab"
                            onTriggered: {
                                closeTab(bar.currentIndex);
                            }
                        }

                        MenuItem {
                            text: "Quit"
                            onTriggered: {
                                Qt.quit();
                            }
                        }

                    }

                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#11d0d0d0"
            anchors.top: urlBar.bottom
        }

    }

}
