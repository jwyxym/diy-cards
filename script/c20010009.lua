--
function c20010009.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c20010009.reptg)
	e1:SetValue(c20010009.repval)
	c:RegisterEffect(e1)
	--maintain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetDescription(aux.Stringid(20010009,5))
	e2:SetCountLimit(1)
	e2:SetCondition(c20010009.mtcon)
	e2:SetOperation(c20010009.mtop)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c20010009.disable)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	--inactivatable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetValue(c20010009.effectfilter)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetValue(c20010009.effectfilter)
	c:RegisterEffect(e5)
end
function c20010009.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0xb33) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function c20010009.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c20010009.repfilter,nil,tp)
	local g=Duel.GetDecktopGroup(tp,ct)
	if chk==0 then return g:IsExists(Card.IsAbleToRemove,ct,nil,tp,POS_FACEUP) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
function c20010009.repval(e,c)
	return c20010009.repfilter(c,e:GetHandlerPlayer())
end
function c20010009.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010009.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010009.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010009.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010009,0),aux.Stringid(20010009,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010009,1))+1
	end
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,cg)
		Duel.ShuffleHand(tp)
	else
		Duel.Destroy(c,REASON_COST)
	end
end
function c20010009.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0xb33) and bit.band(loc,LOCATION_ONFIELD)~=0
end
function c20010009.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0) and c:IsSetCard(0xb33)
end