--苍穹魔女 莉莉安
function c37765000.initial_effect(c)
	--spsummon-self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37765000,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37765000)
	e1:SetCondition(c37765000.spcon)
	e1:SetTarget(c37765000.sptg)
	e1:SetOperation(c37765000.spop)
	c:RegisterEffect(e1)
	--run
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c37765000.rmop)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37765000+1)
	e3:SetCondition(Duel.IsMainPhase)
	e3:SetTarget(c37765000.thtg)
	e3:SetOperation(c37765000.thop)
	c:RegisterEffect(e3)
end
function c37765000.spcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function c37765000.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37765000.spcfilter,1,nil)
end
function c37765000.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x2a4)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c37765000.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x2a4)
	if #g==0 then return end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=g:Select(tp,1,1,nil)
	end
	Duel.Destroy(g,REASON_EFFECT)
end
function c37765000.cfilter(c)
	return c:IsSetCard(0x2a4) and c:IsType(TYPE_QUICKPLAY) and c:IsFaceup()
end
function c37765000.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(c37765000.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or not c:IsAbleToRemove() then return end
	Duel.Hint(HINT_CARD,0,37765000)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabelObject(c)
	e1:SetOperation(c37765000.retop)
	Duel.RegisterEffect(e1,tp)
end
function c37765000.retop(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsActiveType(TYPE_QUICKPLAY) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0x2a4)) then return end
	Duel.Hint(HINT_CARD,0,37765000)
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
function c37765000.thfilter(c,p)
	return c:IsControler(p) and c:IsAbleToHand()
end
function c37765000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetColumnGroup():Filter(c37765000.thfilter,nil,1-tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c37765000.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=c:GetColumnGroup():Filter(c37765000.thfilter,nil,1-tp)
	if c:IsControler(1-tp) then g:AddCard(c) end
	Duel.SendtoHand(g,nil,REASON_RULE,1-tp)
end
