--诺艾尔 受邀同行
function c44100469.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44100469+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c44100469.target)
	e1:SetOperation(c44100469.activate)
	c:RegisterEffect(e1)
end
function c44100469.tdfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x44a)
		and not c:IsCode(44100469) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function c44100469.fselect(sg)
	return sg:GetCount()==3 or sg:GetCount()==6
end
function c44100469.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(c44100469.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #g>=3 end
	local max=3
	if Duel.IsPlayerCanDraw(tp,2) then max=6 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,c44100469.fselect,false,3,max)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,sg:GetCount()//3)
end
function c44100469.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		local xt=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		Duel.SortDecktop(tp,tp,xt)
		for i=1,ct do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
		Duel.BreakEffect()
		Duel.Draw(tp,ct//3,REASON_EFFECT)
	end
end
