--创世之女-提亚马特
function c51900203.initial_effect(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) end)
	c:RegisterEffect(e1)
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetCountLimit(1,51900203)
	e1:SetCost(c51900203.spcost)
	e1:SetTarget(c51900203.sptg)
	e1:SetOperation(c51900203.spop)
	c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,11900203)
	e2:SetCost(c51900203.tkcost)
	e2:SetTarget(c51900203.tktg)
	e2:SetOperation(c51900203.tkop)
	c:RegisterEffect(e2) 
	--search
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_QUICK_O) 
	e3:SetCode(EVENT_FREE_CHAIN) 
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,21900203) 
	e3:SetCondition(function(e) 
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end)
	e3:SetTarget(c51900203.srtg)
	e3:SetOperation(c51900203.srop)
	c:RegisterEffect(e3) 
	--
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_ATTACK) 
	e5:SetRange(LOCATION_MZONE)  
	c:RegisterEffect(e5)
	--battle target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.imval1)
	c:RegisterEffect(e5)
end
function c51900203.rlgck(g,tp) 
	return Duel.GetMZoneCount(tp,g)>0 and 
		  (aux.drccheck(g) or aux.dabcheck(g))  
end 
function c51900203.spcost(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(c51900203.rlgck,2,2,tp) end 
	local rg=g:SelectSubGroup(tp,c51900203.rlgck,false,2,2,tp) 
	Duel.Release(rg,REASON_COST) 
end
function c51900203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c51900203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c51900203.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end 
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c51900203.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,RACE_DRAGON,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c51900203.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
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
function c51900203.srfilter(c)
	return c:IsSetCard(0x515) and not c:IsCode(51900203) and c:IsAbleToHand() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function c51900203.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c51900203.srfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c51900203.srop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c51900203.srfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if tg1 and Duel.SendtoHand(tg1,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,tg1)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tg2=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		if #tg2>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(tg2,REASON_EFFECT)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsLevelAbove(1) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end





