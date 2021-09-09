------------- MARKET FUNCTIONS --------------

-- Table to store the names of the added expansions
AddedExpansions = {'Base Game', 'The Reaper\'s Hand'}
MarketScale = {0.25, 1.0, 0.8}

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

function CreateStartButton()
    self.createButton({
        function_owner = self, click_function = 'StartMarket', label = 'Start',
        position = {0.0, 1.0, 6}, width = 1500, height = 600, scale=MarketScale,
        color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, font_size = 300,
        tooltip="Once you added the expansions to the game you can click here to shuffle the market's decks and deal the cards."
    })
end

-- BUTTONS FUNCTIONS

function StartMarket()
    -- Shuffle decks
    broadcastToAll(string.format("Starting a new adventure with %s!\nHave fun!", table.concat(AddedExpansions," + ")))

    -- Shuffle decks
    for _, zone in pairs(MarketDeckZones) do
        GetDeckFromZone(zone).shuffle()
    end

    -- Remove buttons
    self.clearButtons()

    -- Remove unused decks
    Wait.frames(function ()
        for _, object in ipairs(getObjectFromGUID('5ba021').getObjects()) do object.destruct() end
        for _, object in ipairs(getObjectFromGUID('3bd743').getObjects()) do object.destruct() end
    end, 5)

    -- Remove scripting zones
    Wait.frames(function ()
        getObjectFromGUID('5ba021').destruct()
        getObjectFromGUID('3bd743').destruct()
    end, 5)

    Global.setVar('MarketStarted', true)
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
        nuggets = getObjectFromGUID('466fee'),
        main = getObjectFromGUID('3e9f60'),
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
        main = getObjectFromGUID('bd1ee9'),
    }

    -- Merge decks
    MergeDecksToMarket(expansion_decks)

    -- Add the name of the expansion
    BroadcastAddition("The Horde")
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
            main = getObjectFromGUID('640a84'),
            beers = getObjectFromGUID('488652'),
            scrolls = getObjectFromGUID('5c892f'),
            spells = getObjectFromGUID('985355'),
            potions = getObjectFromGUID('03781b'),
            nuggets = getObjectFromGUID('4da1c1'),
        }
    end

    if not Global.getVar('GameStarted') then
        local tooltip_text = "Add this expansion cards to the game."
        self.createButton({
            function_owner = self, click_function = 'AddAncientGuild',
            label = 'Add Ancient Guild\nto the game',
            position = {-0.65, 1.00, -8.5}, width = 1800, height = 500, scale=MarketScale,
            color = {0.0, 0.0, 0.0}, font_color = {0.3, 0.8, 0.3}, font_size = 200,
            tooltip=tooltip_text
        })
        self.createButton({
            function_owner = self, click_function = 'AddTheHorde',
            label = 'Add The Horde\nto the game',
            position = {1.55, 1.00, -8.5}, width = 1500, height = 500, scale=MarketScale,
            color = {0.0, 0.0, 0.0}, font_color = {0.9, 0.3, 0.4}, font_size = 200,
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