--龙华浑天
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)	
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1c0)
		and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON+RACE_WYRM+RACE_SEASERPENT+RACE_DINOSAUR)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	local dg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=dg:GetBinClassCount(Card.GetRace)
	local b1=pg:GetClassCount(Card.GetLeftScale)>=2
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	local b2=Duel.IsPlayerCanDraw(tp,ct+1)
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+100)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,0),1},
			{b2,aux.Stringid(id,1),2})
	end
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
			e:SetProperty(0)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
		e:SetOperation(s.thop)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
			e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(ct+1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
		e:SetOperation(s.drop)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=pg:SelectSubGroup(tp,function(sg) return sg and sg:GetClassCount(Card.GetLeftScale)==#sg end,false,2,2)
	if #tg==2 and Duel.SendtoHand(tg,nil,SEQ_DECKSHUFFLE)>0 then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=dg:GetBinClassCount(Card.GetRace)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.Draw(p,ct+1,REASON_EFFECT)==ct+1 and ct>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,ct,ct,nil)
		if #g==0 then return end
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end