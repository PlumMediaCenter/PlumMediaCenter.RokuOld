function MainGrid()
    'if the video grid has not yet been created, create it
    if m.videoGrid = invalid then
        m.videoGrid = CreateObject("roGridScreen")
        SetAuthHeader(m.videoGrid)
    end if
    'grab the videoGrid from the global variables
    roGridScreen = m.videoGrid
    port = CreateObject("roMessagePort")
    roGridScreen.SetMessagePort(port)

    'show a loading message while we set up the page
    messageScreen = GetNewMessageScreen("", "Loading videos...")

    categoryNames = API_GetCategoryNames()
    b_printc("Server said it has these categories: ", categoryNames)
    categories = API_GetCategories(categoryNames)

    'load the library from the server. This will replace the global library object with a new one from the server
    'LoadLibrary()

    'get a new grid manager to keep track of all of the tiles
    grid = GridManager()


    'assume that the first item in the list is the 'recently watched' category
    recentlyWatchedCategory = categories[categoryNames[0]]

    tiles = GetMediaTypeVideoGridTiles(recentlyWatchedCategory.videos)
    grid.addRow(categoryNames[0], tiles)


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
    if b_size(m.searchResults) > 0 then
        for each video in m.searchResults
            searchList.Push(GetMediaTypeVideoGridTile(video))
        end for
    end if
    searchTitle = iff(m.searchTerm <> invalid, concat("Search Results for '", m.searchTerm, "'"), "Search")
    grid.addRow(searchTitle, searchList)

    'loop through every other category and add a row for each

    isFirstCategory = true
    for each categoryName in categoryNames
        category = categories[categoryName]
        'skip the first one since it is the 'recently watched' category
        if isFirstCategory then
            isFirstcategory = false
        else
            grid.addRow(categoryName, GetMediaTypeVideoGridTiles(category.videos))
        end if
    end for

    '
    ' Add settings
    '
    settingsList = []
    settingsList.push(GridTile({
        Title: "Settings",
        Description: "Change settings",
        SDPosterUrl: "pkg:/images/settings.sd.png",
        HDPosterUrl: "pkg:/images/settings.hd.png",
        onSelect: function()
            SettingsScreen()
        end function
    }))
    settingsList.push(GridTile({
        Title: "Refresh Videos",
        Description: "Refresh the page with the latest videos from the server",
        SDPosterUrl: "pkg:/images/refresh.sd.png",
        HDPosterUrl: "pkg:/images/refresh.hd.png",
        onSelect: function()
            MainGrid()
        end function
    }))
    settingsList.push(GridTile({
        Title: "Check for server updates",
        Description: concat("App Version: ", APP_VERSION_NUMBER(), chr(10), "Server Version: ", API_GetServerVersionNumber()),
        SDPosterUrl: "pkg:/images/info.sd.png",
        HDPosterUrl: "pkg:/images/info.hd.png",
        onSelect: function()
            waitMessage = GetNewMessageScreen("Updating", "Checking for updates...")
            'try to update the server
            success = API_UpdateServer()
            waitMessage.close()
            if success = true then
                ShowMessage("", "Server was successfully updated")
            else
                ShowMessage("", "There was an issue while updating the server")
            end if
            MainGrid()
        end function
    }))

    grid.addRow("Settings", settingsList)

    grid.draw(roGridScreen)

    'if there is at least one search result, select that first item
    if b_size(m.searchResults) > 0 then
        roGridScreen.SetFocusedListItem(1, 1)
        selectedTile = grid.getItem(1, 1)
    else
        roGridScreen.SetFocusedListItem(0, 0)
        selectedTile = grid.getItem(0, 0)
    end if

    roGridScreen.Show()

    'hide the message screen now that the grid has been shown
    messageScreen.Close()

    while true
        msg = wait(0, port)
        print "message received";msg
        if type(msg) = "roGridScreenEvent" then
            if msg.isScreenClosed() then
                return -1
            else if msg.isListItemFocused() then
                rowNumber = msg.GetIndex()
                columnNumber = msg.GetData()

                selectedTile = grid.getItem(rowNumber, columnNumber)
                print concat("Main grid item focused. Row: ", rowNumber, ", Col: ", columnNumber)
            else if msg.isRemoteKeyPressed() then
                keyCode = msg.GetIndex()
                print concat("Remote key was pressed: ", keyCode)

                if selectedTile <> invalid then
                    'play button was pressed
                    if keyCode = C_BUTTON_PLAY() then
                        'fire the onPlay function of the tile
                        selectedTile.onPlay()
                    end if
                end if
            else if msg.isListItemSelected() then
                if selectedTile <> invalid then
                    'fire the onSelect function of the tile
                    selectedTile.onSelect()
                end if
                'do nothing
            end if
        end if
    end while
end function