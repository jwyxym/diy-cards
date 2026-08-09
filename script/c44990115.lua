--麦琳瑟拉
local s,id=GetID()
function s.initial_effect(c)
	-- 有「伊瑟拉」的卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 卡名在场上·墓地当作「伊瑟拉」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(44990100)
	c:RegisterEffect(e1)

	-- ② 手卡·墓地起效，丢1张其他记述伊瑟拉的卡特召自身，离场除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- ③ 特殊召唤成功时，从手卡·墓地特召其他记述伊瑟拉的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)

	-- 全回合额外自肃计数器（从额外特召的非伊瑟拉怪兽会计入）
	Duel.AddCustomActivityCounter(id+500,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 计数器过滤：只对从额外特召的非伊瑟拉怪兽计数
function s.counterfilter(c)
	if not c:IsSummonLocation(LOCATION_EXTRA) then return true end
	return c:IsSetCard(0xcf1)
end

-- ② 条件：检查是否已经额外特召过非伊瑟拉怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id+500,tp,ACTIVITY_SPSUMMON)==0
end

-- ② cost：丢弃1张其他记述伊瑟拉的卡（使用aux.IsCodeListed）
function s.costfilter(c,tp)
	return aux.IsCodeListed(c,44990100) and not c:IsCode(id) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end

-- ② 目标（注册全回合额外自肃）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 全回合额外自肃
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

-- 额外自肃的限制条件：只能特召伊瑟拉怪兽（从额外）
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xcf1)
end

-- ② 操作：特殊召唤自身，并赋予离场除外效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end

-- ③ 条件：检查是否已经额外特召过非伊瑟拉怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id+500,tp,ACTIVITY_SPSUMMON)==0
end

-- ③ 目标（注册全回合额外自肃）
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 全回合额外自肃
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

-- ③ 可特殊召唤的怪兽：其他记述伊瑟拉的怪兽（修正为使用aux.IsCodeListed）
function s.spfilter2(c,e,tp)
	return aux.IsCodeListed(c,44990100) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ③ 操作：选择并特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end