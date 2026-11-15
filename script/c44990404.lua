--探险者之力-完美创想
local s,id=GetID()
function s.initial_effect(c)
	-- 同名卡在自己场上只能有1张表侧表示存在
	c:SetUniqueOnField(1,0,id)

	-- 激活效果：装备到「探险者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- 装备限制：只能装备给「探险者」怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)

	-- ② 满足条件时，对方不能从额外卡组特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)  -- 只作用于对方玩家
	e3:SetCondition(s.cond2)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
end

-- 装备对象限制：「探险者」怪兽（字段 0x0cf3）
function s.eqlimit(e,c)
	return c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER)
end

-- 可装备对象过滤
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER)
end

-- 激活目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

-- 激活操作：装备
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and c:CheckUniqueOnField(tp) then
		Duel.Equip(tp,c,tc)
	end
end

-- 自己场上表侧装备魔法卡数量
function s.equipcount(tp)
	return Duel.GetMatchingGroupCount(function(c)
		return c:IsFaceup() and c:IsType(TYPE_EQUIP)
	end,tp,LOCATION_SZONE,0,nil)
end

-- 上级召唤怪兽过滤
function s.advfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end

-- ② 条件：自己场上表侧装备魔法卡4张以上，且只有自己场上有上级召唤的怪兽
function s.cond2(e)
	local tp=e:GetHandlerPlayer()
	if s.equipcount(tp)<4 then return false end
	if not Duel.IsExistingMatchingCard(s.advfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	if Duel.IsExistingMatchingCard(s.advfilter,1-tp,LOCATION_MZONE,0,1,nil) then return false end
	return true
end

-- ② 限制函数：禁止从额外卡组特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end