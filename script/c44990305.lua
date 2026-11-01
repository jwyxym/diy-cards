--奥秘的科学家
local s,id=GetID()
function s.initial_effect(c)
	-- ① 召唤・特殊召唤成功时：确认卡组顶5张，可选盖放1张「奥秘」魔陷
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)          -- 移除了 CATEGORY_DECK
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- ② 从场上送去墓地的场合：从卡组盖放1张「奥秘」反击陷阱
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
end

-- ① 可盖放的「奥秘」魔法·陷阱卡
function s.setfilter1(c)
	return c:IsSetCard(0x0cf2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

-- ① 目标：卡组至少5张
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end

-- ① 操作：确认5张，可选盖放1张，剩余按喜好顺序返回卡组顶
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g==0 then return end

	local sg=g:Filter(s.setfilter1,nil)
	local seted=0
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=sg:Select(tp,1,1,nil)
		if #sc>0 then
			Duel.SSet(tp,sc)
			seted=1
		end
	end

	local rest=5-seted
	if rest>0 then
		Duel.SortDecktop(tp,tp,rest)
	end
end

-- ② 条件：从场上送去墓地
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

-- ② 可盖放的「奥秘」反击陷阱
function s.setfilter2(c)
	return c:IsSetCard(0x0cf2) and c:IsType(TYPE_COUNTER) and c:IsSSetable()
end

-- ② 目标
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end

-- ② 操作：从卡组盖放1张「奥秘」反击陷阱
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end