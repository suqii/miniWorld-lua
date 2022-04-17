-- how to use
-- -- 创建计时器(玩家id,计时器名称,是否显示计时器,显示计时器的文字,显示计时器的对象)
-- local re = Timer:setTimer(event.eventobjid, "test", 10, true, "计时器：",
--                           event.eventobjid)
-- -- 暂停计时器(玩家id,计时器名称,是否显示计时器,显示计时器的文字,显示计时器的对象)
-- local re = Timer:pauseTimer(event.eventobjid, "test", true, "暂停计时器:",
--                             event.eventobjid)
-- -- 删除计时器(玩家id,计时器名称)
-- local re = Timer:delTimer(event.eventobjid, "test")
-- 计时器类
Timer = {
    timerPool = {} -- 计时器池 
}
-- 初始化一个计时器
function Timer:getTimer(playerId, timerName, fun,param)
    local playerid = playerId or ""
    local timername = timerName or "default"
    local fnc = fun or function() end
    local param = param or {}
    local timerid
    -- 查找是否有该计时器
    for k, v in pairs(self.timerPool) do
        if (v[1] == timername and v[2] == playerid) then
            timerid = -1
            break
        end
    end
    -- 没找到则创建一个计时器，并加入计时器池中
    if (not (timerid)) then
        local result
        result, timerid =
            MiniTimer:createTimer(playerid .. timername, nil, true)
        self.timerPool[timerid] = {timername, playerid, false, fnc,param}
    end
    return timerid
end
-- 获取计时器id
function Timer:getTimerId(playerId, timerName)
    local playerid = playerId or ""
    local timername = timerName or "default"
    local timerid
    -- 查找是否有该计时器
    for k, v in pairs(self.timerPool) do
        if (v[1] == timername and v[2] == playerid) then
            timerid = k
            break
        end
    end
    return timerid
end
-- 检测计时器是否暂停
function Timer:checkTimer(playerId, timerName)
    local playerid = playerId or ""
    local timername = timerName or "default"
    local timerid
    -- 查找是否有该计时器
    for k, v in pairs(self.timerPool) do
        if (v[1] == timername and v[2] == playerid) then
            timerid = k
            if v[3] then
                timerid = -1
            else
                timerid = k
            end
            break
        end
    end
    return timerid
end

-- 恢复计时器
function Timer:resumeTimer(playerId, timerName, showTimer, showTxt, showObj)
    local PlayerId = playerId or ""
    local TimerName = timerName or "default"
    local TimerId = self:getTimerId(PlayerId, TimerName)
    local result
    if (TimerId > -1) then
        MiniTimer:resumeTimer(TimerId)
        if (showTimer) then
            MiniTimer:showTimerTips({showObj}, TimerId, showTxt, true)
        else
            MiniTimer:showTimerTips({showObj}, TimerId, showTxt, false)
        end
        self.timerPool[TimerId][3] = false
        result = ErrorCode.OK
    else
        result = ErrorCode.FAILED
    end
    return result
end
-- 设置计时器
function Timer:setTimer(playerId, timerName, time, showTimer, showTxt, showObj,
                        fun,param)
    local PlayerId = playerId or ""
    local TimerName = timerName or "default"
    local TimerId = self:getTimer(PlayerId, TimerName, fun,param)
    local TimerId2 = self:checkTimer(PlayerId, TimerName)
    local result
    if (TimerId > -1) then
        local Time = time or 0
        local ShowTimer = showTimer or false
        local ShowTxt = showTxt or "计时器："
        local ShowObj = showObj or 0
        if (TimerId > 0) then
            -- MiniTimer:setTimer(timerid, time, callback)
            MiniTimer:startBackwardTimer(TimerId, Time)
        end
        -- 是否显示计时器
        if (ShowTimer) then
            MiniTimer:showTimerTips({ShowObj}, TimerId, ShowTxt, true)
        end
        result = ErrorCode.OK
    else
        -- 如果是暂停状态，则恢复计时器
        if (TimerId2 == -1) then
            self:resumeTimer(PlayerId, TimerName, true, showTxt, showObj)
            result = ErrorCode.OK
        else
            result = ErrorCode.FAILED
        end
    end
    return result
end

-- 暂停计时器
function Timer:pauseTimer(playerId, timerName, showTimer, showTxt, showObj)
    local PlayerId = playerId or ""
    local TimerName = timerName or "default"
    local TimerId = self:getTimerId(PlayerId, TimerName)
    local result
    if (TimerId > -1) then
        MiniTimer:pauseTimer(TimerId)
        if (showTimer) then
            MiniTimer:showTimerTips({showObj}, TimerId, showTxt, true)
        else
            MiniTimer:showTimerTips({showObj}, TimerId, showTxt, false)

        end
        self.timerPool[TimerId][3] = true
        result = ErrorCode.OK
    else
        result = ErrorCode.FAILED
    end
    return result
end

-- 删除计时器
function Timer:delTimer(playerId, timerName)
    local PlayerId = playerId or ""
    local TimerName = timerName or "default"
    local TimerId = self:getTimerId(PlayerId, TimerName)
    local result
    if (TimerId > -1) then
        MiniTimer:deleteTimer(TimerId)
        -- 清除计时器池中的计时器
        self.timerPool[TimerId] = nil
        result = ErrorCode.OK
    else
        result = ErrorCode.FAILED
    end
    return result
end
minitimerChange = function(arg)
    local result, second = MiniTimer:getTimerTime(arg.timerid)
    local timerInfo = Timer.timerPool[arg.timerid]
    if (second == 0) then
        MiniTimer:deleteTimer(arg.timerid)
        -- 清除计时器池中的计时器
        Timer.timerPool[arg.timerid] = nil
        -- 执行回调函数
        if timerInfo[4] then timerInfo[4](timerInfo[5]) end

        

    end
end
-- 任意计时器发生变化事件
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange)
