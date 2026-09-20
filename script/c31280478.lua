--魔焰烈牙
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--盖放回合发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetValue(id)
	e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.actcon)
	e2:SetCost(s.actcost)
	c:RegisterEffect(e2)
end
function s.fselect(g,zg,ec)
	if g:IsExists(Card.IsOnField,1,nil) then
		return g:GetCount()<=zg:GetCount() and g:IsContains(ec)
    else
    	return g:GetCount()<=zg:GetCount() 
    end
end
function s.cfilter(c) 
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.tgfilter(c,tp,ec,con)
	if c:IsLocation(LOCATION_HAND) then return c~=ec end
	if con and Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,ec)>0 then
		return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND) or c==ec)
    else
    	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
    end
end    
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND
    local con=Duel.GetTurnPlayer()==tp
    if con then loc=LOCATION_HAND+LOCATION_ONFIELD end
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,loc,0,nil,tp,c,con)
    local zg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)    
	local b1=Duel.IsPlayerCanDiscardDeck(tp,2)
    local b2=g:CheckSubGroup(s.fselect,1,2,zg,c) and zg:GetCount()>0
	if chk==0 then return (b1 or b2) end
end
function s.bhfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND
    local con=Duel.GetTurnPlayer()==tp
    if con then loc=LOCATION_HAND+LOCATION_ONFIELD end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,loc,0,nil,tp,c,con)
    local zg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local b1=Duel.IsPlayerCanDiscardDeck(tp,2)
    local b2=g:CheckSubGroup(s.fselect,1,2,zg,c) and zg:GetCount()>0
    if not b1 and not b2 then return end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})        
	if op==1 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		local g=Duel.GetOperatedGroup():Filter(aux.NecroValleyFilter(s.bhfilter),nil)
        if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
            	Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    elseif op==2 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=g:SelectSubGroup(tp,s.fselect,false,1,2,zg,c)
        if tg and tg:GetCount()>0 and Duel.SendtoGrave(tg,REASON_EFFECT)~=0 then
        	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
        	if oc<=0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,oc,oc,nil)
			if dg:GetCount()>0 then
				Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
			end
        end
    end
end
function s.costfilter(c,tp,ec)
	local loc=LOCATION_HAND
    local con=Duel.GetTurnPlayer()==tp
    if con then loc=LOCATION_HAND+LOCATION_ONFIELD end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,loc,0,c,tp,ec,con)
    local zg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local b1=Duel.IsPlayerCanDiscardDeck(tp,2)
    local b2=g:CheckSubGroup(s.fselect,1,2,zg,ec) and zg:GetCount()>0
	return aux.IsCodeListed(c,31280102) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
    	and (b1 or b2)
end
function s.actcon(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp,c)
	Duel.SendtoGrave(g,REASON_COST)
end