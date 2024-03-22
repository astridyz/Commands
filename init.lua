local Discordia = require('discordia')

local Discordia_slash = require('discordia-slash')
local Constructors = Discordia_slash.util.tools()

local enums = Discordia.enums

local Command = {} -- Private
local Command_prototype = {} -- Public
Command.categories = {}
Command.commands = {}

--
--- @author https://github.com/astridyz
--- Discordia package to help creating commands
--- It doesnt use discordia classes. I didnt like it
--
--- @class Command A command class
--- @class Slash-command A slash-command class created by discordia-slash constructor
--- @class Option Slash command class. It's an option of the slash-command

--- Process of creating a command. After that, you'll need to set-up some settings of it
--- @param name string The name of the command
--- @param description string The description of the command
--- @return Command self Return the command
--
function Command.create(_, name, description)

    assert(name ~= nil, 'Insert a name for the command')
    assert(description ~= nil, 'Insert a description')
    name = string.lower(name)

    local self = {}
    local Meta = {__index = Command_prototype}

    self.name = name
    self.description = description
    self.settings = Constructors.slashCommand(name, description)

    Command.commands[name] = self
    return setmetatable(self, Meta)
end

--- Function to set the command reply. It'll check the permissions set by setPermissions method
--- @param callback function The function we'll call when the command is used
--
function Command_prototype:setCallback(callback)
    assert((type(callback) == "function"), 'Insert a function')
    local Meta = getmetatable(self)

    Meta.__call = function(_, interaction, args)

        local member = interaction.member

        for _, permission in ipairs(self.permissions) do
            -- Some checkings
            if member:hasPermission('administrator') then break end
            if member.user.id == member.guild.ownerId then break end -- Breaking the loop will call the callback
            
            if not member:hasPermission(permission) then
                interaction:reply('You dont have enough permissions.')
                return -- Returning the function  won't call the callback
            end
        end

        callback(interaction, args)
    end

    Meta.__metatable = 'locked'
    return true
end

--- @param category string? The category of the command. It'll be stored in a cache variable.
--
function Command_prototype:setCategory(category)
    assert(category ~= nil, 'Insert a category.')
    assert(not self.category, 'Attempt to change the category 2 times')

    category = string.lower(category)

    self.category = category

    if not Command.categories[category] then
        table.insert(Command.categories, category)
    end

    return true
end

---@param option Option The option to add in the slash command
--
function Command_prototype:addSlashOption(option)
    self.settings:addOption(option)
end

--- @param ... string The permissions needed to use this command.
--
function Command_prototype:setPermissions(...)
    local permissions = {...}

    for _, perm in ipairs(permissions) do
        assert(enums.permission[perm] ~= nil)
    end

    self.permissions = permissions
end


-- Getters 

--- @return Slash-command self._settings return the slash command using the constructor of discordia-slash
--
function Command_prototype:getSlash()
    assert(self.settings ~= nil, 'The command ' .. self.name .. ' doesnt have any settings')
    return self.settings
end

--- @return string self._category return the category of the command
--
function Command_prototype:getCategory()
    assert(self.category ~= nil, 'The command ' .. self.name .. ' doesnt have an category')
    return self.category
end

--- @param name string Name of the command. It'll try to look at the cache to find this command
--- @return Command|boolean -- Returning the command if it exists, returning false if it doesnt
--
function Command_prototype.get(name)
    return Command.commands[name] or false
end

return setmetatable(Command, {__call = Command.create, __metatable = 'locked'})