--地平线的边界之龙 梅柳齐娜
function c76200505.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(function(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) end),1)
	c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e) 
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(function(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) end,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	return g:GetSum(Card.GetAttack) end)
	c:RegisterEffect(e1) 
	--chain attack
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING) 
	e2:SetCondition(c76200505.atkcon)
	e2:SetCost(c76200505.atkcost)
	e2:SetTarget(c76200505.atktg)
	e2:SetOperation(c76200505.atkop)
	c:RegisterEffect(e2) 
	--reg
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c76200505.regop)
	c:RegisterEffect(e3) 
end
function c76200505.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetAttacker()==c and aux.bdgcon(e,tp,eg,ep,ev,re,r,rp) 
end
function c76200505.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost() end,tp,LOCATION_GRAVE,0,1,nil) end  
	local g=Duel.SelectMatchingCard(tp,function(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost() end,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c76200505.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() end 
end
function c76200505.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if c:IsRelateToBattle() and c:IsFaceup() then 
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e2)
		Duel.ChainAttack(c)
	end
end
function c76200505.regop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND) 
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD) 
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1) 
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c76200505.tecon)
	e1:SetTarget(c76200505.tetg)
	e1:SetOperation(c76200505.teop)
	c:RegisterEffect(e1)
end
function c76200505.tecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()  
end 
function c76200505.tetg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0) 
end
function c76200505.thfil(c)
	return (c:IsCode(76200500) or aux.IsCodeListed(c,76200500)) and c:IsAbleToHand()
end
function c76200505.teop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) and Duel.IsExistingMatchingCard(c76200505.thfil,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(76200505,0)) then
		local g=Duel.SelectMatchingCard(tp,c76200505.thfil,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,g) 
	end
end


