--奥卓克希昂
local s,id=GetID()
function s.initial_effect(c)
	-- 有「死亡之翼」的卡名记述
	aux.AddCodeList(c,44990201)

	-- ① 自己场上的怪兽不存在时，丢弃其他手卡特召自身并检索
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ② 从卡组以外送墓时特召自身，并特召卡组死亡之翼记述怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)

	-- 全回合额外自肃计数器
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 额外自肃计数器过滤：从额外特召且非龙族·暗属性时计入违规
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end

-- 检查是否已违反额外自肃
function s.CheckBond(tp)
	return Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SPSUMMON)==0
end

-- 注册全回合额外自肃
function s.RegisterSelfBond(tp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

-- 额外自肃限制：只允许暗属性龙族从额外特召
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end

-- ① 条件：一回合一次 + 未违反额外自肃 + 自己场上无怪兽
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
		and s.CheckBond(tp)
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- ① cost：丢弃1张其他手卡
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,c)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end

-- ① 目标
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- ① 操作
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 检索1张有死亡之翼记述的卡
			if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #g>0 then
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
end

-- ① 检索过滤：有死亡之翼记述的卡
function s.thfilter(c)
	return aux.IsCodeListed(c,44990201) and c:IsAbleToHand()
end

-- ② 条件：从卡组以外送墓 + 一回合一次 + 未违反额外自肃
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
		and Duel.GetFlagEffect(tp,id+200)==0
		and s.CheckBond(tp)
end

-- ② 目标
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then
			return false
		end
		return true
	end
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ② 操作
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 从卡组特召1只有死亡之翼记述的怪兽
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if #g>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end

-- ② 卡组特召过滤：有死亡之翼记述的怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,44990201)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end