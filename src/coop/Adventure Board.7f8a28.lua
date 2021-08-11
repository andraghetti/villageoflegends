-- stupid fucking tabletop simulator, not attaching the button index to the calling function
function MoveAdventureCard0(); MoveAdventureCard(0); end
function MoveAdventureCard1(); MoveAdventureCard(1); end
function MoveAdventureCard2(); MoveAdventureCard(2); end
function MoveAdventureCard3(); MoveAdventureCard(3); end
function MoveAdventureCard4(); MoveAdventureCard(4); end
function MoveAdventureCard5(); MoveAdventureCard(5); end
function MoveAdventureCard6(); MoveAdventureCard(6); end
function MoveAdventureCard7(); MoveAdventureCard(7); end
function MoveAdventureCard8(); MoveAdventureCard(8); end
function MoveAdventureCard9(); MoveAdventureCard(9); end
function MoveAdventureCard10(); MoveAdventureCard(10); end
function MoveAdventureCard11(); MoveAdventureCard(11); end
function MoveAdventureCard12(); MoveAdventureCard(12); end
function MoveAdventureCard13(); MoveAdventureCard(13); end
function MoveAdventureCard14(); MoveAdventureCard(14); end
function MoveAdventureCard15(); MoveAdventureCard(15); end
function MoveAdventureCard16(); MoveAdventureCard(16); end
function MoveAdventureCard17(); MoveAdventureCard(17); end
function MoveAdventureCard18(); MoveAdventureCard(18); end
function MoveAdventureCard19(); MoveAdventureCard(19); end
function MoveAdventureCard20(); MoveAdventureCard(20); end
function MoveAdventureCard21(); MoveAdventureCard(21); end
function MoveAdventureCard22(); MoveAdventureCard(22); end
function MoveAdventureCard23(); MoveAdventureCard(23); end
function MoveAdventureCard24(); MoveAdventureCard(24); end
function MoveAdventureCard25(); MoveAdventureCard(25); end
function MoveAdventureCard26(); MoveAdventureCard(26); end
function MoveAdventureCard27(); MoveAdventureCard(27); end
function MoveAdventureCard28(); MoveAdventureCard(28); end
function MoveAdventureCard29(); MoveAdventureCard(29); end
function MoveAdventureCard30(); MoveAdventureCard(30); end
function MoveAdventureCard31(); MoveAdventureCard(31); end
function MoveAdventureCard32(); MoveAdventureCard(32); end
function MoveAdventureCard33(); MoveAdventureCard(33); end
function MoveAdventureCard34(); MoveAdventureCard(34); end
function MoveAdventureCard35(); MoveAdventureCard(35); end
function MoveAdventureCard36(); MoveAdventureCard(36); end
function MoveAdventureCard37(); MoveAdventureCard(37); end
function MoveAdventureCard38(); MoveAdventureCard(38); end
function MoveAdventureCard39(); MoveAdventureCard(39); end
function MoveAdventureCard40(); MoveAdventureCard(40); end
function MoveAdventureCard41(); MoveAdventureCard(41); end
function MoveAdventureCard42(); MoveAdventureCard(42); end
function MoveAdventureCard43(); MoveAdventureCard(43); end
function MoveAdventureCard44(); MoveAdventureCard(44); end
function MoveAdventureCard45(); MoveAdventureCard(45); end
function MoveAdventureCard46(); MoveAdventureCard(46); end
function MoveAdventureCard47(); MoveAdventureCard(47); end
function MoveAdventureCard48(); MoveAdventureCard(48); end
function MoveAdventureCard49(); MoveAdventureCard(49); end
function MoveAdventureCard50(); MoveAdventureCard(50); end
function MoveAdventureCard51(); MoveAdventureCard(51); end
function MoveAdventureCard52(); MoveAdventureCard(52); end
function MoveAdventureCard53(); MoveAdventureCard(53); end
function MoveAdventureCard54(); MoveAdventureCard(54); end
function MoveAdventureCard55(); MoveAdventureCard(55); end

function onLoad(saved_data)
    local adventure_deck = nil
    if saved_data ~= '' then
        local loaded_data = JSON.decode(saved_data)
        BoardInitialized = false--loaded_data.board_initialized
        adventure_deck = getObjectFromGUID(loaded_data.adventure_deck_guid)
    else
        BoardInitialized = false
        AdventureDeckGUID = '9fff7c'
        adventure_deck = getObjectFromGUID(AdventureDeckGUID)
        -- give index as name of cards  (already done, not needed)
        -- SpawnScriptZones(adventure_deck)
        -- for _, card in ipairs(adventure_deck.getObjects()) do
        --     local card_obj = adventure_deck.takeObject()
        --     card_obj.setName(card.index)
        --     card_obj.setPosition(MainAdventureDeckZone.getPosition())
        -- end
        -- get guid of resulting deck
        for _, object in ipairs(MainAdventureDeckZone.getObjects()) do
            if object.type == 'Deck' then
                AdventureDeckGUID = object.guid
            end
        end
    end
    if not BoardInitialized then
        SpawnScriptZones(adventure_deck)
        CreateAdventureButtons()
        BoardInitialized = true
    end
end

function onSave()
    SavedData = JSON.encode({
        board_initialized = BoardInitialized,
        adventure_deck_guid = AdventureDeckGUID
    })
    return SavedData
end

function SpawnScriptZones(adventure_deck)
    if MainAdventureDeckZone ~= nil or SelectedAdventureDeckZone ~= nil then
        MainAdventureDeckZone.destruct()
        SelectedAdventureDeckZone.destruct()
    end
    MainAdventureDeckZone = spawnObject({
        type='ScriptingTrigger',
        position = adventure_deck.getPosition(),
        scale = {adventure_deck.getBounds().size[1], 3, adventure_deck.getBounds().size[3]},
    })
    SelectedAdventureDeckZone = spawnObject({
        type='ScriptingTrigger',
        position = MainAdventureDeckZone.getPosition():copy():add(Vector(0, 0, -4)),
        scale = {adventure_deck.getBounds().size[1], 3, adventure_deck.getBounds().size[3]},
    })
end

function CreateAdventureButtons()
    self.clearButtons()
    for i = 0, 56, 1 do
        local vertical_offset = -1.2 + (i - i % 10)/ 10 / 6 * 3 -- 6 rows of 10.  *2 is to spread between in range [-1 , 1]
        local horizontal_offset = -0.5 + (i % 10) / 10 * 1.6
        if i < 56 then
            self.createButton({
                function_owner = self, click_function = 'MoveAdventureCard'..i, label = tostring(i),
                position = {horizontal_offset, 1.0, vertical_offset}, width = 200, height = 200, scale={0.3, 1.0, 0.8},
                color = {0.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, hover_color = {0.0, 1.0, 0.0},
                press_color = {1.0, 1.0, 0.0}, font_size = 120,
                tooltip = "Add card #" .. tostring(i) .. " to the adventure deck"
            })
        else
            self.createButton({
                function_owner = self, click_function = 'ResetAdventure', label = 'Reset',
                position = {horizontal_offset + 0.1, 1.0, vertical_offset}, width = 400, height = 200, scale={0.3, 1.0, 0.8},
                color = {1.0, 0.0, 0.0}, font_color = {1.0, 1.0, 1.0}, hover_color = {1.0, 0.5, 0.0},
                press_color = {0.8, 0.0, 0.0}, font_size = 120,
                tooltip = "Add card #" .. tostring(i) .. " to the adventure deck"
            })
        end
    end
end

function ResetAdventure()
    -- move back the cards to the adventure decks and reset the buttons
    for _, object in pairs(SelectedAdventureDeckZone.getObjects()) do
        if (object.type == 'Card' or object.type == 'Deck'
            ) and object.name ~= 'CardCustom' then
            object.setPosition(MainAdventureDeckZone.getPosition())
        end
    end
    CreateAdventureButtons()
end

function ChangeColorButton(button_function_name, is_on)
    -- helper function to change colors that matches the 'button_function_name'
    -- based on the activation (on/off) of the button
    if self.getButtons() ~= nil then
        for _, button in ipairs(self.getButtons()) do
            if button.click_function == button_function_name then
                if button.index ~= nil then
                    -- button found
                    local card_number = string.gsub(button.click_function, "MoveAdventureCard", "")
                    if is_on then
                        button.color = {1.0, 1.0, 0.0}  -- yellow
                        button.font_color = {0.0, 0.0, 0.0}
                        button.hover_color = {1.0, 0.0, 0.0} -- red
                        button.press_color = {0.0, 1.0, 0.0}
                        button.tooltip = "Remove card #" .. card_number .. " from the adventure deck"
                    else
                        button.color = {0.0, 0.0, 0.0}
                        button.font_color = {1.0, 1.0, 1.0}
                        button.hover_color = {0.0, 1.0, 0.0} -- green
                        button.press_color = {1.0, 1.0, 0.0} -- yellow
                        button.tooltip = "Add card #" .. card_number .. " to the adventure deck"
                    end
                    self.editButton(button)
                end
            end
        end
    end
end

function PickCard(number, source_zone)
    -- helper function to pick the card that matches the number and return it
    -- from the given zone.
    local selected_card = nil
    for _, object in pairs(source_zone.getObjects()) do
        if object ~= nil then
            if object.type == 'Card' and object.getName() ~= 'Adventure Board' then
                -- object could be just a single card (and it has no name if it's face down)
                selected_card = object
            elseif object.type == 'Deck' then
                for _, card in pairs(object.getObjects()) do
                    if card.name == tostring(number) then
                        selected_card = object.takeObject({index = card.index})
                        break -- Stop iterating
                    end
                end
            end
        end
    end
    return selected_card
end

function MoveAdventureCard(number)
    -- entry point function to move an adventure card between the main
    -- deck and the selected one.

    -- pick from main deck
    local selected_card = PickCard(number, MainAdventureDeckZone)
    local dest_zone = SelectedAdventureDeckZone

    -- pick from selected deck
    if selected_card == nil then
        selected_card = PickCard(number, SelectedAdventureDeckZone)
        dest_zone = MainAdventureDeckZone
    end
    -- card has been moved out of the scripting zones
    if selected_card == nil then
        print('Card not available. Move it back into the main deck.')
        ChangeColorButton('MoveAdventureCard'..number, false)
        return
    else
        ChangeColorButton('MoveAdventureCard'..number, dest_zone == SelectedAdventureDeckZone)
        selected_card.setPosition(dest_zone.getPosition():copy():add(Vector{0,1,0}))
    end
end