getgenv().Websyn = {}


function Websyn.create(options)
    local self = {
        port = options.port or "8000",
        splitter = options.splitter or "|",

        _setupListener = Websyn._setupListener,
        _setupSocket = Websyn._setupSocket
    }

    self:_setupSocket()
    self:_setupListener()

    return self.listener, self.socket
end

function Websyn:_setupSocket()
    local ws = syn.websocket.connect(string.format("ws://websocket:%s", self.port))
    local sckt = {}

    function sckt.Send(_, ...)
        local message = table.concat({...}, self.splitter)
        ws:Send(message)
    end

    self.socket = sckt
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

    self.socket.OnMessage:Connect(received)
    self.listener = lstnr
end


local listener, socket = Websyn.create({
    port = "8023", --  default: "8000"
    splitter = "__", -- default: "|"
})

listener.TestEvent:Connect(function(...)
    for _,v in next, {...} do
        print(v)
    end
end)

socket:Send("ServerEvent", "aids", "testicles")