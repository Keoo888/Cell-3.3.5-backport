---------------------------------------------------------------------
-- File: Cell\RaidDebuffs\RaidDebuffs_TBC.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2022-08-05 17:45:05 +08:00
-- Modified: 2025-02-20 16:08 +08:00
---------------------------------------------------------------------

local _, Cell = ...
local F = Cell.funcs

--! WotLK fix: отсюда удалены 35 записей с id вида 21xxxxx (Ascension: Watery Tomb,
--! Sludge Nova, Focused Fire, Inner Demon, ... Fel Rage). Это спеллы кастомного
--! сервера Project Ascension, которых нет в Spell.dbc клиента 3.3.5a: GetSpellInfo
--! на такой id возвращает nil, F.GetDebuffList отбрасывает запись по `if spellName`,
--! и в окне «Дебаффы рейда» строка не появлялась НИКОГДА - молча, без ошибки, так что
--! ни один игровой прогон её найти не мог. Нашёл `dbc_probe.py --sweep` (сверка с
--! Spell.dbc из patch-enUS-3.MPQ), удаление разрешил владелец 2026-08-24. Пустые
--! ключи боссов оставлены: они и раньше в этом файле есть (GAP-037), а их удаление -
--! это уже правка видимого списка, на которую разрешения не было.

--! WotLK fix: 139 ids added on 2026-09-07 from the same fan fork the Classic file
--! quotes (ref a2f58bdf), all of them into the eight TBC raids [745]..[752]; the
--! five-man lists are untouched. Four raids shipped with every boss key present and
--! every list empty - Gruul's Lair, Magtheridon's Lair, The Eye and The Battle for
--! Mount Hyjal - so half of the raid tier had nothing to tick in the raid-debuff
--! window at all. Measured before/after for this file: 98 ids -> 237.
--! Every id was checked against the client's Spell.dbc and its label is the name the
--! database returns, not the name the fork wrote. Two rules decided what was dropped:
--! one entry per NAME inside an instance, because F.GetDebuffList keys by spell name
--! unless the id is quoted (so a second id with a name already listed in that
--! instance would silently overwrite the first), and nothing whose instance or boss
--! key our build cannot resolve.
--! Five entries keep the fork's quotes on purpose - quoted means trackByID, keyed by
--! id instead of by name: Netherspite's three beams are three different ids all named
--! "Nether Exhaustion", and both Silence entries ("37160" trash, "30225" Kael'thas)
--! carry a name far too common to key by.
--! -13444 Sunder Armor is negative on purpose: leading minus means the row is listed
--! in the options but unchecked by default, our convention for permanent melee filler
--! (same as -15502 in Molten Core).
--! Ids are appended at the end of each list, not inserted: LoadBuiltInDebuffs numbers
--! `order` by position, so appending leaves the icon priority of everything already
--! listed untouched.
--! 13005 Hammer of Justice in The Eye came from a later per-instance re-check: we had
--! the id already, but under Old Hillsbrad Foothills, and a row only ticks inside the
--! instance it is keyed under. See the same note in the Classic file.
--! WotLK fix: 2026-09-07 label pass, same as in the Classic file - every Latin-script
--! label here is now the name the client's Spell.dbc returns, checked by
--! `dbc_probe.py --labels`. Fifteen captions in this file disagreed with the client and
--! were rewritten (30753 Red Riding Hood, 30053 Amplify Flames, 38523 Netherbreath,
--! 40823 Silencing Shriek, 45256 Confounding Blow, 40321 Cyclone of Feathers, 32346
--! Stolen Soul, 33792 Exploding Shot, 33551 Corrosive Acid, 38794 Murmur's Touch, 39019
--! Complete Domination, 31481 Lung Burst, 31718 Enveloping Winds, 35107 Electrified Net,
--! 30923 Domination); Hydross also had the wrong id (38246 is Vile Sludge, the mark is
--! 38215 - both are listed now), and two names claimed twice inside one instance were
--! unstuck (37850 Watery Grave, 39661 Death Coil). Proof per record is in the registry,
--! GAP-142 in audit/STUDY_GAPS.md - the lists here stay data only. Labels are not
--! cosmetic: a bare id is keyed BY NAME, so what the client calls the id is what the
--! checkbox catches.
--! WotLK fix: 2026-09-10 pass over the same fork (HEAD 2bbdac11, data commit e18fcb23)
--! took its remaining new raid debuffs, 505 here, appended per boss; dropped only ids
--! duplicating a name/id already in that instance and out-of-era player spells. Proof: GAP-148.
local debuffs = {
    [745] = { -- Karazhan
        ["general"] = {
            37091, -- Rain of Bones
            30210, -- Smoldering Breath
            30129, -- Charred Earth
            30127, -- Searing Cinders
            36922, -- Bellowing Roar
            8379, -- Disarm
            25653, -- Tail Sweep
            29906, -- Ravage
            29901, -- Acidic Fang
            29304, -- Howl of the Broken Hills
            29303, -- Wing Beat
            29300, -- Sonic Blast
            29292, -- Frost Mist
            29293, -- Poison Bolt Volley
            29935, -- Gaping Maw
            29930, -- Curse of Agony
            29928, -- Immolate
            29923, -- Frostbolt Volley
            29922, -- Fireball Volley
            29925, -- Fireball
            29881, -- Drain Mana
            29900, -- Unstable Magic
            29717, -- Cone of Cold
            29679, -- Bad Poetry
            29673, -- Sandbag
            41580, -- Net
            29666, -- Frost Shock
            29670, -- Ice Tomb
            29490, -- Seduction
            29491, -- Impending Betrayal
            29684, -- Shield Slam
            29690, -- Drunken Skull Crack
            29583, -- Impale
            29540, -- Curse of Past Burdens
            30130, -- Distracting Ash
        },
        [1552] = { -- Servant's Quarters
        },
        [1553] = { -- Attumen the Huntsman
            29833, -- Intangible Presence
            29711, -- Knockdown
        },
        [1554] = { -- Moroes
            37066, -- Garrote
            29425, -- Gouge
            34694, -- Blind
            29570, -- Mind Flay
            13005, -- Hammer of Justice
            9080, -- Hamstring
            29572, -- Mortal Strike
        },
        [1555] = { -- Maiden of Virtue
            29511, -- Repentance
            29522, -- Holy Fire
            29512, -- Holy Ground
        },
        [1556] = { -- Opera Event
            30753, -- Red Riding Hood
            30822, -- Poisoned Thrust
            30889, -- Powerful Attraction
            30890, -- Blinding Passion
            31013, -- Frightened Scream
            31015, -- Annoying Yipping
            31046, -- Brain Bash
            31069, -- Brain Wipe
            31041, -- Mangle
            31042, -- Shred Armor
            30756, -- Little Red Riding Hood
            30752, -- Terrifying Howl
            30761, -- Wide Swipe
        },
        [1557] = { -- The Curator
            30254, -- Evocation
        },
        [1559] = { -- Shade of Aran
            29946, -- Flame Wreath
            29990, -- Slow
            29991, -- Chains of Ice
            29954, -- Frostbolt
            29951, -- Blizzard
            30035, -- Mass Slow
            29963, -- Mass Polymorph
        },
        [1560] = { -- Terestian Illhoof
            30053, -- Amplify Flames
            30115, -- Sacrifice
        },
        [1561] = { -- Netherspite
            38523, -- Netherbreath
            "38637", -- Nether Exhaustion
            "38638", -- Nether Exhaustion
            "38639", -- Nether Exhaustion
            30400, -- Nether Beam - Perseverence
            30401, -- Nether Beam - Serenity
            30402, -- Nether Beam - Dominance
            30421, -- Nether Portal - Perseverence
            30422, -- Nether Portal - Serenity
            30423, -- Nether Portal - Dominance
        },
        [1764] = { -- Chess Event
            30529, -- Recently In Game
        },
        [1563] = { -- Prince Malchezaar
            30843, -- Enfeeble
            39095, -- Amplify Damage
            30898, -- Shadow Word: Pain
            30901, -- Sunder Armor
        },
    },

    [746] = { -- 格鲁尔的巢穴
        ["general"] = {
            39171, -- Mortal Strike
            24193, -- Charge
            22884, -- Psychic Scream
        },
        [1564] = { -- 莫加尔大王
            11726, -- Enslave Demon
            33129, -- Dark Decay
            33175, -- Arcane Shock
            33061, -- Blast Wave
            33130, -- Death Coil
            16508, -- Intimidating Roar
            33173, -- Greater Polymorph
        },
        [1565] = { -- 屠龙者格鲁尔
            38927, -- Fel Ache
            36240, -- Cave In
            33652, -- Stoned
            33525, -- Ground Slam
            36297, -- Reverberation
            33572, -- Gronn Lord's Grasp
        },
    },

    [747] = { -- 玛瑟里顿的巢穴
        ["general"] = {
            34437, -- Death Coil
            34435, -- Rain of Fire
            34439, -- Unstable Affliction
            34441, -- Shadow Word: Pain
        },
        [1566] = { -- 玛瑟里顿
            44032, -- Mind Exhaustion
            30530, -- Fear
            30410, -- Shadow Grasp
            36449, -- Debris
            30657, -- Quake
        },
    },

    [748] = { -- Serpentshrine Cavern
        ["general"] = {
            39042, -- Rampant Infection
            39032, -- Initial Infection
            39044, -- Serpentshrine Parasite
            38591, -- Shatter Armor
            38634, -- Arcane Lightning
            38572, -- Mortal Cleave
            38635, -- Rain of Fire
            38491, -- Silence
            38234, -- Frost Shock
            38655, -- Poison Bolt Volley
            9080, -- Hamstring
            37284, -- Scalding Water
            38924, -- Spore Burst
            38631, -- Avenger's Shield
            38645, -- Frostbolt
            38644, -- Cone of Cold
            39029, -- Virulent Poison
            39063, -- Frost Nova
            38661, -- Net
            41932, -- Carnivorous Bite
            38718, -- Toxic Pool
        },
        [1567] = { -- Hydross
            38246, -- Vile Sludge
            38215, -- Mark of Hydross
            38235, -- Water Tomb
            38219, -- Mark of Corruption
        },
        [1568] = { -- Lurker Below
        },
        [1569] = { -- Leotheras
            37640, -- Whirlwind
            37749, -- Consuming Madness
            37676, -- Insidious Whisper
            37675, -- Chaos Blast
        },
        [1570] = { -- Karathress
            29436, -- Leeching Throw
            39261, -- Gusting Winds
            38441, -- Cataclysmic Bolt
        },
        [1571] = { -- Morogrim
            37850, -- Watery Grave
            37730, -- Tidal Wave
            37871, -- Freeze
        },
        [1572] = { -- Lady Vashj
            38280, -- Static Charge
            38316, -- Entangle
            38509, -- Shock Blast
            38575, -- Toxic Spores
        },
    },

    [749] = { -- 风暴要塞
        ["general"] = {
            37122, -- Domination
            37118, -- Shell Shock
            37133, -- Arcane Buffet
            37120, -- Fragmentation Bomb
            37123, -- Saw Blade
            37132, -- Arcane Shock
            37279, -- Rain of Fire
            "37160", -- Silence
            13005, -- Hammer of Justice
            37276, -- Mind Flay
            37275, -- Shadow Word: Pain
            37262, -- Frostbolt Volley
            37263, -- Blizzard
            37265, -- Cone of Cold
            37289, -- Dragon's Breath
            37155, -- Immolation
            37124, -- Starfall
        },
        [1573] = { -- 奥
            35410, -- Melt Armor
            34121, -- Flame Buffet
            35412, -- Charge
            35383, -- Flame Patch
        },
        [1574] = { -- 空灵机甲
            34190, -- Arcane Orb
        },
        [1575] = { -- 大星术师索兰莉安
            42783, -- Wrath of the Astromancer
            34322, -- Psychic Scream
            33390, -- Arcane Torrent
        },
        [1576] = { -- 凯尔萨斯·逐日者
            44863, -- Bellowing Roar
            37027, -- Remote Toy
            36797, -- Mind Control
            36965, -- Rend
            "30225", -- Silence
            37018, -- Conflagration
            36834, -- Arcane Disruption
            32830, -- Possess
            36970, -- Arcane Burst
            36731, -- Flame Strike
            39432, -- Gravity Lapse
            35859, -- Nether Vapor
        },
    },

    [750] = { -- 海加尔山之战
        ["general"] = {
            31610, -- Knockdown
            28991, -- Web
            31408, -- War Stomp
            33637, -- Infernal
            31724, -- Flame Buffet
            31688, -- Frost Breath
        },
        [1577] = { -- 雷基·冬寒
            31249, -- Icebolt
            31250, -- Frost Nova
            31257, -- Chilled
            31258, -- Death & Decay
        },
        [1578] = { -- 安纳塞隆
            31306, -- Carrion Swarm
            31298, -- Sleep
            31302, -- Inferno Effect
        },
        [1579] = { -- 卡兹洛加
            31447, -- Mark of Kaz'rogal
        },
        [1580] = { -- 阿兹加洛
            31347, -- Doom
            31341, -- Unquenchable Flames
            31340, -- Rain of Fire
            31344, -- Howl of Azgalor
            31406, -- Cripple
        },
        [1581] = { -- 阿克蒙德
            31972, -- Grip of the Legion
            31944, -- Doomfire
            31970, -- Fear
            32053, -- Soul Charge
        },
    },

    [751] = { -- Black Temple
        ["general"] = {
            41213, -- Throw Shield
            40864, -- Throbbing Stun
            41197, -- Shield Bash
            41171, -- Skeleton Shot
            41338, -- Love Tap
            -13444, -- Sunder Armor
            41396, -- Sleep
            41334, -- Polymorph
            24698, -- Gouge
            41150, -- Fear
            34654, -- Blind
            39674, -- Banish
            3609, -- Paralyzing Poison
            25646, -- Mortal Wound
            32588, -- Concussion Blow
            34099, -- Riposte
            39647, -- Curse of Mending
            39665, -- Wound Poison
            39672, -- Curse of Agony
            40078, -- Poison Spit
            40079, -- Debilitating Spray
            40095, -- Poison Bolt Volley
            40099, -- Vile Slime
            40103, -- Sludge Nova
            41084, -- Silencing Shot
            41092, -- Carnivorous Bite
            41115, -- Flame Shock
            41170, -- Curse of the Bleakheart
            41193, -- Cloud of Disease
            41238, -- Blood Drain
            41397, -- Confusion
            40953, -- Immolation
            32908, -- Wing Clip
            41351, -- Curse of Vitality
            41355, -- Shadow Word: Pain
            41346, -- Poisonous Throw
            41345, -- Infatuation
            40936, -- War Stomp
            41384, -- Frostbolt
            41070, -- Death Coil
            41053, -- Whirling Blade
            40090, -- Hurricane
            40082, -- Hooked Net
            39670, -- Fel Immolate
            41116, -- Frost Shock
            41182, -- Concussive Throw
            41168, -- Sonic Strike
            40877, -- Fireball
            40875, -- Freeze
            41230, -- Prophecy of Blood
            41229, -- Bloodbolt
            41274, -- Fel Stomp
            41272, -- Behemoth Charge
        },
        [1582] = { -- High Warlord Naj'entus
            39837, -- Impaling Spine
        },
        [1583] = { -- Supremus
            40253, -- Molten Flame
            41581, -- Charge
        },
        [1584] = { -- Shade of Akama
            42023, -- Rain of Fire
        },
        [1585] = { -- Teron Gorefiend
            40251, -- Shadow of Death
            40239, -- Incinerate
            40243, -- Crushing Shadows
            40327, -- Atrophy
        },
        [1586] = { -- Gurtogg Bloodboil
            40481, -- Acidic Wound
            42005, -- Bloodboil
            40491, -- Bewildering Strike
            40604, -- Fel Rage
            40599, -- Arcing Smash
            40508, -- Fel-Acid Breath
            40597, -- Eject
        },
        [1587] = { -- Reliquary of Souls
            41303, -- Soul Drain
            41410, -- Deaden
            41376, -- Spite
            41426, -- Spirit Shock
            41294, -- Fixate
        },
        [1588] = { -- Mother Shahraz
            40823, -- Silencing Shriek
            41001, -- Fatal Attraction
            40860, -- Vile Beam
        },
        [1589] = { -- Illidari Council
            41461, -- Judgement of Blood
            41485, -- Deadly Poison
            41472, -- Divine Wrath
            41468, -- Hammer of Justice
            41481, -- Flamestrike
            41541, -- Consecration
            41482, -- Blizzard
        },
        [1590] = { -- Illidan Stormrage
            41917, -- Parasitic Shadowfiend
            40932, -- Agonizing Flames
            41032, -- Shear
            40585, -- Dark Barrage
            41142, -- Aura of Dread
            40685, -- Shadow Strike
            41083, -- Paralyze
            40647, -- Shadow Prison
        },
    },

    --! WotLK fix: Зул'Аман в дампе отсутствовал целиком - см. блок missingInstances
    --! в ExpansionData/ExpansionDataOverrides.lua, там же id инстанса и id боссов.
    --! Каждый id проверен по Spell.dbc клиента (`dbc_probe.py`), подпись рядом - имя
    --! из самой базы. Принадлежность босса доказана соседством id внутри кластера
    --! энкаунтера (43143+ Халаззи, 43093..43208 Зул'джин, 42389..42398 Налоракк):
    --! серверных привязок способностей к NPC ни один офлайновый источник не хранит.
    --! Мгновенный урон без ауры (43382 Spirit Bolts, 43267 Saber Lash, 42402 Surge,
    --! 42384 Brutal Swipe, 43121 Cyclone, 43140/43215/43294 Flame Breath) и общие
    --! имена (Frenzy, Enrage, Bomb, Fire Bomb) не берутся: список дебаффов ключуется
    --! по ИМЕНИ (F.GetDebuffList), и общее имя поймало бы чужую ауру.
    [77] = { -- Zul'Aman
        ["general"] = {
            35011, -- Knockdown
            43524, -- Frost Shock
            43353, -- Infected Bite
            43357, -- Feral Swipe
            43356, -- Pounce
            9080, -- Hamstring
            12054, -- Rend
            42747, -- Crunch Armor
            42497, -- Furious Roar
            43364, -- Tranquilizing Poison
            43362, -- Electrified Net
        },
        [186] = { -- Akil'zon
            43622, -- Static Disruption
            43648, -- Electrical Storm
            43621, -- Gust of Wind
        },
        [187] = { -- Nalorakk
            42389, -- Mangle
            42397, -- Rend Flesh
            42395, -- Lacerating Slash
            42398, -- Deafening Roar
        },
        [188] = { -- Jan'alai
            43299, -- Flame Buffet
            43114, -- Fire Wall
        },
        [189] = { -- Halazzi
            43303, -- Flame Shock
            43243, -- Shred Armor
        },
        [190] = { -- Hex Lord Malacrass
            43501, -- Siphon Soul
            44131, -- Drain Power
            43545, -- Moonfire
            43428, -- Frostbolt
            43429, -- Consecration
            43432, -- Psychic Scream
            43433, -- Blind
            43461, -- Wound Poison
            43439, -- Curse of Doom
            43440, -- Rain of Fire
            43522, -- Unstable Affliction
            43441, -- Mortal Strike
            43583, -- Thunderclap
            43590, -- Psychic Wail
            43579, -- Venom Spit
            43550, -- Mind Control
            43586, -- Volatile Infection
        },
        [191] = { -- Zul'jin
            43093, -- Grievous Throw
            43095, -- Creeping Paralysis
            43149, -- Claw Rage
            43153, -- Lynx Rush
            43208, -- Flame Whirl
            43437, -- Paralyzed
        },
    },

    [752] = { -- Sunwell Plateau
        ["general"] = {
            39171, -- Mortal Strike
            46239, -- Bear Down
            46240, -- Earthquake
            46279, -- Flame Buffet
            46283, -- Death Coil
            46293, -- Corrosive Poison
            46296, -- Necrotic Poison
            46300, -- Withered Touch
            46459, -- Assassin's Mark
            46466, -- Drain Life
            46469, -- Melt Armor
            46555, -- Frost Nova
            46557, -- Slaying Shot
            46561, -- Fear
            46562, -- Mind Flay
            46681, -- Scatter Shot
            46280, -- Polymorph
            46288, -- Petrify
            46434, -- Curse of Exhaustion
            46560, -- Shadow Word: Pain
            46762, -- Shield Slam
        },
        [1591] = { -- Kalecgos
            45032, -- Curse of Boundless Agony
            45018, -- Arcane Buffet
            45029, -- Corrupting Strike
            "45001", -- Wild Magic
            "45002", -- Wild Magic
            44799, -- Frost Breath
            45122, -- Tail Lash
            44867, -- Spectral Exhaustion
        },
        [1592] = { -- Brutallus
            45150, -- Meteor Slash
            46394, -- Burn
            45185, -- Stomp
        },
        [1593] = { -- Felmyst
            45855, -- Gas Nova
            45665, -- Encapsulate
            45717, -- Fog of Corruption
            45402, -- Demonic Vapor
            45866, -- Corrosion
        },
        [1594] = { -- Eredar Twins
            45256, -- Confounding Blow
            45342, -- Conflagration
            46771, -- Flame Sear
            45270, -- Shadowfury
            45347, -- Dark Touched
            45348, -- Flame Touched
            45271, -- Dark Strike
        },
        [1595] = { -- M'uru
            45996, -- Darkness
            45944, -- Dark Fiend
            46161, -- Void Blast
        },
        [1596] = { -- Kil'jaeden
            45737, -- Flame Dart
            45641, -- Fire Bloom
            45442, -- Soul Flay
            45885, -- Shadow Spike
            45770, -- Shadow Bolt Volley
            46190, -- Curse of Agony
            45897, -- Hemorrhage
            37369, -- Hammer of Justice
            47072, -- Moonfire
        },
    },

    [248] = { -- 地狱火城墙
        ["general"] = {
            14032, -- Shadow Word: Pain
            16856, -- Mortal Strike
            20754, -- Rain of Fire
            30639, -- Carnivorous Bite
            6713, -- Disarm
            30615, -- Fear
            16244, -- Demoralizing Shout
            26141, -- Hamstring
        },
        [527] = { -- 巡视者加戈玛
            36814, -- Mortal Wound
        },
        [528] = { -- 无疤者奥摩尔
            37566, -- Bane of Treachery
            30695, -- Treacherous Aura
            35748, -- Drain Life
        },
        [529] = { -- 传令官瓦兹德
            39427, -- Bellowing Roar
        },
    },

    [252] = { -- 塞泰克大厅
        ["general"] = {
            40303, -- Spell Bomb (Anzu heroic)
            40321, -- Cyclone of Feathers (Anzu heroic)
            40184, -- Paralyzing Screech
            33967, -- Thunderclap
            32901, -- Carnivorous Bite
            17503, -- Frostbolt
            32690, -- Arcane Lightning
            32129, -- Faerie Fire
            27641, -- Fear
            32651, -- Howling Screech
            32682, -- Curse of the Dark Talon
            32674, -- Avenger's Shield
            32654, -- Talon of Justice
            18144, -- Swoop
            16145, -- Sunder Armor
            38056, -- Flesh Rip
        },
        [541] = { -- 黑暗编织者塞斯
            21401, -- Frost Shock
            34354, -- Flame Shock
            37132, -- Arcane Shock
        },
        [543] = { -- 利爪之王艾吉斯
            12826, -- Polymorph
            35032, -- Slow
        },
    },

    [247] = { -- 奥金尼地穴
        ["general"] = {
            35839, -- Drain Soul
            32863, -- Seed of Corruption
            32860, -- Shadow Bolt
            32859, -- Falter
            31975, -- Serpent Sting
            37551, -- Viper Sting
            15043, -- Frostbolt
            15744, -- Blast Wave
        },
        [523] = { -- 死亡观察者希尔拉克
            36383, -- Carnivorous Bite
            32264, -- Inhibit Magic
        },
        [524] = { -- 大主教玛拉达尔
            32346, -- Stolen Soul
            32421, -- Soul Scream
            37328, -- Moonfire
            37330, -- Mind Flay
            37331, -- Hemorrhage
            37332, -- Frost Shock
            37334, -- Curse of Agony
            37335, -- Mortal Strike
            37369, -- Hammer of Justice
            58840, -- Blood Plague
        },
    },

    [260] = { -- 奴隶围栏
        ["general"] = {
            45947, -- Slip
            35280, -- Domination
            32193, -- Lightning Cloud
            32173, -- Entangling Roots
            19134, -- Frightening Shout
            16145, -- Sunder Armor
            13738, -- Rend
            12675, -- Frostbolt
            15531, -- Frost Nova
            33787, -- Cripple
            9080, -- Hamstring
            15655, -- Shield Slam
            16005, -- Rain of Fire
            17883, -- Immolate
            34984, -- Psychic Horror
            36872, -- Deadly Poison
            6754, -- Slap!
            16172, -- Head Crack
            21096, -- Blizzard
            31551, -- Piercing Jab
            31555, -- Decayed Intellect
            34672, -- Magma Splash
            35760, -- Decayed Strength
        },
        [570] = { -- 背叛者门努
            31983, -- Earthgrab
        },
        [571] = { -- 巨钳鲁克玛尔
            38801, -- Grievous Wound
            31948, -- Ensnaring Moss
        },
        [572] = { -- 夸格米拉
            34780, -- Poison Bolt Volley
            38153, -- Acid Spray
        },
    },

    [262] = { -- 幽暗沼泽
        ["general"] = {
            12675, -- Frostbolt
            15531, -- Frost Nova
            31405, -- Corruption
            32327, -- Spore Explosion
            32065, -- Fungal Decay
            32330, -- Poison Spit
            34984, -- Psychic Horror
            31407, -- Viper Sting
            31410, -- Coral Cut
            31427, -- Allergies
        },
        [576] = { -- 霍加尔芬
            34971, -- Frenzy (Claw)
            31615, -- Hunter's Mark
            31689, -- Spore Cloud
        },
        [577] = { -- 加兹安
            34268, -- Acid Breath
        },
        [578] = { -- 沼地领主穆塞雷克
            34974, -- Multi-Shot
            31429, -- Echoing Roar
            31932, -- Freezing Trap Effect
        },
        [579] = { -- 黑色阔步者
            31715, -- Static Charge
            31717, -- Chain Lightning
            31719, -- Suspension
            31704, -- Levitate
        },
    },

    [251] = { -- 旧希尔斯布莱德丘陵
        ["general"] = {
            9080, -- Hamstring
            16856, -- Mortal Strike
            12024, -- Net
            15654, -- Shadow Word: Pain
            22884, -- Psychic Scream
            3396, -- Corrosive Poison
            17174, -- Concussive Shot
            35511, -- Serpent Sting
            32588, -- Concussion Blow
        },
        [538] = { -- 德拉克中尉
            33792, -- Exploding Shot
            33789, -- Frightening Shout
        },
        [539] = { -- 斯卡洛克上尉
            13005, -- Hammer of Justice
            38385, -- Consecration
        },
        [540] = { -- 时空猎手
            31914, -- Sand Breath
            31916, -- Impending Death
        },
    },

    [253] = { -- 暗影迷宫
        ["general"] = {
            20615, -- Intercept
            16856, -- Mortal Strike
            19134, -- Frightening Shout
            12675, -- Frostbolt
            15063, -- Frost Nova
            33487, -- Addle Humanoid
            9574, -- Flame Buffet
            12540, -- Gouge
            31865, -- Seduction
            30849, -- Spell Lock
            32863, -- Seed of Corruption
            33502, -- Brain Wash
            17165, -- Mind Flay
            14032, -- Shadow Word: Pain
            33480, -- Black Cleave
            11428, -- Knockdown
            6713, -- Disarm
        },
        [544] = { -- 赫尔默大使
            33551, -- Corrosive Acid
            33547, -- Fear
        },
        [545] = { -- 煽动者布莱卡特
            33676, -- Incite Chaos
            33709, -- Charge
        },
        [546] = { -- 沃匹尔大师
            38791, -- Banish
            33617, -- Rain of Fire
        },
        [547] = { -- 摩摩尔
            38794, -- Murmur's Touch
            33657, -- Resonance
            33666, -- Sonic Boom
            33686, -- Shockwave
        },
    },

    [250] = { -- 法力陵墓
        ["general"] = {
            34942, -- Shadow Word: Pain
            17883, -- Immolate
            17145, -- Blast Wave
            13323, -- Polymorph
            25602, -- Faerie Fire
            34322, -- Psychic Scream
            34922, -- Shadows Embrace
            34925, -- Curse of Impotence
            38065, -- Death Coil
            34940, -- Gouge
            33925, -- Phantom Strike
            25603, -- Slow
            22911, -- Charge
            32315, -- Soul Strike
            33865, -- Singe
        },
        [534] = { -- 潘德莫努斯
            38759, -- Dark Shell
        },
        [535] = { -- 塔瓦洛克
            32361, -- Crystal Prison
            33919, -- Earthquake
        },
        [537] = { -- 节点亲王沙法尔
            32365, -- Frost Nova
            32364, -- Frostbolt
        },
    },

    [257] = { -- 生态船
        ["general"] = {
            16427, -- Virulent Poison
            34353, -- Frost Shock
            34354, -- Flame Shock
            34800, -- Impending Coma
            32323, -- Charge
            34856, -- Bloodburn
            18144, -- Swoop
            34616, -- Deadly Poison
            22127, -- Entangling Roots
            34639, -- Polymorph
            34642, -- Death & Decay
            34358, -- Vial of Poison
            34643, -- Corrode Armor
        },
        [558] = { -- 指挥官萨拉妮丝
            34794, -- Arcane Resonance
        },
        [559] = { -- 高级植物学家弗雷温
        },
        [560] = { -- 看管者索恩格林
            34661, -- Sacrifice
        },
        [561] = { -- 拉伊
            34697, -- Allergic Reaction
        },
        [562] = { -- 迁跃扭木
            34716, -- Stomp
        },
    },

    [259] = { -- 破碎大厅
        ["general"] = {
            12542, -- Fear
            22911, -- Charge
            30989, -- Hamstring
            30481, -- Incendiary Shot
            37551, -- Viper Sting
            36020, -- Curse of the Shattered Hand
            30494, -- Sticky Ooze
            16856, -- Mortal Strike
            30986, -- Cheap Shot
            30981, -- Crippling Poison
            11990, -- Rain of Fire
            36023, -- Deathblow
            32588, -- Concussion Blow
            34100, -- Volley
            30932, -- Impaling Bolt
            30639, -- Carnivorous Bite
        },
        [566] = { -- 高阶术士奈瑟库斯
            "39661", -- Death Coil (second rank)
            30500, -- Death Coil
            30502, -- Dark Spin
            30478, -- Hemorrhage
        },
        [568] = { -- 战争使者沃姆罗格
            30618, -- Beatdown
            30600, -- Blast Wave
            30633, -- Thunderclap
        },
        [569] = { -- 酋长卡加斯·刃拳
        },
    },

    [254] = { -- 禁魔监狱
        ["general"] = {
            36866, -- Domination
            36617, -- Gaping Maw
            36786, -- Soul Chill
            37480, -- Bind
            15654, -- Shadow Word: Pain
            36829, -- Hell Rain
            36831, -- Curse of the Elements
            36827, -- Hooked Net
            23601, -- Scatter Shot
            36984, -- Serpent Sting
            35935, -- Immolation
            38942, -- Frost Arrow
            36835, -- War Stomp
            36840, -- Polymorph
            36839, -- Impairing Poison
            36862, -- Gouge
            36887, -- Deafening Roar
            13704, -- Psychic Scream
            36742, -- Fireball Volley
            36741, -- Frostbolt Volley
            36655, -- Drain Life
        },
        [548] = { -- 自由的瑟雷凯斯
            39367, -- Seed of Corruption
        },
        [549] = { -- 末日预言者达尔莉安
            39009, -- Gift of the Doomsayer
            39016, -- Shadow Wave
        },
        [550] = { -- 天怒预言者苏克拉底
            35759, -- Felfire Shock
            36512, -- Knock Away
        },
        [551] = { -- 预言者斯克瑞斯
            39017, -- Mind Rend
            39019, -- Complete Domination
            39415, -- Fear
        },
    },

    [258] = { -- 能源舰
        ["general"] = {
            35318, -- Saw Blade
            35011, -- Knockdown
            35189, -- Solar Strike
            15708, -- Mortal Strike
            12531, -- Chilling Touch
            32863, -- Seed of Corruption
            35185, -- Melt Armor
            36333, -- Anesthetic
            35178, -- Shield Bash
            35183, -- Unstable Affliction
            35055, -- The Claw
            35056, -- Glob of Machine Fluid
            35049, -- Pound
            35267, -- Solarburn
            35311, -- Stream of Machine Fluid
        },
        [563] = { -- 机械领主卡帕西图斯
            35161, -- Head Crack
            "39088", -- Positive Charge
            "39091", -- Negative Charge
        },
        [564] = { -- 灵术师塞比瑟蕾
            45195, -- Frost Attack
        },
        [565] = { -- 计算者帕萨雷恩
            35280, -- Domination
            35250, -- Dragon's Breath
            35314, -- Arcane Blast
            35268, -- Inferno
            36022, -- Arcane Torrent
        },
    },

    [261] = { -- 蒸汽地窟
        ["general"] = {
            11831, -- Frost Nova
            37272, -- Poison Bolt
            32065, -- Fungal Decay
            12675, -- Frostbolt
            31581, -- Blizzard
            6533, -- Net
            6713, -- Disarm
            10987, -- Geyser
            22582, -- Frost Shock
            8281, -- Sonic Burst
            35106, -- Arcane Flare
            38660, -- Fear
        },
        [573] = { -- 水术师瑟丝比娅
            31481, -- Lung Burst
            31718, -- Enveloping Winds
            25033, -- Lightning Cloud
        },
        [574] = { -- 机械师斯蒂里格
            35107, -- Electrified Net
        },
        [575] = { -- 督军卡利瑟里斯
            16172, -- Head Crack
            31534, -- Spell Reflection
            36453, -- Warlord's Rage
            39061, -- Impale
        },
    },

    [249] = { -- 魔导师平台
        ["general"] = {
            44267, -- Immolate
            15043, -- Frostbolt
            44547, -- Deadly Embrace
            35965, -- Frost Arrow
            44504, -- Wretched Frostbolt
            44534, -- Wretched Strike
            44600, -- Injected Poison
            44482, -- Judgement of Wrath
            44765, -- Banish
        },
        [530] = { -- 塞林·火心
            44294, -- Drain Life
            46153, -- Drain Mana
        },
        [531] = { -- 维萨鲁斯
            44335, -- Energy Feedback
            44319, -- Arcane Shock
            44353, -- Overload
        },
        [532] = { -- 女祭司德莉希亚
            44141, -- Seed of Corruption
            13323, -- Polymorph
            14032, -- Shadow Word: Pain
            27615, -- Kidney Shot
            12540, -- Gouge
            14875, -- Curse of Agony
            38595, -- Fear
            11428, -- Knockdown
            46182, -- Snap Kick
            44178, -- Blizzard
            38384, -- Cone of Cold
            20615, -- Intercept
            27581, -- Disarm
            23600, -- Piercing Howl
            19134, -- Frightening Shout
            27584, -- Hamstring
            44268, -- Mortal Strike
            27634, -- Concussive Shot
            44286, -- Wing Clip
            46026, -- War Stomp
            21401, -- Frost Shock
            44138, -- Rocket Launch
            46024, -- Fel Iron Bomb
        },
        [533] = { -- 凯尔萨斯·逐日者
            36819, -- Pyroblast
            44190, -- Flame Strike
            44227, -- Gravity Lapse
        },
    },

    [256] = { -- 鲜血熔炉
        ["general"] = {
            30938, -- Corruption
            58747, -- Intercept
            16102, -- Flamestrike
            15655, -- Shield Slam
            34969, -- Poison
            30832, -- Kidney Shot
            6726, -- Silence
            31865, -- Seduction
        },
        [555] = { -- 制造者
            30923, -- Domination
            20276, -- Knockdown
            25772, -- Mental Domination
            38153, -- Acid Spray
        },
        [556] = { -- 布洛戈克
            30916, -- Poison Cloud
            30917, -- Poison Bolt
            22427, -- Concussion Blow
        },
        [557] = { -- 击碎者克里丹
            30940, -- Burning Nova
            30937, -- Mark of Shadow
        },
    },

    [255] = { -- 黑色沼泽
        ["general"] = {
            31473, -- Sand Breath
            12675, -- Frostbolt
            36277, -- Pyroblast
            36278, -- Blast Wave
            13323, -- Polymorph
            36276, -- Curse of Vulnerability
            12542, -- Fear
            15063, -- Frost Nova
            9080, -- Hamstring
            16145, -- Sunder Armor
            11428, -- Knockdown
            15708, -- Mortal Strike
            14874, -- Rupture
            30981, -- Crippling Poison
            30832, -- Kidney Shot
            38520, -- Deadly Poison
            34366, -- Ebon Poison
        },
        [552] = { -- 时空领主德亚
            31467, -- Time Lapse
        },
        [553] = { -- 坦普卢斯
            31458, -- Hasten
            38592, -- Spell Reflection
            31464, -- Mortal Wound
        },
        [554] = { -- 埃欧努斯
            37605, -- Enrage
            31422, -- Time Stop
        },
    },
}

-- WotLK Fix: Defer loading until F.LoadBuiltInDebuffs is available
if F.LoadBuiltInDebuffs then
    F.LoadBuiltInDebuffs(debuffs)
else
    Cell.RegisterCallback("RaidDebuffsReady", "RaidDebuffs_TBC_LoadBuiltIn", function()
        if F.LoadBuiltInDebuffs then
            F.LoadBuiltInDebuffs(debuffs)
        end
    end)
end
