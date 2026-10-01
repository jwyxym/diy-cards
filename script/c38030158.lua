--元素共鸣·巴尔
function c38030158.initial_effect(c)
	--spsummon-other
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030158,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,38030158)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c38030158.sptg)
	e1:SetOperation(c38030158.spop)
	c:RegisterEffect(e1)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030158,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030158)
	e2:SetCondition(c38030158.icon)
	e2:SetTarget(c38030158.sltg)
	e2:SetOperation(c38030158.slop)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c38030158.qcon)
	c:RegisterEffect(e0)
end
function c38030158.spfilter(c,e,tp,chk)
	return c:IsSetCard(0x5616) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (chk==0 or aux.NecroValleyFilter()(c))-- and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_MONSTER)
end
function c38030158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(c38030158.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,0)
	end--Duel.IsPlayerAffectedByEffect(tp,59822133)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c38030158.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c38030158.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	--local ft=Duel.IsPlayerAffectedByEffect(tp,59822133) and 1 or Duel.GetMZoneCount(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,c38030158.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,1):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c38030158.thfilter(c)
	return c:IsCode(38030158) and c:IsAbleToHand() and c:IsFaceup() 
end
function c38030158.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,38030158)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38030158.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		--Duel.ConfirmCards(1-tp,g)
	end
end
function c38030158.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030158.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030158.sltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
	local b2=Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetCurrentPhase()~=PHASE_DAMAGE
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030158,0)},
		{b2,aux.Stringid(38030158,1)},
		{b3,aux.Stringid(38030158,2)})
	e:SetLabel(op)
	if op~=1 then
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	else
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	end
	local cat=op==1 and CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE or CATEGORY_DISABLE
	if op==3 then cat=CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE end
	e:SetCategory(cat)
end
function c38030158.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=2 then
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
		if not c:IsRelateToChain() or c:IsFacedown() or #g==0 then return end
		res=1
		local tc=g:GetFirst()
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			tc=g:Select(tp,1,1,nil):GetFirst()
		end
		Duel.HintSelection(Group.FromCards(tc))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		c:RegisterEffect(e4)
	end
	if op~=1 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() then
			if op==3 and res~=0 then Duel.BreakEffect() end
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
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
