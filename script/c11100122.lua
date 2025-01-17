--333号-超级偶像计划
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,11100110)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--sp
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--ATK & DEF
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCost(s.atkcost)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3) --Here
end
function s.cfilter1(c,tp)
	return c:IsCode(11100110)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return b1 end
	if b1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_REPTILE) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) -- Here
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and g:GetFirst():IsFaceup() then -- Here
		local tc=g:GetFirst() --Here
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_CODE)
		e5:SetValue(11100110)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e4:SetValue(s.fuslimit)
		tc:RegisterEffect(e4)
		local e7=e3:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e7)
		local e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
	end
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.cfilter(c)
	return c:IsCode(11100110) and c:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if tg:GetCount()>0 then
		local sc=tg:GetFirst()
		while sc do
			local c=e:GetHandler() --Here
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESET_PHASE+RESETS_STANDARD+PHASE_END,2)
			e1:SetValue(3000)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESET_PHASE+RESETS_STANDARD+PHASE_END,2)
			sc:RegisterEffect(e3)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESET_PHASE+RESETS_STANDARD+PHASE_END,2)
			sc:RegisterEffect(e4)
			sc=tg:GetNext()
		end
	end
end
