--为了更美好的明天
local s,id=GetID()

function s.initial_effect(c)
	-- ① 选择表侧卡并根据类型处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(s.conditon)
	e2:SetCost(s.cost)
	e2:SetDescription(aux.Stringid(id,1))
	c:RegisterEffect(e2)
end

function s.conditon(e)
	return Duel.GetTurnPlayer() ~= e:GetHandlerPlayer()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler(),POS_FACEDOWN) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler(),POS_FACEDOWN)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end

function s.filter(c)
	return c:IsFaceup()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)

	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler()):GetFirst()
	if not tc or not tc:IsFaceup() then return end

	-- 魔法·陷阱 → 破坏
	if tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_TRAP) then
		Duel.Destroy(tc,REASON_EFFECT)

	-- 怪兽 → 效果无效
	elseif tc:IsType(TYPE_MONSTER) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

function s.chainlm(re,rp,tp)
	return not (re:GetHandler():IsType(TYPE_QUICKPLAY) and re:GetHandler():IsType(TYPE_SPELL))
end

