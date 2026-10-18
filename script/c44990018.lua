--假日拉法姆
local s,id=GetID()
function s.initial_effect(c)
	-- ① 手卡：场上有拉法姆怪兽的场合，进行这张卡的召唤（额外召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ② 召唤成功时：检索5星以上拉法姆怪兽，之后可以召唤1只拉法姆怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost2)              -- 自肃在cost注册
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

-- 场上拉法姆怪兽过滤
function s.lfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER)
end

-- ① 条件：场上有拉法姆怪兽 + 一回合一次
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
		and Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 目标：设置标志
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end

-- ① 操作：进行额外召唤
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Summon(tp,c,true,nil)       -- true 表示额外召唤，不消耗通常召唤次数
end

-- ② 条件：一回合一次
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+200)==0
end

-- ② cost：注册全回合自肃（即使效果被无效也适用）
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 注册通常召唤限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	-- 注册特殊召唤限制
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
	-- 设置一回合一次标志
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
end

-- 自肃限制函数
function s.sumlimit(e,c)
	return not c:IsSetCard(0x0cf0)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x0cf0)
end

-- ② 目标：检索5星以上拉法姆怪兽
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end

-- ② 检索过滤：5星以上拉法姆怪兽
function s.thfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsAbleToHand()
end

-- ② 操作：检索 + 可选额外召唤
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		-- 可选：从手卡/场上召唤1只拉法姆怪兽（额外召唤）
		local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			if sc then
				Duel.Summon(tp,sc,true,nil)   -- true 表示额外召唤
			end
		end
	end
end

-- ② 召唤过滤：拉法姆怪兽
function s.sumfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsSummonable(true,nil)
end