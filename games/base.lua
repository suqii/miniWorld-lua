return (function()

    -- 变量库名称
    local libname = "data"
    -- 玩家池
    local playerPool = {}

    -- 装备
    local propsFlag = false -- 停用
    -- 是否初始化游戏道具
    local gainPropsFlag = false
    -- 是否开启皮肤
    local skinFlag = false

    -- 本地玩家Id
    local Players = {}

    -- 位置区域数据
    local Pos = { -- 初始数据
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
        skin1 = {name = "凛冬", skinId = 7, id = 4102}
        -- skin2 = {name = "胖哒", skinId = 8, id = 4103},

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
        }

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

        -- 初始化玩家皮肤
        Actor:changeCustomModel(playerId, skinCfg.iniSkin)

        -- 默认给玩家的道具
        GainItems(playerId)
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

    -- LInclude方法
    function LInclude(id, table)
        local flag = false
        for i, v in ipairs(table) do if (v == id) then flag = true end end
        return flag
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
        ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=],
                                         Game_AnyPlayer_LeaveGame)
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

    end
    -- 玩家进入区域
    Player_AreaIn = function(event) if (event.areaid == propAreaId) then end end
    -- 玩家离开区域
    Player_AreaOut =
        function(event) if (event.areaid == propAreaId) then end end
    -- 玩家穿上装备
    Player_EquipOn = function(event)
        local playerId = event.eventobjid
        local itemId = event.itemid

    end

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

    end
    -- 玩家脱下装备
    Player_EquipOff = function(e)

        local playerId = e.eventobjid
        local itemId = e.itemid
        print("脱了", itemId)

    end
    -- 游戏结束
    Game_GameOver = function(e)
        print("游戏结束")
        Data.isGameEnd = true

    end
    Player_UseItem = function(event)
        -- 玩家id
        local playerId = event.eventobjid
        -- 道具id
        local itemId = event.itemid
        print('玩家使用道具:', itemId)
        Chat:sendSystemMsg('玩家使用道具' .. itemId)

    end
    Player_AddItem = function(event)
        -- 玩家id
        local playerId = event.eventobjid
        -- 道具id
        local itemId = event.itemid
        -- print('增加道具itemId=', itemId)
        -- Chat:sendSystemMsg('玩家新增道具' .. itemId)

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

    end

    -- 调用监听事件
    ListenEvents_MiniDemo();

end)()
