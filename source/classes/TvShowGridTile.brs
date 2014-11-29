function TvShowGridTile(video)
    o = VideoGridTile(video)
    o.onSelect = function()
            videoId = m.video.videoId
            ShowTvEpisodesGrid(videoId)
       end function
    return o
end function