function ServerUrlUpdateScreen() as dynamic
    g_username(GetText("Username", "Enter your username", g_username()))
    g_password(GetText("Password", "Enter your password", g_password()))
    serverUrl = g_baseUrl()
    if serverUrl = invalid then
        serverUrl = "http://bronley.no-ip.biz:8080/PlumMediaCenter/"
    end if
    serverUrl = GetText("PlumMediaCenter Server URL", "Enter the url for the server running PlumMediaCenter.", serverUrl)
    'if the base url is missing the ending slash, add it
    endingCharacter = serverUrl.Right(1)
    print b_concat("ending character: ", endingCharacter)
    if endingCharacter <> "/" then
        serverUrl = b_concat(serverUrl, "/")
    end if
    'save the base url to the registry
    g_baseUrl(serverUrl)
    print "User said that the server url was ";serverUrl
    messageScreen = GetNewMessageScreen("", "Connecting to server")
    'see if the server exists at the url the user specified
    serverExists = API_ServerExists()
    messageScreen.close()
    'if the server exists, use this url
    if serverExists = true then
        print "Server exists. Setting the PlumMediaCenter Server url to=";serverUrl
        g_baseUrl(serverUrl)
        ShowMessage("Success", "Successfully connected to the PlumMediaCenter Server at the specified url.")
        return true
    else
        stillSave = Confirm("PlumMediaCenter Server does not exist at the provided url. Do you still want to use this url?","Yes","No")
        if stillSave = true then
            print "PlumMediaCenter Server does not exist at the provided url. Setting url anyway. url=";serverUrl
            g_baseUrl(serverUrl)
            return true
        else
            return ServerUrlUpdateScreen()
        end if
    end if
end function

function GetText(title as string, displayText as string, defaultText = "") as dynamic
    screen = CreateObject("roKeyboardScreen")
    defaultText = b_iff(defaultText <> invalid, defaultText, "")
    'set the default value of the keyboard screen
    screen.SetText(defaultText)
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetTitle(title)
    screen.SetDisplayText(displayText)
    screen.SetMaxLength(800)
    screen.AddButton(1, "Ok")
    screen.AddButton(2, "Cancel")
    screen.Show()
    while true
        msg = wait(0, screen.GetMessagePort())
        print "message received: ";msg
        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed() then
                return invalid
            else if msg.isButtonPressed() then
                if msg.GetIndex() = 1 then
                    return screen.GetText()
                end if
            end if
        end if
    end while
    return invalid
end function
