local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74401085)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

function s.ygfilter(c)
	return c:IsCode(74401076)
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,74401085) and c:IsAbleToHand()
end
function s.zfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(s.ygfilter,tp,LOCATION_MZONE,0,1,nil) then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
				or Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_DECK,0,1,nil)
		end
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local mode=1
	if Duel.IsExistingMatchingCard(s.ygfilter,tp,LOCATION_MZONE,0,1,nil) then
		local avail_ref=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local avail_zombie=Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_DECK,0,1,nil)
		if avail_ref and avail_zombie then
			mode=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
		elseif avail_zombie then
			mode=2
		end
	end
	local f
	if mode==2 then f=s.zfilter else f=s.thfilter end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and aux.exccon(e,tp,eg,ep,ev,re,r,rp)
end
function s.sdgfilter(c)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,74401085) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sdgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sdgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end