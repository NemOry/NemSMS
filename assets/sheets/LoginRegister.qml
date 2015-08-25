import bb.cascades 1.0
import QtQuick 1.0
import bb.system 1.0

import "../nemory/components/"
import nemory.NemAPI 1.0

Sheet 
{
    id: sheet
    peekEnabled: false
    
    signal success(string loggeduserid);

	attachedObjects: 
	[
        NemAPI
        {
            id: nemAPI
            onComplete: 
            {
                btnLogin.enabled 		= true;
                btnRegister.enabled 	= true;
                loadingImage.stop();
                
                console.log(response);
                
                var responseJSON 	= JSON.parse(response);
                
                if(endpoint == "login")
                {
                    if(responseJSON.status == "okay")
                    {
                        var responseJSON 	= JSON.parse(response);
                        
                        success(responseJSON.message.id)

                        toast.body = "Logged in. :)";
                        toast.show();
                        
                        sheet.close();
                    }
                    else 
                    {
                        toast.body = responseJSON.message;
                        toast.show();
                    }
                }
                else if(endpoint == "register") 
                {
                    if(responseJSON.status == "okay")
                    {
                        success(responseJSON.message.id)
                        
                        toast.body = "Registered and Logged in. :)";
                        toast.show();
                        
                        sheet.close();
                    }
                    else 
                    {
                        toast.body = responseJSON.message;
                        toast.show();
                    }
                }
            }
        },
        SystemToast 
        {
            id: toast
        }
	]

    Page 
    {
        titleBar: CustomTitleBar 
        {
            textLogoVisibility: false
            imageLogoVisibility: true
            titleImageLogo: "asset:///images/titleIcon.png"
            titleBarBackgroundColor: Color.create("#a65ca4")
        }
        
        Container 
        {
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ScrollView 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    id: mainContainer
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    
                    leftPadding: 50
                    rightPadding: 50
                    
                    Container 
                    {
                        id: contentContainer
                        bottomPadding: 50
                        
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
                            text: "NemSMS"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                        }
                        
                        Label 
                        {
                            text: "Future version of NemSMS should let you also read SMS from your phone. Send replies directly, view contacts, send sms to contacts + more. Please let me know in the forums if you think this is one AWESOME APP that must be inside BlackBerry World. :)"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXSmall
                            multiline: true
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Username"
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: username
                            hintText: "enter username"
                        }
                        
                        Label 
                        {
                            text: "Password"
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: password
                            hintText: "enter password"
                            inputMode: TextFieldInputMode.Password
                        }
                        
                        Container 
                        {
                            layout: StackLayout 
                            {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            Button 
                            {
                                id: btnLogin
                                horizontalAlignment: HorizontalAlignment.Fill
                                text: "Login"
                                onClicked: 
                                {
                                    if(username.text.length > 0 && password.text.length > 0)
                                    {
                                        btnLogin.enabled = false;
                                        btnRegister.enabled = false;
                                        loadingImage.play();
                                        
                                        var params 		= new Object();
                                        params.username	= username.text;
                                        params.password	= password.text;
                                        params.endpoint	= "login";
                                        nemAPI.request(params);
                                    }
                                    else
                                    {
                                        toast.body = "Please enter a username and a password.";
                                        toast.show();
                                    }
                                }
                            }
                            
                            Button 
                            {
                                id: btnRegister
                                horizontalAlignment: HorizontalAlignment.Fill
                                text: "Register"
                                onClicked: 
                                {
                                    if(username.text.length >= 5 && password.text.length >= 5)
                                    {
                                        btnLogin.enabled = false;
                                        btnRegister.enabled = false;
                                        loadingImage.play();
                                        
                                        var params 		= new Object();
                                        params.username	= username.text;
                                        params.password	= password.text;
                                        params.endpoint	= "register";
                                        nemAPI.request(params);
                                    }
                                    else
                                    {
                                        toast.body = "Username and Password must be atleast 5 characters.";
                                        toast.show();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


