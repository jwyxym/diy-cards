--生命之海的蔓延
function c51900208.initial_effect(c)
	c:EnableCounterPermit(0x1515) 
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(c51900208.ctop)
	c:RegisterEffect(e1)  
	--remove token
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)  
	e2:SetCode(EVENT_SUMMON_SUCCESS) 
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)  
	e2:SetTarget(c51900208.tktg)
	e2:SetOperation(c51900208.tkop)
	c:RegisterEffect(e2)  
	local e3=e2:Clone() 
	e3:SetCode(EVENT_SPSUMMON_SUCCESS) 
	c:RegisterEffect(e3) 
	--search
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,11900208)
	e3:SetTarget(c51900208.thtg)
	e3:SetOperation(c51900208.thop)
	c:RegisterEffect(e3)
end
function c51900208.cfilter(c,tp)
	return c:IsCode(51900202)
end
function c51900208.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c51900208.cfilter,1,nil,1-tp) then
		e:GetHandler():AddCounter(0x1515,1)
	end
end 
function c51900208.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) and e:GetHandler():GetFlagEffect(51900208)==0 end 
	e:GetHandler():RegisterFlagEffect(51900208,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1) 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c51900208.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil) 
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==0 then return end 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,51900202)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then 
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_CHANGE_RACE) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(RACE_DRAGON) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		token:RegisterEffect(e1)
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_NONTUNER) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(function(e,c)
		return e:GetHandler():IsControler(c:GetControler()) end) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		token:RegisterEffect(e1)
	end 
	Duel.SpecialSummonComplete()
end
function c51900208.thfilter(c)
	return c:IsSetCard(0x515) and not c:IsCode(51900208) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c51900208.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c51900208.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function c51900208.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c51900208.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


