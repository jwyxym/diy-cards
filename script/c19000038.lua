--龙装机甲-火花
function c19000038.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c19000038.matfilter,nil,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e0:SetValue(RACE_DRAGON)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19000038)
	e1:SetCondition(c19000038.spcon)
	e1:SetOperation(c19000038.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c19000038.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000038,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,19000038+100)
	e3:SetCondition(c19000038.spscon1)
	e3:SetTarget(c19000038.tg)
	e3:SetOperation(c19000038.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c19000038.spscon2)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e4)
end
function c19000038.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c19000038.mfilter(c)
	return not c:IsType(TYPE_SYNCHRO)
end
function c19000038.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c19000038.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c19000038.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
function c19000038.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_REMOVE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTarget(c19000038.rmrtg)
		e1:SetOperation(c19000038.rmrop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetDescription(aux.Stringid(19000038,0))
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		c:RegisterEffect(e2)
	end
end
function c19000038.rmrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c19000038.rmrop(e,tp,eg,ep,ev,re,r,rp)
	local rm1=false
	local rm2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsOnField() then
			if tc:IsControler(tp) then rm1=true else rm2=true end
		end
		tc=eg:GetNext()
	end
	local g=Group.CreateGroup()
	if rm1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		g:Merge(g1)
	end
	if rm2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,LOCATION_HAND,0,1,1,nil)
		g:Merge(g2)
	end
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c19000038.spscon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsType(TYPE_SPELL) and c:IsReason(REASON_EFFECT)
end
function c19000038.spscon2(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_DRAGON~=0
end
function c19000038.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function c19000038.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000038.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c19000038.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000038.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
