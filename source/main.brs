function beforeEverything()
    'VideoInfoScreen(4688)
    '    g_baseUrl("http://192.168.1.26:8080/PlumMediaCenter/")
    '    video = API_GetVideo(4712)
    '    completeVideo(video)
    '    return -1
end function

sub Main()
    'set the main theme of the application
    SetTheme()
    m.searchResults = []
    
    'add a default facade screen to the app so that the app will only close once this screen has been closed 
    screenFacade = CreateObject("roGridScreen")
    screenFacade.show()
    
    'collect the message screens so we can close them all in one sweep, because it gets a bit jumpy otherwise
    messageScreens = []
    
    beforeEverything()
    PrintIt("Hello")
    'make sure we have a url to the server
    CheckConfiguration()
    skipVersionComparison = false
    'make sure that the server specified in the configuration actually exists
    print "Verifying that the server exists."
    messageScreen = GetNewMessageScreen("", "Connecting to server...")
    messageScreens.push(messageScreen)
    
    serverExists = API_ServerExists() 
    if serverExists = False then 
        confirmResult = Confirm("Unable to find PlumMediaCenter Server at the following url. Would you like to update the url? '" + g_baseUrl() + "'", "Yes", "No")
        if ConfirmResult = True then
            print "The user DOES want to fix the broken url. Prompting for that now.";
            ServerUrlUpdateScreen()
        else
            skipVersionComparison = true
            print "The user does NOT want to fix the broken url. Continue as if the server was working"
        end if
    end if
    
    'we know that the server exists....but now make sure that our version and the server's version are compatible
    messageScreen = GetNewMessageScreen("", "Verifying that the app is compatible with the current version of the server")
    
    messageScreens.Push(messageScreen)
    'if we already know that we have had issues contacting the server, don't bother comparing version numbers....
    if skipVersionComparison = false then
        if compareVersionWithServer() = false then
            messageScreen.close()
            screenFacade.close()
            sleep(25)
            return
        end if
    end if
    
    'close all of the message screens. 
    for each messageScreen in messageScreens
        messageScreen.close()
    end for
    
    'Show the video grid
    MainGrid()
    'exit the app gently so that the screen doesn't flash to black
    screenFacade.Close()
    sleep(25)
end sub

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
    if appMajor < serverMajor or appMinor < serverMinor then
        print "app is behind server"
        'app is behind the server
        choice = b_choose("The server has a higher version than this app can handle. Please go to Settings > System Update from the main roku menu to get the latest version of this app", 0, "Continue at my own risk","Change server url", "Exit")
        if choice = 0 then
            return true
        else if choice = 1
            success = ServerUrlUpdateScreen()
            'try checking the version on the server again now that we have updated the url
            return compareVersionWithServer()
        else
            return false
        end if
        'if the server is behind the app
    else if serverMajor < appMajor or serverMinor <appMinor
        print "server is behind app"
        'server is behind the app
        choice = b_choose(b_concat("The server has a lower version than this app can handle. Server: ", serverVersion, "  Roku App: ", appVersion), 0, "Ignore (Don't update the server)", "Update the server now", "Change the server url", "Exit this app and don't update")
        
        if choice = 0 then
            exitValue = true
        else if  choice = 1
            updatingScreen = GetNewMessageScreen("", "Updating server")
            'get the current server version
            updateSuccess = API_UpdateServer()
            updatingScreen.close()
            'the server threw an error
            if updateSuccess = false  then
                b_alert("There was an error updating the server")
                exitValue = false
            else
                updatedServerVersion = API_GetServerVersionNumber()
                'the server succeeded. see if it actually found any updates
                if serverVersion = updatedServerVersion then
                    b_alert("The server found no updates to install")
                    exitValue = true
                else
                    'the server updated to a new version
                    b_alert(b_concat("Server was successfully updated from version ", serverVersion, " to version ", updatedServerVersion))
                    exitValue = true
                end if
            end if
        else if choice = 2
            success = ServerUrlUpdateScreen()
            'try checking the version on the server again now that we have updated the url
            return compareVersionWithServer()
        else 
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
sub CheckConfiguration()
    print "Checking configuration settings"
    
    if  g_baseUrl() = invalid or g_username() = invalid or g_password = invalid then
        print "PlumMediaCenter api url is not set. Prompting user to enter url."
        ShowMessage("Setup", "This app must be configured before it can be used. Please follow the instructions")
        print "User clicked ok on the initial setup screen"
        ServerUrlUpdateScreen()
    else 
        print "Base URL is set."; g_baseUrl()
    end if
end sub

sub PlayFirstMovie()
    PlayVideo(m.lib.movies[0])
end sub


function PlayFirstEpisode()
    show = m.lib.tvShows[0]
    episode = invalid
    for each season in show.seasons
        for each ep in season
            return PlayVideo(ep)
        end for
    end for
    PlayVideo(episode)
end function

'
' Loads the library from the server into the m.library global variable
'
sub LoadLibrary()
    'retrieve the library from the server
    lib = API_GetLibrary()
    m.lib = lib
end sub


sub PlayVideo(pVideo as object)
    
    'if this video is a tv show, then find the next episode to watch
    if pVideo.mediaType = "TvShow" then 
        messageScreen = GetNewMessageScreen("", "Loading next episode to watch...")
        episode = API_GetNextEpisode(pVideo.videoId)
        'hide the message screen
        messageScreen.Close()
        PlayVideo(episode)
        return
    end if
    
    messageScreen = GetNewMessageScreen("", "Preparing video for playback...")
    
    startSeconds = API_GetVideoProgress(pVideo.videoId)
    print "Start Seconds: ";startSeconds
    resume = true
    if startSeconds > 0 then
        hmsString = GetHourMinuteSecondString(startSeconds)
        'for debugging purposes, skip the confirm window for now
        result = ConfirmWithCancel("Resume where you left off?(" + hmsString + ")", "Resume", "Restart")
        print "Confirm Result: ";result
        if result = 1 then
            print "PlayVideo: resuming playback at ";startSeconds;" seconds"
            resume = true
        else if result = 0 then
            print "PlayVideo: restarting video from beginning"
            resume = false
        else
            print "PlayVideo: cancel video playback"
            return 
        end if
    end if
    if resume then
        startMilliseconds = startSeconds * 1000
        'print "PlayVideo: resuming playback at ";startSeconds;" seconds"
    else
        'print "Restart playback"
        startMilliseconds = -1
    end if
    video  = CreateObject("roAssociativeArray")
    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen") 
    SetAuthHeader(screen)
    ' Note: HDBranded controls whether the "HD" logo is displayed for a 
    '       title. This is separate from IsHD because its possible to
    ' have an HD title where you don't want to show the HD logo 
    ' branding for the title. Set these two as appropriate for 
    ' your content
    video.IsHD = true    
    video.HDBranded = false
    
    ' Note: The preferred way to specify stream info in v2.6 is to use
    ' the Stream roAssociativeArray content meta data parameter. 
    print "Play Video...Url: ";pVideo.url
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
            if msg.isStreamStarted() and startMilliseconds > 0 then
                print "Stream started. Seeking to milliseconds: "; startMilliseconds 
                screen.Seek(startMilliseconds)
                startMilliseconds = -1
            else if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isStatusMessage()
                print "status message: "; msg.GetMessage()
            else if msg.isPlaybackPosition()
                seconds = msg.GetIndex()
                'print "PlayVideo: playback position: ";seconds; " seconds"
                API_SetVideoProgress(pVideo.videoId, seconds)
            else if msg.isFullResult()
                print "playback completed"
                API_SetVideoCompleted(pVideo.videoId)
                completeVideo(pVideo)
                exit while
            else if msg.isPartialResult()
                print "playback interrupted"
                exit while
            else if msg.isRequestFailed()
                print "request failed � error: "; msg.GetIndex();" � "; msg.GetMessage()
                ShowMessage("Error", "There was a problem playing the video. It probably isn't in the proper format. Here is the error message: " + msg.GetMessage())
                exit while
            end if
        end if
    end while 
end sub

function completeVideo(video)
    if g_autoplayIsEnabled() = true then
        print "auto-play is enabled"
        'load the video again, because apparently it is losing the mediaType somwewhere in this process
        video = API_GetVideo(video.videoId)
        print "video.mediaType is ";video.mediaType
        if video.mediaType = "TvShow" or video.mediaType = "TvEpisode" then
            print "video is show or episode"
            messageScreen = GetNewMessageScreen("", "Loading next episode to watch...")
            episode = API_GetNextEpisode(video.videoId)
            
            'if we have just played the last episode, don't repeat it...
            if episode.videoId = video.videoId then
                '
                'show = API_GetTvShow(Int(episode.tvShowVideoId))
                b_alert("Congratulations. You have just finished the last episode of the show")
                return invalid
            end if
            result = UpcomingVideoScreen(episode)
            if result = true then
                PlayVideo(episode)
            else
                'do nothing, the video will just end and we will fall back to the previous screen
            end if
        else
            print "video is not show or episode"
        end if
    else
        print "auto-play is disabled"
    end if
end function
