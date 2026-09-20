--战华之医-华元
local s,id=GetID()
function s.initial_effect(c)
    --①效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --②效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    --③效果
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x137))
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e3b=e3:Clone()
    e3b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e3b)
    
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.recovcon)
    e4:SetOperation(s.recovop)
    c:RegisterEffect(e4)
end

function s.spfilter1(c)
    return c:IsFaceup() and (c:IsLevelAbove(7) or c:IsAttackAbove(2500))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.cfilter2(c,tp)
	if not c:IsAbleToGraveAsCost() then return false end
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_TOFIELD,0x7f)<=0 then
		return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
	end
	return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp))
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.recovfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.recovcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsFaceup() and eg:IsExists(s.recovfilter,1,nil,tp)
end

function s.recovop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,500,REASON_EFFECT)
end

return s
