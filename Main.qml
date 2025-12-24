import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "ui"

ApplicationWindow {
    id: window

    property url ntpUrl: "nicol://new-tab/"
    property Item currentWebView: (webViewRepeater.count > bar.currentIndex && bar.currentIndex >= 0) ? webViewRepeater.itemAt(bar.currentIndex) : null

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
            if (index === bar.currentIndex)
                bar.currentIndex = Math.max(0, index - 1);
            else if (index < bar.currentIndex)
                bar.currentIndex--;
            tabsModel.remove(index);
        } else {
            Qt.quit();
        }
    }

    width: 1024
    height: 768
    visible: true
    title: currentWebView && currentWebView.title ? currentWebView.title : "Nicol Browser"
    color: "#1e1e1e"
    Component.onCompleted: {
        addTab();
    }

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
                url: (model.address && model.address !== "") ? model.address : ntpUrl
                onUrlChanged: {
                    if (model.address !== url.toString())
                        model.address = url.toString();

                }
                onTitleChanged: model.title = title || ""
                onLoadingChanged: {
                    urlInput.cursorPosition = 0;
                }
                onVisibleChanged: {
                    if (visible)
                        forceActiveFocus();

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
                    id: backButton

                    Layout.leftMargin: 16
                    text: "<"
                    enabled: currentWebView && currentWebView.canGoBack ? currentWebView.canGoBack : false
                    onClicked: currentWebView.goBack()

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            if (currentWebView && currentWebView.canGoBack)
                                historyMenu.open();

                        }
                    }

                    Menu {
                        id: historyMenu

                        opacity: 0.9
                        x: -8
                        y: urlBar.height - 8
                        width: Math.max(500, window.width * 0.3)

                        Instantiator {
                            model: window.currentWebView?.history?.items
                            onObjectAdded: function(index, object) {
                                let count = window.currentWebView.history.count;
                                historyMenu.insertItem(count - index - 1, object);
                            }
                            onObjectRemoved: function(index, object) {
                                historyMenu.removeItem(object);
                            }

                            MenuItem {
                                required property var model

                                onTriggered: window.currentWebView.goBackOrForward(model.offset)
                                enabled: model.offset
                                checked: model.offset === 0

                                background: Rectangle {
                                    implicitHeight: parent.checked ? 32 : 28
                                    anchors.fill: parent
                                    anchors.bottomMargin: parent.checked ? 2 : 0
                                    color: parent.checked ? "#3d3d3d" : (parent.highlighted ? "#2d2d2d" : "transparent")
                                    border.color: "transparent"
                                    radius: 3
                                }

                                contentItem: RowLayout {
                                    spacing: 8
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        source: model.icon || ""
                                        Layout.preferredWidth: 16
                                        Layout.preferredHeight: 16
                                        sourceSize: Qt.size(16, 16)
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    Text {
                                        text: model.title
                                        color: "#dadada"
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                }

                            }

                        }

                    }

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

                    function updateBar() {
                        if (!currentWebView || !currentWebView.url) {
                            text = "";
                            return ;
                        }
                        let urlStr = currentWebView.url.toString();
                        text = (urlStr === ntpUrl.toString()) ? "" : urlStr;
                        cursorPosition = 0;
                    }

                    Layout.fillWidth: true
                    Layout.preferredWidth: 420
                    Layout.maximumWidth: 800
                    Layout.preferredHeight: 32
                    placeholderText: "Search or enter address"
                    color: "#fafafa"
                    font.pixelSize: 15
                    selectByMouse: true
                    text: {
                        if (!currentWebView || !currentWebView.url)
                            return "";

                        let urlStr = currentWebView.url.toString();
                        return (urlStr === ntpUrl.toString()) ? "" : urlStr;
                    }
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
                            let searchEngine = "https://duckduckgo.com/?q=%s";
                            targetUrl = searchEngine.replace("%s", encodeURIComponent(input));
                        }
                        if (bar.currentIndex >= 0 && bar.currentIndex < tabsModel.count) {
                            tabsModel.setProperty(bar.currentIndex, "address", targetUrl);
                            if (currentWebView)
                                currentWebView.forceActiveFocus();

                        }
                        focus = false;
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            updateBar();

                    }

                    Connections {
                        function onCurrentWebViewChanged() {
                            urlInput.updateBar();
                        }

                        target: window
                    }

                    Connections {
                        function onUrlChanged() {
                            if (!urlInput.activeFocus)
                                urlInput.updateBar();

                        }

                        function onLoadingChanged() {
                            if (!urlInput.activeFocus && !currentWebView.loading)
                                urlInput.updateBar();

                        }

                        target: currentWebView
                        ignoreUnknownSignals: true
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
                        appMenu.open();
                    }

                    Menu {
                        id: appMenu

                        opacity: 0.9
                        x: -appMenu.width + 40
                        y: urlBar.height - 8

                        AppMenuItem {
                            text: "New Tab"
                            onTriggered: {
                                addTab();
                            }
                        }

                        AppMenuItem {
                            text: "Close Tab"
                            onTriggered: {
                                closeTab(bar.currentIndex);
                            }
                        }

                        AppMenuItem {
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
        }

    }

}
