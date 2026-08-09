-- 三魔官的契约融合
-- ID: 26051958
-- 字段：新星同盟 (0x902)
local s,id=GetID()
function s.initial_effect(c)
	-- 通常魔法发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- 同名卡一回合一次
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

-- 判断自己场上是否有「新星同盟」额外怪兽（融合/同调/超量/链接）
function s.extra_filter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsSetCard(0x902) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 构建素材池
		local mg=Group.CreateGroup()
		mg:Merge(Duel.GetFusionMaterial(tp))  -- 手卡+场上
		if Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_MZONE,0,1,nil) then
			-- 只追加卡组
			local g1=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_DECK,0,nil)
			mg:Merge(g1)
		end
		return Duel.IsExistingMatchingCard(function(tc)
			return tc:IsType(TYPE_FUSION) and tc:IsSetCard(0x902)
				and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
				and tc:CheckFusionMaterial(mg,nil,PLAYER_NONE)
		end,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 发动后立即登记一回合一次标记
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

	-- 构建素材池
	local mg=Group.CreateGroup()
	mg:Merge(Duel.GetFusionMaterial(tp))
	if Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_MZONE,0,1,nil) then
		-- 只追加卡组
		local g1=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_DECK,0,nil)
		mg:Merge(g1)
	end
	-- 选择融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,function(tc)
		return tc:IsType(TYPE_FUSION) and tc:IsSetCard(0x902)
			and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
			and tc:CheckFusionMaterial(mg,nil,PLAYER_NONE)
	end,tp,LOCATION_EXTRA,0,1,1,nil)
	local sc=sg:GetFirst()
	if not sc then return end
	-- 选择素材
	local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,PLAYER_NONE)
	if mat:GetCount()==0 then return end
	sc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()

    -- 自肃：本回合不能发动「新星同盟」怪兽以外的怪兽效果
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0x902)
end