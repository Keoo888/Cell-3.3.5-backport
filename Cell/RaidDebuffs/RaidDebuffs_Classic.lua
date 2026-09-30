---------------------------------------------------------------------
-- File: Cell\RaidDebuffs\RaidDebuffs_Classic.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2022-08-05 17:46:11 +08:00
-- Modified: 2025-12-01 04:11 +08:00
---------------------------------------------------------------------

local _, Cell = ...
local F = Cell.funcs

local debuffs = {
    --! WotLK fix: the last three Molten Core encounters shipped empty, and several
    --! of the others were missing most of what actually lands on the raid. Filled in
    --! from the fan fork (reference/cell_NoM0Re) after checking every id against the
    --! client's own Spell.dbc (`dbc_probe.py`) - the label next to each id is the name
    --! the client returns, not a retelling.
    --! Two rules decided what is NOT here, both of them consequences of how the list
    --! is consumed: F.GetDebuffList matches a bare id BY NAME, so a second id sharing
    --! a name already in the list is dead weight (20294 Immolate next to 15732), and a
    --! boss self-buff can never appear on a player at all. The fork's 47836 Seed of
    --! Corruption and 55360 Living Bomb are dropped for a third reason: those are the
    --! WotLK warlock and mage player spells, not anything Majordomo casts.
    --! A leading minus means "listed in the options, unchecked by default" (upstream's
    --! own convention, see RaidDebuffs_WotLK.lua). Used for the melee filler that sits
    --! on the tank permanently - having Sunder Armor light up the raid-debuff icon for
    --! the whole instance is worse than not having it.
    --! WotLK fix: second pass over the same fork on 2026-09-06 brought 44 more ids, all
    --! of them into ["general"] lists. Eight instances had nothing at all to tick in the
    --! raid-debuff window: Shadowfang Keep, Maraudon, Razorfen Downs, Sunken Temple,
    --! Uldaman, Wailing Caverns, Scarlet Monastery and Ruins of Ahn'Qiraj. Five more had
    --! their bosses but no trash abilities: Deadmines, Razorfen Kraul, Stratholme,
    --! Blackwing Lair, Temple of Ahn'Qiraj. Same checks as above - every id exists in the
    --! client's Spell.dbc and carries the name the database returns, one entry per NAME
    --! inside an instance, nothing whose instance or boss key our build cannot resolve.
    --! Ids are appended at the end of each list on purpose: LoadBuiltInDebuffs numbers
    --! `order` by position, so appending leaves the icon priority of everything already
    --! listed untouched.
    --! Ragefire Chasm, Blackfathom Deeps, Blackrock Depths, Gnomeregan, The Stockade,
    --! Scholomance and Scarlet Halls are still empty because the fork has them empty too.
    --! Zul'Gurub is not touched by this pass - the [76] block below already carries its
    --! ids and the list of what was rejected there. The fork's own [745] is Naxxramas
    --! (40), not Karazhan; its eight ids are already present in our [900745].
--! Three more ids were nearly lost because the fork comparison was an id-set diff over
--! the whole file: 25646 Mortal Wound (Ruins of Ahn'Qiraj), 7645 Dominate Mind
--! (Razorfen Downs) and 13005 Hammer of Justice (The Eye, TBC file) were already listed
--! by us - but under a DIFFERENT instance, and a raid-debuff row only ticks inside the
--! instance it is keyed under. Compare per instance, not per file.
    --! WotLK fix: 2026-09-07 label pass. Every Latin-script label in this file is now the
    --! name the client's own Spell.dbc returns for that id, checked by
    --! `dbc_probe.py --labels` (the owner of this invariant - it re-reads the client every
    --! run). Labels inherited from retail/fork data disagreed with the client on 30 rows
    --! across the three data files; most were just a wrong caption on a working row
    --! (23153..23155 Brood Affliction colours, 13338 Curse of Tongues, 16247 Curse of
    --! Thorns, 28158 Poison, 28169 Mutating Injection here), but eight named a mechanic
    --! whose id pointed somewhere else entirely and had their id replaced: Shazzrah 19714,
    --! Nefarian 22667 (+22539 added), Ouro 26615/26616, Faerlina 28798, Loatheb 29234,
    --! Razuvious 28732, Blind Hunter 32065 here, Hydross 38246 in the TBC file. The same
    --! pass also unstuck 26 names that were claimed twice inside one instance, where only
    --! one of the two checkboxes did anything. Proof per record - old id, client name, why
    --! the old row could not fire - is in the registry, GAP-142 in audit/STUDY_GAPS.md;
    --! the lists here stay data only. Why labels are not cosmetic: a bare id is keyed BY
    --! NAME (F.GetDebuffList), so the client's name for the id - not the label - decides
    --! what the checkbox catches. The five remaining mismatches are the known Cataclysm
    --! ids that do not exist in this client at all (dbc_probe BASELINE).
    --! WotLK fix: 2026-09-10 pass over the same fork (HEAD 2bbdac11, data commit e18fcb23)
    --! took its remaining new raid debuffs, 471 here, appended per boss; dropped only ids
    --! duplicating a name/id already in that instance and out-of-era player spells. Proof: GAP-148.
    [741] = { -- Molten Core
        ["general"] = {
            19366, -- Cauterizing Flames
            15732, -- Immolate
            19641, -- Pyroclast Barrage
            19364, -- Ground Stomp
            19631, -- Melt Armor
            16168, -- Flame Buffet
            20276, -- Knockdown
        },
        [1519] = { -- Lucifron
            19702, -- Impending Doom
            19703, -- Lucifron's Curse
            20604, -- Dominate Mind
        },
        [1520] = { -- Magmadar
            19408, -- Panic
            19451, -- Enrage
            19428, -- Conflagration
            19450, -- Magma Spit
        },
        [1521] = { -- Gehennas
            19716, -- Gehennas' Curse
            20277, -- Fist of Ragnaros
            19717, -- Rain of Fire
            -15502, -- Sunder Armor
            -19730, -- Strike
        },
        [1522] = { -- Garr
            19496, -- Magma Shackles
        },
        [1523] = { -- Shazzrah
            19713, -- Shazzrah's Curse
            19714, -- Magic Grounding
            19715, -- Counterspell
        },
        [1524] = { -- Baron Geddon
            20475, -- Living Bomb
            19659, -- Ignite Mana
            19695, -- Inferno
        },
        [1525] = { -- Sulfuron Harbinger
            19779, -- Inspire
            19780, -- Hand of Ragnaros
            -19777, -- Dark Strike
            19778, -- Demoralizing Shout
        },
        [1526] = { -- Golemagg the Incinerator
            13880, -- Magma Splash
            19820, -- Mangle
            20228, -- Pyroblast
        },
        [1527] = { -- 管理者埃克索图斯
            20229, -- Blast Wave
            19369, -- Ancient Despair
            19365, -- Ancient Dread
            19372, -- Ancient Hysteria
            19367, -- Withering Heat
            19635, -- Incite Flames
            19776, -- Shadow Word: Pain
            19393, -- Soul Burn
        },
        [1528] = { -- 拉格纳罗斯
            20564, -- Elemental Fire
        },
    },

    [742] = { -- Blackwing Lair
        ["general"] = {
            23023, -- Conflagration
            22687, -- Veil of Shadow
            22558, -- Brood Power: Red
            22642, -- Brood Power: Bronze
            22561, -- Brood Power: Green
            22559, -- Brood Power: Blue
            22442, -- Growing Flames
            22275, -- Flamestrike
            22423, -- Flame Shock
            22335, -- Bottle of Poison
            19717, -- Rain of Fire
            22274, -- Greater Polymorph
            14515, -- Dominate Mind
            13747, -- Slow
        },
        [1529] = { -- Razorgore the Untamed
            24375, -- War Stomp
        },
        [1530] = { -- Vaelastrasz the Corrupt
            18173, -- Burning Adrenaline
            23461, -- Flame Breath
        },
        [1531] = { -- Broodlord Lashlayer
            23331, -- Blast Wave
            24573, -- Mortal Strike
            22247, -- Suppression Aura
        },
        [1532] = { -- Firemaw
            23341, -- Flame Buffet
        },
        [1533] = { -- Ebonroc
            23340, -- Shadow of Ebonroc
        },
        [1534] = { -- Flamegor
            23342, -- Enrage (Flamegor frenzy)
        },
        [1535] = { -- Chromaggus
            "23128", -- Enrage (Chromaggus frenzy)
            23153, -- Brood Affliction: Blue
            23154, -- Brood Affliction: Black
            23155, -- Brood Affliction: Red
            23169, -- Brood Affliction: Green
            23170, -- Brood Affliction: Bronze
            23310, -- Time Lapse
            23313, -- Corrosive Acid
            23315, -- Ignite Flesh
            23187, -- Frost Burn
            23174, -- Chromatic Mutation
        },
        [1536] = { -- Nefarian
            22667, -- Shadow Command
            22539, -- Shadow Flame
            22686, -- Bellowing Roar
            22678, -- Fear
            23364, -- Tail Lash
            23397, -- Berserk
            23414, -- Paralyze
            23410, -- Wild Magic
            23398, -- Involuntary Transformation
            23401, -- Corrupted Healing
            23418, -- Siphon Blessing
            23425, -- Corrupted Totems
            23427, -- Summon Infernals
        },
    },

    --! WotLK fix: Зул'Гуруб в дампе отсутствовал целиком - см. блок missingInstances
    --! в ExpansionData/ExpansionDataOverrides.lua, там же id инстанса и id боссов.
    --! Каждый id ниже проверен по Spell.dbc клиента (`dbc_probe.py`), подпись рядом -
    --! имя из самой базы, а не пересказ. Принадлежность босса доказана соседством id
    --! с его собственным *Transform-заклинанием (23849 Веноксис, 23966 Джеклик,
    --! 24084 Мар'ли, 24169 Текал, 24190 Арлокк): серверные привязки способностей к
    --! NPC на 3.3.5a не лежат ни в одном офлайновом источнике, а нумерация внутри
    --! патча идёт кластерами по энкаунтеру. Мгновенный урон без ауры (24326 Slam
    --! Газ'ранки, 24189 Force Punch, 24649 Thousand Blades) и общие имена (Frenzy,
    --! Enrage, Whirlwind) не берутся: отслеживать нечего, а общее имя поймало бы
    --! чужую ауру - список дебаффов ключуется по ИМЕНИ (F.GetDebuffList).
    --! WotLK fix: filled out from the fan fork (reference/cell_NoM0Re) on 2026-08-27,
    --! same two filters as Molten Core above - one entry per NAME, and nothing that
    --! only ever sits on the boss. That is why the fork's *Transform and Aspect of *
    --! ids are not here (Hakkar's Aspects are his own buffs, not raid debuffs), why
    --! Frenzy / Avatar / Enlarge / Vanish / Renew are gone, and why the second id of
    --! every doubled name was dropped: 24003 next to 24002 Tranquilizing Poison,
    --! 24011 next to 23862 Venom Spit, 24840 next to 23861 Poison Cloud, 24321 and
    --! 24327 already present under Hakkar, 24322/24324 next to 24323 Blood Siphon,
    --! 16856 next to 24573 Mortal Strike, 17172 next to 24053 Hex, 24333 next to
    --! 24213 Ravage, 23952 next to 24212 Shadow Word: Pain, 24300 next to 24618
    --! Drain Life, 24664/24004 next to 24778 Sleep, 12540 next to 24698 Gouge.
    --! The fork keys this instance [309] (the map id) with its bosses renumbered
    --! 784-793; ours keeps the Encounter Journal ids the file is documented to use,
    --! so each of the fork's lists was matched to our boss key by boss identity.
    [76] = { -- Zul'Gurub
        ["general"] = {
            23931, -- Thunderclap
            24002, -- Tranquilizing Poison
            24063, -- Disease Cloud
            24778, -- Sleep
            24818, -- Noxious Breath
            24839, -- Acid Breath
            22678, -- Fear
            6713, -- Disarm
            24048, -- Whirling Trip
            13445, -- Rend
            21401, -- Frost Shock
            24619, -- Soul Tap
            16790, -- Knockdown
            15655, -- Shield Slam
            16508, -- Intimidating Roar
            24335, -- Wyvern Sting
            3604, -- Tendon Rip
            24671, -- Snap Kick
            24611, -- Fireball
            24612, -- Flamestrike
            12097, -- Pierce Armor
            13730, -- Demoralizing Shout
        },
        [175] = { -- High Priest Venoxis
            23862, -- Venom Spit
            23861, -- Poison Cloud
            23860, -- Holy Fire
            23865, -- Parasitic Serpent
            23849, -- Venoxis Transform
            23895, -- Renew
            24688, -- Aspect of Venoxis
        },
        [784] = { -- High Priestess Jeklik
            23918, -- Sonic Burst
            23919, -- Swoop
            24437, -- Blood Leech
            22884, -- Psychic Scream
            23953, -- Mind Flay
            23966, -- Jeklik Transform
        },
        [785] = { -- High Priest Mar'li
            24110, -- Enveloping Webs
            24111, -- Corrosive Poison
            24099, -- Poison Bolt Volley
            24097, -- Poison
            24084, -- Mar'li Transform
            24109, -- Enlarge
        },
        [176] = { -- Bloodlord Mandokir
            24314, -- Threatening Gaze
            24573, -- Mortal Strike
            -24317, -- Sunder Armor
            24318, -- Frenzy
        },
        [786] = { -- Edge of Madness
            24157, -- Hoodoo Hex
            24388, -- Brain Damage
            24415, -- Slow
            24674, -- Veil of Shadow
            24683, -- Lightning Cloud
            24646, -- Avatar
            24699, -- Vanish
            6524, -- Ground Tremor
        },
        [787] = { -- High Priest Thekal
            24192, -- Speed Slash
            24193, -- Charge
            24698, -- Gouge
            21060, -- Blind
            22859, -- Mortal Cleave
            22666, -- Silence
        },
        [788] = { -- Gahz'ranka
            16099, -- Frost Breath
        },
        [789] = { -- High Priestess Arlokk
            24210, -- Mark of Arlokk
            24213, -- Ravage
            24212, -- Shadow Word: Pain
            24339, -- Infected Bite
            -24331, -- Rake
            24190, -- Arlokk Transform
        },
        [185] = { -- Jin'do the Hexxer
            24053, -- Hex
            24306, -- Delusions of Jin'do
            24261, -- Brain Wash
            24600, -- Web Spin
            24618, -- Drain Life
        },
        [790] = { -- Hakkar
            24323, -- Blood Siphon
            24321, -- Poisonous Blood
            24327, -- Cause Insanity
            24328, -- Corrupted Blood
            24178, -- Will of Hakkar
            24673, -- Curse of Blood
            24686, -- Aspect of Mar'li
            24687, -- Aspect of Jeklik
            24689, -- Aspect of Thekal
            24690, -- Aspect of Arlokk
        },
    },

    [743] = { -- 安其拉废墟
        ["general"] = {
            25471, -- Attack Order
            96, -- Dismember
            25725, -- Paralyze
            25189, -- Enveloping Winds
            25646, -- Mortal Wound
            17742, -- Cloud of Disease
            24317, -- Sunder Armor
            19134, -- Frightening Shout
            25425, -- Shockwave
            26550, -- Lightning Cloud
        },
        [1537] = { -- 库林纳克斯
        },
        [1538] = { -- 拉贾克斯将军
            6713, -- Disarm
        },
        [1539] = { -- 莫阿姆
        },
        [1540] = { -- 吞咽者布鲁
            20512, -- Creeping Plague
        },
        [1541] = { -- 狩猎者阿亚米斯
            25748, -- Poison Stinger
            25852, -- Lash
        },
        [1542] = { -- 无疤者奥斯里安
            25161, -- Harsh Winds
            25195, -- Curse of Tongues
        },
    },

    [744] = { -- Temple of Ahn'Qiraj
        ["general"] = {
            26580, -- Fear
            26050, -- Acid Spit
            26180, -- Wyvern Sting
            26044, -- Mind Flay
            26071, -- Entangling Roots
            24573, -- Mortal Strike
            26552, -- Nullify
            26069, -- Silence
            23931, -- Thunderclap
            26079, -- Cause Insanity
            26049, -- Mana Burn
            19134, -- Frightening Shout
            25809, -- Crippling Poison
            25051, -- Sunder Armor
            26025, -- Impale
        },
        [1543] = { -- The Prophet Skeram
            785, -- True Fulfillment (Mind Control)
        },
        [1544] = { -- Battleguard Sartura
        },
        [1545] = { -- Fankriss the Unyielding
            25646, -- Mortal Wound
        },
        [1546] = { -- Princess Huhuran
            26052, -- Poison Bolt Volley
            26053, -- Noxious Poison
        },
        [1547] = { -- Silithid Royalty
            25812, -- Toxic Volley
            38718, -- Toxic Pool
            19408, -- Panic
        },
        [1548] = { -- Viscidus
            25991, -- Poison Bolt Volley
            25989, -- Toxin
        },
        [1549] = { -- Twin Emperors
            26613, -- Unbalancing Strike
            26607, -- Blizzard
            568, -- Arcane Burst
        },
        [1550] = { -- Ouro
            26103, -- Sweep
            26102, -- Sand Blast
        },
        [1551] = { -- C'Thun
            26476, -- Digestive Acid
            26141, -- Hamstring
        },
    },

    --! WotLK fix: приватные id 900745 / 901552..901566 вместо 745 / 1552..1566 -
    --! настоящий 745 в Encounter Journal принадлежит Каражану (RaidDebuffs_TBC.lua:12),
    --! у Наксрамаса-40 своего id никогда не было. Развёрнуто - в
    --! ExpansionData/ExpansionData.lua:897.
    [900745] = { -- Naxxramas (40)
        ["general"] = {
            28732, -- Widow's Embrace
        },
        [901552] = { -- Anub'Rekhan
            28785, -- Locust Swarm
        },
        [901553] = { -- Grand Widow Faerlina
            28796, -- Poison Bolt Volley
        },
        [901554] = { -- Maexxna
            28622, -- Web Wrap
            28776, -- Necrotic Poison
        },
        [901555] = { -- Noth the Plaguebringer
            29212, -- Cripple
            29213, -- Curse of the Plaguebringer
        },
        [901556] = { -- Heigan the Unclean
            29998, -- Decrepit Fever
        },
        [901557] = { -- Loatheb
            29185, -- Corrupted Mind
            29204, -- Inevitable Doom
        },
        [901558] = { -- Instructor Razuvious
            55470, -- Unbalancing Strike
        },
        [901559] = { -- Gothik the Harvester
            27825, -- Shadow Mark
            28679, -- Harvest Soul
        },
        [901560] = { -- Four Horsemen
            28832, -- Mark of Korth'azz
            28833, -- Mark of Blaumeux
            28834, -- Mark of Rivendare
            28835, -- Mark of Zeliek
        },
        [901561] = { -- Patchwerk
            28801, -- Slime
        },
        --! WotLK fix: typo, the boss id is 1562 (Grobbulus) -- ExpansionData.lua:953
        --! carries 1562 and no button with id 15562 exists anywhere in the UI, so
        --! this whole block was unreachable and the Grobbulus button was empty.
        [901562] = { -- Grobbulus
            28158, -- Poison
            28169, -- Mutating Injection
        },
        [901563] = { -- Gluth
            29306, -- Infected Wound
            54378, -- Mortal Wound
        },
        [901564] = { -- Thaddius
            28059, -- Positive Charge
            28084, -- Negative Charge
        },
        [901565] = { -- Sapphiron
            28522, -- Icebolt
            28547, -- Chill
        },
        [901566] = { -- Kel'Thuzad
            27808, -- Frost Blast
            27819, -- Detonate Mana
            28410, -- Chains of Kel'Thuzad
        },
    },

    [63] = { -- 死亡矿井
        ["general"] = {
            6304, -- Rhahk'Zor Slam
            12097, -- Pierce Armor
            7399, -- Terrify
            6713, -- Disarm
            5213, -- Molten Metal
            5208, -- Poisoned Harpoon
            6432, -- Smite Stomp
            6435, -- Smite Slam
            6136, -- Chilled
            122, -- Frost Nova
            113, -- Chains of Ice
            5159, -- Melt Ore
            6685, -- Piercing Shot
            11829, -- Flamestrike
            6466, -- Axe Toss
            3603, -- Distracting Pain
        },
        [89] = { -- 格拉布托克
        },
        [90] = { -- 赫利克斯·破甲
        },
        [91] = { -- 死神5000
        },
        [92] = { -- 撕心狼将军
        },
        [93] = { -- “船长”曲奇
            6306, -- Acid Splash
        },
    },

    [64] = { -- 影牙城堡
        ["general"] = {
            7068, -- Veil of Shadow
            7125, -- Toxic Saliva
            7621, -- Arugal's Curse
            68607, -- Alluring Perfume Spray
            68821, -- Chain Reaction
            68948, -- Irresistible Cologne Spray
            7803, -- Thundershock
            7124, -- Arugal's Gift
            7295, -- Soul Drain
            7074, -- Screams of the Past
            9080, -- Hamstring
            7140, -- Expose Weakness
            6713, -- Disarm
            7139, -- Fel Stomp
            7127, -- Wavering Will
            970, -- Shadow Word: Pain
            6136, -- Chilled
        },
        [96] = { -- 灰葬男爵
        },
        [97] = { -- 席瓦莱恩男爵
        },
        [98] = { -- 指挥官斯普林瓦尔
            5588, -- Hammer of Justice
        },
        [99] = { -- 沃登勋爵
        },
        [100] = { -- 高弗雷勋爵
        },
    },

    [226] = { -- 怒焰裂谷
        ["general"] = {
            2818, -- Deadly Poison
            11980, -- Curse of Weakness
            20800, -- Immolate
            8242, -- Shield Slam
            18266, -- Curse of Agony
        },
        [694] = { -- 阿达罗格
        },
        [695] = { -- 黑暗萨满柯兰萨
        },
        [696] = { -- 焰喉
        },
        [697] = { -- 熔岩守卫戈多斯
        },
    },

    [227] = { -- 黑暗深渊
        ["general"] = {
            8391, -- Ravage
            122, -- Frost Nova
            8398, -- Frostbolt Volley
            6533, -- Net
            8399, -- Sleep
            246, -- Slow
            3604, -- Tendon Rip
            8382, -- Leech Poison
            8379, -- Disarm
            15039, -- Flame Shock
            12548, -- Frost Shock
            7645, -- Dominate Mind
            9672, -- Frostbolt
            6136, -- Chilled
        },
        [368] = { -- 加摩拉
        },
        [426] = { -- 征服者克鲁尔
        },
        [436] = { -- 多米尼娜
        },
        [437] = { -- 暮光领主巴赛尔
        },
        [444] = { -- 阿库麦尔
            3815, -- Poison Cloud
        },
        [447] = { -- 深渊守护者
        },
        [1144] = { -- 刽子手戈尔
        },
        [1145] = { -- 苏克
        },
    },

    [228] = { -- 黑石深渊
        ["general"] = {
            13704, -- Psychic Scream
            47340, -- Dark Brewmaiden's Stun
            47442, -- Barreled!
            9080, -- Hamstring
            10894, -- Shadow Word: Pain
            12742, -- Immolate
            11980, -- Curse of Weakness
            6713, -- Disarm
            14868, -- Curse of Agony
            15583, -- Rupture
            15621, -- Skull Crack
            19134, -- Frightening Shout
            20615, -- Intercept
            16856, -- Mortal Strike
            6136, -- Chilled
            12675, -- Frostbolt
            15244, -- Cone of Cold
            11831, -- Frost Nova
            6253, -- Backhand
            15042, -- Curse of Blood
            12540, -- Gouge
            14030, -- Hooked Net
            13729, -- Flame Shock
            13298, -- Poison
            11436, -- Slow
            7140, -- Expose Weakness
            13445, -- Rend
            12551, -- Frost Shot
            12248, -- Amplify Damage
            15499, -- Frost Shock
            13902, -- Fist of Ragnaros
            8364, -- Blizzard
            3604, -- Tendon Rip
            47310, -- Direbrew's Disarm
            11971, -- Sunder Armor
            13692, -- Dire Growl
        },
        [369] = { -- 审讯官格斯塔恩
        },
        [370] = { -- 洛考尔
            6524, -- Ground Tremor
        },
        [371] = { -- 驯犬者格雷布玛尔
        },
        [372] = { -- 秩序竞技场
        },
        [373] = { -- 控火师罗格雷恩
        },
        [374] = { -- 伊森迪奥斯
            26977, -- Curse of the Elemental Lord
            13899, -- Fire Storm
        },
        [375] = { -- 典狱官斯迪尔基斯
        },
        [376] = { -- 弗诺斯·达克维尔
        },
        [377] = { -- 贝尔加
        },
        [378] = { -- 怒炉将军
        },
        [379] = { -- 傀儡统帅阿格曼奇
        },
        [380] = { -- 霍尔雷·黑须
        },
        [381] = { -- 法拉克斯
        },
        [383] = { -- 普拉格
        },
        [384] = { -- 弗莱拉斯总大使
        },
        [385] = { -- 黑铁七贤
        },
        [386] = { -- 玛格姆斯
            24375, -- War Stomp
        },
        [387] = { -- 达格兰·索瑞森大帝
            17492, -- Hand of Thaurissan
        },
    },

    [229] = { -- 黑石塔下层
        ["general"] = {
            16805, -- Conflagration
            15548, -- Thunderclap
            16359, -- Corrosive Acid Breath
            16350, -- Freeze
            16104, -- Crystallize
            16168, -- Flame Buffet
            17274, -- Pyroblast
            14030, -- Hooked Net
            13737, -- Mortal Strike
            11428, -- Knockdown
            11641, -- Hex
            15570, -- Immolate
            14100, -- Terrifying Roar
            15618, -- Snap Kick
            15532, -- Frost Nova
            13747, -- Slow
            11876, -- War Stomp
            15744, -- Blast Wave
            12468, -- Flamestrike
            14032, -- Shadow Word: Pain
            16249, -- Frostbolt
            6253, -- Backhand
            15655, -- Shield Slam
            16145, -- Sunder Armor
            7068, -- Veil of Shadow
            12540, -- Gouge
            15128, -- Mark of Flames
            16071, -- Curse of the Firebrand
            15096, -- Flame Shock
            16001, -- Impale
            13323, -- Polymorph
        },
        [388] = { -- 欧莫克大王
        },
        [389] = { -- 暗影猎手沃什加斯
            24673, -- Curse of Blood
        },
        [390] = { -- 指挥官沃恩
            16075, -- Throw Axe
        },
        [391] = { -- 烟网蛛后
            16468, -- Mother's Milk
        },
        [392] = { -- 尤洛克·暗嚎
        },
        [393] = { -- 军需官兹格雷斯
            15284, -- Cleave
            16497, -- Stun Bomb
        },
        [394] = { -- 哈雷肯
            13738, -- Rend
        },
        [395] = { -- 奴役者基兹鲁尔
            16128, -- Infected Bite
        },
        [396] = { -- 维姆萨拉克
            23511, -- Demoralizing Shout
        },
    },

    [230] = { -- 厄运之槌
        ["general"] = {
            17228, -- Shadow Bolt Volley
            5568, -- Trample
            12742, -- Immolate
            15063, -- Frost Nova
            22519, -- Ice Nova
            22356, -- Slow
            21749, -- Thorn Volley
            5416, -- Venom Sting
            13738, -- Rend
            3604, -- Tendon Rip
            11428, -- Knockdown
            15654, -- Shadow Word: Pain
            17831, -- Call of the Grave
            16838, -- Banshee Shriek
            18101, -- Chilled
            15530, -- Frostbolt
            22744, -- Chains of Ice
            15244, -- Cone of Cold
            22823, -- Starshards
            13323, -- Polymorph
            12540, -- Gouge
            21060, -- Blind
            14331, -- Vicious Rend
            20754, -- Rain of Fire
            12096, -- Fear
            22371, -- Curse of Impotence
            12493, -- Curse of Weakness
            3609, -- Paralyzing Poison
            15583, -- Rupture
            9080, -- Hamstring
            8994, -- Banish
            16102, -- Flamestrike
            12024, -- Net
            23224, -- Veil of Shadow
            20989, -- Sleep
            22946, -- Lightning Cloud
            16046, -- Blast Wave
            22713, -- Flame Buffet
        },
        [402] = { -- 瑟雷姆·刺蹄
            22651, -- Sacrifice
            22478, -- Intense Pain
        },
        [403] = { -- 海多斯博恩
            17207, -- Whirlwind
            22419, -- Riptide
        },
        [404] = { -- 蕾瑟塔蒂丝
            13338, -- Curse of Tongues
            16247, -- Curse of Thorns
        },
        [405] = { -- 荒野变形者奥兹恩
            22661, -- Enervate
            22662, -- Wither
            22415, -- Entangling Roots
            10101, -- Knock Away
            22689, -- Mangle
            22691, -- Disarm
        },
        [406] = { -- 特迪斯·扭木
            22924, -- Grasping Vines
            22994, -- Entangle
        },
        [407] = { -- 伊琳娜·暗木
            22910, -- Immolation Trap
            22914, -- Concussive Shot
            22911, -- Charge
            22908, -- Volley
            22915, -- Improved Concussive Shot
        },
        [408] = { -- 卡雷迪斯镇长
            7645, -- Dominate Mind
            22917, -- Shadowform
            22919, -- Mind Flay
        },
        [409] = { -- 伊莫塔尔
            22899, -- Eye of Immol'thar
            16128, -- Infected Bite
        },
        [410] = { -- 托塞德林王子
        },
        [411] = { -- 卫兵摩尔达
            11972, -- Shield Bash
            15749, -- Shield Charge
            14516, -- Strike
        },
        [412] = { -- 践踏者克雷格
            "15578", -- Whirlwind
            "16740", -- War Stomp
            22833, -- Booze Spit
        },
        [413] = { -- 卫兵芬古斯
        },
        [414] = { -- 卫兵斯里基克
        },
        [415] = { -- 克罗卡斯
            13704, -- Psychic Scream
            22859, -- Mortal Cleave
            19134, -- Frightening Shout
        },
        [416] = { -- 观察者克鲁什
        },
        [417] = { -- 戈多克大王
            16856, -- Mortal Strike
            15572, -- Sunder Armor
            16727, -- War Stomp
        },
    },

    [231] = { -- 诺莫瑞根
        ["general"] = {
            11820, -- Electrified Net
            6533, -- Net
            10730, -- Pacify
            22519, -- Ice Nova
            11264, -- Ice Blast
            5116, -- Concussive Shot
            10341, -- Radiation Cloud
        },
        [418] = { -- 群体打击者9-60
        },
        [419] = { -- 格鲁比斯
        },
        [420] = { -- 粘性辐射尘
        },
        [421] = { -- 电刑器6000型
        },
        [422] = { -- 机械师瑟玛普拉格
        },
    },

    [232] = { -- 玛拉顿
        ["general"] = {
            7964, -- Smoke Bomb
            21869, -- Repulsive Gaze
            11922, -- Entangling Roots
            11428, -- Knockdown
            5413, -- Noxious Catalyst
            11876, -- War Stomp
            26419, -- Acid Spray
            21070, -- Noxious Cloud
            21749, -- Thorn Volley
            21069, -- Larva Goo
            744, -- Poison
            21068, -- Corruption
            21067, -- Poison Bolt
            21787, -- Deadly Poison
            7992, -- Slowing Poison
            9080, -- Hamstring
            12540, -- Gouge
            8281, -- Sonic Burst
            21062, -- Putrid Breath
        },
        [423] = { -- 诺克赛恩
            21687, -- Toxic Volley
        },
        [424] = { -- 锐刺鞭笞者
            15976, -- Puncture
        },
        [425] = { -- 工匠吉兹洛克
        },
        [427] = { -- 维利塔恩
        },
        [428] = { -- 被诅咒的塞雷布拉斯
        },
        [429] = { -- 兰斯利德
            21808, -- Landslide
        },
        [430] = { -- 洛特格里普
        },
        [431] = { -- 瑟莱德丝公主
        },
    },

    [233] = { -- 剃刀高地
        ["general"] = {
            12255, -- Curse of Tuten'kash
            12252, -- Web Spray
            12946, -- Putrid Stench
            7645, -- Dominate Mind
            9672, -- Frostbolt
            11831, -- Frost Nova
            12251, -- Virulent Poison
            744, -- Poison
            745, -- Web
            12528, -- Silence
            8078, -- Thunderclap
            12461, -- Backhand
            11980, -- Curse of Weakness
            11443, -- Cripple
            6725, -- Flame Spike
            11436, -- Slow
        },
        [433] = { -- 火眼莫德雷斯
        },
        [1141] = { -- 寒冰之王亚门纳尔
        },
        [1142] = { -- 阿鲁克斯
        },
        [1143] = { -- 麦什伦
        },
        [1146] = { -- 亡语者布莱克松
        },
    },

    [234] = { -- 剃刀沼泽
        ["general"] = {
            14515, -- Dominate Mind
            6533, -- Net
            15548, -- Thunderclap
            8400, -- Fireball
            8282, -- Curse of Blood
            8281, -- Sonic Burst
            8275, -- Poisoned Shot
            6984, -- Frost Shot
            8046, -- Earth Shock
            6524, -- Ground Tremor
            6728, -- Enveloping Winds
            9672, -- Frostbolt
            113, -- Chains of Ice
        },
        [895] = { -- 鲁古格
        },
        [896] = { -- 猎手布塔斯克
        },
        [899] = { -- 督军拉姆塔斯
        },
        [900] = { -- 盲眼猎手格罗亚特
            31956, -- Grievous Wound
        },
        [901] = { -- 卡尔加·刺肋
        },
    },

    [236] = { -- 斯坦索姆
        ["general"] = {
            12734, -- Ground Smash
            17293, -- Burning Winds
            17307, -- Knockout
            10887, -- Crowd Pummel
            14099, -- Mighty Blow
            16791, -- Furious Anger
            14518, -- Crusader Strike
            9672, -- Frostbolt
            6253, -- Backhand
            8552, -- Curse of Weakness
            17831, -- Call of the Grave
            3589, -- Deafening Screech
            17146, -- Shadow Word: Pain
            17165, -- Mind Flay
            11667, -- Immolate
            17145, -- Blast Wave
            17142, -- Holy Fire
            17274, -- Pyroblast
            6136, -- Chilled
            13323, -- Polymorph
            14331, -- Vicious Rend
            13005, -- Hammer of Justice
            12674, -- Frost Nova
            6713, -- Disarm
            16866, -- Venom Spit
            7992, -- Slowing Poison
            15471, -- Enveloping Web
            8715, -- Terrifying Howl
            13738, -- Rend
            16458, -- Ghoul Plague
            16430, -- Soul Tap
            11443, -- Cripple
            16429, -- Piercing Shadow
            9080, -- Hamstring
            16143, -- Cadaver Worms
            7713, -- Wailing Dead
            12889, -- Curse of Tongues
            15618, -- Snap Kick
        },
        [443] = { -- 弗雷斯特恩
            16798, -- Enchanting Lullaby
            16244, -- Demoralizing Shout
        },
        [445] = { -- 悲惨的提米
            17470, -- Ravenous Claw
            8599, -- Enrage
        },
        [446] = { -- 希望破坏者威利
        },
        [448] = { -- 档案管理员加尔福特
        },
        [449] = { -- 巴纳扎尔
            17405, -- Domination
            13704, -- Psychic Scream
            17286, -- Crusader's Hammer
            12098, -- Sleep
        },
        [450] = { -- 不可宽恕者
        },
        [451] = { -- 安娜丝塔丽男爵夫人
            17244, -- Possess
            18327, -- Silence
            16867, -- Banshee Curse
        },
        [452] = { -- 奈鲁布恩坎
            4962, -- Encasing Webs
            6016, -- Pierce Armor
        },
        [453] = { -- 苍白的玛勒基
            16869, -- Ice Tomb
            17620, -- Drain Life
        },
        [454] = { -- 巴瑟拉斯镇长
        },
        [455] = { -- 吞咽者拉姆斯登
        },
        [456] = { -- 奥里克斯·瑞文戴尔领主
            15708, -- Mortal Strike
        },
        [749] = { -- 指挥官玛洛尔
        },
    },

    [237] = { -- 阿塔哈卡神庙
        ["general"] = {
            12889, -- Curse of Tongues
            12888, -- Cause Insanity
            12479, -- Hex of Jammal'an
            12493, -- Curse of Weakness
            12890, -- Deep Slumber
            24375, -- War Stomp
            7992, -- Slowing Poison
            12884, -- Acid Breath
            12279, -- Curse of Blood
            8242, -- Shield Slam
            11639, -- Shadow Word: Pain
            12280, -- Acid of Hakkar
            8398, -- Frostbolt Volley
            5708, -- Swoop
            11831, -- Frost Nova
            12098, -- Sleep
            12096, -- Fear
            16186, -- Fevered Plague
            11641, -- Hex
            13445, -- Rend
            6524, -- Ground Tremor
            12097, -- Pierce Armor
        },
        [457] = { -- 哈卡的化身
        },
        [458] = { -- 预言者迦玛兰
            12468, -- Flamestrike
        },
        [459] = { -- 梦境守望者
        },
        [463] = { -- 伊兰尼库斯的阴影
        },
    },

    [238] = { -- 监狱
        ["general"] = {
            19134, -- Frightening Shout
            7964, -- Smoke Bomb
            6253, -- Backhand
            6547, -- Rend
            3427, -- Infected Wound
            6713, -- Disarm
            8242, -- Shield Slam
        },
        [464] = { -- 霍格
        },
        [465] = { -- 灼热勋爵
        },
        [466] = { -- 兰多菲·摩洛克
        },
    },

    [239] = { -- 奥达曼
        ["general"] = {
            3356, -- Flame Lash
            6524, -- Ground Tremor
            3636, -- Crystalline Slumber
            8281, -- Sonic Burst
            8242, -- Shield Slam
            6685, -- Piercing Shot
            8814, -- Flame Spike
            10452, -- Flame Buffet
            6713, -- Disarm
            2767, -- Shadow Word: Pain
            6726, -- Silence
            8257, -- Venom Sting
            744, -- Poison
            2941, -- Immolate
        },
        [467] = { -- 鲁维罗什
        },
        [468] = { -- 失踪的矮人
        },
        [469] = { -- 艾隆纳亚
            11876, -- War Stomp
        },
        [470] = { -- 远古巨石卫士
            10093, -- Harsh Winds
        },
        [471] = { -- 加加恩·火锤
            8053, -- Flame Shock
            9482, -- Amplify Flames
        },
        [472] = { -- 格瑞姆洛克
            11892, -- Shrink
        },
        [473] = { -- 阿扎达斯
        },
        [748] = { -- 黑曜石哨兵
        },
    },

    [240] = { -- 哀嚎洞穴
        ["general"] = {
            8040, -- Druid's Slumber
            8142, -- Grasping Vines
            7967, -- Naralex's Nightmare
            8150, -- Thundercrack
            7947, -- Localized Toxin
            744, -- Poison
            7399, -- Terrify
            3604, -- Tendon Rip
        },
        [474] = { -- 安娜科德拉
        },
        [475] = { -- 考布莱恩
        },
        [476] = { -- 皮萨斯
            8147, -- Thunderclap
        },
        [477] = { -- 克雷什
        },
        [478] = { -- 斯卡姆
        },
        [479] = { -- 瑟芬迪斯
            700, -- Sleep
        },
        [480] = { -- 永生者沃尔丹
            5164, -- Knockdown
        },
        [481] = { -- 吞噬者穆坦努斯
        },
    },

    [241] = { -- 祖尔法拉克
        ["general"] = {
            3427, -- Infected Wound
            11641, -- Hex
            12741, -- Curse of Weakness
            11962, -- Immolate
            11990, -- Rain of Fire
            12540, -- Gouge
            14032, -- Shadow Word: Pain
            744, -- Poison
            3256, -- Plague Cloud
        },
        [483] = { -- 加兹瑞拉
            11836, -- Freeze Solid
            11131, -- Icicle
        },
        [484] = { -- 安图苏尔
            11020, -- Petrify
        },
        [485] = { -- 殉教者塞卡
            8600, -- Fevered Plague
        },
        [486] = { -- 巫医祖穆拉恩
        },
        [487] = { -- 耐克鲁姆和塞瑟斯
        },
        [489] = { -- 乌克兹·沙顶
        },
    },

    [246] = { -- 通灵学院
        ["general"] = {
            16509, -- Rend
            18103, -- Backhand
            18671, -- Curse of Agony
            14515, -- Dominate Mind
            12542, -- Fear
            6726, -- Silence
            12020, -- Call of the Grave
            11672, -- Corruption
            12279, -- Curse of Blood
            18144, -- Swoop
            8379, -- Disarm
            20294, -- Immolate
            7068, -- Veil of Shadow
            18270, -- Dark Plague
            23313, -- Corrosive Acid
            18151, -- Noxious Catalyst
            15043, -- Frostbolt
            18101, -- Chilled
            18763, -- Freeze
            18099, -- Chill Nova
            8398, -- Frostbolt Volley
            25174, -- Sundering Cleave
            16046, -- Blast Wave
            3436, -- Wandering Plague
            17742, -- Cloud of Disease
            17716, -- Consuming Shadows
            17620, -- Drain Life
            15655, -- Shield Slam
            15654, -- Shadow Word: Pain
            11428, -- Knockdown
            15588, -- Thunderclap
            17243, -- Drain Mana
            17165, -- Mind Flay
            11443, -- Cripple
            15244, -- Cone of Cold
            15499, -- Frost Shock
            15474, -- Web Explosion
            3583, -- Deadly Poison
            22371, -- Curse of Impotence
            12493, -- Curse of Weakness
            3609, -- Paralyzing Poison
            6016, -- Pierce Armor
            12889, -- Curse of Tongues
            24928, -- Volatile Infection
        },
        [659] = { -- 指导者寒心
        },
        [663] = { -- 詹迪斯·巴罗夫
        },
        [665] = { -- 血骨傀儡
            16727, -- War Stomp
        },
        [666] = { -- 莉莉安·沃斯
        },
        [684] = { -- 黑暗院长加丁
            18702, -- Curse of the Darkmaster
        },
    },

    [311] = { -- 血色大厅
        ["general"] = {
        },
        [654] = { -- 武器大师哈兰
        },
        [656] = { -- 织焰者孔格勒
        },
        [660] = { -- 驯犬者布兰恩
        },
    },

    [316] = { -- 血色修道院
        ["general"] = {
            9034, -- Immolate
            8814, -- Flame Spike
            8988, -- Silence
            9256, -- Deep Sleep
            8282, -- Curse of Blood
            13323, -- Polymorph
            17831, -- Call of the Grave
            7399, -- Terrify
            7290, -- Soul Siphon
            8053, -- Flame Shock
            42380, -- Conflagration
            42514, -- Squash Soul
            12096, -- Fear
            1090, -- Sleep
            2767, -- Shadow Word: Pain
            14518, -- Crusader Strike
            5589, -- Hammer of Justice
            8398, -- Frostbolt Volley
            17313, -- Mind Flay
            15531, -- Frost Nova
            3815, -- Poison Cloud
            6713, -- Disarm
            9672, -- Frostbolt
            6146, -- Slow
            8422, -- Flamestrike
            7068, -- Veil of Shadow
        },
        [671] = { -- 科洛夫修士
        },
        [674] = { -- 大检察官怀特迈恩
        },
        [688] = { -- 裂魂者萨尔诺斯
        },
    },

}

-- WotLK Fix: Defer loading until F.LoadBuiltInDebuffs is available (defined in Modules/RaidDebuffs/RaidDebuffs_Classic.lua)
if F.LoadBuiltInDebuffs then
    F.LoadBuiltInDebuffs(debuffs)
else
    -- Register a callback to load debuffs once the function is available
    Cell.RegisterCallback("RaidDebuffsReady", "RaidDebuffs_Classic_LoadBuiltIn", function()
        if F.LoadBuiltInDebuffs then
            F.LoadBuiltInDebuffs(debuffs)
        end
    end)
end
