PrefabFiles = {
    "dungbeetle",
    "dungball",
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/dungbeetle.xml"),
    Asset("IMAGE", "images/inventoryimages/dungbeetle.tex"),
    Asset("ATLAS", "images/inventoryimages/dungball.xml"),
    Asset("IMAGE", "images/inventoryimages/dungball.tex"),
}

-- 注册动物调整
TUNING.DUNG_BEETLE_HEALTH = 200
TUNING.DUNG_BEETLE_WALK_SPEED = 3
TUNING.DUNG_BEETLE_RUN_SPEED = 6

-- 注册自定义行为
AddAction("DIGDUNG", "挖粪", function(act)
    if act.target and act.target:HasTag("dungpile") and not act.doer:HasTag("hasdung") then
        -- 生成粪球
        local dungball = SpawnPrefab("dungball")
        local pt = act.target:GetPosition()
        dungball.Transform:SetPosition(pt.x, pt.y, pt.z)
        
        -- 可能移除粪堆
        if math.random() < 0.5 then
            act.target:Remove()
        end
        
        return true
    end
    return false
end)

AddAction("MOUNTDUNG", "骑上粪球", function(act)
    if act.target and act.target:HasTag("dungball") and not act.doer:HasTag("hasdung") then
        act.doer:AddTag("hasdung")
        act.target:Remove()
        return true
    end
    return false
end)

-- 注册字符串
STRINGS.NAMES.DUNGBEETLE = "屎壳郎"
STRINGS.NAMES.DUNGBALL = "粪球"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE = "它喜欢滚粪球！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBALL = "闻起来很臭，但却是好肥料。"

-- 屎壳郎状态描述
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DUNGBEETLE_UNDUNGED = "它失去了它珍贵的粪球。"