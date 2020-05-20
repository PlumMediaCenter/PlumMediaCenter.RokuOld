function VideoInfoScreen(videoId as integer, selectedEpisodeId = invalid)
    b_print("VideoInfoScreen", 1)

    b_print(b_concat("videoId: ", videoId))

    messageScreen = GetNewMessageScreen("", "Loading")
    if m.videoInfoScreen = invalid then
        m.videoInfoScreen = CreateObject("roSpringboardScreen")
        SetAuthHeader(m.videoInfoScreen)
    end if
    print "loading video"
    video = API_GetVideo(videoId)
    print "video loaded"

    b_print(video)

    port = CreateObject("roMessagePort")
    screen = m.videoInfoScreen
    screen.SetMessagePort(port)
    screen.setProgressIndicatorEnabled(true)
    screen.SetStaticRatingEnabled(false)

    screen.SetDisplayMode("photo-fit")

    'screen.SetBreadcrumbText("[location 1]", "[location2]")
    screen.SetMessagePort(port)
    o = CreateObject("roAssociativeArray")
    isMovie = video.mediaType = "Movie"
    isTvShow = video.mediaType = "TvShow"
    if isTvShow then
        'if no episode was provided, fetch the next episode
        if selectedEpisodeId = invalid then
            episode = API_GetNextEpisode(videoId)
        else
            episode = API_GetEpisode(selectedEpisodeId)
        end if
        videoToPlay = episode

        o.ContentType = "episode"
        'trick the actors list into showing the episode title
        o.Actors = CreateObject("roArray", 10, true)
        o.Actors.Push(b_concat("S", episode.seasonNumber, ":E", episode.episodeNumber, " - ", episode.title))
        o.SDPosterUrl = episode.sdPosterUrl
        o.HDPosterUrl = episode.hdPosterUrl
        o.Description = episode.plot
    else if isMovie then
        o.ContentType = "movie"
        o.SDPosterUrl = video.sdPosterUrl
        o.HDPosterUrl = video.hdPosterUrl
        o.Description = video.plot
        videoToPlay = video
    end if
    startSeconds = API_GetVideoProgress(videoToPlay.videoId)

    SetButtons(video, startSeconds)

    o.Title = video.title
    o.Rating = video.mpaa
    o.ReleaseDate = video.year
    o.Length = video.runtime
    screen.SetContent(o)
    screen.Show()

    screen.setProgressIndicator(250, 1000)
    messageScreen.Close()
    while true
        msg = wait(0, port)
        if msg.isScreenClosed() then
            exit while
        else if msg.isButtonPressed()
            idx = msg.GetIndex()
            'resume
            if idx = m.button_resume then
                PlayVideo(videoToPlay, startSeconds)
                startSeconds = API_GetVideoProgress(videoToPlay.videoId)
                SetButtons(video, startSeconds)

                'play from beginning
            else if idx = m.button_play_from_beginning then
                PlayVideo(videoToPlay, 0)
                startSeconds = API_GetVideoProgress(videoToPlay.videoId)
                SetButtons(video, startSeconds)

                'toggle list inclusion
            else if idx = m.toggle_list then
                ToggleMyList(video, startSeconds)

                'exit
            else if idx = m.back then
                exit while

                'episode picker
            else if idx = m.button_choose_episode then
                episode = EpisodeGridScreen(videoId)
                if episode <> invalid then
                    return VideoInfoScreen(videoId, episode.videoId)
                end if
            end if
            print "msg: "; msg.GetMessage(); "idx: "; msg.GetIndex()
        end if
    end while

    b_print(invalid, -1)
    m.videoInfoScreen = invalid
    return -1
end function

function ToggleMyList(video, startSeconds as integer)
    API_ToggleListInclusion("My+List", video.videoId)
    SetButtons(video, startSeconds)
end function

function SetButtons(video, startSeconds as integer)
    m.button_resume = 0
    m.button_play_from_beginning = 1
    m.button_choose_episode = 2
    m.toggle_list = 3
    m.back = 4

    m.videoInfoScreen.ClearButtons()

    if startSeconds > 0 then
        m.videoInfoScreen.AddButton(m.button_resume, "Resume (" + GetHourMinuteSecondString(startSeconds, true, true) + ")")
        m.videoInfoScreen.AddButton(m.button_play_from_beginning, "Play From Beginning")
    else
        m.videoInfoScreen.AddButton(m.button_play_from_beginning, "Play")
    end if

    if video.mediaType = "TvShow" then
        m.videoInfoScreen.AddButton(m.button_choose_episode, "Choose a different episode")
    end if

    isInMyList = API_GetIsInList("My+List", video.videoId)
    m.videoInfoScreen.AddButton(m.toggle_list, b_iff(isInMyList, "Remove from my list", "Add to my list"))

    m.videoInfoScreen.AddButton(m.back, "Back")

end function
