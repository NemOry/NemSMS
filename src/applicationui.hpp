#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/system/InvokeManager>

namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
    }
}

class QTranslator;

class ApplicationUI : public QObject
{
    Q_OBJECT

public:

    ApplicationUI(bb::cascades::Application *app);
    virtual ~ApplicationUI() { }

    Q_INVOKABLE void sendSMS(QString recipientNumber, QString message);
    Q_INVOKABLE void invokeBBWorld(QString appurl);
	Q_INVOKABLE void invokeBrowser(QString url);
	Q_INVOKABLE void invokeEmail(QString email, QString subject, QString body);

private slots:

    void onSystemLanguageChanged();

private:

    bb::system::InvokeManager* invokeManager;
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;

};

#endif /* ApplicationUI_HPP_ */
