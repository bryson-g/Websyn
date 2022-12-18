local Players = game:GetService("Players")

getgenv().Websyn = {}

local function getClient()
    if Players.LocalPlayer then
        return Players.LocalPlayer
    else
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        return Players.LocalPlayer
    end
end


function Websyn.create(port)
    local self = {
        port = port or "8000",
        splitter = "__!!",

        _setupListener = Websyn._setupListener,
        _setupSocket = Websyn._setupSocket
    }

    self:_setupSocket()
    self:_setupListener()

    return self.listener, self.socket
end

function Websyn:_setupListener()
    local lstnr, i; lstnr = setmetatable({}, {
        __index = function(t,k)
            i = k
            return lstnr.registry
        end
    })

    lstnr.registry = {
        Connect = function(registry, callback)
            if not registry[i] then
                registry[i] = {}
            end
            table.insert(registry[i], callback)
        end
    }

    local function received(message)
        local args = string.split(message, self.splitter)
        if lstnr.registry[args[1]] then
            local event = table.remove(args, 1)
            for _,callback in next, lstnr.registry[event] do
                coroutine.wrap(callback)(unpack(args))
            end
        end
    end

    self.socket.real.OnMessage:Connect(received)
    self.listener = lstnr
end

function Websyn:_setupSocket()
    local ws, i = syn.websocket.connect(string.format("ws://localhost:%s", self.port))
    local sckt; sckt = setmetatable({real=ws}, {
        __index = function(t,k)
            i=k
            return sckt
        end
    })

    function sckt.Send(_, ...)
        local username = getClient().Name
        local message = table.concat({i, username, ...}, self.splitter)
        ws:Send(message)
    end

    function sckt.SendTo(_, receiver, ...)
        local username = getClient().Name
        local message = table.concat({"_sendingTo_DONT_USE", receiver, username, i, ...}, self.splitter)
        ws:Send(message)
    end

    sckt._init_DONT_USE:Send()
    self.socket = sckt
end

-- example code

local listener, socket = Websyn.create("8000")

listener.Shit:Connect(function(...)
    for _,v in next, {...} do
        print(_, v)
    end
end)

socket.Shit:SendTo('barjalemuel', 'aids', 'monkey')