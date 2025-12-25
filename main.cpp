#include <QBuffer>
#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QIODevice>
#include <QMimeDatabase>
#include <QQmlApplicationEngine>
#include <QRegularExpression>
#include <QSettings>
#include <QWebEngineClientHints>
#include <QWebEngineProfile>
#include <QWebEngineSettings>
#include <QWebEngineUrlRequestJob>
#include <QWebEngineUrlScheme>
#include <QWebEngineUrlSchemeHandler>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include <qdebug.h>
#include <qlogging.h>
#include <qstringview.h>
#include <qurl.h>
#include <qwebenginesettings.h>

class NicolSchemeHandler : public QWebEngineUrlSchemeHandler {
public:
  NicolSchemeHandler(QObject *parent = nullptr)
      : QWebEngineUrlSchemeHandler(parent) {}
  void requestStarted(QWebEngineUrlRequestJob *job) {

    QUrl url = job->requestUrl();
    const QByteArray method = job->requestMethod();

    if (url.isEmpty() || !url.isValid()) {
      job->fail(QWebEngineUrlRequestJob::UrlInvalid);
      return;
    }

    if (method != QByteArrayLiteral("GET"))
      job->fail(QWebEngineUrlRequestJob::RequestDenied);

    if (url.scheme() != QLatin1String("nicol")) {
      job->fail(QWebEngineUrlRequestJob::UrlInvalid);
      return;
    }

    QString host = url.host();
    QString path = url.path();

    if (path.isEmpty()) {
      path = "/";
    }

    if (path.endsWith('/')) {
      path += "index.html";
    }

    // qDebug() << "[internal url req] host:" << host << " Path:" << path;

    QString resourcePath = QStringLiteral(":/qt/qml/nicol/chrome");

    if (!host.isEmpty()) {
      resourcePath += "/" + host + path;
    } else {
      resourcePath += path;
    }

    resourcePath.replace("//", "/");

    // qDebug() << "[internal url req] returning:" << resourcePath;

    QFile file(resourcePath);

    if (!file.open(QIODevice::ReadOnly)) {
      job->fail(QWebEngineUrlRequestJob::UrlNotFound);
      return;
    }

    auto data = file.readAll();
    auto *buffer = new QBuffer(job);
    buffer->setData(data);
    buffer->open(QIODevice::ReadOnly);
    const auto mimeType =
        QMimeDatabase().mimeTypeForFileNameAndData(path, data).name().toUtf8();

    job->reply(mimeType.isEmpty() ? "application/octet-stream" : mimeType,
               buffer);
  }
};

int main(int argc, char *argv[]) {
  QSettings settings("config.ini", QSettings::IniFormat);
  QString version = settings.value("browser/version", "1.0.0").toString();

  QWebEngineUrlScheme scheme("nicol");
  scheme.setSyntax(QWebEngineUrlScheme::Syntax::Path);
  scheme.setFlags(QWebEngineUrlScheme::SecureScheme |
                  QWebEngineUrlScheme::CorsEnabled |
                  QWebEngineUrlScheme::LocalAccessAllowed);
  QWebEngineUrlScheme::registerScheme(scheme);

  QtWebEngineQuick::initialize();
  QGuiApplication app(argc, argv);
  auto profile = QWebEngineProfile::defaultProfile();

  NicolSchemeHandler *handler = new NicolSchemeHandler(&app);
  profile->installUrlSchemeHandler("nicol", handler);

  QString UA = profile->httpUserAgent();
  QRegularExpression re("QtWebEngine/\\d+\\.\\d+\\.\\d+");
  QString nicolUA = UA.replace(re, "");
  nicolUA = nicolUA.simplified() + " Nicol/" + version;
  profile->setHttpUserAgent(nicolUA);

  profile->setPersistentCookiesPolicy(
      QWebEngineProfile::AllowPersistentCookies);
  profile->setPersistentStoragePath(qApp->applicationDirPath() + "/userdata");

  profile->settings()->setAttribute(QWebEngineSettings::ScrollAnimatorEnabled,
                                    true);
  profile->settings()->setAttribute(
      QWebEngineSettings::FullScreenSupportEnabled, true);
  profile->settings()->setAttribute(
      QWebEngineSettings::Accelerated2dCanvasEnabled, true);
  profile->settings()->setAttribute(QWebEngineSettings::WebGLEnabled, true);
  profile->settings()->setAttribute(QWebEngineSettings::PluginsEnabled, true);
  profile->settings()->setAttribute(QWebEngineSettings::PdfViewerEnabled, true);
  profile->settings()->setAttribute(
      QWebEngineSettings::FullScreenSupportEnabled, true);

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("nicol", "Main");
  return app.exec();
}
