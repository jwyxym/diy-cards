-- 新星同盟 魔法洛亚
-- ID: 26051907
-- 字段: 新星同盟 (0x902)
local s,id=GetID()
function s.initial_effect(c)
	-- Link 召唤限制
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x902),2,99)

	-- ① 自己场上只能有1张表侧表示存在
	c:SetUniqueOnField(1,0,id)

	-- ② 连接召唤成功时，从卡组表侧放置1张「新星同盟」永续魔法·陷阱
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- ② 条件：连接召唤
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- 过滤卡组中符合条件的永续魔法·陷阱
function s.filter(c)
	return c:IsSetCard(0x902)
		and c:IsType(TYPE_CONTINUOUS)
		and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
		and not c:IsForbidden()
end

-- ② 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
end

-- ② 操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end