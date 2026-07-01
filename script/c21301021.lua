--墨染乐章 茫然
function c21301021.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21301021+EFFECT_COUNT_CODE_OATH) 
	e1:SetTarget(c21301021.target)
	e1:SetOperation(c21301021.activate)
	c:RegisterEffect(e1)
	--rme
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21301022)
	e2:SetTarget(c21301021.rmetg)
	e2:SetOperation(c21301021.rmeop)
	c:RegisterEffect(e2)
	c21301021.remove_effect=e2  
end 
function c21301021.filter(c,e,tp)
	return c:IsSetCard(0x682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21301021.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21301021.filter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
function c21301021.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c21301021.filter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then 
		if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x682) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21301021,0)) then  
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst() 
			local og=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil) 
			Duel.Overlay(tc,og)
		end 
	end
end
function c21301021.rmetg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return true end 
end
function c21301021.rmeop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	--control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD) 
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET) 
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) 
	return c:IsSetCard(0x682) end) 
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END) 
	Duel.RegisterEffect(e1,tp)
end 


