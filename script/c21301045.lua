--墨染乐章 莫逆
function c21301045.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c21301045.mfilter,c21301045.xyzcheck,3,3)
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--sp 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,21301045)
	e1:SetTarget(c21301045.sptg)
	e1:SetOperation(c21301045.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)  
	c21301045.remove_effect=e2  
	--xx
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1) 
	e2:SetCost(c21301045.xxcost)
	e2:SetTarget(c21301045.xxtg)
	e2:SetOperation(c21301045.xxop)
	c:RegisterEffect(e2)
end
function c21301045.mfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x682) 
end
function c21301045.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
function c21301045.spfilter(c,e,tp)
	return c:IsCode(21301003,21301012) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function c21301045.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301045.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c21301045.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c21301045.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
	end
end
function c21301045.xctfil(c) 
	return c:IsSetCard(0x682) and c:IsAbleToRemoveAsCost() 
end 
function c21301045.xxcost(e,tp,eg,ep,ev,re,r,rp,chk)  
	local b1=e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(c21301045.xctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end 
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(21301045,1)},{b2,aux.Stringid(21301045,2)})
	if op==1 then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
	if op==2 then
		local g=Duel.SelectMatchingCard(tp,c21301045.xctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
		Duel.Remove(g,POS_FACEUP,REASON_COST) 
	end
end 
function c21301045.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
end
function c21301045.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()  
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e1:SetCode(EVENT_CHAIN_SOLVING) 
	e1:SetCondition(c21301045.xdiscon) 
	e1:SetOperation(c21301045.xdisop)  
	e1:SetReset(RESET_PHASE+PHASE_END) 
	Duel.RegisterEffect(e1,tp)   
end 
function c21301045.xdiscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainDisablable(ev) and rp==1-tp and Duel.GetFlagEffect(tp,21301045)==0
end 
function c21301045.xdisop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsChainDisablable(ev) and rp==1-tp and Duel.SelectYesNo(tp,aux.Stringid(21301045,0)) then 
		Duel.Hint(HINT_CARD,0,21301045)
		Duel.RegisterFlagEffect(tp,21301045,RESET_PHASE+PHASE_END,0,1)
		if Duel.NegateEffect(ev)~=0 and re:GetHandler():IsRelateToEffect(re) then 
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end 
	end 
end 




