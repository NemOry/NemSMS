#ifndef NEMAPI_H_
#define NEMAPI_H_

#include <QtCore/QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtCore/QVariant>
#include <QtCore/QFile>

class Snap2ChatAPISimple : public QObject
{
    Q_OBJECT

public:
    Snap2ChatAPISimple(QObject* parent = 0);

    Q_INVOKABLE void request(QVariant params);

Q_SIGNALS:

    void complete(QString response, QString httpcode, QString endpoint);

private Q_SLOTS:

	void onComplete();

private :

    QNetworkAccessManager m_manager;
};

#endif /* SNAP2CHATAPI_H_ */
