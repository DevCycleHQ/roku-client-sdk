sub displayChangedConfig(event as Object)
    config = event.getData()
    if config <> invalid
        m.configData.text = "Config: " + FormatJson(config)
        m.jsonVar.text = "JSON: " + FormatJson(m.devcycleClient.getVariableValue("json-var", {}))
        m.numVar.text = "Number: " + Str(m.devcycleClient.getVariableValue("num-var", 0))
        m.stringVar.text = "String: " + m.devcycleClient.getVariableValue("string-var", "stringy")
        m.undefinedVar.text = "Undefined: " + m.devcycleClient.getVariableValue("undefined-var", "invalid")
        m.booleanVar.text = "Boolean: " + FormatJson(m.devcycleClient.getVariable("onetestfr1", false))
        booleanVar = m.devcycleClient.getVariableValue("onetestfr1", false)
        if booleanVar
            m.booleanSquare.color = "0x00FF00FF"
        else
            m.booleanSquare.color = "0xFF0000FF"
        end if
    else
        m.configData.text = "Invalid Config Data"
    end if

    mockEvent = {
        type: "mockEventType",
        date: CreateObject("roDateTime").ToISOString(),
        target: "mockTarget",
        value: 123,
        metaData: {
            key1: "value1",
            key2: "value2"
        }
    }
    mockEvent2 = {
        type: "mockEventType2",
        date: CreateObject("roDateTime").ToISOString(),
        target: "mockTarget",
        value: 123,
        metaData: {
            key1: "value1",
            key2: "value2"
        }
    }
    m.devcycleClient.track(mockEvent)
    m.devcycleClient.track(mockEvent2)
end sub

sub init()
    m.top.setFocus(true)
    m.myLabel = m.top.findNode("myLabel")
    m.configData = m.top.findNode("configData")
    m.featuresData = m.top.findNode("featuresData")
    m.variablesData = m.top.findNode("variablesData")
    m.devCycleTask = m.top.findNode("devCycleTask")
    m.resultLabel = m.top.findNode("resultLabel")
    m.buttonGroup = m.top.findNode("buttonGroup")
    m.buttonPressedLabel = m.top.findNode("buttonPressedLabel")
    m.labelLayout = m.top.findNode("labelLayout")

    m.jsonVar = m.top.findNode("jsonVar")
    m.numVar = m.top.findNode("numVar")
    m.stringVar = m.top.findNode("stringVar")
    m.booleanVar = m.top.findNode("booleanVar")
    m.undefinedVar = m.top.findNode("undefinedVar")
    m.booleanSquare = m.top.findNode("booleanSquare")

    m.myLabel.font.size = 88
    m.configData.font.size = 15
    m.variablesData.font.size = 15
    m.featuresData.font.size = 15
    m.resultLabel.font.size = 15
    m.buttonPressedLabel.font.size = 15
    m.jsonVar.font.size = 15
    m.numVar.font.size = 15
    m.booleanVar.font.size = 15
    m.stringVar.font.size = 15
    m.undefinedVar.font.size = 15
    m.myLabel.color = "0x72D7EEFF"

    m.buttonGroup.buttons = [
        "Initialize",
        "Initialize Error",
        "Identify User",
        "Reset User",
        "Get All Features",
        "Get All Variables",
        "Get Variable",
        "Get Variable Value",
        "Track Event"
    ]
    m.buttonGroup.observeField("buttonSelected", "onButtonSelected")
    m.buttonGroup.setFocus(true)

end sub

function onButtonSelected() as Boolean
    buttonIndex = m.buttonGroup.buttonSelected
    if buttonIndex = 0
        m.buttonPressedLabel.text = "Initialize"
        initializeDevCycle()
    else if buttonIndex = 1
        m.buttonPressedLabel.text = "Initialize Error"
        initializeDevCycleError()
    else if buttonIndex = 2
        m.buttonPressedLabel.text = "Identify User"
        if m.devcycleClient <> invalid
        m.devcycleClient.identifyUser({
            user_id: "test_user_identify",
            email: "identify@devcycle.com",
            privateCustomData: {
                orgId: "parthOrg",
                role: "admin"
            }
            })
        end if
    else if buttonIndex = 3
        m.buttonPressedLabel.text = "Reset User"
        if m.devcycleClient <> invalid
            m.devcycleClient.resetUser()
        end if
    else if buttonIndex = 4 
        m.buttonPressedLabel.text = "Get All Features"
        if m.devcycleClient <> invalid
            features = m.devcycleClient.getAllFeatures()
            m.resultLabel.text = "Features: " + FormatJson(features)
        end if
    else if buttonIndex = 5
        m.buttonPressedLabel.text = "Get All Variables"
        if m.devcycleClient <> invalid
            variables = m.devcycleClient.getAllVariables()
            m.resultLabel.text = "Variables: " + FormatJson(variables)
        end if
    else if buttonIndex = 6
        m.buttonPressedLabel.text = "Get Variable"
        if m.devcycleClient <> invalid
            variable = m.devcycleClient.getVariable("example-text", "default value")
            m.resultLabel.text = "Variable: " + FormatJson(variable)
        end if
    else if buttonIndex = 7
        m.buttonPressedLabel.text = "Get Variable Value"
        if m.devcycleClient <> invalid
            value = m.devcycleClient.getVariableValue("example-text", "default value")
            m.resultLabel.text = "Variable Value: " + value
        end if
    else if buttonIndex = 8
        m.buttonPressedLabel.text = "Track Event"
        if m.devcycleClient <> invalid
            m.devcycleClient.track({
                type: "testEvent",
                value: 1
            })
        end if
    end if
    return true
end function

sub displayChangedVariables(event as Object)
    variables = event.getData()
    m.variablesData.text = "Variables: " + FormatJson(variables)
end sub

sub displayChangedFeatures(event as Object)
    features = event.getData()
    m.featuresData.text = "Features: " + FormatJson(features)
end sub

sub initializeDevCycle()
    user = {
        user_id: "test_user_init",
        email: "test_user_init@devcycle.com",
        privateCustomData: {
            orgId: "testOrg"
        }
    }

    sdkKey = "DEVCYCLE_MOBILE_SDK_KEY"

    options = {
        enableEdgeDB: true
    }

    InitializeDevCycleClient(sdkKey, user, options, m.devCycleTask)
    m.devcycleClient = DevCycleSGClient(m.devCycleTask)

    m.devCycleTask.observeField("config", "displayChangedConfig")
    m.devCycleTask.observeField("variables", "displayChangedVariables")
    m.devCycleTask.observeField("features", "displayChangedFeatures")

    m.resultLabel.text = "DevCycle initialized successfully"
end sub

sub initializeDevCycleError()
    user = {
        user_id: "test_user_init",
        email: "test_user_init@devcycle.com",
        privateCustomData: {
            orgId: "testOrg"
        }
    }

    sdkKey = "" ' Empty SDK key to trigger an error

    options = {
        enableEdgeDB: true
    }

    InitializeDevCycleClient(sdkKey, user, options, m.devCycleTask)
    m.devcycleClient = DevCycleSGClient(m.devCycleTask)

    m.devCycleTask.observeField("config", "displayChangedConfig")
    m.devCycleTask.observeField("variables", "displayChangedVariables")
    m.devCycleTask.observeField("features", "displayChangedFeatures")

    m.resultLabel.text = "DevCycle initialization failed (expected error)"
end sub
