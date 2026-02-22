--仙境的爱丽丝游戏
function c20200037.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_FZONE+LOCATION_GRAVE)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,20200037+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--double damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20200037.damtg)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	--change race
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20200037,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(c20200037.tg)
	e2:SetOperation(c20200037.op)
	c:RegisterEffect(e2)
end
function c20200037.damtg(e,c)
	return c:IsSetCard(0xb31)
end
function c20200037.rcfilter(c)
	return c:IsFaceupEx() and not c:IsCode(20200003)
end
function c20200037.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) and c20200037.rcfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20200037.rcfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20200037.rcfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function c20200037.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceupEx() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetValue(20200003)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end