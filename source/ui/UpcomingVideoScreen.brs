function UpcomingVideoScreen(video)
    print "Show upcoming video screen"
    if m.upcomingVideoScreen = invalid then
        m.upcomingVideoScreen = CreateObject("roMessageDialog")
    end if
    screen = m.upcomingVideoScreen
    screen.SetTitle("Up Next")

    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    autoplayDuration = g_autoplayDuration()
    secondsUntilPlayback = iff(autoplayDuration > 0, autoplayDuration / 1000, 0)

    baselineText = b_concat("Up next: ", video.title, " Season ", video.seasonNumber, " Episode ", video.episodeNumber, chr(10), "Playing in ")
    screen.UpdateText(b_concat(baselineText, secondsUntilPlayback, " seconds"))
    screen.ShowBusyAnimation()

    screen.AddButton(0, "Play Now")
    screen.AddButton(1, "Cancel")
    screen.show()

    result = b_timedInterval({
        messageCallback: function(obj, msg)
            print "message received"
            if msg.isButtonPressed() then
                print "remote key pressed"

                index = msg.GetIndex()
                print "index is: ";index
                if index = 0 then
                    'play right now
                    m.upcomingVideoScreen = invalid
                    return true
                else if index = 1 then
                    'cancel playback
                    m.upcomingVideoScreen = invalid
                    return false
                end if

            end if
        end function,
        intervalCallback: function(obj)
            print "autoplay next video in ";obj.secondsUntilPlayback;" seconds"
            obj.secondsUntilPlayback = obj.secondsUntilPlayback - 1
            obj.screen.UpdateText(b_concat(obj.baselineText, obj.secondsUntilPlayback, " seconds"))
        end function
        secondsUntilPlayback: secondsUntilPlayback,
        screen: screen,
        baselineText: baselineText,
        durationMilliseconds: autoplayDuration,
        intervalMilliseconds: 1000,
        port: port
    })
    if b_isBoolean(result) then
        m.upcomingVideoScreen = invalid
        return result
    else
        m.upcomingVideoScreen = invalid
        return true
    end if
end function