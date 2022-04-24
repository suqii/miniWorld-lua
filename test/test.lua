-- 玩家池
local playerPool = {}
-- 玩家信息
local playersInfo = {}

-- 赛场文字
local Graph = {
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

-- 初始化队伍位置
function initPlayerPos(playerId, teamId)
    if (teamId == 1) then
        local re1 = Actor:setPosition(playerId, Graph.redTeam.pos.x,
                                      Graph.redTeam.pos.y, Graph.redTeam.pos.z)
        print("初始红队位置结果：", re1)
    elseif (teamId == 2) then
        local re2 = Actor:setPosition(playerId, Graph.blueTeam.pos.x,
                                      Graph.blueTeam.pos.y, Graph.blueTeam.pos.z)
        print("初始蓝队位置结果：", re2)
    elseif (teamId == 3) then
        local re3 = Actor:setPosition(playerId, Graph.greenTeam.pos.x,
                                      Graph.greenTeam.pos.y,
                                      Graph.greenTeam.pos.z)
        print("初始绿色队位置结果：", re3)
    elseif (teamId == 4) then
        local re4 = Actor:setPosition(playerId, Graph.yellowTeam.pos.x,
                                      Graph.yellowTeam.pos.y,
                                      Graph.yellowTeam.pos.z)
        print("初始黄队位置结果：", re4)
    end

end

-- 加入队伍
ScriptSupportEvent:registerEvent([=[Player.JoinTeam]=], function(e)
    local playerId = e.eventobjid
    print("玩家加入队伍，玩家id为：", playerId)
    local ret, teamId = Player:getTeam(playerId)
    print("玩家队伍id为：", teamId)
end)
-- 进入游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], function(e)
    local playerId = e.eventobjid
    print("玩家进入游戏，玩家id为：", playerId)
    local ret, teamId = Player:getTeam(playerId)
    print("进入游戏时的队伍id为：", teamId)
    playerPool[#playerPool + 1] = playerId
    playersInfo[playerId] = {teamFlag = 0}
end)
-- 游戏update
ScriptSupportEvent:registerEvent([=[Game.Run]=], function(e)
    for i, v in ipairs(playerPool) do
        -- 获取玩家队伍
        local playerId = v
        local ret, teamId = Player:getTeam(playerId)
        -- print("玩家id为：", playerId, "的队伍id为：", teamId)
        if (teamId == 0) then
            print("玩家id为：", playerId, "的队伍未初始化")
            playersInfo[playerId].teamFlag = 1
        end
        if (playersInfo[playerId].teamFlag == 1 and teamId ~= 0) then
            print("玩家id为：", playerId, "的队伍id为：", teamId,
                  "初始化成功")
            initPlayerPos(playerId, teamId)
            playersInfo[v].teamFlag = 0
        end
    end
end)
-- 游戏结束
ScriptSupportEvent:registerEvent([=[Game.End]=], function(e)

    print("游戏结束")
    for i, v in ipairs(playerPool) do
        print(v)
        -- 获取玩家队伍
        local ret, teamId = Player:getTeam(v)
        print("玩家id为：", v, "的队伍id为：", teamId)
    end
end)
