import "."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

ApplicationWindow {
    id: window

    property var applicationRoot: null
    readonly property bool isIncognito: windowProfile && windowProfile.offTheRecord
    property WebEngineProfile windowProfile: null
    property url initialUrl: "nicol://new-tab/"
    property Item currentWebView: (webViewRepeater.count > bar.currentIndex && bar.currentIndex >= 0) ? webViewRepeater.itemAt(bar.currentIndex) : null
    property int previousVisibility: Window.Windowed

    function updateUrlBar() {
        if (!urlInput)
            return ;

        if (urlInput.activeFocus)
            return ;

        if (currentWebView && currentWebView.url) {
            let urlStr = currentWebView.url.toString();
            urlInput.text = (urlStr === initialUrl.toString()) ? "" : urlStr;
            urlInput.cursorPosition = 0;
        } else {
            urlInput.text = "";
        }
    }

    function addTab(url) {
        var loadUrl = url ? url.toString() : initialUrl.toString();
        tabsModel.append({
            "title": "New Tab",
            "address": loadUrl,
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
            window.close();
        }
    }

    function openTabWithRequest(request) {
        tabsModel.append({
            "title": "New Tab",
            "address": "",
            "icon": ""
        });
        var newIndex = tabsModel.count - 1;
        bar.currentIndex = newIndex;
        var newItem = webViewRepeater.itemAt(newIndex);
        if (newItem) {
            request.openIn(newItem);
        } else {
            console.warn("View not ready for request, opening normally.");
            request.openIn(currentWebView);
        }
    }

    width: 1024
    height: 768
    visible: true
    title: currentWebView && currentWebView.title ? currentWebView.title : "Nicol Browser"
    color: "#1e1e1e"
    Component.onCompleted: {
        addTab();
        Qt.callLater(function() {
            if (urlInput) {
                urlInput.forceActiveFocus();
                urlInput.selectAll();
            }
        });
    }

    ListModel {
        id: tabsModel
    }

    Shortcut {
        sequences: ["Ctrl+N"]
        onActivated: {
            window.applicationRoot.createDefaultWindow();
        }
    }

    Shortcut {
        sequences: ["Ctrl+Shift+N"]
        onActivated: {
            window.applicationRoot.createIncognitoWindow();
        }
    }

    Shortcut {
        sequences: ["Ctrl+T"]
        onActivated: {
            addTab();
            urlInput.forceActiveFocus();
            urlInput.selectAll();
        }
    }

    Shortcut {
        sequences: [StandardKey.Close]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.RequestClose);

        }
    }

    Shortcut {
        sequences: ["Ctrl+L"]
        onActivated: {
            urlInput.forceActiveFocus();
            urlInput.selectAll();
        }
    }

    Shortcut {
        sequences: [StandardKey.Refresh, "Ctrl+R"]
        onActivated: {
            if (currentWebView)
                currentWebView.reload();

        }
    }

    Shortcut {
        sequences: [StandardKey.Back]
        onActivated: {
            if (currentWebView && currentWebView.canGoBack)
                currentWebView.goBack();

        }
    }

    Shortcut {
        sequences: [StandardKey.Forward]
        onActivated: {
            if (currentWebView && currentWebView.canGoForward)
                currentWebView.goForward();

        }
    }

    Shortcut {
        sequences: ["F11"]
        onActivated: {
            if (window.currentWebView) {
                if (window.visibility !== Window.FullScreen) {
                    window.previousVisibility = window.visibility;
                    window.visibility = Window.FullScreen;
                    fullScreenNotification.show();
                } else {
                    if (window.currentWebView && window.currentWebView.isFullScreen)
                        window.currentWebView.triggerWebAction(WebEngineView.ExitFullScreen);

                    window.visibility = window.previousVisibility;
                }
            }
        }
    }

    Shortcut {
        sequences: ["Esc"]
        context: Qt.ApplicationShortcut
        onActivated: {
            if (window.visibility === Window.FullScreen) {
                if (window.currentWebView && window.currentWebView.isFullScreen)
                    window.currentWebView.triggerWebAction(WebEngineView.ExitFullScreen);

                window.visibility = window.previousVisibility;
                return ;
            }
            if (window.currentWebView && window.currentWebView.loading)
                window.currentWebView.stop();

        }
    }

    Shortcut {
        sequences: ["Ctrl+0"]
        onActivated: {
            if (window.currentWebView) {
                window.currentWebView.zoomFactor = 1;
                zoomOverlay.show();
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.ZoomOut]
        onActivated: {
            if (window.currentWebView) {
                window.currentWebView.zoomFactor -= 0.1;
                zoomOverlay.show();
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.ZoomIn]
        onActivated: {
            if (window.currentWebView) {
                window.currentWebView.zoomFactor += 0.1;
                zoomOverlay.show();
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.Copy]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.Copy);

        }
    }

    Shortcut {
        sequences: [StandardKey.Cut]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.Cut);

        }
    }

    Shortcut {
        sequences: [StandardKey.Paste]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.Paste);

        }
    }

    Shortcut {
        sequences: ["Shift+" + StandardKey.Paste]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.PasteAndMatchStyle);

        }
    }

    Shortcut {
        sequences: [StandardKey.SelectAll]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.SelectAll);

        }
    }

    Shortcut {
        sequences: [StandardKey.Undo]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.Undo);

        }
    }

    Shortcut {
        sequences: [StandardKey.Redo]
        onActivated: {
            if (window.currentWebView)
                window.currentWebView.triggerWebAction(WebEngineView.Redo);

        }
    }

    Shortcut {
        sequences: [StandardKey.Quit]
        onActivated: {
            window.close();
        }
    }

    StackLayout {
        id: webviewStack

        anchors.fill: parent
        currentIndex: bar.currentIndex || 0

        Repeater {
            id: webViewRepeater

            model: tabsModel

            WebEngineView {
                profile: window.windowProfile || null
                url: model.address
                onUrlChanged: {
                    if (url.toString() !== model.address)
                        model.address = url.toString();

                    if (this === window.currentWebView)
                        window.updateUrlBar();

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
                    if (request.destination === WebEngineView.NewViewInNewWindow) {
                        if (window.applicationRoot) {
                            var newWin = window.applicationRoot.createBrowserWindow(window.windowProfile);
                            if (newWin)
                                newWin.openTabWithRequest(request);

                        }
                    } else {
                        window.openTabWithRequest(request);
                    }
                }
                onSelectClientCertificate: function(selection) {
                    selection.certificates[0].select();
                }
                onCertificateError: function(error) {
                    error.rejectCertificate();
                    console.warn("Certificate error rejected:", error.description);
                }
                onDesktopMediaRequested: function(request) {
                    request.selectScreen(request.screensModel.index(0, 0));
                }
                onWindowCloseRequested: closeTab(bar.currentIndex)
                onFullScreenRequested: function(request) {
                    if (request.toggleOn) {
                        window.previousVisibility = window.visibility;
                        window.visibility = Window.FullScreen;
                        fullScreenNotification.show();
                        request.accept();
                    } else {
                        window.visibility = window.previousVisibility;
                        request.accept();
                    }
                }
                onProfileChanged: {
                    if (profile) {
                        settings.javascriptEnabled = true;
                        settings.javascriptCanOpenWindows = true;
                        settings.localStorageEnabled = true;
                        settings.pluginsEnabled = true;
                        settings.fullScreenSupportEnabled = true;
                        settings.autoLoadImages = true;
                        settings.localContentCanAccessRemoteUrls = true;
                        settings.allowRunningInsecureContent = false;
                        settings.errorPageEnabled = true;
                        settings.scrollAnimatorEnabled = true;
                        settings.pdfViewerEnabled = true;
                    }
                }
            }

        }

    }

    ZoomOverlay {
        id: zoomOverlay

        zoom: currentWebView ? currentWebView.zoomFactor : 1
    }

    FullScreenNotification {
        id: fullScreenNotification
    }

    header: ColumnLayout {
        id: browserUI

        visible: window.visibility !== Window.FullScreen
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

                    Layout.fillWidth: true
                    Layout.preferredWidth: 420
                    Layout.maximumWidth: 800
                    Layout.preferredHeight: 32
                    placeholderText: "Search or enter address"
                    color: "#fafafa"
                    font.pixelSize: 15
                    selectByMouse: true
                    onAccepted: {
                        let input = text.trim();
                        let targetUrl = "";
                        if (["http", "https", "file", "view-source", "data", "blob", "about", "nicol"].some((p) => {
                            return input.startsWith(p);
                        }))
                            targetUrl = input;
                        else if (input.includes(".") && !input.includes(" "))
                            targetUrl = "https://" + input;
                        else
                            targetUrl = "https://duckduckgo.com/?q=" + encodeURIComponent(input) + "&ia=web";
                        if (bar.currentIndex >= 0 && bar.currentIndex < tabsModel.count) {
                            tabsModel.setProperty(bar.currentIndex, "address", targetUrl);
                            if (currentWebView)
                                currentWebView.forceActiveFocus();

                        }
                        focus = false;
                        cursorPosition = 0;
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            window.updateUrlBar();

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
                                window.close();
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
