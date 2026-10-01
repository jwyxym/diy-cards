--瓦尔基里-代号：光
local s,id,o=GetID()
function s.initial_effect(c)
	--
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,99)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetTarget(s.nontg)
	e4:SetOperation(s.nonop)
	c:RegisterEffect(e4)
end
--
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
--
function s.filter(c,e,tp)
	return (c:IsLevelBelow(4) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
--
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
--
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		end
	end
end
--
function s.tunerfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
--
function s.oppfilter(c)
	return c:IsAbleToRemove()
end
--
function s.nontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,PLAYER_ALL,LOCATION_MZONE)
end
--
function s.nonop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_MZONE,nil)
	if #g1==0 or #g2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	if Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
	local og=Duel.GetOperatedGroup()
	local fid=c:GetFieldID()
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	og:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(fid)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	Duel.RegisterEffect(e1,tp)
end
--
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
--
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,fid) then
		e:GetLabelObject():DeleteGroup()
		return false
	end
	return true
end
--
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	if #g<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	for tc in aux.Next(g) do
		local p=tc:GetPreviousControler()
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
			Duel.ReturnToField(tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	e:GetLabelObject():DeleteGroup()
end