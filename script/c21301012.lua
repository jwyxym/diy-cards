--墨染乐章 浸心
function c21301012.initial_effect(c)
	--to hand 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21301012)
	e1:SetTarget(c21301012.thtg)
	e1:SetOperation(c21301012.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)  
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)  
	c:RegisterEffect(e2)	
	c21301012.remove_effect=e2	 
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget() end)
	e2:SetValue(1)
	c:RegisterEffect(e2) 
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21301013) 
	e2:SetCondition(function(e) 
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 end) 
	e2:SetCost(c21301012.atkcost)
	e2:SetTarget(c21301012.atktg)
	e2:SetOperation(c21301012.atkop)
	c:RegisterEffect(e2) 
end
function c21301012.thfilter(c)
	return c:IsSetCard(0x682) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() 
end
function c21301012.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301012.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c21301012.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c21301012.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,g)  
	end
end
function c21301012.ctfil(c) 
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x682)   
end 
function c21301012.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301012.ctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end  
	local g=Duel.SelectMatchingCard(tp,c21301012.ctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c21301012.atkfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x682) 
end 
function c21301012.atktg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c21301012.atkfil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:GetCount()>0 end   
end
function c21301012.atkop(e,tp,eg,ep,ev,re,r,rp)   
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c21301012.atkfil,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then 
		local tc=g:GetFirst() 
		while tc do 
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_UPDATE_ATTACK) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(500) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		tc:RegisterEffect(e1) 
		tc=g:GetNext() 
		end 
	end 
end 

