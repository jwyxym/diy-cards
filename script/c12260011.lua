--山水-挥墨
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)
	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ptg)
	e2:SetOperation(s.pop)
	c:RegisterEffect(e2)
end

function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount() 
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetTurnID()==Duel.GetTurnCount() then
		return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
	end
	return true
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
			or Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetTurnID()==Duel.GetTurnCount() then
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=g:Select(tp,1,1,nil)
			Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
		end
	end
	
	local tp1=tp
	local tp2=1-tp
	
	local d1=Duel.SelectYesNo(tp1,aux.Stringid(id,2))
	local d2=Duel.SelectYesNo(tp2,aux.Stringid(id,2))
	
	if d1 then
		Duel.Hint(HINT_SELECTMSG,tp1,HINTMSG_POSCHANGE)
		local g1=Duel.SelectMatchingCard(tp1,Card.IsCanTurnSet,tp1,LOCATION_MZONE,0,1,99,nil)
		if #g1>0 then
			Duel.ChangePosition(g1,POS_FACEDOWN_DEFENSE)
		end
	end
	
	if d2 then
		Duel.Hint(HINT_SELECTMSG,tp2,HINTMSG_POSCHANGE)
		local g2=Duel.SelectMatchingCard(tp2,Card.IsCanTurnSet,tp2,LOCATION_MZONE,0,1,99,nil)
		if #g2>0 then
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end
	end
	
	local opp=tp2
	local g=Duel.GetMatchingGroup(Card.IsFaceup,opp,LOCATION_ONFIELD,0,nil)
	local ct=#g
	if ct>0 then
		Duel.Damage(opp,ct*500,REASON_EFFECT)
	end
end

function s.filter(c)
	return c:IsFaceup() or c:IsFacedown()
end

function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local self_count=Duel.GetMatchingGroupCount(Card.IsCanBeEffectTarget,tp,LOCATION_MZONE,0,nil,e)
		return self_count>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
	end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,2,nil)
	if #sg==1 then
		local g2=Duel.SelectMatchingCard(tp,Card.IsCanBeEffectTarget,tp,0,LOCATION_MZONE,1,1,nil,e)
		sg:Merge(g2)
	end
	Duel.SetTargetCard(sg)
end

function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg==0 then return end
	for tc in aux.Next(sg) do
		if tc:IsFacedown() then
			local sel=0
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
			else
				sel=0
			end
			if sel==0 then
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end