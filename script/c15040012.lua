-- 风暴与光耀之华岚尔
-- ID: 15040012
-- 字段：异响鸣 (0x1a3)
local s,id=GetID()
function s.initial_effect(c)
    -- 超量召唤：4星「异响鸣」怪兽2只以上
    aux.AddXyzProcedure(c, s.xyzfilter, 4, 2)
    c:EnableReviveLimit()

    -- ① 对方准备阶段，自己场上没有其他「异响鸣」怪兽时破坏自身
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- ② 二速取除全部素材，选择效果发动（1回合1次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- ③ 持有素材且守备表示时，强制表侧怪兽变守备
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SET_POSITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetCondition(s.poscon)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e3:SetValue(POS_FACEUP_DEFENSE)
    c:RegisterEffect(e3)

    -- ③ 无效其他守备表示怪兽发动的效果
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_SOLVING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.discon)
    e4:SetOperation(s.disop)
    c:RegisterEffect(e4)
end

-- 超量素材基础条件：4星「异响鸣」怪兽
function s.xyzfilter(c)
    return c:IsSetCard(0x1a3) and c:IsLevel(4)
end

-- ① 条件：对方准备阶段，且自己场上没有其他「异响鸣」怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()~=tp
        and not Duel.IsExistingMatchingCard(function(tc) return tc:IsSetCard(0x1a3) and tc~=c end,tp,LOCATION_MZONE,0,1,nil)
end
-- ① 操作：破坏自身
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Destroy(c,REASON_EFFECT)
    end
end

-- ② cost：取除全部超量素材
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetOverlayCount()
    if chk==0 then return ct>0 and c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
    c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
-- ② 操作：选择效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    if op==0 then
        -- 回复500，可选破坏里侧卡，守备力下降900
        Duel.Recover(tp,500,REASON_EFFECT)
        if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #dg>0 then
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
        -- 守备力下降900
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetValue(-900)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    else
        -- 受到500伤害，可选无效场上1只怪兽，守备力下降900
        Duel.Damage(tp,500,REASON_EFFECT)
        if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local tg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
            local tc=tg:GetFirst()
            if tc then
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
                local e3=e2:Clone()
                e3:SetCode(EFFECT_DISABLE_EFFECT)
                tc:RegisterEffect(e3)
            end
        end
        -- 守备力下降900
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_UPDATE_DEFENSE)
        e4:SetValue(-900)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e4)
    end
end

-- ③ 位置条件：持有素材且这张卡在守备表示
function s.poscon(e)
    local c=e:GetHandler()
    return c:IsDefensePos() and c:GetOverlayCount()>0
end

-- ③ 无效条件：自身持有素材且守备表示，且发动的效果是其他守备表示怪兽的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsDefensePos() or c:GetOverlayCount()<=0 then return false end
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    local rc=re:GetHandler()
    if rc==c then return false end  -- 排除自身
    local loc,pos=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
    return loc==LOCATION_MZONE and bit.band(pos,POS_DEFENSE)~=0
end
-- ③ 无效操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end