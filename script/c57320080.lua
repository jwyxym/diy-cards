--天剑深渊
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.costcheck(c,e,tp,ec)
	return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ec)
    	or Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
        or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.costfilter(c,e,tp,ec)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost() and s.costcheck(c,e,tp,ec)
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return aux.IsCodeListed(c,id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return aux.IsCodeListed(c,id) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local b1=Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
    	and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
    local b2=Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
    local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    	and (Duel.GetFlagEffect(tp,id+o*2)==0 or not e:IsCostChecked())
	if chk==0 then return (b1 or b2 or b3) end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
    e:SetLabel(op)
	if op==1 then
    	if e:IsCostChecked() then
        	e:SetCategory(CATEGORY_DESTROY)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
    elseif op==2 then
    	if e:IsCostChecked() then
        	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
    elseif op==3 then
    	if e:IsCostChecked() then
        	e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
            e:SetProperty(0)
            Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
        end
    	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
    	local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end    
    elseif op==2 then
    	local sc=Duel.GetFirstTarget()
		if sc:IsRelateToEffect(e) then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end    
    elseif op==3 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end    
    end
end