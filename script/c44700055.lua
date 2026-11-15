local s,id=GetID()
local SET_MOKUSHOKU = 0x747

function s.initial_effect(c)
    -- ★ 核心修复：盖放回合发动的条件
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    -- 卡的发动
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- ② 升降星/阶
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE) 
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(2,id+1) -- ②③共用2次
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- ③ 送墓表侧放置
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+1) -- ②③共用2次
    e3:SetCondition(s.gycon)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

-- 盖放回合发动的条件
function s.actcon(e)
    local tp = e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(function(c) 
        return c:IsFaceup() and not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) 
    end, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, nil) == 0
end

-- 发动目标判定
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- ① 发动时处理（选发盖放）
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSetCard(SET_MOKUSHOKU) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
    end, tp, LOCATION_HAND+LOCATION_REMOVED, 0, nil)
    if #g>0 then
        if Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SSet(tp,sg)
            end
        end
    end
end

function s.lvfilter(c)
    return c:IsFaceup() and (c:IsLevelAbove(1) or c:IsRankAbove(1)) 
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    
    local max_ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
    if max_ct <= 0 then return end
    
    local op=Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))
    
    local ct = max_ct
    if max_ct > 1 then
        local t={}
        for i=1,max_ct do t[i]=i end
        ct = Duel.AnnounceNumber(tp, table.unpack(t))
    end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    
    if tc:IsType(TYPE_XYZ) then
        e1:SetCode(EFFECT_UPDATE_RANK)
    else
        e1:SetCode(EFFECT_UPDATE_LEVEL)
    end
    
    if op==0 then
        e1:SetValue(ct)
    else
        e1:SetValue(-ct)
    end
    
    tc:RegisterEffect(e1)
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT) and re and re:GetHandler():IsType(TYPE_MONSTER)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end