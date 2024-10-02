function DevCycleOptions(options as Object) as Object
    defaultOptions = {}

    defaultOptions["flushEventsIntervalMs"] = 10000
    defaultOptions["disableCustomEventLogging"] = false
    defaultOptions["disableAutomaticEventLogging"] = false
    defaultOptions["enableEdgeDB"] = false
    defaultOptions["apiProxyURL"] = invalid
    defaultOptions["eventsApiProxyURL"] = invalid

    populatedOptions = {}

    if options.flushEventsIntervalMs <> invalid
        populatedOptions["flushEventsIntervalMs"] = options.flushEventsIntervalMs
    else
        populatedOptions["flushEventsIntervalMs"] = defaultOptions["flushEventsIntervalMs"]
    end if

    if options.disableCustomEventLogging <> invalid
        populatedOptions["disableCustomEventLogging"] = options.disableCustomEventLogging
    else
        populatedOptions["disableCustomEventLogging"] = defaultOptions["disableCustomEventLogging"]
    end if

    if options.disableAutomaticEventLogging <> invalid
        populatedOptions["disableAutomaticEventLogging"] = options.disableAutomaticEventLogging
    else
        populatedOptions["disableAutomaticEventLogging"] = defaultOptions["disableAutomaticEventLogging"]
    end if
    
    if options.enableEdgeDB <> invalid
        populatedOptions["enableEdgeDB"] = options.enableEdgeDB
    else
        populatedOptions["enableEdgeDB"] = defaultOptions["enableEdgeDB"]
    end if

    if options.apiProxyURL <> invalid
        populatedOptions["apiProxyURL"] = options.apiProxyURL
    else
        populatedOptions["apiProxyURL"] = defaultOptions["apiProxyURL"]
    end if

    if options.eventsApiProxyURL <> invalid
        populatedOptions["eventsApiProxyURL"] = options.eventsApiProxyURL
    else
        populatedOptions["eventsApiProxyURL"] = defaultOptions["eventsApiProxyURL"]
    end if
    
    return populatedOptions
end function
