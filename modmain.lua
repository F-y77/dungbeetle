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
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE_DEATH = "它死了，散发着恶臭..."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE_EATING = "它在享用美食..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE_SANITY = "它的死亡让我感到不适..."

-- 修改eater组件，使屎壳郎可以吃粪便
--已失效但为了喜爱效果保留
local function ModifyPoopEdible()
    -- 让粪便可以被屎壳郎吃
    AddPrefabPostInit("poop", function(inst)
        -- 如果已有edible组件，只修改foodtype；如果没有，添加组件
        if inst.components.edible == nil then
            if not inst:HasTag("cooked") then
                inst:AddComponent("edible")
                inst.components.edible.foodtype = FOODTYPE.GENERIC
                inst.components.edible.healthvalue = 100  -- 设置健康值
                --inst.components.edible.hungervalue = 0  -- 设置饥饿值
                --inst.components.edible.sanityvalue = 0  -- 设置精神值
            end
        else
            inst.components.edible.foodtype = FOODTYPE.GENERIC
        end
    end)
end

ModifyPoopEdible()