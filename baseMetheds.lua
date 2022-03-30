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
    local Teams = {red = 1, blue = 2} -- 游戏队伍
    local Battle = {win = 1, lose = 2, draw = 3} -- 战斗结果
    local LiveType = {all = -1, dead = 0, alive = 1} -- 玩家状态

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

    -- 监听事件
    function ListenEvents_MiniDemo()
        -- 游戏事件---
        ScriptSupportEvent:registerEvent([=[Game.Start]=], Game_StartGame)
        -- 玩家死亡
        ScriptSupportEvent:registerEvent([=[Player.Die]=], Player_Dead)

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
