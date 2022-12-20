# Websyn
An easy to use system for Synapse webhooks.
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

## Usage

Node.js
```js
const websyn = require('websyn');

const socket = 8000
const handler = new websyn(socket); // Default socket is 8000

handler.connect('EventNameHere', username => {
    console.log(`${username} has sent this event`);
});
```

Lua
```lua
local websyn = loadstring(game:HttpGet('https://raw.githubusercontent.com/bryson-g/Websyn/main/rbx-counterpart/client.lua'))()

local listener, socket = websyn.create("8000") // Default socket is 8000

```
