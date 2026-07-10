--极神圣帝 奥丁
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
    c:EnableReviveLimit()
    
    -- 效果①：自己场上的「极神」怪兽·幻神兽族怪兽不受魔法·陷阱卡的效果影响
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.immtg)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)
    
    -- 效果②：被破坏送墓后，结束阶段自动特殊召唤并抽卡
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
end

-- 效果①：筛选「极神」怪兽和幻神兽族怪兽
function s.immtg(e,c)
    return c:IsSetCard(0x4b) or c:IsRace(RACE_DIVINE)
end

-- 效果①：只免疫魔法·陷阱卡的效果
function s.efilter(e,te)
    return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- 效果②：被破坏时注册结束阶段处理
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_MZONE) or not c:IsPreviousPosition(POS_FACEUP) then return end
    
    -- 注册结束阶段自动处理效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(s.endop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabelObject(c)
    Duel.RegisterEffect(e1,tp)
end

-- 结束阶段处理（不入连锁）
function s.endop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    
    -- 特殊召唤自身
    if c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonComplete()
        -- 特殊召唤成功时抽1张卡
        Duel.Draw(tp,1,REASON_EFFECT)
        
        -- ★★★ 新增：这个回合，这张卡不会被效果破坏 ★★★
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetValue(1)
        e3:SetReset(RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)
    end
end