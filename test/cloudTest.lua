local function ClickBlock(event)
    local vartype = 3 -- 变量组类型，3是数值
    local libname = "test" -- 组名
    local value = 10 -- 值
    local playerId = 123456 -- 私有变量组所属玩家id，0代表全局变量组
    local data = {num = "10"}
    local ret = CloudSever:setDataListBykey("test", playerId, data)
    if ret == ErrorCode.OK then
        print('设置排行榜值成功 k = 123456 ,v = {}')
    else
        print('设置排行榜值失败')
    end

end
local callback = function(ret, k, v)
    print("ret=", ret)
    print("k=", k)
    print("v=", v)

    Chat:sendSystemMsg("ret=" .. ret)
    Chat:sendSystemMsg("k=" .. k)
    Chat:sendSystemMsg("v=" .. v)
    if ret == true then
        print('返回数据成功 键= ' .. k .. ' 值=' .. v)
    else
        print('返回数据失败')
    end
end

local function Game_StartGame(event)
    local libvarname = 'test'
    local playerId = 123456 -- 私有变量组所属玩家id，0代表全局变量组
    local ret = CloudSever:getDataListByKey(libvarname, playerId, callback) -- 获取key1的分数
    if ret == ErrorCode.OK then
        print('请求排行榜数据成功')
    else
        print("请求排行榜数据失败")
    end
end
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], ClickBlock) -- 点击方块
-- 游戏事件---
ScriptSupportEvent:registerEvent([=[Game.Start]=], Game_StartGame)
