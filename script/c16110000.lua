--神帝 伊兹莫
local m=16110000
local cm=_G["c"..m]
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.descon)
	e1:SetTarget(cm.destg)
	e1:SetOperation(cm.desop)
	c:RegisterEffect(e1)
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function cm.filter(c)
	return not c:IsPublic() and (c:IsAttack(2400) or c:IsAttack(2800))
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(m,4))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(m,2))
		e4:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetRange(LOCATION_HAND)
		e4:SetCountLimit(1)
		e4:SetCost(cm.cost)
		e4:SetCondition(cm.sumcon)
		e4:SetTarget(cm.sumtg)
		e4:SetOperation(cm.sumop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
function cm.tdfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeckAsCost() and c:IsFaceup()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	Duel.SendtoDeck(tg1,nil,2,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,c:GetCode(),RESET_PHASE+PHASE_END,0,1)
end
function cm.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPublic()
end
function cm.cfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function cm.tgfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function cm.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return (c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)) and g:GetClassCount(Card.GetCode)>1 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function cm.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 then
		if not c:IsRelateToEffect(e) then return end
		local pos=0
		if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
		if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
		if pos==0 then return end
		if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
			Duel.Summon(tp,c,true,nil,1)
		else
			Duel.MSet(tp,c,true,nil,1)
		end
	end
end