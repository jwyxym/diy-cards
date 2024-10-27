--祭法魔女 咒湮
local this,id,ofs=GetID()
function this.initial_effect(c)
    c:SetSPSummonOnce(id)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCost(this.spcost)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(this.cost)
    e2:SetTarget(this.tg)
    e2:SetOperation(this.op)
    c:RegisterEffect(e2)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(this.regop)
    c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,this.counterfilter)
end
function this.counterfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
function this.spfilter(c,e,tp)
    return c:IsSetCard(0x676) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLevelBelow(4) or c:IsLinkBelow(2))
end
function this.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMZoneCount(tp)==0 then return end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
    end
    Duel.SpecialSummonComplete()
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.CheckReleaseGroup(tp,nil,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_SZONE,0,1,nil) and Duel.GetMZoneCount(tp)>0
    if chk==0 then return b1 or b2 end
    local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,1103})
    if op==1 then
        local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil,tp)
        Duel.Release(g,REASON_COST)
    elseif op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_SZONE,0,1,1,nil)
        Duel.SendtoGrave(tc,REASON_COST)
    end
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0 and c:IsStatus(STATUS_PROC_COMPLETE) or Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function this.regop(e)
    Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
end
