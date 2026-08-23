-- 吹息律法 飏嵐 (ID: 23600182)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 开启灵摆刻度与灵摆召唤手续
	aux.EnablePendulumAttribute(c)

	-- ==================== 灵摆效果 ====================
	-- 灵摆效果：P区特召自身+回收「吹息」怪兽，之后可选从手卡特召风属性魔法师族
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id) -- 灵摆效果 HOPT
	e1:SetCost(s.oath_cost)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)

	-- ==================== 怪兽效果 ====================
	-- ①：场上无怪兽或有魔法师族·风属性怪兽存在的场合才能发动。从手卡特召自身。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o*100) -- 怪兽效果 ① HOPT
	e2:SetCondition(s.spcon1)
	e2:SetCost(s.oath_cost)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)

	-- ②：作为魔法师族·风属性同调怪兽的素材表侧进额外的场合才能发动。自身放置P区并盖放「吹息」魔陷。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o*200) -- 怪兽效果 ② HOPT
	e3:SetCondition(s.matcon)
	e3:SetCost(s.oath_cost)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
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
function s.oath_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.oath_check(e,tp) end
	s.reg_oath(e,tp)
end

-- ==================== 灵摆效果函数 ====================
function s.thfilter(c)
	return c:IsSetCard(0xd82) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.spfilter_hand(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			-- 那之后，可以从手卡把1只魔法师族·风属性怪兽特殊召唤
			local sg=Duel.GetMatchingGroup(s.spfilter_hand,tp,LOCATION_HAND,0,nil,e,tp)
			if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=sg:Select(tp,1,1,nil)
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

-- ==================== 怪兽效果 ① 函数 ====================
function s.mfilter_field(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	local b2=Duel.IsExistingMatchingCard(s.mfilter_field,tp,LOCATION_MZONE,0,1,nil)
	return b1 or b2
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== 怪兽效果 ② 函数 ====================
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsReason(REASON_SYNCHRO)
		and rc and rc:IsRace(RACE_SPELLCASTER) and rc:IsAttribute(ATTRIBUTE_WIND) and rc:IsType(TYPE_SYNCHRO)
end
function s.setfilter(c)
	return c:IsSetCard(0xd82) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 原生灵摆区域空格检查与魔陷区空格校验
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and not c:IsForbidden()
	end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end