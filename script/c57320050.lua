--惨烈的剑王
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57320080)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
    e2:SetCondition(aux.exccon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.costfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return true end
    e:SetLabel(0)
    if b and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
        e:SetLabel(100)
    end    
end
function s.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup()
end
function s.thfilter(c,tp)
	return aux.IsCodeListed(c,57320080) and c:IsAbleToHand()
    	and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function s.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
    	and Duel.IsPlayerCanDraw(tp,1)
    local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	if chk==0 then return (b1 or b2) end    
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
    	and Duel.IsPlayerCanDraw(tp,1)
    local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
    local b3=e:GetLabel()==100 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and b1 and b2
    if not b1 and not b2 then return end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
    local effect=false
    if op~=2 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,6,nil)
        if g:GetCount()>0 then
        	Duel.HintSelection(g)
            local res=false
            local check=false
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=g:Select(tp,1,g:GetCount(),nil)
            if tg:GetCount()>0 and Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)~=0 then
                g:Sub(tg)
                local gc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
                if gc>0 then
                    res=true
                end
            end                
            if g:GetCount()>0 then
            	local dg=g:Filter(Card.IsAbleToDeck,nil)
            	if dg:GetCount()>0 and Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)~=0 then
                	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
                    if oc>0 then
                    	check=true
                    end                
                end
            end
            if res then
            	if check then Duel.ShuffleDeck(tp) end
                Duel.BreakEffect()
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
        effect=true
    end
    if op~=1 then
    	if effect then Duel.BreakEffect() end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if hg:GetCount()>0 then 
        	Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
        end
    end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and aux.IsCodeListed(c,57320080) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc~=c and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,c)
    g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    sg:AddCard(c)    
	if sg:GetCount()>0 then
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	end
end