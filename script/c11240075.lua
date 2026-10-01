-- 永夜的无光世界 (ID: 11240075)
local s,id,o=GetID()
local SET_YONGYE=0xb92 -- 「永夜」字段

function s.initial_effect(c)
	-- 分支 1：从卡组把1只「永夜」怪兽加入手卡（连锁对方效果可改为特召）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- 分支 2：手卡·场上融合（对方场上有额外特召怪兽时，自己额外1只「永夜」也能作为素材）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100) -- 严格遵循 HOPT 递增规范
	e2:SetTarget(s.fusiontg)
	e2:SetOperation(s.fusionop)
	c:RegisterEffect(e2)
end

-- ==================== 分支 1：检索 / 特召逻辑 ====================

function s.thfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 【核心修复】：通过 GetChainInfo 精准抓取上一连锁点的发动玩家，杜绝 rp 虚假占位
	local chain=Duel.GetCurrentChain()
	local is_chain_oppo=false
	if chain>0 then
		local p=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
		is_chain_oppo=(p==1-tp)
	end

	local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local can_sp=is_chain_oppo and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)

	if chk==0 then return can_th or can_sp end

	-- 记录发动时是否属于连锁对方效果（封存状态，防时序篡改）
	e:SetLabel(is_chain_oppo and 1 or 0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if is_chain_oppo then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local is_chain_oppo=(e:GetLabel()==1)
	local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local can_sp=is_chain_oppo and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)

	-- 连锁对方效果且满足特召条件时，弹窗由玩家自主决定是否改为特召
	if can_sp and (not can_th or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 常规效果：加入手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- ==================== 分支 2：融合召唤逻辑 ====================

-- 判定对方场上是否有从额外卡组特殊召唤的怪兽
function s.oppo_ex_filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.mfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsOnField()) and not c:IsImmuneToEffect(e)
end

function s.ex_mat_filter(c,e)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e)
end

-- 融合素材组校验：如果使用了额外卡组的怪兽，必须至多为 1 只
function s.fgoalcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end

function s.fcheck(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
		-- 对方场上有额外特召怪兽时，引入额外卡组的「永夜」怪兽作为候选素材
		if Duel.IsExistingMatchingCard(s.oppo_ex_filter,tp,0,LOCATION_MZONE,1,nil) then
			local mg_ex=Duel.GetMatchingGroup(s.ex_mat_filter,tp,LOCATION_EXTRA,0,nil,e)
			mg:Merge(mg_ex)
		end
		aux.FCheckAdditional=s.fgoalcheck
		local res=Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
		aux.FCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
	if Duel.IsExistingMatchingCard(s.oppo_ex_filter,tp,0,LOCATION_MZONE,1,nil) then
		local mg_ex=Duel.GetMatchingGroup(s.ex_mat_filter,tp,LOCATION_EXTRA,0,nil,e)
		mg:Merge(mg_ex)
	end

	aux.FCheckAdditional=s.fgoalcheck
	local sg=Duel.GetMatchingGroup(s.fcheck,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
		tc:SetMaterial(mat)
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
	aux.FCheckAdditional=nil
end