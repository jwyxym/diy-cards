--清蓝之龙神 碧天
function c31000407.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DRAGON+RACE_SEASERPENT+RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	--multi attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c31000407.valcheck)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c31000407.discon)
	e2:SetTarget(c31000407.distg)
	e2:SetOperation(c31000407.disop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31000407.atkcon)
	e3:SetTarget(c31000407.atktg)
	e3:SetOperation(c31000407.atkop)
	c:RegisterEffect(e3)
	local e33=e3:Clone()
	e33:SetCode(EVENT_ATTACK_ANNOUNCE)
	e33:SetCondition(c31000407.atkcon2)
	c:RegisterEffect(e33)
	
end
function c31000407.valcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsRace,nil,RACE_DRAGON+RACE_SEASERPENT+RACE_WINDBEAST):GetCount()
	if ct>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
	e2:SetValue(ct*1200)
	c:RegisterEffect(e2)
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_SINGLE)
	e22:SetCode(EFFECT_UPDATE_DEFENSE)
	e22:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE-RESET_TOFIELD)
	e22:SetValue(ct*1200)
	c:RegisterEffect(e22)
end
function c31000407.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c31000407.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function c31000407.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function c31000407.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function c31000407.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function c31000407.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.nzatk(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c31000407.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end