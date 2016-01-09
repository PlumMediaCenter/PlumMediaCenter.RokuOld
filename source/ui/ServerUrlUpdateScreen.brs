Function ServerUrlUpdateScreen() as dynamic
    print "Setting up Base URL Promt Screen";
    screen = CreateObject("roKeyboardScreen")
    'get the serverUrl from the registry
    serverUrl = g_baseUrl()

    If serverUrl = invalid Then
        serverUrl = "http://192.168.1.9/PlumMediaCenter/"
    End If
    'set the default value of the keyboard screen
    screen.SetText(serverUrl)
    port = CreateObject("roMessagePort") 
    screen.SetMessagePort(port)
    screen.SetTitle("PlumMediaCenter Server URL")
    screen.SetDisplayText("Enter the url for the server running PlumMediaCenter.")
    screen.SetMaxLength(800)
    screen.AddButton(1, "Ok")
    screen.AddButton(2, "Cancel")
    screen.Show() 
    print "Prompting user for Base Url"
     while true
         msg = wait(0, screen.GetMessagePort()) 
         print "message received: ";msg
         If type(msg) = "roKeyboardScreenEvent"
             If msg.isScreenClosed()
                 Return invalid
             Else If msg.isButtonPressed() then
                 If msg.GetIndex() = 1
                    sBaseUrl = screen.GetText()
                    'if the base url is missing the ending slash, add it
                    endingCharacter = sBaseUrl.Right(1)
                    print b_concat("ending character: ", endingCharacter)
                    if endingCharacter <> "/"
                        sBaseUrl = b_concat(sBaseUrl, "/")
                    end if
                    'save the base url to the registry
                    g_baseUrl(sBaseUrl)
                    print "User said that the server url was ";sBaseUrl
                    messageScreen = GetNewMessageScreen("", "Connecting to server")
                    'see if the server exists at the url the user specified
                    serverExists = API_ServerExists()
                    messageScreen.close()
                    'if the server exists, use this url
                    If serverExists = true Then
                        print "Server exists. Setting the PlumMediaCenter Server url to=";sBaseUrl
                        g_baseUrl(sBaseUrl)
                        ShowMessage("Success", "Successfully connected to the PlumMediaCenter Server at the specified url.")
                        Return true
                    Else
                        stillSave = Confirm("PlumMediaCenter Server does not exist at the provided url. Do you still want to use this url?","Yes","No")
                        If stillSave = true Then
                            print "PlumMediaCenter Server does not exist at the provided url. Setting url anyway. url=";sBaseUrl
                            g_baseUrl(sBaseUrl)
                            Return true
                        Else
                            return ServerUrlUpdateScreen()
                        End If
                    End If
                Else
                    print "User cancled entering the PlumMediaCenter Server url"
                    Return false 
                 End If
             End If
         End If
     End While 
     Return invalid
End Function
