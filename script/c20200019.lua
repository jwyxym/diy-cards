--爱丽丝，仙境的天使
function c20200019.initial_effect(c)
	c:SetSPSummonOnce(20200019)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c20200019.matfilter,1,1)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE)
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--spsummon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20200019,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(c20200019.sptg)
	e1:SetOperation(c20200019.spop)
	c:RegisterEffect(e1)
end
function c20200019.matfilter(c)
	return c:IsLinkSetCard(0xb31) and c:IsLevel(3)
end
function c20200019.filter(c,e,tp)
	return c:IsSetCard(0xb31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0 and (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsFaceup()) or (c:IsLocation(LOCATION_PZONE) and c:IsFaceup())
end
function c20200019.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	if chk==0 then return Duel.IsExistingMatchingCard(c20200019.filter,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA,0,1,exc,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA)
end
function c20200019.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20200019.filter,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20200019.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c20200019.splimit(e,c)
	return not c:IsSetCard(0xb31)
end