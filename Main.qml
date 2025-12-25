import QtQuick
import QtWebEngine

QtObject {
    id: root

    property WebEngineProfilePrototype defaultProto
    property WebEngineProfilePrototype otrProto
    property var defaultProfile: null
    property Component browserWindowComponent
    property var openWindows: []

    function trackWindow(win) {
        if (!win)
            return ;

        openWindows.push(win);
        if (win.closing)
            win.closing.connect(function() {
            var idx = openWindows.indexOf(win);
            if (idx !== -1)
                openWindows.splice(idx, 1);

        });

    }

    function createBrowserWindow(profile, url) {
        if (!profile)
            return null;

        var newWindow = browserWindowComponent.createObject(root, {
            "windowProfile": profile,
            "initialUrl": url ? url : "nicol://new-tab/"
        });
        if (newWindow) {
            trackWindow(newWindow);
            newWindow.show();
        } else {
            console.error("failed to create BrowserWindow object");
        }
        return newWindow;
    }

    function createDefaultWindow() {
        if (defaultProfile)
            createBrowserWindow(defaultProfile, "nicol://new-tab/");

    }

    function createIncognitoWindow() {
        var incognitoProfile = otrProto.instance();
        profileHelper.setupProfile(incognitoProfile);
        var window = createBrowserWindow(incognitoProfile, "nicol://incognito");
        if (window)
            window.title = "Nicol (Incognito)";

    }

    Component.onCompleted: {
        defaultProfile = defaultProto.instance();
        if (defaultProfile) {
            profileHelper.setupProfile(defaultProfile);
            createDefaultWindow();
        } else {
            console.error("filed to launch default profile");
        }
    }

    defaultProto: WebEngineProfilePrototype {
        storageName: "NicolProfile"
    }

    otrProto: WebEngineProfilePrototype {
    }

    browserWindowComponent: BrowserWindow {
        applicationRoot: root
    }

}
