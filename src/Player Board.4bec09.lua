-- UTILITY FUNCTIONS
function GetCharacterFromGlobal()
    local characters = Global.getTable('Characters')
    assert(characters ~= nil, "Something went wrong in the scripts: global has no characters table loaded")

    assert(characters[CurrentCharacterName]~=nil, CurrentCharacterName .. ": did you change name of a character tile? In that case, please reload and don't change names")
    local current_char = characters[CurrentCharacterName]

    return current_char
end

function LoadCharacter()
    -- Get the character tile from the board
    if CharacterTileZone == nil then
        return
    end
    if CharacterTileZone.getObjects() == nil then
        return
    end
    local current_character_name = nil
    local character_tile = nil
    for _, obj in ipairs(CharacterTileZone.getObjects()) do
        if obj.type == "Tile" and obj.getName() ~= nil then
            character_tile = obj
            current_character_name = character_tile.getName()
            break
        end
    end
    if current_character_name ~= nil then  -- if there is a tile inside
        if CurrentCharacterName == nil then  -- new tile enters
            self.clearButtons()
            CurrentCharacterName = current_character_name
            GenerateCounterButtons()
        end
    else -- no tile on the board
        CurrentCharacterName = nil
        self.clearButtons()
        CreateRandomSelectionButton()
    end
end

-- CREATION FUNCTIONS

function SpawnScriptZones()
    -- spawns the scripting zone, given the variable and the position
    spawnObject({
        type='ScriptingTrigger',
        position = self.getPosition():copy():add(Vector(-2.13, 0.0, 0.61)),
        rotation = self.getRotation(),
        scale = {6.50, 1.50, 6.45},
        callback_function=function(zone)
            CharacterTileZone = zone
        end
    })
    spawnObject({
        type='ScriptingTrigger',
        position = self.getPosition():copy():add(Vector(2.93, 0.0, 1.95)),
        rotation = self.getRotation(),
        scale = {3, 1.00, 4},
        callback_function=function(zone)
            DeckZone = zone
        end
    })
    spawnObject({
        type='ScriptingTrigger',
        position = self.getPosition():copy():add(Vector(2.93, 0.0, -2.19)),
        rotation = self.getRotation(),
        scale = {3, 1.00, 4},
        callback_function=function(zone)
            DiscardPileZone = zone
        end
    })
end

function GenerateCounterButtons()
    -- Load button parameters into tables for button creation
    local character = GetCharacterFromGlobal()

    local button_background_color = {0.0, 0.0, 0.0}
    local button_scale = {0.3, 1.0, 0.5}

    -- Value button parameters (this is what shows the current LifePointsCount)

    local counter_button_size = 400
    local counter_button_horizontal_position = -0.4   -- Negative for left, positive for right
    local counter_button_vertical_position = 1.2   -- Negative for up, positive for down
    CounterFontSize = counter_button_size * 0.7

    -- small buttons parameters
    local small_button_scale_ratio = 0.6
    local small_button_horizontal_offset = counter_button_size * 0.0005
    local small_button_vertical_offset = -0.0

    CounterButtonParams = {
        index = 0, click_function='BroadcastValue', function_owner = self, label = tostring(character.current_life_points),
        position = {
            counter_button_horizontal_position,
            1.0,
            counter_button_vertical_position,
        },
        width = counter_button_size, height = counter_button_size, scale=button_scale,
        color = button_background_color, font_color = {1.0, 1.0, 1.0},
        font_size = (character.current_life_points >= 0 and character.current_life_points <= 9) and CounterFontSize or CounterFontSize*0.8
    }

    local counter_margin = 0.04

    -- Create buttons
    self.createButton(CounterButtonParams)
    self.createButton({
        function_owner = self, click_function = 'AddOne', label = '+1',
        position = {
            CounterButtonParams.position[1] + counter_margin + small_button_horizontal_offset,
            CounterButtonParams.position[2],
            CounterButtonParams.position[3] + small_button_vertical_offset,
        },
        width = CounterButtonParams.width * small_button_scale_ratio,
        height = CounterButtonParams.height * small_button_scale_ratio, scale=button_scale,
        color = button_background_color, font_color = {0.7, 1.0, 0.7},
        font_size = CounterFontSize*small_button_scale_ratio
    })
    self.createButton({
        function_owner = self, click_function = 'SubtractOne', label = '-1',
        position = {
            CounterButtonParams.position[1]  - counter_margin - small_button_horizontal_offset,
            CounterButtonParams.position[2],
            CounterButtonParams.position[3] + small_button_vertical_offset,
        },
        width = CounterButtonParams.width * small_button_scale_ratio,
        height = CounterButtonParams.height * small_button_scale_ratio, scale=button_scale,
        color = button_background_color, font_color = {1.0, 0.7, 0.7},
        font_size = CounterFontSize*small_button_scale_ratio
    })
    self.createButton({
        function_owner = self, click_function = 'AddFive', label = '+5',
        position = {
            CounterButtonParams.position[1] + 2*small_button_horizontal_offset,
            CounterButtonParams.position[2],
            CounterButtonParams.position[3] + small_button_vertical_offset,
        },
        width = CounterButtonParams.width * small_button_scale_ratio,
        height = CounterButtonParams.height * small_button_scale_ratio, scale=button_scale,
        color = button_background_color, font_color = {0.0, 1.0, 0.0},
        font_size = CounterFontSize*small_button_scale_ratio
    })
    self.createButton({
        function_owner = self, click_function = 'SubtractFive', label = '-5',
        position = {
            CounterButtonParams.position[1] - 2*small_button_horizontal_offset,
            CounterButtonParams.position[2],
            CounterButtonParams.position[3] + small_button_vertical_offset,
        },
        width = CounterButtonParams.width * small_button_scale_ratio,
        height = CounterButtonParams.height * small_button_scale_ratio, scale=button_scale,
        color = button_background_color, font_color = {1.0, 0.0, 0.0},
        font_size = CounterFontSize*small_button_scale_ratio
    })
end

function CreateShuffleButton()
    self.createButton({
        function_owner = self, click_function = 'ShuffleDiscardPile', label = 'Shuffle\nDeck',
        position = {0.55, 1.1, -0.3}, width = 500, height = 500, scale={0.3, 1.0, 0.4},
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 120,
        tooltip='Shuffle discard pile and recreate your deck'
    })
end

function CreateRandomSelectionButton()
    self.createButton({
        function_owner = self, click_function = 'RandomlySelectCharacter', label = 'Select a\nrandom\ncharacter',
        position = {-0.4, 1.1, 0.3}, width = 700, height = 700, scale={0.3, 1.0, 0.4},
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 120,
        tooltip='Select a random character'
    })
end

-- BUTTON FUNCTIONS

function RandomlySelectCharacter()
    -- select the character
    local characters = Global.getTable('Characters')
    local free_characters = {}
    local index = 0
    for name, character in pairs(characters) do
        if character.selected == false and getObjectFromGUID(character.tile_guid) ~= nil then
            index = index + 1
            table.insert(free_characters, index, name)
        end
    end
    if #free_characters < 1 then
        broadcastToAll('There are no characters available in the table of characters in the script. Start over.')
    else
        local selected_index = math.random(#free_characters)
        local selected_character_name = table.remove(free_characters, selected_index)

        -- get the tile and move it on the player board
        local tile = getObjectFromGUID(characters[selected_character_name].tile_guid)
        tile.setPosition(CharacterTileZone.getPosition():copy():add(Vector(0, 1.0, 0)))
        if math.random(2) == 1 then tile.flip() end
        local selected_sex = tile.is_face_down and 'female' or 'male'
        print('Selected: ' .. tostring(selected_character_name) .. ' ' .. selected_sex .. ' version.')
    end
end

function ShuffleDiscardPile()
    if DiscardPileZone == nil or DeckZone == nil then
        return
    elseif DiscardPileZone.getObjects() == nil then
        return
    elseif  #DiscardPileZone.getObjects() == 1 then
        return
    else
        local discard_pile = nil
        -- get discard pile object
        for _, obj in ipairs(DiscardPileZone.getObjects()) do
            if obj.type == "Deck" then
                discard_pile = obj
                break
            end
        end
        if not discard_pile.is_face_down then discard_pile.flip() end
        discard_pile.shuffle()
        discard_pile.setPosition(DeckZone.getPosition())
        -- get button to removeButton
        for _, button in ipairs(self.getButtons()) do
            if button.click_function == "ShuffleDiscardPile" then
                self.removeButton(button.index)
                break
            end
        end
    end
end

function AddOne()
    -- Add 1 to the character.current_life_points and update the value button
    local character = GetCharacterFromGlobal()
    character.current_life_points = math.min(character.current_life_points + 1, character.max_life)
    UpdateValues(character)
end

function SubtractOne()
    -- Subtract 1 from the character.current_life_points and update the value button
    local character = GetCharacterFromGlobal()
    character.current_life_points = math.max(character.current_life_points - 1, 0)
    UpdateValues(character)
end

function AddFive()
    -- Add 5 to the character.current_life_points and update the value button
    local character = GetCharacterFromGlobal()
    character.current_life_points = math.min(character.current_life_points + 5, character.max_life)
    UpdateValues(character)
end

function SubtractFive()
    -- Subtract 5 from the character.current_life_points and update the value button
    local character = GetCharacterFromGlobal()
    character.current_life_points = math.max(character.current_life_points - 5, 0)
    UpdateValues(character)
end

function UpdateValues(character)
    -- Update the value button according to the current character.current_life_points
    CounterButtonParams.font_size = (
        (character.current_life_points >= 0 and character.current_life_points <= 9) and CounterFontSize or CounterFontSize*0.8
    )
    CounterButtonParams.label = tostring(character.current_life_points)
    self.editButton(CounterButtonParams)

    -- Update characters table
    local updated_table = Global.getTable('Characters')
    updated_table[CurrentCharacterName] = character
    Global.setTable('Characters', updated_table)
end

function BroadcastValue()
    -- Writes the current health point of the characters
    local character = GetCharacterFromGlobal()
    broadcastToAll(getObjectFromGUID(character.tile_guid).getName() .. " has " .. character.current_life_points .. " health points left.")
end

function SetSnapPoints()
    -- local first_defense_snap = {position = DeckZone.getPosition(), rotation = self.getRotation(), rotation_snap = true}
    -- local first_monster_snap = {position = DiscardPileZone.getPosition(), rotation = self.getRotation(), rotation_snap = true}
    -- local snaps = {}
    -- table.insert(snaps, 1, first_defense_snap)
    -- table.insert(snaps, 2, first_monster_snap)
    -- local defense_offset = Vector(-1.5, 0, 0)
    -- local monster_offset = Vector(-3, 0, 0)
    -- -- for i = 2, 4 do
    -- --     local current_defense_snap = first_defense_snap
    -- --     local current_position = current_defense_snap.position:copy():add(defense_offset)
    -- --     current_defense_snap.position = current_position
    -- --     table.insert(snaps, i, current_defense_snap)

    -- --     local current_monster_snap = first_monster_snap
    -- --     current_position = current_monster_snap.position:copy():add(monster_offset)
    -- --     current_monster_snap.position = current_position
    -- --     table.insert(snaps, i, current_monster_snap)
    -- -- end
    -- self.setSnapPoints({table.unpack(self.getSnapPoints()), table.unpack(snaps)})
end


-- TABLETOP FUNCTIONS

function onLoad()
    if Global.getVar('PlayersSelected') then
        SpawnScriptZones()
        Wait.frames(LoadCharacter, 30)
        Wait.frames(SetSnapPoints, 30)
    end
end

function onObjectEnterZone(zone, object)
    if zone == CharacterTileZone then
        local characters = Global.getTable('Characters')
        for char_name, _ in pairs(characters) do
            if object.getName() == char_name then
                characters[char_name].selected = true
                Global.setTable('Characters', characters)
                LoadCharacter()
                break
            end
        end
    end
end

function onObjectLeaveZone(zone, object)
    if zone == CharacterTileZone then
        local characters = Global.getTable('Characters')
        for char_name, _ in pairs(characters) do
            if object.getName() == char_name then
                characters[char_name].selected = false
                Global.setTable('Characters', characters)
                break
            end
        end
        LoadCharacter()
    elseif zone == DeckZone then
        if #DeckZone.getObjects() == 1 and DeckZone.getObjects()[1].getName() == 'Player Board' then
            CreateShuffleButton()
        end
    end
end