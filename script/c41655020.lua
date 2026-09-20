-- 烬雪的怀柔·薇缇娅
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	local e9=e1:Clone()
	e9:SetCondition(s.cannotcon)
	e9:SetOperation(s.operation3)
	c:RegisterEffect(e9)
	s.jinxue_effect=e9
end
function s.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.pcfilter(c,tp)
	return c:IsSetCard(0xe93) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.thfilter(c)
	return c:IsCode(41655000) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(s.indct)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g2)
	end
end
function s.ptfilter(e,c)
	return c:IsSetCard(0xe93)
end
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer() then
		return 1
	else return 0 end
end
function s.cannotcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(e:GetHandler())<0
end
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	s.operation(e,tp,eg,ep,ev,re,r,rp)
	s.operation2(e,tp,eg,ep,ev,re,r,rp)
end
