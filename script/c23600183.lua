-- 吹息天灵 卡斯特里翁 (ID: 23600183)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 同调召唤手续：风属性调整＋调整以外的风属性怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- 开启灵摆刻度与灵摆召唤手续
	aux.EnablePendulumAttribute(c)

	-- ==================== 灵摆效果 ====================
	-- 灵摆效果 ①：自己场上的风属性同调怪兽不会成为对方效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ptarget)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	-- 灵摆效果 ②：自己主要阶段特召手卡·额外（表侧）1只魔法师族·风属性怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id) -- 灵摆效果 ② HOPT
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- ==================== 怪兽效果 ====================
	-- ①：同调召唤成功的场合从卡组·墓地把1张「吹息」卡加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*100) -- 怪兽效果 ① HOPT
	e3:SetCondition(s.thcon)
	e3:SetCost(s.oath_cost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	-- ②：自己主要阶段从额外（表侧）·墓地回收魔法师族·风属性，之后可选弹回P区1张卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*200) -- 怪兽效果 ② HOPT
	e4:SetCost(s.oath_cost)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)

	-- ③：怪兽区域的这张卡离场的场合在自己的灵摆区域放置（完美支持战破/效破/送墓/除外/回额外）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,id+o*300) -- 怪兽效果 ③ HOPT
	e5:SetCondition(s.pencon)
	e5:SetCost(s.oath_cost)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)

	-- 全局特召/召唤监听（怪兽效果整回合自肃检查）
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
	e1:SetDescription(aux.Stringid(id,5))
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
function s.ptarget(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND)
end

-- 灵摆效果 ②：手卡/额外特召魔法师族·风属性
function s.spfilter(c,e,tp)
	if not (c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))) then
		return false
	end
	if c:IsLocation(LOCATION_HAND) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== 怪兽效果 ① 函数 ====================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c)
	return c:IsSetCard(0xd82) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==================== 怪兽效果 ② 函数 ====================
function s.thfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0):Filter(Card.IsAbleToHand,nil)
		if #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local sg=pg:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end

-- ==================== 怪兽效果 ③ 函数 ====================
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 严格检验在场上时为怪兽区表侧表示
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 原生灵摆区域空格检查
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 原生灵摆区域空格检查
	if c:IsRelateToEffect(e) and not c:IsForbidden() and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end