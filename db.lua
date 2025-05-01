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
    local WW_S2 = 25
    local currentSeason = C_SeasonInfo and C_SeasonInfo.GetCurrentDisplaySeasonID() or 0

    local isClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

    local isAlliance = UnitFactionGroup("player") == "Alliance"
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
        {item = 21711, map = isClassic and 1450 or 80, continent = KALIMDOR}, -- Lunar Festival Invitation
        {item = 22589, map = 350, continent = EASTERN_KINGDOMS}, -- Atiesh, Greatstaff of the Guardian
        {item = 22630, map = 350, continent = EASTERN_KINGDOMS}, -- Atiesh, Greatstaff of the Guardian
        {item = 22631, map = 350, continent = EASTERN_KINGDOMS}, -- Atiesh, Greatstaff of the Guardian
        {item = 22632, map = 350, continent = EASTERN_KINGDOMS}, -- Atiesh, Greatstaff of the Guardian
        {item = 32757, map = 339, continent = OUTLAND}, -- Blessed Medallion of Karabor
        {item = 37863, map = isClassic and 242 or 35, continent = EASTERN_KINGDOMS}, -- Direbrew's Remote
        {item = 40585, map = 125, continent = NORTHREND}, -- Signet of the Kirin Tor
        {item = 40586, map = 125, continent = NORTHREND}, -- Band of the Kirin Tor
        {item = 44934, map = 125, continent = NORTHREND}, -- Loop of the Kirin Tor
        {item = 44935, map = 125, continent = NORTHREND}, -- Ring of the Kirin Tor
        {item = 45688, map = 125, continent = NORTHREND}, -- Inscribed Band of the Kirin Tor
        {item = 45689, map = 125, continent = NORTHREND}, -- Inscribed Loop of the Kirin Tor
        {item = 45690, map = 125, continent = NORTHREND}, -- Inscribed Ring of the Kirin Tor
        {item = 45691, map = 125, continent = NORTHREND}, -- Inscribed Signet of the Kirin Tor
        {item = 46874, map = 118, continent = NORTHREND}, -- Argent Crusader's Tabard
        {item = 48954, map = 125, continent = NORTHREND}, -- Etched Band of the Kirin Tor
        {item = 48955, map = 125, continent = NORTHREND}, -- Etched Loop of the Kirin Tor
        {item = 48956, map = 125, continent = NORTHREND}, -- Etched Ring of the Kirin Tor
        {item = 48957, map = 125, continent = NORTHREND}, -- Etched Signet of the Kirin Tor
        {item = 50287, map = 210, continent = EASTERN_KINGDOMS}, -- Boots of the Bay
        {item = 51557, map = 125, continent = NORTHREND}, -- Runed Signet of the Kirin Tor
        {item = 51558, map = 125, continent = NORTHREND}, -- Runed Loop of the Kirin Tor
        {item = 51559, map = 125, continent = NORTHREND}, -- Runed Ring of the Kirin Tor
        {item = 51560, map = 125, continent = NORTHREND}, -- Runed Band of the Kirin Tor
        {item = 52251, map = 125, continent = NORTHREND}, -- Jaina's Locket
        {item = 63206, map = isClassic and 1453 or 84, continent = EASTERN_KINGDOMS}, -- Wrap of Unity
        {item = 63207, map = isClassic and 1454 or 85, continent = KALIMDOR}, -- Wrap of Unity
        {item = 63352, map = isClassic and 1453 or 84, continent = EASTERN_KINGDOMS}, -- Shroud of Cooperation
        {item = 63353, map = isClassic and 1454 or 85, continent = KALIMDOR}, -- Shroud of Cooperation
        {item = 63378, map = 245, continent = EASTERN_KINGDOMS}, -- Hellscream's Reach Tabard
        {item = 63379, map = 245, continent = EASTERN_KINGDOMS}, -- Baradin's Wardens Tabard
        {item = 65274, map = isClassic and 1454 or 85, continent = KALIMDOR}, -- Cloak of Coordination
        {item = 65360, map = isClassic and 1453 or 84, continent = EASTERN_KINGDOMS}, -- Cloak of Coordination
        {item = 95050, map = 503, continent = KALIMDOR}, -- The Brassiest Knuckle
        {item = 95051, map = 500, continent = EASTERN_KINGDOMS}, -- The Brassiest Knuckle
        {item = 103678, map = 554, continent = PANDARIA}, -- Time-Lost Artifact
        {item = 118662, map = 624, continent = DRAENOR}, -- Bladespire Relic
        {item = 118663, map = 622, continent = DRAENOR}, -- Relic of Karabor
        {item = 118907, map = 500, continent = EASTERN_KINGDOMS}, -- Pit Fighter's Punching Ring
        {item = 118908, map = 503, continent = KALIMDOR}, -- Pit Fighter's Punching Ring
        {item = 128353, map = (isAlliance and 539 or 525), continent = DRAENOR}, -- Admiral's Compass
        {item = 138448, map = 627, continent = BROKEN_ISLES}, -- Emblem of Margoss
        {item = 139590, map = 25, continent = EASTERN_KINGDOMS}, -- Scroll of Teleport: Ravenholdt
        {item = 139599, map = 627, continent = BROKEN_ISLES}, -- Empowered Ring of the Kirin Tor
        {item = 142469, map = 350, continent = EASTERN_KINGDOMS}, -- Violet Seal of the Grand Magus
        {item = 144391, map = 500, continent = EASTERN_KINGDOMS}, -- Pugilist's Powerful Punching Ring
        {item = 144392, map = 503, continent = KALIMDOR}, -- Pugilist's Powerful Punching Ring
        {item = 166559, map = 1165, continent = ZANDALAR}, -- Commander's Signet of Battle
        {item = 166560, map = 1161, continent = KUL_TIRAS}, --Captain's Signet of Command
        {item = 202046, map = 942, continent = KUL_TIRAS}, -- Lucky Tortollan Charm
        {item = 219222, map = 554, continent = PANDARIA}, -- Time-Lost Artifact
        {toy = 110560, map = (isAlliance and 582 or 590), continent = DRAENOR}, -- Garrison Hearthstone
        {toy = 140192, map = 627, continent = BROKEN_ISLES}, -- Dalaran Hearthstone
        {toy = 151016, map = 104, continent = OUTLAND}, -- Fractured Necrolyte Skull
        {toy = (playerRace == "Worgen" and 211788), map = 179, continent = EASTERN_KINGDOMS}, -- Tess's Peacebloom

        {spell = 50977,
         map = isClassic and 1423 or 648,
         continent = LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_LEGION and BROKEN_ISLES or EASTERN_KINGDOMS
        }, -- Archerus (DK)
        {spell = 126892, map = C_QuestLog.IsQuestFlaggedCompleted(40236) and 709 or 379}, -- Zen Pilgrimage  (Monk)
        {spell = 193759, map = 734, continent = BROKEN_ISLES}, -- Hall of the guardian (Mage)

        -- Druid Dreamwalk
        {spell = 18960, map = isClassic and 1450 or 80, continent = KALIMDOR},
        {spell = 193753, map = 26, continent = EASTERN_KINGDOMS},
        {spell = 193753, map = 47, continent = EASTERN_KINGDOMS},
        {spell = 193753, map = 69, continent = KALIMDOR},
        {spell = 193753, map = isClassic and 1450 or 80, continent = KALIMDOR},
        {spell = 193753, map = 116, continent = NORTHREND},
        {spell = 193753, map = 198, continent = KALIMDOR},
        {spell = 193753, map = 747, continent = BROKEN_ISLES},

        -- Mage Teleports with Portals
        -- https://www.wowhead.com/guide/transportation#mage-portals
        {spell = 3561, portal = 10059, map = isClassic and 1453 or 84, continent = EASTERN_KINGDOMS}, -- Stormwind
        {spell = 3562, portal = 11416, map = isClassic and 1455 or 87, continent = EASTERN_KINGDOMS}, -- Ironforge
        {spell = 3563, portal = 11418, map = isClassic and 1458 or 90, continent = EASTERN_KINGDOMS}, -- Undercity
        {spell = 3565, portal = 11419, map = isClassic and 1457 or 89, continent = KALIMDOR}, -- Darnassus
        {spell = 3566, portal = 11420, map = isClassic and 1456 or 88, continent = KALIMDOR}, -- Thunder Bluff
        {spell = 3567, portal = 11417, map = isClassic and 1454 or 85, continent = KALIMDOR}, -- Orgrimmar
        {spell = 32271, portal = 32266, map = isClassic and 1947 or 103, continent = KALIMDOR}, -- Exodar
        {spell = 32272, portal = 32267, map = isClassic and 1954 or 110, continent = EASTERN_KINGDOMS}, -- Silvermoon
        {spell = 35715, portal = 35717, map = isClassic and 1955 or 111, continent = OUTLAND}, -- Shattrath
        {spell = 33690, portal = 33691, map = isClassic and 1955 or 111, continent = OUTLAND}, -- Shattrath
        {spell = 49358, portal = 49361, map = isClassic and 1435 or 51, continent = EASTERN_KINGDOMS}, -- Stonard
        {spell = 49359, portal = 49360, map = isClassic and 1445 or 70, continent = KALIMDOR}, -- Theramore
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
        {spell = 265225, map = isClassic and 1455 or 87, continent = EASTERN_KINGDOMS}, -- Ironforge
        {spell = 265225, map = isClassic and 1453 or 84, continent = EASTERN_KINGDOMS}, -- Stormwind
        {spell = 265225, map = 243, continent = EASTERN_KINGDOMS}, -- Shadowforge City
        {spell = 265225, quest = 53594, map = 17, continent = EASTERN_KINGDOMS}, -- Blasted Lands
        {spell = 265225, quest = 53585, map = 26, continent = EASTERN_KINGDOMS}, -- The Hinterlands
        {spell = 265225, quest = 53587, map = 35, continent = EASTERN_KINGDOMS}, -- Blackrock Mountain
        {spell = 265225, quest = 53591, map = 78, continent = KALIMDOR}, -- Un'Goro Crater
        {spell = 265225, quest = 53601, map = 198, continent = KALIMDOR}, -- Mount Hyjal
        {spell = 265225, quest = 53600, map = 199, continent = KALIMDOR}, -- Southern Barrens
        {spell = 265225, quest = 53592, map = 100, continent = OUTLAND}, -- Hellfire Peninsula
        {spell = 265225, quest = 53599, map = 104, continent = OUTLAND}, -- Shadowmoon Valley
        {spell = 265225, quest = 53597, map = 105, continent = OUTLAND}, -- Blade's Edge Mountains
        {spell = 265225, quest = 53586, map = 118, continent = NORTHREND}, -- Icecrown
        {spell = 265225, quest = 53596, map = 115, continent = NORTHREND}, -- Dragonblight
        {spell = 265225, quest = 53595, map = 379, continent = PANDARIA}, -- Kun-Lai Summit
        {spell = 265225, quest = 53598, map = 376, continent = PANDARIA}, -- Valley of the Four Winds
        {spell = 265225, quest = 53588, map = 543, continent = DRAENOR}, -- Gorgond
        {spell = 265225, quest = 53590, map = 550, continent = DRAENOR}, -- Nagrand
        {spell = 265225, quest = 53593, map = 650, continent = BROKEN_ISLES}, -- Highmountain
        {spell = 265225, quest = 53589, map = 646, continent = BROKEN_ISLES}, -- Broken Shore
        {spell = 265225, quest = 80099, map = 863, continent = ZANDALAR}, -- Nazmir
        {spell = 265225, quest = 80100, map = 862, continent = ZANDALAR}, -- Zuldazar
        {spell = 265225, quest = 80101, map = 895, continent = KUL_TIRAS}, -- Tiragarde Sound
        {spell = 265225, quest = 80102, map = 942, continent = KUL_TIRAS}, -- Stormsong Valley
        {spell = 265225, quest = 80103, map = 1536, continent = SHADOWLANDS}, -- Maldraxxus
        {spell = 265225, quest = 80104, map = 1525, continent = SHADOWLANDS}, -- Revendreth
        {spell = 265225, quest = 80105, map = 1533, continent = SHADOWLANDS}, -- Bastion
        {spell = 265225, quest = 80106, map = 1565, continent = SHADOWLANDS}, -- Ardenweald
        {spell = 265225, quest = 80107, map = 2022, continent = DRAGON_ISLES}, -- Waking Shores
        {spell = 265225, quest = 80108, map = 2024, continent = DRAGON_ISLES}, -- Azure Span
        {spell = 265225, quest = 80109, map = 2133, continent = DRAGON_ISLES}, -- Zaralek Cavern

        -- Engineering Items
        {toy = isEngineer and 18984, map = isClassic and 1452 or 83, continent = KALIMDOR}, -- Dimensional Ripper - Everlook
        {toy = isEngineer and 18986, map = isClassic and 1446 or 71, continent = KALIMDOR}, -- Ultrasafe Transporter: Gadgetzan
        {toy = isEngineer and 30542, map = isClassic and 1953 or 109, continent = OUTLAND}, -- Dimensional Ripper - Area 52
        {toy = isEngineer and 30544, map = isClassic and 1949 or 105, continent = OUTLAND}, -- Ultrasafe Transporter: Toshley's Station
        {toy = isEngineer and 48933, map = 114, continent = NORTHREND}, -- Wormhole Generator: Northrend
        {toy = isEngineer and 48933, map = 117, continent = NORTHREND}, -- Wormhole Generator: Northrend
        {toy = isEngineer and 48933, map = 118, continent = NORTHREND}, -- Wormhole Generator: Northrend
        {toy = isEngineer and 48933, map = 119, continent = NORTHREND}, -- Wormhole Generator: Northrend
        {toy = isEngineer and 48933, map = 120, continent = NORTHREND}, -- Wormhole Generator: Northrend
        {toy = isEngineer and 87215, map = 371, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 376, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 379, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 388, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 390, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 418, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 87215, map = 422, continent = PANDARIA}, -- Wormhole Generator: Pandaria
        {toy = isEngineer and 112059, map = 525, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 112059, map = 535, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 112059, map = 539, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 112059, map = 542, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 112059, map = 543, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 112059, map = 550, continent = DRAENOR}, -- Wormhole Centrifuge
        {toy = isEngineer and 151652, map = 994, continent = BROKEN_ISLES}, -- Wormhole Generator: Argus
        {toy = isEngineer and 168807, map = 992, continent = KUL_TIRAS}, -- Wormhole Generator: Kul Tiras
        {toy = isEngineer and 168808, map = 991, continent = ZANDALAR}, -- Wormhole Generator: Zandalar
        {toy = isEngineer and 172924, map = 1525, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 172924, map = 1536, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 172924, map = 1543, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 172924, map = 1565, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 172924, map = 1569, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 172924, map = 1670, continent = SHADOWLANDS}, -- Wormhole Generator: Shadowlands
        {toy = isEngineer and 198156, map = 2022, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 198156, map = 2023, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 198156, map = 2024, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 198156, map = 2025, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 198156, map = 2133, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 198156, map = 2200, continent = DRAGON_ISLES}, -- Wormhole Generator: Dragon Isles
        {toy = isEngineer and 221966, map = 2214, continent = KHAZ_ALGAR}, -- Wormhole Generator: Khaz Algar
        {toy = isEngineer and 221966, map = 2215, continent = KHAZ_ALGAR}, -- Wormhole Generator: Khaz Algar
        {toy = isEngineer and 221966, map = 2248, continent = KHAZ_ALGAR}, -- Wormhole Generator: Khaz Algar
        {toy = isEngineer and 221966, map = 2255, continent = KHAZ_ALGAR}, -- Wormhole Generator: Khaz Algar
        {toy = isEngineer and 221966, quest = 86630, map = 2346, continent = KHAZ_ALGAR}, -- Wormhole Generator: Khaz Algar

        -- Seasonal Dungeon Port
        {spell = 354467, instance = 2293, continent = SHADOWLANDS, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Theater of Pain
        {spell = 373274, instance = 2097, continent = KUL_TIRAS, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Operation: Mechagon
        {spell = 445441, instance = 2651, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Darkflame Cleft
        {spell = 445443, instance = 2648, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- The Rookery
        {spell = 445444, instance = 2649, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Priory of the Sacred Flame
        {spell = 445440, instance = 2661, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Cinderbrew Meadery
        {spell = 467546, instance = 2661, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Cinderbrew Meadery
        {spell = 1216786, instance = 2773, continent = KHAZ_ALGAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- Operation: Floodgate
        {spell = isAlliance and 467553, instance = 1594, continent = ZANDALAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- The MOTHERLODE (alliance)
        {spell = false == isAlliance and 467555, instance = 1594, continent = ZANDALAR, category = (currentSeason == WW_S2 and ADDON.Category.SeasonInstance)}, -- The MOTHERLODE (horde)

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
        {spell = 354465, instance = 2287, continent = SHADOWLANDS}, -- Halls of Atonement
        {spell = 354466, instance = 2285, continent = SHADOWLANDS}, -- Spires of Ascension
        {spell = 354468, instance = 2291, continent = SHADOWLANDS}, -- De Other Side
        {spell = 354469, instance = 2284, continent = SHADOWLANDS}, -- Sanguine Depths
        {spell = 367416, instance = 2441, continent = SHADOWLANDS}, -- Tazavesh the Veiled Market
        {spell = 373190, instance = 2296, continent = SHADOWLANDS}, -- Castle Nathria
        {spell = 373191, instance = 2450, continent = SHADOWLANDS}, -- Sanctum of Domination
        {spell = 373192, instance = 2481, continent = SHADOWLANDS}, -- Sepulcher of the First Ones
        {spell = 373262, instance = 532, continent = EASTERN_KINGDOMS}, -- Karazhan
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
        {spell = 445418, instance = 1822, continent = KUL_TIRAS}, -- Siege of Boralus
        {spell = 445424, instance = 670, continent = EASTERN_KINGDOMS}, -- Grim Batol
        {spell = 464256, instance = 1822, continent = KUL_TIRAS}, -- Siege of Boralus
        {spell = 445416, instance = 2669, continent = KHAZ_ALGAR, }, -- City of Threads
        {spell = 445417, instance = 2660, continent = KHAZ_ALGAR, }, -- Ara Kara: City of Echoes
        {spell = 445414, instance = 2662, continent = KHAZ_ALGAR, }, -- The Dawnbreaker
        {spell = 445269, instance = 2652, continent = KHAZ_ALGAR, }, -- Stonevault

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
    }

    ADDON.db = tFilter(db, function(row)
        return row.toy or row.spell or row.item
    end, true)
end