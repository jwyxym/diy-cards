-- 剂型法师 (ID: 44400028)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 规则效果：这个卡名在规则上也当做「绮饿罗」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x444)
	c:RegisterEffect(e0)

	-- ①：双方主要阶段把手卡这张卡丢弃才能发动。选手卡·墓地1只「绮饿罗」怪兽特召。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON)
	e1:SetCountLimit(1,id) -- ①效果 HOPT
	e1:SetCondition(s.spcon1)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：自己主要阶段或者自己把「绮饿罗」融合·同调·连接怪兽效果发动的场合
	-- ②-1：自己主要阶段起动发动
	local e2_1=Effect.CreateEffect(c)
	e2_1:SetDescription(aux.Stringid(id,1))
	e2_1:SetCategory(CATEGORY_TOGRAVE)
	e2_1:SetType(EFFECT_TYPE_IGNITION)
	e2_1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2_1:SetRange(LOCATION_MZONE)
	e2_1:SetCountLimit(1,id+o*100) -- ②效果 HOPT
	e2_1:SetTarget(s.tgtg2)
	e2_1:SetOperation(s.tgop2)
	c:RegisterEffect(e2_1)
	-- ②-2：本家额外怪兽效果发动时诱发
	local e2_2=Effect.CreateEffect(c)
	e2_2:SetDescription(aux.Stringid(id,1))
	e2_2:SetCategory(CATEGORY_TOGRAVE)
	e2_2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2_2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2_2:SetCode(EVENT_CHAINING)
	e2_2:SetRange(LOCATION_MZONE)
	e2_2:SetCountLimit(1,id+o*100) -- ②效果 HOPT
	e2_2:SetCondition(s.tgcon2)
	e2_2:SetTarget(s.tgtg2)
	e2_2:SetOperation(s.tgop2)
	c:RegisterEffect(e2_2)

	-- ③：自己场上的融合怪兽离场的场合才能发动。墓地·除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCountLimit(1,id+o*200) -- ③效果 HOPT（严格修复）
	e3:SetCondition(s.spcon3)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end

-- ①效果：主阶段手卡丢弃特召
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x444) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ②效果：额外送墓与融合防连锁保护
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and rc:IsSetCard(0x444) and rc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_LINK) and re:IsActiveType(TYPE_MONSTER)
end
function s.exfilter(c,tc)
	return c:IsAbleToGrave() and (c:IsAttribute(tc:GetAttribute()) or c:IsRace(tc:GetRace()))
end
function s.tgfilter2(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter2(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc)
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			-- 这个回合，自己的怪兽融合召唤发动的场合对方不能把效果发动
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAINING)
			e1:SetOperation(s.chainop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SPSUMMON_SUCCESS)
			e2:SetOperation(s.limop)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:IsHasCategory(CATEGORY_FUSION_SUMMON) then
		Duel.SetChainLimit(s.chainlimit)
	end
end
function s.chainlimit(e,rp,tp)
	return tp==rp
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_FUSION) and eg:IsExists(Card.IsControler,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(s.chainlimit)
	end
end

-- ③效果：自己场上融合怪兽离场时墓地·除外特召自身
function s.cfilter3(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
end
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter3,1,nil,tp)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end