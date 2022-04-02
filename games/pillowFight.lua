return (function()

    -- 地图常量数据
    local Cfg = {
        map_size = 30, -- 地图大小
        map_high = 5, -- 城墙高度
        pool_width = 5, -- 水池竖宽
        pool_lenth = 15, -- 水池横长
        max_score = 35 -- 游戏分数
    }

    -- ItemID数据
    local Items = {
        waterId = 4, -- 水方块ID
        treatId = 8, -- 加血方块ID
        floorId = 104, -- 地板方块ID

        fishCnt = 4, -- 灯笼鱼
        fishIdx = 3600, -- 灯笼鱼ID
        starCnt = 12, -- 闪星数量
        starIdx = 997, -- 闪星方块
        rewardCnt = 15, -- 肘子数量
        rewardIdx = 12526, -- 大肘子ID

        redFlagId = 919, -- 红旗ID
        blueFlagId = 920, -- 蓝旗ID

        mobsCnt = 7, -- 怪物数量/ID组
        mobsIdx = {3132, 3132, 3407},

        -- 测试方块trigger事件 --
        trigger_tx = 11311, -- 动物肥料
        trigger_x1 = 256, -- 桃花树苗
        trigger_ty = 11055, -- 点火器
        trigger_y1 = 881, -- 喷花烟花
        trigger_y2 = 931 -- 蜡烛台
    }
    -- 系统相关数据
    local Sys = {
        chatType = 1 -- 公告类型 1:系统公告
    }

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

    -- 游戏怪物数据
    local Mobs = {
        objIds = {}, -- 怪物objId
        gensCnt = 0, -- 攻击手数量
        deadCnt = 0 -- 已死量数量
    }
    -- 玩家打败目标
    function Player_Attack(event)
        print('玩家开始攻击')
        Chat:sendSystemMsg('玩家开始攻击')
        -- Player:gainItems(0,1,10,1)
        print(event)
        Actor:playBodyEffect(0, 1027)
        -- Actor:playBodyEffect(0, 1024)
        -- Actor:playBodyEffect(event.eventobjid, 1024)
        Chat:sendSystemMsg("房主被添加了特效1024")
        -- print(event)
        -- Chat:sendSystemMsg(event)
    end
    -- 玩家移动一格
    function Player_MoveOneBlockSize(event)
        print('玩家移动一格')
        Chat:sendSystemMsg('玩家移动一格')

        -- Actor:playBodyEffect(0, 1027)
        -- -- Actor:playBodyEffect(0, 1024)
        -- print(event)
        -- print(event.toobjid)
        -- print(event.eventobjid)
        -- local re = Player:shakeCamera(event.eventobjid, 3, 500)
        -- print(re)
        -- print(ErrorCode.OK)
        -- print(ErrorCode)
        -- Chat:sendSystemMsg("房主被添加了抖动")
        -- -- print(event)
        -- -- Chat:sendSystemMsg(event)
    end
    -- 监听事件
    function ListenEvents_MiniDemo()
        -- 游戏事件---
        ScriptSupportEvent:registerEvent([=[Game.Start]=], Game_StartGame)
        -- 玩家死亡
        ScriptSupportEvent:registerEvent([=[Player.Die]=], Player_Dead)
        -- 方块被破坏
        ScriptSupportEvent:registerEvent([=[Block.DestroyBy]=], Block_DestroyBy)
        -- 玩家打败目标
        -- ScriptSupportEvent:registerEvent([=[Player.Attack]=], Player_Attack)
        -- 玩家移动一格
        ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=],
                                         Player_MoveOneBlockSize)

    end
    -- 方块被破坏
    function Block_DestroyBy(event)
        Chat:sendSystemMsg("发生事件：方块被破坏")
        print(event)
        print(event.eventobjid)
        PlayerAddScore(event.eventobjid, 1)
        Chat:sendSystemMsg("创建特效")
        Actor:playBodyEffect(event.eventobjid, 1203)

    end
    -- 初始玩家道具
    function GainItems(playerId)
        -- 给玩家一个枕头,优先快捷栏
        local itemId, itemCnt, prioritytype = 15500, 1, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
            local re = Creature:addModAttrib(playerId, 0, 100)
            print('附魔结果', re)
            Chat:sendSystemMsg('附魔结果' .. re)
        end
        -- 给玩家一个信纸
        local itemId, itemCnt, prioritytype = 11806, 1, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
        end

    end
    -- 初始化玩家信息
    function InitGamePlayer(isTestMode)
        -- 获取本地玩家信息
        local ret, playerId = Player:getMainPlayerUin()
        if ret == ErrorCode.OK then
            print('玩家id', playerId)
            Chat:sendSystemMsg('玩家id' .. playerId)
            -- 清空玩家的所有物品
            Backpack:clearAllPack(playerId)
            -- 可移动
            -- Player:setActionAttrState(playerId, 1, false)
            -- 可摆放方块
            Player:setActionAttrState(playerId, 2, false)
            -- 可操作方块
            Player:setActionAttrState(playerId, 4, false)
            -- 可破坏方块
            Player:setActionAttrState(playerId, 8, false)
            -- 可被攻击
            Player:setActionAttrState(playerId, 64, false)
            -- 加入玩家id组
            Players[#Players + 1] = playerId
        end
        -- 设置队伍
        if #Players == 1 then
            Player:setTeam(playerId, Teams.red)
            print('你是红队')
            Chat:sendSystemMsg('你是红队')
        elseif #Players == 2 then
            Player:setTeam(playerId, Teams.blue)
            print('你是蓝队')
            Chat:sendSystemMsg('你是蓝队')
        elseif #Players == 3 then
            Player:setTeam(playerId, Teams.yellow)
            print('你是黄队')
            Chat:sendSystemMsg('你是黄队')
        else
            Player:setTeam(playerId, Teams.green)
            print('你是绿队')
            Chat:sendSystemMsg('你是绿队')
        end
        -- 默认给玩家的道具
        GainItems(playerId)
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

    -------------------------------自定义方法-------------------------------
    -- 游戏规则
    function InitGameRule()
        Data.isRuleInit = true
        GameRule.EndTime = 9 -- 游戏时长
        GameRule.CurTime = 17.9 -- 当前时间
        GameRule.LifeNum = 3 -- 玩家生命
        GameRule.TeamNum = 2
        GameRule.MaxPlayers = 2
        GameRule.CameraDir = 1 -- 1:正视角
        GameRule.StartMode = 0 -- 0:房主开启
        GameRule.StartPlayers = 1
        -- GameRule.ScoreKillMob = 3 --击杀特定怪物+3分
        GameRule.ScoreKillPlayer = 5 -- 击杀玩家+5分
        GameRule.PlayerDieDrops = 1 -- 死亡掉落 1:true
        GameRule.DisplayScore = 1 -- 显示比分 1:true
    end
    -------------------------------游戏事件-------------------------------
    Game_StartGame = function()
        -- 初始化游戏规则
        if not Data.isRuleInit then InitGameRule() end
        -- 初始化玩家信息
        InitGamePlayer(isTestMode)

    end
    -- 玩家死亡
    Player_Dead = function(trigger_obj)
        print('player die')
        Chat:sendSystemMsg('player ' .. 'die')
        if (trigger_obj['toobjid']) then
            local killById = trigger_obj['toobjid']
            print("killer id:", killById)
            Chat:sendSystemMsg("killer id:" .. killById)
        else
            print("无toobjid")
        end
        if (trigger_obj['eventobjid']) then
            local playerId = trigger_obj['eventobjid']
            print("be killed id:", playerId)
            Chat:sendSystemMsg(playerId)
            Chat:sendSystemMsg("be killed id" .. playerId)
        else
            print("无eventobjid")
        end
    end

    -- 调用监听事件
    ListenEvents_MiniDemo();
    -- 外挂脚本---start
    local function Player_ClickActor(event)
        Creature:setHpRecover(event.toobjid, 100)
        Creature:setWalkSpeed(event.toobjid, 100)
        Creature:setJumpPower(event.toobjid, 100)
        -- 在聊天框显示
        Chat:sendSystemMsg("objid为" .. event.toobjid ..
                               "的生物的 当前生命值被设置为了100")
    end
    -- ScriptSupportEvent:registerEvent([=[Game.Run]=], Player_ClickActor)
    -- 外挂脚本---end

end)()
