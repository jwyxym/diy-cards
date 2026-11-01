--日月潭
local s,id=GetID()
function s.initial_effect(c)
	--场地魔法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--① 对方场上的光·暗属性怪兽的攻击力和守备力变为0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.atkfilter)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_SET_DEFENSE)
	e1b:SetRange(LOCATION_FZONE)
	e1b:SetTargetRange(0,LOCATION_MZONE)
	e1b:SetTarget(s.atkfilter)
	e1b:SetValue(0)
	c:RegisterEffect(e1b)

	--② ●1 战破时点（专门抓光属性战破）
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_BATTLE_DESTROYED)    -- 战破事件
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(s.spcon1_battle)
	e2a:SetTarget(s.sptg1)
	e2a:SetOperation(s.spop1)
	c:RegisterEffect(e2a)

	--② ●1 其他方式离场时点（抓光属性效破、回手等）
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_LEAVE_FIELD)         -- 普通离场事件
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetCountLimit(1,id)
	e2b:SetCondition(s.spcon1_leave)
	e2b:SetTarget(s.sptg1)
	e2b:SetOperation(s.spop1)
	c:RegisterEffect(e2b)

	--② ●2 战破时点（专门抓暗属性战破）
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCode(EVENT_BATTLE_DESTROYED)    -- 战破事件
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCountLimit(1,id)
	e3a:SetCondition(s.spcon2_battle)
	e3a:SetTarget(s.sptg2)
	e3a:SetOperation(s.spop2)
	c:RegisterEffect(e3a)

	--② ●2 其他方式离场时点（抓暗属性效破、回手等）
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3b:SetCode(EVENT_LEAVE_FIELD)         -- 普通离场事件
	e3b:SetRange(LOCATION_FZONE)
	e3b:SetProperty(EFFECT_FLAG_DELAY)
	e3b:SetCountLimit(1,id)
	e3b:SetCondition(s.spcon2_leave)
	e3b:SetTarget(s.sptg2)
	e3b:SetOperation(s.spop2)
	c:RegisterEffect(e3b)
end

function s.atkfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end

-- ========= 光属性相关 =========
function s.spcon1_battle(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lvfilter1,1,nil,tp)
end

-- 这里因为 EVENT_LEAVE_FIELD 已经抓了全部，要防止战破重复触发，所以加一个 non-battle 判断
function s.spcon1_leave(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lvfilter1_nonbattle,1,nil,tp)
end

function s.lvfilter1(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
end

function s.lvfilter1_nonbattle(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
		and not c:IsReason(REASON_BATTLE)  -- 排除战破，防止重复
end

function s.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

-- ========= 暗属性相关 =========
function s.spcon2_battle(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lvfilter2,1,nil,tp)
end

function s.spcon2_leave(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lvfilter2_nonbattle,1,nil,tp)
end

function s.lvfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER)
end

function s.lvfilter2_nonbattle(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER)
		and not c:IsReason(REASON_BATTLE)  -- 排除战破，防止重复
end

function s.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

return s
