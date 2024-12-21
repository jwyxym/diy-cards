--尸朽鬼 风化寄生者
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(this.con)
	e1:SetCost(this.cost)
	e1:SetTarget(this.tg)
	e1:SetOperation(this.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(this.sptg)
	e2:SetOperation(this.spop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,this.counterfilter)
end
function this.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK))
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK))
end
function this.nt(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function this.tnfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(this.nt,tp,LOCATION_GRAVE,0,nil)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and g:CheckSubGroup(this.ntfilter,1,2,c:GetLevel(),e,tp)
end
function this.ntfilter(g,lv,e,tp)
	return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_EXTRA,0,1,nil,lv+g:GetSum(Card.GetLevel),e,tp)
end
function this.spfilter(c,lv,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsLevel(lv)
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.tnfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCountFromEx(tp)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tn=Duel.SelectMatchingCard(tp,this.tnfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	local g=Duel.GetMatchingGroup(this.nt,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local nt=g:SelectSubGroup(tp,this.ntfilter,false,1,2,tn:GetLevel(),e,tp)
	nt:AddCard(tn)
	e:SetLabel(nt:GetSum(Card.GetLevel))
	Duel.Remove(nt,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel(),e,tp)
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	end
end
function this.filtter(c,e,tp)
	return c:IsSetCard(0x679) and c:IsPosition(POS_FACEUP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filtter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.GetMZoneCount(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,this.filtter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
