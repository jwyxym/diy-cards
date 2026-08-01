-- 温泉娘·足摺星 (ID: 23600130)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 连接召唤手续：包含「温泉娘」(0xd89) 怪兽在内的水族怪兽 2 只以上 (LINK-3)
	local e0=aux.AddLinkProcedure(c,s.matfilter,2,99,s.lcheck)
	-- 核心：赋予 EFFECT_FLAG_SET_AVAILABLE，原生允许点选场上里侧水族怪兽作为连接素材
	e0:SetProperty(e0:GetProperty()|EFFECT_FLAG_SET_AVAILABLE)
	c:EnableReviveLimit()

	-- ①：连接召唤的这张卡的攻击力上升自己场上·墓地的「温泉娘」连接怪兽数量×300，这张卡不会被战斗·效果破坏。
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

	-- ②：自己·对方回合，以自己场上1只水族·反转怪兽为对象才能发动。那只怪兽是表侧表示的场合，变成里侧守备表示。里侧表示的场合，变成表侧攻击表示或表侧守备表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_END_PHASE)
	e5:SetCountLimit(1,id+o*100) -- ②效果 HOPT
	e5:SetCost(s.costop)
	e5:SetTarget(s.pftg)
	e5:SetOperation(s.pfop)
	c:RegisterEffect(e5)

	-- ③：对方在战斗阶段把魔法·陷阱·怪兽的效果发动时，把自己场上1只表侧表示的水族·反转怪兽变成里侧守备表示才能发动。对方场上的全部表侧表示的卡的效果无效。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+o*200) -- ③效果 HOPT
	e6:SetCondition(s.discon)
	e6:SetCost(s.discost)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)

	-- 全局检测：记录玩家本回合是否特召过非水族·反转怪兽
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end

-- ==================== 连接召唤素材校验（完美支持表侧与里侧水族） ====================
function s.matfilter(c,lc,sumtype,tp)
	-- 支持表侧或里侧的水族怪兽（包括原本种族为水族）
	return c:IsLinkRace(RACE_AQUA) or (c:GetOriginalRace()&RACE_AQUA~=0)
end

function s.chkfilter(c,lc,sumtype,tp)
	return c:IsLinkSetCard(0xd89) or (c:GetOriginalSetCard()&0xd89~=0)
end

function s.lcheck(g,lc,sumtype,tp)
	-- 素材组合中必须包含至少 1 只「温泉娘」(0xd89) 怪兽
	return g:IsExists(s.chkfilter,1,nil,lc,sumtype,tp)
end

-- 全局特召记录
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
			and not (tc:IsRace(RACE_AQUA) and tc:IsType(TYPE_FLIP)) then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		end
	end
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
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	s.regop(e,tp)
end

-- ==================== ① 效果：攻击力上升与不破抗性 ====================
function s.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xd89) and c:IsType(TYPE_LINK)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)*300
end

-- ==================== ② 效果：二速表示形式变更 ====================
function s.pffilter(c)
	if c:IsFaceup() then
		return c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP) and c:IsCanTurnSet()
	else
		return (c:GetOriginalRace()&RACE_AQUA~=0) and (c:GetOriginalType()&TYPE_FLIP~=0)
			and c:IsCanChangePosition()
	end
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
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			Duel.ChangePosition(tc,pos)
		end
	end
end

-- ==================== ③ 效果：战阶全场无效与3次攻击 ====================
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and rp==1-tp and Duel.IsChainDisablable(ev)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP) and c:IsCanTurnSet()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
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