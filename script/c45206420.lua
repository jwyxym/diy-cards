--缚魂灵-轮回殿
local s,id=GetID()
function s.initial_effect(c)
	-- 永续陷阱的卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ① 场上二速融合（每回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0, TIMING_MAIN_END+TIMING_END_PHASE+TIMING_BATTLE_START)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fuscost)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
	e1:SetLabelObject(e0)

	-- ② 自己·对方的准备阶段，回收最多5张卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.tdcost)       -- ★ 补回：Cost 除外
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

-- ================= ① 效果 =================

function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,1,nil,tp)
	end
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.costfilter(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

function s.fusfilter(c,e,tp,m,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and c:CheckFusionMaterial(m,nil,chkf)
end

function s.ofilter(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end

function s.mfilter(c,e)
	return c:IsOnField() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	if chk==0 then
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
		local mg2=Duel.GetMatchingGroup(s.ofilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,PLAYER_ALL,LOCATION_MZONE)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
	local mg2=Duel.GetMatchingGroup(s.ofilter,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,chkf)
	if sg:GetCount()==0 then return end
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
	if not mat or mat:GetCount()==0 then return end
	tc:SetMaterial(mat)

	-- ★ 核心：完全保留你的完美离场判定
	for sc in aux.Next(mat) do
		local redirect = sc:IsHasEffect(EFFECT_LEAVE_FIELD_REDIRECT)
		if redirect then
			redirect:Reset()
			Duel.Remove(sc, POS_FACEUP, REASON_EFFECT+REASON_MATERIAL+REASON_FUSION, sc:GetOwner())
		else
			if sc:IsType(TYPE_MONSTER) and sc:IsExtraDeckMonster() then
				Duel.SendtoDeck(sc, tp, SEQ_DECKBOTTOM, REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				if sc:IsLocation(LOCATION_DECK) then
					Duel.SendtoDeck(sc, tp, SEQ_DECKBOTTOM, REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				end
			else
				Duel.SendtoDeck(sc, tp, SEQ_DECKSHUFFLE, REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			end
		end
	end
	Duel.BreakEffect()

	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

-- ================= ② 效果 =================

-- ★ 补回：② 效果的 Cost 除外
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tdcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,1,nil,tp)
	end
	local g=Duel.GetMatchingGroup(s.tdcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tdcostfilter(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

function s.tdfilter(c)
	return c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		local max_count = math.min(5, g:GetCount())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,max_count,nil)
		if sg:GetCount()>0 then
			Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

return s