#include "NemAPI.hpp"

#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QtNetwork/QtNetwork>
#include <QtCore/QtCore>

const QString PROTOCOL 				= "http://";
const QString API_ENDPOINT 			= "kellyescape.com/nemsms/includes/webservices/";
const QString CONTENT_TYPE 			= "application/x-www-form-urlencoded";

Snap2ChatAPISimple::Snap2ChatAPISimple(QObject* parent)
    : QObject(parent)
{

}

void Snap2ChatAPISimple::request(QVariant params)
{
	QUrl dataToSend;

	QVariantMap paramsMap = params.toMap();

	const QString endpoint		= paramsMap.value("endpoint").toString();

	if(endpoint == "listen")
	{
		dataToSend.addQueryItem("userid", paramsMap.value("userid").toString());
	}
	else if(endpoint == "login" || endpoint == "register")
	{
		dataToSend.addQueryItem("username", paramsMap.value("username").toString());
		dataToSend.addQueryItem("password", paramsMap.value("password").toString());
	}

	QNetworkRequest request;
	request.setUrl(QUrl(PROTOCOL + API_ENDPOINT + endpoint + ".php"));
	request.setHeader(QNetworkRequest::ContentTypeHeader, CONTENT_TYPE);

	QNetworkReply* reply = m_manager.post(request, dataToSend.encodedQuery());
	reply->setProperty("endpoint", endpoint);
	connect (reply, SIGNAL(finished()), this, SLOT(onComplete()));
}

void Snap2ChatAPISimple::onComplete()
{
	QNetworkReply* reply 	= qobject_cast<QNetworkReply*>(sender());
	int status 				= reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
	QString reason 			= reply->attribute( QNetworkRequest::HttpReasonPhraseAttribute ).toString();

	QString response;

	if (reply)
	{
		if (reply->error() == QNetworkReply::NoError)
		{
			const int available = reply->bytesAvailable();

			if (available > 0)
			{
				const QByteArray buffer(reply->readAll());
				response = QString::fromUtf8(buffer);
			}
		}
		else
		{
			response = "error";
		}

		reply->deleteLater();
	}

	if (response.trimmed().isEmpty())
	{
		response = "error";
	}

	if(QString::number(status) == "200")
	{
		response = ((response.length() > 0 && response != "error") ? response : QString::number(status));
	}
	else
	{
		response = QString::number(status);
	}

	emit complete(response, QString::number(status), reply->property("endpoint").toString());
}
