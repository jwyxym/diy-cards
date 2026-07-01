--轰然倒塌
local s,id,o=GetID()
function s.initial_effect(c)
	--① 通常魔法
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,0,1,nil,TYPE_FIELD)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,0,1,nil,TYPE_FIELD)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
	end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_FZONE,0,nil)
	local bg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_FZONE,nil)
	if #ag>0 then
	ca=Duel.Destroy(ag,REASON_EFFECT)
	end
	if #ag>0 then
	cb=Duel.Destroy(bg,REASON_EFFECT)
	end
	if ca>0 then
		local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
		for fc1 in aux.Next(g1) do
			Duel.ChangePosition(fc1,POS_FACEDOWN)
		end
	end
	if cb>0 then
		local g2=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_ONFIELD,0,nil)
		for fc2 in aux.Next(g2) do
			Duel.ChangePosition(fc2,POS_FACEDOWN)
		end
	end
end
