--杜丝娜瑞尔·先魔
local m=11110003
local cm=_G["c"..m]
function c11110003.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCost(cm.cost2)
	e2:SetTarget(cm.tg1)
	e2:SetCountLimit(1,m+1000)
	e2:SetOperation(cm.op1)
	c:RegisterEffect(e2)
end
function cm.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end  
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local aa=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	if aa:GetCount()>0 then
		Duel.BreakEffect()
		local tc=aa:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

end
function cm.filter(c) 
	return c:IsSetCard(0xa61) and c:IsType(TYPE_CONTINUOUS) and (c:IsType(TYPE_TRAP) or c:IsType(TYPE_SPELL))
end 
function cm.filter2(c) 
	return c:IsRace(RACE_REPTILE) 
end 
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,e:GetHandler(),RACE_REPTILE) end  
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local aa=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND,0,1,1,e:GetHandler(),RACE_REPTILE)
	if Duel.SendtoGrave(aa,REASON_EFFECT)~=0 and Card.IsSetCard(aa:GetFirst(),0xa61) then
	local bb=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,RACE_REPTILE)
	Duel.SendtoHand(bb,tp,REASON_EFFECT)
end
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.splimit(e,c)
return not (c:IsRace(RACE_REPTILE))
end 








