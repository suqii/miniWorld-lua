return (function()

    -- 变量库名称
    local libname = "data"

    -- 本地玩家Id
    local Players = {}

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

        -- 默认给玩家的道具
        GainItems(playerId)
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

    -- LInclude方法
    function LInclude(id, table)
        local flag = false
        for i, v in ipairs(table) do if (v == id) then flag = true end end
        return flag
    end

    -------------------------------游戏事件-------------------------------

    Game_StartGame = function()
        Chat:sendSystemMsg("游戏开始")
        -- 初始化游戏规则
        if not Data.isRuleInit then InitGameRule() end

        -- 初始化玩家信息
        -- InitGamePlayer(isTestMode)

    end
    -- 玩家死亡
    Player_Dead = function(trigger_obj) end
    -- 玩家复活
    Player_Revive = function(event) end
    -- 方块被破坏
    Block_DestroyBy = function(event) end
    -- 玩家选择快捷栏
    Player_SelectShortcut = function(event) end
    -- 玩家进入区域
    Player_AreaIn = function(event) end
    -- 玩家离开区域
    Player_AreaOut = function(event) end
    -- 玩家穿上装备
    Player_EquipOn = function(event) end

    -- 玩家新增道具
    Player_AddItem = function(event) end
    -- 计时器变化
    minitimerChange = function(arg) end
    -- 玩家受到伤害
    Player_BeHurt = function(event) end
    -- 任一玩家进入游戏
    Game_AnyPlayer_EnterGame = function(event)
        -- 初始化玩家信息
        InitGamePlayer(event.eventobjid)
        -- 将玩家id添加到玩家列表
        playerPool[#playerPool + 1] = event.eventobjid

    end
    -- 投掷物命中
    Actor_Projectile_Hit = function(event) end
    -- 玩家脱下装备
    Player_EquipOff = function(e) end
    -- 游戏结束
    Game_GameOver = function(e) end
    -- 玩家移动一格
    Player_MoveOneBlockSize = function(event)
        print('玩家移动一格')
        Chat:sendSystemMsg('玩家移动一格')

    end
    -- 调用监听事件
    ListenEvents_MiniDemo();

end)()
