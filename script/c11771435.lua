--吸血鬼的谐谑
function c11771435.initial_effect(c)
    -- 特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(11771435,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,11771435)
    e1:SetCost(c11771435.cost1)
    e1:SetTarget(c11771435.tg1)
    e1:SetOperation(c11771435.op1)
    c:RegisterEffect(e1)
    -- 转移控制权
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(11771435,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,11771436)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCondition(aux.exccon)
    e2:SetCost(c11771435.cost2)
    e2:SetTarget(c11771435.tg2)
    e2:SetOperation(c11771435.op2)
    c:RegisterEffect(e2)
    -- 手卡发动条件
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11771435,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(c11771435.handcon)
	c:RegisterEffect(e3)
end
-- 手卡发动
function c11771435.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function c11771435.handcon(e)
	return Duel.IsExistingMatchingCard(c11771435.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 1
function c11771435.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function c11771435.filter1(c,e,tp)
    return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771435.filter11(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsReleasableByEffect()
end
function c11771435.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c11771435.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c11771435.op1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11771435.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        if Duel.IsExistingMatchingCard(c11771435.filter11,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(11771435,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            local rg=Duel.SelectMatchingCard(tp,c11771435.filter11,tp,LOCATION_MZONE,0,1,1,nil)
            if rg:GetCount()>0 then
                Duel.Release(rg,REASON_EFFECT)
            end
        end
    end
end
-- 2
function c11771435.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.CheckLPCost(tp,1000) end
    aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.PayLPCost(tp,1000)
end
function c11771435.filter2(c,e,tp)
    return c:IsControler(1-tp) and c:IsAbleToGrave()
end
function c11771435.filter22(c,e,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771435.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c11771435.filter2,tp,0,LOCATION_MZONE,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c11771435.op2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c11771435.filter2,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
    if g:GetCount()>0 then
        if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
            if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
