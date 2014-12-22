'
' Retrieves the library json file from the server. If that was unsuccessful, 
' this function returns an empty library object
' @return Object  - the library object if successful, an empty library object if unsuccessful 
'
Function API_GetLibrary() as Object
    libraryUrl = BaseUrl() + "api/GetLibrary.php"
    'perform a blocking request to retrieve the library object


    lib = GetJSON(libraryUrl)
    
    'if the library was not able to be retrieved, make an empty library object
    If (lib = invalid) Then
        print "Failed to successfully fetch library from server. Using empty library object"
        lib =[]
    Else
        print "Retrieved library from server. "
    End if
    
    return lib
End Function

'
' Gets the next episode videoId for the specified tv show
'
Function API_GetNextEpisode(tvShowVideoId as integer) as Object
    url = BaseUrl() + "api/GetNextEpisode.php?videoId=" + tvShowVideoId.ToStr()
    print "API-GetNextEpisode: ";url
    result = GetJson(url)
    If result = invalid Then
        print "API-GetNextEpisode: invalid"
    Else
        print "API-GetNextEpisode: success"
    End If
    return result
End Function

'
' Wraps the API_GetNextEpisode call and only returns the episode videoId
'
Function API_GetNextEpisodeId(tvShowVideoId as Integer) as Integer
    episode = API_GetNextEpisode(tvShowVideoId)
    episodeId = -1
    If episode = invalid Then
        episodeId = -1
    Else
        episodeId = episode.videoId
    End If
    print "API-GetNextEpisodeId: EpisodeId->";episodeId
    return episodeId
End Function

'
' Returns an object containing the tv show with the videoId requested, as well as all of the episodes in that show
'
Function API_GetTvShow(tvShowVideoId as Integer) as Object
    url = BaseUrl() + "api/GetTvShow.php?videoId=" + tvShowVideoId.ToStr()
    print "API-GetTvShow: ";url
    result = GetJson(url)
    If result <> invalid Then
        print "API-GetTvShow: showId=";tvShowVideoId;", success"
    Else
        print "API-GetTvShow: showId=";tvShowVideoId;", result=invalid"
    End If
    return result
End Function

'
' Returns an object containing the tv show with the videoId requested, as well as all of the episodes in that show
'
Function API_GetTvEpisodes(tvShowVideoId as Integer) as Object
    url = b_concat(BaseUrl(), "api/GetTvEpisodes.php?videoId=", tvShowVideoId)
    print "API-GetTvEpisodes: ";url
    result = GetJson(url)
    If result <> invalid Then
        print "API-GetTvEpisodes: showId=";tvShowVideoId;", success"
    Else
        print "API-GetTvEpisodes: showId=";tvShowVideoId;", result=invalid"
    End If
    return result
End Function


'
'Get the current second number to start a video at 
'
Function API_GetVideoProgress(videoId as Integer) as Integer
    url = BaseUrl() + "api/GetVideoProgress.php?videoId=" + videoId.ToStr()
    print "API-GetVideoProgress: ";url
    progress = GetJSON(url)
    startSeconds = progress.startSeconds
    print "API-GetVideoProgress: videoId=";videoId;". result (startSeconds)=";startSeconds
    return startSeconds 
End Function


'
'Set the current second number the video is playing at
'
Sub API_SetVideoProgress(videoId as Integer, seconds as Integer)
    strSeconds = seconds.ToStr()
    strVideoId = videoId.ToStr()
    url = BaseUrl() + "api/SetVideoProgress.php?videoId=" + strVideoId + "&seconds=" + strSeconds
    result = GetJSON(url)
    success = result.success
    print "API-SetVideoProgress: videoId=";strVideoId;", seconds=";strSeconds;", success=";success
End Sub

'
'Set the current second number the video is playing at
'
Sub API_SetVideoCompleted(videoId as Integer)
    strVideoId = videoId.ToStr()
    url = BaseUrl() + "api/SetVideoProgress.php?videoId=" + strVideoId + "&finished=true"
    result = GetJSON(url)
    success = result.success
    print "API-SetVideoProgress completed: videoId=";strVideoId;", success=";success
End Sub

'
' Determines if the server is currently visible or not. 
'
Function API_ServerExists() as Boolean
    mBaseUrl = BaseUrl()
    If mBaseUrl = invalid Then
        Return false
    End If
    
    url = mBaseUrl + "api/ServerExists.php"
    result = GetJSONBoolean(url)
    success = result
    print "API-ServerExists: url=";url;" Success=";success
    return success
End Function

Function API_GetServerVersionNumber() as String
    mBaseUrl = BaseUrl()
    If mBaseUrl = invalid Then
        print "base url is invalid"
        Return "0.1.0"
    End If
    
    url = mBaseUrl + "api/GetServerVersionNumber.php"
    result = GetJSON(url)
    print b_concat("server says that version is", result)
    if result = invalid then
        print "result is invalid"
        result = "0.1.0"
    else if result = "001.000" then
        print "result is the old value"
        result = "0.1.0"
    end if
    
    print "API-GetServerVersionNumber: url=";url;" Success=";result
    return result
End Function

function API_GetSearchSuggestions(searchString) as Object
    url = concat(BaseUrl(), "api/GetSearchSuggestions.php?title=",searchString)
    result = GetJSON(url)
    if result = invalid 
        result = []
    end if
    print concat("API-GetSearchSuggestions: url: ", url)
    return result
end function

function API_GetSearchResults(searchString) as Object
    url = concat(BaseUrl(), "api/GetSearchResults.php?title=", b_escapeUrl(searchString))
    print concat("API-GetSearchResults: url: ", url)
    searchResults = GetJSON(url)
    print concat("API-GetSearchResults: number of results found: ", b_size(searchResults))
    return searchResults
end function

function API_UpdateServer() as Boolean
    url = concat(BaseUrl(), "api/Update.php")
    print concat("API-UpdateServer: url: ", url)
    result = GetJSON(url)
    print result
    if result = invalid
        result = {success: false}
    end if
    print result.success
    return result.success
end function
