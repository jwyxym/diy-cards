--永瞬华彩·昏色哀歌
function c11127181.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,function(c) return c:IsFusionSetCard(0xa62) and c:IsFusionType(TYPE_MONSTER) end,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT+RACE_INSECT),1,1,true) 
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
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY) 
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11127181) 
	e1:SetCondition(c11127181.gspcon) 
	e1:SetTarget(c11127181.gsptg)
	e1:SetOperation(c11127181.gspop)
	c:RegisterEffect(e1)  
	--search
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_REMOVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY) 
	e2:SetCountLimit(1,21127181) 
	e2:SetTarget(c11127181.thtg)
	e2:SetOperation(c11127181.thop)
	c:RegisterEffect(e2) 
end
function c11127181.gckfil(c,tp) 
	return c:IsPreviousControler(tp) and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER)  
end 
function c11127181.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11127181.gckfil,1,nil,tp) 
end 
function c11127181.gspfilter(c,e,tp,eg)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not eg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function c11127181.gsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c11127181.gspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c11127181.gspfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c11127181.gspfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end 
function c11127181.rmfil(c) 
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsAbleToRemove() 
end 
function c11127181.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
	end 
end
function c11127181.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c11127181.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127181.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c11127181.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11127181.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end  
end






