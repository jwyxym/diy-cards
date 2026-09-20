--灵魂向导
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--回收    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--送去墓地
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)   
end
function s.dhfilter(c,g)
	return c:IsAbleToHand() and g:IsExists(Card.IsAbleToDeck,1,c)
end
function s.thfilter(c,ec)
	local g=Group.FromCards(c,ec)
	return aux.IsCodeListed(c,31280102) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and g:IsExists(s.dhfilter,1,nil,g)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(tp) and chkc~=c and s.thfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,c,c)
    g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    if e:GetActivateLocation()==LOCATION_MZONE or g:GetFirst():IsLocation(LOCATION_MZONE) then
    	e:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_TODECK)
    end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local tg=Group.FromCards(c,tc):Filter(Card.IsRelateToEffect,nil,e)
    if tg:GetCount()~=2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local hc=tg:FilterSelect(tp,s.dhfilter,1,1,nil,tg):GetFirst()
	if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
    	Duel.ConfirmCards(1-tp,hc)
        tg:RemoveCard(hc)
		if Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)~=0 and tg:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA)
        	and (hc:IsPreviousLocation(LOCATION_MZONE) or tg:GetFirst():IsPreviousLocation(LOCATION_MZONE))
            and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.ShuffleDeck(tp)
        	Duel.Draw(tp,1,REASON_EFFECT)
        end
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.tgfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end