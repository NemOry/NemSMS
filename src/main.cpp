#include <bb/cascades/Application>
#include <QLocale>
#include <QTranslator>
#include "applicationui.hpp"
#include "NemAPI.hpp"
#include <Qt/qdeclarativedebug.h>

using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
	qmlRegisterType<Snap2ChatAPISimple>("nemory.NemAPI", 1, 0, "NemAPI");

    Application app(argc, argv);
    new ApplicationUI(&app);
    return Application::exec();
}
