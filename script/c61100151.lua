--孱弱巫咒
-- 61100151（魔法卡）
-- ①：对方基本分比自己少的场合，把自己基本分支付到和对方基本分相同为止才能发动。选对方场上1张表侧表示的卡效果无效化（每支付1000基本分可以再选1张卡）。那张卡是怪兽的场合，再让那张卡攻击力·守备力变成0。
function c61100151.initial_effect(c)
	-- ①效果：魔法卡激活
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61100151,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE) -- 魔法卡激活类型
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,61100151+EFFECT_COUNT_CODE_OATH) -- 1回合1次（或根据需求调整）
	e1:SetCost(c61100151.cost) -- 代价：支付LP至与对方同等
	e1:SetTarget(c61100151.tg) -- 目标选择
	e1:SetOperation(c61100151.op) -- 效果执行
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_DISABLED)
	e3:SetRange(0xff)
	e3:SetCondition(c61100151.discon2)
	e3:SetOperation(c61100151.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAIN_NEGATED)
	c:RegisterEffect(e4) 
end
function c61100151.discon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==re:GetHandler()
end
function c61100151.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(24,0,aux.Stringid(61100151,7))
end

function c61100151.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local lp_self=Duel.GetLP(tp)
		local lp_opp=Duel.GetLP(1-tp)
		return  Duel.CheckLPCost(tp,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))) -- 
	end
	local pay=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
	Duel.PayLPCost(tp, pay)
	Duel.Hint(24,0,aux.Stringid(61100151,5))
	e:SetLabel(pay) -- 记录支付总量，用于计算可选卡数量
end

-- ①目标：选择对方场上表侧表示的卡（数量=支付总量÷1000，至少1张）
function c61100151.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	local pay=e:GetLabel()
	local max_count=math.floor(pay / 1000)
	max_count=math.max(max_count+1)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	e:SetLabel(max_count) 
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
end
end

-- ①操作：无效选中卡的效果，怪兽额外降攻
function c61100151.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local max_count=e:GetLabel()
	-- 选择目标（1~max_count张）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,max_count,nil)
	Duel.Hint(24,0,aux.Stringid(61100151,6))
	if #g==0 then return end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECTS)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_MONSTER) then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_SET_ATTACK_FINAL)
			e4:SetValue(0)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
			local e5=e4:Clone()
			e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e5)
end
	end
end
