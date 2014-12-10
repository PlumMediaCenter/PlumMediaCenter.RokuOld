function MainGrid()
     'if the video grid has not yet been created, create it
    If m.videoGrid = invalid Then
        m.videoGrid = CreateObject("roGridScreen")
    End If 
    'grab the videoGrid from the global variables
    roGridScreen = m.videoGrid
    port = CreateObject("roMessagePort")
    roGridScreen.SetMessagePort(port) 
    
    'show a loading message while we set up the page
    messageScreen = GetNewMessageScreen("", "Loading videos...")

    'load the library from the server. This will replace the global library object with a new one from the server
    LoadLibrary()
    
    'get a new grid manager to keep track of all of the tiles
    grid = GridManager()
    
    '
    ' Add search tile and any search results
    '
    searchList = []
    searchList.push(GridTile({
        Title: "Search",
        Description: "Search for movies and TV shows by title",
        onSelect: showSearchScreen,
        SDPosterUrl: "pkg:/images/search.sd.png"
        HDPosterUrl: "pkg:/images/search.hd.png"
    }))
       'load any search results into the list as well
    if b_size(m.searchResults) > 0 
        for each video in m.searchResults
            searchList.Push(GetMediaTypeVideoGridTile(video))
        end for
    end if
    searchTitle = iff(m.searchTerm <> invalid, concat("Search Results for '", m.searchTerm, "'"), "Search")
    grid.addRow(searchTitle, searchList)
    
    tvShowList = []
    movieList = []
 
    'break the videos out into movies or tv shows
    for each video in m.lib
        tile = GetMediaTypeVideoGridTile(video)
        if video.mediaType = "TvShow"
           tvShowList.push(tile)
        else
            movieList.push(tile)
        end if
    end for
 
    'add the tv shows to the grid
    grid.addRow("TV Shows", tvShowList)
    'add the movies to the grid
    grid.addRow("Movies", movieList)
    
    '
    ' Add settings
    '
    settingsList = []
    settingsList.push(GridTile({
        Title: "Set PlumMediaCenter server url",
        Description:"Set the url for the PlumMediaCenter server that this app will interact with",
        SDPosterUrl: "pkg:/images/settings.sd.png",
        HDPosterUrl: "pkg:/images/settings.hd.png",
        onSelect: function()
            showSettings(0)
        end function
    }))
    settingsList.push(GridTile({
        Title: "Refresh Videos",
        Description:"Refresh the page with the latest videos from the server",
        SDPosterUrl: "pkg:/images/refresh.sd.png",
        HDPosterUrl: "pkg:/images/refresh.hd.png",
        onSelect: function()
            showSettings(1)
        end function
    }))
    settingsList.push(GridTile({
        Title: "Version Number",
        Description:concat("App Version: ", APP_VERSION_NUMBER(), chr(10),"Server Version: ", API_GetServerVersionNumber()),
        SDPosterUrl: "pkg:/images/info.sd.png",
        HDPosterUrl: "pkg:/images/info.hd.png"
    }))

    grid.addRow("Settings", settingsList)
   
    roGridScreen.Show() 
    
    grid.draw(roGridScreen)
    'if there is at least one search result, select that first item
    if b_size(m.searchResults) > 0
        roGridScreen.SetFocusedListItem(0,1)
    end if
    
    'hide the message screen now that the grid has been shown
    messageScreen.Close()

    'by default, select the search icon since that's the one that is highlighted on page load
    selectedTile = grid.getItem(0, 0)
    while true
        msg = wait(0, port)
        print "message received";msg
        If type(msg) = "roGridScreenEvent" Then
            If msg.isScreenClosed() Then
                Return -1
            Else If msg.isListItemFocused()
                rowNumber = msg.GetIndex()
                columnNumber = msg.GetData()
                
                selectedTile = grid.getItem(rowNumber, columnNumber)
                print concat("Main grid item focused. Row: ",rowNumber,", Col: ",columnNumber)
            else if msg.isRemoteKeyPressed()
                keyCode = msg.GetIndex()
                print concat("Remote key was pressed: ",keyCode)
                
                 if selectedTile <> invalid
                    'play button was pressed
                    if keyCode = C_BUTTON_PLAY()
                        'fire the onPlay function of the tile
                        selectedTile.onPlay()
                    end if
                end if
             Else If msg.isListItemSelected()
               if selectedTile <> invalid
                    'fire the onSelect function of the tile
                    selectedTile.onSelect()
                end if
               'do nothing
            End if
        End if
    End While


end function