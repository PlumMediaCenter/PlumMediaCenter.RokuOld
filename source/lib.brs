function lib_GetGridScreenVideo(video)
    if video.mediaType = "TvShow"
        return lib_GetGridScreenTvShow(video)
    else if video.mediaType = "TvEpisode"
        return lib_GetGridScreenTvEpisode(video)
    else
        return lib_GetGridScreenMovie(video)
    end if
end function

function lib_GetGridScreenMovie(video)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "movie"
    o.Title = video.title
    o.SDPosterUrl = video.sdPosterUrl
    o.HDPosterUrl = video.hdPosterUrl
    o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
    o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
    o.Description = video.plot
    o.Rating = video.mpaa
    'o.StarRating = "75"
    o.ReleaseDate = video.year
    'o.Length = 5400
    o.Actors = []
    for each actor in video.actorList
        name = actor.name
        o.Actors.push(name)
    end for
    o.Director = "[Director]"
    return o
end function

function lib_GetGridScreenTvShow(video)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "series"
    o.Title = video.title
    o.SDPosterUrl = video.sdPosterUrl
    o.HDPosterUrl = video.hdPosterUrl
    o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
    o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
    o.Description = video.plot
    o.Rating = video.mpaa
    'o.Length = 1000
    o.NumEpisodes = video.episodeCount
    'o.StarRating = "75"
    o.ReleaseDate = video.year
    o.TextAttrs = {
        Color: "#FFCCCCCC",
        Font: "Small",
        HAlign: "HCenter",
        VAlign: "VCenter",
        Direction: "LeftToRight"
    }
    'o.Length = 5400
    o.Actors = []

    for each actor in video.actorList
        name = actor.name
        o.Actors.push(name)
    end for
    o.Director = "[Director]"
    return o
end function

function lib_GetGridScreenTvEpisode(video)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "movie"
    o.Title = video.title
    o.SDPosterUrl = video.sdPosterUrl
    o.HDPosterUrl = video.hdPosterUrl
    o.ShortDescriptionLine1 = "[ShortDescriptionLine1]"
    o.ShortDescriptionLine2 = "[ShortDescriptionLine2]"
    o.Description = video.plot
    o.Rating = video.mpaa
    'o.StarRating = "75"
    o.ReleaseDate = video.year
    'o.Length = 5400
    o.Actors = []
    for each actor in video.actorList
        name = actor.name
        o.Actors.push(name)
    end for
    o.Director = "[Director]"
    return o
end function