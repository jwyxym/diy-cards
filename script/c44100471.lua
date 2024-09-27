--诺艾尔 清凉夏日
function c44100471.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(44100471,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(aux.TRUE)
	c:RegisterEffect(e0)
	--attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44100471,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,44100471)
	e1:SetCost(c44100471.cost1)
	e1:SetTarget(c44100471.target1)
	e1:SetOperation(c44100471.activate1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44100471,2))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,44100471)
	e3:SetCondition(c44100471.condition2)
	e3:SetCost(c44100471.cost2)
	e3:SetTarget(c44100471.target2)
	e3:SetOperation(c44100471.activate2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
function c44100471.tgfilter1(c)
	return c:IsSetCard(0x44a) and c:IsFaceup()
end
function c44100471.cfilter1(c,tp)
	return c:IsSetCard(0x44a)
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsExistingTarget(c44100471.tgfilter1,tp,LOCATION_MZONE,0,1,c)
end
function c44100471.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c44100471.cfilter1,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c44100471.cfilter1,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c44100471.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44100471.tgfilter1(c) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c44100471.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function c44100471.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetBaseAttack()+tc:GetBaseDefense()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c44100471.tfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x44a)
end
function c44100471.condition2(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c44100471.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function c44100471.cfilter2(c,tp)
	return c:IsSetCard(0x44a)
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c44100471.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c44100471.cfilter2,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c44100471.cfilter2,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c44100471.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c44100471.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
