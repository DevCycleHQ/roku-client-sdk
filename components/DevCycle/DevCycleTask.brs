sub Init()
    m.messagePort = createObject("roMessagePort")
    m.top.observeField("sdkKey", "startThread")
    m.top.observeField("config", m.messagePort)
    m.top.observeField("options", m.messagePort)
    m.top.observeField("flush", m.messagePort)
    m.top.observeField("track", m.messagePort)
    m.top.observeField("identifyUser", m.messagePort)
    m.top.observeField("resetUser", m.messagePort)
    m.top.initialized = false
end sub

sub startThread()
    m.top.functionName = "mainThread"
    m.top.control = "RUN"
end sub

sub mainThread()
    m.client = DevCycleClient(m.top)
    m.client.initialize()
    m.top.initialized = m.client.private.initialized
    while true
        ' Use a non-blocking wait with a timeout of 100ms
        msg = wait(1000, m.messagePort)
        ' Process the message if there is one
        if msg <> invalid and type(msg) = "roSGNodeEvent"
            field = msg.getField()
            if field = "track"
                m.client.track(msg.getData())
            else if field = "flush"
                m.client.flush()
            else if field = "identifyUser"
                if m.top.identifyUser = true
                    m.client.identifyUser(m.top.user)
                    m.top.identifyUser = false
                end if
            else if field = "resetUser"
                if msg.getData() = true
                    m.client.resetUser()
                    m.top.resetUser = false
                end if
            end if
        end if
        ' Check the flush timer
        if m.client.private.flushTimer.TotalMilliseconds() > m.client.private.flushInterval
            m.client.flush()
        end if
    end while
end sub
