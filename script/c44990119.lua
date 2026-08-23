--世界之树-宁静之冠
local s,id=GetID()
function s.initial_effect(c)
	-- 有「伊瑟拉」的卡名记述
	aux.AddCodeList(c,44990100)

	-- 场地魔法的发动效果（必须，否则无法从手牌发动）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ① 检索 + 发动后风属性自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ② 自己场上的「伊瑟拉」怪兽的控制权不能变更
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.controlfilter)
	c:RegisterEffect(e2)

	-- ③ 表侧表示从场上离开时特召伊瑟拉超量怪兽并叠放自身
	local events = {EVENT_TO_GRAVE, EVENT_REMOVE, EVENT_TO_HAND, EVENT_TO_DECK}
	for _, event in ipairs(events) do
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(event)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCondition(s.condition3)
		e3:SetTarget(s.target3)
		e3:SetOperation(s.operation3)
		c:RegisterEffect(e3)
	end
end

-- ① 条件：一回合一次
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
end

-- ① 目标
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end

-- ① 检索过滤：有「伊瑟拉」的卡名记述的卡
function s.thfilter(c)
	return aux.IsCodeListed(c,44990100) and c:IsAbleToHand()
end

-- ① 操作
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	-- 发动后自肃：直到回合结束时自己不是风属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- ① 自肃限制函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end

-- ② 控制权保护过滤：自己场上的「伊瑟拉」怪兽
function s.controlfilter(e,c)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
end

-- ③ 条件：表侧表示从场上离开 + 一回合一次
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
		and Duel.GetFlagEffect(tp,id+200)==0
end

-- ③ 目标
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ③ 伊瑟拉超量怪兽过滤
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ③ 操作
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g==0 then return end
	local xyz=g:GetFirst()

	if Duel.SpecialSummon(xyz,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 把这张卡作为超量素材叠放
		Duel.Overlay(xyz,Group.FromCards(c))
	end
end