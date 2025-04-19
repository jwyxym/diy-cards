--深池之锋 “校官”
function c31280308.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--超量召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xca3),4,2,nil,nil,99)
	c:EnableReviveLimit()
	--检索召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31280308)
	e1:SetCondition(c31280308.condition)
	e1:SetTarget(c31280308.target)
	e1:SetOperation(c31280308.operation)
	c:RegisterEffect(e1)
	--送去墓地
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31280308.condition1)
	e2:SetCost(c31280308.cost1)
    e2:SetTarget(c31280308.target1)
	e2:SetOperation(c31280308.operation1)
	c:RegisterEffect(e2)
end    
function c31280308.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) or c:IsSpecialSummonSetCard(0xca3)
end
function c31280308.filter(c)
	return c:IsSetCard(0xca3) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function c31280308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280308.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280308.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0xca3)
end
function c31280308.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c31280308.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        if Duel.GetMatchingGroupCount(c31280308.sumfilter,tp,LOCATION_HAND,0,nil)>0
			and c:CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT)
			and Duel.SelectYesNo(tp,aux.Stringid(31280308,0)) then
        	Duel.BreakEffect()
			if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0 then
				local eg=Duel.SelectMatchingCard(tp,c31280308.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
				if #eg>0 then
					Duel.BreakEffect()
					Duel.Summon(tp,eg:GetFirst(),true,nil)
                end
            end
        end           
	end
end
function c31280308.condition1(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsFaceup() and a:IsSetCard(0xca3) then
		e:SetLabelObject(d)
		return true
	else return false end
end
function c31280308.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c31280308.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	if chk==0 then return d end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
function c31280308.operation1(e,tp,eg,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	if d and d:IsControler(1-tp) and d:IsRelateToBattle() then
		Duel.SendtoGrave(d,REASON_EFFECT)
	end
end