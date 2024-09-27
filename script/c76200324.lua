--无名的妖精 藿普
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c)
    aux.AddCodeList(c,76200312)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.spcost)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
	aux.EnableChangeCode(c,76200312,LOCATION_ONFIELD)
end
function this.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function this.spfilter(c,e,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsCode(76200312) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0
    or c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsCode(76200312) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp)>0
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if tc and #tc>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetHandler():IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
    end
end
