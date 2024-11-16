--Data without words
function c88188209.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c88188209.target)
	e1:SetOperation(c88188209.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c88188209.eqlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(c88188209.immval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88188209,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_CONFIRM)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,88188209)
	e4:SetCondition(c88188209.atkcon)
	e4:SetTarget(c88188209.atktg)
	e4:SetOperation(c88188209.atkop)
	c:RegisterEffect(e4)
end
c88188209.SetCard_Numerical_Crack=true 
function c88188209.eqlimit(e,c)
	return c:IsSetCard(0xa590)
end
function c88188209.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa590)
end
function c88188209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88188209.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c88188209.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c88188209.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c88188209.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
function c88188209.immval(e,re)
	return re:IsActivated() and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c88188209.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc
end
function c88188209.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
end
function c88188209.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetHandler():GetEquipTarget()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c88188209.atkval)
	e:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
end
function c88188209.atkval(e,c)
	local x=Duel.GetFlagEffect(e:GetHandlerPlayer(),88188200)
	return e:GetHandler():GetAttack()*x
end