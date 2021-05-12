--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]
Market = getObjectFromGUID('33133e')
Players = {}


function SetupPlayers(num_players)
    UI.hide('welcome_panel')
    PlayersSelected = true

    -- declare a table of all possible players
    local colors = Player.getAvailableColors()

    -- sort players prioritizing the seated ones
    table.sort(colors, function(a, b) return Player[a].seated end)

    -- set the starting position
    local initial_position = {
        position = Vector(0, 5, -50),
        rotation = Vector(0, 360, 0),
        scale    = Vector(12.00, 12.00, 7.00),
    }

    -- starting board and deck available and moved on the side
    local board = getObjectFromGUID('4bec09')
    board.setPosition({-40.00, 1.00, 20.00})
    local starting_deck = getObjectFromGUID('fc501f')
    starting_deck.setPosition({-40.00, 1.00, 18.00})

    local angle_step = (num_players%2==0 and 180 or 120) / num_players
    local vertical_offset = 20

    -- loop through the player hands, relocating them based on the number of players
    local fixed_players = 0
    for i, color in ipairs(colors) do
        if fixed_players < num_players then
            local swap_direction = i%2==0 and 1 or -1
            -- the final result should be a displacement of (-2, -1, 0, 1, 2) or (-2, -1, 0, 0, 1, 2)
            local player_ratio = num_players%2==0 and (
                i%2==0 and math.floor((i-1)/2) or math.floor(i/2)) or ( -- if players are even
                    math.floor(i/2) -- if players are odd
                )

            local rotation_angle = 0 -- player_ratio * swap_direction * angle_step
            local horizontal_offset = -swap_direction * (num_players%2==0 and 5 or 2)
            local rotate_over_angle = player_ratio * swap_direction * angle_step

            -- horrible way to handle special cases
            if num_players%2==0 then
                if i==1 or i==2 then
                    horizontal_offset = -swap_direction*10
                end
                if (i==3 or i==4) and num_players==4 then
                    horizontal_offset = swap_direction*5
                end
                if i==5 or i==6 then
                    horizontal_offset = swap_direction*2
                end
            end

            -- print(tostring(i) .. ' ' .. tostring(horizontal_offset))

            -- move the hand-zone and the player board with all details based on the rotation
            local transform = {
                position = initial_position.position:copy():rotateOver('y', rotate_over_angle):add(Vector(horizontal_offset, 0, vertical_offset)),
                rotation = initial_position.rotation:copy():add(Vector(0, rotation_angle, 0)),
                scale    = initial_position.scale
            }
            Player[color].setHandTransform(transform)
            fixed_players = fixed_players + 1

            -- get a copy of the board
            local current_board = board.clone()
            local board_position = transform.position:add(Vector(0,0,10)) --moveTowards(Vector(0, 0, 20), 10.0)
            current_board.setPosition({board_position[1], 1.0, board_position[3]})
            -- current_board.setRotation(transform.rotation:add(Vector(0, 180, 0)))

            -- get a copy of the starting deck
            local current_deck = starting_deck.clone()
            current_deck.shuffle()
            local deck_position = board_position:copy():add(current_deck.positionToWorld(Vector(2.43, 0.0, -1.69)))
            current_deck.setPosition({deck_position[1], 1.0, deck_position[3]})

        else
            Player[color].setHandTransform({
                position = initial_position.position,
                rotation = initial_position.rotation,
                scale    = initial_position.scale,
            })
        end
    end
    board.destruct()
    starting_deck.destruct()
end

function TwoPlayers() SetupPlayers(2) end
function ThreePlayers() SetupPlayers(3) end
function FourPlayers() SetupPlayers(4) end
function FivePlayers() SetupPlayers(5) end
function SixPlayers() SetupPlayers(6) end


function onSave()
    if GameStarted then -- worth to save only if game is started
        local data_to_save = {
            game_started = GameStarted,
            characters = Characters
        }
        SavedData = JSON.encode(data_to_save)
        return SavedData
    end
end

function onLoad(saved_data)
    if saved_data ~= '' then
        local loaded_data = JSON.decode(saved_data)
        PlayersSelected = loaded_data.game_started
        MarketStarted = loaded_data.game_started
        GameStarted = loaded_data.game_started
        Characters = loaded_data.characters
    else
        PlayersSelected = false -- if set, the players tiles are selected and placed on the playerboards
        MarketStarted = false -- if set, the market is ready to be used
        GameStarted = false -- if set, the game is ready to be played
        Characters = {
            Barbarian = {current_life_points = 45, max_life = 45, selected=false, tile_guid='5e201a'},
            Dwarf = {current_life_points = 45, max_life = 45, selected=false, tile_guid='7e5c84'},
            Elf = {current_life_points = 35, max_life = 35, selected=false, tile_guid='d24fae'},
            Mage = {current_life_points = 30, max_life = 30, selected=false, tile_guid='29a29b'},
            Warrior = {current_life_points = 40, max_life = 40, selected=false, tile_guid='1cbcd9'},
            Paladin = {current_life_points = 40, max_life = 40, selected=false, tile_guid='ebc562'},
            Cleric = {current_life_points = 35, max_life = 35, selected=false, tile_guid='5c2f72'},
            Druid = {current_life_points = 30, max_life = 30, selected=false, tile_guid='a11911'},
            Thief = {current_life_points = 35, max_life = 35, selected=false, tile_guid='f8b21a'},
            Slayer = {current_life_points = 40, max_life = 40, selected=false, tile_guid='0c6550'},
            DarkElf = {current_life_points = 35, max_life = 35, selected=false, tile_guid='0a23bf'},
            RedMage = {current_life_points = 35, max_life = 35, selected=false, tile_guid='79e8f1'},
            Necromancer = {current_life_points = 30, max_life = 30, selected=false, tile_guid='d3a57c'},
        }
    end
    if not GameStarted then
        UI.show('welcome_panel')
    end
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    -- should happen only once when START button is pressed.
    if MarketStarted and not GameStarted then
        GameStarted = true
        local tokens_zone = getObjectFromGUID('1e4e11')
        local index = 0
        for _, character in pairs(Characters) do
            local character_tile = getObjectFromGUID(character.tile_guid)
            local token = nil
            -- search for token
            for _, object in ipairs(tokens_zone.getObjects()) do
                if object.getName() == character_tile.getName() then
                    token = object
                    break
                end
            end
            if character.selected then -- move the characters tokens
                character_tile.setLock(true)
                token.setPosition(character_tile.getPosition():copy():add(Vector(-2.95, 1, -2.95)))
            else -- move the unused ones
                index = index + 1
                character_tile.setPosition({-50.00, 1.00 + index, 32.00})
                token.setPosition({-48.00, 1.00 + index, 36.00})
            end
        end
        tokens_zone.destruct()
        -- move characters picker out
        getObjectFromGUID('e6589a').setPosition({-40.00, 1.00, 32.00})
    end
end