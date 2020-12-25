function EpisodeGridScreen(tvShowVideoId as integer)
    print "Show tv episodes"
    messageScreen = GetNewMessageScreen("", "Retrieving tv episodes...")
    port = CreateObject("roMessagePort")
    eScreen = CreateObject("roPosterScreen")
    SetAuthHeader(eScreen)
    show = API_GetTvShow(tvShowVideoId)
    episodes = API_GetTvEpisodes(tvShowVideoId)
    'get the video id of the video that should be focused in the episode grid as the one to watch
    nextEpisodeVideoId = API_GetNextEpisodeId(show.videoId)

    eScreen.SetMessagePort(port)
    episodeList = []

    'these two should be populated if there is a tv episode that should be played next. otherwise, it defaults to the first episode in the list
    nextEpisodeIndex = 0
    episodeIndex = 0
    for each episode in episodes
        'if this is the episode to watch, save its position for later when we create the grid
        if episode.videoId = nextEpisodeVideoId then
            nextEpisodeIndex = episodeIndex
        end if
        runtime = invalid
        if episode.runtime > 0 then
            episodeRuntimeMinutes = b_ceil(episode.runtime / 60)
            if episodeRuntimeMinutes <= 1 then
                runtime = "Less than 1 minute"
            else
                runtime = concat(episodeRuntimeMinutes, " minutes")
            end if
        end if
        o = CreateObject("roAssociativeArray")

        o.ContentType = "movie"
        o.Title = b_toString(episode.episodeNumber) + ". " + b_toString(episode.title)
        o.SDPosterUrl = episode.sdPosterUrl
        o.HDPosterUrl = episode.hdPosterUrl
        o.ShortDescriptionLine1 = concat("S", episode.seasonNumber, ":E", b_toString(episode.episodeNumber).trim(), " - ", episode.title)

        o.Description = episode.plot
        o.Rating = episode.mpaa
        'o.StarRating = "75"
        o.ReleaseDate = episode.year
        'o.EpisodeNumber = episode.seasonNumber.ToStr()  + ":" +  episode.episodeNumber.ToStr()
        if runtime <> invalid then
            'o.Length = runtimeStr
            o.ShortDescriptionLine2 = runtime
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
    end for

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
    episodeIndex = nextEpisodeIndex
    while true
        msg = wait(0, port)
        if msg.isScreenClosed() then
            eScreen = invalid
            return invalid
        else if msg.isListItemFocused() then
            print "Focused msg: ";msg.GetMessage()
            print "row: ";msg.GetData();
            print " col: ";msg.GetIndex()
            episodeIndex = msg.GetIndex()
        else if msg.isListItemSelected() then
            print "Selected Episode Index: ";msg.GetIndex()
            episode = episodeList[episodeIndex]
            return episode
        else if msg.isRemoteKeyPressed() and msg.GetIndex() = C_BUTTON_PLAY() then
            episode = episodeList[episodeIndex]
            PlayVideo(episode)
            'whenever the video has finished playing, reload this grid
            return EpisodeGridScreen(tvShowVideoId)
        end if
    end while
end function