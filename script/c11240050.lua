-- 永夜的阴影 影魔 (ID: 11240050)
local s,id,o=GetID()
local SET_YONGYE=0xb92 -- 「永夜」字段

function s.initial_effect(c)
	-- ①：丢弃自身，从卡组把1只「永夜」怪兽送去墓地。那之后可以把墓地·除外的怪兽返回卡组，把1只「永夜」融合怪兽融合召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- ②：召唤·特殊召唤的场合才能发动。从卡组把1张「永夜」魔·陷盖放。盖放的速攻魔法卡在盖放的回合也能发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果逻辑 ====================

-- 代价：丢弃自身
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- 卡组送墓过滤：1只「永夜」怪兽
function s.tgfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

-- 融合素材过滤（墓地或表侧除外的怪兽，必须能返回卡组）
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

-- 额外卡组融合目标过滤（「永夜」融合怪兽）
function s.fcheck(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_YONGYE)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,tp)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 从卡组把1只「永夜」怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_GRAVE) then return end

	-- 2. 那之后，检查是否满足融合召唤的条件
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local can_fuse=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)>0
		and Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)

	-- 询问是否执行后续融合召唤
	if can_fuse and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		-- 选择要融合召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=Duel.SelectMatchingCard(tp,s.fcheck,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
		local tc=tg:GetFirst()
		if not tc then return end

		-- 选择匹配的融合素材
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
		tc:SetMaterial(mat)

		-- 将选中的素材全部洗回卡组（标准 ocgcore 洗牌回卡组参数为 2）
		Duel.SendtoDeck(mat,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

		-- 融合怪兽登场
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

-- ==================== ② 效果逻辑 ====================

-- 盖放过滤：卡组中的「永夜」魔·陷
function s.setfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		-- 如果盖放的是速攻魔法卡，赋予在盖放的回合也能发动的效果
		if tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end