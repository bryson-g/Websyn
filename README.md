# Websyn
An easy to use event based system for Synapse webhooks.
I created this for myself, so I probably won't be fixing any bugs or adding features unless I personally need to.
Feel free to fork and modify it however you'd like to.

## Installation
Node.js
```bash
npm i https://github.com/bryson-g/Websyn.git
```

Lua
```lua
local websyn = loadstring(game:HttpGet('https://raw.githubusercontent.com/bryson-g/Websyn/main/rbx-counterpart/client.lua'))()
```

## Known issues that I'm not going to patch:
 - Calling websyn.create too fast (like autoexec) will cause an error (synapse issue)

## Usage
### Example #1: Server log arguments:

Node.js (server)
```js
const websyn = require('websyn');

const handler = new websyn(8000); // Optional socket parameter, default is 8000

// Username of the sender will always be the first parameter
handler.connect('EventNameHere', (username, ...args) => {
    console.log(`${username} has triggered this event`);
    console.log(args);
    // Expected output: ['hello', 'goodbye']
});
```

Lua (client)
```lua
local websyn = loadstring(game:HttpGet('https://raw.githubusercontent.com/bryson-g/Websyn/main/rbx-counterpart/client.lua'))()

local listener, server = websyn.create("8000") -- Optional socket parameter, default is 8000

server.EventNameHere:Send('hello', 'goodbye');
```
