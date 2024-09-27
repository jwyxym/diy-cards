--永瞬华彩·渊月幽冥
function c11127180.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT+RACE_INSECT),2,true)	
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST):SetValue(SUMMON_TYPE_FUSION)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xa62) end) 
	c:RegisterEffect(e1) 
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,11127180) 
	e1:SetCondition(function(e) 
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetTarget(c11127180.gsptg)
	e1:SetOperation(c11127180.gspop)
	c:RegisterEffect(e1) 
	--SpecialSummon
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_REMOVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY)  
	e2:SetCountLimit(1,21127180) 
	e2:SetTarget(c11127180.sptg)
	e2:SetOperation(c11127180.spop)
	c:RegisterEffect(e2) 
end
function c11127180.gspfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function c11127180.gsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c11127180.gspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c11127180.gspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c11127180.gspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end 
function c11127180.rmfil(c) 
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsAbleToRemove() 
end 
function c11127180.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c11127180.rmfil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(11127180,0)) then
		Duel.BreakEffect() 
		local g=Duel.SelectMatchingCard(tp,c11127180.rmfil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil) 
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT) 
	end 
end
function c11127180.spfilter(c,e,tp)
	return c:IsSetCard(0xa62) and not c:IsCode(11127180) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup() 
end 
function c11127180.spgck(g,tp) 
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount() and aux.dncheck(g) 
end 
function c11127180.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c11127180.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(c11127180.spgck,2,2,tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_REMOVED)
end
function c11127180.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c11127180.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp) 
	if g:CheckSubGroup(c11127180.spgck,2,2,tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then  
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON) 
		local sg=g:SelectSubGroup(tp,c11127180.spgck,false,2,2,tp)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)  
	end   
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0) 
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end



