--纠缠的因果
function c38030116.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030116+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c38030116.cost)
	e1:SetTarget(c38030116.thtg)
	e1:SetOperation(c38030116.thop)
	c:RegisterEffect(e1)
end
function c38030116.cfilter(c,tp)
	return c:IsSetCard(0x614) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and (c:IsAttribute(0x30) and c:IsSummonable(true,nil) or not c:IsAttribute(0x30) and Duel.IsExistingMatchingCard(c38030116.thfilter,tp,LOCATION_DECK,0,1,nil))
end
function c38030116.thfilter(c)
	return c:IsSetCard(0x614) and c:IsAttribute(0x30) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function c38030116.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030116.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,c38030116.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	--e:SetLabel(tc:GetAttribute())
	Duel.SetTargetCard(tc)
end
function c38030116.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:IsCostChecked() end
end
function c38030116.thop(e,tp,eg,ep,ev,re,r,rp)
	--[[local attr=e:GetLabel()
	if attr==0 then return end]]--
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsAttribute(0x30) then--(attr&0x30)~=0
		if not tc:IsRelateToChain() then return end
		Duel.Summon(tp,tc,true,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,c38030116.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if not tc then return end
		--Duel.HintSelection(Group.FromCards(tc))
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsLocation(LOCATION_HAND) then return end
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetTargetRange(1,0)
		e0:SetTarget(c38030116.splimit)
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
	end
end
function c38030116.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsRace(RACE_SPELLCASTER+RACE_FAIRY+RACE_FIEND) and c:IsLevelAbove(1))-- and c:IsLocation(LOCATION_EXTRA)
end
