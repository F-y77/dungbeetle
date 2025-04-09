name = "屎壳郎"
description = [[

将单机版的屎壳郎外观添加到联机版，但是并不会滚粪球只会产生大量粪便，并大量改变行为。

屎壳郎的产出地形：

1.只在皮弗娄大草原产出。
2.只在草丛中产出。

屎壳郎有五个行为：

1. 游荡：在一定范围内随机游荡，偶尔会产出1,2个粪便。
2. 逃跑：当玩家靠近时，会高速逃跑，直到边缘，玩家离开时停止逃跑。
3. 恐慌：屎壳郎被火烧时会恐慌，恐慌时会四处乱跑。
4. 死亡：当屎壳郎死亡时，攻击他的玩家会掉San，屎壳郎会掉落大量粪便和1个怪物肉。
5. 喜爱，屎壳郎喜爱粪便，当它看到粪便时会非常高兴，会立即跟粪便贴贴；除非玩家靠近则不会离开粪便。

]]
author = "凌"
version = "1.5.0"

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
} 