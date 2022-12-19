const WebSocket = require('ws');

class Websyn {
    constructor(port = 8000) {
        this.clients = {};
        this.registry = {};
        this.server = new WebSocket.Server({ port: port });
        this.server.on('connection', client => this._onConnection(client));
    }

    _onConnection(client) {
        client.on('message', bufferMessage => {
            const message = bufferMessage.toString();
            const split = message.split("__!!");  
            const protocol = split[0];
            
            // Initialize username ID
            if (protocol == "_init_DONT_USE") {
                const [ _, sender ] = split;
                console.log(`Initializing ${sender}...`);
                this.clients[sender] = client;
            }

            // Initialize SendTo
            if (protocol == "_sendingTo_DONT_USE" && this.clients[split[1]]) {
                const [ _, receiver, sender, eventName, ...rest ] = split;
                const sending = [eventName, sender, ...rest ].join("__!!");
                this.clients[receiver].send(sending);
            }

            // Initialize event callbacks
            if (this.registry[protocol]) {
                const [ _, sender, ...args ] = split;
                this.registry[protocol](sender, ...args);
            }
        })
    }

    connect(event, callback) {
        this.registry[event] = callback;
    }
}

// const handler = new Websyn();

// handler.connect('Shit', (username, ...args) => {
//     console.log(`${args} send by ${username}`);
// });

module.exports = Websyn;