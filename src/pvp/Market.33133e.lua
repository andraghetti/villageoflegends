------------- MARKET FUNCTIONS --------------

-- Table to store the names of the added expansions
AddedExpansions = {'Base Game'}

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
        position = {0.0, 1.0, 1.7}, width = 500, height = 300, scale={0.3, 1.0, 0.5},
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 90,
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
            Card = main_deck.takeObject({position=zone.getPosition(), rotation={0,180,0}})
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

function MergeDecksToMarket(deck_list)
    for market_deck_zone_name, expansion_deck in pairs(deck_list) do
        local market_deck_zone = MarketDeckZones[market_deck_zone_name]
        local market_deck = GetDeckFromZone(market_deck_zone)
        expansion_deck.setPosition({market_deck.getPosition()[1], market_deck.getPosition()[2]+1, market_deck.getPosition()[3]})
        expansion_deck.setRotation({0, 180, market_deck.getRotation()[3]})
    end
end

function BroadcastAddition(expansion_name)
    broadcastToAll(string.format("Added %s expansion to the game", expansion_name))
    table.insert(AddedExpansions, expansion_name)
end

function AddAncientGuild()
    -- Search for button and remove it
    RemoveButton('AddAncientGuild')

    -- Get decks
    local expansion_decks = {
        scrolls = getObjectFromGUID('e988c1'),
        spells = getObjectFromGUID('ee0a0a'),
        potions = getObjectFromGUID('85d8ec'),
        nuggets = getObjectFromGUID('569860'),
        main = getObjectFromGUID('661223'),
    }
    -- Merge decks
    MergeDecksToMarket(expansion_decks)

    -- Add the name of the expansion
    BroadcastAddition("Ancient Guild")
end

function AddTheHorde()
    -- Search for button and remove it
    RemoveButton('AddTheHorde')

    -- Get decks
    local expansion_decks = {
        spells = getObjectFromGUID('bbf4dc'),
        potions = getObjectFromGUID('f31506'),
        main = getObjectFromGUID('a6166d'),
    }

    -- Merge decks
    MergeDecksToMarket(expansion_decks)

    -- Add the name of the expansion
    BroadcastAddition("The Horde")
end

function AddReapersHand()
    -- Search for button and remove it
    RemoveButton('AddReapersHand')

    -- Get decks
    local expansion_decks = {
        scrolls = getObjectFromGUID('5e987a'),
        spells = getObjectFromGUID('70196f'),
        potions = getObjectFromGUID('eaa7b0'),
        nuggets = getObjectFromGUID('6ba05a'),
        main = getObjectFromGUID('c4b2ee'),
    }
    -- Merge decks
    MergeDecksToMarket(expansion_decks)

    -- Add the name of the expansion
    BroadcastAddition("The Reaper's Hand")
end

function InitMarket()
    self.clearButtons()
    -- function run once to initialize the market at the first load
    local empty_card_zones_guids = {"a48d03", "dfb0e3", "847317", "e9ea04", "384922"}
    EmptyMarketZones = {}
    for id, guid in ipairs(empty_card_zones_guids) do
        local zone = getObjectFromGUID(guid)
        table.insert(EmptyMarketZones, id, zone)
    end

    if MarketDeckZones == nil then
        MarketDeckZones = {
            main = getObjectFromGUID('56f136'),
            beers = getObjectFromGUID('dc6eb8'),
            scrolls = getObjectFromGUID('d73d71'),
            spells = getObjectFromGUID('04859c'),
            potions = getObjectFromGUID('1d69f2'),
            nuggets = getObjectFromGUID('cae607'),
        }
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