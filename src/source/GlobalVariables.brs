'
' The base url of the PlumMediaCenter server. This is the server
' at which the videos are actually hosted from.
' An example url: http://192.168.1.109/PlumMediaCenter/
' @return string - the base url, if it was found in the registry
'
function g_baseUrl(value = "__invalid") as dynamic
    if b_toString(value) = "__invalid" then
        registryValue = b_getRegistryValue("baseUrl")
        return registryValue
    else
        b_setRegistryValue("baseUrl", value)
    end if
    return invalid
end function

function g_username(value = "__invalid") as dynamic
    if b_toString(value) = "__invalid" then
        registryValue = b_getRegistryValue("username")
        return registryValue
    else
        b_setRegistryValue("username", value)
    end if
    return invalid
end function

function g_password(value = "__invalid") as dynamic
    if b_toString(value) = "__invalid" then
        registryValue = b_getRegistryValue("password")
        return registryValue
    else
        b_setRegistryValue("password", value)
    end if
    return invalid
end function

'
' Gets or sets the autoplay duration. A duration of 0 is instant, a duration of -1 is disabled
function g_autoplayDuration(value = "__invalid") as dynamic
    if b_toString(value) = "__invalid" then
        print "get autoplayDuration"
        result = b_getRegistryValue("autoplayDuration")
        print "autoplayValue=";result
        return b_iff(b_isInvalid(result), 10000, b_parseInt(result))
    else
        duration = b_toString(value)
        print "set autoplayDuration";duration
        b_setRegistryValue("autoplayDuration", duration)
    end if
    return invalid
end function

'
' Determines if autoplay is enabled
'
function g_autoplayIsEnabled() as boolean
    duration = g_autoplayDuration()
    if duration > 0 then
        return true
    else
        return false
    end if
end function