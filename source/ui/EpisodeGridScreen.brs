Function EpisodeGridScreen(tvShowVideoId as Integer)
    print "Show tv episodes"
    messageScreen =  GetNewMessageScreen("", "Retrieving tv episodes...")
    port = CreateObject("roMessagePort")
    If m.episodeScreen = invalid Then
        m.episodeScreen = CreateObject("roPosterScreen")
    End If     
    show = API_GetTvShow(tvShowVideoId)  
    episodes = API_GetTvEpisodes(tvShowVideoId)  
    'get the video id of the video that should be focused in the episode grid as the one to watch
    nextEpisodeVideoId = API_GetNextEpisodeId(show.videoId)
    
    eScreen = m.episodeScreen
    eScreen.SetMessagePort(port) 
    episodeList = []
   
    'these two should be populated if there is a tv episode that should be played next. otherwise, it defaults to the first episode in the list
    nextEpisodeIndex = 0
    episodeIndex = 0 
    For Each episode in episodes
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
        'For Each actor in episode.actorList
        '    name = actor.name
        '    o.Actors.push(name)
        'End For
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