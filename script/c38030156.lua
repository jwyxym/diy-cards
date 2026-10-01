--混融的肯定者
function c38030156.initial_effect(c)
	--spsummon-self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030156,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030156+1)
	e1:SetCondition(c38030156.spcon)
	e1:SetTarget(c38030156.sptg)
	e1:SetOperation(c38030156.spop)
	c:RegisterEffect(e1)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030156,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030156)
	e2:SetCondition(c38030156.icon)
	e2:SetTarget(c38030156.sltg)
	e2:SetOperation(c38030156.slop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCondition(c38030156.qcon)
	c:RegisterEffect(e0)
end
function c38030156.cfilter(c)
	return c:IsSetCard(0x5616) and c:IsFaceup()
end
function c38030156.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c38030156.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c38030156.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030156.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
end
function c38030156.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030156.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030156.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local b2=true
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030156,0)},
		{b2,aux.Stringid(38030156,1)},
		{b3,aux.Stringid(38030156,2)})
	e:SetLabel(op)
end
function c38030156.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=2 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g>0 then res=1 end
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
	if op~=1 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsFaceup() then
			if op==3 and res~=0 then Duel.BreakEffect() end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
