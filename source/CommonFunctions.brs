

function Get(sUrl as string) as object
    searchRequest = CreateObject("roUrlTransfer") 
    searchRequest.SetURL(sUrl)
    result = searchRequest.GetToString() 
    return result
end function

'
' Performs a network request, returning the json result as an object
' @param string sUrl - the url to request
' @return object - the object created from the result json.
'
Function GetJSON(sUrl as String) as Object
    searchRequest = CreateObject("roUrlTransfer") 
    searchRequest.SetURL(sUrl)
    result = searchRequest.GetToString() 
    obj = ParseJson(result)
    return obj    
End Function

'
' For some reason, brightscript doesn't like to convert json into a boolean value. 
' Perform a web request and expect a boolean value back, either true or false.
'
Function GetJSONBoolean(sUrl as String) as Boolean
  searchRequest = CreateObject("roUrlTransfer") 
    searchRequest.SetURL(sUrl)
    result = searchRequest.GetToString() 
    If result = "true" Then
        return true
    Else
        return false
    End If
End Function

function iff(condition, trueValue, falseValue)
    return b_iff(condition, trueValue, falseValue)
End Function

Function Concat(a=invalid,b=invalid,c=invalid,d=invalid,e=invalid,f=invalid,g=invalid,h=invalid,i=invalid,j=invalid,k=invalid,l=invalid)
    return b_concat(a,b,c,d,e,f,g,h,i,j,k,l)
End function

'
' Sends a nonblocking request in which the return result is not important. 
' This is useful for update requests and such.
'
Sub FireNonBlockingRequest(sUrl as String)
    'print "FireNonBlockingRequest: ";sUrl
    searchRequest = CreateObject("roUrlTransfer") 
    searchRequest.SetURL(sUrl)
    'send the request 
    searchRequest.AsyncGetToString() 
End Sub

Function GetNewMessageScreen(messageTitle = "", message = "") as Object
    dialog = CreateObject("roMessageDialog")
    dialog.SetTitle(messageTitle)
    dialog.SetText(message)
    dialog.Show()
    dialog.ShowBusyAnimation() 
    return dialog
End Function

Sub ShowMessage(messageTitle as String, message as String)
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    dialog.SetTitle(messageTitle)
    dialog.SetText(message)
 
    dialog.AddButton(1, "Ok")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    exit while
                End If
            Else If dlgMsg.isScreenClosed()
                exit while
            End If
        End If
    End While
End Sub

'
' Prompts the user for a yes/no answer, returns the result
' @return boolean - true if user selects yes, false if user selects no.
Function Confirm(message as string, yesText as String, noText as String) as Boolean
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
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                If dlgMsg.GetIndex() = 0
                    print "User chose ";noText 
                    Return False
                End If
                If dlgMsg.GetIndex() = 1
                  print "User chose ";yesText 
                    Return True
                End If
            Else If dlgMsg.isScreenClosed()
                exit while
            End If
        End If
    End While
    'default to return false
    print "User chose cancel or back, which means ";noText 
    Return false
End Function

'
' Prompts the user for a yes/no/cancel answer, returns the result
' @return integer  - 1 if the user chooses yes, 0 if the user chooses no, -1 if the user chooses cancel
Function ConfirmWithCancel(message = "Confirm", yesText  = "Yes", noText  = "No", cancelText = "Cancel") as Integer
    print b_concat("Confirming: '", message , "', '",yesText, "', ", noText, "', 'Cancel'", cancelText)
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
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                print dlgMsg.getMessage()
                If dlgMsg.GetIndex() = 0
                    Return 1
                End If
                If dlgMsg.GetIndex() = 1
                    Return 0
                End If
                If dlgMsg.GetIndex() = 2
                    Return -1
                End If
            Else If dlgMsg.isScreenClosed()
                exit while
            End If
        End If
    End While
    'default to return cancel
    Return -1
End Function

'
' Generates a string containing the hours minutes all together for presentation purposes
' @return string - a string with the hours, minutes and seconds in presentation format
'
Function GetHourMinuteSecondString(pSeconds) As String
    'convert the parameter into an integer
    pSeconds = Int(pSeconds)
    'get the number of hours, minutes and seconds
    hours = Int(pSeconds / 3600)
    minutes = Int((pSeconds / 60) mod 60)
    seconds = pSeconds mod 60
    
    resultString = ""
    'Add the hours, if there are any
    If hours > 0 Then
        resultString = hours.ToStr() + " hours "
    End If
    'Add the minutes, if there are any
    If minutes > 0 Then
        resultString = resultString + minutes.ToStr() + " minutes "
    End If
    'add the seconds, if there are any
    If seconds > 0 Then
        resultString = resultString + seconds.ToStr() + " seconds"        
    End If
    return resultString.Trim()
End Function

Function SortAssociativeArray(aa as Object) as Dynamic
    resultKeys = []
    For Each key in aa
        keyInserted = false
        'determine where in the result this item belongs
        newResult = []
        For Each sortedKey in resultKeys
            'if this new key belongs at the beginning of the list, put it there
            If key < sortedKey Then
                newResult.push(key)
                newResult.push(sortedKey)
                keyInserted = true
            Else
                newResult.push(sortedKey)
            End If
        End For
        If keyInserted = false Then
            newResult.push(key)
        End If
        resultKeys = newResult
    End For
    
    'actually construct the result array
    finalResult = []
    For Each sortKey in resultKeys
        finalResult = aa[sortKey]
    End For
    Return finalResult
End Function

function arrayMerge(a=invalid,b=invalid,c=invalid,d=invalid,e=invalid,f=invalid,g=invalid,h=invalid,i=invalid) as Object
    result = []
    
    params = [a,b,c,d,e,f,g,h,i]
    
    for each param in params
        if param <> invalid
            for each item in param
                result.push(item)
            end for
        end if
    end for
    return result
end function
