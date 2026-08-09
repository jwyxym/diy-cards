-- 属于我们的歌 椎名立希
-- ID: 15040000
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)

    -- 同调召唤限制：「碰面 椎名立希」(26062904) + 调整以外的怪兽1只以上
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsCode,26062904),
        aux.NonTuner(nil), 1)

    -- ① 特殊召唤成功时，场上最多2只怪兽攻击力减半
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- ② 自己主要阶段，场上有「春日影」时，回收墓地3只记述怪兽并赋予守备攻击能力
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end

-- ① 对象：场上最多2只表侧怪兽
function s.atkfilter(c)
    return c:IsFaceup() and c:GetAttack()>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    local tc=g:GetFirst()
    while tc do
        local atk=tc:GetAttack()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(math.floor(atk/2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end

-- ② 条件：自己场上有「春日影」(26062911)
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,26062911)
end
-- ② 对象：自己墓地3只记述「春日影」的怪兽
function s.recfilter(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.recfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    -- 赋予守备表示攻击能力（直到回合结束）
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DEFENSE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(aux.IsCodeListed,26062911))
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ALLOW_ATTACK_IN_DEFENSE_POS)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(aux.IsCodeListed,26062911))
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end