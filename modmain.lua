-- modmain.lua

-- 设置环境变量
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

--注册动物
PrefabFiles = {
    "dungbeetle",
}

-- 从配置选项读取设置
local SPAWN_CHANCE = GetModConfigData("spawn_chance") or 0.03
local BEETLE_HEALTH = GetModConfigData("health") or 200
local WALK_SPEED = GetModConfigData("walk_speed") or 3
local RUN_SPEED = GetModConfigData("run_speed") or 6

-- 注册动物调整
TUNING.DUNG_BEETLE_HEALTH = BEETLE_HEALTH
TUNING.DUNG_BEETLE_WALK_SPEED = WALK_SPEED
TUNING.DUNG_BEETLE_RUN_SPEED = RUN_SPEED
TUNING.DUNG_BEETLE_SPAWN_CHANCE = SPAWN_CHANCE

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

-- 从草丛中生成屎壳郎
local function SpawnDungBeetleFromGrass(inst, picker)
    -- 根据几率决定是否生成屎壳郎
    if math.random() > TUNING.DUNG_BEETLE_SPAWN_CHANCE then
        return
    end
    
    -- 生成屎壳郎在草丛位置
    local beetle = SpawnPrefab("dungbeetle")
    if beetle then
        local pos = inst:GetPosition()
        beetle.Transform:SetPosition(pos.x, pos.y, pos.z)
        
        -- 让屎壳郎逃跑
        if picker and beetle.components.combat then
            beetle.components.combat:SetTarget(picker)
        end
        
        -- 播放逃跑的声音效果
       -- if beetle.SoundEmitter then
       --     beetle.SoundEmitter:PlaySound("dontstarve/creatures/perd/scream")
       -- end
        
        -- 设置屎壳郎的家为这株草丛
        if beetle.components.homeseeker and inst:IsValid() then
            beetle.components.homeseeker:SetHome(inst)
        end
        
        -- 添加动画效果
        if beetle.sg then
            beetle.sg:GoToState("walk")
        end
    end
end

-- 添加采集草丛的钩子函数
local function AddGrassHarvesting()
    -- 修改所有类型的草
    local grass_prefabs = {"grass", "grassgekko", "reeds"}
    
    for _, grass_prefab in ipairs(grass_prefabs) do
        AddPrefabPostInit(grass_prefab, function(inst)
            -- 确保已有采集组件
            if inst.components.pickable then
                -- 保存原始的onpickedfn函数
                local old_onpickedfn = inst.components.pickable.onpickedfn
                
                -- 新的onpickedfn函数
                inst.components.pickable.onpickedfn = function(inst, picker, ...)
                    -- 调用原始函数
                    if old_onpickedfn then
                        old_onpickedfn(inst, picker, ...)
                    end
                    
                    -- 从草丛中生成屎壳郎
                    SpawnDungBeetleFromGrass(inst, picker)
                end
            end
        end)
    end
end

AddGrassHarvesting()