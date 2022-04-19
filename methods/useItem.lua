-- 道具
local items = {[4099] = 12275}

-- 皮肤
local skin = {
    -- skin1 = {name = "凛冬", skinId = 7, id = 4102},
    -- skin2 = {name = "胖哒", skinId = 8, id = 4103},
    -- skin3 = {name = "兔美美", skinId = 9, id = 4104},
    -- skin4 = {name = "齐天小圣", skinId = 10, id = 4105},
    -- skin5 = {name = "迷斯拉", skinId = 11, id = 4106},
    -- skin6 = {name = "琉璃酱", skinId = 12, id = 4107},
    -- skin7 = {name = "乔治", skinId = 13, id = 4108},
    -- skin8 = {name = "安妮", skinId = 14, id = 4109},
    -- skin9 = {name = "墨家小飞", skinId = 15, id = 4110},
    skin10 = {name = "德古拉六世", skinId = 16, id = 4111},
    skin11 = {name = "叮叮当", skinId = 17, id = 4112},
    skin12 = {name = "羽姬", skinId = 18, id = 4113},
    skin13 = {name = "荒原猎人雪诺", skinId = 19, id = 4114}
    -- skin14 = {name = "秋果", skinId = 125, id = 4220},
    -- skin15 = {name = "凌美琪", skinId = 126, id = 4221},
    -- skin16 = {name = "游乐王子", skinId = 127, id = 4222},
    -- skin17 = {name = "殷小敏", skinId = 128, id = 4223},
    -- skin18 = {name = "施巧灵", skinId = 129, id = 4224}

}
-- LInclude方法
function LInclude(id, table)
    local flag = false
    for i, v in ipairs(table) do if (v == id) then flag = true end end
    return flag
end
-- 获取所有skin的id
function getAllSkinId()
    local ids = {}
    for i, v in pairs(skin) do ids[#ids + 1] = v.id end

    return ids
end
-- 获取skin id 对应的skinId
function getSkinId(id)
    local Id = 0
    for i, v in pairs(skin) do
        if v.id == id then
            Id = v.skinId
            break
        end
    end
    return Id
end
-- 使用道具
function useItem(playerId, itemId)
    local playerId = playerId or 0
    local itemId = itemId or 0
    -- 道具i对应的装备id
    local equipId = items[itemId]

    -- 是否是皮肤
    local isSkin = LInclude(equipId, getAllSkinId())
    -- 检测玩家是否装备了该装备
    local isWare = Player:isEquipByResID(playerId, equipId)
    if (isSkin) then
        print("开始切换皮肤")
        local result12, name = Actor:getActorFacade(playerId)
        -- print("切换皮肤结果：",result12)
        -- print("name=", name)
        -- 皮肤id
        local skinId = getSkinId(equipId)
        if (name == "mob_" .. skinId) then
            local face = Actor:changeCustomModel(playerId, iniSkin)
            print("恢复外观=", face)
        else
            Actor:changeCustomModel(playerId, "mob_" .. skinId)
        end
    elseif (isWare == 0) then
        print("玩家已经装备了该装备")
    else
        --  将玩家现装备的装备脱下
        local re = Backpack:actEquipOffByEquipID(playerId, 4)
        print("脱下装备返回状态", re)
        -- 穿上装备
        Backpack:actEquipUpByResID(playerId, equipId)
    end
end

Player_UseItem = function(event)
    -- 玩家id
    local playerId = event.eventobjid
    -- 道具id
    local itemId = event.itemid
    print('玩家使用道具:', itemId)
    Chat:sendSystemMsg('玩家使用道具' .. itemId)
    useItem(playerId, itemId)

end
-- 任意计时器发生变化事件
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], Player_UseItem)
