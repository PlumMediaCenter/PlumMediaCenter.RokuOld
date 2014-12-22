'
' The base url of the PlumMediaCenter server. This is the server
' at which the videos are actually hosted from.
' An example url: http://192.168.1.109/PlumMediaCenter/
' @return string - the base url, if it was found in the registry
'
Function BaseUrl() as Dynamic
    return GetRegVal("baseUrl")
End Function

'
' The base url of the server. This is the server
' at which the videos are actually hosted from.
' An example url: http://192.168.1.109/PlumMediaCenter/
' @param string sBaseUrl- the base url to be saved to the registry
'
Sub SetBaseUrl(sBaseUrl as String)
    SetRegVal("baseUrl", sBaseUrl)
End Sub

