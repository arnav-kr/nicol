#include <QBuffer>
#include <QDebug>
#include <QFile>
#include <QGuiApplication>
#include <QIODevice>
#include <QMimeDatabase>
#include <QQmlApplicationEngine>
#include <QWebEngineProfile>
#include <QWebEngineUrlRequestJob>
#include <QWebEngineUrlScheme>
#include <QWebEngineUrlSchemeHandler>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include <qdebug.h>
#include <qlogging.h>
#include <qstringview.h>
#include <qurl.h>

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

    qDebug() << "[internal url req] host:" << host << " Path:" << path;

    QString resourcePath = QStringLiteral(":/qt/qml/nicol/chrome");

    if (!host.isEmpty()) {
      resourcePath += "/" + host + path;
    } else {
      resourcePath += path;
    }

    resourcePath.replace("//", "/");

    qDebug() << "[internal url req] returning:" << resourcePath;

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
  QWebEngineUrlScheme scheme("nicol");
  scheme.setSyntax(QWebEngineUrlScheme::Syntax::Path);
  scheme.setFlags(QWebEngineUrlScheme::SecureScheme |
                  QWebEngineUrlScheme::CorsEnabled |
                  QWebEngineUrlScheme::LocalAccessAllowed);
  QWebEngineUrlScheme::registerScheme(scheme);

  QtWebEngineQuick::initialize();
  QGuiApplication app(argc, argv);

  NicolSchemeHandler *handler = new NicolSchemeHandler(&app);
  QWebEngineProfile::defaultProfile()->installUrlSchemeHandler("nicol",
                                                               handler);

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("nicol", "Main");
  return app.exec();
}
