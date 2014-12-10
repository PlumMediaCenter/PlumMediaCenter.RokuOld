'''
' count the number of items in an array or associative array
'''
function b_size(collection=invalid)
    count = 0 
    if collection = invalid
        count = 0
    'if it has a count function, use that
    else if b_isArray(collection)
        count = collection.Count()
    else
        'manually determine its size by interating over each item in the list
        for each item in collection
            count = count + 1
        end for
    end if
    return count
end function

Function b_isXmlElement(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifXMLElement") <> invalid
End Function

Function b_isFunction(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifFunction") <> invalid
End Function

Function b_isBoolean(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifBoolean") <> invalid
End Function

Function b_isInteger(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifInt") <> invalid And (Type(value) = "roInt" Or Type(value) = "roInteger" Or Type(value) = "Integer")
End Function

Function b_isFloat(value As Dynamic) As Boolean
    Return b_isValid(value) And (GetInterface(value, "ifFloat") <> invalid Or (Type(value) = "roFloat" Or Type(value) = "Float"))
End Function

Function b_isDouble(value As Dynamic) As Boolean
    Return b_isValid(value) And (GetInterface(value, "ifDouble") <> invalid Or (Type(value) = "roDouble" Or Type(value) = "roIntrinsicDouble" Or Type(value) = "Double"))
End Function

Function b_isList(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifList") <> invalid
End Function

Function b_isArray(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifArray") <> invalid
End Function

Function b_isAssociativeArray(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifAssociativeArray") <> invalid
End Function

Function b_isString(value As Dynamic) As Boolean
    Return b_isValid(value) And GetInterface(value, "ifString") <> invalid
End Function

Function b_isDateTime(value As Dynamic) As Boolean
    Return b_isValid(value) And (GetInterface(value, "ifDateTime") <> invalid Or Type(value) = "roDateTime")
End Function

Function b_isValid(value As Dynamic) As Boolean
    Return Type(value) <> "<uninitialized>" And value <> invalid
End Function


'
' Shows the user a message and waits until they click ok
Sub b_alert(message as string) 
    print "Alerting: '" + message + "'"
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    'dialog.SetTitle(messageTitle)
    dialog.SetText(message)
 
    dialog.AddButton(1, "Ok")
    dialog.EnableBackButton(false)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                exit while
            End If
        End If
    End While
End Sub

function b_iff(condition, trueValue, falseValue)
    if condition = true
        return trueValue
    else
        return falseValue
    end if
End Function

'**
' Turns the value into a url-safe string (converting invalid characters to their safe representations
' @param {string} value - the value to be escaped
' @return {string} - the value in url escaped form
'*
Function b_escapeUrl(value) as String
    value = b_CStr(value)
    o = CreateObject("roUrlTransfer")
    return o.Escape(value)
End Function

'**
' Converts the item to a string
' @param {object} item - the item to be converted to a string
' @return {string} - the item in its string representation
'*
Function b_CStr(item) as String
    result = ""
    itemType = type(item)
    
    if item = invalid
        result = "invalid"
    else if itemType = "String"
        result = item
    else if itemType = "roString"
        result = item.GetString()
    else if itemType = "Boolean"
        result = iff(item, "true", "false")
    else if itemType = "Integer" or itemType = "Float" or itemType = "Double"
        'remove the leading space brightscript puts in for numeric types
        result = Str(item).trim()
    else if itemType = "Object"
        result = "[object]"
    else if itemType = "Function"
        result = "[function]"
    else if itemType = "Interface"
        result = "[interface]"
    else
        result = Str(item)
    end if
    return result
End Function

Function b_concat(a=invalid,b=invalid,c=invalid,d=invalid,e=invalid,f=invalid,g=invalid,h=invalid,i=invalid,j=invalid,k=invalid,l=invalid)
    result = ""
    if a <> invalid
        result = result + b_cstr(a)
    end if
    if b <> invalid
        result = result + b_cstr(b)
    end if
    if c <> invalid
        result = result + b_cstr(c)
    end if
    if d <> invalid
        result = result + b_cstr(d)
    end if
    if e <> invalid
        result = result + b_cstr(e)
    end if
    if f <> invalid
        result = result + b_cstr(f)
    end if
    if g <> invalid
        result = result + b_cstr(g)
    end if
    if h <> invalid
        result = result + b_cstr(h)
    end if
    if i <> invalid
        result = result + b_cstr(i)
    end if
    if j <> invalid
        result = result + b_cstr(j)
    end if
    if k <> invalid
        result = result + b_cstr(k)
    end if
    return result
End function