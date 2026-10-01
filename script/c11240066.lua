-- 永夜的妖精 月莺 (ID: 11240065)
local s,id,o=GetID()
local SET_YONGYE=0xb92 -- 「永夜」字段

function s.initial_effect(c)
	-- 融合召唤手续：暗属性怪兽×2
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)

	-- ①：特殊召唤成功的场合，回收墓地·除外1张「永夜」卡；融合召唤的场合可再夺取对方1只怪兽控制权至下个回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，二选一适用：手卡特召「永夜」怪兽 / 包含场上自身的融合召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.efftg2)
	e2:SetOperation(s.effop2)
	c:RegisterEffect(e2)
end

-- 融合素材过滤：暗属性怪兽
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionAttribute(ATTRIBUTE_DARK,fc,sub,mg,sg)
end

-- ==================== ① 效果逻辑 ====================

-- 回收过滤：墓地或表侧除外的「永夜」卡
function s.thfilter(c)
	return c:IsSetCard(SET_YONGYE) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_FUSION) then
		local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)

		local c=e:GetHandler()
		local cg=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
		-- 融合召唤出场的场合，可以再夺取对方场上1只怪兽的控制权直到下个回合结束
		if c:IsSummonType(SUMMON_TYPE_FUSION) and #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sc=cg:Select(tp,1,1,nil):GetFirst()
			if sc then
				-- 原生引擎支持：第三参数为重置阶段，第四参数指定回合数为2，实现“直到下个回合结束”
				Duel.GetControl(sc,tp,PHASE_END,2)
			end
		end
	end
end

-- ==================== ② 效果逻辑 ====================

-- 手卡特召过滤：「永夜」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 融合怪兽过滤（必须能以场上包含自身的怪兽为素材进行融合召唤）
function s.fcheck2(c,e,tp,mg,gc)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,gc,tp)
end

function s.mfilter2(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end

function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 分支 1 合法性检查：手卡特召
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

	-- 分支 2 合法性检查：场上包含自身的融合召唤
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	local b2=c:IsCanBeFusionMaterial()
		and Duel.IsExistingMatchingCard(s.fcheck2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,c)

	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()

	if op==0 then
		-- 分支 1：从手卡特召1只「永夜」怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 分支 2：包含自身的场上融合召唤
		if not (c:IsRelateToEffect(e) and c:IsFaceup() and c:IsCanBeFusionMaterial()) then return end
		local mg=Duel.GetFusionMaterial(tp):Filter(s.mfilter2,nil,e)
		if not mg:IsContains(c) then return end

		local sg=Duel.GetMatchingGroup(s.fcheck2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,c)
		if #sg==0 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if not tc then return end

		-- 原生接口：第四参数传入 c，强制融合素材中必须包含自身
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,c,tp)
		tc:SetMaterial(mat)
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end