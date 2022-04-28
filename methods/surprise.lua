return (function()
    -- -- 用法
    --  -- 彩蛋函数
    -- function smallJetBackpack(playerId)
    --     print("小型背包", playerId)
    --     Chat:sendSystemMsg('小型背包')
    -- end
    -- -- 彩蛋
    -- Suprise:check(function()
    --     Suprise:saveSupriseValue(playerId, smallJetBackpack)
    -- end)
    Suprise = {
        -- 清除键
        delKey = 6,
        -- 确认键
        confirmKey = 7,
        -- 彩蛋码
        surpriseCode = "9527",
        -- 彩蛋特效
        surpriseEffect = {particleId = 1566, scale = 1},
        -- 储存输入值
        inputValue = {},
        -- 彩蛋执行程序
        surpriseFunc = {}
    }
    -- 校验
    function Suprise:check(f)
        xpcall(f, function(err) Chat:sendSystemMsg(err) end)
    end
    -- 清除输入值
    function Suprise:clearSupriseValue(playerId)
        self.inputValue[playerId] = ""
    end
    -- 存储输入值
    function Suprise:saveSupriseValue(playerId, fun)
        -- 获取玩家当前选中的快捷栏位置
        local result, scutIdx = Player:getCurShotcut(playerId)
        scutIdx = scutIdx + 1
        if (self.delKey == scutIdx) then
            self:clearSupriseValue(playerId)
        elseif (self.confirmKey == scutIdx) then
            if (self.inputValue[playerId] == self.surpriseCode) then
                print("surprise!")
                Chat:sendSystemMsg("surprise!")
                -- 播放特效
                Actor:playBodyEffectById(playerId,
                                         self.surpriseEffect.particleId,
                                         self.surpriseEffect.scale)
                -- 执行彩蛋
                self.surpriseFunc[playerId](playerId)

            end
            -- 清除输入值
            self:clearSupriseValue(playerId)
        else
            -- 储存彩蛋码
            if (self.inputValue[playerId] == nil) then
                self.inputValue[playerId] = ""
                self.surpriseFunc[playerId] = fun
            end
            self.inputValue[playerId] = self.inputValue[playerId] .. scutIdx

        end
    end

end)()
