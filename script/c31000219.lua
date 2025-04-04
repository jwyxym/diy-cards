--虚幻梦之摇篮
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddCodeList(c,31000201)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e2=aux.AddRitualProcGreater2(c,this.filter,LOCATION_HAND+LOCATION_GRAVE,nil,nil,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.acon)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(this.condition)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(this.target)
	e2:SetOperation(this.operation)
	c:RegisterEffect(e2)
end
function this.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
function this.afilter(c)
	return aux.IsCodeListed(c,31000201) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function this.cfilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and aux.IsCodeListed(c,31000201) and not c:IsReason(REASON_RULE)
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.cfilter,1,nil,tp)
end
function this.spfilter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR+RACE_BEAST) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function this.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
