--寂雷天霆
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_STANDBY_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_STANDBY_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
	--add overlay
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.ovcon)
	e4:SetTarget(s.ovtg2)
	e4:SetOperation(s.ovop2)
	c:RegisterEffect(e4)
end
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
function s.ocfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		and c:IsRankAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ocfilter,1,nil)
end
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,nil,e)
end
function s.mtfilter(c,e)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local xc=g:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
	if mg:GetCount()>0 then
		Duel.Overlay(xc,mg)
	end
end
function s.filter3(c,e,tp,eg)
	return c:IsFaceup() and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
		and Duel.IsExistingMatchingCard(s.filter4,tp,LOCATION_MZONE,0,1,c,eg)
end
function s.filter4(c,eg)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and eg:IsContains(c)
end
function s.ovtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter3(chkc,e,tp,eg) end
	if chk==0 then return Duel.IsExistingTarget(s.filter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.filter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp,eg)
end
function s.ovop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter4,tp,LOCATION_MZONE,0,1,1,tc,eg)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		tc:CancelToGrave()
		Duel.Overlay(g:GetFirst(),Group.FromCards(tc))
	end
end