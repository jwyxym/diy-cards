--梭巡游侠 合取
function c16820045.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c16820045.mfilter,1)
	--SpecialSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16820045)
	e1:SetTarget(c16820045.sptg)
	e1:SetOperation(c16820045.spop)
	c:RegisterEffect(e1)
	c16820045.discard_effect=e1
end
function c16820045.mfilter(c,xyzc)
	return (c:IsLevel(1) or c:IsRank(1)) and c:IsSetCard(0xdf28)
end
function c16820045.spfilter(c,e,tp)
	return (c:IsLevel(1) or c:IsRace(1) or c:IsLink(1)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c16820045.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c16820045.spfilter,tp,0x10,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x10)
end
function c16820045.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16820045.spfilter),tp,0x10,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c16820045.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c16820045.splimit(e,c)
	return not c:IsLevel(1) and not c:IsRank(1) and not c:IsLink(1)
end