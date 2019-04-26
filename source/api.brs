'
' Retrieves the list of category names that will be displayed in the grid
'
function API_GetCategoryNames() as object
    url = g_baseUrl() + "api/GetCategoryNames.php"
    'perform a blocking request to retrieve the library object


    names = GetJSON(url)

    'if the library was not able to be retrieved, make an empty library object
    if (names = invalid) then
        print "Failed to successfully fetch category names from the server"
        names = []
    else
        print "Retrieved library from server. "
    end if

    return names
end function

'
' Retrieves the list of categories
'
function API_GetCategories(categoryNames) as object
    querystring = b_join(categoryNames, ",")
    url = g_baseUrl() + "api/GetCategories.php?names=" + b_urlEncode(querystring)
    b_print("Retrieving categories")
    categories = GetJSON(url)
    categoryLookup = {}
    if (categories = invalid) then
        print "Failed to successfully fetch categories from the server"
        categories = []
        'put the categories into an associative array
    else
        for each category in categories
            categoryLookup[category.name] = category
        end for
        print "Retrieved categories from server."
    end if

    return categoryLookup
end function

'
' Retrieves the library json file from the server. If that was unsuccessful,
' this function returns an empty library object
' @return Object  - the library object if successful, an empty library object if unsuccessful
'
function API_GetLibrary() as object
    libraryUrl = g_baseUrl() + "api/GetLibrary.php"
    'perform a blocking request to retrieve the library object


    lib = GetJSON(libraryUrl)

    'if the library was not able to be retrieved, make an empty library object
    if (lib = invalid) then
        print "Failed to successfully fetch library from server. Using empty library object"
        lib =[]
    else
        print "Retrieved library from server. "
    end if

    return lib
end function

'
' Gets the next episode videoId for the specified tv show
'
function API_GetNextEpisode(tvShowVideoId as integer) as object
    url = g_baseUrl() + "api/GetNextEpisode.php?videoId=" + tvShowVideoId.ToStr()
    print "API-GetNextEpisode: ";url
    result = GetJson(url)
    if result = invalid then
        print "API-GetNextEpisode: invalid"
    else
        print "API-GetNextEpisode: success"
    end if
    return result
end function

'
' Wraps the API_GetNextEpisode call and only returns the episode videoId
'
function API_GetNextEpisodeId(tvShowVideoId as integer) as integer
    episode = API_GetNextEpisode(tvShowVideoId)
    episodeId = -1
    if episode = invalid then
        episodeId = -1
    else
        episodeId = episode.videoId
    end if
    print "API-GetNextEpisodeId: EpisodeId->";episodeId
    return episodeId
end function

'
' Returns an object containing the tv show with the videoId requested, as well as all of the episodes in that show
'
function API_GetTvShow(tvShowVideoId as integer) as object
    url = g_baseUrl() + "api/GetTvShow.php?videoId=" + tvShowVideoId.ToStr()
    print "API-GetTvShow: ";url
    result = GetJson(url)
    if result <> invalid then
        print "API-GetTvShow: showId=";tvShowVideoId;", success"
    else
        print "API-GetTvShow: showId=";tvShowVideoId;", result=invalid"
    end if
    return result
end function

'
' Returns an object containing the tv show with the videoId requested, as well as all of the episodes in that show
'
function API_GetTvEpisodes(tvShowVideoId as integer) as object
    url = b_concat(g_baseUrl(), "api/GetTvEpisodes.php?videoId=", tvShowVideoId)
    print "API-GetTvEpisodes: ";url
    result = GetJson(url)
    if result <> invalid then
        print "API-GetTvEpisodes: showId=";tvShowVideoId;", success"
    else
        print "API-GetTvEpisodes: showId=";tvShowVideoId;", result=invalid"
    end if
    return result
end function

'
'Get the current second number to start a video at
'
function API_GetVideo(videoId as integer) as object
    b_print("API_GetVideo", 1)

    url = b_concat(g_baseUrl(), "api/GetVideo.php?videoId=", videoId)

    b_printc("url: ", url)

    video = GetJSON(url)
    b_printc("Success. videoId: ", b_toString(video.videoId))

    b_print(invalid, -1)
    return video
end function


'
'Get the current second number to start a video at
'
function API_GetVideoProgress(videoId as integer) as integer
    url = g_baseUrl() + "api/GetVideoProgress.php?videoId=" + videoId.ToStr()
    print "API-GetVideoProgress: ";url
    progress = GetJSON(url)
    startSeconds = progress.startSeconds
    print "API-GetVideoProgress: videoId=";videoId;". result (startSeconds)=";startSeconds
    return startSeconds
end function


'
'Set the current second number the video is playing at
'
sub API_SetVideoProgress(videoId as integer, seconds as integer)
    strSeconds = seconds.ToStr()
    strVideoId = videoId.ToStr()
    url = g_baseUrl() + "api/SetVideoProgress.php?videoId=" + strVideoId + "&seconds=" + strSeconds
    result = GetJSON(url)
    if result = invalid then
        success = false
    else
        success = result.success
    end if

    print "API-SetVideoProgress: videoId=";strVideoId;", seconds=";strSeconds;", success=";success
end sub

'
'Set the current second number the video is playing at
'
sub API_SetVideoCompleted(videoId as integer)
    strVideoId = videoId.ToStr()
    url = g_baseUrl() + "api/SetVideoProgress.php?videoId=" + strVideoId + "&finished=true"
    result = GetJSON(url)
    if result = invalid then
        success = false
    else
        success = result.success
    end if
    print "API-SetVideoProgress completed: videoId=";strVideoId;", success=";success
end sub

'
' Determines if the server is currently visible or not.
'
function API_ServerExists() as boolean
    mBaseUrl = g_baseUrl()
    if mBaseUrl = invalid then
        return false
    end if

    url = mBaseUrl + "api/ServerExists.php"
    result = GetJSONBoolean(url)
    success = result
    print "API-ServerExists: url=";url;" Success=";success
    return success
end function

function API_GetServerVersionNumber() as string
    mBaseUrl = g_baseUrl()
    if mBaseUrl = invalid then
        print "base url is invalid"
        return "0.1.0"
    end if

    url = mBaseUrl + "api/GetServerVersionNumber.php"
    result = GetJSON(url)
    print b_concat("server says that version is: ", result)
    if result = invalid then
        print "result is invalid"
        result = "0.1.0"
    else if result = "001.000" then
        print "result is the old value"
        result = "0.1.0"
    end if

    print "API-GetServerVersionNumber: url=";url;" Success=";result
    return result
end function

function API_GetSearchSuggestions(searchString) as object
    url = concat(g_baseUrl(), "api/GetSearchSuggestions.php?q=",searchString)
    result = GetJSON(url)
    if result = invalid
        result = []
    end if
    print concat("API-GetSearchSuggestions: url: ", url)
    return result
end function

function API_GetSearchResults(searchString) as object
    url = concat(g_baseUrl(), "api/GetSearchResults.php?q=", b_escapeUrl(searchString))
    print concat("API-GetSearchResults: url: ", url)
    searchResults = GetJSON(url)
    print concat("API-GetSearchResults: number of results found: ", b_size(searchResults))
    return searchResults
end function

function API_UpdateServer() as boolean
    url = concat(g_baseUrl(), "api/Update.php")
    print concat("API-UpdateServer: url: ", url)
    result = GetJSON(url)
    print result
    if result = invalid
        result = {success: false}
    end if
    print result.success
    return result.success
end function
