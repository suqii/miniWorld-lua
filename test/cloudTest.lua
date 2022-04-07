local function ClickBlock(event)
    local vartype = 3 -- 变量组类型，3是数值
    local libname = "test" -- 组名
    local value = 10 -- 值
    local playerid = 0 -- 私有变量组所属玩家id，0代表全局变量组
    -- 添加value到vartype类型的变量组的最后一位
    Valuegroup:insertInGroupByName(vartype, libname, value, playerid)
    -- local libvarname = 'test'
    local ret = CloudSever:setOrderDataBykey("test", "key1", 1)
    if ret == ErrorCode.OK then
        print('设置排行榜值成功 k = key1 ,v = 1')
    else
        print('设置排行榜值失败')
    end
end
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], ClickBlock) -- 点击方块
