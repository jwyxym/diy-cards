--叫唤与憎恶
function c38030163.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCountLimit(1,38030163+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38030163.target)
	e1:SetOperation(c38030163.activate)
	c:RegisterEffect(e1)
end
function c38030163.tdfilter(c,chk)
	return c:IsSetCard(0x5616) and not c:IsCode(38030163) and c:IsAbleToDeck() and (chk==0 or aux.NecroValleyFilter()(c))
end
function c38030163.thfilter(c)
	return c:IsSetCard(0x5616) and c:IsAbleToHand()
end
function c38030163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(c38030163.tdfilter,tp,LOCATION_GRAVE,0,1,nil,0)
	local b3=Duel.IsExistingMatchingCard(c38030163.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local cat=0
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030163,0),1},
		{b2,aux.Stringid(38030163,1),2},
		{b3,aux.Stringid(38030163,2),4})
	if op==1 then
		cat=cat+CATEGORY_DESTROY
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		b1=false
	elseif op==2 then
		cat=cat+CATEGORY_TODECK
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		b2=false
	elseif op==4 then
		cat=cat+CATEGORY_TOHAND+CATEGORY_SEARCH
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		b3=false
	end
	if Duel.GetCounter(tp,1,0,0x611)>=10 and (b1 or b2 or b3) then
		local b4=true
		local s=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(38030163,0),1},
			{b2,aux.Stringid(38030163,1),2},
			{b3,aux.Stringid(38030163,2),4},
			{b4,aux.Stringid(38030163,3),0})
		if s==1 then
			cat=cat+CATEGORY_DESTROY
			local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		elseif s==2 then
			cat=cat+CATEGORY_TODECK
			Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		elseif s==4 then
			cat=cat+CATEGORY_TOHAND+CATEGORY_SEARCH
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
		op=op+s
	end
	e:SetLabel(op)
	e:SetCategory(cat)
end
function c38030163.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if (op&1)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			res=Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if (op&2)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,c38030163.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil,1)
		if #tg>0 then
			if res~=0 then Duel.BreakEffect() end
			Duel.HintSelection(tg)
			res=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	if (op&4)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,c38030163.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
		if not tc then return end
		if res~=0 then Duel.BreakEffect() end
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
