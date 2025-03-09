--
function c20010021.initial_effect(c)
	c:SetUniqueOnField(1,0,20010021)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20010021,2))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetCost(c20010021.atkcost)
	e1:SetTarget(c20010021.atktg)
	e1:SetOperation(c20010021.atkop)
	c:RegisterEffect(e1)
	--Avoid battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c20010021.filter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--maintain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c20010021.mtcon)
	e3:SetOperation(c20010021.mtop)
	c:RegisterEffect(e3)
end
function c20010021.filter(e,c)
	return c:IsSetCard(0xb33)
end
function c20010021.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010021.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010021.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010021.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010021,0),aux.Stringid(20010021,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010021,1))+1
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
function c20010021.costfilter(c)
	return c:IsSetCard(0xb33) and c:IsAttackAbove(1) and c:IsAbleToRemoveAsCost()
end
function c20010021.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010021.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010021.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010021.atkfilter(c)
	return c:IsFaceup()
end
function c20010021.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20010021.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20010021.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20010021.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c20010021.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end