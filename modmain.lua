-- modmain.lua

-- 设置环境变量
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

--注册动物
PrefabFiles = {
    "dungbeetle",
}

-- 注册动物调整
TUNING.DUNG_BEETLE_HEALTH = 200
TUNING.DUNG_BEETLE_WALK_SPEED = 3
TUNING.DUNG_BEETLE_RUN_SPEED = 6

-- 注册字符串
STRINGS.NAMES.DUNGBEETLE = "屎壳郎"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE = "它喜欢滚粪球！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE_UNDUNGED = "它失去了它珍贵的粪球。"