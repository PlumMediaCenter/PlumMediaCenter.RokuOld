
Function Main()
    'set the main theme of the application
    SetTheme()
    m.searchResults = []

    'add a default facade screen to the app so that the app will only close once this screen has been closed 
    screenFacade = CreateObject("roGridScreen")
    screenFacade.show()
    
    'make sure we have a url to the server
     CheckConfiguration()
         
    'make sure that the server specified in the configuration actually exists
    print "Verifying that the server exists."
    messageScreen = GetNewMessageScreen("", "Verifying that the server exists at the provided url...")
    serverExists = API_ServerExists() 
    If serverExists = False Then 
        confirmResult = Confirm("Unable to find PlumVideoPlayer server at the following url. Would you like to update the url? '" + BaseUrl() + "'", "Yes", "No")
        If ConfirmResult = True Then
            print "The user DOES want to fix the broken url. Prompting for that now.";
            GetBaseUrlFromUser()
        Else
            print "The user does NOT want to fix the broken url. Continue as if the server was working"
        End If
    End If
    messageScreen.close()
    
    'we know that the server exists....but now make sure that our version and the server's version are compatible
    messageScreen = GetNewMessageScreen("", "Verifying that the app is compatible with the current version of the server")
   
    messageScreen.close()
    if compareVersionWithServer() = false
        messageScreen.close()
        screenFacade.close()
        sleep(25)
        return true
    end if
    messageScreen.close()

    
    
    'Show the video grid
    ShowVideoGrid()
    'exit the app gently so that the screen doesn't flash to black
    screenFacade.Close()
    sleep(25)
End Function

Function ShowVideoGrid()
   MainGrid()
End Function

'''
' Compares the app version to the server version and determines if anything is out of sync. 
' @return {boolean} - true if the application could keep processing, false if it should exit
'''
function compareVersionWithServer()
    exitValue = false
    appVersion = APP_VERSION_NUMBER()
    appVersionParts = appVersion.Tokenize(".")
    appMajor = Val(appVersionParts[0])
    appMinor = Val(appVersionParts[1])
    
    serverVersion = API_GetServerVersionNumber()
    serverVersionParts = serverVersion.Tokenize(".")
    serverMajor = Val(serverVersionParts[0])
    serverMinor = Val(serverVersionParts[1])

    print concat("Comparing app version and server version: ", appVersion, " --- ", serverVersion)
    print concat(appMajor, " < ",serverMajor, " or ",appMinor ," < ",serverMinor)
    print concat( serverMajor, " < ",appMajor, " or ", serverMinor ," < ", appMinor)
    'if app is behind the server
    if appMajor < serverMajor or appMinor < serverMinor
        print "app is behind server"
        'app is behind the server
        result = Confirm("The server has a higher version than this app can handle. Please go to Settings > System Update to get the latest version of this app","Continue at my own risk","Exit")
        exitValue = result
    'if the server is behind the app
    else if serverMajor < appMajor or serverMinor <appMinor
        print "server is behind app"
        'server is behind the app
        result = ConfirmWithCancel("The server has a lower version than this app can handle. Would you like to have the server check for updates now (this may take several minutes)?","Yes, update the server now","Don't update the server but launch the app", "Don't update the server and exit the app")
        if result = 1
            updatingScreen = GetNewMessageScreen("", "Updating server")
            'get the current server version
            updateSuccess = API_UpdateServer()
            updatingScreen.close()
            'the server threw an error
            if updateSuccess = false 
                b_alert("There was an error updating the server")
                exitValue = false
            else
                updatedServerVersion = API_GetServerVersionNumber()
                'the server succeeded. see if it actually found any updates
                if serverVersion = updatedServerVersion
                    b_alert("The server found no updates to install")
                    exitValue = true
                else
                    'the server updated to a new version
                    b_alert(b_concat("Server was successfully updated from version ", serverVersion, " to version ", updatedServerVersion))
                    exitValue = true
               end if
            end if
        else if result = 0
            exitValue = true
        else if result = -1
           exitValue = false
        end if
    'the app and the server are within the same major/minor versions of each other. everything is ok
    else
        print "app and server are at the same major-minor version"
        exitValue = true
    end if
    return exitValue
end function

'
' Checks that all of the roku configuration 
'
Sub CheckConfiguration()
    print "Checking configuration settings"
    bUrl = BaseUrl()
    If bUrl = invalid Then
        print "PlumVideoPlayer api url is not set. Prompting user to enter url."
        ShowMessage("Setup", "This app must be configured before it can be used. Please follow the instructions")
        print "User clicked ok on the initial setup screen"
        GetBaseUrlFromUser()
    Else 
        print "Base URL is set.";bUrl
    End If
End Sub

Sub PlayFirstMovie()
    PlayVideo(m.lib.movies[0])
End Sub


Function PlayFirstEpisode()
    show = m.lib.tvShows[0]
     episode = invalid
     For Each season in show.seasons
        For Each ep in season
            Return PlayVideo(ep)
        End For
     End For
     PlayVideo(episode)
End Function

'
' Loads the library from the server into the m.library global variable
'
Sub LoadLibrary()
    'retrieve the library from the server
    lib = API_GetLibrary()
    m.lib = lib
End Sub


Sub PlayVideo(pVideo as Object)
    
    'if this video is a tv show, then find the next episode to watch
    if pVideo.mediaType = "TvShow"
        messageScreen = GetNewMessageScreen("", "Loading next episode to watch...")
        episode = API_GetNextEpisode(pVideo.videoId)
        'hide the message screen
        messageScreen.Close()
        PlayVideo(episode)
        return
    end if
    
    messageScreen = GetNewMessageScreen("", "Preparing video for playback...")
    
    print pVideo
    startSeconds = API_GetVideoProgress(pVideo.videoId)
    print "Start Seconds";startSeconds
    resume = true
    If startSeconds > 0 Then
        hmsString = GetHourMinuteSecondString(startSeconds)
        'for debugging purposes, skip the confirm window for now
        result = ConfirmWithCancel("Resume where you left off?(" + hmsString + ")", "Resume", "Restart")
        print "Confirm Result: ";result
        If result = 2 Then
            print "PlayVideo: resuming playback at ";startSeconds;" seconds"
            resume = true
        Else If result = 1 Then
            print "PlayVideo: restarting video from beginning"
            resume = false
        Else
            print "PlayVideo: cancel video playback"
            return 
        End If
    End If
    If resume Then
        startMilliseconds = startSeconds * 1000
        'print "PlayVideo: resuming playback at ";startSeconds;" seconds"
    Else
        'print "Restart playback"
        startMilliseconds = -1
    End If
    video  = CreateObject("roAssociativeArray")
    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen") 
    ' Note: HDBranded controls whether the "HD" logo is displayed for a 
    '       title. This is separate from IsHD because its possible to
    ' have an HD title where you don't want to show the HD logo 
    ' branding for the title. Set these two as appropriate for 
    ' your content
    video.IsHD = true    
    video.HDBranded = false

    ' Note: The preferred way to specify stream info in v2.6 is to use
    ' the Stream roAssociativeArray content meta data parameter. 
    print "Play Video...Url:";pVideo.url
    video.Stream = { 
        url: pVideo.url
        bitrate:0
        StreamFormat:  "mp4"
    }
    
   ' now just tell the screen about the title to be played, set the 
   ' message port for where you will receive events and call show to 
   ' begin playback.  You should see a buffering screen and then 
   ' playback will start immediately when we have enough data buffered. 
    screen.SetContent(video)
    screen.SetMessagePort(port)
    'every n seconds, fire a position notification
    screen.SetPositionNotificationPeriod(3)
    screen.Show() 
    'hide the message screen
    messageScreen.Close()
    
    m.lastVideoProgressUpdateTime = CreateObject("roDateTime")
   ' Wait in a loop on the message port for events to be received.  
   ' We will just quit the loop and Return to the calling function 
   ' when the users terminates playback, but there are other things 
   ' you could do here like monitor playback position and see events 
   ' from the streaming player.  Look for status messages from the video 
   ' player for status and failure events that occur during playback 
    while true
       msg = wait(0, port)
        
       if type(msg) = "roVideoScreenEvent" then
           if msg.isStreamStarted() and startMilliseconds > 0
                print "Stream started. Seeking to milliseconds: "; startMilliseconds 
                screen.Seek(startMilliseconds)
                startMilliseconds = -1
          Else if msg.isScreenClosed()
               print "Screen closed"
               exit while
            Else If msg.isStatusMessage()
                  print "status message: "; msg.GetMessage()
            Else If msg.isPlaybackPosition()
                seconds = msg.GetIndex()
                'print "PlayVideo: playback position: ";seconds; " seconds"
                API_SetVideoProgress(pVideo.videoId, seconds)
            Else If msg.isFullResult()
                  print "playback completed"
                  API_SetVideoCompleted(pVideo.videoId)
                  exit while
            Else If msg.isPartialResult()
                  print "playback interrupted"
                  exit while
            Else If msg.isRequestFailed()
                  print "request failed – error: "; msg.GetIndex();" – "; msg.GetMessage()
                  ShowMessage("Error", "There was a problem playing the video. It probably isn't in the proper format. Here is the error message: " + msg.GetMessage())
                  exit while
            End If
       End If
    End While 
End Sub
