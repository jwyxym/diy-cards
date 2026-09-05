-- 暗跃之光天使 (ID: 20263240)
local s,id,o=GetID()
local SET_STAR_SERAPH=0x86  -- 「光天使」官方字段代码
local CARD_CNO102=67173574   -- 「混沌No.102 光堕天使 贵魔」官方卡号
local CARD_SARGASSO=20263244 -- 「异晶人的古战场-死域海」自定义卡号

function s.initial_effect(c)
	-- 记录关联卡名（CNo.102: 67173574, 死域海: 20263244）
	aux.AddCodeList(c,CARD_CNO102,CARD_SARGASSO)

	-- ①：双方回合，丢弃自身并展示额外CNo.102：从卡组把「死域海」在场地区域表侧放置 (HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②：墓地存在，自己场上有原本光属性怪兽召唤·特召的场合：墓地特召自身 (HOPT: id+o*100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：丢弃+展示 放置「死域海」 ====================
function s.cfilter(c)
	return c:IsCode(CARD_CNO102) and not c:IsPublic()
end

function s.fieldfilter(c,tp)
	return c:IsCode(CARD_SARGASSO) and not c:IsForbidden()
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

-- ==================== ② 效果：原本光属性怪兽登场时墓地自跳 ====================
function s.ckfilter(c,tp)
	-- ★ 核心修复：使用官方标准原生 API GetOriginalAttribute() 判定原本属性
	return c:IsFaceup() and c:IsControler(tp) and (c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ckfilter,1,nil,tp)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end