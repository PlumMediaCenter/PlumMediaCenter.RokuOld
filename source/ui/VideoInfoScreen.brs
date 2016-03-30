Function VideoInfoScreen(videoId as Integer)
    b_print("VideoInfoScreen", 1)
    
    b_print(b_concat("videoId: ", videoId))

    messageScreen =  GetNewMessageScreen("", "Loading")
    If m.videoInfoScreen = invalid Then
        m.videoInfoScreen = CreateObject("roSpringboardScreen")
    End If     
    video = API_GetVideo(videoId)
    
    b_print(video)
    
    port = CreateObject("roMessagePort")
    screen = m.videoInfoScreen
    screen.SetMessagePort(port) 
    screen.setProgressIndicatorEnabled(true)
    screen.SetStaticRatingEnabled(false)
    
    screen.AddButton(0, "Play")
    
    screen.SetDisplayMode("photo-fit")
    
    screen.SetBreadcrumbText("[location 1]", "[location2]")
    screen.SetMessagePort(port)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "movie"
    o.Title = video.title
    o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
    o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
    o.Description = video.plot
    o.SDPosterUrl = video.sdPosterUrl
    o.HDPosterUrl = video.hdPosterUrl
    o.Rating = video.mpaa
'    o.StarRating = "75"
    o.ReleaseDate = video.year
    o.Length = video.runtime
'    o.Categories = CreateObject("roArray", 10, true)
'    o.Categories.Push("[Category1]")
'    o.Categories.Push("[Category2]")
'    o.Categories.Push("[Category3]")
'    o.Actors = CreateObject("roArray", 10, true)
'    o.Actors.Push("[Actor1]")
'    o.Actors.Push("[Actor2]")
'    o.Actors.Push("[Actor3]")
'    o.Director = "[Director]"
    screen.SetContent(o)
    screen.Show()
    
    screen.setProgressIndicator(250, 1000)
    while true
        msg = wait(0, port)
        if msg.isScreenClosed() Then
            exit while
        else if msg.isButtonPressed()
            idx = msg.GetIndex()
            if idx = 0 then
                PlayVideo(video)
            end if
            print "msg: "; msg.GetMessage(); "idx: "; msg.GetIndex()
        end if
    end while
    
    b_print(invalid, -1)
    m.videoInfoScreen = invalid
    return -1
End Function