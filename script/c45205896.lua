--止战之殇
local s,id=GetID()
function s.initial_effect(c)
	-- ① 对方的回合才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	-- 从手卡发动：对方场上卡数量 > 自己场上卡数量
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

-- ① 条件：对方的回合
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

-- 从手卡发动条件：对方场上卡数量 > 自己场上卡数量
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0) > Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end

-- cost：把自己手卡1张卡交给对方
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoHand(g,1-tp,REASON_COST)
	end
end

-- ① 处理：跳过对方下个战斗阶段
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- ★ 注册跳过战斗阶段的效果（对对方生效）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(0,1)   -- 对方
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)  -- 经过1个对方回合的战斗阶段后解除
	Duel.RegisterEffect(e1,tp)
end

return s
