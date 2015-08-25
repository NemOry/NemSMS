#include "applicationui.hpp"
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <QList>
#include <bb/PackageInfo>

#include <bb/data/JsonDataAccess>
#include <bb/data/DataAccessError>

#include <bb/system/InvokeRequest>
#include <bb/cascades/Invocation>
#include <bb/pim/message/SmsTransport>
#include <bb/pim/message/SmsTransportRegistrationResult>

#include <bb/pim/account/AccountService>
#include <bb/pim/account/Account>
#include <bb/pim/account/Provider>
#include <bb/pim/message/MessageSearchFilter>
#include <bb/pim/message/MessageService>
#include <bb/pim/message/MessageBuilder>
#include <bb/pim/message/ConversationBuilder>
#include <bb/pim/message/Attachment>
#include <bb/PpsObject>
#include <bb/device/DeviceInfo>
#include <bb/cascades/SceneCover>

using namespace bb::pim::account;
using namespace bb::pim::message;
using namespace bb::cascades;
using namespace bb::device;
using namespace bb::system;

using bb::data::JsonDataAccess;
using bb::data::DataAccessError;
using bb::data::DataAccessErrorType;
using bb::PpsObject;
using bb::PackageInfo;

using namespace bb::cascades;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
        QObject(app)
{
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);
    Q_UNUSED(res);
    onSystemLanguageChanged();

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("_app", this);
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    app->setScene(root);
}

void ApplicationUI::sendSMS(QString recipientNumber, QString messageText)
{
	QStringList phoneNumbers;
	phoneNumbers << recipientNumber;

	bb::pim::account::AccountService accountService;
	bb::pim::message::MessageService messageService;

	QList<Account> accountListy = accountService.accounts(bb::pim::account::Service::Messages,"sms-mms");

	bb::pim::account::AccountKey smsAccountId = 0;

	if(!accountListy.isEmpty())
	{
		smsAccountId = accountListy.first().id();
		qDebug() << "SMS-MMS account ID:" << smsAccountId;
	}
	else
	{
		//showToast("Could not find SMS account");
		return;
	}

	QList<bb::pim::message::MessageContact> participants;

	foreach(const QString &phoneNumber, phoneNumbers)
	{
		bb::pim::message::MessageContact recipient = bb::pim::message::MessageContact(
			-1, bb::pim::message::MessageContact::To,
			phoneNumber, phoneNumber);
		participants.append(recipient);
	}

	bb::pim::message::ConversationBuilder *conversationBuilder = bb::pim::message::ConversationBuilder::create();
	conversationBuilder->accountId(smsAccountId);
	conversationBuilder->participants(participants);

	bb::pim::message::Conversation conversation = *conversationBuilder;
	bb::pim::message::ConversationKey conversationId = messageService.save(smsAccountId, conversation);

	bb::pim::message::MessageBuilder *builder = bb::pim::message::MessageBuilder::create(smsAccountId);
	builder->conversationId(conversationId);

	QByteArray bodyData = messageText.toUtf8();

	builder->body(MessageBody::PlainText, bodyData);

	foreach(const bb::pim::message::MessageContact recipient, participants)
	{
		builder->addRecipient(recipient);
	}

	bb::pim::message::Message message = *builder;

	messageService.send(smsAccountId, message);

	delete builder;
	delete conversationBuilder;

	//showToast("SMS Sent Successfully");
}

void ApplicationUI::invokeEmail(QString email, QString subject, QString body)
{
	InvokeRequest request;
	request.setTarget("sys.pim.uib.email.hybridcomposer");
	request.setAction("bb.action.SENDEMAIL");
	request.setUri(
			"mailto:" + email + "?subject=" + subject.replace(" ", "%20")
					+ "&body=" + body.replace(" ", "%20"));
	invokeManager->invoke(request);
}

void ApplicationUI::invokeBBWorld(QString appurl)
{
	InvokeRequest request;
	request.setMimeType("application/x-bb-appworld");
	request.setAction("bb.action.OPEN");
	request.setUri(appurl);
	invokeManager->invoke(request);
}

void ApplicationUI::invokeBrowser(QString url)
{
	InvokeRequest request;
	request.setTarget("sys.browser");
	request.setAction("bb.action.OPEN");
	request.setUri(url);
	invokeManager->invoke(request);
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    QString locale_string = QLocale().name();
    QString file_name = QString("NemSMS_%1").arg(locale_string);

    if (m_pTranslator->load(file_name, "app/native/qm"))
    {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}
