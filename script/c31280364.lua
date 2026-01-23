--重返的奏绝
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
    end    
end    
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	local dtp=tc:GetPreviousControler()
    	if tc:IsSetCard(0x3ca1) and tc:IsReason(REASON_BATTLE+REASON_EFFECT) and e:GetHandler():GetOwner()==dtp then
			Duel.RegisterFlagEffect(dtp,id,0,0,0)           	
        end    
	end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ca1) and c:GetOriginalType()&TYPE_MONSTER~=0
end
function s.thfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0x3ca1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
    	and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.bhfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.fselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x3ca1) and g:GetClassCount(Card.GetCode)==g:GetCount()
end
function s.filter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if g:GetFirst():IsLocation(LOCATION_HAND) and tc:IsRelateToEffect(e) then
    		Duel.BreakEffect()           
            if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetFlagEffect(tp,id)>=10 then
            	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.bhfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
                if cg:CheckSubGroup(s.fselect,2,2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                	Duel.BreakEffect()
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                    local sg=cg:SelectSubGroup(tp,s.fselect,false,2,2)
                    if not sg then return end
                    Duel.SendtoHand(sg,nil,2,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,sg)
                    local og=Duel.GetOperatedGroup()
                    if og:FilterCount(s.filter,nil,tp)==2 then
                    	Duel.BreakEffect()
                        Duel.ShuffleHand(tp)
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                        local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
                        Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
                    end
                end
            end
    	end
    end
end