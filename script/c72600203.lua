--祭神科尔努诺斯
function c72600203.initial_effect(c) 
	aux.AddCodeList(c,72600200) 
	--Synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--token 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e1:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e1:SetProperty(EFFECT_FLAG_DELAY) 
	e1:SetCountLimit(1,72600203) 
	e1:SetCondition(c72600203.tkcon)
	e1:SetTarget(c72600203.tktg)
	e1:SetOperation(c72600203.tkop) 
	c:RegisterEffect(e1) 
	--des 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c72600203.descon) 
	e2:SetCost(c72600203.descost)
	e2:SetTarget(c72600203.destg)
	e2:SetOperation(c72600203.desop)
	c:RegisterEffect(e2) 
	--to hand 
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP) 
	e3:SetCountLimit(1,12600203)
	e3:SetTarget(c72600203.thtg)
	e3:SetOperation(c72600203.thop)
	c:RegisterEffect(e3)
end  
function c72600203.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetHandler():GetMaterial():IsExists(Card.IsType,1,nil,TYPE_TOKEN)  
end 
function c72600203.tktg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,72600209,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_DARK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function c72600203.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,72600209,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_DARK) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,72600209)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) 
		end
		Duel.SpecialSummonComplete()
	end
end
function c72600203.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)  
end
function c72600203.descost(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.CheckReleaseGroup(REASON_COST,tp,function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) and c:IsReleasable() end,1,nil) end
	local g=Duel.SelectReleaseGroup(REASON_COST,tp,function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) and c:IsReleasable() end,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c72600203.destg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local c=e:GetHandler() 
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) end  
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0) 
end
function c72600203.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		Duel.Destroy(bc,REASON_EFFECT) 
	end
end
function c72600203.thfilter(c)
	return (aux.IsCodeListed(c,72600200) or c:IsCode(72600200)) and c:IsAbleToHand()
end
function c72600203.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c72600203.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c72600203.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c72600203.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end



