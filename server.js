const WebSocket = require('ws');

class Websyn {
    constructor(port = 8000) {
        this.clients = {};
        this.registry = {};
        this.remove_registry = {};

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
                //console.log(`Initializing ${sender}...`);
                this.clients[sender] = client;
            }

            // Initialize SendTo
            if (protocol == "_sendingTo_DONT_USE" && this.clients[split[1]]) {
                const [ _, receiver, sender, eventName, ...rest ] = split;
                const sending = [eventName, sender, ...rest ].join("__!!");
                this.clients[receiver].send(sending);
                
            }

            // Initialize event callbacks
            const registry = this.registry[protocol];
            if (registry) {
                const [ _, sender, ...args ] = split;

                for (const callback of registry) {
                    callback(sender, ...args);
                }

                const removeRegistry = this.remove_registry[protocol] || [];

                for (const callback of removeRegistry) {
                    registry.splice(registry.indexOf(callback), 1);
                }
                this.remove_registry[protocol] = [];
            }
        })
    }

    connect(event, callback) {
        if (!this.registry[event]) {
            this.registry[event] = [];
        }
        this.registry[event].push(callback);
        
        let db = false;
        return () => {
            if (db) throw 'Cannot disconnect multiple times.';
            db = true;

            if (!this.remove_registry[event]) {
                this.remove_registry[event] = [];
            }
            this.remove_registry[event].push(callback);
        };
    }

    once(event, callback, timeout) { // integrate timeout cuz if the join fails, the event may never be ran.
        this.connect(event, callback);
        
        if (!this.remove_registry[event]) {
            this.remove_registry[event] = [];
        }

        this.remove_registry[event].push(callback);
    }

    send(data) {
        const message = [data.event, ...(data.args || [])].join("__!!");
        console.log(message);
        this.clients[data.username].send(message);
    }
}

module.exports = Websyn;