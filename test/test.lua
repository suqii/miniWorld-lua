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
    -- 游戏道具数据
    local props = {
        jetBackpack = {
            name = '喷射背包',
            duration = 20,
            propId = 4226,
            desc = '喷射剩余时间'
        },
        armor = {
            name = '无敌装甲',
            duration = 5,
            propId = 4225,
            desc = '无法击飞剩余时间'
        }
    }
    local gainProps = {
      feather = {name = '羽毛', itemId = 11303, itemCnt = 60, prioritytype = 1},
      basePillow = {name = '枕头', itemId = 4228, itemCnt = 1, prioritytype = 1}
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
        local result = Actor:changeCustomModel(event.eventobjid, "mob_3402")
        -- local result = Creature:replaceActor(event.eventobjid, 3402, 1)

        print(result)
        Chat:sendSystemMsg(result)

        -- local result1 = Backpack:actDestructEquip(event.eventobjid, 4226)
        -- 移除第一组物品
        --   local result = Backpack:actDestructEquip(event.eventobjid, 5)
        -- Backpack:actDestructEquip(event.eventobjid, 4)

        --   print(result1)
        -- local result, x, y, z = Actor:getPosition(event.eventobjid)
        -- print(x, y, z)
        -- -- 在聊天框显示
        -- Chat:sendSystemMsg("objid为" .. event.eventobjid ..
        --                        "的生物的坐标为(" .. x .. "," .. y .. "," ..
        --                        z .. ")")
        -- Actor:addEnchant(event.eventobjid, 5, 11, 5)
        -- -- 在聊天框显示
        -- Chat:sendSystemMsg("objid为" .. event.eventobjid ..
        --                        "的生物手中的物品被添加了击退1的附魔")

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
    -- 玩家复活
    function Player_Revive(event)
        print('玩家复活')
        print(event)
        Chat:sendSystemMsg('玩家复活')
        print(event.eventobjid)
        -- local result = Actor:changeCustomModel(event.toobjid, "豹子")
        local result = Actor:changeCustomModel(event.toobjid, "喷射背包")
        -- local result = Creature:replaceActor(event.toobjid, 3402, 1)
        -- local result = Actor:changeCustomModel(event.toobjid, 3402)
        -- local result =Actor:changeCustomModel(event.eventobjid, 3402)
        print(result)
        Chat:sendSystemMsg(result)

    end
    local function Player_ClickActor(event)
        -- 判断生物是否成年，参数为生物在存档中的id
        local result = Creature:isAdult(event.toobjid)
        if result == 0 then -- 如果已成年
            -- 在聊天框显示
            Chat:sendSystemMsg("objid为" .. event.toobjid ..
                                   "的生物已成年")
        else -- 如果未成年
            -- 在聊天框显示
            Chat:sendSystemMsg("objid为" .. event.toobjid ..
                                   "的生物未成年")

        end
        -- 击退概率抵抗值, 0.2表示有20%概率不被击退
        -- Creature:addModAttrib(event.toobjid, 26, 1)
        -- 在聊天框显示
        -- Chat:sendSystemMsg("objid为" .. event.toobjid ..
        --                        "的生物的移动速度附魔等级被增加了1")
        Actor:playBodyEffect(event.toobjid, 1024)
        Actor:playBodyEffect(0, 1024)
    end
    -- 写个函数，随便命名，当玩家离开区域时会执行此函数
    local function Player_AreaOut(event)
        print('玩家离开区域', event)
        Chat:sendSystemMsg("发生事件：玩家离开区域")
        Chat:sendSystemMsg("参数eventobjid为:" .. event.eventobjid)
        Chat:sendSystemMsg("参数areaid为:" .. event.areaid)
    end
    local function Player_AreaIn(event)
        print('玩家进入区域', event)
        Chat:sendSystemMsg("发生事件：玩家进入区域")
        Chat:sendSystemMsg("参数eventobjid为:" .. event.eventobjid)
        Chat:sendSystemMsg("参数areaid为:" .. event.areaid)
    end
    -- 回旋镖效果
    local boomerang = {
        itemid = 4098, -- 回旋镖投掷物道具id，不同地图需要改变该值
        countdown = 6, -- 倒计时2秒
        missileids = {}, -- 代码创建的投掷物
        timerPool = {} -- 计时器池 { timerid = { isOver, missileInfo } }
    }
    -- 获得一个计时器id
    function boomerang:getTimer(timerName, playerId)
        local timerid
        -- 查找一个停止的计时器
        for k, v in pairs(self.timerPool) do
            if (v[1]) then
                v[1] = false -- 设置计时器开始工作标识isOver
                timerid = k
                break
            end
        end
        -- 没找到则创建一个计时器，并加入计时器池中s
        if (not (timerid)) then
            local result
            result, timerid = MiniTimer:createTimer(timerName, nil, true)
            self.timerPool[timerid] = {false, playerId}
        end
        return timerid
    end
    -- timerid, timername
    local minitimerChange = function(arg)
        print(arg)
        -- 计时器池中的计时器倒计时为0时，销毁关联的投掷物，并创建返回的投掷物
        local result, second = MiniTimer:getTimerTime(arg.timerid)
        if (second == 0) then -- 倒计时为0
            print('计时器结束')
            Chat:sendSystemMsg('计时器结束')

            local timerInfo = boomerang.timerPool[arg.timerid]
            if (timerInfo) then -- 是计时器池里面的计时器
                timerInfo[1] = true -- 设置计时器结束工作标识isOver
                local playerId = timerInfo[2]
                if (arg.timername == props["jetBackpack"].name) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    --  移动方式变为默认
                    Player:changPlayerMoveType(playerId, 0)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                elseif (arg.timername == props["armor"].name) then
                    -- 删除计时器
                    MiniTimer:deleteTimer(arg.timerid)
                    -- 销毁装备
                    local result = Backpack:actDestructEquip(playerId, 4)
                    print(result)
                    Creature:addModAttrib(playerId, 26, 0)
                end

            end
        end
    end
    -- 玩家穿上装备
    local function Player_EquipOn(event)
        local result, name = Item:getItemName(event.itemid)
        print('获得装备' .. name)
        Chat:sendSystemMsg('获得装备' .. name)
        -- 判断道具类型
        if (name == props["jetBackpack"].name) then
            print('获得飞行技能')
            Chat:sendSystemMsg('获得飞行技能')
            local timerid = boomerang:getTimer(props["jetBackpack"].name,
                                               event.eventobjid)
            MiniTimer:startBackwardTimer(timerid, props["jetBackpack"].duration)
            MiniTimer:showTimerTips({0}, timerid, props["jetBackpack"].desc,
                                    true)
            Player:changPlayerMoveType(event.eventobjid, 1)
        elseif (name == props["armor"].name) then
            print('获得无法击飞技能')
            Chat:sendSystemMsg('获得无法击飞技能')
            local timerid = boomerang:getTimer(props["armor"].name,
                                               event.eventobjid)
            MiniTimer:startBackwardTimer(timerid, props["armor"].duration)
            MiniTimer:showTimerTips({0}, timerid, props["armor"].desc, true)
            -- 击退概率抵抗值, 0.2表示有20%概率不被击退
            Creature:addModAttrib(event.eventobjid, 26, 1)
        end

    end

    -- 玩家新增道具
    local function Player_AddItem(event)

        -- local result3, itemid = Item:getItemId(event.itemid)
        -- -- print(itemid)
        local result, name = Item:getItemName(event.itemid)
        print('玩家新增道具', name)
        Chat:sendSystemMsg("发生事件：玩家新增道具" .. name)
        -- Prop_Add(name)
    end
    -- 玩家开始攻击
    local function Player_Attack(event)
        print('玩家开始攻击', event)
        Chat:sendSystemMsg("玩家开始攻击")
        Actor:addEnchant(event.eventobjid, 5, 11, 1)
        -- 在聊天框显示
        Chat:sendSystemMsg("objid为" .. event.eventobjid ..
                               "的生物手中的物品被添加了击退1的附魔")
    end
    -- 玩家道具附魔属性增加
    local function Prop_Add(eventobjid, pName)
        print('玩家获得装备', pName)
        
        -- 击退附魔
        if (pName == '中型枕头') then
          -- 击退附魔（11为附魔id,1-5个等级）
        Actor:addEnchant(eventobjid, 5, 11, 1)
        -- 在聊天框显示
        Chat:sendSystemMsg("手中的物品被添加了击退1的附魔")
        end

    end
    -- 玩家选择快捷栏
    local function Player_SelectShortcut(event)
        print('玩家选择快捷栏', event)
        Chat:sendSystemMsg("玩家选择快捷栏")
        local result3, itemid = Item:getItemId(event.itemid)
        -- print(itemid)
        local result, name = Item:getItemName(event.itemid)
        Prop_Add(event.eventobjid, name)
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
        -- 玩家打败目标
        -- ScriptSupportEvent:registerEvent([=[Player.Attack]=], Player_Attack)
        -- 玩家移动一格
        -- ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=],
        --                                  Player_MoveOneBlockSize)
        -- 玩家开始攻击
        -- ScriptSupportEvent:registerEvent([=[Player.Attack]=], Player_Attack)
        -- 玩家选择快捷栏
        ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=],
                                         Player_SelectShortcut)
        -- 注册监听器，玩家进入区域时执行Player_AreaIn函数
        -- 第一个参数是监听的事件，第二个参数Player_AreaIn即事件发生时执行的函数
        ScriptSupportEvent:registerEvent([=[Player.AreaIn]=], Player_AreaIn)
        -- 注册监听器，玩家离开区域时执行Player_AreaOut函数
        -- 第一个参数是监听的事件，第二个参数Player_AreaOut即事件发生时执行的函数
        ScriptSupportEvent:registerEvent([=[Player.AreaOut]=], Player_AreaOut)
        -- 注册监听器，点击生物时执行Player_ClickActor函数
        -- ScriptSupportEvent:registerEvent([=[Player.ClickActor]=],
        --                                  Player_ClickActor)
        --  玩家穿上装备
        ScriptSupportEvent:registerEvent([=[Player.EquipOn]=], Player_EquipOn)
        -- 玩家新增道具
        ScriptSupportEvent:registerEvent([=[Player.AddItem]=], Player_AddItem)
        -- 任意计时器发生变化事件
        ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化事件

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
      -- for i,v in pairs(gainProps) do
      --   -- print(i,v)
      --   print(gainProps[i].name)
      -- end
        -- 改变外观
        local result1 = Actor:getActorFacade(playerId)
        print(result)
        -- local result = Actor:changeCustomModel(playerId, '秋果')
        -- print(result)
        -- 给玩家羽毛,优先快捷栏
        local itemId, itemCnt, prioritytype = 11303, 60, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
        end
        -- 给玩家一个枕头,优先快捷栏
        local itemId, itemCnt, prioritytype = 4228, 1, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
            -- local re = Creature:addModAttrib(playerId, 0, 100)
            -- print('附魔结果', re)
            -- Chat:sendSystemMsg('附魔结果' .. re)
        end
        -- 给玩家一个信纸
        local itemId, itemCnt, prioritytype = 11806, 1, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
        end
        -- 给玩家一个喷射背包
        local itemId, itemCnt, prioritytype = props["jetBackpack"].propId, 1, 1 -- 物品的id, 物品的id, 1优先快捷栏/2优先背包栏
        -- 检测是否有空间
        local ret = Backpack:enoughSpaceForItem(playerId, itemId, itemCnt)
        if ret == ErrorCode.OK then
            Player:gainItems(playerId, itemId, itemCnt, prioritytype)
        end

    end
    -- 初始化玩家信息
    function InitGamePlayer(isTestMode)
        -- 在两点之间的范围内填充某方块
        -- 前两个参数为填充范围的起点和终点坐标组成的表
        -- 第三个参数1为要填充的方块id，1是地心基石
        -- 第四个参数0为方块朝向：0西 1东 2南 3北 4下 5上
        -- Area:fillBlockAreaRange({x = -332, y = 7, z = 197},
        --                         {x = 5, y = 9, z = 5}, 1, 0)
        -- -- 在聊天框显示
        -- Chat:sendSystemMsg(
        --     "从(0,0)高度7到(5,5)高度9的范围被填充了基岩")

        -- 获取本地玩家信息
        local ret, playerId = Player:getMainPlayerUin()
        if ret == ErrorCode.OK then
            print('玩家id', playerId)
            Chat:sendSystemMsg('玩家id' .. playerId)
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
            Player:setActionAttrState(playerId, 64, false)
            -- 玩家移动方式
            -- Player:changPlayerMoveType(playerId, 1)
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
        -- 初始化区域
        -- 通过中心点和扩展长度创建一个区域
        -- 第一个参数{x=0,y=10,z=0}为区域中心坐标组成的表
        -- 第二个参数{x=1,y=2,z=3}为区域各方向扩展的距离组成的表
        -- local result, areaid = Area:createAreaRect({x = -337, y = 180, z = 7},
        --                                            {x = 1, y = 2, z = 3})
        -- -- 在聊天框显示
        -- Chat:sendSystemMsg(
        --     "以(0,0)高度10为中心，左右各扩展1格，上下各扩展2格，前后各扩展3格，创建了一个区域，id为" ..
        --         areaid)
        -- 通过起点终点坐标创建区域
        -- 第一个参数为区域起点坐标组成的表，即面朝北时，区域的左、下、后方的顶点坐标
        -- 第二个参数为区域终点坐标组成的表，即面朝北时，区域的右、上、前方的顶点坐标
        local result, areaid = Area:createAreaRectByRange({
            x = -332,
            y = 7,
            z = 170
        }, {x = -345, y = 7, z = 175})
        -- 销毁指定区域，参数为区域id
        -- Area:destroyArea(areaid)
        Area:fillBlock(areaid, 112) -- 用112这个方块填充区域
        -- Chat:sendSystemMsg("创建区域，id为" .. areaid)
        -- print("创建区域，id为", areaid)

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
