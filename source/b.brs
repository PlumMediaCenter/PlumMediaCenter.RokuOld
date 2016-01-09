function b_ceil(val as integer)
    ceiling = val
    if Int(val) = val 
        ceiling = val
    else 
        ceiling = Int(val) + 1
    end if
    return ceiling
end function


'
' Prompts the user to choose from the specified options. 
' @param {string} message - the message 
' @param {int} selectedItemIndex - the index of the item that should be selected by default
' @param ... pass in a string for each option
' @return {int} - the zero based index of the item selected, where 0 is the first option
function b_choose(message, selectedItemIndex, a=invalid,b=invalid,c=invalid,d=invalid,e=invalid,f=invalid,g=invalid,h=invalid) as integer
    print b_concat("Making user choose: '", message)
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    dialog.EnableBackButton(true)
    'dialog.SetTitle(messageTitle)
    dialog.SetText(message)
    options = [a,b,c,d,e,f,g,h]
    i = 0
    for each option in options
        if option = invalid
            exit for
        end if
        dialog.AddButton(i, option)
        i = i + 1
    end for
    dialog.SetFocusedMenuItem(selectedItemIndex)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                selectedIndex = dlgMsg.GetIndex()
                return selectedIndex
            Else If dlgMsg.isScreenClosed()
                exit while
            end If
        end If
    end While
    'default to return false
    print "User chose cancel or back" 
    Return -1 
end function

'
' Retrieves the registry value in the provided section and at the specified key
' @param string name - the name of the variable to be saved in the registry
' @param {string} [section="Settings"] - the section to save the value into. If not specified, the default is used
'
function b_getRegistryValue(name as String, section="Settings") as dynamic
    sec = CreateObject("roRegistrySection", section)
     if sec.Exists(name)  
         return sec.Read(name)
     endif
     return invalid
end function


'
' Saves a value to the registry in the 'Settings category
' @param string name - the name of the variable to be saved in the registry
' @param string value - the value to save into the registry
' @param {string} [section="Settings"] - the section to save the value into. If not specified, the default is used
'
function b_setRegistryValue(name as string, value as string, section="Settings") as void
    sec = CreateObject("roRegistrySection", section)
    sec.Write(name, value)
    sec.Flush()
end function


'
' Deletes a registry setting from the registry
' @param string name - the name of the registry key
' @param {string} [section="Settings"] - the section the value is saved in. If not specified, the default is used
'
function b_deleteRegistryValue(name as String, section="Settings") as Void
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(name)
    sec.Flush()
end function

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

function b_isXmlElement(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifXMLElement") <> invalid
end function

function b_isfunction(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "iffunction") <> invalid
end function

function b_isBoolean(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifBoolean") <> invalid
end function

function b_isInteger(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifInt") <> invalid And (Type(value) = "roInt" Or Type(value) = "roInteger" Or Type(value) = "Integer")
end function

function b_isFloat(value as Dynamic) as Boolean
    Return b_isValid(value) And (GetInterface(value, "ifFloat") <> invalid Or (Type(value) = "roFloat" Or Type(value) = "Float"))
end function

function b_isDouble(value as Dynamic) as Boolean
    Return b_isValid(value) And (GetInterface(value, "ifDouble") <> invalid Or (Type(value) = "roDouble" Or Type(value) = "roIntrinsicDouble" Or Type(value) = "Double"))
end function

function b_isList(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifList") <> invalid
end function

function b_isArray(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifArray") <> invalid
end function

function b_isAssociativeArray(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifAssociativeArray") <> invalid
end function

function b_isString(value as Dynamic) as Boolean
    Return b_isValid(value) And GetInterface(value, "ifString") <> invalid
end function

function b_isDateTime(value as Dynamic) as Boolean
    Return b_isValid(value) And (GetInterface(value, "ifDateTime") <> invalid Or Type(value) = "roDateTime")
end function

function b_isValid(value as Dynamic) as Boolean
    Return Type(value) <> "<uninitialized>" And value <> invalid
end function

function b_isInvalid(value as Dynamic) as Boolean
    Return not b_isValid(value)
end function

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
            end If
        end If
    end While
end Sub

function b_iff(condition, trueValue, falseValue)
    if condition = true
        return trueValue
    else
        return falseValue
    end if
end function

'**
' Turns the value into a url-safe string (converting invalid characters to their safe representations
' @param {string} value - the value to be escaped
' @return {string} - the value in url escaped form
'*
function b_escapeUrl(value) as String
    value = b_toString(value)
    o = CreateObject("roUrlTransfer")
    return o.Escape(value)
end function

function b_timedInterval(obj as dynamic) 
    
    if b_isInvalid(obj.durationMilliseconds) then
        print "obj.durationMilliseconds is invalid"
    else 
        print "obj.durationMilliseconds is valid";obj.durationMilliseconds
    end if
    obj.durationMilliseconds = b_iff(b_isInvalid(obj.durationMilliseconds), 10000, obj.durationMilliseconds)
    obj.intervalMilliseconds = b_iff(b_isInvalid(obj.intervalMilliseconds), 1000, obj.intervalMilliseconds)
    obj.port = b_iff(b_isInvalid(obj.port),  CreateObject("roMessagePort"), obj.port)
    
    clock = CreateObject("roTimespan")
    lastCall = clock.TotalMilliseconds() + obj.durationMilliseconds
    
    next_call = clock.TotalMilliseconds() + obj.intervalMilliseconds
    while true
        msg = wait(250, obj.port) ' wait for a message
        if b_isValid(msg) then
            result = obj.messageCallback(obj, msg)
            if b_isValid(result) then
                return result
            end if
        end if
        if clock.TotalMilliseconds() > next_call then
            'if we have exceeded the alotted duration, finish
            if clock.TotalMilliseconds() >= lastCall then
                return invalid
            end if
            obj.intervalCallback(obj)
            next_call = clock.TotalMilliseconds() + obj.intervalMilliseconds
        end if
    end while
    return invalid
end function

'**
' Converts the item to a string
' @param {object} item - the item to be converted to a string
' @return {string} - the item in its string representation
'*
function b_toString(item) as String
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
    else if itemType = "function"
        result = "[function]"
    else if itemType = "Interface"
        result = "[interface]"
    else
        result = Str(item)
    end if
    return result
end function

function b_concat(a=invalid,b=invalid,c=invalid,d=invalid,e=invalid,f=invalid,g=invalid,h=invalid,i=invalid,j=invalid,k=invalid,l=invalid)
    result = ""
    if a <> invalid
        result = result + b_toString(a)
    end if
    if b <> invalid
        result = result + b_toString(b)
    end if
    if c <> invalid
        result = result + b_toString(c)
    end if
    if d <> invalid
        result = result + b_toString(d)
    end if
    if e <> invalid
        result = result + b_toString(e)
    end if
    if f <> invalid
        result = result + b_toString(f)
    end if
    if g <> invalid
        result = result + b_toString(g)
    end if
    if h <> invalid
        result = result + b_toString(h)
    end if
    if i <> invalid
        result = result + b_toString(i)
    end if
    if j <> invalid
        result = result + b_toString(j)
    end if
    if k <> invalid
        result = result + b_toString(k)
    end if
    return result
end function

    