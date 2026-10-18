-- 永夜的无光世界 (ID: 11240075)
local s,id,o=GetID()
local SET_YONGYE=0xb92

function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- ==================== 过滤函数 ====================
function s.thfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.oppo_ex_filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.mfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsOnField()) and not c:IsImmuneToEffect(e)
end

function s.ex_mat_filter(c,e)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e)
end

function s.fgoalcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end

function s.fcheck(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end

-- ==================== 发动与分支选择（官方标准对齐） ====================
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ch=Duel.GetCurrentChain()
	-- 预检阶段(chk==0)本卡尚未入链，链顶即为 ch
	local is_chain_oppo=(ch>0 and Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER)==1-tp)

	-- 分支 1 判定
	local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local can_sp=is_chain_oppo and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b1=(can_th or can_sp) and Duel.GetFlagEffect(tp,id)==0

	-- 分支 2 判定
	local chkf=tp
	local mg=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
	if Duel.IsExistingMatchingCard(s.oppo_ex_filter,tp,0,LOCATION_MZONE,1,nil) then
		local mg_ex=Duel.GetMatchingGroup(s.ex_mat_filter,tp,LOCATION_EXTRA,0,nil,e)
		mg:Merge(mg_ex)
	end
	aux.FCheckAdditional=s.fgoalcheck
	local b2=Duel.IsExistingMatchingCard(s.fcheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
		and Duel.GetFlagEffect(tp,id+o*100)==0
	aux.FCheckAdditional=nil

	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end

	-- 正式入链(chk==1)时本卡在链顶，前一环是 ch_now-1（完全复刻 5786513/54408264 官方写法）
	local ch_now=Duel.GetCurrentChain()
	local chained_oppo=(ch_now>1 and Duel.GetChainInfo(ch_now-1,CHAININFO_TRIGGERING_PLAYER)==1-tp)

	if op==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 极简单数字标记：1=连锁对方可特召，0=常规检索
		e:SetLabel(chained_oppo and 1 or 0)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		if chained_oppo then
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
		end
	else
		Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
		e:SetLabel(2) -- 2=融合
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

-- ==================== 结算逻辑 ====================
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()

	if label==0 or label==1 then
		local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local can_sp=(label==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp))

		-- 连锁对方且满足特召条件时，弹窗询问是否改为特召
		if can_sp and (not can_th or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif label==2 then
		-- 融合处理
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
end