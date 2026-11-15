--功夫鼠 吱助
local s,id=GetID()
function s.initial_effect(c)
	-- ★ 强制注册：这张卡记述了「格斗鼠 吱助」
	aux.AddCodeList(c, 8508055)

	-- 超量召唤：3星兽族怪兽×2。或者在特定怪兽上重叠（1回合1次）
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c, s.matfilter, 3, 2, s.altfilter, aux.Stringid(id,2), 1, s.altop)

	-- ① 超量召唤成功时，从手卡·墓地把「格斗鼠 吱助」或记述了它的怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ② 自己·对方回合，取除1个超量素材，选对方场上1张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	-- ③ 这张卡在场上也当作「格斗鼠 吱助」使用
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(8508055)
	c:RegisterEffect(e3)
end

-- 正常超量素材过滤：3星兽族怪兽
function s.matfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsLevel(3)
end

-- 替代超量素材过滤：兽族通常怪兽 或 格斗鼠 / 记述它的怪兽
function s.altfilter(c)
	return (c:IsRace(RACE_BEAST) and c:IsType(TYPE_NORMAL)) 
		or c:IsCode(8508055) or aux.IsCodeListed(c,8508055)
end

-- 替代超量操作：1回合1次
function s.altop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ① 条件：超量召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

-- ① 特召过滤：格斗鼠 或 记述了格斗鼠的怪兽
function s.spfilter(c,e,tp)
	return (c:IsCode(8508055) or aux.IsCodeListed(c,8508055)) and c:IsType(TYPE_MONSTER) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- ① 处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ★ 补充誓约限制：只能特召3星/3阶以上，或连接2以下的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ★ 新增的誓约限制过滤函数
function s.splimit(e,c)
	if c:IsType(TYPE_MONSTER) then
		if c:IsLevelAbove(3) or c:IsRankAbove(3) or (c:IsType(TYPE_LINK) and c:GetLink()<=2) then
			return false -- 允许特召
		end
	end
	return true -- 其他情况（比如1星、2星、Link3等）禁止特召
end

-- ② cost：取除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- ★ 修正：加上判定，如果玩家取消或者去素材失败，直接返回
	if c:RemoveOverlayCard(tp,1,1,REASON_COST)<=0 then return end
end

-- ② target
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

-- ② 处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

return s
