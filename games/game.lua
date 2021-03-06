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
    -- 换装flag
    local changeSkin = true
    -- 是否开局增加道具
    local propsFlag = true
    -- 是否初始化游戏道具
    local gainPropsFlag = true
    -- 是否开启皮肤
    local skinFlag = false

    -- 本地玩家Id
    local Players = {}
    -- 玩家二次选择
    local playersChoose = {}
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
    -- Areas
    local Areas = {born_send1 = nil, born_send2 = nil}
    -- 出生传送点
    local born_send1 = {
        -- 替换的目标方块
        blockid = 8,
        -- 位置
        pos = {x = 29, y = 12, z = 7},
        -- 特效
        effect = {show = true, id = 1250, scale = 1},
        -- 文字板
        txt = {
            show = true,
            title = "#R 赛场传送点", -- 文字内容
            font = 16, -- 字体大小
            alpha = 0, -- 背景透明度(0:完全透明 100:不透明)
            itype = 1 -- 文字板编号
        }
    }
    local born_send2 = {
        -- 替换的目标方块
        blockid = 8,
        -- 位置
        pos = {x = -14, y = 12, z = 0},
        -- 特效
        effect = {show = true, id = 1250, scale = 1},
        -- 文字板
        txt = {
            show = true,
            title = "#R 赛场传送点", -- 文字内容
            font = 16, -- 字体大小
            alpha = 0, -- 背景透明度(0:完全透明 100:不透明)
            itype = 8 -- 文字板编号
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
        -- skin11 = {name = "叮叮当", skinId = 17, id = 4112},
        -- skin12 = {name = "羽姬", skinId = 18, id = 4113},
        skin13 = {name = "荒原猎人雪诺", skinId = 19, id = 4114},
        -- skin14 = {name = "秋果", skinId = 125, id = 4220},
        skin15 = {name = "凌美琪", skinId = 126, id = 4221},
        skin16 = {name = "游乐王子", skinId = 127, id = 4222},
        skin17 = {name = "殷小敏", skinId = 128, id = 4223},
        skin18 = {name = "施巧灵", skinId = 129, id = 4224}

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
        superShield = {name = '超级遁甲', particleId = 1231, scale = 1}
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
        --     itemId = 4249,
        --     itemCnt = 60,
        --     prioritytype = 1
        -- },
        -- feather = {
        --     name = '羽毛',
        --     itemId = 4249,
        --     itemCnt = 60,
        --     prioritytype = 1
        -- },
        -- -- 基础枕头
        -- basePillow = {
        --     name = '枕头',
        --     itemId = 4228,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 中型枕头
        -- midPillow = {
        --     name = '中型枕头',
        --     itemId = 4229,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- -- 哈士奇狗头枕头
        -- haskiPillow = {
        --     name = '哈士奇狗头枕头',
        --     itemId = 4230,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 大枕头炸弹
        -- bigBomb = {
        --     name = '大枕头炸弹',
        --     itemId = 4231,
        --     itemCnt = 30,
        --     prioritytype = 1
        -- },

        -- -- 小枕头炸弹
        -- smallBomb = {
        --     name = '小枕头炸弹',
        --     itemId = 4232,
        --     itemCnt = 30,
        --     prioritytype = 1
        -- },
        -- -- -- 小熊枕头
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
        -- flowerPillow = {
        --     name = '小花枕头',
        --     itemId = 4240,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- 饼干枕头
        -- cookiesPillow = {
        --     name = '饼干枕头',
        --     itemId = 4241,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- -- -- 玲娜贝儿抱枕
        -- linaBellPillow = {
        --     name = '玲娜贝儿抱枕',
        --     itemId = 4242,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        -- 计时器
        -- crocodilePillow = {
        --     name = '计时器',
        --     itemId = 4243,
        --     itemCnt = 20,
        --     prioritytype = 1
        -- },
        -- 库洛米抱枕q
        -- kuromiPillow = {
        --     name = '库洛米抱枕',
        --     itemId = 4245,
        --     itemCnt = 1,
        --     prioritytype = 1
        -- },
        kuromiPillow = {
            name = '库洛米抱枕',
            itemId = 4250,
            itemCnt = 1,
            prioritytype = 1
        }

    }

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
    -- 得到一个真实的随机数
    function GetTrueRandom(min, max)
        -- 得到时间字符串
        local strTime = tostring(os.time())
        -- 得到一个反转字符串
        local strRev = string.reverse(strTime)
        -- 得到前6位
        local strRandomTime = string.sub(strRev, 1, 6)

        -- 设置时间种子
        math.randomseed(strRandomTime)
        -- 输出随机数
        -- print("#随机数=",math.random(min, max))
        -- return math.random(min, max)
        -- 输出随机数
        -- print("min = ", min, ",max = ", max)
        if (min < 0 or max < 0) then
            min = -min
            max = -max
            -- print("min = ", min, ",max = ", max)
            return math.random(max, min)
        else
            return math.random(min, max)
        end
    end
    -- 随机重生点
    function GetRandomPoint()
        local x1 = GetTrueRandom(26, 29)
        local z1 = GetTrueRandom(1, 7)
        local x2 = GetTrueRandom(-14, -10)
        local z2 = GetTrueRandom(1, 7)
        local flag = GetTrueRandom(1, 2)
        -- print("flag",flag)
        if flag == 1 then
            return x1, z1
        else
            return -x2, z2
        end
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
        Actor:setActionAttrState(playerId, 16, false)

        -- 玩家移动方式
        -- Player:changPlayerMoveType(playerId, 1)
        -- 加入玩家id组
        -- Players[#Players + 1] = playerId
        -- 初始化玩家皮肤
        Actor:changeCustomModel(playerId, iniSkin)
        --  -- 初始化玩家重生点
        -- local x, z = GetRandomPoint()
        -- print("x", x)
        -- print("z", z)
        -- local result,x,y,z=Actor:getPosition(playerId)
        -- print("adsasas")
        -- local re = Player:setRevivePoint(playerId, x, 13, z)
        local re = Player:setRevivePoint(playerId, 26, 13, 7)
        print("初始化玩家重生点结果:", re)

        -- 默认给玩家的道具
        GainItems(playerId)
    end
    -- 清除玩家所有的计时器
    function ClearAllTimer(playerId)
        -- 清除玩家的所有计时器
        -- Timer:clearAllTimer(playerId)
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
            -- print('add score', playScore)
            -- Chat:sendSystemMsg('add score' .. playScore)
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
            -- Chat:sendSystemMsg("手中的物品被添加了击退1的附魔")
        elseif (pName == '玲娜贝儿抱枕' or pName == '库洛米抱枕' or
            pName == '鳄鱼枕头') then
            -- 击退附魔（11为附魔id,1-5个等级）
            Actor:addEnchant(eventobjid, 5, 11, 2)
            -- 在聊天框显示
            -- Chat:sendSystemMsg("手中的物品被添加了击退2的附魔")
        end

    end
    -- 赛场传送门
    function portalArea(data)
        local blockid = data.blockid or 1
        local x = data.pos.x or 0
        local y = data.pos.y or 0
        local z = data.pos.z or 0
        local particleId = data.effect.id or 0
        local scale = data.effect.scale or 1
        local effect_show = data.effect.show or false
        local txt_show = data.txt.show or false
        local txt_title = data.txt.title or "传送点"
        local txt_font = data.txt.font or 16
        local txt_alpha = data.txt.alpha or 0
        local txt_itype = data.txt.itype or 1
        -- 生成方块
        Block:placeBlock(blockid, x, y, z)

        if effect_show then
            -- 在此位置播放特效
            World:playParticalEffect(x, y, z, particleId, scale)
        end
        if txt_show then
            -- 创建文字板
            local graphicsInfo = Graphics:makeGraphicsText(txt_title, txt_font,
                                                           txt_alpha, txt_itype)
            local re = Graphics:createGraphicsTxtByPos(x, y + 3, z,
                                                       graphicsInfo, 0, 0)
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
    -- 传送玩家到对应队伍的战斗点
    function teleportToBattlePoint(playerId)
        -- 获取玩家队伍
        local ret, teamId = Player:getTeam(playerId)
        print('玩家队伍', teamId)
        -- 红队
        if (teamId == 1) then
            -- local x = GetTrueRandom(7, 9)
            -- local y = GetTrueRandom(13, 14)
            -- Player:setPosition(playerId, x, 7, y)
            Player:setPosition(playerId, 8, 7, 14)
            -- Actor:setPosition(playerId, 8, 7, 14)
                    -- 设置生物朝向
            local re = Actor:setFaceYaw(playerId,0)
--             print("生物朝向设置结果：",re)
--             local result,yaw=Actor:getFaceYaw(playerId)
-- --在聊天框显示
-- Chat:sendSystemMsg("房主的朝向偏转角度为"..yaw)
-- print("房主的朝向偏转角度为",yaw)
        elseif (teamId == 2) then
            -- local x = GetTrueRandom(-2, -3)
            -- local y = GetTrueRandom(2, 4)
            -- Player:setPosition(playerId, x, 7, y)
            Player:setPosition(playerId, -3, 7, 3)
            -- Actor:setPosition(playerId, -3, 7, 3)
        elseif (teamId == 3) then
            -- local x = GetTrueRandom(7, 9)
            -- local y = GetTrueRandom(-7, -8)
            -- Player:setPosition(playerId, x, 7, y)
            Player:setPosition(playerId, 8, 7, -8)
            -- Actor:setPosition(playerId, 8, 7, -8)
        elseif (teamId == 4) then
            -- local x = GetTrueRandom(18, 19)
            -- local y = GetTrueRandom(2, 4)
            -- Player:setPosition(playerId, x, 7, y)
            Player:setPosition(playerId, 19, 7, 3)
            -- Actor:setPosition(playerId, 19, 7, 3)
        end
    end

    -------------------------------游戏事件-------------------------------

    Game_StartGame = function()
        Chat:sendSystemMsg("游戏开始")

        -- 初始化游戏规则
        if not Data.isRuleInit then InitGameRule() end
        -- 初始化生成道具区域
        -- 通过起点终点坐标创建区域
        local result, areaid = Area:createAreaRectByRange({x = 9, y = 6, z = 2},
                                                          {x = 7, y = 8, z = 4})
        propAreaId = areaid
        -- 在此位置播放特效
        World:playParticalEffect(8, 6, 3, propParticleId, 3)

        -- 初始战斗区
        local result, areaid = Area:createAreaRectByRange({
            x = -7,
            y = 0,
            z = 16
        }, {x = 22, y = 15, z = -9})
        playAreaId = areaid

        -- 创建一个文字板
        local title = " 道具区" -- 文字内容
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
        if (sendDoor == false) then
            -- 初始化传送门
            portalArea(born_send1)
            portalArea(born_send2)
            -- 初始化传送门区域
            local result, areaid = Area:createAreaRectByRange({
                x = born_send1.pos.x,
                y = born_send1.pos.y,
                z = born_send1.pos.z
            }, {
                x = born_send1.pos.x,
                y = born_send1.pos.y + 2,
                z = born_send1.pos.z
            })
            Areas.born_send1 = areaid
            local result, areaid = Area:createAreaRectByRange({
                x = born_send2.pos.x,
                y = born_send2.pos.y,
                z = born_send2.pos.z
            }, {
                x = born_send2.pos.x,
                y = born_send2.pos.y + 2,
                z = born_send2.pos.z
            })
            Areas.born_send2 = areaid
            sendDoor = true
        end

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
        -- Chat:sendSystemMsg('玩家复活')
        Actor:setActionAttrState(event.eventobjid, 16, false)
        Actor:setActionAttrState(event.eventobjid, 2, false)
        Actor:setActionAttrState(event.eventobjid, 4, false)
        Actor:setActionAttrState(event.eventobjid, 32, false)

    end
    -- 方块被破坏
    Block_DestroyBy = function(event)
        Block:placeBlock(event.blockid, event.x, event.y, event.z, 0)
    end
    -- 玩家选择快捷栏
    Player_SelectShortcut = function(event)
        -- print(event)
        -- Chat:sendSystemMsg('选择快捷栏')
        print('是否处于战斗区：', playAreaFlag)

        local itemid = event.itemid
        local playerId = event.eventobjid
        -- 如果是生物蛋关闭交互
        if (playAreaFlag == false or LInclude(event.itemid, getAllSkinId())) then
            Actor:setActionAttrState(event.eventobjid, 16, false)
            Actor:setActionAttrState(event.eventobjid, 2, false)
            Actor:setActionAttrState(event.eventobjid, 4, false)
            Actor:setActionAttrState(event.eventobjid, 32, false)
        else
            Actor:setActionAttrState(event.eventobjid, 16, true)
            Actor:setActionAttrState(event.eventobjid, 2, true)
            Actor:setActionAttrState(event.eventobjid, 4, true)
            Actor:setActionAttrState(event.eventobjid, 32, true)
        end
        -- 获取玩家当前选中的快捷栏位置
        local result, scutIdx = Player:getCurShotcut(playerId)
        if (result == 0) then
            if (itemid == playersChoose[playerId].itemid and scutIdx ==
                playersChoose[playerId].scutIdx) then
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
                    -- 如果是战斗区
                    if (playAreaFlag == true) then
                        -- 将玩家现装备的装备脱下
                        local re = Backpack:actEquipOffByEquipID(
                                       event.eventobjid, 4)
                        print("脱下装备返回状态", re)
                        Backpack:actEquipUpByResID(event.eventobjid,
                                                   event.itemid)
                    end

                    -- elseif (event.itemid == skin["skin11"].id) then
                elseif (LInclude(event.itemid, getAllSkinId()) and changeSkin) then
                    print("开始切换皮肤")
                    local result12, name =
                        Actor:getActorFacade(event.eventobjid)
                    -- print("切换皮肤结果：",result12)
                    print("name=", name)
                    if (name == "mob_" .. getSkinId(event.itemid)) then
                        -- local test = Actor:recoverinitialModel(event.eventobjid)
                        local test = Actor:changeCustomModel(event.eventobjid,
                                                             iniSkin)
                        print("恢复外观=", test)
                    else
                        Actor:changeCustomModel(event.eventobjid, "mob_" ..
                                                    getSkinId(event.itemid))
                    end

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
        -- print('玩家进入区域', event)
        -- Chat:sendSystemMsg("发生事件：玩家进入区域")

        if (event.areaid == propAreaId) then

            function featherTimer(playerId)
                -- 生成羽毛
                local result, objid = World:spawnItem(8, 7, 3, 4249, 1)
                -- 删除文字板
                local re = Graphics:removeGraphicsByPos(8, 9, 3, 1, 1)
                -- 玩家加分
                PlayerAddScore(playerId, 1)

                -- 再开启一个计时器`

                print("再开启一个羽毛计时器")
                print("playerId=", playerId)
                local re = Timer:setTimer(playerId, "featherTimer", 1, false,
                                          "", playerId, featherTimer, playerId)
                print("设置计时器结果：", re)
            end
            -- 设置计时器
            local re = Timer:setTimer(event.eventobjid, "featherTimer", 1,
                                      false, "", event.eventobjid, featherTimer,
                                      event.eventobjid)
        elseif (event.areaid == playAreaId) then
            print("进入战斗区")
            -- Chat:sendSystemMsg("进入战斗区")
            -- 可使用道具
            Actor:setActionAttrState(event.eventobjid, 16, true)
            Actor:setActionAttrState(event.eventobjid, 32, true)
            playAreaFlag = true
    
            -- changeSkin = false
        elseif (event.areaid == Areas.born_send1 or event.areaid ==
            Areas.born_send2) then
            -- print("进入战斗区传送门")
            -- Chat:sendSystemMsg("进入战斗区传送门")
            teleportToBattlePoint(event.eventobjid)

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
            Actor:setActionAttrState(event.eventobjid, 16, false)
            Actor:setActionAttrState(event.eventobjid, 32, false)

        end
    end
    -- 玩家穿上装备
    Player_EquipOn = function(event)

        -- 如果在准备区则脱下装备
        if (playAreaFlag == false) then
            -- 将玩家现装备的装备脱下
            local re = Backpack:actEquipOffByEquipID(event.eventobjid, 4)
        else
            local result, name = Item:getItemName(event.itemid)
            -- print('获得装备' .. name)
            -- Chat:sendSystemMsg('获得装备' .. name)

            -- 判断道具类型
            if (name == props["smallJetBackpack"].name) then
                -- print('获得飞行技能')
                -- Chat:sendSystemMsg('获得飞行技能')
                -- 播放特效
                playEffect(event.eventobjid,
                           effects["smallJetBackpack"].particleId,
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
                                          props["smallJetBackpack"].duration,
                                          true, props["smallJetBackpack"].desc,
                                          event.eventobjid, smallJetBackpack,
                                          event.eventobjid)

                Player:changPlayerMoveType(event.eventobjid, 1)
            elseif (name == props["midJetBackpack"].name) then
                -- print('获得飞行技能')
                -- Chat:sendSystemMsg('获得飞行技能')
                -- 播放特效
                playEffect(event.eventobjid,
                           effects["midJetBackpack"].particleId,
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
                                          props["midJetBackpack"].duration,
                                          true, props["midJetBackpack"].desc,
                                          event.eventobjid, midJetBackpack,
                                          event.eventobjid)
                Player:changPlayerMoveType(event.eventobjid, 1)
            elseif (name == props["bigJetBackpack"].name) then
                -- print('获得飞行技能')
                -- Chat:sendSystemMsg('获得飞行技能')
                -- 播放特效
                playEffect(event.eventobjid,
                           effects["bigJetBackpack"].particleId,
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
                                          props["bigJetBackpack"].duration,
                                          true, props["bigJetBackpack"].desc,
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
                local re = Timer:setTimer(event.eventobjid,
                                          props["shield15"].name,
                                          props["shield15"].duration, true,
                                          props["shield15"].desc,
                                          event.eventobjid, shield15,
                                          event.eventobjid)

                -- 增加披风附魔值
                Actor:addEnchant(event.eventobjid, 4, 23, 5)
            end
        end

    end

    -- 计时器改变
    minitimerChange = function(arg)

        local result, second = MiniTimer:getTimerTime(arg.timerid)

        -- 如果是羽毛计时器
        if (string.find(arg.timername, "featherTimer") ~= nil) then

            -- 创建一个文字板
            local title = "#cFF33CC 羽毛＋1，得分＋1"
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
        -- 加入玩家选择组
        playersChoose[event.eventobjid] = {itemid = 0, scutIdx = 0}

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

        if (playAreaFlag) then
            -- 清楚玩家叠加状态
            clearPlayerState(e.eventobjid)
            -- 清除所有特效
            initEffect(e.eventobjid)
        end
        -- 下降玩家位置
        local result, x, y, z = Actor:getPosition(e.eventobjid)
        local re1 = Actor:setPosition(e.eventobjid, x, 7, z)

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

    -- 调用监听事件
    ListenEvents_MiniDemo();

end)()
