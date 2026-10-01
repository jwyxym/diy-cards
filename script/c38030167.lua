--启程的退场
function c38030167.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030167,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,38030167)
	e2:SetTarget(c38030167.sltg)
	e2:SetOperation(c38030167.slop)
	c:RegisterEffect(e2)
end
function c38030167.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=true
	local b2=true
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil)
	local b4=Duel.IsPlayerCanDiscardDeck(tp,3)
	local s,cat=0,0
	for i=1,3 do
		if i==3 and Duel.GetCounter(tp,1,0,0x611)<10 then break end
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(38030167,0),1},
			{b2,aux.Stringid(38030167,1),2},
			{b3,aux.Stringid(38030167,2),4},
			{b4,aux.Stringid(38030167,3),8},
			{i==3,aux.Stringid(38030167,4),0})
		s=s+op
		if op==1 then
			cat=cat+CATEGORY_DAMAGE
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
			b1=false
		elseif op==2 then
			cat=cat+CATEGORY_RECOVER
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2500)
			b2=false
		elseif op==4 then
			cat=cat+CATEGORY_TODECK
			Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
			b3=false
		elseif op==8 then
			cat=cat+CATEGORY_TOGRAVE+CATEGORY_DECKDES
			Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
			b4=false
		end
	end
	e:SetLabel(s)
	e:SetCategory(cat)
end
function c38030167.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if (op&1)~=0 then
		res=Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
	if (op&2)~=0 then
		if res~=0 then Duel.BreakEffect() end
		res=Duel.Recover(tp,2500,REASON_EFFECT)
	end
	if (op&4)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,3,nil)
		if #tg>0 then
			if res~=0 then Duel.BreakEffect() end
			Duel.HintSelection(tg)
			res=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	if (op&8)~=0 then
		if res~=0 then Duel.BreakEffect() end
		res=Duel.DiscardDeck(tp,3,REASON_EFFECT)
	end
end
