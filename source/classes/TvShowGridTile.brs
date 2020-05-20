function TvShowGridTile(video)
    o = VideoGridTile(video)
    o.onSelect = function()
        messageScreen = GetNewMessageScreen("Loading", "Retrieving episodes")
        videoId = m.video.videoId
        VideoInfoScreen(videoId)
        messageScreen.close()
    end function
    return o
end function