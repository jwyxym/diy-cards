-- 妖仙兽 翼天师
-- ID: 44800003
-- 字段: 0xb3
local s,id=GetID()
function s.initial_effect(c)
    -- 灵摆召唤启用
    aux.EnablePendulumAttribute(c)
    -- 灵摆召唤条件限制
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.penlimit)
    c:RegisterEffect(e0)

    -- 灵摆效果：二选一
    local pe1=Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id,0))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1,id)
    pe1:SetTarget(s.pentg)
    pe1:SetOperation(s.penop)
    c:RegisterEffect(pe1)

    -- 怪兽①：在额外卡组表侧存在的场合，主动发动检索
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,id+1)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- 怪兽②：有其他妖仙兽卡时，召唤·反转·灵摆成功检索魔法
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id+2)
    e2:SetCondition(s.thcon2)
    e2:SetTarget(s.thtg2)
    e2:SetOperation(s.thop2)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.pspcon2)
    c:RegisterEffect(e4)

    -- 怪兽③：召唤·特殊召唤的回合结束阶段回手
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.retcon)
    e5:SetTarget(s.rettg)
    e5:SetOperation(s.retop)
    c:RegisterEffect(e5)
end

-- 灵摆效果选择
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = true
    local b2 = e:GetHandler():IsDestructable()
    if chk == 0 then return b1 or b2 end
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id,4), aux.Stringid(id,5))
    elseif b1 then
        op = Duel.SelectOption(tp, aux.Stringid(id,4))
    else
        op = Duel.SelectOption(tp, aux.Stringid(id,5)) + 1
    end
    e:SetLabel(op)
    if op == 0 then
        -- 刻度变为11，风属性自肃
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LSCALE)
        e1:SetValue(11)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        e:GetHandler():RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_CHANGE_RSCALE)
        e:GetHandler():RegisterEffect(e2)
        local e3 = Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(1, 0)
        e3:SetTarget(s.splimit)
        e3:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e3, tp)
    else
        Duel.Destroy(e:GetHandler(), REASON_EFFECT)
    end
end
function s.splimit(e, c)
    return not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.penop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabel() == 1 then
        -- 追加通常召唤权，并立即询问是否召唤手牌妖仙兽
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
        if Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND, 0, 1, nil)
            and Duel.SelectYesNo(tp, aux.Stringid(id,6)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
            local sg = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
            if #sg > 0 then
                Duel.Summon(tp, sg:GetFirst(), true, nil)
            end
        end
    end
end
function s.sumfilter(c)
    return c:IsSetCard(0xb3) and c:IsSummonable(true, nil)
end

-- 怪兽① 条件：在额外卡组表侧表示
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsFaceup()
end
function s.thfilter(c)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- 怪兽② 条件：有其他妖仙兽卡存在
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.othercheck, tp, LOCATION_ONFIELD, 0, 1, nil)
end
function s.othercheck(c)
    return c:IsSetCard(0xb3) and not c:IsCode(id)
end
function s.pspcon2(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and Duel.IsExistingMatchingCard(s.othercheck, tp, LOCATION_ONFIELD, 0, 1, nil)
end
function s.thfilter2(c)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- 怪兽③ 回手：召唤或特殊召唤的回合结束阶段
function s.retcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetTurnPlayer() == tp and (c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_SPECIAL))
end
function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToHand() then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end
end