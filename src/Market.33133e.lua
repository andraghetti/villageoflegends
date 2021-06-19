------------- MARKET FUNCTIONS --------------

-- Table to store the names of the added expansions
AddedExpansions = {'Base Game'}

function zip(...)
    -- Python-like zip() iterator
    local arrays, ans = {...}, {}
    local index = 0
    return
    function()
        index = index + 1
        for i,t in ipairs(arrays) do
            if type(t) == 'function' then ans[i] = t() else ans[i] = t[index] end
            if ans[i] == nil then return end
        end
        return unpack(ans)
    end
end

function GetDeckFromZone(zone)
    for _, obj in ipairs(zone.getObjects()) do --returns the zone object table in the for each/pairs loop
        if obj.type == "Deck" then --if the object has the deck type
            return obj
        end
    end
end

function RemoveButton(button_function_name)
    if self.getButtons() ~= nil then
        for _, button in ipairs(self.getButtons()) do
            if button.click_function == button_function_name then
                if button.index ~= nil then
                    self.removeButton(button.index)
                end
            end
        end
    end
end

-- CREATION FUNCTIONS

function CreateRefillButton()
    self.createButton({
        function_owner = self, click_function = 'RefillCards', label = 'Refill\nMarket',
        position = {0.0, 1.0, 1.7}, width = 250, height = 250, scale={0.3, 1.0, 0.4},
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 60,
        tooltip = "Refill the market in case some cards have been bought"
    })
end

function CreateStartButton()
    self.createButton({
        function_owner = self, click_function = 'StartMarket', label = 'Start',
        position = {0.0, 1.0, 3.0}, width = 700, height = 300, scale={0.3, 1.0, 0.4},
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 200,
        tooltip="Once you added the expansions to the game you can click here to shuffle the market's decks and deal the cards."
    })
end

function SpawnZones(decks)
    local CardZones = {}
    for key, deck in pairs(decks) do
        spawnObject({
            type='ScriptingTrigger',
            position = deck.getPosition(),
            scale = {deck.getBounds().size[1], 5, deck.getBounds().size[3]},  -- for safety, we get a very tall size for big decks.
            callback_function=function(zone)
                CardZones[key] = zone
            end
        })
    end
    return CardZones
end

-- BUTTONS FUNCTIONS

function StartMarket()
    -- Shuffle decks
    broadcastToAll(string.format("Starting a new game with %s!\nHave fun!", table.concat(AddedExpansions," + ")))

    -- Enable right OnLoad function
    for _, zone in pairs(MarketDeckZones) do
        GetDeckFromZone(zone).shuffle()
    end

    -- Remove buttons
    self.clearButtons()

    -- Create refill button
    CreateRefillButton()

    -- Fill the market
    Wait.frames(RefillCards, 5)

    -- Remove unused decks
    Wait.frames(function ()
        for _, object in ipairs(getObjectFromGUID('bf1b6a').getObjects()) do object.destruct() end
        for _, object in ipairs(getObjectFromGUID('5ba021').getObjects()) do object.destruct() end
        for _, object in ipairs(getObjectFromGUID('3bd743').getObjects()) do object.destruct() end
    end, 5)

    -- Remove scripting zones
    Wait.frames(function ()
        getObjectFromGUID('bf1b6a').destruct()
        getObjectFromGUID('5ba021').destruct()
        getObjectFromGUID('3bd743').destruct()
    end, 5)

    Global.setVar('MarketStarted', true)
end

function RefillCards()
    -- Remove this same button to prevent other actions to start
    RemoveButton('RefillCards')

    -- Actual refill
    local main_deck = GetDeckFromZone(MarketDeckZones.main)
    local added_cards = 0
    for _, zone in pairs(EmptyMarketZones) do
        if #zone.getObjects() == 1 and zone.getObjects()[1].getName() == "Market" then
            Card = main_deck.takeObject({flip=true, position=zone.getPosition()})
            added_cards = added_cards +1
        end
    end
    Wait.condition(
        CreateRefillButton, -- function to execute and wait until it's over
        function() -- condition function to be met before re-creating the button
            return Card.resting
        end
    )
end

function MergeDecksToMarket(deck_list1, market_decks_list2)
    for expansion_deck, market_deck_zone in zip(deck_list1, market_decks_list2) do
        local market_deck = GetDeckFromZone(market_deck_zone)
        expansion_deck.setPosition({market_deck.getPosition()[1], market_deck.getPosition()[2]+1, market_deck.getPosition()[3]})
        expansion_deck.setRotation(market_deck.getRotation())
    end
end

function BroadcastAddition(expansion_name)
    broadcastToAll(string.format("Added %s expansion to the game", expansion_name))
    table.insert(AddedExpansions, expansion_name)
end

function AddAncientGuild()
    -- Search for button and remove it
    for _, button in ipairs(self.getButtons()) do
        if button.click_function == "AddAncientGuild" then
            self.removeButton(button.index)
            break
        end
    end

    -- Get decks
    local expansion_decks = {
        getObjectFromGUID('e988c1'), -- scrolls
        getObjectFromGUID('ee0a0a'), -- spells
        getObjectFromGUID('85d8ec'), -- potions
        getObjectFromGUID('569860'), -- nuggets
        getObjectFromGUID('661223'), -- main
    }
    local market_decks_zones = {
        MarketDeckZones.scrolls, MarketDeckZones.spells, MarketDeckZones.potions,
        MarketDeckZones.nuggets, MarketDeckZones.main
    }
    -- Merge decks
    MergeDecksToMarket(expansion_decks, market_decks_zones)

    -- Add the name of the expansion
    BroadcastAddition("Ancient Guild")
end

function AddTheHorde()
    -- Search for button and remove it
    for _, button in ipairs(self.getButtons()) do
        if button.click_function == "AddTheHorde" then
            self.removeButton(button.index)
            break
        end
    end

    -- Get decks
    local expansion_decks = {
        getObjectFromGUID('bbf4dc'), -- spells
        getObjectFromGUID('f31506'), -- potions
        getObjectFromGUID('a6166d'), -- main
    }
    local market_decks_zones = {MarketDeckZones.spells, MarketDeckZones.potions, MarketDeckZones.main}

    -- Merge decks
    MergeDecksToMarket(expansion_decks, market_decks_zones)

    -- Add the name of the expansion
    BroadcastAddition("The Horde")
end

function AddReapersHand()
    -- Search for button and remove it
    for _, button in ipairs(self.getButtons()) do
        if button.click_function == "AddReapersHand" then
            self.removeButton(button.index)
            break
        end
    end

    -- Get decks
    local expansion_decks = {
        getObjectFromGUID('5e987a'), -- scrolls
        getObjectFromGUID('70196f'), -- spells
        getObjectFromGUID('eaa7b0'), -- potions
        getObjectFromGUID('6ba05a'), -- nuggets
        getObjectFromGUID('c4b2ee'), -- main
    }
    local market_decks_zones = {
        MarketDeckZones.scrolls, MarketDeckZones.spells, MarketDeckZones.potions, MarketDeckZones.nuggets, MarketDeckZones.main
    }
    -- Merge decks
    MergeDecksToMarket(expansion_decks, market_decks_zones)

    -- Add the name of the expansion
    BroadcastAddition("The Reaper's Hand")
end

function InitMarket()
    -- TODO save the scripting zones guids in saved_data (with object.guid) and handle them without recreating them each time
    self.clearButtons()
    -- function run once to initialize the market at the first load
    local empty_card_zones_guids = {"a48d03", "dfb0e3", "847317", "e9ea04", "384922"}
    EmptyMarketZones = {}
    for id, guid in ipairs(empty_card_zones_guids) do
        local zone = getObjectFromGUID(guid)
        table.insert(EmptyMarketZones, id, zone)
    end

    if MarketDeckZones == nil then
        local market_decks = {
            main = getObjectFromGUID("88c1a4"),
            beers = getObjectFromGUID('c905b4'),
            scrolls = getObjectFromGUID('45ddb2'),
            spells = getObjectFromGUID('fb04df'),
            potions = getObjectFromGUID('c593d2'),
            nuggets = getObjectFromGUID('0b5d92'),
        }

        MarketDeckZones = SpawnZones(market_decks)
    end

    if not Global.getVar('GameStarted') then
        local scale = {0.3, 1.0, 0.4}
        local tooltip_text = "Add this expansion cards to the game."
        self.createButton({
            function_owner = self, click_function = 'AddAncientGuild',
            label = 'Add Ancient Guild\nto the game',
            position = {-0.65, 1.00, -2.9}, width = 1800, height = 500, scale=scale,
            color = {0.0, 0.0, 0.0}, font_color = {0.3, 0.8, 0.3}, font_size = 200,
            tooltip=tooltip_text
        })
        self.createButton({
            function_owner = self, click_function = 'AddTheHorde',
            label = 'Add The Horde\nto the game',
            position = {1.55, 1.00, -2.9}, width = 1500, height = 500, scale=scale,
            color = {0.0, 0.0, 0.0}, font_color = {0.9, 0.3, 0.4}, font_size = 200,
            tooltip=tooltip_text
        })
        self.createButton({
            function_owner = self, click_function = 'AddReapersHand',
            label = "Add The Reaper's Hand\nto the game",
            position = {4.5, 1.00, -2.1}, width = 2200, height = 500, scale=scale,
            color = {0.0, 0.0, 0.0}, font_color = {0.3, 0.3, 0.9}, font_size = 200,
            tooltip=tooltip_text
        })
    end
end

-- TABLETOP FUNCTIONS

function onLoad()
    -- Initizalize the market at each load because of the
    Wait.frames(InitMarket, 5)
    if Global.getVar('GameStarted') then
        RemoveButton('RefillCards')
        Wait.frames(CreateRefillButton, 5)
    end
end

function onUpdate()
    if not Global.getVar('GameStarted') then
        local players_ready = 0
        for _, character in pairs(Global.getTable('Characters')) do
            if character.selected then
                players_ready = players_ready + 1
            end
        end
        if players_ready > 0 and Global.getVar('PlayersSelected') == players_ready then
            CreateStartButton()
        else
            RemoveButton('StartMarket')
        end
    end
end