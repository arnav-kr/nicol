cmake_minimum_required(VERSION 3.16)

project(nicol VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick WebEngineQuick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appnicol
    main.cpp
)

qt_add_qml_module(appnicol
    URI nicol
    VERSION 1.0
    QML_FILES
    Main.qml
    ui/BrowserWindow.qml
    ui/ToolbarButton.qml
    ui/AppMenuItem.qml
    ui/ZoomOverlay.qml
    ui/FullScreenNotification.qml
    RESOURCES
    chrome/new-tab/index.html
    chrome/incognito/index.html
    chrome/error/404.html
    chrome/error/offline.html
    chrome/assets/styles/globals.css
    chrome/assets/logo_horizontal_dark.svg
    chrome/assets/logo_light.svg
    chrome/assets/logo_dark.svg
    chrome/assets/logo_horizontal_light.svg
)

set_target_properties(appnicol PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "dev.arnv.nicol"
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE_ICON_FILE "logo.icns"
)

target_link_libraries(appnicol
    PRIVATE Qt6::Quick
    PRIVATE Qt6::WebEngineQuick
)

include(GNUInstallDirs)
install(TARGETS appnicol
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES config.ini DESTINATION ${CMAKE_INSTALL_BINDIR})

# linux
if(UNIX AND NOT APPLE)
    install(FILES dev.arnv.nicol.desktop
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)

    install(FILES "assets/icons/logo.png"
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/1024x1024/apps
        RENAME "dev.arnv.nicol.png")

    install(FILES "assets/icons/logo.png"
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons
        RENAME "dev.arnv.nicol.png")
endif()

# windows and mac
if(WIN32 OR APPLE)
    qt_generate_deploy_qml_app_script(
        TARGET appnicol
        OUTPUT_SCRIPT deploy_script
    )
    install(SCRIPT ${deploy_script})
endif()

# cpack
set(CPACK_PACKAGE_NAME "NicolBrowser")
set(CPACK_PACKAGE_VENDOR "Arnav")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A minimal web browser")

if(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "Nicol Browser")
    set(CPACK_NSIS_PACKAGE_NAME "Nicol Browser")
    set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/assets/icons/logo.ico")
    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/assets/icons/logo.ico")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\appnicol.exe")
    set(CPACK_NSIS_EXECUTABLES_DIRECTORY "bin")
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
        "CreateShortCut '$SMPROGRAMS\\$STARTMENU_FOLDER\\Nicol Browser.lnk' '$INSTDIR\\bin\\appnicol.exe'")
    set(CPACK_NSIS_DELETE_ICONS_EXTRA
        "Delete '$SMPROGRAMS\\$START_MENU\\Nicol Browser.lnk'")
    set(CPACK_NSIS_MODIFY_PATH OFF)
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)

    set(APP_ICON_RESOURCE_WINDOWS "${CMAKE_CURRENT_BINARY_DIR}/appnicol_icon.rc")
    file(WRITE "${APP_ICON_RESOURCE_WINDOWS}" "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_SOURCE_DIR}/assets/icons/logo.ico\"\n")
    target_sources(appnicol PRIVATE "${APP_ICON_RESOURCE_WINDOWS}")
endif()

if(APPLE)
    set(CPACK_GENERATOR "DragNDrop")
    set(CPACK_DMG_VOLUME_NAME "Nicol")
    set(ICON_SOURCE "assets/icons/logo.icns")
    set_source_files_properties(${ICON_SOURCE} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    target_sources(appnicol PRIVATE ${ICON_SOURCE})
endif()

include(CPack)
