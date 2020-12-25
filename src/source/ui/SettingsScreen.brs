function SettingsScreen()
    print "Show settings screen"
    if m.settingsScreen = invalid then
        m.settingsScreen = CreateObject("roListScreen")
    end if
    screen = m.settingsScreen
    screen.SetHeader("Settings")

    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    list = []
    o = CreateObject("roAssociativeArray")
    o.Title = "Set PlumMediaCenter Server Url"
    o.ShortDescriptionLine1 = "Point the app to the server url running PlumMediaCenter"
    o.SDPosterUrl = "pkg:/images/settings.sd.png"
    o.HDPosterUrl = "pkg:/images/settings.hd.png"
    o.action = function()
        ServerUrlUpdateScreen()
    end function
    list.Push(o)

    o = CreateObject("roAssociativeArray")
    o.Title = "Auto-play"
    o.ShortDescriptionLine1 = "Set the auto-play settings"
    o.SDPosterUrl = "pkg:/images/settings.sd.png"
    o.HDPosterUrl = "pkg:/images/settings.hd.png"
    o.action = function()
        selectedIndex = 0

        duration = g_autoplayDuration()
        if duration = 15000 then
            selectedIndex = 1
        else if duration = 10000 then
            selectedIndex = 1
        else if duration = 5000 then
            selectedIndex = 2
        else if duration = 0
            selectedIndex = 3
        else
            selectedIndex = 4
        end if

        choice = b_choose("Select the length of time to wait before playing the next media item", selectedIndex, "15 seconds", "10 seconds", "5 seconds", "Instant", "Disable auto-play")
        if choice = 0 then
            duration = 15000
        else if choice = 1 then
            duration = 10000
        else if choice = 2 then
            duration = 5000
        else if choice = 3 then
            duration = 0
        else
            duration = -1
        end if

        'set the selected duration
        g_autoplayDuration(duration)
    end function
    list.Push(o)

    o = CreateObject("roAssociativeArray")
    o.Title = "Back"
    o.ShortDescriptionLine1 = "Return to the previous screen"
    o.SDPosterUrl = "pkg:/images/settings.sd.png"
    o.HDPosterUrl = "pkg:/images/settings.hd.png"
    list.Push(o)

    screen.SetContent(list)
    screen.show()
    '
    '   'add the list of episodes to the posterScreen
    '    eScreen.SetContentList(episodeList)
    '    'set the grid to wide so the episode pictures look better
    '    eScreen.SetListStyle("flat-episodic-16x9")
    '    eScreen.SetListDisplayMode("scale-to-fit")
    '    eScreen.SetBreadcrumbText(show.title, "")
    '    'focus the grid on the episode that was marked as 'next'.
    '    print "Next Episode grid indexes:: ";nextEpisodeIndex
    '    eScreen.SetFocusedListItem(nextEpisodeIndex)
    '    'hide the message
    '    messageScreen.Close()
    '    print "show episode screen"
    '    eScreen.Show()
    '    episodeIndex = -1
    while true
        msg = wait(0, port)
        if msg.isScreenClosed() then
            exit while
        else if msg.isListItemFocused()
            print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
            print " col: ";msg.GetData()
        else if msg.isListItemSelected()
            index = msg.GetIndex()
            print "Selected Index: ";index
            item = list[index]

            'if this is the last item in the list, it's the exit option
            if index = b_size(list) - 1 then
                exit while
            else
                item.action()
            end if
        end if
    end while

    m.settingsScreen = invalid
    return -1
end function