function GridTile(params)
    o = CreateObject("roAssociativeArray")
    o.ContentType = "movie"
    o.Title = params.Title

    o.SDPosterUrl = params.SDPosterUrl
    o.HDPosterUrl = params.HDPosterUrl
    o.ShortDescriptionLine1 = params.ShortDescriptionLine1
    o.ShortDescriptionLine2 = params.ShortDescriptionLine2
    o.Description = params.Description
    o.Rating = params.Rating
    'o.StarRating = "75"
    o.ReleaseDate = params.ReleaseDate

    'o.Length = 5400
    'o.Actors = []
    'For Each actor in video.actorList
    '    name = actor.name
    '    o.Actors.push(name)
    'End For
    'o.Director = "[Director]"

    'methods
    o.onPlay = iff(params.onPlay <> invalid, params.onPlay, function()
        print "onPlay empty action"
    end function)
    o.onSelect = iff(params.onSelect <> invalid, params.onSelect, function()
        print "onPlay empty action 1"
    end function)
    return o
end function