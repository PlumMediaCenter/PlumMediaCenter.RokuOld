function VideoGridTile(video)
    o = GridTile({
        Title: video.title,
        SDPosterUrl: video.sdPosterUrl,
        HDPosterUrl: video.hdPosterUrl,
        Description: video.plot,
        Rating: video.mpaa,
        ReleaseDate: video.year,
        onSelect: function()
                PlayVideo(m.video)
            end function,
        onPlay: function()
                PlayVideo(m.video)
            end function
    })
    o.video = video
    o.videoId = video.videoId
    return o
end function


function GetMediaTypeVideoGridTile(video)
    if video.mediaType = "TvShow"
        return TvShowGridTile(video)
    else if video.mediaType = "TvEpisode"
        return VideoGridTile(video)
    end if
end function