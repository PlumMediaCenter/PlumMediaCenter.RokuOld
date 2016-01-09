function VideoGridTile(video)
    o = GridTile({
        Title: video.title,
        Description: video.plot,
        Rating: video.mpaa,
        ReleaseDate: video.year,
        onSelect: function()
                messageScreen = GetNewMessageScreen("Loading", "Playing video")
                PlayVideo(m.video)
                messageScreen.close()
            end function,
        onPlay: function()
                messageScreen = GetNewMessageScreen("Loading", "Playing video")
                PlayVideo(m.video)
                messageScreen.close()
            end function
    })
    
    'if the video has no poster, then the poster url is pointing to a relative path to the server.
    o.SDPosterUrl = b_iff(video.posterModifiedDate = invalid, b_concat(g_baseUrl(), video.sdPosterUrl), video.sdPosterUrl)
    o.HDPosterUrl = b_iff(video.posterModifiedDate = invalid, b_concat(g_baseUrl(), video.hdPosterUrl), video.hdPosterUrl)
    o.video = video
    o.videoId = video.videoId
    return o
end function


function GetMediaTypeVideoGridTile(video)
    if video.mediaType = "TvShow"
        return TvShowGridTile(video)
    else if video.mediaType = "TvEpisode"
        return VideoGridTile(video)
    else 
        return VideoGridTile(video)
    end if
end function