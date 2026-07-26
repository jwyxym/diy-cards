-- 温泉娘·足摺星
local s,id,o=GetID()
function s.initial_effect(c)
	-- link summon：包含「むすめ」怪兽在内的水族怪兽2只以上
	local e0=aux.AddLinkProcedure(c,s.matfilter,2,99,s.lcheck)
	-- 为主连接召唤手续赋予 EFFECT_FLAG_SET_AVAILABLE，允许引擎点选场上里侧怪兽
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	c:EnableReviveLimit()

	-- 里侧表示的水族怪兽也能作为连接素材 (额外素材补充)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)

	-- ①：连接召唤的这卡攻上升，永续双不破
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)

	-- ②：自己·对方回合表示形式变更
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,id+o*100)
	e5:SetCost(s.costop)
	e5:SetTarget(s.pftg)
	e5:SetOperation(s.pfop)
	c:RegisterEffect(e5)

	-- ③：战斗阶段全场无效+作3次攻击
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+o*200)
	e6:SetCondition(s.discon)
	e6:SetCost(s.discost)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end

-- 【修复】素材过滤：使用原生的 GetOriginalRace 位运算判断原本种族
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_AQUA,lc,sumtype,tp) or (c:GetOriginalRace()&RACE_AQUA~=0)
end

-- 本家素材校验：使用原生 IsSetCard 配合参数 lc 穿透里侧校验「温泉娘」字段
function s.chkfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xd89,lc,sumtype,tp)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.chkfilter,1,nil,lc,sumtype,tp)
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return c:IsFacedown() and (c:IsRace(RACE_AQUA,lc,SUMMON_TYPE_LINK,tp) or (c:GetOriginalRace()&RACE_AQUA~=0)),true
end

-- 誓约限制：包含这些效果发动的回合，非水族·反转怪兽不能从手卡·墓地特召
function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE)
		and not (c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP))
end

function s.regop(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.costop(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.regop(e,tp)
end

-- ①效果：连接召唤判定与攻击力数值计算
function s.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xd89) and c:IsType(TYPE_LINK)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)*300
end

-- ②效果：Target / Operation
function s.pffilter(c)
	return c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP)
		and (c:IsFaceup() and c:IsCanTurnSet()
			or c:IsFacedown() and (c:IsCanChangePosition() or c:IsCanTurnSet()))
end

function s.pftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.pffilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pffilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.pffilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.pfop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsFaceup() then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		elseif tc:IsFacedown() then
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
		end
	end
end

-- ③效果：Condition / Cost / Target / Operation
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and rp==1-tp and Duel.IsChainDisablable(ev)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP) and c:IsCanTurnSet()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	s.regop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanBeDisabled,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanBeDisabled,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanBeDisabled,tp,0,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_ATTACK)
		e3:SetValue(2)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end