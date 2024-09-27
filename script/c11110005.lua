--杜丝娜瑞尔的圣妖·梅杜莎
local m=11110005
local cm=_G["c"..m]
function c11110005.initial_effect(c)
	 aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),cm.filter,1)
	c:EnableReviveLimit()
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.spstg)
	e1:SetOperation(cm.spsop)
	c:RegisterEffect(e1)
local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLED)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCondition(cm.descon)
		e3:SetTarget(cm.tgtg)
		e3:SetOperation(cm.tgop)
		c:RegisterEffect(e3)
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetHandler()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	return d:IsControler(1-tp)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cm.filter(c) 
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK)
end 
function cm.filter2(c,e,tp) 
	return c:IsSetCard(0xa61) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end 
function cm.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function cm.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	local gc=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(gc,0,tp,tp,false,false,POS_FACEUP)
   

end
function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsAbleToGrave() and bc:IsAbleToGrave() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,0)

end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()  
		Duel.SendtoGrave(c,REASON_EFFECT)
		Duel.SendtoGrave(bc,REASON_EFFECT)
	local g=Duel.SelectMatchingCard(tp,Card.IsLevelBelow,tp,LOCATION_GRAVE,0,1,1,nil,6)
	local gc=Duel.SelectMatchingCard(1-tp,Card.IsLevelBelow,tp,0,LOCATION_GRAVE,1,1,nil,6)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummon(gc,0,1-tp,1-tp,false,false,POS_FACEUP)

end














