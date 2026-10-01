--盗贼浮世绘·终幕
function c21363704.initial_effect(c) 
	aux.AddCodeList(c,21363700)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,21363704+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21363704.condition)
	e1:SetTarget(c21363704.target)
	e1:SetOperation(c21363704.activate)
	c:RegisterEffect(e1)
	--to deck 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F) 
	e2:SetCode(EVENT_REMOVE) 
	e2:SetTarget(c21363704.tdtg)
	e2:SetOperation(c21363704.tdop)
	c:RegisterEffect(e2)
end
function c21363704.condition(e,tp,eg,ep,ev,re,r,rp)  
	return Duel.IsChainDisablable(ev)
end
function c21363704.rmfil(c) 
	return c:IsFaceup() and c:IsCode(21363700) and c:IsAbleToRemove(POS_FACEDOWN)
end 
function c21363704.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363704.rmfil,tp,LOCATION_MZONE,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end 
end
function c21363704.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local rg=Duel.SelectMatchingCard(tp,c21363704.rmfil,tp,LOCATION_MZONE,0,1,1,nil) 
	if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)~=0 and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT) 
	end 
end
function c21363704.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c21363704.tdop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) then 
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT) 
	end 
end 




