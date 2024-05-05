local Discordia = require('discordia')

local Discordia_slash = require('discordia-slash')
local Constructors = Discordia_slash.util.tools()

local enums = Discordia.enums

local Command = Discordia.class('Command')
Command.categories = {}
Command.commands = {}

--
--- @author https://github.com/astridyz
--- Discordia package to help creating commands
--
--- @class Command A command class
--- @class Slash-command A slash-command class created by discordia-slash constructor
--- @class Option Slash command class. It's an option of the slash-command

--- Process of creating a command. After that, you'll need to set-up some settings of it
--- @param name string The name of the command
--- @param description string The description of the command
--
function Command:__init(name, description)
    assert(name ~= nil, 'Insert a name for the command')
    assert(description ~= nil, 'Insert a description')
    name = string.lower(name)

    self._name = name
    self._description = description
    self._settings = Constructors.slashCommand(name, description)

    Command.commands[name] = self
end

--- @description It'll check the permissions set by setPermissions method
--- and then call the callback.
--
function Command:callback(interaction, args)
    assert(self._callback ~= nil, 'Attempt to callback the command ' .. self._name .. ' without setting a callback')

    if not self._permissions then --// If there's no permissions needed, just skip it
        self._callback(interaction, args)
        return
    end

    local member = interaction.member

    for _, permission in ipairs(self._permissions) do

        if member:hasPermission('administrator') then --// Some checkings
            break --// Breaking the loop will call the callback
        end

        if member.user.id == member.guild.ownerId then
            break
        end
        
        if not member:hasPermission(permission) then
            interaction:reply('You dont have enough permissions.')
            return --// Returning the function  won't call the callback
        end
    end

    self._callback(interaction, args)
end

--// Setters

--- Function to set the command reply.
--- @param callback function The function we'll call when the command is used
--
function Command:setCallback(callback)
    assert((type(callback) == "function"), 'Insert a function')

    self._callback = callback
    return true
end

--- @param category string? The category of the command. It'll be stored in a cache variable.
--
function Command:setCategory(category)
    assert(category ~= nil, 'Insert a category.')
    assert(not self._category, 'Attempt to change the category 2 times')

    category = string.lower(category)

    self._category = category

    if not Command.categories[category] then
        table.insert(Command.categories, category)
    end

    return true
end

---@param option Option The option to add in the slash command
--
function Command:addSlashOption(option)
    self._settings:addOption(option)
end

--- @param ... string The permissions needed to use this command.
--
function Command:setPermissions(...)
    local permissions = {...}

    for _, perm in ipairs(permissions) do
        assert(enums.permission[perm] ~= nil)
    end

    self._permissions = permissions
end

--// Getters 

--- @return string self._description Returns the description of the command
--
function Command:getDescription()
    return self._description
end

--- @return string self._name Returns the description of the command
--
function Command:getName()
    return self._name
end

--- @return Slash-command self._settings Returns the slash command using the constructor of discordia-slash
--
function Command:getSlash()
    assert(self._settings ~= nil, 'The command ' .. self._name .. ' doesnt have any settings')
    return self._settings
end

--- @return string self._category Returns the category of the command
--
function Command:getCategory()
    assert(self._category ~= nil, 'The command ' .. self._name .. ' doesnt have a category')
    return self._category
end

--// Module getters

--- @return boolean Command Returns the command if it exists or false if it doesn't
--
function Command.get(command)
    return Command.commands[command] or false
end

return Command