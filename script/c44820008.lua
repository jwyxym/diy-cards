--圣浊的进军
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--回收
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o*1000)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)    
end
function s.thfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.penfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
        if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 
        	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.penfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local pc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.penfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
			if pc then
				Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
        end
	end
end
function s.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:IsSetCard(0x6ce1) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.cfilter(c,g)
	return c:IsAbleToDeck() and g:IsExists(Card.IsAbleToHand,1,c)
end
function s.fselect(g,e,tp)
	return g:IsExists(s.cfilter,1,nil,g)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	local sg=g:Filter(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
    Duel.HintSelection(Group.FromCards(sc))
	if Duel.SendtoDeck(sc,nil,2,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		g:RemoveCard(sc)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
		end
	end
end