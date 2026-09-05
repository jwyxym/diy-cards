--万术的罪人·赛菲
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,57310005)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id+id)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,57310005,0,TYPES_TOKEN,1000,1000,2,RACE_ILLUSION,ATTRIBUTE_DARK)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,57310005,0,TYPES_TOKEN,1000,1000,2,RACE_ILLUSION,ATTRIBUTE_DARK) then return end
    local token=Duel.CreateToken(tp,57310005)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
function s.fusion_filter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.fusion_filter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.fusion_filter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
            and Duel.IsPlayerCanSpecialSummonMonster(tp,57310005,0,TYPES_TOKEN,1000,1000,2,RACE_ILLUSION,ATTRIBUTE_DARK)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.fusion_filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not s.fusion_filter(tc) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,57310005,0,TYPES_TOKEN,1000,1000,2,RACE_ILLUSION,ATTRIBUTE_DARK) then return end
    for i=1,2 do
        local token=Duel.CreateToken(tp,57310005)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
    if not tc:IsRelateToEffect(e) then return end
    s.attach_negate_effect(e,tc)
end
function s.attach_negate_effect(e,tc)
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetDescription(aux.Stringid(id,2))
    e0:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e0:SetType(EFFECT_TYPE_QUICK_O)
    e0:SetCode(EVENT_CHAINING)
    e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCountLimit(1)
    e0:SetCondition(s.negate_condition)
    e0:SetCost(s.negate_cost)
    e0:SetTarget(s.negate_target)
    e0:SetOperation(s.negate_operation)
    tc:RegisterEffect(e0)
end
function s.negate_condition(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
    and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.negate_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.derivative_filter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.derivative_filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.derivative_filter(c)
    return c:IsCode(57310005) and c:IsReleasable()
end
function s.negate_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negate_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
