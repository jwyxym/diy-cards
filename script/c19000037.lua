--龙装机甲-神光
function c19000037.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c19000037.matfilter,nil,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
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
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19000037)
	e1:SetCondition(c19000037.spcon)
	e1:SetOperation(c19000037.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c19000037.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000037,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,19000037+100)
	e3:SetCondition(c19000037.spscon1)
	e3:SetTarget(c19000037.tg)
	e3:SetOperation(c19000037.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c19000037.spscon2)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e4)
end
function c19000037.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c19000037.mfilter(c)
	return not c:IsType(TYPE_SYNCHRO)
end
function c19000037.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c19000037.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c19000037.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
function c19000037.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetDescription(aux.Stringid(19000037,0))
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		c:RegisterEffect(e3)
	end
end
function c19000037.spscon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsType(TYPE_SPELL) and c:IsReason(REASON_EFFECT)
end
function c19000037.spscon2(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_DRAGON~=0
end
function c19000037.tgfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
end
function c19000037.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000037.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function c19000037.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19000037.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

