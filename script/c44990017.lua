--拉法姆的奋战
local s,id=GetID()
function s.initial_effect(c)
	-- ① 从卡组把1只拉法姆怪兽送去墓地，检索1只拉法姆怪兽，之后可以召唤1只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ② 把墓地的这张卡除外，从手卡召唤1只拉法姆怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)

	-- 全回合自肃计数器（召唤与特殊召唤）
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 自肃计数器过滤：只允许「拉法姆」怪兽
function s.counterfilter(c)
	return c:IsSetCard(0x0cf0)
end

-- 检查是否已违反自肃
function s.CheckBond(tp)
	return Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SPSUMMON)==0
end

-- 注册全回合自肃
function s.RegisterSelfBond(tp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
end

-- 通常召唤限制
function s.sumlimit(e,c)
	return not c:IsSetCard(0x0cf0)
end

-- 特殊召唤限制
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x0cf0)
end

-- ① 条件：①②共用一回合一次 + 未违反自肃
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0 and s.CheckBond(tp)
end

-- ① cost：从卡组把1只拉法姆怪兽送去墓地
function s.costfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

-- ① 目标：设置共用标志，注册自肃
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ① 检索过滤
function s.thfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- ① 操作：检索 + 可选召唤
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 检索1只拉法姆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	-- 可选召唤1只怪兽
	local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.Summon(tp,sc,true,nil)
		end
	end
end

-- ① 召唤过滤
function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

-- ② 条件：①②共用一回合一次 + 未违反自肃 + 主要阶段
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
		and s.CheckBond(tp)
		and Duel.GetTurnPlayer()==tp
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end

-- ② cost：把墓地的这张卡除外
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- ② 目标：设置共用标志，注册自肃
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.sumfilter2,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
end

-- ② 召唤过滤：拉法姆怪兽
function s.sumfilter2(c)
	return c:IsSetCard(0x0cf0) and c:IsSummonable(true,nil)
end

-- ② 操作：从手卡召唤1只拉法姆怪兽
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter2,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end