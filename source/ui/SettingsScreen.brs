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
    o.ShortDescriptionLine1  = "Point the app to the server url running PlumMediaCenter"
    o.SDPosterUrl =  "pkg:/images/settings.sd.png"
    o.HDPosterUrl = "pkg:/images/settings.hd.png"
    o.action = function()
        ServerUrlUpdateScreen()
    end function
    list.Push(o)
    
    o = CreateObject("roAssociativeArray")
    o.Title = "Auto-play"
    o.ShortDescriptionLine1  = "Set the auto-play settings"
    o.SDPosterUrl =  "pkg:/images/settings.sd.png"
    o.HDPosterUrl = "pkg:/images/settings.hd.png"
    o.action = function()
        choice = b_choose("Enable Auto-play?", 0, "Yes", "No")
        if choice = 0 then
            g_autoplayIsEnabled("true")
        else
            g_autoplayIsEnabled("false")
        end if        
    end function
    list.Push(o)
    
    o = CreateObject("roAssociativeArray")
    o.Title = "Back"
    o.ShortDescriptionLine1  = "Return to the previous screen"
    o.SDPosterUrl =  "pkg:/images/settings.sd.png"
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
        If msg.isScreenClosed() then
            exit while
        Else If msg.isListItemFocused()
            print "Focused msg: ";msg.GetMessage();"row: ";msg.GetIndex();
            print " col: ";msg.GetData()
         Else If msg.isListItemSelected()
            index = msg.GetIndex()
            print "Selected Index: ";index
            item = list[index]
            
            'if this is the last item in the list, it's the exit option
            if index = b_size(list) - 1 then
                exit while
            else
                item.action()
            end if
        End If
    End While
    
    m.settingsScreen = invalid
    Return -1
end function