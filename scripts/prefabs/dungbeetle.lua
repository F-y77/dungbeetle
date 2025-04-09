-- scripts/prefabs/dungbeetle.lua
-- 动画
local assets=
{
    Asset("ANIM", "anim/dung_beetle_basic.zip"),
    Asset("ANIM", "anim/dung_beetle_build.zip"),
}

-- 掉落物
local prefabs =
{
}

-- 大脑
local brain = require "brains/dungbeetlebrain"

-- 醒来
local function OnWake(inst)
end

-- 睡觉
local function OnSleep(inst)
end

-- 碰撞
local function oncollide(inst, other)
    if inst.sg:HasStateTag("running") and inst:HasTag("hasdung") then
        if other then
            inst:PushEvent("bumped")
        end 
    end
end

-- 创建
local function fn()
    local inst = CreateEntity()
    -- 实体
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    -- 阴影
    inst.DynamicShadow:SetSize(2, 1.5)
    -- 标签
    inst:AddTag("hasdung") 
    inst:AddTag("animal") 
    inst:AddTag("dungbeetle")
    inst:AddTag("scarytoprey")
    -- 六面
    inst.Transform:SetSixFaced()
    -- 物理
    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Physics:SetCollisionCallback(oncollide)
    -- 动画
    inst.AnimState:SetBank("dung_beetle")
    inst.AnimState:SetBuild("dung_beetle_build")
    inst.AnimState:PlayAnimation("idle")
    -- 实体
    inst.entity:SetPristine()
    -- 主控
    if not TheWorld.ismastersim then
        return inst
    end
    -- 状态图
    inst:SetStateGraph("SGdungbeetle")
    -- 大脑
    inst:SetBrain(brain)
    -- 移动
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.DUNG_BEETLE_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.DUNG_BEETLE_WALK_SPEED
    -- 已知位置
    inst:AddComponent("knownlocations")
    -- 战斗
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    -- 健康
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DUNG_BEETLE_HEALTH)
    -- 燃烧
    MakeSmallBurnableCharacter(inst, "body")
    -- 冻结
    MakeTinyFreezableCharacter(inst, "body")
    -- 掉落
    inst:AddComponent("lootdropper")
    -- 检查
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst, viewer)
        if not inst:HasTag("hasdung") then
            return "UNDUNGED"
        end
    end
    -- 睡觉
    inst:AddComponent("sleeper")
    -- 醒来
    inst.OnEntityWake = OnWake
    -- 睡觉
    inst.OnEntitySleep = OnSleep    
    -- 返回
    return inst
end

-- 返回
return Prefab("dungbeetle", fn, assets, prefabs)