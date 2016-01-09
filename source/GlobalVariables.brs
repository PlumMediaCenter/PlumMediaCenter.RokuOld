'
' The base url of the PlumMediaCenter server. This is the server
' at which the videos are actually hosted from.
' An example url: http://192.168.1.109/PlumMediaCenter/
' @return string - the base url, if it was found in the registry
'
function g_baseUrl(value="__invalid") as dynamic
    if b_toString(value) = "__invalid" then
        registryValue = b_getRegistryValue("baseUrl")
        return registryValue
    else
        b_setRegistryValue("baseUrl", value)
    end if
    return invalid
end function

function g_autoplayIsEnabled(value="__invalid") as dynamic
    print "autoplayIsEnabled.";b_iff( b_isInvalid(value), "get()", "set()")
    if b_toString(value) = "__invalid" then
        result = b_getRegistryValue("autoplayIsEnabled")
        return b_iff(result = "false", false, true)
    else
        b_setRegistryValue("autoplayIsEnabled", b_toString(value))
    end if
    return invalid
end function
