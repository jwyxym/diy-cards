-- 化龙
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--to hand(self)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
function s.costfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.costfilter4,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttribute(),tp)
end
function s.costfilter2(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.costfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttribute(),tp)
end
function s.costfilter3(c,att,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:GetAttribute()==att
end
function s.costfilter4(c,att,tp)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:GetAttribute()==att
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) or Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	local att=g1:GetFirst():GetAttribute()
	if g1:GetFirst():GetRace()==RACE_WYRM then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.costfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst(),att,tp)
		g1:Merge(g2)
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
		local atk=g1:GetSum(Card.GetPreviousAttackOnField)
		e:SetLabel(atk)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.costfilter4,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst(),att,tp)
		g1:Merge(g2)
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
		local atk=g1:GetSum(Card.GetPreviousAttackOnField)
		e:SetLabel(atk)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe91) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sc:RegisterEffect(e1)
	end
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsControler(tp) and ec:IsType(TYPE_NORMAL)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
