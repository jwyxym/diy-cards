--
function c20010033.initial_effect(c)
	c:SetSPSummonOnce(20010033)
	--xyz summon
	aux.AddXyzProcedure(c,nil,12,3,c20010033.ovfilter,aux.Stringid(20010033,6),99,c20010033.xyzop)
	c:EnableReviveLimit()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20010033,4))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c20010033.cost)
	e1:SetTarget(c20010033.target)
	e1:SetOperation(c20010033.operation)
	c:RegisterEffect(e1)
	--spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.xyzlimit)
	c:RegisterEffect(e2)
	--maintain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetDescription(aux.Stringid(20010033,5))
	e3:SetCountLimit(1)
	e3:SetCondition(c20010033.mtcon)
	e3:SetOperation(c20010033.mtop)
	c:RegisterEffect(e3)
	--cannot direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
	--attack all
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_ALL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Negate summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(20010033,3))
	e6:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_SUMMON)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e6:SetCondition(c20010033.discon)
	e6:SetCost(c20010033.discost)
	e6:SetTarget(c20010033.distg)
	e6:SetOperation(c20010033.disop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e8)
end
function c20010033.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb33) and c:IsType(TYPE_XYZ+TYPE_SYNCHRO+TYPE_LINK) and c:GetBaseAttack()==4000 and not c:IsCode(20010033)
end
function c20010033.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,20010033)==0 end
	Duel.RegisterFlagEffect(tp,20010033,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c20010033.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010033.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010033.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010033.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010033,0),aux.Stringid(20010033,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010033,1))+1
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
function c20010033.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function c20010033.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c20010033.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
function c20010033.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
function c20010033.costfilter(c)
	return c:IsCode(20010010) and c:IsAbleToRemoveAsCost()
end
function c20010033.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c20010033.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010033.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010033.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb33)
end
function c20010033.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and c20010033.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20010033.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20010033.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function c20010033.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c20010033.efilter)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
	end
end
function c20010033.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end