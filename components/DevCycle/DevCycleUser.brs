function DevCycleUser(user as Object) as Object
    isAnonymous = false
    user_id = invalid
    if user = invalid or type(user.user_id).InStr("String") <= 0 or user.user_id = ""
        if user.user_id = invalid
            user_id = CreateObject("roDeviceInfo").GetChannelClientId()
            isAnonymous = true
        else
            throw "user_id must be a non-empty string"
        end if
    else
        user_id = user.user_id
    end if

    
    populatedUser = {}
    populatedUser["user_id"] = user_id
    populatedUser["isAnonymous"] = isAnonymous
    populatedUser["createdDate"] = CreateObject("roDateTime").ToISOString()
    populatedUser["lastSeenDate"] = CreateObject("roDateTime").ToISOString()
    populatedUser["platformVersion"] = "1.0.0"
    populatedUser["platform"] = "roku"
    populatedUser["deviceModel"] = createObject("roDeviceInfo").GetModel()
    populatedUser["sdkType"] = "mobile"
    populatedUser["sdkVersion"] = "0.0.0"

    if user.email <> invalid
        populatedUser["email"] = user.email
    end if

    if user.name <> invalid
        populatedUser["name"] = user.name
    end if

    if user.country <> invalid
        populatedUser["country"] = user.country
    end if

    if user.customData <> invalid
        populatedUser["customData"] = user.customData
    end if

    if user.privateCustomData <> invalid
        populatedUser["privateCustomData"] = user.privateCustomData
    end if

    return populatedUser
end function

function HttpEncode(str as String) as String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
end function

function getSDKConfigUrl(user as Object, sdkKey as String, options as Object) as String
    if options.apiProxyURL <> invalid
        sdkBaseUrl = options.apiProxyURL
    else
        sdkBaseUrl = "https://sdk-api.devcycle.com/v1/mobileSDKConfig"
    end if
    url = sdkBaseUrl + "?sdkKey=" + sdkKey

    if user.user_id <> invalid
        url += "&user_id=" + user.user_id
    end if

    url += "&isAnonymous=" + user.isAnonymous.toStr()

    if user.email <> invalid
        url += "&email=" + user.email
    end if

    if user.name <> invalid
        url += "&name=" + user.name
    end if

    if user.country <> invalid
        url += "&country=" + user.country
    end if

    if user.customData <> invalid
        url += "&customData=" + HttpEncode(FormatJson(user.customData))
    end if

    if user.privateCustomData <> invalid
        url += "&privateCustomData=" + HttpEncode(FormatJson(user.privateCustomData))
    end if

    url += "&createdDate=" + user.createdDate
    url += "&lastSeenDate=" + user.lastSeenDate
    url += "&platform=" + user.platform
    url += "&platformVersion=" + user.platformVersion
    url += "&deviceModel=" + user.deviceModel
    url += "&sdkType=" + user.sdkType
    url += "&sdkVersion=" + user.sdkVersion

    if options.enableEdgeDB = true
        url += "&enableEdgeDB=true"
    end if
    return url
end function
