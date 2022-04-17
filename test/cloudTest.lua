local function ClickBlock(event)
  Chat:sendSystemMsg("玩家点击了一个方块")
    local vartype = 3 -- 变量组类型，3是数值
    local libname = "test" -- 组名
    local value = 10 -- 值
    local playerId = event.eventobjid
    local data = {
        skins = {1, 2, 3},
        props = { -- 羽毛
            feather = {id = 11303, num = 0},
            -- 无敌装甲
            armor = {id = 4225, num = 0},
            -- 喷射背包(大)
            bigJetBackpack = {id = 4226, num = 20}
        }
    }
    local ret = CloudSever:setDataListBykey("test", playerId, data)
    if ret == ErrorCode.OK then
        print('设置排行榜值成功 k = 123456 ,v = {}')
    else
        print('设置排行榜值失败')
    end

end

-- 获取table长度
function table_leng(t)
    local leng = 0
    for k, v in pairs(t) do leng = leng + 1 end
    return leng;
end

function getUserData(libvarname, playerId)
    local userData = {skins = {}, props = {}}
    local function initGamer()
        CloudSever:setDataListBykey("test", tostring(playerId), userData)
        -- 初始化玩家道具
        -- Player:gainItems(playerId, 4228, 1, 1)
    end
    local ret = CloudSever:getDataListByKey(libvarname, playerId,
                                            function(ret2, k, v, ix)

        -- if ret ~= 0 or ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
        if ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
            print('返回表数据失败')
            -- initGamer()
        else
          print("v=", v)
            print("v.skins = ", v.skins)
            print("v.props = ", v.props)
            -- 初始化玩家道具
           
            

        end
    end) -- 获取key1的分数

    if ret == ErrorCode.OK then
        print('请求test表数据成功')

    else
        print("请求test表数据失败")
    end
end

-- 玩家移动一格
Player_MoveOneBlockSize = function(event)
    local libvarname = 'test'
    local playerId = event.eventobjid
    getUserData(libvarname, playerId)
    Chat:sendSystemMsg("玩家移动一格")

end
-- 任一玩家进入游戏
Game_AnyPlayer_EnterGame = function(event)
    Chat:sendSystemMsg("玩家进入游戏")
    -- 初始化玩家信息
    local playerId = event.eventobjid
    local libvarname = 'test'
    getUserData(libvarname, playerId)
end

ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], ClickBlock) -- 点击方块
-- 游戏事件---
-- 任一玩家进入游戏	
-- ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=],
--                                  Game_AnyPlayer_EnterGame)
-- 玩家移动一格
ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=],
                                 Player_MoveOneBlockSize)
