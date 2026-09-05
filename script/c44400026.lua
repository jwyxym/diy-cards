-- 魂零归于拉斯弥雅
local s,id,o=GetID()
function s.initial_effect(c)
	-- 规则效果：这个卡名在规则上也当做「绮饿罗」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x444)
	c:RegisterEffect(e0)

	-- ①：二选一发动（每个选项 1 回合只能选择 1 次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：自己把怪兽融合召唤成功的场合，把墓地这张卡除外才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*300) -- HOPT 限制码
	e2:SetCondition(s.spcon2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- ①效果选项 1 特召过滤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x444) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ①效果选项 2 融合素材过滤（场上怪兽支持里侧；除外区仅支持表侧；排除不受效果影响的怪兽）
function s.mfilter(c,e)
	return (c:IsLocation(LOCATION_ONFIELD) or c:IsFaceup()) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

-- 融合素材必须包含融合怪兽的额外检查
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end

-- 融合怪兽合法性检查函数
function s.ffilter(c,e,tp,m,fcheck,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	Auxiliary.FCheckAdditional=fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	Auxiliary.FCheckAdditional=nil
	return res
end

-- ①效果 Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 选项 1 检查：未选择过 + 有手卡可丢弃(排除自身) + 有怪兽区 + 有可特召目标
	local b1 = Duel.GetFlagEffect(tp,id+o*100)==0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
	
	-- 选项 2 检查：未选择过 + 满足包含融合怪兽的融合召唤
	local mg = Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil,e)
	local b2 = Duel.GetFlagEffect(tp,id+o*200)==0
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,s.fcheck,tp)

	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end

	e:SetLabel(op)
	if op==0 then
		-- 记录选项 1 已使用
		Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
	else
		-- 记录选项 2 已使用
		Duel.RegisterFlagEffect(tp,id+o*200,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

-- ①效果 Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- 选项 1 处理：特召卡组/除外状态的「绮饿罗」怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 选项 2 处理：融合召唤（包含场上与除外状态怪兽）
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil,e)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg,s.fcheck,tp)
		local tc=sg:GetFirst()
		if tc then
			Auxiliary.FCheckAdditional=s.fcheck
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
			Auxiliary.FCheckAdditional=nil
			tc:SetMaterial(mat)
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

-- ②效果 Condition / Target / Operation
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x444) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end

-- 保护生效条件：自己场上有「绮饿罗」融合怪兽存在
function s.fusfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x444) and c:IsType(TYPE_FUSION)
end
function s.protcon(e)
	return Duel.IsExistingMatchingCard(s.fusfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		-- 不会成为效果对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCondition(s.protcon)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 不会被效果破坏
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		-- 不会被除外
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_REMOVE)
		tc:RegisterEffect(e3)
	end
end