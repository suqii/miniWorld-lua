--[[自定义延时回调
    
延时回调:
    local id= Time:delayCall(callBack,delay,target,nickName);
        callBack:回调方法 必须
        delay:等待时间 >=0
        target:执行函数的目标参数 可空
        nickName:事件回调的键 可空
        id:事件分配的id (当nickName不为nil 返回 nickName)
    
延时回调(?次)
    local id= Time:repeatCall(callBack,delay,timeSpace,repeatCount, target,nickName)
        timeSpace:执行时间间隔
        repeatCount:执行次数,小于等于0为无限次

获取事件
    local event=Time:get(id);

取消延时回调
    local r =Time:cancel(id)；
        id：事件id
        r：是否取消成功
]]--

local count=0;
local eventData=
{
    startTime=0,
    executeTime=0,
    callBack=nil,
    target=nil,
    maxCount=1,
    timeSpace=0,
    currentCount=0
}

function eventData:new(eventData)
    local e=eventData or {};
    setmetatable(e, self);
    self.__index=self;
    return e;
end

function eventData:update (currnetTime)
    if(currnetTime>=self.executeTime )then
        self.currentCount=self.currentCount+1;
        self.callBack(self.target);
        if(self.maxCount>0 and self.currentCount>=self.maxCount)then
            return true; 
        end
        self.executeTime=currnetTime+self.timeSpace;
    end  
    return false;
end

Time=
{
    id=0,
    eventPool={},
}
function Time:getCurrentMillisecond()
    return count*50;
end

function Time:getCurrentSecond()
    return math.floor( Time:getCurrentMillisecond()*0.001);
end

function Time:cancel(id)
    if(self.eventPool[id])then
        self.eventPool[id]=nil;
        return true;
    end
    return false;
end

function Time:get(id)
    if(not id)then
        return false;
    end
    return self.eventPool[id];
end

function Time:update()
    local currentTime=Time:getCurrentMillisecond();
    for key,value in pairs(self.eventPool) do
        if(value:update(currentTime))then
            self.eventPool[key]=nil;
        end
    end
end

function Time:delayCall(callBack,delay,target,nickName)
    if(not callBack)then
        return 0;
    end
    if(not delay or delay<=0)then
        callBack(target);
        return 0;
    end
    local id=self.id;
    
    if(nickName)then
        id=nickName; 
    else  
        id=id+1;
        self.id=id;     
    end
 
    local data=eventData:new();
    data.startTime=self:getCurrentMillisecond();
    data.callBack=callBack;
    data.executeTime=data.startTime+delay;
    data.target=target;
    self.eventPool[id]=data;
    return  id;
end

function Time:repeatCall(callBack,delay,timeSpace,repeatCount, target,nickName)
    if(not callBack)then
        return -1;
    end
    delay= delay or 0;
    delay= delay<=0 and 0 or delay;
    timeSpace=timeSpace or 0;
    timeSpace=timeSpace<=0 or timeSpace;
    repeatCount=repeatCount or 0;
    local id=self.id;
    if(nickName)then
        id=nickName; 
    else  
        id=id+1;
        self.id=id;     
    end
 
    local data=eventData:new();
    data.startTime=self:getCurrentMillisecond();
    data.callBack=callBack;
    data.target=target;
    data.executeTime=data.startTime+delay;
    data.maxCount=repeatCount;
    data.timeSpace=timeSpace;
    self.eventPool[id]=data;
    return  id;
end

--[[Time:repeatCall(function ()
    Chat:sendChat(0);
end,0,500,10);]]--

ScriptSupportEvent:registerEvent("Game.Run", function()
    count=count+1;
    Time:update();
end);
