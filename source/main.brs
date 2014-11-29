
Function Main()
    'set the main theme of the application
    SetTheme()
    m.searchResults = []

    'add a default facade screen to the app so that the app will only close once this screen has been closed 
    screenFacade = CreateObject("roGridScreen")
    screenFacade.show()
    
    if compareVersionWithServer() = false
        screenFacade.close()
        sleep(25)
        return true
    end if
     
    'Check the app configuration. If not configured, prompt the user for all necessary information
    CheckConfiguration()
    
    'make sure that the server specified in the configuration actually exists
    print "Verifying that the server exists."
    messageScreen = GetNewMessageScreen("", "Verifying that the server exists at the provided url...")
    serverExists = API_ServerExists() 
    messageScreen.close()
    
    If serverExists = False Then 
        confirmResult = Confirm("Unable to find PlumVideoPlayer server at the following url. Would you like to update the url? '" + BaseUrl() + "'", "Yes", "No")
        If ConfirmResult = True Then
            print "The user DOES want to fix the broken url. Prompting for that now.";
            GetBaseUrlFromUser()
        Else
            print "The user does NOT want to fix the broken url. Continue as if the server was working"
        End If
    End If
    
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
    appVersion = APP_VERSION_NUMBER()
    appVersionParts = appVersion.Tokenize(".")
    serverVersion = API_GetServerVersionNumber()
    serverVersionParts = serverVersion.Tokenize(".")
    print concat("Comparing app version and server version: ", appVersion, " --- ", serverVersion)
    print concat( Val(appVersionParts[0]), " < ",Val(serverVersionParts[0]), " or ", Val(appVersionParts[1]) ," < ", Val(serverVersionParts[1]))
    print concat( Val(serverVersionParts[0]), " < ",Val(appVersionParts[0]), " or ", Val(serverVersionParts[1]) ," < ", Val(appVersionParts[1]))
    'if app is behind the server
    if appVersionParts[0] < serverVersionParts[0] or appVersionParts[1] < serverVersionParts[0]
        print "app is behind server"
        'app is behind the server
        result = Confirm("The server has a higher version than this app can handle. Please go to Settings > System Update to get the latest version of this app","I don't care. Proceed","Exit")
   'if the server is behind the app

    else if Val(serverVersionParts[0]) < Val(appVersionParts[0]) or Val(serverVersionParts[1]) < Val( appVersionParts[1])
        print "server is behind app"
        'server is behind the app
        result = ConfirmWithCancel("The server has a lower version than this app can handle. Would you like to have the server check for updates now?","Yes, update the server now","Don't update the server but launch the app", "Don't update the server and exit the app")
    'the app and the server are within the same major/minor versions of each other. everything is ok
    else
        print "app and server are at the same major-minor version"
        return true
    end if
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

Function ShowTvEpisodesGrid(tvShowVideoId as Integer)
    print "Show tv episodes"
    messageScreen =  GetNewMessageScreen("", "Retrieving tv episodes...")
    port = CreateObject("roMessagePort")
    If m.episodeScreen = invalid Then
        m.episodeScreen = CreateObject("roPosterScreen")
    End If     
    show = API_GetTvShow(tvShowVideoId)    
    'get the video id of the video that should be focused in the episode grid as the one to watch
    nextEpisodeVideoId = API_GetNextEpisodeId(show.videoId)
    
    eScreen = m.episodeScreen
    eScreen.SetMessagePort(port) 
    episodeList = []
   
    'these two should be populated if there is a tv episode that should be played next. otherwise, it defaults to the first episode in the list
    nextEpisodeIndex = 0
    episodeIndex = 0 
    For Each episode in show.episodes
        'if this is the episode to watch, save its position for later when we create the grid
        If episode.videoId = nextEpisodeVideoId Then
            nextEpisodeIndex = episodeIndex
        End If
       runtime = invalid
       If episode.runtime > 0 Then
            episodeRuntimeMinutes = episode.runtime / 60
            if episodeRuntimeMinutes <= 1
                runtime = "Less than 1 minute"
            else
                runtime = concat(episodeRuntimeMinutes, " minutes")
            end if
        End If
        o = CreateObject("roAssociativeArray")
        
        o.ContentType = "movie"
        o.Title = cstr(episode.episodeNumber) + ". " + cstr(episode.title)
        o.SDPosterUrl = episode.sdPosterUrl
        o.HDPosterUrl = episode.hdPosterUrl
        o.ShortDescriptionLine1 = concat("S", episode.seasonNumber,":E", cstr(episode.episodeNumber).trim()," - ", episode.title)
        
        o.Description = episode.plot
        o.Rating = episode.mpaa
        'o.StarRating = "75"
        o.ReleaseDate = episode.year
        'o.EpisodeNumber = episode.seasonNumber.ToStr()  + ":" +  episode.episodeNumber.ToStr()
        if runtime <> invalid then
            'o.Length = runtimeStr
            o.ShortDescriptionLine2 =  runtime
        end if
        o.Actors = []
        o.url = episode.url
        o.videoId = episode.videoId
        For Each actor in episode.actorList
            name = actor.name
            o.Actors.push(name)
        End For
        o.Director = "[Director]"
        episodeList.Push(o)
        episodeIndex = episodeIndex + 1
    End For
   
   'add the list of episodes to the posterScreen
    eScreen.SetContentList(episodeList)
    'set the grid to wide so the episode pictures look better
    eScreen.SetListStyle("flat-episodic-16x9")
    eScreen.SetListDisplayMode("scale-to-fit")
    eScreen.SetBreadcrumbText(show.title, "")
    'focus the grid on the episode that was marked as 'next'. 
    print "Next Episode grid indexes:: ";nextEpisodeIndex 
    eScreen.SetFocusedListItem(nextEpisodeIndex)    
    'hide the message
    messageScreen.Close()
    print "show episode screen"
    eScreen.Show() 
    episodeIndex = -1
    while true
        msg = wait(0, port)
        If msg.isScreenClosed() then
            m.episodeScreen = invalid
            Return -1
        Else If msg.isListItemFocused()
            print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
            print " col: ";msg.GetData()
         Else If msg.isListItemSelected()
            print "Selected Episode Index: ";msg.GetIndex()
            episodeIndex = msg.GetIndex()
            episode = episodeList[episodeIndex]
            PlayVideo(episode)
            'whenever the video has finished playing, reload this grid
            Return ShowTvEpisodesGrid(tvShowVideoId) 
        End If
    End While
End Function

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
