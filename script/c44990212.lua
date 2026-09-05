--奈法利安的融合符文
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990201)

	-- ① 通常魔法的融合效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ② 从卡组以外送墓时盖放（无次数限制）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end

function s.mfilter_field(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.mfilter_grave(c)
	return c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end

-- 获取可融合的融合怪兽组（已过滤素材不足的怪兽）
function s.GetUsableFusionMonsters(tp)
	local chkf=tp
	local mg_self = Duel.GetMatchingGroup(s.mfilter_field,tp,LOCATION_MZONE,0,nil)
	local mg_grave_self = Duel.GetMatchingGroup(s.mfilter_grave,tp,LOCATION_GRAVE,0,nil)
	mg_self:Merge(mg_grave_self)

	local mg_opp = Duel.GetMatchingGroup(s.mfilter_grave,tp,0,LOCATION_GRAVE,nil)

	local fg = Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
	local usable = Group.CreateGroup()
	for fc in aux.Next(fg) do
		local mg = mg_self:Clone()
		if aux.IsCodeListed(fc,44990201) then
			mg:Merge(mg_opp)
		end
		if fc:CheckFusionMaterial(mg,nil,chkf) then
			usable:AddCard(fc)
		end
	end
	return usable, mg_self, mg_opp
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local usable = s.GetUsableFusionMonsters(tp)
		return #usable>0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local usable, mg_self, mg_opp = s.GetUsableFusionMonsters(tp)
	if #usable==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fc = usable:Select(tp,1,1,nil):GetFirst()

	local mg = mg_self:Clone()
	if aux.IsCodeListed(fc,44990201) then
		mg:Merge(mg_opp)
	end

	-- 选择融合素材
	local mat = Duel.SelectFusionMaterial(tp,fc,mg,nil,chkf)
	if not mat or #mat==0 then return end

	-- 先设置素材，再送回卡组（关键修正）
	fc:SetMaterial(mat)
	Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

	-- 融合召唤
	Duel.BreakEffect()
	Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	fc:CompleteProcedure()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,c)
	end
end