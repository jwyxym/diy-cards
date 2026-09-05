local s,id,o=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+o)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end

function s.spfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.recfilter(c)
    return c:IsSetCard(SET_HOLY_NIGHT) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON))
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.recop(e,tp)
    local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_GRAVE,0,nil)
    if #g==0 then return end
    local sg=g:Select(tp,1,math.min(5,#g),nil)
    local ct=Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
    if ct>1 then Duel.Draw(tp,math.floor(ct/2),REASON_EFFECT) end
end