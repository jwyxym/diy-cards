--诺艾尔 小街漫步
function c44100472.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44100472+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c44100472.activate)
	c:RegisterEffect(e1)
	--swap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,44110472)
	e2:SetCondition(c44100472.adon)
	e2:SetTarget(c44100472.adtg)
	e2:SetOperation(c44100472.adop)
	c:RegisterEffect(e2)
	--act limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c44100472.actcon)
	e3:SetValue(c44100472.actlimit)
	c:RegisterEffect(e3)
end
function c44100472.cfilter(c,code)
	return c:IsCode(code) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c44100472.thfilter(c,tp)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(c44100472.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function c44100472.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c44100472.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(44100472,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c44100472.concfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44a)
end
function c44100472.adon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	return ct>0 and ct==Duel.GetMatchingGroupCount(c44100472.concfilter,tp,LOCATION_MZONE,0,nil)
end
function c44100472.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(2000)
end
function c44100472.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c44100472.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c44100472.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c44100472.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function c44100472.adop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
function c44100472.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function c44100472.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
