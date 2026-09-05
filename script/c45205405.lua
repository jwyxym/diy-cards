--飞龙天舞
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,45205409)
	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsFaceup() and c:IsCanBeEffectTarget()
end

function s.tgfilter(c,tc)
	return c~=tc and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
		and (c:IsLocation(LOCATION_HAND+LOCATION_MZONE) or (c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_NORMAL)))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,4,tc,nil)
	if #g==0 then return end
	local ct=Duel.SendtoGrave(g,REASON_EFFECT)
	if ct==0 then return end
	local atk=ct*300
	if tc:IsCode(45205409) then
		local sum=0
		for sc in aux.Next(g) do
			if sc:IsLocation(LOCATION_GRAVE) then
				sum=sum+sc:GetBaseAttack()
			end
		end
		atk=atk+sum
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end

return s