function showSearchScreen()
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSearchScreen")
    screen.SetBreadcrumbText("", "search")
    screen.SetMessagePort(port)
    screen.SetSearchTermHeaderText("Suggestions:")
    screen.SetEmptySearchTermsText("Enter a title of a movie or TV show")
    screen.SetSearchButtonText("Search")
    screen.SetClearButtonEnabled(false)
    screen.show()
    done = false
    searchTerm = ""
    while done = false
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSearchScreenEvent"
            if msg.isScreenClosed()
                print "screen closed"
                done = true
            else if msg.isCleared()
                print "search terms cleared"
                screen.ClearSearchTerms()
            else if msg.isFullResult()
                searchTerm = msg.GetMessage()
                loadSearchResults(searchTerm)
                done = true
            else
                searchTerm = msg.GetMessage()
                screen.SetSearchTerms(getSearchSuggestions(searchTerm))
            end if
        end if
    end while
    print "Exiting..."
end function

function getSearchSuggestions(searchTerm) as object
    results = CreateObject("roArray", 1, true)
    suggestions = API_GetSearchSuggestions(searchTerm)
    for each suggestion in suggestions
        results.push(suggestion.title)
    end for
    return results
end function

function loadSearchResults(searchTerm) as object
    messageScreen = GetNewMessageScreen("", "Searching")
    results = API_GetSearchResults(searchTerm)
    m.searchResults = results
    m.searchTerm = searchTerm
    numberOfResults =  b_size(results)
    print concat("Search results for '",searchTerm,"': count: ",numberOfResults)
    MainGrid()
    messageScreen.Close()
end function



