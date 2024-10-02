function DevCycleClient(taskNode as Object) as Object
    DevCycleClientObject = {
        initialize: sub()
            if m.private.initialized = true
                return
            end if
            m.private.config = m.private.getConfig()
            m.private.initialized = true
            m.private.scheduleNextFlush()
        end sub,
        identifyUser: sub(user as Object)
            m.private.user = DevCycleUser(user)
            m.private.getConfig()
        end sub,
        track: sub(event as Object)
            eventType = event.type

            if eventType = invalid OR eventType = "" 
                return
            end if

            if eventType <> "variableEvaluated" AND eventType <> "variableDefaulted"
                if m.private.options.disableCustomEventLogging = true
                    return
                else
                    formattedEvent = {
                        type: "customEvent",
                        target: event.target,
                        value: event.value,
                        user_id: m.private.user.user_id
                    }
                    if event.metaData <> invalid
                        formattedEvent["metaData"] = event.metaData
                    end if
                    formattedEvent["customType"] = eventType
                    formattedEvent["clientDate"] = CreateObject("roDateTime").ToISOString()
                    if m.private.config.featureVariationMap <> invalid
                        formattedEvent["featureVars"] = m.private.config.featureVariationMap
                    end if
                    m.private.addCustomEventToQueue(formattedEvent)
                end if
            else 
                if m.private.options.disableAutomaticEventLogging = true
                    return
                else
                    variableEvent = m.private.getVariableEventsFromQueue(eventType, event.target)

                    if variableEvent <> invalid 
                        variableEvent.value += 1.0
                        variableEvent.clientDate = CreateObject("roDateTime").ToISOString()
                        variableEvent.metaData = event.metaData
                        variableEvent.featureVars = m.private.config.featureVariationMap
                        m.private.addVariableEventToQueue(eventType, variableEvent)
                    else
                        formattedEvent = {
                            type: eventType,
                            target: event.target,
                            value: 1.0,
                            user_id: m.private.user.user_id
                        }
                        formattedEvent["clientDate"] = CreateObject("roDateTime").ToISOString()
                        formattedEvent["featureVars"] = m.private.config.featureVariationMap
                        formattedEvent["metaData"] = event.metaData
                        m.private.addVariableEventToQueue(eventType, formattedEvent)
                    end if
                end if
            end if
        end sub,
        resetUser: function() as Object
            m.flush()
            m.private.user = DevCycleUser({})
            m.private.config = invalid
            newConfig = m.private.getConfig()
            return newConfig
        end function,
        flush: sub()
            eventsToSend = m.private.eventQueue
            m.private.sendEvents(eventsToSend)
            m.private.scheduleNextFlush()
        end sub,
        private: {
            sdkKey: taskNode.sdkKey,
            user: DevCycleUser(taskNode.user),
            options: DevCycleOptions(taskNode.options),
            initialized: false,
            config: invalid,
            taskNode: taskNode,
            eventQueue: {
                customEvent: [],
                variableEvaluated: {},
                variableDefaulted: {}
            },
            flushInterval: 10000,
            flushTimer: CreateObject("roTimespan"),
            scheduleNextFlush: sub()
                m.eventQueue["customEvent"] = []
                m.eventQueue["variableEvaluated"] = {}
                m.eventQueue["variableDefaulted"] = {}
                m.flushTimer.Mark() ' Reset the timer
                m.taskNode.flush = true
            end sub,
            addEventToQueue: sub(eventType as String, events as Object)
                if m.eventQueue[eventType] = invalid
                    m.eventQueue[eventType] = []
                end if
                m.eventQueue[eventType] = events
            end sub,
            getEventsFromQueue: function(eventType as String) as Object
                if eventType = "customEvent" and m.eventQueue[eventType] = invalid
                    return []
                end if
                if m.eventQueue[eventType] = invalid
                    return {}
                end if
                return m.eventQueue[eventType]
            end function,
            addCustomEventToQueue: sub(event as Object)
                customEvents = m.getEventsFromQueue("customEvent")
                customEvents.Push(event)
                m.addEventToQueue("customEvent", customEvents)
            end sub,
            addVariableEventToQueue: sub(eventType as String, event as Object)
                if m.eventQueue[eventType][event.target] = invalid
                    m.eventQueue[eventType][event.target] = {}
                end if
                m.eventQueue[eventType][event.target] = event
                m.addEventToQueue(eventType, m.eventQueue[eventType])
            end sub,
            getVariableEventsFromQueue: function(eventType as String, target as String) as Object
                if m.eventQueue[eventType] = invalid OR m.eventQueue[eventType][target] = invalid
                    return invalid
                end if
                return m.eventQueue[eventType][target]
            end function,
            sendEvents: sub(events as Object)
                if m.options.eventsApiProxyURL <> invalid
                    url = m.options.eventsApiProxyURL
                else
                    url = "https://events.devcycle.com/v1/events"
                end if

                combinedEvents = []
                for each event in events.customEvent
                    combinedEvents.Push(event)
                end for
                for each event in events.variableEvaluated
                    combinedEvents.Push(events.variableEvaluated[event])
                end for
                for each event in events.variableDefaulted
                    combinedEvents.Push(events.variableDefaulted[event])
                end for

                formattedEvents = []
                for each event in combinedEvents
                    formattedEvent = {
                        type: event.type,
                        user_id: event.user_id,
                        target: event.target,
                        value: event.value
                    }
                    formattedEvent["customType"] = event.customType
                    formattedEvent["clientDate"] = event.clientDate
                    formattedEvent["metaData"] = event.metaData
                    formattedEvent["featureVars"] = event.featureVars
                    formattedEvents.Push(formattedEvent)
                end for

                if formattedEvents.Count() = 0
                    return
                end if 

                numberOfRequests = formattedEvents.Count() / 100

                for i = 0 to numberOfRequests
                    requestBody = {
                        user: m.user,
                        events: formattedEvents.Slice(i * 100, 100)
                    }
                    
                    urlTransfer = CreateObject("roUrlTransfer")
                    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
                    urlTransfer.InitClientCertificates()
                    urlTransfer.SetUrl(url)
                    urlTransfer.SetRequest("POST")
                    urlTransfer.AddHeader("Content-Type", "application/json")
                    urlTransfer.AddHeader("Authorization", m.sdkKey)

                    response = urlTransfer.PostFromString(FormatJson(requestBody))

                    if response = invalid
                        print "Error sending events"
                    else
                        print "Events sent successfully: "; response
                    end if
                end for

                m.taskNode.flush = false
            end sub,
            getConfig: function() as Object
                sdkKey = m.sdkKey
                url = m.createSDKConfigUrl(sdkKey, m.user, m.options)

                if url = invalid
                    return invalid
                end if

                ' Create and setup the URL transfer object
                urlTransfer = CreateObject("roUrlTransfer")
                urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
                urlTransfer.InitClientCertificates()
                urlTransfer.SetUrl(url)

                ' Make the API request
                response = urlTransfer.GetToString()

                if response <> invalid
                    ' Parse the JSON response
                    jsonResponse = ParseJson(response)
                    if jsonResponse <> invalid
                        ' Save the response in the config property
                        m.configEtag = jsonResponse.etag
                        if m.configEtag = jsonResponse.etag AND FormatJson(m.config) = FormatJson(jsonResponse)
                            return m.config
                        end if
                        m.config = jsonResponse
                        m.taskNode.config = jsonResponse
                        m.updateConfigData(jsonResponse)
                    else
                        print "Error parsing JSON response"
                    end if
                else
                    print "Error fetching data from API"
                end if
                return m.config
            end function,
            createSDKConfigUrl: function(sdkKey as String, user as Object, options as Object) as String
                if sdkKey = invalid
                    return invalid
                end if

                url = getSDKConfigUrl(user, sdkKey, options)

                if url = invalid
                    return invalid
                end if

                return url
            end function,
            updateConfigData: sub(newConfig as Object)
                if newConfig <> invalid
                    m.taskNode.variables = newConfig.variables
                    m.taskNode.features = newConfig.features
                end if
            end sub
        }
    }
    return DevCycleClientObject
end function
