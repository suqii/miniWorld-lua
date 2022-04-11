local function ClickBlock(event)
    local vartype = 3 -- 变量组类型，3是数值
    local libname = "test" -- 组名
    local value = 10 -- 值
    local playerId = 123456 -- 私有变量组所属玩家id，0代表全局变量组
    local data = {featherNum = 0, skins = {1, 2, 3}, props = {23, 33, 0}}
    local ret = CloudSever:setDataListBykey("test", playerId, data)
    if ret == ErrorCode.OK then
        print('设置排行榜值成功 k = 123456 ,v = {}')
    else
        print('设置排行榜值失败')
    end

end
local getData = function(ret, k, v)

    if ret == true then
        print("v.featherNum = ", v.featherNum)
        print("v.skins = ", v.skins)
        print("v.props = ", v.props)
    else
        print('返回表数据失败')
        initGamer()
    end

end
local getUserData = function(libvarname, playerId)
    local userData = {featherNum = 0, skins = {}, props = {}}
    local function initGamer()
        CloudSever:setDataListBykey("test", tostring(playerId), userData)
    end
    local ret = CloudSever:getDataListByKey(libvarname, playerId,
                                            function(ret2, k, v, ix)

        -- if ret ~= 0 or ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
        if ret2 ~= true then -- 由于数据是云端的，所以要判断玩家是否初始化过，没有则初始化
            print('返回表数据失败')
            initGamer()
        else
            print("v.featherNum = ", v.featherNum)
            print("v.skins = ", v.skins)
            print("v.props = ", v.props)
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
    local playerId = 123456 -- 私有变量组所属玩家id，0代表全局变量组
    getUserData(libvarname, playerId)

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
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=],
                                 Game_AnyPlayer_EnterGame)
-- 玩家移动一格
ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=],
                                 Player_MoveOneBlockSize)
