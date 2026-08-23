-- 天限的吹息 (ID: 23600184)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- 全局特召/召唤监听（整回合自肃检查：只能召唤·特召持有等级的风属性怪兽）
	if not s.global_check then
		s.global_check=true
		Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
		Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	end
end

-- 全局自肃过滤：只允许持有等级的风属性怪兽（等级 >= 1）
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and (c:IsLevelAbove(1) or c:IsStatus(STATUS_NO_LEVEL))
end
function s.oath_check(e,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.reg_oath(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_WIND) and (c:IsLevelAbove(1) or c:IsStatus(STATUS_NO_LEVEL)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.oath_check(e,tp) end
	s.reg_oath(e,tp)
end

-- 过滤函数：卡组·表侧额外「吹息」灵摆怪兽
function s.pzfilter(c)
	return c:IsSetCard(0xd82) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
-- 场上风属性魔法师族同调怪兽过滤
function s.syncfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
end
-- 卡组「吹息」灵摆怪兽表侧进额外过滤
function s.exfilter(c)
	return c:IsSetCard(0xd82) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 原生灵摆区域空格检查
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 原生灵摆区域空格检查
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		-- 判定是否满足追加表侧进额外条件（场上无怪 或 有魔法师族·风属性同调怪兽）
		local b1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		local b2=Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_MZONE,0,1,nil)
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if (b1 or b2) and #eg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local sg=eg:Select(tp,1,1,nil)
			Duel.SendtoExtraP(sg,tp,REASON_EFFECT)
		end
	end
end