return (function()

    -- 变量库名称
    local libname = "data"
    -- 玩家池
    local playerPool = {}
    -- 道具区域id
    local propAreaId = 0
    -- 道具特效id
    local propParticleId = 1297
    -- 道具区文字版id
    local graphId = 0
    -- 准备区域id
    local playAreaId = 0
    -- 传送门开启标识
    local sendDoor = false
    -- 是否处于战斗区
    local playAreaFlag = false

    -- 装备
    local propsFlag = false -- 停用
    -- 是否初始化游戏道具
    local gainPropsFlag = false
    -- 是否开启皮肤
    local skinFlag = false

    -- 本地玩家Id
    local Players = {}
    -- 玩家二次选择
    local playersChoose = {}

    -- 是否给特殊玩家发放道具
    local playerBuff = {
        ids = {1530423300,1526843526},
        flag = false,
        skin = true,
        props = true
    }
    -- 游戏队伍
    local Teams = {red = 1, blue = 2, yellow = 3, green = 4}

    -- 位置区域数据
    local Pos = { -- 初始数据
        ix = 0,
        iy = 0,
        iz = 0, -- 默认出生点
        cx = 0,
        cz = 0,
        cr = 0 -- 雾圈原点/半径
    }
    -- 赛场文字
    local Graph = {
        -- 红队准备区
        redTeam = {
            -- 位置
            pos = {x = 25, y = 15 + 2, z = 12},
            -- pos2 = {x = 8, y = 7 - 2, z = 13},
            pos2 = {x = 10, y = 7 - 2, z = 13}
        },
        -- 蓝队准备区
        blueTeam = {
            -- 位置
            pos = {x = -9, y = 15 + 2, z = 12},
            pos2 = {x = -2, y = 7 - 2, z = 3}
        },
        -- 黄队准备区
        yellowTeam = {
            -- 位置
            pos = {x = 25, y = 15 + 2, z = -5},
            pos2 = {x = 18, y = 7 - 2, z = 3}
        },
        -- 绿队准备区
        greenTeam = {
            -- 位置
            pos = {x = -9, y = 15 + 2, z = -5},
            -- pos2 = {x = 8, y = 7 - 2, z = -7},
            pos2 = {x = 9, y = 7 - 2, z = -7}
        }

    }

    -- 游戏数据
    local Data = { -- 随游戏逻辑变更
        tickCount = 0, -- tick计数
        newTicker = 20, -- 刷新时长
        glEffectId = -1, -- 雾圈ID
        miniMarkId = -1, -- 小地图标记
        markRadius = 100, -- 地图标记半径
        isTimeout = false, -- 是否超时
        isGameEnd = false, -- 是否已结束
        isRuleInit = false, -- 游戏是否初始化
        notChooseTwice = true, -- 不需要二次选择
        deadFlag = false -- 死亡标记
    }

    -- 皮肤
    local skinCfg = {
        goBack = false,
        iniSkin = "mob_8",
        effectId = 1149,
        effectScale = 1,
        -- 换装flag
        changeSkin = true
    }
    -- 皮肤
    local skin = {
        skin1 = {name = "凛冬", skinId = 7, id = 4102},
        -- skin2 = {name = "胖哒", skinId = 8, id = 4103},
        -- skin3 = {name = "兔美美", skinId = 9, id = 4104},
        -- skin4 = {name = "齐天小圣", skinId = 10, id = 4105},
        -- skin5 = {name = "迷斯拉", skinId = 11, id = 4106},
        -- skin6 = {name = "琉璃酱", skinId = 12, id = 4107},
        skin7 = {name = "乔治", skinId = 13, id = 4108},
        skin8 = {name = "安妮", skinId = 14, id = 4109},
        skin9 = {name = "墨家小飞", skinId = 15, id = 4110},
        skin10 = {name = "德古拉六世", skinId = 16, id = 4111},
        -- skin11 = {name = "叮叮当", skinId = 17, id = 4112},
        skin12 = {name = "羽姬", skinId = 18, id = 4113}
        -- skin13 = {name = "荒原猎人雪诺", skinId = 19, id = 4114},
        -- skin14 = {name = "秋果", skinId = 125, id = 4220},
        -- skin15 = {name = "凌美琪", skinId = 126, id = 4221},
        -- skin16 = {name = "游乐王子", skinId = 127, id = 4222},
        -- skin17 = {name = "殷小敏", skinId = 128, id = 4223},
        -- skin18 = {name = "施巧灵", skinId = 129, id = 4224},

    }
    -- 特效
    local effects = {
        smallJetBackpack = {
            name = '喷射背包（小）',
            particleId = 1312,
            scale = 1
        },
        midJetBackpack = {
            name = '喷射背包（中）',
            particleId = 1312,
            scale = 2
        },
        bigJetBackpack = {
            name = '喷射背包（大）',
            particleId = 1194,
            scale = 1
        },
        shield15 = {name = '15秒防护盾', particleId = 1468, scale = 1},
        armor = {name = '无敌装甲', particleId = 1185, scale = 1},
        superShield = {name = '超级遁甲', particleId = 1565, scale = 1}
    }

    -- 游戏装备数据
    local props = {
        bigJetBackpack = {
            name = '喷射背包（大）',
            duration = 20,
            propId = 4226,
            desc = '喷射剩余时间:'
        },
        smallJetBackpack = {
            name = '喷射背包（小）',
            duration = 5,
            propId = 4246,
            desc = '喷射剩余时间:'
        },
        midJetBackpack = {
            name = '喷射背包（中）',
            duration = 10,
            propId = 4247,
            desc = '喷射剩余时间:'
        },
        shield15 = {
            name = '15秒防护盾',
            duration = 15,
            propId = 4244,
            desc = '护盾剩余时间:'
        },
        armor = {
            name = '无敌装甲',
            duration = 15,
            propId = 4225,
            desc = '无法击飞剩余时间:'
        },
        superShield = {
            name = '超级遁甲',
            duration = 25,
            propId = 4248,
            desc = '超级遁甲剩余时间:'
        }
    }
    -- 初始道具
    local gainProps = {
        -- 羽毛
        -- feather = {
        --     name = '羽毛',
        --     itemId = 4249,
        --     itemCnt = 60,
        --     prioritytype = 1
        -- },
        feather = {
            name = '羽毛',
            itemId = 4249,
            itemCnt = 60,
            prioritytype = 1
        },
        -- -- 基础枕头
        -- basePillow = {
        --     name = '枕头',
        --     itemId = 4228,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 中型枕头
        midPillow = {
            name = '中型枕头',
            itemId = 4229,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 哈士奇狗头枕头
        haskiPillow = {
            name = '哈士奇狗头枕头',
            itemId = 4230,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 大枕头炸弹
        bigBomb = {
            name = '大枕头炸弹',
            itemId = 4231,
            itemCnt = 30,
            prioritytype = 1
        },

        -- -- 小枕头炸弹
        smallBomb = {
            name = '小枕头炸弹',
            itemId = 4232,
            itemCnt = 30,
            prioritytype = 1
        },
        -- -- 小熊枕头
        bearPillow = {
            name = '小熊枕头',
            itemId = 4233,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 小熊枕头
        bearPillow = {
            name = '小熊枕头',
            itemId = 4233,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 鸡腿枕头
        chickenPillow = {
            name = '鸡腿枕头',
            itemId = 4234,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 葱鸭枕头
        duckPillow = {
            name = '葱鸭枕头',
            itemId = 4235,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 葱鸭枕头
        rabbitPillow = {
            name = '小兔子枕头',
            itemId = 4236,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 咸鱼枕头
        fishPillow = {
            name = '咸鱼枕头',
            itemId = 4237,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 书包枕头
        bagPillow = {
            name = '书包枕头',
            itemId = 4238,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 鳄鱼枕头
        crocodilePillow = {
            name = '鳄鱼枕头',
            itemId = 4239,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 小花枕头
        flowerPillow = {
            name = '小花枕头',
            itemId = 4240,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 饼干枕头
        cookiesPillow = {
            name = '饼干枕头',
            itemId = 4241,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 玲娜贝儿抱枕
        linaBellPillow = {
            name = '玲娜贝儿抱枕',
            itemId = 4242,
            itemCnt = 1,
            prioritytype = 1
        },
        -- 计时器
        -- crocodilePillow = {
        --     name = '计时器',
        --     itemId = 4243,
        --     itemCnt = 20,
        --     prioritytype = 1
        -- },
        -- 库洛米抱枕q
        kuromiPillow = {
            name = '库洛米抱枕',
            itemId = 4245,
            itemCnt = 1,
            prioritytype = 1
        },
        bigJetBackpack = {
            name = '喷射背包(大)',
            itemId = 4250,
            itemCnt = 10,
            prioritytype = 1
        },
        -- midJetBackpack = {
        --     name = '喷射背包(中)',
        --     itemId = 4251,
        --     itemCnt = 10,
        --     prioritytype = 1
        -- },
        smallJetBackpack = {
            name = '喷射背包(小)',
            itemId = 4252,
            itemCnt = 10,
            prioritytype = 1
        },
        armor = {
            name = '无敌装甲',
            itemId = 4253,
            itemCnt = 10,
            prioritytype = 1
        },
        shield15 = {
            name = '15秒防护盾',
            itemId = 4254,
            itemCnt = 10,
            prioritytype = 1
        },
        superShield = {
            name = '超级遁甲',
            itemId = 4255,
            itemCnt = 10,
            prioritytype = 1
        }

    }
    -- 道具
    local items = {
        -- 喷射背包(大)
        [4250] = 4226,
        -- 喷射背包(中)
        [4251] = 4247,
        -- 喷射背包(小)
        [4252] = 4246,
        -- 无敌装甲
        [4253] = 4225,
        -- 15秒防护盾
        [4254] = 4244,
        -- 超级遁甲
        [4255] = 4248
    }
    -- npc商店
    local npcShop = {
        red = {id = 4319270112},
        -- blue = {id = 4319270111},
        blue = {id = 4323670905},
        green = {id = 4319270110},
        -- yellow = {id = 4319270113}
        yellow = {id = 4335374483}
    }

    -------------------------------自定义方法-------------------------------
    -- 获取玩家当前所有道具
    function getPlayerProps(playerId)
        -- 参数0为背包栏物品格id，0为储存栏的第一格：0-29储存栏 1000-1007快捷栏 8000-8004装备栏

        local baseProps = {
            -- 羽毛
            [4249] = {id = 4249, num = 0},
            -- 无敌装甲
            [4225] = {id = 4225, num = 0},
            -- 喷射背包(大)
            [4226] = {id = 4226, num = 0},
            -- 基础枕头
            [4228] = {id = 4228, num = 0},
            -- 中型枕头
            [4229] = {id = 4229, num = 0},
            -- 哈士奇狗头枕头
            [4230] = {id = 4230, num = 0},
            -- 大枕头炸弹
            [4231] = {id = 4231, num = 0},
            -- 小枕头炸弹
            [4232] = {id = 4232, num = 0},
            -- 小熊枕头
            [4233] = {id = 4233, num = 0},
            -- 鸡腿枕头
            [4234] = {id = 4234, num = 0},
            -- 葱鸭枕头
            [4235] = {id = 4235, num = 0},
            -- 小兔子枕头
            [4236] = {id = 4236, num = 0},
            -- 咸鱼枕头
            [4237] = {id = 4237, num = 0},
            -- 书包枕头
            [4238] = {id = 4238, num = 0},
            -- 鳄鱼枕头
            [4239] = {id = 4239, num = 0},
            -- 小花枕头
            [4240] = {id = 4240, num = 0},
            -- 饼干枕头
            [4241] = {id = 4241, num = 0},
            -- 玲娜贝儿抱枕
            [4242] = {id = 4242, num = 0},
            -- 计时器
            [4243] = {id = 4243, num = 0},
            -- 15秒防护盾
            [4244] = {id = 4244, num = 0},
            -- 库洛米抱枕
            [4245] = {id = 4245, num = 0},
            -- 喷射背包(小)
            [4246] = {id = 4246, num = 0},
            -- 喷射背包(中)
            [4247] = {id = 4247, num = 0},
            -- 超级遁甲
            [4248] = {id = 4248, num = 0},
            -- 喷射背包(大)
            [4250] = {id = 4250, num = 0},
            -- 喷射背包(中)
            [4251] = {id = 4251, num = 0},
            -- 喷射背包(小)
            [4252] = {id = 4252, num = 0},
            -- 无敌装甲
            [4253] = {id = 4253, num = 0},
            -- 15秒防护盾
            [4254] = {id = 4254, num = 0},
            -- 超级遁甲
            [4255] = {id = 4255, num = 0},

            -- 皮肤
            [4102] = {id = 4102, num = 0},
            [4108] = {id = 4108, num = 0},
            [4109] = {id = 4109, num = 0},
            [4110] = {id = 4110, num = 0},
            [4111] = {id = 4111, num = 0},
            [4112] = {id = 4112, num = 0},
            [4113] = {id = 4113, num = 0},
            [4114] = {id = 4114, num = 0}

        }
        -- 0-29储存栏
        for i = 0, 29 do
            local result, itemid, num = Backpack:getGridItemID(playerId, i)
            if result == 0 then -- 如果获取成功
                -- print("背包储存栏的第", i + 1, "格物品id为：",
                --       itemid, "，数量为：", num)
                -- 如果num大于0
                if (num > 0 and itemid > 0) then
                    baseProps[itemid].num = baseProps[itemid].num + num
                end
            end
        end

        -- 1000-1007快捷栏
        for i = 1000, 1007 do
            local result, itemid, num = Backpack:getGridItemID(playerId, i)
            if result == 0 then -- 如果获取成功
                -- print("快捷栏的第", i - 999, "格物品id为：", itemid,
                --       "，数量为：", num)
                if (num > 0 and itemid > 0) then
                    baseProps[itemid].num = baseProps[itemid].num + num
                end
            end
        end
        -- 8000-8004装备栏
        for i = 8000, 8004 do
            local result, itemid, num = Backpack:getGridItemID(playerId, i)
            if result == 0 then -- 如果获取成功
                -- print("装备栏的第", i - 7999, "格物品id为：", itemid,
                --       "，数量为：", num)
                if (num > 0 and itemid > 0) then
                    baseProps[itemid].num = baseProps[itemid].num + num
                end
            end
        end

        -- 获取baseProps里num大于0的数据
        local props = {}
        for k, v in pairs(baseProps) do
            if (v.num > 0 or v.id == 4249) then
                table.insert(props, v)
            end
        end
        -- print(props)
        return props

    end
    -- 获取table长度
    function table_leng(t)
        local leng = 0
        for k, v in pairs(t) do leng = leng + 1 end
        return leng;
    end
    -- 获取道具对应的键值
    function getItemsKey(itemId)
        for k, v in pairs(items) do if (v == itemId) then return k end end
        return nil
    end
    -- 获取云端玩家数据
    function getUserData(playerId)
        print("获取云端玩家数据")
        local userData = {props = {}}
        local function initGamer()
            CloudSever:setDataListBykey(libvarname, tostring(playerId), userData)
            -- 初始化玩家道具
            -- Player:gainItems(playerId, 4228, 1, 1)
        end
        local ret = CloudSever:getDataListByKey(libvarname, playerId,
                                                function(ret2, k, v, ix)

            -- if ret ~= 0 or ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
            if ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
                print('返回表数据失败')
                initGamer()
            else
                -- print("v.skins = ", v.skins)
                -- print("v.props = ", v.props)
                -- 初始化玩家道具
                local gainProps = v.props
                if (table_leng(gainProps) ~= 0) then
                    for i, v in pairs(gainProps) do
                        print("增加道具id=", gainProps[i].id, "的数量=",
                              gainProps[i].num)
                        -- 实例化玩家道具
                        -- 检测是否有空间
                        local ret = Backpack:enoughSpaceForItem(playerId,
                                                                gainProps[i].id,
                                                                gainProps[i].num)
                        if ret == ErrorCode.OK then
                            Player:gainItems(playerId, gainProps[i].id,
                                             gainProps[i].num, 1)
                        end
                    end
                else
                    Player:gainItems(playerId, 4228, 1, 1)
                end

            end
        end) -- 获取key1的分数

        if ret == ErrorCode.OK then
            print('请求test表数据成功')

        else
            print("请求test表数据失败")
            Player:gainItems(playerId, 4228, 1, 1)
        end
    end
    -- 将玩家信息保存到云库
    function savePlayerData(playerId, addFeatherNum)
        -- 获取玩家拥有的道具列表，参数为玩家id
        local playerProps = getPlayerProps(playerId)
        -- print("playerProps = ", playerProps)
        for i, v in pairs(playerProps) do
            if v.id == 4249 then v.num = v.num + addFeatherNum end
        end
        print("playerProps = ", playerProps)
        -- playerProps[4249].num = playerProps[4249].num + addFeatherNum
        local data = {props = playerProps}
        local ret = CloudSever:setDataListBykey(libname, playerId, data)
        if ret == ErrorCode.OK then
            print('设置data表值成功 k = ', playerId, ',v = {....}')
        else
            print('设置data表值失败')
        end
    end
    -- 游戏规则
    function InitGameRule()
        Data.isRuleInit = true
        GameRule.EndTime = 10 -- 游戏时长
        GameRule.BgMusicMode = 4 -- 背景音乐
        -- GameRule.CurTime = 17.9 -- 当前时间
        -- GameRule.LifeNum = 9 -- 玩家生命
        -- GameRule.TeamNum = 2
        GameRule.MaxPlayers = 12
        -- GameRule.CameraDir = 1 -- 1:正视角
        -- GameRule.StartMode = 0 -- 0:房主开启
        GameRule.StartPlayers = 2
        -- GameRule.ScoreKillMob = 3 --击杀特定怪物+3分
        GameRule.ScoreKillPlayer = 5 -- 击杀玩家+5分
        -- GameRule.PlayerDieDrops = 0 -- 死亡掉落 1:true
        GameRule.DisplayScore = 1 -- 显示比分 1:true
        -- GameRule.ViewMode = 1 -- 开启失败观战 0:不开启 1:开启
        GameRule.BlockDestroy = 0 -- 是否可摧毁方块 0:否 1:是
        GameRule.CountDown = 3
    end
    -- 初始玩家道具
    function GainItems(playerId)
        -- -- 基础
        if gainPropsFlag then
            for i, v in pairs(gainProps) do
                -- print(gainProps[i].name)
                -- 检测是否有空间
                local ret = Backpack:enoughSpaceForItem(playerId,
                                                        gainProps[i].itemId,
                                                        gainProps[i].itemCnt)
                if ret == ErrorCode.OK then
                    Player:gainItems(playerId, gainProps[i].itemId,
                                     gainProps[i].itemCnt,
                                     gainProps[i].prioritytype)
                end
            end
        end

        -- -- 道具测试
        if propsFlag then
            for i, v in pairs(props) do
                -- print(props[i].name)
                -- 检测是否有空间
                local ret = Backpack:enoughSpaceForItem(playerId,
                                                        props[i].propId, 1)
                if ret == ErrorCode.OK then
                    Player:gainItems(playerId, props[i].propId, 1, 1)
                end
            end
        end
        -- -- 皮肤测试
        if skinFlag then
            for i, v in pairs(skin) do
                print(skin[i].name)
                -- 检测是否有空间
                local ret = Backpack:enoughSpaceForItem(playerId, skin[i].id, 1)
                if ret == ErrorCode.OK then
                    Player:gainItems(playerId, skin[i].id, 1, 1)
                end
            end
        end
        -- 特殊玩家
        if (playerBuff.flag) then
            for i, v in pairs(playerBuff.ids) do
                if (playerId == v) then
                    -- 添加皮肤
                    if playerBuff.skin then
                        for i, v in pairs(skin) do
                            print(skin[i].name)
                            -- 检测是否有空间
                            local ret = Backpack:enoughSpaceForItem(playerId,
                                                                    skin[i].id,
                                                                    1)
                            if ret == ErrorCode.OK then
                                Player:gainItems(playerId, skin[i].id, 1, 1)
                            end
                        end
                    end
                    -- 添加道具
                    if playerBuff.props then
                        for i, v in pairs(gainProps) do
                            -- 检测是否有空间
                            local ret = Backpack:enoughSpaceForItem(playerId,
                                                                    gainProps[i]
                                                                        .itemId,
                                                                    gainProps[i]
                                                                        .itemCnt)
                            if ret == ErrorCode.OK then
                                Player:gainItems(playerId, gainProps[i].itemId,
                                                 gainProps[i].itemCnt,
                                                 gainProps[i].prioritytype)
                            end
                        end
                    end
                end
            end
        end

        -- 获取玩家数据
        getUserData(playerId)
    end

    -- 初始化玩家信息
    function InitGamePlayer(playerId)
        -- 初始化玩家视角
        -- 第二个参数为视角模式：0主视角 1背视角 2正视角 3俯视角 4俯视角 5自定义视角
        Player:changeViewMode(playerId, 1, false)
        -- 清空玩家的所有物品
        Backpack:clearAllPack(playerId)
        -- 可移动
        -- local re = Player:setActionAttrState(playerId, 1, false)
        -- print("设置不可移动结果：",re)
        -- Actor:setActionAttrState(3402, 1, false)
        -- 可摆放方块
        -- Player:setActionAttrState(playerId, 2, false)
        -- 可操作方块
        -- Player:setActionAttrState(playerId, 4, false)
        -- 可破坏方块
        Actor:setActionAttrState(playerId, 8, false)
        -- 可被攻击
        -- Player:setActionAttrState(playerId, 64, true)
        -- 可丢弃道具
        -- Player:setActionAttrState(playerId, 2048, false)
        -- 可使用道具
        -- Actor:setActionAttrState(playerId, 16, false)

        -- 玩家移动方式
        -- Player:changPlayerMoveType(playerId, 1)
        -- 加入玩家id组
        -- Players[#Players + 1] = playerId
        -- 初始化玩家皮肤
        Actor:changeCustomModel(playerId, skinCfg.iniSkin)
        --  -- 初始化玩家重生点
        -- local x, z = GetRandomPoint()
        -- print("x", x)
        -- print("z", z)
        -- local result,x,y,z=Actor:getPosition(playerId)
        -- print("adsasas")
        -- local re = Player:setRevivePoint(playerId, x, 13, z)
        -- local re = Player:setRevivePoint(playerId, 26, 13, 7)
        -- print("初始化玩家重生点结果:", re)

        -- 默认给玩家的道具
        GainItems(playerId)
    end

    -- 清除所有特效
    function initEffect(playerId)
        -- print("清除所有特效") 
        -- 清除所有特效
        for i, v in pairs(effects) do stopEffect(playerId, v.particleId) end
    end
    -- 清除玩家叠加状态
    function clearPlayerState(playerId)
        -- 玩家可被击退
        -- local re1 = Creature:addModAttrib(playerId, 26, 0.1)
        -- 下降玩家位置
        -- local result, x, y, z = Actor:getPosition(playerId)
        -- local re1 = Actor:setPosition(playerId, x, 7, z)
        --  玩家可移动
        local re2 = Actor:setActionAttrState(playerId, 1, true)
        --  移动方式变为默认
        local re3 = Player:changPlayerMoveType(playerId, 0)
        print("清除状态：", re1, re2, re3)

    end
    -- 给玩家播放特效
    function playEffect(playerId, particleId, scale)
        Scale = scale or 1
        local re = Actor:playBodyEffectById(playerId, particleId, Scale)
        -- print("播放特效结果=", re)
    end
    -- 停止玩家特效
    function stopEffect(playerId, particleId)
        Actor:stopBodyEffectById(playerId, particleId)
    end
    -- 设置玩家分数
    function PlayerAddScore(playerId, addScore)
        if playerId <= 0 then return end

        local ret, currScore = Player:getGameScore(playerId)
        if ret == ErrorCode.OK then
            local playScore = currScore + addScore
            if addScore < 0 then -- 设置玩家分数
                playScore = math.max(0, playScore)
            end
            Player:setGameScore(playerId, playScore)
            -- print('add score', playScore)
            -- Chat:sendSystemMsg('add score' .. playScore)
        end

        local ret, teamId = Player:getTeam(playerId)
        -- print("队伍Id:", teamId)
        if ret == ErrorCode.OK and teamId > 0 then
            local ret, teamScore = Team:getTeamScore(teamId)
            if addScore < 0 then -- 设置队伍分数
                teamScore = math.max(0, addScore + teamScore)
                Team:setTeamScore(teamId, teamScore)
            else
                Team:addTeamScore(teamId, addScore)
            end
        end
    end
    -- 玩家道具附魔属性增加
    local function Prop_Add(eventobjid, pName)
        -- print('玩家获得装备', pName)

        -- 击退附魔 “葱鸭”抱枕 咸鱼抱枕
        if (pName == '中型枕头' or pName == '“葱鸭”抱枕' or pName ==
            '咸鱼抱枕') then
            -- 击退附魔（11为附魔id,1-5个等级）
            Actor:addEnchant(eventobjid, 5, 11, 1)
            -- 在聊天框显示
            -- Chat:sendSystemMsg("手中的物品被添加了击退1的附魔")
        elseif (pName == '玲娜贝儿抱枕' or pName == '库洛米抱枕' or
            pName == '鳄鱼抱枕') then
            -- 击退附魔（11为附魔id,1-5个等级）
            Actor:addEnchant(eventobjid, 5, 11, 2)
            -- 在聊天框显示
            -- Chat:sendSystemMsg("手中的物品被添加了击退2的附魔")
        end

    end

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
    -- 获取所有props的id
    function getAllPropsId()
        local ids = {}
        for i, v in pairs(props) do ids[#ids + 1] = v.propId end

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
    -- 根据得分返回排名加分
    function getAddScore(score)
        local function sortScore(score)
            local t = {}
            for k, v in pairs(score) do table.insert(t, v) end
            table.sort(t)
            local rank = {}
            for i, v in ipairs(t) do
                for k, v2 in pairs(score) do
                    if v == v2 then rank[k] = i end
                end
            end
            return rank
        end
        local rank = sortScore(score)
        local teamAddScore = {}
        for i, v in ipairs(rank) do
            if (v == 1) then
                teamAddScore[i] = 2
            elseif (v == 2) then
                teamAddScore[i] = 4
            elseif (v == 3) then
                teamAddScore[i] = 6
            elseif (v == 4) then
                teamAddScore[i] = 8

            end

        end
        return (teamAddScore)
    end

    -- 获取排名加分
    function rankScore()
        local Score = {[1] = 10, [2] = 0, [3] = 0, [4] = 50}
        for i = 1, 4 do
            local result, score = Team:getTeamScore(i)
            Score[i] = score
        end
        return getAddScore(Score)
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
            if (name == "mob_" .. skinId and skinCfg.goBack) then
                local face = Actor:changeCustomModel(playerId, skinCfg.iniSkin)
                -- print("恢复外观=", face)
            else
                Actor:changeCustomModel(playerId, "mob_" .. skinId)
            end
        elseif (isWare == 0) then
            -- print("玩家已经装备了该装备")
        else
            --  将玩家现装备的装备脱下
            local re = Backpack:actEquipOffByEquipID(playerId, 4)
            -- print("脱下装备返回状态", re)
            if (re == 0) then
                -- 删除脱下的装备
                Player:removeBackpackItem(playerId,
                                          playersChoose[playerId].wareId, 1)
                -- 新增装备对应的道具
                local equipId = getItemsKey(playersChoose[playerId].wareId)
                Player:gainItems(playerId, equipId, 1, 1)
            end
            -- 移除玩家背包里的物品
            local re = Player:removeBackpackItem(playerId, itemId, 1)
            -- print("移除玩家背包里的物品结果：", re)
            -- 检测是否有空间
            local ret = Backpack:enoughSpaceForItem(playerId, equipId, 1)
            -- 背包新增道具对应的装备
            if ret == ErrorCode.OK then
                local re = Player:gainItems(playerId, equipId, 1, 2)
                if re == ErrorCode.OK then
                    -- 穿上装备
                    local re1 = Backpack:actEquipUpByResID(playerId, equipId)
                    -- print("穿上装备返回状态", re1)
                end
            end
            playersChoose[playerId].wareId = 0

        end
    end
    -- 生成赛场传送门文字
    function createDoorText(x, y, z)
        -- print("生成赛场传送门文字", x, y, z)
        -- 创建一个文字板
        local title = "#R 进入赛场" -- 文字内容
        local font = 16 -- 字体大小
        local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
        local itype = 1 -- 文字板编号
        -- 创建一个文字板信息，存到graphicsInfo中
        local graphicsInfo =
            Graphics:makeGraphicsText(title, font, alpha, itype)
        local re = Graphics:createGraphicsTxtByPos(x, y, z, graphicsInfo, 0, 0)
    end
    -- 初始npc商店生物
    function initNpcShop()

        for k, v in pairs(npcShop) do
            -- 不可可被攻击
            Actor:setActionAttrState(v.id, 64, false)
            -- 不可移动
            Actor:setActionAttrState(v.id, 1, false)
            -- 不可被杀死
            Actor:setActionAttrState(v.id, 128, false)
            -- 附魔
            -- Creature:addModAttrib(v.id, 26, 1)
            -- Creature:addModAttrib(v.id, 21, 10)
            -- Creature:addModAttrib(v.id, 25, 10)
        end

    end
    -- 替换准备区星能块
    function replacePowerBlock(blockid)
        local blockid = blockid or 415
        -- 星能块id 415
        -- 冰块id 123
        Block:placeBlock(blockid, Graph.redTeam.pos.x, Graph.redTeam.pos.y - 4,
                         Graph.redTeam.pos.z, 0)
        Block:placeBlock(blockid, Graph.redTeam.pos2.x, Graph.redTeam.pos2.y,
                         Graph.redTeam.pos2.z, 0)

        Block:placeBlock(blockid, Graph.blueTeam.pos.x,
                         Graph.blueTeam.pos.y - 4, Graph.blueTeam.pos.z, 0)
        Block:placeBlock(blockid, Graph.blueTeam.pos2.x, Graph.blueTeam.pos2.y,
                         Graph.blueTeam.pos2.z, 0)

        Block:placeBlock(blockid, Graph.greenTeam.pos.x,
                         Graph.greenTeam.pos.y - 4, Graph.greenTeam.pos.z, 0)
        Block:placeBlock(blockid, Graph.greenTeam.pos2.x,
                         Graph.greenTeam.pos2.y, Graph.greenTeam.pos2.z, 0)

        Block:placeBlock(blockid, Graph.yellowTeam.pos.x,
                         Graph.yellowTeam.pos.y - 4, Graph.yellowTeam.pos.z, 0)
        Block:placeBlock(blockid, Graph.yellowTeam.pos2.x,
                         Graph.yellowTeam.pos2.y, Graph.yellowTeam.pos2.z, 0)
    end
    -- 传送点生成空气墙
    function sendDoorWall(flag)
        local flag = flag or 0
        -- print("flag", flag)
        -- 空气墙id
        -- local wallId = 1001
        local wallId = 1
        if flag == 0 then
            -- 生成空气墙
            -- 红队
            Block:placeBlock(wallId, Graph.redTeam.pos.x, Graph.redTeam.pos.y,
                             Graph.redTeam.pos.z, 0)
            Block:placeBlock(wallId, Graph.redTeam.pos.x,
                             Graph.redTeam.pos.y - 1, Graph.redTeam.pos.z, 0)
            -- 蓝队
            Block:placeBlock(wallId, Graph.blueTeam.pos.x, Graph.blueTeam.pos.y,
                             Graph.blueTeam.pos.z, 0)
            Block:placeBlock(wallId, Graph.blueTeam.pos.x,
                             Graph.blueTeam.pos.y - 1, Graph.blueTeam.pos.z, 0)
            -- 绿队
            Block:placeBlock(wallId, Graph.greenTeam.pos.x,
                             Graph.greenTeam.pos.y, Graph.greenTeam.pos.z, 0)
            Block:placeBlock(wallId, Graph.greenTeam.pos.x,
                             Graph.greenTeam.pos.y - 1, Graph.greenTeam.pos.z, 0)
            -- 黄队
            Block:placeBlock(wallId, Graph.yellowTeam.pos.x,
                             Graph.yellowTeam.pos.y, Graph.yellowTeam.pos.z, 0)
            Block:placeBlock(wallId, Graph.yellowTeam.pos.x,
                             Graph.yellowTeam.pos.y - 1, Graph.yellowTeam.pos.z,
                             0)

        else
            -- 销毁空气墙
            -- 红队
            Block:destroyBlock(Graph.redTeam.pos.x, Graph.redTeam.pos.y,
                               Graph.redTeam.pos.z, false)
            Block:destroyBlock(Graph.redTeam.pos.x, Graph.redTeam.pos.y - 1,
                               Graph.redTeam.pos.z, false)
            -- 蓝队
            Block:destroyBlock(Graph.blueTeam.pos.x, Graph.blueTeam.pos.y,
                               Graph.blueTeam.pos.z, false)
            Block:destroyBlock(Graph.blueTeam.pos.x, Graph.blueTeam.pos.y - 1,
                               Graph.blueTeam.pos.z, false)
            -- 绿队
            Block:destroyBlock(Graph.greenTeam.pos.x, Graph.greenTeam.pos.y,
                               Graph.greenTeam.pos.z, false)
            Block:destroyBlock(Graph.greenTeam.pos.x, Graph.greenTeam.pos.y - 1,
                               Graph.greenTeam.pos.z, false)
            -- 黄队
            Block:destroyBlock(Graph.yellowTeam.pos.x, Graph.yellowTeam.pos.y,
                               Graph.yellowTeam.pos.z, false)
            Block:destroyBlock(Graph.yellowTeam.pos.x,
                               Graph.yellowTeam.pos.y - 1,
                               Graph.yellowTeam.pos.z, false)

        end

    end
    -- 初始化队伍位置
    function initPlayerPos(playerId, teamId)
        if (teamId == 1) then
            local re1 = Actor:setPosition(playerId, Graph.redTeam.pos.x,
                                          Graph.redTeam.pos.y - 1,
                                          Graph.redTeam.pos.z)
            print("初始红队位置结果：", re1)
        elseif (teamId == 2) then
            local re2 = Actor:setPosition(playerId, Graph.blueTeam.pos.x,
                                          Graph.blueTeam.pos.y - 1,
                                          Graph.blueTeam.pos.z)
            print("初始蓝队位置结果：", re2)
        elseif (teamId == 3) then
            local re3 = Actor:setPosition(playerId, Graph.greenTeam.pos.x,
                                          Graph.greenTeam.pos.y - 1,
                                          Graph.greenTeam.pos.z)
            print("初始绿色队位置结果：", re3)
        elseif (teamId == 4) then
            local re4 = Actor:setPosition(playerId, Graph.yellowTeam.pos.x,
                                          Graph.yellowTeam.pos.y - 1,
                                          Graph.yellowTeam.pos.z)
            print("初始黄队位置结果：", re4)
        end

    end

    -- 监听事件
    function ListenEvents_MiniDemo()
        -- 游戏事件---
        ScriptSupportEvent:registerEvent([=[Game.Start]=], Game_StartGame)
        -- 玩家死亡
        ScriptSupportEvent:registerEvent([=[Player.Die]=], Player_Dead)

        -- 方块被破坏
        ScriptSupportEvent:registerEvent([=[Block.DestroyBy]=], Block_DestroyBy)

        -- 玩家选择快捷栏
        ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=],
                                         Player_SelectShortcut)
        -- 玩家进入区域
        ScriptSupportEvent:registerEvent([=[Player.AreaIn]=], Player_AreaIn)
        -- 玩家离开区域
        ScriptSupportEvent:registerEvent([=[Player.AreaOut]=], Player_AreaOut)

        --  玩家穿上装备
        ScriptSupportEvent:registerEvent([=[Player.EquipOn]=], Player_EquipOn)

        -- 任意计时器发生变化事件
        ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange)
        -- 玩家受到伤害
        ScriptSupportEvent:registerEvent([=[Player.BeHurt]=], Player_BeHurt)
        -- 任一玩家进入游戏	
        ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=],
                                         Game_AnyPlayer_EnterGame)

        -- 玩家脱下装备
        ScriptSupportEvent:registerEvent([=[Player.EquipOff]=], Player_EquipOff)
        -- 游戏结束
        ScriptSupportEvent:registerEvent([=[Game.End]=], Game_GameOver)
        -- 玩家使用道具
        ScriptSupportEvent:registerEvent([=[Player.UseItem]=], Player_UseItem)
        -- 玩家新增道具
        ScriptSupportEvent:registerEvent([=[Player.AddItem]=], Player_AddItem)
        -- 任一玩家离开游戏
        ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], Game_AnyPlayer_LeaveGame)
        -- 玩家点击生物，在聊天框显示生物id

        -- 游戏update
        -- ScriptSupportEvent:registerEvent([=[Game.Run]=], function(e)
        --     for i, v in ipairs(playerPool) do
        --         -- 获取玩家队伍
        --         local playerId = v
        --         local ret, teamId = Player:getTeam(playerId)
        --         -- print("玩家id为：", playerId, "的队伍id为：", teamId)
        --         if (teamId == 0) then
        --             print("玩家id为：", playerId, "的队伍未初始化")
        --             playersChoose[playerId].teamFlag = 1
        --         end
        --         if (playersChoose[playerId].teamFlag == 1 and teamId ~= 0) then
        --             print("玩家id为：", playerId, "的队伍id为：",
        --                   teamId, "初始化成功")
        --             initPlayerPos(playerId, teamId)
        --             playersChoose[v].teamFlag = 0
        --         end
        --     end
        -- end)

    end

    -------------------------------游戏事件-------------------------------

    Game_StartGame = function()
        Chat:sendSystemMsg("游戏开始")

        -- 初始化游戏规则
        if not Data.isRuleInit then InitGameRule() end
        -- 初始化游戏数据
        if (Data.deadFlag == false) then
            Data.deadFlag = true
            -- 初始化npc商店生物状态
            initNpcShop()
            -- 初始化生成道具区域
            -- 通过起点终点坐标创建区域
            local result, areaid = Area:createAreaRectByRange({
                x = 9,
                y = 6,
                z = 2
            }, {x = 7, y = 11, z = 4})
            propAreaId = areaid
            -- 在此位置播放特效
            World:playParticalEffect(8, 6, 3, propParticleId, 3)

            -- 创建一个文字板
            local title = " 道具区" -- 文字内容
            local font = 16 -- 字体大小
            local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
            local itype = 1 -- 文字板编号
            -- 创建一个文字板信息，存到graphicsInfo中
            local graphicsInfo = Graphics:makeGraphicsText(title, font, alpha,
                                                           itype)
            local re = Graphics:createGraphicsTxtByPos(8, 8, 3, graphicsInfo, 0,
                                                       0)

            -- 初始战斗区
            local result, areaid = Area:createAreaRectByRange({
                x = -7,
                y = 0,
                z = 16
            }, {x = 22, y = 15, z = -9})
            playAreaId = areaid

            -- 初始化传送点方块
            -- replacePowerBlock(123)
            -- 初始传送门能源
            replacePowerBlock(415)
            -- 初始化传送点空气墙
            sendDoorWall(1)

        end
        -- 计时器结束函数
        --   function door(playerId)
        --     if (Data.deadFlag == false) then
        --       -- 创建进入赛场传送门文字
        --       -- 红队
        --       createDoorText(Graph.redTeam.pos.x, Graph.redTeam.pos.y,
        --                      Graph.redTeam.pos.z)
        --       -- 蓝队
        --       createDoorText(Graph.blueTeam.pos.x, Graph.blueTeam.pos.y,
        --                      Graph.blueTeam.pos.z)
        --       -- 绿队
        --       createDoorText(Graph.greenTeam.pos.x, Graph.greenTeam.pos.y,
        --                      Graph.greenTeam.pos.z)
        --       -- 黄队
        --       createDoorText(Graph.yellowTeam.pos.x, Graph.yellowTeam.pos.y,
        --                      Graph.yellowTeam.pos.z)

        --       -- 初始化玩家信息
        --       -- InitGamePlayer(isTestMode)
        --       -- 初始化npc商店生物状态
        --       initNpcShop()
        --       -- 初始传送门能源
        --       replacePowerBlock(415)
        --       Data.deadFlag = true
        --   end
        -- end
        -- -- 设置计时器
        -- local re = Timer:setTimer(0, "door",
        --                           30, true,
        --                           "赛场传送门开启倒计时：", 0,
        --                           door, 0)
        -- if (Data.deadFlag == false) then
        --     -- 创建进入赛场传送门文字
        --     -- 红队
        --     createDoorText(Graph.redTeam.pos.x, Graph.redTeam.pos.y,
        --                    Graph.redTeam.pos.z)
        --     -- 蓝队
        --     createDoorText(Graph.blueTeam.pos.x, Graph.blueTeam.pos.y,
        --                    Graph.blueTeam.pos.z)
        --     -- 绿队
        --     createDoorText(Graph.greenTeam.pos.x, Graph.greenTeam.pos.y,
        --                    Graph.greenTeam.pos.z)
        --     -- 黄队
        --     createDoorText(Graph.yellowTeam.pos.x, Graph.yellowTeam.pos.y,
        --                    Graph.yellowTeam.pos.z)

        --     -- 初始传送门能源
        --     replacePowerBlock(415)
        --     Data.deadFlag = true
        -- end

    end
    -- 玩家死亡
    Player_Dead = function(trigger_obj)

        -- 他杀
        if (trigger_obj['toobjid']) then
            local killById = trigger_obj['toobjid']

            PlayerAddScore(killById, 5)

        end
        -- 自杀
        if (trigger_obj['eventobjid']) then
            local playerId = trigger_obj['eventobjid']

        end
        -- 清除所有特效
        -- initEffect(trigger_obj['eventobjid'])
        -- 清楚玩家叠加状态
        -- clearPlayerState(trigger_obj['eventobjid'])
        -- 脱下装备
        --  将玩家现装备的装备脱下
        -- local re = Backpack:actEquipOffByEquipID(trigger_obj['eventobjid'], 4)
        -- print("脱下装备返回状态", re)
        --   if (re == 0) then
        --     -- 删除脱下的装备
        --     Player:removeBackpackItem(trigger_obj['eventobjid'],
        --                               playersChoose[playerId].wareId, 1)
        --     -- -- 新增装备对应的道具
        --     -- local equipId = getItemsKey(playersChoose[playerId].wareId)
        --     -- Player:gainItems(playerId, equipId, 1, 1)
        -- end
    end

    -- 方块被破坏
    Block_DestroyBy = function(event)
        Block:placeBlock(event.blockid, event.x, event.y, event.z, 0)
    end
    -- 玩家选择快捷栏
    Player_SelectShortcut = function(event)
        -- print(event)
        -- Chat:sendSystemMsg('选择快捷栏')
        -- print('是否处于战斗区：', playAreaFlag)

        local itemid = event.itemid
        local playerId = event.eventobjid

        -- 获取玩家当前选中的快捷栏位置
        local result, scutIdx = Player:getCurShotcut(playerId)
        if (result == 0) then
            if (itemid == playersChoose[playerId].itemid and scutIdx ==
                playersChoose[playerId].scutIdx or Data.notChooseTwice) then
                -- print('成功选择', itemid, "与", scutIdx)
                -- Chat:sendSystemMsg('成功选择' .. itemid .. "与" .. scutIdx)
                local result3, itemid = Item:getItemId(event.itemid)
                -- print(event.itemid)
                local result, name = Item:getItemName(event.itemid)
                -- 如果是装备
                -- jetBackpack  shield15  armor
                if (event.itemid == props["smallJetBackpack"].propId or
                    event.itemid == props["midJetBackpack"].propId or
                    event.itemid == props["bigJetBackpack"].propId or
                    event.itemid == props["shield15"].propId or event.itemid ==
                    props["armor"].propId or event.itemid ==
                    props["superShield"].propId) then

                    -- 将玩家现装备的装备脱下
                    local re =
                        Backpack:actEquipOffByEquipID(event.eventobjid, 4)
                    print("脱下装备返回状态", re)
                    Backpack:actEquipUpByResID(event.eventobjid, event.itemid)

                    -- elseif (event.itemid == skin["skin11"].id) then
                elseif (LInclude(event.itemid, getAllSkinId()) and
                    skinCfg.changeSkin) then
                    local result12, name =
                        Actor:getActorFacade(event.eventobjid)
                    -- print("切换皮肤结果：",result12)
                    print("开始切换皮肤=", name)

                    if (name == "mob_" .. getSkinId(event.itemid) and
                        skinCfg.goBack) then
                        -- local test = Actor:recoverinitialModel(event.eventobjid)
                        local test = Actor:changeCustomModel(event.eventobjid,
                                                             skinCfg.iniSkin)
                        print("恢复外观=", test)
                    else
                        Actor:changeCustomModel(event.eventobjid, "mob_" ..
                                                    getSkinId(event.itemid))
                    end
                    -- 播放特效
                    playEffect(playerId, skinCfg.effectId, skinCfg.effectScale)

                else
                    Prop_Add(event.eventobjid, name)
                end
            else
                playersChoose[playerId].itemid = itemid
                playersChoose[playerId].scutIdx = scutIdx
                local result, name = Item:getItemName(event.itemid)
                Prop_Add(event.eventobjid, name)
            end
        end

    end
    -- 玩家进入区域
    Player_AreaIn = function(event)

        if (event.areaid == propAreaId) then

            function featherTimer(playerId)
                -- 生成羽毛
                local result, objid = World:spawnItem(8, 7, 3, 4249, 1)
                -- 删除文字板
                local re = Graphics:removeGraphicsByPos(8, 9, 3, 1, 1)
                local title = "#cFF33CC 生成羽毛中，得分＋1"
                local font = 14 -- 字体大小
                local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
                local itype = 1 -- 文字板编号
                -- 创建一个文字板信息，存到graphicsInfo中
                local graphicsInfo = Graphics:makeGraphicsText(title, font,
                                                               alpha, itype)
                local re, graphid = Graphics:createGraphicsTxtByPos(8, 9, 3,
                                                                    graphicsInfo,
                                                                    0, 0)
                graphId = graphid
                -- 玩家加分
                PlayerAddScore(playerId, 1)

                -- 再开启一个计时器

                if Data.isGameEnd == false then
                    -- print("再开启一个羽毛计时器")
                    -- print("playerId=", playerId)
                    local re = Timer:setTimer(playerId, "featherTimer", 1,
                                              false, "", playerId, featherTimer,
                                              playerId)
                    -- print("设置计时器结果：", re)
                end
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid, "featherTimer", 1,
                                      false, "", event.eventobjid, featherTimer,
                                      event.eventobjid)
            -- 创建一个文字板
            local title = "#cFF33CC 生成羽毛中，得分＋1"
            local font = 14 -- 字体大小
            local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
            local itype = 1 -- 文字板编号
            -- 创建一个文字板信息，存到graphicsInfo中
            local graphicsInfo = Graphics:makeGraphicsText(title, font, alpha,
                                                           itype)
            local re, graphid = Graphics:createGraphicsTxtByPos(8, 9, 3,
                                                                graphicsInfo, 0,
                                                                0)
            graphId = graphid
        elseif (event.areaid == playAreaId) then
            -- print("进入战斗区")
            -- Chat:sendSystemMsg("进入战斗区")

            playAreaFlag = true

        end

    end
    -- 玩家离开区域
    Player_AreaOut = function(event)
        if (event.areaid == propAreaId) then
            -- 删除文字板
            local re = Graphics:removeGraphicsByPos(8, 9, 3, 1, 1)
            -- 删除计时器
            local re = Timer:delTimer(event.eventobjid, "featherTimer")
        elseif (event.areaid == playAreaId) then
            -- print("离开战斗区")
            -- Chat:sendSystemMsg("离开战斗区")
            playAreaFlag = false

        end
    end
    -- 玩家穿上装备
    Player_EquipOn = function(event)
        local playerId = event.eventobjid
        local itemId = event.itemid
        playersChoose[playerId].wareId = itemId
        local result, name = Item:getItemName(event.itemid)
        -- print('获得装备' .. name)
        -- Chat:sendSystemMsg('获得装备' .. name)

        -- 判断道具类型
        if (name == props["smallJetBackpack"].name) then
            -- print('获得飞行技能')
            -- Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["smallJetBackpack"].particleId,
                       effects["smallJetBackpack"].scale)
            function smallJetBackpack(playerId)
                --  移动方式变为默认
                Player:changPlayerMoveType(playerId, 0)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)
                -- 停止特效
                stopEffect(playerId, effects["smallJetBackpack"].particleId)

            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid,
                                      props["smallJetBackpack"].name,
                                      props["smallJetBackpack"].duration, true,
                                      props["smallJetBackpack"].desc,
                                      event.eventobjid, smallJetBackpack,
                                      event.eventobjid)

            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["midJetBackpack"].name) then
            -- print('获得飞行技能')
            -- Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["midJetBackpack"].particleId,
                       effects["midJetBackpack"].scale)
            function midJetBackpack(playerId)
                --  移动方式变为默认
                Player:changPlayerMoveType(playerId, 0)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)

                -- 停止特效
                stopEffect(playerId, effects["midJetBackpack"].particleId)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid,
                                      props["midJetBackpack"].name,
                                      props["midJetBackpack"].duration, true,
                                      props["midJetBackpack"].desc,
                                      event.eventobjid, midJetBackpack,
                                      event.eventobjid)
            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["bigJetBackpack"].name) then
            -- print('获得飞行技能')
            -- Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["bigJetBackpack"].particleId,
                       effects["bigJetBackpack"].scale)
            function bigJetBackpack(playerId)
                --  移动方式变为默认
                Player:changPlayerMoveType(playerId, 0)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)

                -- 停止特效
                stopEffect(playerId, effects["bigJetBackpack"].particleId)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid,
                                      props["bigJetBackpack"].name,
                                      props["bigJetBackpack"].duration, true,
                                      props["bigJetBackpack"].desc,
                                      event.eventobjid, bigJetBackpack,
                                      event.eventobjid)

            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["armor"].name) then
            -- print('获得无法击飞技能')
            -- Chat:sendSystemMsg('获得无法击飞技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["armor"].particleId,
                       effects["armor"].scale)
            -- 技能结束函数
            function armor(playerId)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)

                --  玩家可移动
                Actor:setActionAttrState(playerId, 1, true)
                -- 停止特效
                stopEffect(playerId, effects["armor"].particleId)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid, props["armor"].name,
                                      props["armor"].duration, true,
                                      props["armor"].desc, event.eventobjid,
                                      armor, event.eventobjid)

            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
            Actor:setActionAttrState(event.eventobjid, 1, false)

        elseif (name == props["superShield"].name) then
            -- print('获得超级遁甲技能')
            -- Chat:sendSystemMsg('获得超级遁甲技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["superShield"].particleId,
                       effects["superShield"].scale)
            -- 技能结束函数
            function superShield(playerId)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)

                -- 停止特效
                stopEffect(playerId, effects["superShield"].particleId)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid,
                                      props["superShield"].name,
                                      props["superShield"].duration, true,
                                      props["superShield"].desc,
                                      event.eventobjid, superShield,
                                      event.eventobjid)

            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
        elseif (name == props["shield15"].name) then
            -- print('获得15s护盾技能1')
            -- Chat:sendSystemMsg('获得15s护盾技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["shield15"].particleId,
                       effects["shield15"].scale)
            -- 技能结束函数
            function shield15(playerId)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)
                -- 销毁装备
                local result = Backpack:actDestructEquip(playerId, 4)

                -- 停止特效
                stopEffect(playerId, effects["shield15"].particleId)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid, props["shield15"].name,
                                      props["shield15"].duration, true,
                                      props["shield15"].desc, event.eventobjid,
                                      shield15, event.eventobjid)

            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
        end

    end

    -- -- 计时器改变
    -- minitimerChange = function(arg)

    --     local result, second = MiniTimer:getTimerTime(arg.timerid)
    --     -- 删除文字板
    --     local re = Graphics:removeGraphicsByPos(8, 9, 3, 1, 1)

    --     -- 如果是羽毛计时器
    --     if (string.find(arg.timername, "featherTimer") ~= nil) then

    --         -- 创建一个文字板
    --         local title = "#cFF33CC 羽毛＋1，得分＋1"
    --         local font = 14 -- 字体大小
    --         local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
    --         local itype = 1 -- 文字板编号
    --         -- 创建一个文字板信息，存到graphicsInfo中
    --         local graphicsInfo = Graphics:makeGraphicsText(title, font, alpha,
    --                                                        itype)
    --         local re, graphid = Graphics:createGraphicsTxtByPos(8, 9, 3,
    --                                                             graphicsInfo, 0,
    --                                                             0)
    --         graphId = graphid

    --     end

    -- end
    -- 玩家受到伤害
    Player_BeHurt = function(event)
        -- 加血
        Actor:addHP(event.eventobjid, 100)

    end
    -- 任一玩家进入游戏
    Game_AnyPlayer_EnterGame = function(event)
        -- print("玩家进入游戏")

        -- 初始化玩家信息
        InitGamePlayer(event.eventobjid)
        -- 将玩家id添加到玩家列表
        playerPool[#playerPool + 1] = event.eventobjid
        -- 加入玩家选择组
        playersChoose[event.eventobjid] = {
            itemid = 0,
            scutIdx = 0,
            wareId = 0,
            teamFlag = 0
        }
        -- 设置位置
        -- local re2 = Actor:setPosition(event.eventobjid,
        --                                               15,
        --                                               -6,
        --                                               13)
        --                 print("初始化玩家位置结果=", re2)

    end
    -- 玩家脱下装备
    Player_EquipOff = function(e)
        local name = ""
        for k, v in pairs(props) do
            if v.propId == e.itemid then
                -- print(v.name)
                name = v.name
            end
        end

        local re = Timer:pauseTimer(e.eventobjid, name, false,
                                    "暂停计时器:", e.eventobjid)

        -- 清楚玩家叠加状态
        clearPlayerState(e.eventobjid)
        -- 清除所有特效
        initEffect(e.eventobjid)

        -- 下降玩家位置
        -- if (playAreaFlag == false) then
        --     local result, x, y, z = Actor:getPosition(e.eventobjid)
        --     local re1 = Actor:setPosition(e.eventobjid, x, 15, z)
        -- else
        --     local result, x, y, z = Actor:getPosition(e.eventobjid)
        --     local re1 = Actor:setPosition(e.eventobjid, x, 7, z)
        -- end
        -- 如果是道具
        -- if (LInclude(e.itemid, getAllPropsId())) then
        --   print(e.eventobjid)
        --   print(e.itemid)
        --     -- 删除脱下的装备
        --     Player:removeBackpackItem(e.eventobjid, e.itemid, 1)
        --     -- 新增装备对应的道具
        --     local equipId = getItemsKey(e.itemid)
        --     Player:gainItems(e.eventobjid, equipId, 1, 1)
        -- end
        local playerId = e.eventobjid
        local itemId = e.itemid
        print("脱了", itemId)
        --- 删除脱下的装备
        --  Player:removeBackpackItem(playerId, itemId, 1)
        playersChoose[playerId].wareId = itemId

    end
    -- 游戏结束
    Game_GameOver = function(e)
        print("游戏结束")
        Data.isGameEnd = true
        -- 获取排名加分
        local rankS = rankScore()
        for i, v in ipairs(playerPool) do
            print(v)
            -- 获取玩家队伍
            local ret, teamId = Player:getTeam(v)
            savePlayerData(v, rankS[teamId])
        end
    end
    Player_UseItem = function(event)
        -- 玩家id
        local playerId = event.eventobjid
        -- 道具id
        local itemId = event.itemid
        -- print('玩家使用道具:', itemId)
        -- Chat:sendSystemMsg('玩家使用道具' .. itemId)
        -- 获取items的key
        local allItemsKey = {}
        for k, v in pairs(items) do table.insert(allItemsKey, k) end
        if (LInclude(itemId, allItemsKey)) then useItem(playerId, itemId) end

    end
    Player_AddItem = function(event)
        -- 玩家id
        local playerId = event.eventobjid
        -- 道具id
        local itemId = event.itemid
        -- print('增加道具itemId=', itemId)
        -- print('playersChoose[playerId].wareId=', playersChoose[playerId].wareId)
        -- Chat:sendSystemMsg('玩家新增道具' .. itemId)
        if (playersChoose[playerId].wareId == itemId) then
            -- print("flag")
            -- 删除脱下的装备
            Player:removeBackpackItem(playerId, itemId, 1)
            -- 新增装备对应的道具
            local equipId = getItemsKey(itemId)
            Player:gainItems(playerId, equipId, 1, 1)
            -- 清除当前玩家的选择
            playersChoose[playerId].wareId = 0
        end

    end
    -- 玩家加入队伍
    Player_JoinTeam = function(e)
        print('玩家加入队伍', e)
        Chat:sendSystemMsg('玩家加入队伍')
    end
    -- 任一玩家离开游戏
    Game_AnyPlayer_LeaveGame = function(e)
        local playerId = e.eventobjid
        print('有玩家离开游戏', playerId)
        -- 存储玩家信息
        -- savePlayerData(playerId, 0)
    end

    -- 调用监听事件
    ListenEvents_MiniDemo();

end)()
