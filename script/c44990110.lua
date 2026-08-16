--守护巨龙之拥
local s,id=GetID()
function s.initial_effect(c)
	-- 有「伊瑟拉」的卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 效果：无效效果 + 抽卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)

	-- ② 效果：结束阶段墓地回收
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end

-- 检查场上是否有表侧「伊瑟拉」怪兽（卡名）
function s.IsYseraOnField(tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
	end,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 条件：场上有「伊瑟拉」且未发动过①效果（标志 id+100）
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return s.IsYseraOnField(tp) and Duel.GetFlagEffect(tp,id+100)==0
end

-- ① 目标：选择场上最多2张表侧卡为对象（排除自身）
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then
		return Duel.IsExistingTarget(function(c)
			return c:IsFaceup() and c~=e:GetHandler()
		end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local ct=Duel.GetMatchingGroupCount(function(c)
		return c:IsFaceup() and c~=e:GetHandler()
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local max=math.min(ct,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,function(c)
		return c:IsFaceup() and c~=e:GetHandler()
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end

-- ① 操作：无效目标卡的效果，抽1张，设置一回合一次标志
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if g then
		for tc in aux.Next(g) do
			if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end

-- ② 条件：自己结束阶段，场上有「伊瑟拉」，且未发动过②效果（标志 id+200）
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and s.IsYseraOnField(tp) and Duel.GetFlagEffect(tp,id+200)==0
end

-- ② 目标
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- ② 操作：回收并设置标志
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end