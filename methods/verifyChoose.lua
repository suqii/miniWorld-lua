local playersChoose = {}

Player_SelectShortcut = function(event)

    -- print('玩家选择了一个快捷栏')
    -- Chat:sendSystemMsg('玩家选择了一个快捷栏')
    local itemid = event.itemid
    local playerId = event.eventobjid
    -- 获取玩家当前选中的快捷栏位置
    local result, scutIdx = Player:getCurShotcut(playerId)
    if (result == 0) then
        if (itemid == playersChoose[playerId].itemid and scutIdx ==
            playersChoose[playerId].scutIdx) then
            print('成功选择', itemid, "与", scutIdx)
            Chat:sendSystemMsg('成功选择' .. itemid .. "与" .. scutIdx)
        else
            playersChoose[playerId].itemid = itemid
            playersChoose[playerId].scutIdx = scutIdx
        end
    end

    print("playersChoose=", playersChoose)

end

-- 验证是否二次选择
function verifyChoose(playerId) local re = false end
-- 任一玩家进入游戏
Game_AnyPlayer_EnterGame = function(event)
    print('玩家进入游戏')
    Chat:sendSystemMsg("玩家进入游戏")
    -- 加入玩家选择组
    playersChoose[event.eventobjid] = {itemid = 0, scutIdx = 0}

end

-- 任一玩家进入游戏	
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=],
                                 Game_AnyPlayer_EnterGame)
-- 选择快捷栏
ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=],
                                 Player_SelectShortcut)
