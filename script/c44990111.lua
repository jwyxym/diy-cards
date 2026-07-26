--大德鲁伊 纳拉雷克斯
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990100)

	-- ① 丢弃自身，从卡组·墓地选记述魔陷盖放（全回合风属性自肃）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 墓地起效，特召自身并回收记述卡（全回合风属性自肃）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- ② 的全回合自肃计数器
	Duel.AddCustomActivityCounter(id+100,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 计数器过滤：只允许风属性
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end

-- 是否有「伊瑟拉」记述
function s.IsYseraCard(c)
	return aux.IsCodeListed(c,44990100)
end
function s.IsYseraMonster(c)
	return s.IsYseraCard(c) and c:IsType(TYPE_MONSTER)
end
function s.IsYseraOnField(c)
	return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
end

-- ① cost：丢弃自身
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- ① 目标（注册全回合自肃）
function s.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and s.IsYseraCard(c) and c:IsSSetable()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	-- 全回合自肃（发动时立即生效，即使发动被无效也适用）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WIND) end)
	Duel.RegisterEffect(e1,tp)
end

-- ① 操作
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

-- ② 条件（互斥检查）
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCustomActivityCount(id+100,tp,ACTIVITY_SPSUMMON)>0 then return false end
	return Duel.IsExistingMatchingCard(s.IsYseraMonster,tp,LOCATION_MZONE,0,1,nil)
end

-- ② 目标（注册全回合自肃）
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
		local hasYsera = Duel.IsExistingMatchingCard(s.IsYseraOnField,tp,LOCATION_MZONE,0,1,nil)
		if hasYsera then
			return Duel.IsExistingMatchingCard(s.IsYseraCard,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.IsYseraCard,tp,LOCATION_GRAVE,0,1,nil)
		end
	end
	-- 全回合自肃
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WIND) end)
	Duel.RegisterEffect(e1,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- ② 操作
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local hasYsera = Duel.IsExistingMatchingCard(s.IsYseraOnField,tp,LOCATION_MZONE,0,1,nil)
	local recLoc = LOCATION_GRAVE
	if hasYsera then recLoc = LOCATION_DECK+LOCATION_GRAVE end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local recg = Duel.SelectMatchingCard(tp,s.IsYseraCard,tp,recLoc,0,1,1,nil)
	if #recg>0 then
		Duel.SendtoHand(recg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,recg)
	end
end