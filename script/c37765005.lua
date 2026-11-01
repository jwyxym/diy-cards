--苍穹魔女 塞拉
function c37765005.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37765005,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37765005)
	e1:SetCondition(Duel.IsMainPhase)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c37765005.settg)
	e1:SetOperation(c37765005.setop)
	c:RegisterEffect(e1)
	--run
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c37765005.rmop)
	c:RegisterEffect(e2)
	--Straylight spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37765005,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,37765005+1)
	e3:SetCondition(c37765005.spcon)
	e3:SetTarget(c37765005.sptg)
	e3:SetOperation(c37765005.spop)
	c:RegisterEffect(e3)
end
function c37765005.setfilter(c)
	return c:IsSetCard(0x2a4) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function c37765005.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37765005.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c37765005.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,c37765005.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc then Duel.SSet(tp,sc) end
end
function c37765005.cfilter(c)
	return c:IsSetCard(0x2a4) and c:IsType(TYPE_QUICKPLAY) and c:IsFaceup()
end
function c37765005.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(c37765005.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or not c:IsAbleToRemove() then return end
	Duel.Hint(HINT_CARD,0,37765005)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabelObject(c)
	e1:SetOperation(c37765005.retop)
	Duel.RegisterEffect(e1,tp)
end
function c37765005.retop(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0x2a4)) then return end
	Duel.Hint(HINT_CARD,0,37765005)
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
function c37765005.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
function c37765005.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c37765005.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c37765005.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c37765005.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and aux.NecroValleyFilter()(c)
end
function c37765005.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,37765005)
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetMatchingGroup(c37765005.thfilter,p,LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(37765005,2)) then
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
			g=g:Select(p,1,1,nil)
		end
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
