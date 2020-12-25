

function Get(sUrl as string) as object
    http = CreateObject("roUrlTransfer")
    http.SetURL(sUrl)

    SetAuthHeader(http)
    result = http.GetToString()
    return result
end function

'
' Add basic auth to all requests from this http agent (video player, grid, request, etc)
'
function SetAuthHeader(httpAgent, username = invalid, password = invalid) as object
    if username = invalid then username = g_username()
    if password = invalid then password = g_password()

    'assume all requests are protected by basic authentication
    ba = CreateObject("roByteArray")
    header = b_concat(username, ":", password)
    ba.FromAsciiString(header)
    'ba.FromAsciiString("bronley:romantic")
    httpAgent.AddHeader("Authorization", "Basic " + ba.ToBase64String())
    return httpAgent
end function

'
' Performs a network request, returning the json result as an object
' @param string sUrl - the url to request
' @return object - the object created from the result json.
'
function GetJSON(sUrl as string) as object
    resultText = Get(sUrl)
    if resultText <> "" then
        obj = ParseJson(resultText)
    else
        obj = invalid
    end if
    return obj
end function

'
' For some reason, brightscript doesn't like to convert json into a boolean value.
' Perform a web request and expect a boolean value back, either true or false.
'
function GetJSONBoolean(sUrl as string) as boolean
    resultText = Get(sUrl)
    if resultText = "true" then
        return true
    else
        return false
    end if
end function

function iff(condition, trueValue, falseValue)
    return b_iff(condition, trueValue, falseValue)
end function

function Concat(a = invalid, b = invalid, c = invalid, d = invalid, e = invalid, f = invalid, g = invalid, h = invalid, i = invalid, j = invalid, k = invalid, l = invalid)
    return b_concat(a, b, c, d, e, f, g, h, i, j, k, l)
end function

'
' Sends a nonblocking request in which the return result is not important.
' This is useful for update requests and such.
'
sub FireNonBlockingRequest(sUrl as string)
    'print "FireNonBlockingRequest: ";sUrl
    http = CreateObject("roUrlTransfer")
    SetAuthHeader(http)
    http.SetURL(sUrl)
    'send the request
    http.AsyncGetToString()
end sub

function GetMediaTypeVideoGridTiles(videos)
    tiles = []
    'break the videos out into movies or tv shows
    for each video in videos
        'b_printc("viewing video", video)
        if b_isAssociativeArray(video) then
            tile = GetMediaTypeVideoGridTile(video)
            tiles.Push(tile)
        end if
    end for
    return tiles
end function

function GetNewMessageScreen(messageTitle = "", message = "") as object
    dialog = CreateObject("roMessageDialog")
    dialog.SetTitle(messageTitle)
    dialog.SetText(message)
    dialog.Show()
    ' dialog.ShowBusyAnimation()
    return dialog
end function

sub ShowMessage(messageTitle as string, message as string)
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    dialog.SetTitle(messageTitle)
    dialog.SetText(message)

    dialog.AddButton(1, "Ok")
    dialog.EnableBackButton(true)
    dialog.Show()
    while True
        dlgMsg = wait(0, dialog.GetMessagePort())
        if type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
end sub

'
' Prompts the user for a yes/no answer, returns the result
' @return boolean - true if user selects yes, false if user selects no.
function Confirm(message as string, yesText as string, noText as string) as boolean
    print "Confirming: '" + message + "', '" + yesText + "', " + noText + "'"
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    'dialog.SetTitle(messageTitle)
    dialog.SetText(message)

    dialog.AddButton(1, yesText)
    dialog.AddButton(0, noText)
    dialog.EnableBackButton(true)
    dialog.Show()
    while True
        dlgMsg = wait(0, dialog.GetMessagePort())
        if type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 0
                    print "User chose ";noText
                    return False
                end if
                if dlgMsg.GetIndex() = 1
                    print "User chose ";yesText
                    return True
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
    'default to return false
    print "User chose cancel or back, which means ";noText
    return false
end function

'
' Prompts the user for a yes/no/cancel answer, returns the result
' @return integer  - 1 if the user chooses yes, 0 if the user chooses no, -1 if the user chooses cancel
function ConfirmWithCancel(message = "Confirm", yesText = "Yes", noText = "No", cancelText = "Cancel") as integer
    print b_concat("Confirming: '", message, "', '", yesText, "', ", noText, "', 'Cancel'", cancelText)
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    'dialog.SetTitle(messageTitle)
    dialog.SetText(message)

    dialog.AddButton(0, yesText)
    dialog.AddButton(1, noText)
    dialog.AddButton(2, cancelText)
    dialog.EnableBackButton(true)
    dialog.Show()
    while True
        dlgMsg = wait(0, dialog.GetMessagePort())
        if type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                print dlgMsg.getMessage()
                if dlgMsg.GetIndex() = 0
                    return 1
                end if
                if dlgMsg.GetIndex() = 1
                    return 0
                end if
                if dlgMsg.GetIndex() = 2
                    return -1
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
    'default to return cancel
    return -1
end function

'
' Generates a string containing the hours minutes all together for presentation purposes
' @return string - a string with the hours, minutes and seconds in presentation format
'
function GetHourMinuteSecondString(pSeconds, useShortUnits = false, skipSecondsIfHaveHours = false) as string
    'convert the parameter into an integer
    pSeconds = Int(pSeconds)
    'get the number of hours, minutes and seconds
    hours = Int(pSeconds / 3600)
    minutes = Int((pSeconds / 60) mod 60)
    seconds = pSeconds mod 60


    resultString = ""
    'Add the hours, if there are any
    if hours > 0 then
        resultString = hours.ToStr() + iff(useShortUnits, "h ", " hours ")
    end if
    'Add the minutes, if there are any
    if minutes > 0 then
        resultString = resultString + minutes.ToStr() + iff(useShortUnits, "m ", " minutes ")
    end if
    haveSeconds = seconds > 0
    haveHours = hours > 0

    if hours > 0 and skipSecondsIfHaveHours then
        'skip seconds
    else
        'add the seconds, if there are any
        if haveSeconds then
            resultString = resultString + seconds.ToStr() + iff(useShortUnits, "s", " seconds")
        end if
    end if
    return resultString.Trim()
end function

function SortAssociativeArray(aa as object) as dynamic
    resultKeys = []
    for each key in aa
        keyInserted = false
        'determine where in the result this item belongs
        newResult = []
        for each sortedKey in resultKeys
            'if this new key belongs at the beginning of the list, put it there
            if key < sortedKey then
                newResult.push(key)
                newResult.push(sortedKey)
                keyInserted = true
            else
                newResult.push(sortedKey)
            end if
        end for
        if keyInserted = false then
            newResult.push(key)
        end if
        resultKeys = newResult
    end for

    'actually construct the result array
    finalResult = []
    for each sortKey in resultKeys
        finalResult = aa[sortKey]
    end for
    return finalResult
end function

function arrayMerge(a = invalid, b = invalid, c = invalid, d = invalid, e = invalid, f = invalid, g = invalid, h = invalid, i = invalid) as object
    result = []

    params = [a, b, c, d, e, f, g, h, i]

    for each param in params
        if param <> invalid
            for each item in param
                result.push(item)
            end for
        end if
    end for
    return result
end function

function getIpAddress()
    info = CreateObject("roDeviceInfo")
    return info.GetConnectionInfo().ip
end function