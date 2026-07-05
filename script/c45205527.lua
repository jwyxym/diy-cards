--幻镜骑士衍生物
--卡密ID: 45205527

local s,id=GetID()

function s.initial_effect(c)
    --衍生物标记
    c:SetStatus(STATUS_TOKEN,true)
    --攻防0，已在数据库定义
end