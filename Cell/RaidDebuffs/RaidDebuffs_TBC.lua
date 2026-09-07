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
local debuffs = {
    [745] = { -- Karazhan
        ["general"] = {
            37091, -- Rain of Bones
            30210, -- Smoldering Breath
            30129, -- Charred Earth
            30127, -- Searing Cinders
            36922, -- Bellowing Roar
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
        },
    },

    [746] = { -- 格鲁尔的巢穴
        ["general"] = {
        },
        [1564] = { -- 莫加尔大王
            11726, -- Enslave Demon
            33129, -- Dark Decay
            33175, -- Arcane Shock
            33061, -- Blast Wave
            33130, -- Death Coil
            16508, -- Intimidating Roar
        },
        [1565] = { -- 屠龙者格鲁尔
            38927, -- Fel Ache
            36240, -- Cave In
            33652, -- Stoned
            33525, -- Ground Slam
        },
    },

    [747] = { -- 玛瑟里顿的巢穴
        ["general"] = {
        },
        [1566] = { -- 玛瑟里顿
            44032, -- Mind Exhaustion
            30530, -- Fear
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
        },
        [1567] = { -- Hydross
            38246, -- Vile Sludge
            38215, -- Mark of Hydross
            38235, -- Water Tomb
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
        },
        [1571] = { -- Morogrim
            37850, -- Watery Grave
        },
        [1572] = { -- Lady Vashj
            38280, -- Static Charge
            38316, -- Entangle
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
        },
        [1573] = { -- 奥
            35410, -- Melt Armor
        },
        [1574] = { -- 空灵机甲
        },
        [1575] = { -- 大星术师索兰莉安
            42783, -- Wrath of the Astromancer
            34322, -- Psychic Scream
        },
        [1576] = { -- 凯尔萨斯·逐日者
            44863, -- Bellowing Roar
            37027, -- Remote Toy
            36797, -- Mind Control
            36965, -- Rend
            "30225", -- Silence
            37018, -- Conflagration
        },
    },

    [750] = { -- 海加尔山之战
        ["general"] = {
            31610, -- Knockdown
            28991, -- Web
        },
        [1577] = { -- 雷基·冬寒
            31249, -- Icebolt
            31250, -- Frost Nova
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
        },
        [1581] = { -- 阿克蒙德
            31972, -- Grip of the Legion
            31944, -- Doomfire
            31970, -- Fear
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
        },
        [1582] = { -- High Warlord Naj'entus
            39837, -- Impaling Spine
        },
        [1583] = { -- Supremus
            40253, -- Molten Flame
        },
        [1584] = { -- Shade of Akama
            42023, -- Rain of Fire
        },
        [1585] = { -- Teron Gorefiend
            40251, -- Shadow of Death
            40239, -- Incinerate
            40243, -- Crushing Shadows
        },
        [1586] = { -- Gurtogg Bloodboil
            40481, -- Acidic Wound
            42005, -- Bloodboil
            40491, -- Bewildering Strike
            40604, -- Fel Rage
            40599, -- Arcing Smash
            40508, -- Fel-Acid Breath
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
        },
        [189] = { -- Halazzi
            43303, -- Flame Shock
        },
        [190] = { -- Hex Lord Malacrass
            43501, -- Siphon Soul
            44131, -- Drain Power
        },
        [191] = { -- Zul'jin
            43093, -- Grievous Throw
            43095, -- Creeping Paralysis
            43149, -- Claw Rage
            43153, -- Lynx Rush
            43208, -- Flame Whirl
        },
    },

    [752] = { -- Sunwell Plateau
        ["general"] = {
        },
        [1591] = { -- Kalecgos
            45032, -- Curse of Boundless Agony
            45018, -- Arcane Buffet
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
        },
        [1594] = { -- Eredar Twins
            45256, -- Confounding Blow
            45342, -- Conflagration
            46771, -- Flame Sear
            45270, -- Shadowfury
            45347, -- Dark Touched
            45348, -- Flame Touched
        },
        [1595] = { -- M'uru
            45996, -- Darkness
        },
        [1596] = { -- Kil'jaeden
            45737, -- Flame Dart
            45641, -- Fire Bloom
            45442, -- Soul Flay
            45885, -- Shadow Spike
        },
    },

    [248] = { -- 地狱火城墙
        ["general"] = {
        },
        [527] = { -- 巡视者加戈玛
            36814, -- Mortal Wound
        },
        [528] = { -- 无疤者奥摩尔
            37566, -- Bane of Treachery
            30695, -- Treacherous Aura
        },
        [529] = { -- 传令官瓦兹德
        },
    },

    [252] = { -- 塞泰克大厅
        ["general"] = {
            40303, -- Spell Bomb (Anzu heroic)
            40321, -- Cyclone of Feathers (Anzu heroic)
        },
        [541] = { -- 黑暗编织者塞斯
        },
        [543] = { -- 利爪之王艾吉斯
            12826, -- Polymorph
        },
    },

    [247] = { -- 奥金尼地穴
        ["general"] = {
        },
        [523] = { -- 死亡观察者希尔拉克
        },
        [524] = { -- 大主教玛拉达尔
            32346, -- Stolen Soul
        },
    },

    [260] = { -- 奴隶围栏
        ["general"] = {
        },
        [570] = { -- 背叛者门努
        },
        [571] = { -- 巨钳鲁克玛尔
            38801, -- Grievous Wound
            31948, -- Ensnaring Moss
        },
        [572] = { -- 夸格米拉
        },
    },

    [262] = { -- 幽暗沼泽
        ["general"] = {
        },
        [576] = { -- 霍加尔芬
            34971, -- Frenzy (Claw)
            31615, -- Hunter's Mark
        },
        [577] = { -- 加兹安
        },
        [578] = { -- 沼地领主穆塞雷克
            34974, -- Multi-Shot
            31429, -- Echoing Roar
        },
        [579] = { -- 黑色阔步者
            31715, -- Static Charge
            31717, -- Chain Lightning
        },
    },

    [251] = { -- 旧希尔斯布莱德丘陵
        ["general"] = {
        },
        [538] = { -- 德拉克中尉
            33792, -- Exploding Shot
        },
        [539] = { -- 斯卡洛克上尉
            13005, -- Hammer of Justice
        },
        [540] = { -- 时空猎手
        },
    },

    [253] = { -- 暗影迷宫
        ["general"] = {
        },
        [544] = { -- 赫尔默大使
            33551, -- Corrosive Acid
            33547, -- Fear
        },
        [545] = { -- 煽动者布莱卡特
            33676, -- Incite Chaos
        },
        [546] = { -- 沃匹尔大师
            38791, -- Banish
        },
        [547] = { -- 摩摩尔
            38794, -- Murmur's Touch
        },
    },

    [250] = { -- 法力陵墓
        ["general"] = {
        },
        [534] = { -- 潘德莫努斯
            38759, -- Dark Shell
        },
        [535] = { -- 塔瓦洛克
            32361, -- Crystal Prison
        },
        [537] = { -- 节点亲王沙法尔
            32365, -- Frost Nova
        },
    },

    [257] = { -- 生态船
        ["general"] = {
        },
        [558] = { -- 指挥官萨拉妮丝
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
        },
    },

    [259] = { -- 破碎大厅
        ["general"] = {
        },
        [566] = { -- 高阶术士奈瑟库斯
            "39661", -- Death Coil (second rank)
            30500, -- Death Coil
            30502, -- Dark Spin
        },
        [568] = { -- 战争使者沃姆罗格
            30618, -- Beatdown
        },
        [569] = { -- 酋长卡加斯·刃拳
        },
    },

    [254] = { -- 禁魔监狱
        ["general"] = {
        },
        [548] = { -- 自由的瑟雷凯斯
            39367, -- Seed of Corruption
        },
        [549] = { -- 末日预言者达尔莉安
            39009, -- Gift of the Doomsayer
        },
        [550] = { -- 天怒预言者苏克拉底
        },
        [551] = { -- 预言者斯克瑞斯
            39017, -- Mind Rend
            39019, -- Complete Domination
        },
    },

    [258] = { -- 能源舰
        ["general"] = {
        },
        [563] = { -- 机械领主卡帕西图斯
        },
        [564] = { -- 灵术师塞比瑟蕾
        },
        [565] = { -- 计算者帕萨雷恩
            35280, -- Domination
            35250, -- Dragon's Breath
            35314, -- Arcane Blast
            35268, -- Inferno
        },
    },

    [261] = { -- 蒸汽地窟
        ["general"] = {
        },
        [573] = { -- 水术师瑟丝比娅
            31481, -- Lung Burst
            31718, -- Enveloping Winds
        },
        [574] = { -- 机械师斯蒂里格
            35107, -- Electrified Net
        },
        [575] = { -- 督军卡利瑟里斯
            16172, -- Head Crack
            31534, -- Spell Reflection
            36453, -- Warlord's Rage
        },
    },

    [249] = { -- 魔导师平台
        ["general"] = {
        },
        [530] = { -- 塞林·火心
        },
        [531] = { -- 维萨鲁斯
            44335, -- Energy Feedback
        },
        [532] = { -- 女祭司德莉希亚
            44141, -- Seed of Corruption
            13323, -- Polymorph
        },
        [533] = { -- 凯尔萨斯·逐日者
            36819, -- Pyroblast
        },
    },

    [256] = { -- 鲜血熔炉
        ["general"] = {
        },
        [555] = { -- 制造者
            30923, -- Domination
        },
        [556] = { -- 布洛戈克
            30916, -- Poison Cloud
        },
        [557] = { -- 击碎者克里丹
            30940, -- Burning Nova
        },
    },

    [255] = { -- 黑色沼泽
        ["general"] = {
        },
        [552] = { -- 时空领主德亚
        },
        [553] = { -- 坦普卢斯
            31458, -- Hasten
            38592, -- Spell Reflection
        },
        [554] = { -- 埃欧努斯
            37605, -- Enrage
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
