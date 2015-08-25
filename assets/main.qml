import bb.cascades 1.2
import QtQuick 1.0
import bb.system 1.0
import nemory.NemAPI 1.0

import "nemory/components/"
import "sheets/"

Page 
{
    property int userid;
    
    titleBar: CustomTitleBar 
    {
        textLogoVisibility: false
        imageLogoVisibility: true
        titleImageLogo: "asset:///images/titleIcon.png"
        titleBarBackgroundColor: Color.create("#a65ca4")
    }
    
    onCreationCompleted: 
    {
    	loginRegisterSheet.open();    
    }
    
    Container 
    {
        leftPadding: 40
        rightPadding: 40
        topPadding: 40
        bottomPadding: 40
        
        layout: DockLayout {}
        
        Container 
        {
            id: stackContainer
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill  
                
                layout: DockLayout {}
                
                Label
                {
                    text: "Nem Engine"
                    textStyle.fontWeight: FontWeight.W100
                }
                
                ToggleButton 
                {
                    id: nemEngine
                    checked: true
                    horizontalAlignment: HorizontalAlignment.Right
                    onCheckedChanged:
                    {
                        if(checked)
                        {
                            timerListener.stop();
                            timerListener.start();
                            loadingImage.play();
                        }
                        else 
                        {
                            timerListener.stop();
                            loadingImage.stop();
                        }
                    }
                }
            }
            
            Divider {}
            
            Container
            {
                id: loadingContainer
                visible: timerListener.running || loadingImage.visible
                
                onVisibleChanged: 
                {
                    if(visible)
                    {
                        loadingImage.play();
                    }
                    else
                    {
                        loadingImage.stop();
                    }
                }
                
                ImageView
                {
                    id: loadingImage
                    visible: false
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    imageSource: "asset:///images/loading.png"
                    preferredHeight: 200
                    minHeight: preferredHeight
                    minWidth: preferredHeight
                    scalingMethod: ScalingMethod.AspectFit
                    
                    animations: 
                    [
                        FadeTransition 
                        {
                            id: fadeAnimation
                            duration: 1000
                            repeatCount: 99999999
                            toOpacity: 1.0
                            fromOpacity: 0.3
                            easingCurve: StockCurve.Linear
                            
                            onStopped: 
                            {
                                loadingImage.resetOpacity();
                            }
                        },
                        ScaleTransition 
                        {
                            id: scaleAnimation
                            duration: 1000
                            repeatCount: 99999999
                            toX: 1.0
                            toY: 1.0
                            fromX: 0.7
                            fromY: 0.7
                            easingCurve: StockCurve.BounceInOut
                            
                            onStopped: 
                            {
                                loadingImage.resetScale();
                            }
                        }
                    ]
                    
                    function play()
                    {
                        loadingImage.visible = true;
                        fadeAnimation.play();
                        scaleAnimation.play();
                    }
                    
                    function stop()
                    {
                        loadingImage.visible = false;
                        fadeAnimation.stop();
                        scaleAnimation.stop();
                    }
                }
                
                Label 
                {
                    id: loadingStatusText
                    text: "Listening for incoming messages..."
                    textStyle.fontWeight: FontWeight.W100
                    textStyle.color: Color.DarkCyan
                    textStyle.fontSize: FontSize.XSmall
                    textStyle.fontStyle: FontStyle.Italic
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                Divider {}
            }
            
            Header 
            {
                title: "Latest Message"
            }
            
            Label 
            {
                text: "Recipient:" 
                textStyle.fontSize: FontSize.XLarge
                textStyle.fontWeight: FontWeight.W100    
            }
            
            Label 
            {
                id: toPhoneNumber
            	textStyle.color: Color.DarkGray
                textStyle.fontWeight: FontWeight.W100
            }
            
            Divider {}
            
            Label 
            {
                text: "Message:" 
                textStyle.fontSize: FontSize.XLarge
                textStyle.fontWeight: FontWeight.W100    
            }
            
            Label
            {
                id: message
                multiline: true
                textStyle.color: Color.DarkGray
                textStyle.fontWeight: FontWeight.W100
            }
        }
    }
    
    attachedObjects: 
    [
        Timer
        {
            id: timerListener
            interval: 1000
            repeat: true
            onTriggered: 
            {
            	listenForIncomingMessages();	   
            }
        },
        Invocation 
        {
            id: invokeShare
            query.mimeType: "text/plain"
            query.invokeActionId: "bb.action.SHARE"
            query.invokerIncluded: true
            query.data: "Send and Receive SMS from your PC to your Phone with #NemSMS. #TeamBlackBerry"
        },
        SystemDialog
        {
        	id: dialog    
        },
        SystemToast
        {
            id: toast    
        },
        LoginRegister
        {
            id: loginRegisterSheet
            onSuccess: 
            {
                userid = loggeduserid;
                loadingImage.play();
                timerListener.start();
                
                nemEngine.enabled = true;
            }
        },
        NemAPI
        {
            id: nemAPI
            onComplete: 
            {
                console.log(response);
                
                if(endpoint == "listen")
                {
                    if(response != "No messages in queue.")
                    {
                        var responseJSON 	= JSON.parse(response);
                        toPhoneNumber.text 	= responseJSON.phonenumber;
                        message.text 		= responseJSON.message;
                        
                        _app.sendSMS(responseJSON.phonenumber, responseJSON.message);
                    }
                }
            }
        }
    ]
    
    function listenForIncomingMessages()
    {
        var params 		= new Object();
        params.userid	= userid;
        params.endpoint	= "listen";
        nemAPI.request(params);
    }
    
    Menu.definition: MenuDefinition 
    {
        actions: 
        [
            ActionItem 
            {
                title: "About"
                imageSource: "asset:///images/titleInfo.png"
                onTriggered: 
                {
                    dialog.title 	= "About NemSMS";
                    dialog.body		= "Send and Receive SMS from your PC to your Phone with NemSMS. Created by Nemory Development Studios.";
                    dialog.show();
                }
            },
            ActionItem 
            {
                title: "Share"
                imageSource: "asset:///images/tabShare.png"
                onTriggered:
                {
                    invokeShare.trigger("bb.action.SHARE");
                }
            },
            ActionItem  
            {
                title: "Contact"
                imageSource: "asset:///images/menuEmail.png"
                onTriggered: 
                {
                    _app.invokeEmail("nemoryoliver@gmail.com", "Support : NemSMS ", "")
                }
            },
            ActionItem 
            {
                title: "Rate"
                imageSource: "asset:///images/rate.png"
                enabled: true
                onTriggered:
                {
                    _app.invokeBBWorld("appworld://content/");
                }
            },
            ActionItem 
            {
                title: "Logout"
                imageSource: "asset:///images/ic_cancel.png"
                enabled: true
                onTriggered:
                {
                    userid = 0;
                    timerListener.stop();
                    loadingImage.stop();
                    loginRegisterSheet.open();
                }
            }
        ]
    }
}
