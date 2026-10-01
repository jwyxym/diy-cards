--混融的祈祷者
function c38030160.initial_effect(c)
	aux.AddCodeList(c,38030151)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,38030160+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c38030160.sprcon)
	c:RegisterEffect(e1)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030160,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030160)
	e2:SetCondition(c38030160.icon)
	e2:SetTarget(c38030160.sltg)
	e2:SetOperation(c38030160.slop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c38030160.qcon)
	c:RegisterEffect(e0)
end
function c38030160.sprcon(e,c)
	if c==nil then return true end
	return Duel.IsEnvironment(38030151,c:GetControler())
		and Duel.GetMZoneCount(c:GetControler())>0
end
function c38030160.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030160.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030160.sltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	local b1=Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
	local b2=true
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030160,0)},
		{b2,aux.Stringid(38030160,1)},
		{b3,aux.Stringid(38030160,2)})
	e:SetLabel(op)
	if op~=1 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetProperty(0)
	end
	if op~=2 then Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000) end
	local cat=op==1 and CATEGORY_DESTROY or CATEGORY_RECOVER
	if op==3 then cat=CATEGORY_DESTROY+CATEGORY_RECOVER end
	e:SetCategory(cat)
end
function c38030160.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then res=Duel.Destroy(tc,REASON_EFFECT) end
	end
	if op~=1 then
		if op==3 and res~=0 then Duel.BreakEffect() end
		Duel.Recover(tp,2000,REASON_EFFECT)
	end
end
