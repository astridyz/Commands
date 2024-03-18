# Commands package
Utility package for creating commands using Discordia-slash

## Info
This package depends on Discordia-slash and Discordia.
It doesn't use Discordia Classes.
It doesn't work without a command handler. It just supports the command creation process

## Usage
In your command.lua

```lua
local Command = require('../packages/astrid_commands@0.0.1')
local Ping = Command('Ping', 'Useful for tests I think')

Ping:setCallback(function(interaction, args)
    print('Command callback!')
end)

Ping:setCategory('Useful')

return Ping
```

In your main.lua

```lua
-- Require the command using its name and call it as a function using the metamethod __call

local function commandsCallback(interaction, command, args)
    commands[command.name](interaction, args)
end

-- Client configs
Client:on('slashCommand', commandsCallback)
```

[More examples on my bot's repository](https://github.com/astridyz/Luthe-discord-bot)