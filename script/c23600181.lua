-- 吹息届法 飂岚 (ID: 23600181)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 开启灵摆刻度与灵摆召唤手续
	aux.EnablePendulumAttribute(c)

	-- ==================== 灵摆效果 ====================
	-- 灵摆效果：自己主要阶段特召自身，并从手卡·表侧额外·墓地放置风属性魔法师族灵摆怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id) -- 灵摆效果 HOPT
	e1:SetCost(s.pencost)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)

	-- ==================== 怪兽效果 ====================
	-- ①：场上没有怪兽存在或有魔法师族·风属性同调怪兽存在的场合，可以从手卡特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o*100+EFFECT_COUNT_CODE_OATH) -- ①方法特召 1 回合 1 次
	e2:SetCondition(s.spcon1)
	c:RegisterEffect(e2)

	-- ②：把这张卡解放才能发动。从卡组·表侧额外把1只「吹息」怪兽在灵摆区域放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*200) -- ②效果 HOPT
	e3:SetCost(s.pzcost2)
	e3:SetTarget(s.pztg2)
	e3:SetOperation(s.pzop2)
	c:RegisterEffect(e3)

	-- 全局召唤/特召监听（整回合自肃：只能召唤·特召持有等级的风属性怪兽）
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
	e1:SetDescription(aux.Stringid(id,3))
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

-- ==================== 灵摆效果函数 ====================
function s.pzfilter1(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.oath_check(e,tp) end
	s.reg_oath(e,tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.pzfilter1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 原生灵摆区域空格检查
		if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pzfilter1),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

-- ==================== 怪兽效果 ① 函数 ====================
function s.syncfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
end
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	local b2=Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_MZONE,0,1,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (b1 or b2)
end

-- ==================== 怪兽效果 ② 函数 ====================
function s.pzfilter2(c)
	return c:IsSetCard(0xd82) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.pzcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and s.oath_check(e,tp) end
	Duel.Release(c,REASON_COST)
	s.reg_oath(e,tp)
end
function s.pztg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 原生灵摆区域空格检查
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.IsExistingMatchingCard(s.pzfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	end
end
function s.pzop2(e,tp,eg,ep,ev,re,r,rp)
	-- 原生灵摆区域空格检查
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pzfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end