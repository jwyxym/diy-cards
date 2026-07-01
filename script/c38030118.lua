--魔法少女最终决战
function c38030118.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030118)
	--e1:SetCost(c38030118.thcost)
	e1:SetTarget(c38030118.thtg)
	e1:SetOperation(c38030118.thop)
	c:RegisterEffect(e1)
	--attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030118,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030118+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38030118.atktg)
	e2:SetOperation(c38030118.atkop)
	c:RegisterEffect(e2)
end
function c38030118.cfilter(c)
	return c:IsSetCard(0x614) and c:IsType(TYPE_MONSTER)
end
function c38030118.thfilter(c,attr)
	return c:IsSetCard(0x614) and c:IsNonAttribute(attr) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c38030118.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030118.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) and e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c38030118.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,c38030118.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	Duel.HintSelection(Group.FromCards(tc))
	local attr=tc:GetAttribute()
	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(c38030118.thfilter,tp,LOCATION_DECK,0,nil,attr)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if #tg==2 and Duel.SendtoHand(tg,nil,REASON_EFFECT)==2 then
		Duel.ConfirmCards(1-tp,tg)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function c38030118.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function c38030118.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		--e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(1000)
		--e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
