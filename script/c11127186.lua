--瞬华仙植·悠游漂妖
function c11127186.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT+RACE_INSECT),2,2,c11127186.lcheck)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e1:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,11127186) 
	e1:SetCondition(function(e) 
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetCost(c11127186.rmcost)
	e1:SetTarget(c11127186.rmtg)
	e1:SetOperation(c11127186.rmop)
	c:RegisterEffect(e1) 
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE) 
	e2:SetCode(EFFECT_SET_BASE_ATTACK) 
	e2:SetRange(LOCATION_MZONE) 
	e2:SetValue(function(e) 
	local mg=e:GetHandler():GetMaterial() 
	return mg:GetSum(Card.GetBaseAttack) end) 
	c:RegisterEffect(e2) 
	--remove 
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION) 
	e3:SetRange(LOCATION_MZONE) 
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,21127186)   
	e3:SetTarget(c11127186.grmtg)
	e3:SetOperation(c11127186.grmop)
	c:RegisterEffect(e3) 
end
function c11127186.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xa62)
end
function c11127186.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c11127186.rmfilter(c)
	return c:IsSetCard(0xa62) and c:IsAbleToRemove()
end
function c11127186.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127186.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c11127186.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c11127186.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT) 
	end
end 
function c11127186.grmfil(c) 
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() 
end
function c11127186.grmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(tp) and c11127186.grmfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c11127186.grmfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectTarget(tp,c11127186.grmfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0) 
end 
function c11127186.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup() and c:IsSetCard(0xa62)   
end 
function c11127186.grmop(e,tp,eg,ep,ev,re,r,rp)  
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c11127186.spfil,tp,LOCATION_REMOVED,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(11127186,0)) then 
		Duel.BreakEffect() 
		local sg=Duel.SelectMatchingCard(tp,c11127186.spfil,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) 
	end 
end 







