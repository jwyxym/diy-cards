--魔神重塑 黑暗洪流
function c21362814.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362814)
	e1:SetTarget(c21362814.target)
	e1:SetOperation(c21362814.activate)
	c:RegisterEffect(e1)
	--pendulum set
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362814)
	e2:SetCost(c21362814.pccost) 
	e2:SetTarget(c21362814.pctg)
	e2:SetOperation(c21362814.pcop)
	c:RegisterEffect(e2)
end
function c21362814.rmfil(c) 
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0xba38) 
end 
function c21362814.rmgck(g,e,tp) 
	return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,g:GetCount(),nil) 
end 
function c21362814.target(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c21362814.rmfil,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c21362814.rmgck,1,99,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,c21362814.rmgck,false,1,99,e,tp) 
	local x=Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(x)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,x,1-tp,LOCATION_ONFIELD)
end
function c21362814.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local x=e:GetLabel() 
	local g=Duel.SelectMatchingCard(1-tp,nil,tp,0,LOCATION_ONFIELD,x,x,nil)
	if g:GetCount()>0 then 
		Duel.SendtoDeck(g,nil,2,REASON_RULE) 
	end
end 
function c21362814.pccost(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end 
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function c21362814.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362814.pctg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362814.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil) end
end
function c21362814.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()  
	if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362814.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil) then  
		local tc=Duel.SelectMatchingCard(tp,c21362814.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA+LOCATION_REMOVED,0,1,1,nil):GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)  
	end
end

