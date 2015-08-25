APP_NAME = NemSMS

CONFIG += qt warn_on cascades10

QT 			+= network
QT 			+= declarative
CONFIG 		+= qt warn_on debug_and_release cascades mobility

LIBS += -lbb
LIBS += -lbbdata
LIBS += -lbbsystem
LIBS += -lbbdevice
LIBS += -lbbpim

include(config.pri)
