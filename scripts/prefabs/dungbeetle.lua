-- scripts/prefabs/dungbeetle.lua
local assets=
{
    Asset("ANIM", "anim/dungbeetle.zip"),
}

local prefabs =
{
    "poop",
    "monstermeat"
}

local brain = require "brains/dungbeetlebrain"

-- 当吃下食物时调用的函数 已经失效
local function OnEat(inst, food)
    if food.prefab == "poop" then
        -- 粪便恢复30%的生命值
        if inst.components.health then
            inst.components.health:DoDelta(inst.components.health.maxhealth * 0.3)
            -- 输出debug信息
            --print("屎壳郎吃了粪便，恢复了生命值")
        end
    end
end

-- 随机产生粪便
local function DoPoopDrop(inst)
    if math.random() < 0.45 then  -- 45%几率产出粪便
        local numPoops = math.random(1, 3)  -- 产出1-3个粪便
        for i = 1, numPoops do
            local poop = SpawnPrefab("poop")
            local pos = inst:GetPosition()
            local angle = math.random() * 2 * PI
            local dist = math.random() * 2  -- 粪便掉落在2格半径内
            local offset = Vector3(dist * math.cos(angle), 0, dist * math.sin(angle))
            poop.Transform:SetPosition(pos.x + offset.x, pos.y, pos.z + offset.z)
        end
    end
    
    -- 设置下一次产出粪便的时间
    inst.pooptask = inst:DoTaskInTime(math.random(20, 40), DoPoopDrop)
end

-- 当死亡时降低周围玩家的San
local function OnDeath(inst, data)
    -- 死亡时掉落大量粪便和1个怪物肉
    for i = 1, math.random(5, 10) do  -- 掉落5-10个粪便
        local poop = SpawnPrefab("poop")
        local pos = inst:GetPosition()
        local angle = math.random() * 2 * PI
        local dist = math.random() * 1.5  -- 粪便掉落在1.5格半径内
        local offset = Vector3(dist * math.cos(angle), 0, dist * math.sin(angle))
        poop.Transform:SetPosition(pos.x + offset.x, pos.y, pos.z + offset.z)
    end
    
    -- 只有被玩家杀死时才降低精神值
    if data and data.afflicter and data.afflicter:HasTag("player") then
        -- 为杀死屎壳郎的玩家降低精神值
        if data.afflicter.components.sanity then
            data.afflicter.components.sanity:DoDelta(-15)  -- 降低15点精神值
        end
        
        -- 为周围其他玩家也降低一些精神值
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = FindPlayersInRange(x, y, z, 15)  -- 15格范围内的玩家
        for _, player in ipairs(players) do
            if player ~= data.afflicter and player.components.sanity then
                player.components.sanity:DoDelta(-7)  -- 降低7点精神值
            end
        end
    end
end

local function OnLoad(inst)
    -- 开始产生粪便的循环任务
    if inst.pooptask then
        inst.pooptask:Cancel()
    end
    inst.pooptask = inst:DoTaskInTime(math.random(20, 40), DoPoopDrop)
end

local function OnRemove(inst)
    -- 取消产生粪便的任务
    if inst.pooptask then
        inst.pooptask:Cancel()
        inst.pooptask = nil
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    
    inst.DynamicShadow:SetSize(2, 1.5)
    
    inst:AddTag("animal") 
    inst:AddTag("dungbeetle")
    inst:AddTag("scarytoprey")
    
    -- 设置朝向，可能需要根据您的动画调整
    inst.Transform:SetFourFaced()
    
    MakeCharacterPhysics(inst, 1, 0.5)
    
    -- 设置动画
    inst.AnimState:SetBank("dungbeetle")
    inst.AnimState:SetBuild("dungbeetle")
    inst.AnimState:PlayAnimation("idle", true)
    
    -- 设置声音
    inst.sounds = {
        idle = "monkeyisland/pollyroger/caw1",
        walk = "monkeyisland/pollyroger/caw2",
        death = "monkeyisland/pollyroger/caw3",
        hit = "monkeyisland/pollyroger/caw4",
    }

    -- 添加声音路径函数
    inst.SoundPath = function(inst, event)
        return inst.sounds[event]
    end
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:SetStateGraph("SGdungbeetle")
    inst:SetBrain(brain)
    
    -- 添加吃东西的组件 - 修改为DST兼容的方式
    inst:AddComponent("eater")
    -- 在DST中设置可以吃的食物类型
    inst.components.eater:SetDiet({ FOODTYPE.GENERIC }, { FOODTYPE.GENERIC })
    inst.components.eater:SetCanEatHorrible(true)  -- 可以吃恶心的食物（如粪便）
    --inst.components.eater:SetStrongStomach(true)   -- 有强壮的胃（不会因吃恶心食物而降低精神值）
    inst.components.eater:SetOnEatFn(OnEat)
    
    -- 添加可以吃粪便的标签
    inst:AddTag("poop_eater")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.DUNG_BEETLE_WALK_SPEED
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DUNG_BEETLE_HEALTH)
    
    MakeSmallBurnableCharacter(inst, "body")
    MakeTinyFreezableCharacter(inst, "body")
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"monstermeat"})  -- 设置掉落物品为怪物肉
    
    inst:AddComponent("inspectable")
    
    -- 监听死亡事件
    inst:ListenForEvent("death", OnDeath)
    
    -- 设置粪便产生任务
    inst.pooptask = inst:DoTaskInTime(math.random(20, 40), DoPoopDrop)
    
    -- 当实体被移除时，取消任务
    inst.OnRemoveEntity = OnRemove
    
    -- 加载时设置粪便产生任务
    inst.OnLoad = OnLoad

    -- 监听受击事件播放声音
    inst:ListenForEvent("attacked", function(inst)
        inst.SoundEmitter:PlaySound(inst:SoundPath("hit"))
    end)

    -- 监听死亡事件播放声音
    inst:ListenForEvent("death", function(inst)
        inst.SoundEmitter:PlaySound(inst:SoundPath("death"))
    end)
    
    return inst
end

return Prefab("dungbeetle", fn, assets, prefabs)