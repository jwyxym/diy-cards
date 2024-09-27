--炽天使之身
local cm,m,o=GetID()
function cm.initial_effect(c)
    --spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,m+5)
    e1:SetCost(cm.cost)
    e1:SetTarget(cm.tg)
    e1:SetOperation(cm.op)
    c:RegisterEffect(e1)
    --material
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,m+5)
    e2:SetCost(cm.cost1)
    e2:SetTarget(cm.tg1)
    e2:SetOperation(cm.op1)
    c:RegisterEffect(e2)
    --get effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_XMATERIAL)
    e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetValue(1)
    e3:SetCondition(cm.mcon)
    c:RegisterEffect(e3)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,700) end
    Duel.PayLPCost(tp,700)
end
function cm.filter(c,e,tp)
    return c:IsSetCard(0x721)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
function cm.xyzfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsType(TYPE_XYZ)
end
function cm.matfilter(c)
    return c:IsSetCard(0x721) and c:IsAbleToRemoveAsCost()
end
function cm.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.matfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,cm.matfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.xyzfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cm.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,cm.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
        Duel.Overlay(tc,c)
    end
end
function cm.mcon(e)
    return e:GetHandler():GetOriginalRace()==RACE_FAIRY
end