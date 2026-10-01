--双轮夜行·吟雪&夕月
function c38030166.initial_effect(c)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030166,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030166)
	e2:SetCondition(c38030166.icon)
	e2:SetTarget(c38030166.sltg)
	e2:SetOperation(c38030166.slop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCondition(c38030166.qcon)
	c:RegisterEffect(e0)
end
function c38030166.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030166.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030166.cfilter(c)
	return c:IsSetCard(0x5616) and c:IsFaceup()
end
function c38030166.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(c38030166.cfilter,tp,LOCATION_MZONE,0,nil)
	local b1=ct>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,38030165,0,TYPES_TOKEN_MONSTER,100,2000,1,RACE_BEAST,ATTRIBUTE_DARK)
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030166,0)},
		{b2,aux.Stringid(38030166,1)},
		{b3,aux.Stringid(38030166,2)})
	e:SetLabel(op)
	if op~=2 then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	if op~=1 then
		local ft=Duel.IsPlayerAffectedByEffect(tp,59822133) and 1 or Duel.GetMZoneCount(tp)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
	end
	local cat=op==1 and CATEGORY_DESTROY+CATEGORY_RECOVER or CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN
	if op==3 then cat=CATEGORY_DESTROY+CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN end
	e:SetCategory(cat)
end
function c38030166.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if (op&1)~=0 then
		local ct=Duel.GetMatchingGroupCount(c38030166.cfilter,tp,LOCATION_MZONE,0,nil)
		if ct==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #g==0 then return end
		Duel.HintSelection(g)
		res=Duel.Destroy(g,REASON_EFFECT)
		local val=Duel.GetOperatedGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)
		if res==0 or val==0 then return end
		Duel.BreakEffect()
		Duel.Recover(tp,val*1000,REASON_EFFECT)
	end
	if (op&2)~=0 then
		local ft=Duel.GetMZoneCount(tp)
		if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,38030165,0,TYPES_TOKEN_MONSTER,100,2000,1,RACE_BEAST,ATTRIBUTE_DARK) then return end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		for i=1,ft do
			local token=Duel.CreateToken(tp,38030165)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end
