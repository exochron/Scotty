local _, ADDON = ...

-- for classic: filter db for existing items & spells

-- see: https://warcraft.wiki.gg/wiki/UiMapID & https://warcraft.wiki.gg/wiki/InstanceID
-- or: /dump WorldMapFrame:GetMapID()

function ADDON:InitDatabase()

    local EASTERN_KINGDOMS = 0
    local KALIMDOR = 1
    local OUTLAND = 530
    local NORTHREND = 571
    local PANDARIA = 870
    local DRAENOR = 1116
    local BROKEN_ISLES = 1220
    local ZANDALAR = 1642
    local KUL_TIRAS = 1643
    local SHADOWLANDS = 2222
    local DRAGON_ISLES = 2444
    local KHAZ_ALGAR = 2601

    -- https://wago.tools/db2/DisplaySeason
    local WW_S3 = 30
    local currentSeason = C_SeasonInfo and C_SeasonInfo.GetCurrentDisplaySeasonID() or 0

    local isAlliance = UnitFactionGroup("player") == "Alliance"
    local isHorde = UnitFactionGroup("player") == "Horde"
    local playerRace = UnitRace("player")
    local prof1, prof2 = GetProfessions()
    local isEngineer = prof1 and select(7, GetProfessionInfo(prof1)) == 202
    isEngineer = isEngineer or prof2 and select(7, GetProfessionInfo(prof2)) == 202

    ADDON.Category = {
        Hearthstone = 1,
        SeasonInstance = 2,
    }

    local db = {
        -- Various Items and Toys
        -- isEquippableItem is actually also available via api. However it requires cached item data.

        {item = 21711, map = 80, continent = KALIMDOR}, -- Lunar Festival Invitation
        {item = 22589, map = 350, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Atiesh, Greatstaff of the Guardian
        {item = 22630, map = 350, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Atiesh, Greatstaff of the Guardian
        {item = 22631, map = 350, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Atiesh, Greatstaff of the Guardian
        {item = 22632, map = 350, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Atiesh, Greatstaff of the Guardian
        {item = 32757, map = 339, continent = OUTLAND, isEquippableItem = true}, -- Blessed Medallion of Karabor
        {item = 37863, map = 35, continent = EASTERN_KINGDOMS}, -- Direbrew's Remote
        {item = 40585, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Signet of the Kirin Tor
        {item = 40586, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Band of the Kirin Tor
        {item = 44934, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Loop of the Kirin Tor
        {item = 44935, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Ring of the Kirin Tor
        {item = 45688, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Inscribed Band of the Kirin Tor
        {item = 45689, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Inscribed Loop of the Kirin Tor
        {item = 45690, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Inscribed Ring of the Kirin Tor
        {item = 45691, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Inscribed Signet of the Kirin Tor
        {item = 46874, map = 118, continent = NORTHREND, isEquippableItem = true}, -- Argent Crusader's Tabard
        {item = 48954, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Etched Band of the Kirin Tor
        {item = 48955, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Etched Loop of the Kirin Tor
        {item = 48956, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Etched Ring of the Kirin Tor
        {item = 48957, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Etched Signet of the Kirin Tor
        {item = 50287, map = 210, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Boots of the Bay
        {item = 51557, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Runed Signet of the Kirin Tor
        {item = 51558, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Runed Loop of the Kirin Tor
        {item = 51559, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Runed Ring of the Kirin Tor
        {item = 51560, map = 125, continent = NORTHREND, isEquippableItem = true}, -- Runed Band of the Kirin Tor
        {item = 52251, map = 125, continent = NORTHREND}, -- Jaina's Locket
        {item = 63206, map = 84, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Wrap of Unity
        {item = 63207, map = 85, continent = KALIMDOR, isEquippableItem = true}, -- Wrap of Unity
        {item = 63352, map = 84, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Shroud of Cooperation
        {item = 63353, map = 85, continent = KALIMDOR, isEquippableItem = true}, -- Shroud of Cooperation
        {item = 63378, map = 245, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Hellscream's Reach Tabard
        {item = 63379, map = 245, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Baradin's Wardens Tabard
        {item = 65274, map = 85, continent = KALIMDOR, isEquippableItem = true}, -- Cloak of Coordination
        {item = 65360, map = 84, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Cloak of Coordination
        {item = 95050, map = 503, continent = KALIMDOR, isEquippableItem = true}, -- The Brassiest Knuckle
        {item = 95051, map = 500, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- The Brassiest Knuckle
        {item = 103678, map = 554, continent = PANDARIA, isEquippableItem = true}, -- Time-Lost Artifact
        {item = 118662, map = 624, continent = DRAENOR}, -- Bladespire Relic
        {item = 118663, map = 622, continent = DRAENOR}, -- Relic of Karabor
        {item = 118907, map = 500, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Pit Fighter's Punching Ring
        {item = 118908, map = 503, continent = KALIMDOR, isEquippableItem = true}, -- Pit Fighter's Punching Ring
        {item = 128353, map = (isAlliance and 539 or 525), continent = DRAENOR}, -- Admiral's Compass
        {item = 138448, map = 627, continent = BROKEN_ISLES}, -- Emblem of Margoss
        {item = 139590, map = 25, continent = EASTERN_KINGDOMS}, -- Scroll of Teleport: Ravenholdt
        {item = 139599, map = 627, continent = BROKEN_ISLES, isEquippableItem = true}, -- Empowered Ring of the Kirin Tor
        {item = 141605, isMultiDestination = true, name=MINIMAP_TRACKING_FLIGHTMASTER, continent = BROKEN_ISLES}, -- Flight Master's Whistle
        {item = 141605, isMultiDestination = true, name=MINIMAP_TRACKING_FLIGHTMASTER, continent = ZANDALAR}, -- Flight Master's Whistle
        {item = 141605, isMultiDestination = true, name=MINIMAP_TRACKING_FLIGHTMASTER, continent = KUL_TIRAS}, -- Flight Master's Whistle
        {item = 142469, map = 350, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Violet Seal of the Grand Magus
        {item = 144391, map = 500, continent = EASTERN_KINGDOMS, isEquippableItem = true}, -- Pugilist's Powerful Punching Ring
        {item = 144392, map = 503, continent = KALIMDOR, isEquippableItem = true}, -- Pugilist's Powerful Punching Ring
        {item = 166559, map = 1165, continent = ZANDALAR, isEquippableItem = true}, -- Commander's Signet of Battle
        {item = 166560, map = 1161, continent = KUL_TIRAS, isEquippableItem = true}, -- Captain's Signet of Command
        {item = 202046, map = 942, continent = KUL_TIRAS}, -- Lucky Tortollan Charm
        {item = 219222, map = 554, continent = PANDARIA}, -- Time-Lost Artifact
        {toy = isAlliance and 110560, map = 582, quest=34586, name=GARRISON_LOCATION_TOOLTIP, continent = DRAENOR}, -- Garrison Hearthstone (alliance)
        {toy = isHorde and 110560, map = 590, quest=34378, name=GARRISON_LOCATION_TOOLTIP, continent = DRAENOR}, -- Garrison Hearthstone (horde)
        {toy = 140192, map = 627, continent = BROKEN_ISLES}, -- Dalaran Hearthstone -- todo: lookup quest
        {toy = 151016, map = 104, continent = OUTLAND}, -- Fractured Necrolyte Skull
        {toy = (playerRace == "Worgen" and 211788), map = 179, continent = EASTERN_KINGDOMS}, -- Tess's Peacebloom
        {toy = 230850, name = DELVE_LABEL, continent = KHAZ_ALGAR, }, -- Delve-O-Bot 7001
        {toy = 243056, map = 2339, continent = KHAZ_ALGAR, }, -- Delver's Mana-Bound Ethergate

        {spell = 50977,
         map = LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_LEGION and 648 or 23,
         continent = LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_LEGION and BROKEN_ISLES or EASTERN_KINGDOMS
        }, -- Archerus (DK)
        {spell = 126892, isMultiDestination = true, map = 379, continent = PANDARIA }, -- Zen Pilgrimage (Monk)
        {spell = LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_LEGION and 126892, isMultiDestination = true, quest = 40236, map = 709, continent = BROKEN_ISLES}, -- Zen Pilgrimage (Monk)
        {spell = 193759, map = 734, continent = BROKEN_ISLES}, -- Hall of the guardian (Mage)

        -- Druid Dreamwalk
        {spell = 18960, map = 80, continent = KALIMDOR},
        {spell = 193753, isMultiDestination = true, map = 26, continent = EASTERN_KINGDOMS},
        {spell = 193753, isMultiDestination = true, map = 47, continent = EASTERN_KINGDOMS},
        {spell = 193753, isMultiDestination = true, map = 69, continent = KALIMDOR},
        {spell = 193753, isMultiDestination = true, map = 80, continent = KALIMDOR},
        {spell = 193753, isMultiDestination = true, map = 116, continent = NORTHREND},
        {spell = 193753, isMultiDestination = true, map = 198, continent = KALIMDOR},
        {spell = 193753, isMultiDestination = true, map = 747, continent = BROKEN_ISLES},

        -- Mage Teleports with Portals
        -- https://www.wowhead.com/guide/transportation#mage-portals
        {spell = 3561, portal = 10059, map = 84, continent = EASTERN_KINGDOMS}, -- Stormwind
        {spell = 3562, portal = 11416, map = 87, continent = EASTERN_KINGDOMS}, -- Ironforge
        {spell = 3563, portal = 11418, map = 998, continent = EASTERN_KINGDOMS}, -- Undercity
        {spell = 3565, portal = 11419, map = 89, continent = KALIMDOR}, -- Darnassus
        {spell = 3566, portal = 11420, map = 88, continent = KALIMDOR}, -- Thunder Bluff
        {spell = 3567, portal = 11417, map = 85, continent = KALIMDOR}, -- Orgrimmar
        {spell = 32271, portal = 32266, map = 103, continent = KALIMDOR}, -- Exodar
        {spell = 32272, portal = 32267, map = 110, continent = EASTERN_KINGDOMS}, -- Silvermoon
        {spell = 35715, portal = 35717, map = 111, continent = OUTLAND}, -- Shattrath
        {spell = 33690, portal = 33691, map = 111, continent = OUTLAND}, -- Shattrath
        {spell = 49358, portal = 49361, map = 51, continent = EASTERN_KINGDOMS}, -- Stonard
        {spell = 49359, portal = 49360, map = 70, continent = KALIMDOR}, -- Theramore
        {spell = 53140, portal = 53142, map = 125, continent = NORTHREND}, -- Dalaran
        {spell = 88342, portal = 88345, map = 245, continent = EASTERN_KINGDOMS}, -- Tol Barad
        {spell = 88344, portal = 88346, map = 245, continent = EASTERN_KINGDOMS}, -- Tol Barad
        {spell = 120145, portal = 120146, map = 25, continent = EASTERN_KINGDOMS}, -- Dalaran Crater
        {spell = 132621, portal = 132620, map = 390, continent = PANDARIA}, -- Vale of Eternal BLossoms
        {spell = 132627, portal = 132626, map = 390, continent = PANDARIA}, -- Vale of Eternal BLossoms
        {spell = 176242, portal = 176244, map = 624, continent = DRAENOR}, -- Warspear
        {spell = 176248, portal = 176246, map = 622, continent = DRAENOR}, -- Stormshield
        {spell = 224869, portal = 224871, map = 627, continent = BROKEN_ISLES}, -- Dalaran
        {spell = 281403, portal = 281400, map = 1161, continent = KUL_TIRAS}, -- Boralus
        {spell = 281404, portal = 281402, map = 1165, continent = ZANDALAR}, -- Dazar'alor
        {spell = 344587, portal = 344597, map = 1670, continent = SHADOWLANDS}, -- Oribos
        {spell = 395277, portal = 395289, map = 2134, continent = DRAGON_ISLES}, -- Valdraken
        {spell = 446540, portal = 446534, map = 2339, continent = KHAZ_ALGAR}, -- Dornogal

        -- Mole Machine of Dark Iron Dwarfes
        -- from https://www.wowhead.com/spell=265225/mole-machine#comments:id=2579704 Kudos to P3lim
        -- /dump C_GossipInfo.GetOptions()
        {spell = 265225, isMultiDestination = true, map = 87, continent = EASTERN_KINGDOMS, gossip={49322, 49331}}, -- Ironforge
        {spell = 265225, isMultiDestination = true, map = 84, continent = EASTERN_KINGDOMS, gossip={49322, 49332}}, -- Stormwind
        {spell = 265225, isMultiDestination = true, map = 243, continent = EASTERN_KINGDOMS, gossip={49322, 49336}}, -- Shadowforge City
        {spell = 265225, isMultiDestination = true, quest = 53594, map = 17, continent = EASTERN_KINGDOMS, gossip={49322, 49333}}, -- Blasted Lands
        {spell = 265225, isMultiDestination = true, quest = 53585, map = 26, continent = EASTERN_KINGDOMS, gossip={49322, 49334}}, -- The Hinterlands
        {spell = 265225, isMultiDestination = true, quest = 53587, map = 35, continent = EASTERN_KINGDOMS, gossip={49322, 49335}}, -- Blackrock Mountain
        {spell = 265225, isMultiDestination = true, quest = 53591, map = 78, continent = KALIMDOR, gossip={49323, 49337}}, -- Un'Goro Crater
        {spell = 265225, isMultiDestination = true, quest = 53601, map = 198, continent = KALIMDOR, gossip={49323, 49338}}, -- Mount Hyjal
        {spell = 265225, isMultiDestination = true, quest = 53600, map = 199, continent = KALIMDOR, gossip={49323, 49339}}, -- Southern Barrens
        {spell = 265225, isMultiDestination = true, quest = 53592, map = 100, continent = OUTLAND, gossip={49324, 49340}}, -- Hellfire Peninsula
        {spell = 265225, isMultiDestination = true, quest = 53599, map = 104, continent = OUTLAND, gossip={49324, 49341}}, -- Shadowmoon Valley
        {spell = 265225, isMultiDestination = true, quest = 53597, map = 105, continent = OUTLAND, gossip={49324, 49342}}, -- Blade's Edge Mountains
        {spell = 265225, isMultiDestination = true, quest = 53586, map = 118, continent = NORTHREND,gossip={49325, 49343}}, -- Icecrown
        {spell = 265225, isMultiDestination = true, quest = 53596, map = 115, continent = NORTHREND, gossip={49325, 49344}}, -- Dragonblight
        {spell = 265225, isMultiDestination = true, quest = 53595, map = 379, continent = PANDARIA, gossip={49326, 49345}}, -- Kun-Lai Summit
        {spell = 265225, isMultiDestination = true, quest = 53598, map = 376, continent = PANDARIA, gossip={49326, 49346}}, -- Valley of the Four Winds
        {spell = 265225, isMultiDestination = true, quest = 53588, map = 543, continent = DRAENOR, gossip={49327, 49347}}, -- Gorgond
        {spell = 265225, isMultiDestination = true, quest = 53590, map = 550, continent = DRAENOR, gossip={49327, 49348}}, -- Nagrand
        {spell = 265225, isMultiDestination = true, quest = 53593, map = 650, continent = BROKEN_ISLES, gossip={49328, 49349}}, -- Highmountain
        {spell = 265225, isMultiDestination = true, quest = 53589, map = 646, continent = BROKEN_ISLES, gossip={49328, 49350}}, -- Broken Shore
        {spell = 265225, isMultiDestination = true, quest = 80099, map = 863, continent = ZANDALAR, gossip={49330, 125454}}, -- Nazmir
        {spell = 265225, isMultiDestination = true, quest = 80100, map = 862, continent = ZANDALAR, gossip={49330, 125453}}, -- Zuldazar
        {spell = 265225, isMultiDestination = true, quest = 80101, map = 895, continent = KUL_TIRAS, gossip={49329, 125456}}, -- Tiragarde Sound
        {spell = 265225, isMultiDestination = true, quest = 80102, map = 942, continent = KUL_TIRAS, gossip={49329, 125455}}, -- Stormsong Valley
        {spell = 265225, isMultiDestination = true, quest = 80103, map = 1536, continent = SHADOWLANDS, gossip={125452, 125460}}, -- Maldraxxus
        {spell = 265225, isMultiDestination = true, quest = 80104, map = 1525, continent = SHADOWLANDS, gossip={125452, 125459}}, -- Revendreth
        {spell = 265225, isMultiDestination = true, quest = 80105, map = 1533, continent = SHADOWLANDS, gossip={125452, 125458}}, -- Bastion
        {spell = 265225, isMultiDestination = true, quest = 80106, map = 1565, continent = SHADOWLANDS, gossip={125452, 125457}}, -- Ardenweald
        {spell = 265225, isMultiDestination = true, quest = 80107, map = 2022, continent = DRAGON_ISLES, gossip={125451, 125463}}, -- Waking Shores
        {spell = 265225, isMultiDestination = true, quest = 80108, map = 2024, continent = DRAGON_ISLES, gossip={125451, 125462}}, -- Azure Span
        {spell = 265225, isMultiDestination = true, quest = 80109, map = 2133, continent = DRAGON_ISLES, gossip={125451, 132053}}, -- Zaralek Cavern

        -- Engineering Items
        -- /dump C_GossipInfo.GetOptions()
        {toy = isEngineer and 18984, map = 83, continent = KALIMDOR}, -- Dimensional Ripper - Everlook
        {toy = isEngineer and 18986, map = 71, continent = KALIMDOR}, -- Ultrasafe Transporter: Gadgetzan
        {toy = isEngineer and 30542, map = 109, continent = OUTLAND}, -- Dimensional Ripper - Area 52
        {toy = isEngineer and 30544, map = 105, continent = OUTLAND}, -- Ultrasafe Transporter: Toshley's Station
        {toy = isEngineer and 48933, isMultiDestination = true, map = 114, continent = NORTHREND, gossip={38054}}, -- Wormhole Generator: Northrend - Borean Tundra
        {toy = isEngineer and 48933, isMultiDestination = true, map = 117, continent = NORTHREND, gossip={38055}}, -- Wormhole Generator: Northrend - Howling Fjord
        {toy = isEngineer and 48933, isMultiDestination = true, map = 118, continent = NORTHREND, gossip={38057}}, -- Wormhole Generator: Northrend - Icecrown
        {toy = isEngineer and 48933, isMultiDestination = true, map = 119, continent = NORTHREND, gossip={38056}}, -- Wormhole Generator: Northrend - Sholazar Basin
        {toy = isEngineer and 48933, isMultiDestination = true, map = 120, continent = NORTHREND, gossip={38058}}, -- Wormhole Generator: Northrend - The Storm Peaks
        {toy = isEngineer and 87215, map = 424, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 112059, isMultiDestination = true, map = 525, continent = DRAENOR, gossip={42591}}, -- Wormhole Centrifuge - Frostfire Ridge
        {toy = isEngineer and 112059, isMultiDestination = true, map = 535, continent = DRAENOR, gossip={42587}}, -- Wormhole Centrifuge - Talador
        {toy = isEngineer and 112059, isMultiDestination = true, map = 539, continent = DRAENOR, gossip={42588}}, -- Wormhole Centrifuge - Shadowmoon Valley
        {toy = isEngineer and 112059, isMultiDestination = true, map = 542, continent = DRAENOR, gossip={42586}}, -- Wormhole Centrifuge - Spires of Arak
        {toy = isEngineer and 112059, isMultiDestination = true, map = 543, continent = DRAENOR, gossip={42590}}, -- Wormhole Centrifuge - Gorgrond
        {toy = isEngineer and 112059, isMultiDestination = true, map = 550, continent = DRAENOR, gossip={42589}}, -- Wormhole Centrifuge - Nagrand
        {toy = isEngineer and 151652, map = 994, continent = BROKEN_ISLES}, -- Wormhole Generator: Argus
        {toy = isEngineer and 168807, map = 992, continent = KUL_TIRAS}, -- Wormhole Generator: Kul Tiras
        {toy = isEngineer and 168808, map = 991, continent = ZANDALAR}, -- Wormhole Generator: Zandalar
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1525, continent = SHADOWLANDS, gossip={51938}}, -- Wormhole Generator: Shadowlands - Revendreth
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1536, continent = SHADOWLANDS, gossip={51936}}, -- Wormhole Generator: Shadowlands - Maldraxxus
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1543, continent = SHADOWLANDS, gossip={51939}}, -- Wormhole Generator: Shadowlands - The Maw
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1565, continent = SHADOWLANDS, gossip={51937}}, -- Wormhole Generator: Shadowlands - Ardenweald
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1569, continent = SHADOWLANDS, gossip={51935}}, -- Wormhole Generator: Shadowlands - Bastion
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1670, continent = SHADOWLANDS, gossip={51934}}, -- Wormhole Generator: Shadowlands - Oribos
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1961, continent = SHADOWLANDS, gossip={51941}}, -- Wormhole Generator: Shadowlands - Korthia
        {toy = isEngineer and 172924, isMultiDestination = true, map = 1970, continent = SHADOWLANDS, gossip={51942}}, -- Wormhole Generator: Shadowlands - Zereth Mortis
        {toy = isEngineer and 198156, isMultiDestination = true, map = 1978, continent = DRAGON_ISLES, gossip={63907}}, -- Wyrmhole Generator: Dragon Isles - Random
        {toy = isEngineer and 198156, isMultiDestination = true, quest = {70573,70574,70575}, map = 2022, continent = DRAGON_ISLES, gossip={63911}}, -- Wyrmhole Generator: Dragon Isles - The Waking Shores
        {toy = isEngineer and 198156, isMultiDestination = true, quest = {70576,70577,70578}, map = 2023, continent = DRAGON_ISLES, gossip={63910}}, -- Wyrmhole Generator: Dragon Isles - Ohn'ahran Plains
        {toy = isEngineer and 198156, isMultiDestination = true, quest = {70579,70580,70581}, map = 2024, continent = DRAGON_ISLES, gossip={63909}}, -- Wyrmhole Generator: Dragon Isles - The Azure Span
        {toy = isEngineer and 198156, isMultiDestination = true, quest = {70583,70584,70585}, map = 2025, continent = DRAGON_ISLES, gossip={63908}}, -- Wyrmhole Generator: Dragon Isles - Thaldraszus
        {toy = isEngineer and 198156, isMultiDestination = true, quest = 76017, map = 2133, continent = DRAGON_ISLES, gossip={109715}}, -- Wyrmhole Generator: Dragon Isles - Zaralek Cavern
        {toy = isEngineer and 198156, isMultiDestination = true, map = 2200, continent = DRAGON_ISLES, gossip={114080}}, -- Wyrmhole Generator: Dragon Isles -.Emerald Dream
        {toy = isEngineer and 221966, isMultiDestination = true, map = 2274, continent = KHAZ_ALGAR, gossip={122362}}, -- Wormhole Generator: Khaz Algar - Random
        {toy = isEngineer and 221966, isMultiDestination = true, map = 2214, continent = KHAZ_ALGAR, gossip={122360}}, -- Wormhole Generator: Khaz Algar - Ringing Deeps
        {toy = isEngineer and 221966, isMultiDestination = true, map = 2215, continent = KHAZ_ALGAR, gossip={122359}}, -- Wormhole Generator: Khaz Algar - Hallowfall
        {toy = isEngineer and 221966, isMultiDestination = true, map = 2248, continent = KHAZ_ALGAR, gossip={122361}}, -- Wormhole Generator: Khaz Algar - Isle of Dorn
        {toy = isEngineer and 221966, isMultiDestination = true, map = 2255, continent = KHAZ_ALGAR, gossip={122358}}, -- Wormhole Generator: Khaz Algar - Azj-Kahet
        {toy = isEngineer and 221966, isMultiDestination = true, accountQuest = 86630, map = 2346, continent = KHAZ_ALGAR, gossip={131563}}, -- Wormhole Generator: Khaz Algar - Undermine

        -- Seasonal Dungeon Port
        {spell = 354465, instance = 2287, continent = SHADOWLANDS, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Halls of Atonement
        {spell = 367416, instance = 2441, continent = SHADOWLANDS, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Tazavesh the Veiled Market
        {spell = 445414, instance = 2662, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- The Dawnbreaker
        {spell = 445417, instance = 2660, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Ara Kara: City of Echoes
        {spell = 445444, instance = 2649, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Priory of the Sacred Flame
        {spell = 1216786, instance = 2773, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Operation: Floodgate
        {spell = 1237215, instance = 2830, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Eco-Dome, Al'dani
        {spell = 1239155, instance = 2810, continent = KHAZ_ALGAR, category = (currentSeason == WW_S3 and ADDON.Category.SeasonInstance)}, -- Manaforge Omega

        -- Older Dungeon Ports
        {spell = 131204, instance = 960, continent = PANDARIA}, -- Temple of the Jade Serpent
        {spell = 131205, instance = 961, continent = PANDARIA}, -- Stormstout Brewery
        {spell = 131206, instance = 959, continent = PANDARIA}, -- Shado-Pan Monastery
        {spell = 131222, instance = 994, continent = PANDARIA}, -- Mogu'shan Palace
        {spell = 131225, instance = 962, continent = PANDARIA}, -- Gate of the Setting Sun
        {spell = 131228, instance = 1011, continent = PANDARIA}, -- Siege of Niuzao Temple
        {spell = 131229, instance = 1004, continent = EASTERN_KINGDOMS}, -- Scarlet Monastery
        {spell = 131231, instance = 1001, continent = EASTERN_KINGDOMS}, -- Scarlet Halls
        {spell = 131232, instance = 1007, continent = EASTERN_KINGDOMS}, -- Scholomance
        {spell = 159895, instance = 1175, continent = DRAENOR}, -- Bloodmaul Slag Mines
        {spell = 159896, instance = 1195, continent = DRAENOR}, -- Iron Docks
        {spell = 159897, instance = 1182, continent = DRAENOR}, -- Auchindoun
        {spell = 159898, instance = 1209, continent = DRAENOR}, -- Skyreach
        {spell = 159899, instance = 1176, continent = DRAENOR}, -- Shadowmoon Burial Grounds
        {spell = 159900, instance = 1208, continent = DRAENOR}, -- Grimrail Depot
        {spell = 159901, instance = 1279, continent = DRAENOR}, -- The Everbloom
        {spell = 159902, instance = 1358, continent = EASTERN_KINGDOMS}, -- Upper Blackrock Spire
        {spell = 354462, instance = 2286, continent = SHADOWLANDS}, -- Necrotic Wake
        {spell = 354463, instance = 2289, continent = SHADOWLANDS}, -- Plaguefall
        {spell = 354464, instance = 2290, continent = SHADOWLANDS}, -- Mists of Tirna Scithe
        {spell = 354466, instance = 2285, continent = SHADOWLANDS}, -- Spires of Ascension
        {spell = 354467, instance = 2293, continent = SHADOWLANDS,}, -- Theater of Pain
        {spell = 354468, instance = 2291, continent = SHADOWLANDS}, -- De Other Side
        {spell = 354469, instance = 2284, continent = SHADOWLANDS}, -- Sanguine Depths
        {spell = 373190, instance = 2296, continent = SHADOWLANDS}, -- Castle Nathria
        {spell = 373191, instance = 2450, continent = SHADOWLANDS}, -- Sanctum of Domination
        {spell = 373192, instance = 2481, continent = SHADOWLANDS}, -- Sepulcher of the First Ones
        {spell = 373262, instance = 532, continent = EASTERN_KINGDOMS}, -- Karazhan
        {spell = 373274, instance = 2097, continent = KUL_TIRAS,}, -- Operation: Mechagon
        {spell = 393222, instance = 2451, continent = EASTERN_KINGDOMS}, -- Uldaman: Legacy of Tyr
        {spell = 393256, instance = 2521, continent = DRAGON_ISLES}, -- Ruby Life Pools
        {spell = 393262, instance = 2516, continent = DRAGON_ISLES}, -- The Nokhud Offensive
        {spell = 393267, instance = 2520, continent = DRAGON_ISLES}, -- Brackenhide Hollow
        {spell = 393273, instance = 2526, continent = DRAGON_ISLES}, -- Algeth'ar Academy
        {spell = 393276, instance = 2519, continent = DRAGON_ISLES}, -- Neltharus
        {spell = 393279, instance = 2515, continent = DRAGON_ISLES}, -- The Azure Vault
        {spell = 393283, instance = 2527, continent = DRAGON_ISLES}, -- Halls of Infusion
        {spell = 393764, instance = 1477, continent = BROKEN_ISLES}, -- Halls of Valor
        {spell = 393766, instance = 1571, continent = BROKEN_ISLES}, -- Court of Stars
        {spell = 410071, instance = 1754, continent = KUL_TIRAS}, -- Freehold
        {spell = 410074, instance = 1841, continent = ZANDALAR}, -- The Underrot
        {spell = 410078, instance = 1458, continent = BROKEN_ISLES}, -- Neltharion's Lair
        {spell = 410080, instance = 657, continent = KALIMDOR}, -- The Vortex Pinnacle
        {spell = 424142, instance = 643, continent = EASTERN_KINGDOMS}, -- Throne of the Tides
        {spell = 424153, instance = 1501, continent = BROKEN_ISLES}, -- Black Rook Hold
        {spell = 424163, instance = 1466, continent = BROKEN_ISLES}, -- Darkheart Thicket
        {spell = 424167, instance = 1862, continent = KUL_TIRAS}, -- Waycrest Manor
        {spell = 424187, instance = 1763, continent = ZANDALAR}, -- Atal'Dazar
        {spell = 424197, instance = 2579, continent = DRAGON_ISLES}, -- Dawn of the Infinite
        {spell = 432254, instance = 2522, continent = DRAGON_ISLES}, -- Vault of the Incarnates
        {spell = 432257, instance = 2569, continent = DRAGON_ISLES}, -- Aberrus
        {spell = 432258, instance = 2549, continent = DRAGON_ISLES}, -- Amirdrassil, the Dream's Hope
        {spell = 445269, instance = 2652, continent = KHAZ_ALGAR, }, -- Stonevault
        {spell = 445416, instance = 2669, continent = KHAZ_ALGAR, }, -- City of Threads
        {spell = 445418, instance = 1822, continent = KUL_TIRAS}, -- Siege of Boralus
        {spell = 445424, instance = 670, continent = EASTERN_KINGDOMS}, -- Grim Batol
        {spell = 464256, instance = 1822, continent = KUL_TIRAS}, -- Siege of Boralus
        {spell = isAlliance and 467553, instance = 1594, continent = ZANDALAR,}, -- The MOTHERLODE (alliance)
        {spell = isHorde and 467555, instance = 1594, continent = ZANDALAR,}, -- The MOTHERLODE (horde)
        {spell = 445441, instance = 2651, continent = KHAZ_ALGAR,}, -- Darkflame Cleft
        {spell = 445443, instance = 2648, continent = KHAZ_ALGAR,}, -- The Rookery
        {spell = 445440, instance = 2661, continent = KHAZ_ALGAR,}, -- Cinderbrew Meadery
        {spell = 467546, instance = 2661, continent = KHAZ_ALGAR,}, -- Cinderbrew Meadery
        {spell = 1226482, instance = 2769, continent = KHAZ_ALGAR,}, -- Liberation of Undermine

        -- Hearthstones
        {toy = 54452, category = ADDON.Category.Hearthstone},
        {toy = 64488, category = ADDON.Category.Hearthstone},
        {toy = 93672, category = ADDON.Category.Hearthstone},
        {toy = 142542, category = ADDON.Category.Hearthstone},
        {toy = 162973, category = ADDON.Category.Hearthstone},
        {toy = 163045, category = ADDON.Category.Hearthstone},
        {toy = 165669, category = ADDON.Category.Hearthstone},
        {toy = 165670, category = ADDON.Category.Hearthstone},
        {toy = 165802, category = ADDON.Category.Hearthstone},
        {toy = 166746, category = ADDON.Category.Hearthstone},
        {toy = 166747, category = ADDON.Category.Hearthstone},
        {toy = 168907, category = ADDON.Category.Hearthstone},
        {toy = 172179, category = ADDON.Category.Hearthstone},
        {toy = 180290, category = ADDON.Category.Hearthstone},
        {toy = 182773, category = ADDON.Category.Hearthstone},
        {toy = 183716, category = ADDON.Category.Hearthstone},
        {toy = 184353, category = ADDON.Category.Hearthstone},
        {toy = 184871, category = ADDON.Category.Hearthstone},
        {toy = 188952, category = ADDON.Category.Hearthstone},
        {toy = 190196, category = ADDON.Category.Hearthstone},
        {toy = 190237, category = ADDON.Category.Hearthstone},
        {toy = 193588, category = ADDON.Category.Hearthstone},
        {toy = 200630, category = ADDON.Category.Hearthstone},
        {toy = 206195, category = ADDON.Category.Hearthstone},
        {toy = 209035, category = ADDON.Category.Hearthstone},
        {toy = 208704, category = ADDON.Category.Hearthstone},
        {toy = ((playerRace == "Draenei" or playerRace == "LightforgedDraenei") and 210455), category = ADDON.Category.Hearthstone},
        {toy = 212337, category = ADDON.Category.Hearthstone},
        {toy = 228940, category = ADDON.Category.Hearthstone},
        {toy = 235016, category = ADDON.Category.Hearthstone},
        {toy = 236687, category = ADDON.Category.Hearthstone},
        {toy = 246565, category = ADDON.Category.Hearthstone}, -- Cosmic Hearthstone
        {toy = 245970, category = ADDON.Category.Hearthstone}, -- P.O.S.T. Master's Express Hearthstone
    }

    -- the actual function C_Item.DoesItemExistByID() is misleading and only checks for non empty parameter.
    -- see: https://github.com/Stanzilla/WoWUIBugs/issues/449#issuecomment-2638266396
    local function DoesItemExist(itemId)
        return C_Item.GetItemIconByID(itemId) ~= 134400 -- question icon
    end

    ADDON.db = tFilter(db, function(row)
        return (row.spell and C_Spell.DoesSpellExist(row.spell))
            or (row.item and DoesItemExist(row.item))
            or (row.toy and DoesItemExist(row.toy))
    end, true)
end