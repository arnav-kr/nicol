#include <QBuffer>
#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QIODevice>
#include <QMimeDatabase>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QRegularExpression>
#include <QSettings>
#include <QWebEngineUrlRequestJob>
#include <QWebEngineUrlScheme>
#include <QWebEngineUrlSchemeHandler>
#include <QtWebEngineQuick/QQuickWebEngineProfile>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include <qdebug.h>
#include <qlogging.h>
#include <qstringview.h>
#include <qurl.h>

class NicolSchemeHandler : public QWebEngineUrlSchemeHandler {
  Q_OBJECT
public:
  NicolSchemeHandler(QObject *parent = nullptr)
      : QWebEngineUrlSchemeHandler(parent) {}
  void requestStarted(QWebEngineUrlRequestJob *job) override {
    QUrl url = job->requestUrl();
    if (url.scheme() != "nicol" || job->requestMethod() != "GET") {
      job->fail(QWebEngineUrlRequestJob::UrlInvalid);
      return;
    }
    QString path = url.path();
    if (path.isEmpty() || path == "/")
      path = "/index.html";
    else if (path.endsWith('/'))
      path += "index.html";

    QString host = url.host();
    QString resourcePath = ":/qt/qml/nicol/chrome";
    if (!host.isEmpty())
      resourcePath += "/" + host + path;
    else
      resourcePath += path;

    resourcePath.replace("//", "/");
    QFile file(resourcePath);
    if (!file.open(QIODevice::ReadOnly)) {
      job->fail(QWebEngineUrlRequestJob::UrlNotFound);
      return;
    }
    auto data = file.readAll();
    auto *buffer = new QBuffer(job);
    buffer->setData(data);
    buffer->open(QIODevice::ReadOnly);
    QString mime =
        QMimeDatabase().mimeTypeForFileNameAndData(path, data).name();
    job->reply(mime.toUtf8(), buffer);
  }
};

class ProfileHelper : public QObject {
  Q_OBJECT
public:
  explicit ProfileHelper(QObject *parent = nullptr) : QObject(parent) {}

  Q_INVOKABLE void setupProfile(QQuickWebEngineProfile *profile) {
    if (!profile) {
      qWarning() << "setupProfile called with NULL profile!";
      return;
    }

    if (!profile->urlSchemeHandler("nicol")) {
      auto handler = new NicolSchemeHandler(profile);
      profile->installUrlSchemeHandler("nicol", handler);
    }

    QSettings settings("config.ini", QSettings::IniFormat);
    QString version = settings.value("browser/version", "1.0.0").toString();

    QString UA = profile->httpUserAgent();
    QRegularExpression re("QtWebEngine/\\d+\\.\\d+\\.\\d+");
    QString nicolUA = UA.replace(re, "");
    nicolUA = nicolUA.simplified() + " Nicol/" + version;
    profile->setHttpUserAgent(nicolUA);

    if (!profile->isOffTheRecord()) {
      profile->setPersistentCookiesPolicy(
          QQuickWebEngineProfile::AllowPersistentCookies);
      qDebug() << "configured persistent profile:" << profile->storageName();
    } else {
      qDebug() << "configured incognito profile";
    }
  }
};

#include "main.moc"

int main(int argc, char *argv[]) {
  QWebEngineUrlScheme scheme("nicol");
  scheme.setSyntax(QWebEngineUrlScheme::Syntax::Path);
  scheme.setFlags(QWebEngineUrlScheme::SecureScheme |
                  QWebEngineUrlScheme::CorsEnabled |
                  QWebEngineUrlScheme::LocalAccessAllowed);
  QWebEngineUrlScheme::registerScheme(scheme);

  QtWebEngineQuick::initialize();
  QGuiApplication app(argc, argv);

  ProfileHelper helper;

  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("profileHelper", &helper);

  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

  engine.loadFromModule("nicol", "Main");
  return app.exec();
}