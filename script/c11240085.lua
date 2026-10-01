-- 红的永夜月 (ID: 11240085)
local s,id,o=GetID()
local SET_YONGYE=0xb92 -- 「永夜」字段

function s.initial_effect(c)
	-- ①：从以下效果选择1个发动
	-- ●从卡组特召1只「永夜」怪兽
	-- ●手卡·场上·墓地·除外的「永夜」怪兽返回卡组，把1只融合怪兽融合召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②：墓地除外自身，墓地融合怪兽任意数量返回额外。那之后最多该数量×2的双方墓地·除外卡返回卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg2)
	e2:SetOperation(s.tdop2)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果逻辑 ====================

-- 卡组特召过滤
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 融合素材过滤（手卡、场上、墓地、表侧除外的「永夜」怪兽，且必须能返回卡组）
function s.mfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

-- 融合怪兽合法性检测
function s.fcheck(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 分支 1 判定：卡组特召
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)

	-- 分支 2 判定：洗回素材融合
	local chkf=tp
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local b2=Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)

	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==0 then
		-- 分支 1：从卡组把1只「永夜」怪兽特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 分支 2：洗回素材融合召唤
		local chkf=tp
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		local sg=Duel.GetMatchingGroup(s.fcheck,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
		if #sg==0 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if not tc then return end

		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
		tc:SetMaterial(mat)

		-- 将素材洗回卡组（标准原生参数 2）
		Duel.SendtoDeck(mat,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

-- ==================== ② 效果逻辑 ====================

-- 墓地融合怪兽过滤（必须能返回额外卡组）
function s.tdfilter1(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

-- 双方墓地·除外卡片过滤（能返回卡组·额外卡组）
function s.tdfilter2(c)
	return c:IsAbleToDeck()
end

function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter1,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 自己墓地的融合怪兽任意数量返回额外卡组
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter1),tp,LOCATION_GRAVE,0,nil)
	if #g1==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg1=g1:Select(tp,1,#g1,nil)
	if #sg1==0 then return end

	Duel.SendtoDeck(sg1,nil,2,REASON_EFFECT)

	-- 精准统计实际成功返回额外卡组的怪兽数量
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	local ct=#og
	if ct<=0 then return end

	-- 2. 那之后，可以把最多返回数量×2的双方墓地·除外卡返回卡组
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local max_count=math.min(#g2,ct*2)
		local sg2=g2:Select(tp,1,max_count,nil)
		if #sg2>0 then
			Duel.HintSelection(sg2)
			Duel.SendtoDeck(sg2,nil,2,REASON_EFFECT)
		end
	end
end