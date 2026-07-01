--墨染乐章 浮生
function c21301003.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,21301003)
	e1:SetCost(c21301003.hspcost)
	e1:SetTarget(c21301003.hsptg)
	e1:SetOperation(c21301003.hspop)
	c:RegisterEffect(e1)   
	--to grave 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21301004)
	e1:SetTarget(c21301003.tgtg)
	e1:SetOperation(c21301003.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)  
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE) 
	c:RegisterEffect(e2)  
	c21301003.remove_effect=e2	
end
function c21301003.ctfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemoveAsCost() and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsSetCard(0x682))
end
function c21301003.hspcost(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c21301003.ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21301003.ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c21301003.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c21301003.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end 
function c21301003.tgfilter(c)
	return c:IsSetCard(0x682) and c:IsAbleToGrave() 
end
function c21301003.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301003.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c21301003.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c21301003.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT) 
	end
end




