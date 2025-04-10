name = "屎壳郎"
description = [[

将单机版的屎壳郎外观添加到联机版，但是并不会滚粪球只会产生大量粪便，并大量改变行为。

屎壳郎的产出地形：

当玩家采集过某一株草丛之后，屎壳郎将会有3%概率自草丛中生成，无论草丛处在什么地方。

屎壳郎有五个行为：

1. 游荡：在一定范围内随机游荡，偶尔会产出1,2个粪便。
2. 逃跑：当玩家靠近时，会高速逃跑，直到边缘，玩家离开时停止逃跑。
3. 恐慌：屎壳郎被火烧时会恐慌，恐慌时会四处乱跑。
4. 死亡：当屎壳郎死亡时，攻击他的玩家会掉San，屎壳郎会掉落大量粪便和1个怪物肉。
5. 喜爱，屎壳郎喜爱粪便，当它看到粪便时会非常高兴，会立即跟粪便贴贴；除非玩家靠近则不会离开粪便。

作者已弃坑，不会更新声音了。

]]
author = "凌"
version = "1.8.1"

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = true
client_only_mod = false
server_only_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
    "dungbeetle",
    "凌"
}

configuration_options = {
    {
        name = "spawn_chance",
        label = "生成几率",
        hover = "屎壳郎从草丛中生成的几率",
        options = {
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "3%", data = 0.03},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.1},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.2},
        },
        default = 0.03,
    },
    {
        name = "health",
        label = "屎壳郎生命值",
        hover = "屎壳郎的最大生命值",
        options = {
            {description = "较弱 (100)", data = 100},
            {description = "普通 (200)", data = 200},
            {description = "较强 (300)", data = 300},
            {description = "坚固 (400)", data = 400},
        },
        default = 200,
    },
    {
        name = "walk_speed",
        label = "行走速度",
        hover = "屎壳郎的行走速度",
        options = {
            {description = "慢 (2)", data = 2},
            {description = "正常 (3)", data = 3},
            {description = "快 (4)", data = 4},
            {description = "极快 (5)", data = 5},
        },
        default = 3,
    },
    {
        name = "run_speed",
        label = "奔跑速度",
        hover = "屎壳郎的奔跑速度",
        options = {
            {description = "慢 (4)", data = 4},
            {description = "正常 (6)", data = 6},
            {description = "快 (8)", data = 8},
            {description = "极快 (10)", data = 10},
        },
        default = 6,
    },
} 