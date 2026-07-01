-- 无垠轨途 街角补给
-- ID: 26051939
-- 字段: 无垠轨途 (0x903)
local s,id=GetID()
function s.initial_effect(c)
	-- ① 卡的发动：以自己墓地1只「无垠轨途」怪兽为对象特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ② 墓地效果：除外自身，用自己的手卡·场上「无垠轨途」怪兽融合召唤，附加自肃
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCost(s.fucost)
	e2:SetTarget(s.futg)
	e2:SetOperation(s.fuop)
	c:RegisterEffect(e2)
end

-- ① 目标：自己墓地1只「无垠轨途」怪兽
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x903) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ② cost：除外墓地的这张卡
function s.fucost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ② 素材过滤：自己的手卡·场上「无垠轨途」怪兽
function s.fufilter(c)
	return c:IsSetCard(0x903) and c:IsCanBeFusionMaterial()
end
-- ② 检查额外卡组是否存在可融合怪兽
function s.ffilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,PLAYER_NONE)
end
function s.futg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 收集素材：自己场上+手牌的「无垠轨途」怪兽
		local mg=Duel.GetFusionMaterial(tp):Filter(s.fufilter,nil)
		local mg2=Duel.GetMatchingGroup(s.fufilter,tp,LOCATION_HAND,0,nil)
		mg:Merge(mg2)
		return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fuop(e,tp,eg,ep,ev,re,r,rp)
	-- 自肃：直到回合结束，不是「无垠轨途」怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 构建素材池
	local mg=Duel.GetFusionMaterial(tp):Filter(s.fufilter,nil)
	local mg2=Duel.GetMatchingGroup(s.fufilter,tp,LOCATION_HAND,0,nil)
	mg:Merge(mg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local sc=sg:GetFirst()
	if not sc then return end
	local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,PLAYER_NONE)
	if mat:GetCount()==0 then return end
	sc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x903)
end