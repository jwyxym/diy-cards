--绝叫与爱绝的显现·鲁鲁纳伊&巴娜蕾卡
function c38030161.initial_effect(c)
	--inactivatable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c38030161.effectfilter)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c38030161.effectfilter)
	c:RegisterEffect(e3)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030161,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030161)
	e2:SetCondition(c38030161.icon)
	e2:SetTarget(c38030161.sltg)
	e2:SetOperation(c38030161.slop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c38030161.qcon)
	c:RegisterEffect(e0)
end
function c38030161.effectfilter(e,ct)
	local code,p=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_PLAYER)
	return p==e:GetHandlerPlayer() and (code==38030155 or code==38030152)
end
function c38030161.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030161.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030161.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function c38030161.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(c38030161.thfilter,tp,LOCATION_DECK,0,1,nil,38030155)
	local b2=Duel.IsExistingMatchingCard(c38030161.thfilter,tp,LOCATION_DECK,0,1,nil,38030152)
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030161,0)},
		{b2,aux.Stringid(38030161,1)},
		{b3,aux.Stringid(38030161,2)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030161.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,c38030161.thfilter,tp,LOCATION_DECK,0,1,1,nil,38030155):GetFirst()
		if not tc then return end
		--Duel.HintSelection(Group.FromCards(tc))
		res=Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
	if op~=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,c38030161.thfilter,tp,LOCATION_DECK,0,1,1,nil,38030152):GetFirst()
		if not tc then return end
		if op==3 and res~=0 then Duel.BreakEffect() end
		--Duel.HintSelection(Group.FromCards(tc))
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
