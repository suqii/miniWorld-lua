return (function()

    -- 变量库名称
    local libname = "data"
    -- 玩家池
    local playerPool = {}
    -- 道具区域id
    local propAreaId = 0
    -- 准备区域id
    local playAreaId = 0
    -- 换装flag
    local changeSkin = true
    -- 是否开局增加道具
    local propsFlag = false
    -- 是否初始化游戏道具
    local gainPropsFlag = false
    -- 是否开启皮肤
    skinFlag = true

    -- 本地玩家Id
    local Players = {}
    -- 游戏队伍
    local Teams = {red = 1, blue = 2, yellow = 3, green = 4}
    -- 战斗结果
    local Battle = {win = 1, lose = 2, draw = 3}
    -- 玩家状态
    local LiveType = {all = -1, dead = 0, alive = 1}

    -- 位置区域数据
    local Pos = { -- 初始数据
        ix = 0,
        iy = 0,
        iz = 0, -- 默认出生点
        cx = 0,
        cz = 0,
        cr = 0 -- 雾圈原点/半径
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
        isRuleInit = false -- 游戏是否初始化
    }

    -- 玩家初始皮肤
    local iniSkin = "mob_8"
    
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
        skin13 = {name = "荒原猎人雪诺", skinId = 19, id = 4114},
        -- skin14 = {name = "秋果", skinId = 125, id = 4220},
        -- skin15 = {name = "凌美琪", skinId = 126, id = 4221},
        -- skin16 = {name = "游乐王子", skinId = 127, id = 4222},
        -- skin17 = {name = "殷小敏", skinId = 128, id = 4223},
        -- skin18 = {name = "施巧灵", skinId = 129, id = 4224}

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
        shield15 = {name = '15秒防护盾', particleId = 1028, scale = 1},
        armor = {name = '无敌装甲', particleId = 1185, scale = 1},
        superShield = {name = '超级遁甲', particleId = 1278, scale = 2}
    }
    -- 装备标识
    local isWare = false
    
    -- 游戏道具数据
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
        --     itemId = 11303,
        --     itemCnt = 60,
        --     prioritytype = 1
        -- },
        -- 基础枕头
        basePillow = {
            name = '枕头',
            itemId = 4228,
            itemCnt = 1,
            prioritytype = 1
        },
        -- -- 哈士奇狗头枕头
        -- haskiPillow = {
        --     name = '哈士奇狗头枕头',
        --     itemId = 4230,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- 大枕头炸弹
        -- bigBomb = {
        --     name = '大枕头炸弹',
        --     itemId = 4231,
        --     itemCnt = 10,
        --     prioritytype = 1
        -- },

        -- 小枕头炸弹
        smallBomb = {
            name = '小枕头炸弹',
            itemId = 4232,
            itemCnt = 30,
            prioritytype = 1
        },
        -- -- 小熊枕头
        -- bearPillow = {
        --     name = '小熊枕头',
        --     itemId = 4233,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 小熊枕头
        -- bearPillow = {
        --     name = '小熊枕头',
        --     itemId = 4233,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 鸡腿枕头
        -- chickenPillow = {
        --     name = '鸡腿枕头',
        --     itemId = 4234,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 葱鸭枕头
        -- duckPillow = {
        --     name = '葱鸭枕头',
        --     itemId = 4235,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 葱鸭枕头
        -- rabbitPillow = {
        --     name = '小兔子枕头',
        --     itemId = 4236,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 咸鱼枕头
        -- fishPillow = {
        --     name = '咸鱼枕头',
        --     itemId = 4237,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 书包枕头
        -- bagPillow = {
        --     name = '书包枕头',
        --     itemId = 4238,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 鳄鱼枕头
        -- crocodilePillow = {
        --     name = '鳄鱼枕头',
        --     itemId = 4239,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 小花枕头
        -- crocodilePillow = {
        --     name = '小花枕头',
        --     itemId = 4240,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 饼干枕头
        -- crocodilePillow = {
        --     name = '饼干枕头',
        --     itemId = 4241,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
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
        }

    }

    -- 计时器池
    local boomerang = {
        itemid = 4098, -- 回旋镖投掷物道具id，不同地图需要改变该值
        countdown = 6, -- 倒计时2秒
        missileids = {}, -- 代码创建的投掷物
        timerPool = {} -- 计时器池 { timerid = { isOver, missileInfo } }
    }
    -- 获得一个计时器id
    function boomerang:getTimer(timerName, playerId)
        print("开始检测是否有重复")
        -- print(timerName)
        timername = timerName or 'default'
        local timerid
        -- 查找一个停止的计时器
        for k, v in pairs(self.timerPool) do
            print("v1", v[1])
            print("v2", v[2])
            if (v[2] == timername) then
                v[1] = true -- 设置计时器开始工作标识isOver

                print("当前时间池", self.timerPool)
                print("计时器重复", k)

                timerid = -1
                -- 恢复计时器
                -- MiniTimer:resumeTimer(k)
                break
            end
        end
        -- 没找到则创建一个计时器，并加入计时器池中
        if (not (timerid)) then
            local result
            result, timerid = MiniTimer:createTimer(timername, nil, true)
            self.timerPool[timerid] = {false, timername, playerId}
        end
        print("return的计时器id", timerid)
        return timerid
    end
    function boomerang:getTimer2(timerName, playerId)
        -- print("开始检测是否有重复")
        -- print(timerName)
        timername = timerName or 'default'
        local timerid
        -- 查找一个停止的计时器
        for k, v in pairs(self.timerPool) do
            -- print("v1", v[1])
            -- print("v2", v[2])
            if (v[2] == timername) then
                v[1] = true -- 设置计时器开始工作标识isOver

                -- print("当前时间池", self.timerPool)
                -- print("计时器重复", k)
                timerid = k
                -- 恢复计时器
                -- MiniTimer:resumeTimer(k)
                break
            end
        end

        return timerid
    end

    -- 监听事件
    function ListenEvents_MiniDemo()
        -- 游戏事件---
        ScriptSupportEvent:registerEvent([=[Game.Start]=], Game_StartGame)
        -- 玩家死亡
        ScriptSupportEvent:registerEvent([=[Player.Die]=], Player_Dead)
        -- 玩家复活
        -- ScriptSupportEvent:registerEvent([=[Player.Revive]=], Player_Revive)
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
        -- 玩家新增道具
        ScriptSupportEvent:registerEvent([=[Player.AddItem]=], Player_AddItem)
        -- 任意计时器发生变化事件
        ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange)
        -- 玩家受到伤害
        ScriptSupportEvent:registerEvent([=[Player.BeHurt]=], Player_BeHurt)
        -- 任一玩家进入游戏	
        ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=],
                                         Game_AnyPlayer_EnterGame)
        -- 投掷物命中
        -- ScriptSupportEvent:registerEvent([=[Actor.Projectile.Hit]=],
        --                                  Actor_Projectile_Hit)
        -- 玩家脱下装备
        ScriptSupportEvent:registerEvent([=[Player.EquipOff]=], Player_EquipOff)
        -- 游戏结束
        ScriptSupportEvent:registerEvent([=[Game.End]=], Game_GameOver)
        -- 玩家移动一格
        -- ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=],
        --                                  Player_MoveOneBlockSize)

    end

    -------------------------------自定义方法-------------------------------
    -- 获取玩家当前所有道具
    function getPlayerProps(playerId)
        -- 参数0为背包栏物品格id，0为储存栏的第一格：0-29储存栏 1000-1007快捷栏 8000-8004装备栏

        local baseProps = {
            -- 羽毛
            [11303] = {id = 11303, num = 0},
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
            -- 皮肤
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
            if (v.num > 0 or v.id == 11303) then
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
            if v.id == 11303 then v.num = v.num + addFeatherNum end
        end
        print("playerProps = ", playerProps)
        -- playerProps[11303].num = playerProps[11303].num + addFeatherNum
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
        -- GameRule.CurTime = 17.9 -- 当前时间
        GameRule.LifeNum = 9 -- 玩家生命
        -- GameRule.TeamNum = 2
        GameRule.MaxPlayers = 12
        GameRule.CameraDir = 1 -- 1:正视角
        GameRule.StartMode = 0 -- 0:房主开启
        GameRule.StartPlayers = 2
        -- GameRule.ScoreKillMob = 3 --击杀特定怪物+3分
        GameRule.ScoreKillPlayer = 5 -- 击杀玩家+5分
        -- GameRule.PlayerDieDrops = 0 -- 死亡掉落 1:true
        GameRule.DisplayScore = 1 -- 显示比分 1:true
        GameRule.ViewMode = 1 -- 开启失败观战 0:不开启 1:开启
        GameRule.BlockDestroy = 0 -- 是否可摧毁方块 0:否 1:是
        GameRule.CountDown = 10
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
        getUserData(playerId)
    end
    -- 初始化玩家信息
    function InitGamePlayer(playerId)

        -- 清空玩家的所有物品
        Backpack:clearAllPack(playerId)
        -- 可移动
        -- Player:setActionAttrState(playerId, 1, false)
        Actor:setActionAttrState(3402, 1, false)
        -- 可摆放方块
        Player:setActionAttrState(playerId, 2, false)
        -- 可操作方块
        Player:setActionAttrState(playerId, 4, false)
        -- 可破坏方块
        Player:setActionAttrState(playerId, 8, false)
        -- 可被攻击
        Player:setActionAttrState(playerId, 64, true)
        -- 可丢弃道具
        -- Player:setActionAttrState(playerId, 2048, false)
        Player:setItemAttAction(playerId, 4226, 1, false)

        -- 玩家移动方式
        -- Player:changPlayerMoveType(playerId, 1)
        -- 加入玩家id组
        -- Players[#Players + 1] = playerId

        Actor:changeCustomModel(playerId, iniSkin)

        -- 默认给玩家的道具
        GainItems(playerId)
    end
    -- 清除玩家所有的计时器
    function ClearAllTimer(playerId)
        -- 清除玩家的所有计时器
        Timer:clearAllTimer(playerId)
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
        local result,x,y,z=Actor:getPosition(playerId)
        local re1 = Actor:setPosition(playerId,x,7,z)
        --  玩家可移动
        local re2 = Player:setActionAttrState(playerId, 1, true)
        --  移动方式变为默认
        local re3 = Player:changPlayerMoveType(playerId, 0)
        print("清除状态：", re1, re2, re3)

    end
    -- 给玩家播放特效
    function playEffect(playerId, particleId, scale)
        Scale = scale or 1
        Actor:playBodyEffectById(playerId, particleId, Scale)
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
            print('add score', playScore)
            Chat:sendSystemMsg('add score' .. playScore)
        end

        local ret, teamId = Player:getTeam(playerId)
        print("队伍Id:", teamId)
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
        print('玩家获得装备', pName)

        -- 击退附魔 “葱鸭”抱枕 咸鱼抱枕
        if (pName == '中型枕头' or pName == '“葱鸭”抱枕' or pName ==
            '咸鱼抱枕') then
            -- 击退附魔（11为附魔id,1-5个等级）
            Actor:addEnchant(eventobjid, 5, 11, 1)
            -- 在聊天框显示
            Chat:sendSystemMsg("手中的物品被添加了击退1的附魔")
        elseif (pName == '玲娜贝儿抱枕' or pName == '库洛米抱枕' or
            pName == '鳄鱼枕头') then
            -- 击退附魔（11为附魔id,1-5个等级）
            Actor:addEnchant(eventobjid, 5, 11, 2)
            -- 在聊天框显示
            Chat:sendSystemMsg("手中的物品被添加了击退2的附魔")
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

    -------------------------------游戏事件-------------------------------

    Game_StartGame = function()
        Chat:sendSystemMsg("游戏开始")
        -- 初始化游戏规则
        if not Data.isRuleInit then InitGameRule() end
        -- 初始化生成道具区域
        -- 通过起点终点坐标创建区域
        local result, areaid = Area:createAreaRectByRange({x = 8, y = 6, z = 3},
                                                          {x = 8, y = 8, z = 3})
        propAreaId = areaid

        -- 初始战斗区
        local result, areaid = Area:createAreaRectByRange({
            x = -7,
            y = 0,
            z = 16
        }, {x = 22, y = 15, z = -9})
        playAreaId = areaid

        -- 在此位置播放特效
        World:playParticalEffect(8, 7, 3, 1001, 1)
        -- 创建一个文字板
        local title = "#R 道具区" -- 文字内容
        local font = 16 -- 字体大小
        local alpha = 0 -- 背景透明度(0:完全透明 100:不透明)
        local itype = 1 -- 文字板编号
        -- 创建一个文字板信息，存到graphicsInfo中
        local graphicsInfo =
            Graphics:makeGraphicsText(title, font, alpha, itype)
        local re = Graphics:createGraphicsTxtByPos(8, 8, 3, graphicsInfo, 0, 0)
        print("文字信息：", re)
        -- 销毁指定区域，参数为区域id
        -- Area:destroyArea(areaid)
        -- Area:fillBlock(areaid, 112) -- 用112这个方块填充区域
        -- Chat:sendSystemMsg("创建区域，id为" .. areaid)
        -- print("创建区域，id为", areaid)

        -- 初始化玩家信息
        -- InitGamePlayer(isTestMode)

    end
    -- 玩家死亡
    Player_Dead = function(trigger_obj)
        print(trigger_obj)
        print('player die')
        -- Chat:sendSystemMsg('player ' .. 'die')
        -- 他杀
        if (trigger_obj['toobjid']) then
            local killById = trigger_obj['toobjid']
            -- print("killer id:", killById)
            -- Chat:sendSystemMsg("killer id:" .. killById)
            PlayerAddScore(killById, 5)
        else
            -- print("无toobjid")
        end
        -- 自杀
        if (trigger_obj['eventobjid']) then
            local playerId = trigger_obj['eventobjid']
            -- print("be killed id:", playerId)
            -- Chat:sendSystemMsg(playerId)
            -- Chat:sendSystemMsg("be killed id" .. playerId)

        else
            -- print("无eventobjid")
        end
        -- 清除所有特效
        initEffect(trigger_obj['eventobjid'])
        -- 清楚玩家叠加状态
        clearPlayerState(trigger_obj['eventobjid'])
    end
    -- 玩家复活
    Player_Revive = function(event)
        print('玩家复活')
        print(event)
        Chat:sendSystemMsg('玩家复活')

    end
    -- 方块被破坏
    Block_DestroyBy = function(event)
        Block:placeBlock(event.blockid, event.x, event.y, event.z, 0)
    end
    -- 玩家选择快捷栏
    Player_SelectShortcut = function(event)
        -- print(event)

        local result3, itemid = Item:getItemId(event.itemid)
        -- print(event.itemid)
        local result, name = Item:getItemName(event.itemid)
        -- 如果是装备
        -- jetBackpack  shield15  armor
        if (event.itemid == props["smallJetBackpack"].propId or event.itemid ==
            props["midJetBackpack"].propId or event.itemid ==
            props["bigJetBackpack"].propId or event.itemid ==
            props["shield15"].propId or event.itemid == props["armor"].propId or
            event.itemid == props["superShield"].propId) then
            -- 将玩家现装备的装备脱下
            local re = Backpack:actEquipOffByEquipID(event.eventobjid, 4)
            print("脱下装备返回状态", re)
            Backpack:actEquipUpByResID(event.eventobjid, event.itemid)
            -- elseif (event.itemid == skin["skin11"].id) then
        elseif (LInclude(event.itemid, getAllSkinId()) and changeSkin) then
            print("开始切换皮肤")
            local result12, name = Actor:getActorFacade(event.eventobjid)
            -- print("切换皮肤结果：",result12)
            print("name=", name)
            if (name == "mob_" .. getSkinId(event.itemid)) then
                -- local test = Actor:recoverinitialModel(event.eventobjid)
                local test = Actor:changeCustomModel(event.eventobjid, iniSkin)
                print("恢复外观=", test)
            else
                Actor:changeCustomModel(event.eventobjid,
                                        "mob_" .. getSkinId(event.itemid))
            end

        else
            Prop_Add(event.eventobjid, name)
        end
    end
    -- 玩家进入区域
    Player_AreaIn = function(event)
        -- print('玩家进入区域', event)
        -- Chat:sendSystemMsg("发生事件：玩家进入区域")
        -- 生成羽毛
        -- local result, objid = World:spawnItem(8, 7, 3, 11303, 5)
        if (event.areaid == propAreaId) then
            local timerid = boomerang:getTimer("featherTimer" ..
                                                   event.eventobjid,
                                               event.eventobjid)
            MiniTimer:startBackwardTimer(timerid, 4)
            MiniTimer:showTimerTips({0}, timerid,
                                    "4秒后即将产生羽毛：", true)
        elseif (event.areaid == playAreaId) then
            print("进入战斗区")
            -- Chat:sendSystemMsg("进入战斗区")
            changeSkin = false
        end

    end
    -- 玩家离开区域
    Player_AreaOut = function(event)

        -- print("离开的区域id", event.areaid)

        if (event.areaid == propAreaId) then
            -- print('玩家离开道具区域：', event)
            local id = boomerang:getTimer2("featherTimer" .. event.eventobjid,
                                           event.eventobjid)
            -- print("道具区域计时器id:", id)
            -- 删除计时器
            MiniTimer:deleteTimer(id)
            -- 将上一个道具区域计时器id移除
            boomerang.timerPool[id] = nil

        end

    end
    -- 玩家穿上装备
    Player_EquipOn = function(event)
        local result, name = Item:getItemName(event.itemid)
        -- print('获得装备' .. name)
        -- Chat:sendSystemMsg('获得装备' .. name)
        -- 判断道具类型
        if (name == props["smallJetBackpack"].name) then
            print('获得飞行技能')
            Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["smallJetBackpack"].particleId,
                       effects["smallJetBackpack"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["smallJetBackpack"].name ..
                                    event.eventobjid, event.eventobjid)

            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid,
                                             props["smallJetBackpack"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["smallJetBackpack"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["smallJetBackpack"].name ..
                                   event.eventobjid, event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["smallJetBackpack"].desc, true)
            end

            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["midJetBackpack"].name) then
            print('获得飞行技能')
            Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["midJetBackpack"].particleId,
                       effects["midJetBackpack"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["midJetBackpack"].name .. event.eventobjid,
                                event.eventobjid)

            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid,
                                             props["midJetBackpack"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["midJetBackpack"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["midJetBackpack"].name .. event.eventobjid,
                               event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["midJetBackpack"].desc, true)
            end
            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["bigJetBackpack"].name) then
            print('获得飞行技能')
            Chat:sendSystemMsg('获得飞行技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["bigJetBackpack"].particleId,
                       effects["bigJetBackpack"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["bigJetBackpack"].name .. event.eventobjid,
                                event.eventobjid)
            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid,
                                             props["bigJetBackpack"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["bigJetBackpack"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["bigJetBackpack"].name .. event.eventobjid,
                               event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["bigJetBackpack"].desc, true)
            end

            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["armor"].name) then
            print('获得无法击飞技能')
            Chat:sendSystemMsg('获得无法击飞技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["armor"].particleId,
                       effects["armor"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["armor"].name .. event.eventobjid,
                                event.eventobjid)

            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid, props["armor"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["armor"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["armor"].name .. event.eventobjid,
                               event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["armor"].desc, true)
            end
            -- 击退概率抵抗值, 0.2表示有20%概率不被击退
            -- Creature:addModAttrib(event.eventobjid, 26, 1)
            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
            Player:setActionAttrState(event.eventobjid, 1, false)
        elseif (name == props["superShield"].name) then
            print('获得超级遁甲技能')
            Chat:sendSystemMsg('获得超级遁甲技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["superShield"].particleId,
                       effects["superShield"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["superShield"].name .. event.eventobjid,
                                event.eventobjid)

            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid,
                                             props["superShield"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["superShield"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["superShield"].name .. event.eventobjid,
                               event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["superShield"].desc, true)
            end
            -- 击退概率抵抗值, 0.2表示有20%概率不被击退
            -- 击退概率抵抗值, 0.2表示有20%概率不被击退
            -- Creature:addModAttrib(event.eventobjid, 26, 1)
            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
        elseif (name == props["shield15"].name) then
            print('获得15s护盾技能1')
            Chat:sendSystemMsg('获得15s护盾技能')
            -- 播放特效
            playEffect(event.eventobjid, effects["shield15"].particleId,
                       effects["shield15"].scale)
            -- 设置计时器
            local timerid = boomerang:getTimer(
                                props["shield15"].name .. event.eventobjid,
                                event.eventobjid)
            print(timerid)

            if (timerid > -1) then
                MiniTimer:startBackwardTimer(timerid, props["shield15"].duration)
                MiniTimer:showTimerTips({event.eventobjid}, timerid,
                                        props["shield15"].desc, true)
            else
                print('重启此计时器')
                local id = boomerang:getTimer2(
                               props["shield15"].name .. event.eventobjid,
                               event.eventobjid)
                MiniTimer:resumeTimer(id)
                MiniTimer:showTimerTips({event.eventobjid}, id,
                                        props["shield15"].desc, true)
            end
            -- 击退概率抵抗值, 0.2表示有20%概率不被击退
            -- Creature:addModAttrib(event.eventobjid, 26, 1)
            -- 增加披风附魔值
            Actor:addEnchant(event.eventobjid, 4, 23, 5)
        end

    end

    -- 玩家新增道具
    Player_AddItem = function(event)

        local result, name = Item:getItemName(event.itemid)
        -- print('玩家新增道具', name)
        -- Chat:sendSystemMsg("发生事件：玩家新增道具" .. name)
        -- Prop_Add(name)
    end
    -- timerid, timername
    minitimerChange = function(arg)
        -- print(arg)
        -- 计时器池中的计时器倒计时为0时，销毁关联的投掷物，并创建返回的投掷物
        local result, second = MiniTimer:getTimerTime(arg.timerid)
        -- print('time:', second)
        -- Chat:sendSystemMsg('time:' .. second)
        if (second == 0) then -- 倒计时为0
            print('计时器结束')
            print(arg)
            -- Chat:sendSystemMsg('计时器结束')

            local timerInfo = boomerang.timerPool[arg.timerid]
            if (timerInfo) then -- 是计时器池里面的计时器
                print(timerInfo)
                -- print(timerInfo[3])
                timerInfo[1] = true -- 设置计时器结束工作标识isOver
                local playerId = timerInfo[3]
                if (arg.timername == props["smallJetBackpack"].name ..
                    timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    --  移动方式变为默认
                    Player:changPlayerMoveType(playerId, 0)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    -- 停止特效
                    stopEffect(playerId, effects["smallJetBackpack"].particleId)
                    print(result)
                    -- 喷射背包（中）
                elseif (arg.timername == props["midJetBackpack"].name ..
                    timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    --  移动方式变为默认
                    Player:changPlayerMoveType(playerId, 0)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    -- 停止特效
                    stopEffect(playerId, effects["midJetBackpack"].particleId)
                    -- 喷射背包（大）
                elseif (arg.timername == props["bigJetBackpack"].name ..
                    timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    --  移动方式变为默认
                    Player:changPlayerMoveType(playerId, 0)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    -- 停止特效
                    stopEffect(playerId, effects["bigJetBackpack"].particleId)

                    -- 无敌装甲
                elseif (arg.timername == props["armor"].name .. timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    -- Creature:addModAttrib(playerId, 26, 0)
                    --  玩家可移动
                    Player:setActionAttrState(playerId, 1, true)
                    -- 停止特效
                    stopEffect(playerId, effects["armor"].particleId)
                    -- 超级遁甲
                elseif (arg.timername == props["superShield"].name ..
                    timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    -- 玩家可被击退
                    -- Creature:addModAttrib(playerId, 26, 0)
                    -- 停止特效
                    stopEffect(playerId, effects["superShield"].particleId)

                elseif (arg.timername == props["shield15"].name .. timerInfo[3]) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    -- 玩家可被击退
                    -- Creature:addModAttrib(playerId, 26, 0)
                    -- 停止特效
                    stopEffect(playerId, effects["shield15"].particleId)
                elseif (arg.timername == "featherTimer" .. timerInfo[3]) then

                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    -- 生成羽毛
                    local result, objid = World:spawnItem(8, 7, 3, 11303, 5)

                end
                -- 将boomerang.timerPool[arg.timerid]移除
                boomerang.timerPool[arg.timerid] = nil
            end
        end
    end
    -- 玩家受到伤害
    Player_BeHurt = function(event)
        -- Chat:sendSystemMsg("玩家受伤开始加血")
        Actor:addHP(event.eventobjid, 100)

    end
    -- 任一玩家进入游戏
    Game_AnyPlayer_EnterGame = function(event)
        -- Chat:sendSystemMsg("玩家进入游戏")
        -- 初始化玩家信息
        InitGamePlayer(event.eventobjid)
        -- 将玩家id添加到玩家列表
        playerPool[#playerPool + 1] = event.eventobjid

    end
    -- 投掷物命中
    Actor_Projectile_Hit = function(event)
        print('投掷物命中', event)
        Chat:sendSystemMsg("投掷物命中")

    end
    -- 玩家脱下装备
    Player_EquipOff = function(e)
        print("脱下装备时的时间池：", boomerang.timerPool)
        local name = ""
        for k, v in pairs(props) do
            if v.propId == e.itemid then
                -- print(v.name)
                name = v.name
            end
        end
        local id = boomerang:getTimer2(name .. e.eventobjid, e.eventobjid)
        print("停止的id:", id)
        -- 停止计时器
        local re = MiniTimer:pauseTimer(id)
        -- 清除计时器显示
        MiniTimer:showTimerTips({e.eventobjid}, id, name, false)
        -- 清楚玩家叠加状态
        clearPlayerState(e.eventobjid)
        -- 清除所有特效
        initEffect(e.eventobjid)

        -- -- 销毁装备
        -- local result = Backpack:actDestructEquip(e.eventobjid, 4)
        -- print(result)

    end
    -- 游戏结束
    Game_GameOver = function(e)
        print("游戏结束")
        -- 获取排名加分
        local rankS = rankScore()
        for i, v in ipairs(playerPool) do
            print(v)
            -- 获取玩家队伍
            local ret, teamId = Player:getTeam(v)
            savePlayerData(v, rankS[teamId])
        end
    end
    -- 玩家移动一格
    Player_MoveOneBlockSize = function(event)
        print('玩家移动一格')
        Chat:sendSystemMsg('玩家移动一格')
        -- local result = Actor:changeCustomModel(event.eventobjid, "mob_129")
        -- -- -- local result = Creature:replaceActor(event.eventobjid, 3402, 1)

        -- print(result)
        -- Chat:sendSystemMsg(result)
        -- local ret, teamId = Player:getTeam(event.eventobjid)
        -- print("队伍Id:", teamId)
        -- -- 获取属于第一个队伍的生物列表，参数为队伍id
        -- local result, array = Team:getTeamCreatures(1)
        -- if #array == 0 then -- 如果没有生物
        --     -- 在聊天框显示
        --     Chat:sendSystemMsg("没有动物或怪物属于第一个队伍")
        -- else -- 如果有生物
        --     for i, a in ipairs(array) do
        --         -- 在聊天框显示生物列表
        --         print(i)
        --         print(a)
        --         Chat:sendSystemMsg("属于第一个队伍的生物id，" .. i ..
        --                                "：" .. a)
        --     end
        -- end
        -- 获取玩家拥有的道具列表，参数为玩家id
        -- local playerProps = getPlayerProps(event.eventobjid)
        -- print(playerProps)
        -- savePlayerData(event.eventobjid)
        -- 获取队伍的分数，参数为队伍id
        -- local result,score=Team:getTeamScore(1)
        --         for i, v in ipairs(playerPool) do
        --           print("玩家",i,"id",v)
        --       end

    end
    -- 调用监听事件
    ListenEvents_MiniDemo();

end)()
