local playerData = {
    [123456] = {
        skins = {1, 2, 4, 7, 9},
        props = {
            -- 羽毛
            feather = {id = 11303, num = 0},
            -- 无敌装甲
            armor = {id = 4225, num = 0},
            -- 喷射背包(大)
            bigJetBackpack = {id = 4226, num = 20},
            -- 基础枕头
            basePillow = {id = 4228, num = 0},
            -- 中型枕头
            midPillow = {id = 4229, num = 0},
            -- 哈士奇狗头枕头
            haskiPillow = {id = 4230, num = 0},
            -- 大枕头炸弹
            bigBomb = {id = 4231, num = 0},
            -- 小枕头炸弹
            smallBomb = {id = 4232, num = 0},
            -- 小熊枕头
            bearPillow = {id = 4233, num = 0},
            -- 鸡腿枕头
            chickenPillow = {id = 4234, num = 0},
            -- 葱鸭枕头
            duckPillow = {id = 4235, num = 0},
            -- 小兔子枕头
            rabbitPillow = {id = 4236, num = 0},
            -- 咸鱼枕头
            fishPillow = {id = 4237, num = 0},
            -- 书包枕头
            bagPillow = {id = 4238, num = 0},
            -- 鳄鱼枕头
            crocodilePillow = {id = 4239, num = 0},
            -- 小花枕头
            flowerPillow = {id = 4240, num = 0},
            -- 饼干枕头
            cookiePillow = {id = 4241, num = 0},
            -- 玲娜贝儿抱枕
            linaBellPillow = {id = 4242, num = 0},
            -- 计时器
            timer = {id = 4243, num = 0},
            -- 15秒防护盾
            shield15 = {id = 4244, num = 0},
            -- 库洛米抱枕
            kuromiPillow = {id = 4245, num = 0},
            -- 喷射背包(小)
            smallJetBackpack = {id = 4246, num = 0},
            -- 喷射背包(中)
            midJetBackpack = {id = 4247, num = 0},
            -- 超级遁甲
            superShield = {id = 4248, num = 0}

        }
    }
}

-- 删除表里为某一值的数
function removeValue(t, v)
    for i, v2 in ipairs(t) do if v2 == v then table.remove(t, i) end end
end
-- 删除玩家皮肤为某一值数据
function delPlayerSkins(playerId, skinId)
    removeValue(playerData[playerId].skins, skinId)
end
-- 玩家道具数量改为num
function changePlayerProps(playerId, propName, num)
    playerData[playerId].props[propName].num = num
end

delPlayerSkins(123456, 1)
changePlayerProps(123456, 'smallJetBackpack', 10)
-- 循环输出skins里的元素
for i, v in ipairs(playerData[123456].skins) do print(v) end
print(playerData[123456].props["smallJetBackpack"].num)

--   Player:gainItems(0, 236, 70, 1)
--   Player:gainItems(0, 11056, 1, 2)
-- 获取指定玩家指定物品格的物品id和数量
-- 第一个参数为玩家迷你号
-- 第二个参数0为背包栏物品格id，0为储存栏的第一格：0-29储存栏 1000-1007快捷栏 8000-8004装备栏
for i = 1, 29 do
    local result, itemid, num = Backpack:getGridItemID(1530438992, i)
    if result == 0 then -- 如果获取成功
        print("背包储存栏的第", i + 1, "格物品id为：", itemid,
              "，数量为：", num)
    end
end
