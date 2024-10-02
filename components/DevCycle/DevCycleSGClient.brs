sub InitializeDevCycleClient(sdkKey as String, user as Object, options as Object, taskNode as Dynamic) 
    taskNode.sdkKey = sdkKey
    taskNode.user = user
    taskNode.options = options
    taskNode.config = invalid
    taskNode.variables = invalid
    taskNode.features = invalid
end sub

function getRokuTypeForDefault(value as dynamic) as String
    if type(value) = "String"
        return "roString"
    else if type(value) = "Integer"
        return "roInt"
    else if type(value) = "Float"
        return "roFloat"
    else if type(value) = "Boolean"
        return "roBoolean"
    else if type(value) = "roAssociativeArray"
        return "roAssociativeArray"
    else
        return "unknown"
    end if
end function

function getTypeFromRokuType(value as dynamic) as String
    if type(value) = "roString"
        return "String"
    else if type(value) = "roInt" or type(value) = "roLong" or type(value) = "roFloat" or type(value) = "roInteger"
        return "Number"
    else if type(value) = "roBoolean"
        return "Boolean"
    else if type(value) = "roAssociativeArray"
        return "JSON"
    else
        return "unknown"
    end if
end function

function getEvaluatedEvent(variable as Object, defaulted as Boolean)
    variableEventType = "variableDefaulted"
    if NOT defaulted
        variableEventType = "variableEvaluated"
    end if

    event = {
        type: variableEventType,
        target: variable.key,
        value: 1,
        metaData: {
            value: variable.value,
            type: getTypeFromRokuType(variable.value)
        }
    }
    if NOT defaulted 
        event.metaData._variable = variable._id
    end if
    return event
end function

function DevCycleSGClient(taskNode as Object) as Object 
    DevCycleSGClientObject = {
        identifyUser: sub(user as Object)
            m.private.taskNode.user = user
            m.private.taskNode.identifyUser = true
        end sub,

        getAllVariables: function() as Object
            if NOT m.private.taskNode.initialized
                print "Error: DevCycleClient not initialized"
                return invalid
            end if
            return m.private.taskNode.variables
        end function,

        getAllFeatures: function() as Object
            if NOT m.private.taskNode.initialized
                print "Error: DevCycleClient not initialized"
                return invalid
            end if
            return m.private.taskNode.features
        end function,

        resetUser: function() as Object
            m.private.taskNode.resetUser = true
            return m.private.config
        end function,
        
        track: sub(event as Object)
            m.private.taskNode.track = event
        end sub,
        getVariable: function(key as String, default as dynamic) as Object
            variable = m.private.taskNode.config.variables[key]
            defaulted = false
            
            if variable = invalid
                variable = {
                    key: key,
                    value: default,
                    type: Type(default)
                }
                defaulted = true
            end if
            
            m.private.taskNode.track = getEvaluatedEvent(variable, defaulted)
            return variable
        end function,
        getVariableValue: function(key as String, default as dynamic) as Object
            variable = m.private.taskNode.config.variables[key]
            defaulted = false

            if variable = invalid
                variable = {
                    key: key,
                    value: default,
                    type: Type(default)
                }
                defaulted = true
            else
                if type(variable.value) <> getRokuTypeForDefault(default)
                    variable.value = default
                    defaulted = true
                end if
            end if

            m.private.taskNode.track = getEvaluatedEvent(variable, defaulted)
            return variable.value
        end function,
        private: {
            taskNode: taskNode
        }
    }

    return DevCycleSGClientObject
end function
