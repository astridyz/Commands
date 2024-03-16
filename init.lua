local Discordia = require('discordia')

local Discordia_slash = require('discordia-slash')
local Constructors = Discordia_slash.util.tools()

local Command = {} -- Private
local Prototype = {} -- Public
Command.commands = {}

--
--- @author https://github.com/astridyz
--- Discordia package to help creating commands
--- It doesnt use discordia classes. I didnt like it
--
--- @class Command A command class
--- @class Slash-command A slash-command class created by discordia-slash constructor

--- Process of creating a command. After that, you'll need to set-up some settings of it
--- @param name string The name of the command
--- @param description string The description of the command
--- @return Command self Return the command
--
function Command.__create(_, name, description)

    assert(name ~= nil, 'Insert a name for the command')
    assert(description ~= nil, 'Insert a description')
    name = string.lower(name)

    local self = {}
    local Meta = {__index = Prototype}

    self.name = name
    self.description = description
    self._settings = Constructors.slashCommand(name, description)

    Command.commands[name] = self
    return setmetatable(self, Meta)
end

--- @param func function The function we'll call when the command is used
--
function Prototype:setCallback(func)
    local Meta = getmetatable(self)
    Meta.__call = func
    Meta.__metatable = 'locked'
end

--- @param category string? The category of the command. It'll be useful to the help commands
--
function Prototype:setCategory(category)
    self._category = category
end

-- Getters 

--- @return Slash-command self._settings return the slash command using the constructor of discordia-slash
--
function Prototype:getConfigs()
    assert(self._settings ~= nil, 'The command ' .. self.name .. ' doesnt have any settings')
    return self._settings
end

--- @return string self._category return the category of the command
--
function Prototype:getCategory()
    assert(self._category ~= nil, 'The command ' .. self.name .. ' doesnt have an category')
    return self._category
end

--- @param name string Name of the command. It'll try to look at the cache to find this command
--- @return Command|boolean -- Returning the command if it exists, returning false if it doesnt
--
function Prototype.get(name)
    return Command.commands[name] or false
end

return setmetatable(Command, {__call = Command.__create, __metatable = 'locked'})