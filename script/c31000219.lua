--虚幻梦之摇篮
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddCodeList(c,31000201)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e2=aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),LOCATION_HAND+LOCATION_GRAVE,nil,nil,true)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(this.acon)
    c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(this.condition)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(this.target)
	e2:SetOperation(this.operation)
	c:RegisterEffect(e2)
end
function this.afilter(c)
    return aux.IsCodeListed(c,31000201) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function this.filter(c,e,tp)
    return c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function this.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMZoneCount(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if tc and #tc==1 then
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end
