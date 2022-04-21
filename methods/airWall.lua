-- 位置区域数据
local Pos = {ix = -15, iy = 6, iz = 7}
-- local Pos = {ix = 0, iy = 0, iz = 0}
-- 地图常量数据
local Cfg = {
    lenth = 1, -- 长
    width = 5, -- 宽
    height = 2 -- 高
}
-- 正方向
function Init(pWid, pLen, pHei, p)
    local Pos = p or Pos
    pWid = pWid and pWid or Cfg.width
    pLen = pLen and pLen or Cfg.lenth
    pHei = pHei and pHei or Cfg.height

    local xwid, yhid, zwid = pWid, pHei, pLen
    -- 挖坑(正方向)
    for yPos = Pos.iy, Pos.iy - yhid + 1, -1 do
        for xPos = Pos.ix, Pos.ix + (xwid - 1) do
            for zPos = Pos.iz, Pos.iz + (zwid - 1) do
                -- print("(", xPos, ",", yPos, ",", zPos, ")")
                local re = Block:destroyBlock(xPos, yPos, zPos, false)
                print("re:", re)
                if re == 0 then
                    -- 放置方块
                    local re1 = Block:placeBlock(1, xPos, yPos, zPos, 3)
                    -- local re1 = Block:placeBlock(1081, xPos, yPos, zPos, 3)
                    print("re1:", re1)
                end

            end
        end
    end

end

-- Init(1,5,3) -- N的右边
-- Init(1,5,3) -- N的后边 
-- InitT(5,1,3) -- N的左边

-- N的右边延申(长：28，高：19)
local pos1 = {ix = -6, iy = 20, iz = -13}
Init(29, 1, 19, pos1) 

local pos2 = {ix = -6, iy = 20, iz = 19}
Init(29, 1, 19, pos2) 

-- N方向(长：26，高：19)
local pos3 = {ix = -7, iy = 20, iz = -13}
Init(1, 2, 19, pos3)
local pos3 = {ix = -7, iy = 20, iz = 1}
Init(1, 5, 19, pos3)
local pos3 = {ix = -7, iy = 20, iz = 18}
Init(1, 3, 19, pos3)
local pos3 = {ix = -7, iy = 12, iz = -11}
Init(1, 14, 13, pos3)
local pos3 = {ix = -7, iy = 12, iz = 6}
Init(1, 14, 13, pos3)


-- local pos4 = {ix = 23, iy = 12, iz = -13}
-- Init(1, 34, 19, pos4)
local pos3 = {ix = 23, iy = 20, iz = -13}
Init(1, 2, 19, pos3)
local pos3 = {ix = 23, iy = 20, iz = 1}
Init(1, 5, 19, pos3)
local pos3 = {ix = 23, iy = 20, iz = 18}
Init(1, 3, 19, pos3)
local pos3 = {ix = 23, iy = 12, iz = -11}
Init(1, 14, 13, pos3)
local pos3 = {ix = 23, iy = 12, iz = 6}
Init(1, 14, 13, pos3)
-- 顶部（N,N右,高）
local pos5 = {ix = -7, iy = 20, iz = -13}
Init(30, 32, 1, pos5)
