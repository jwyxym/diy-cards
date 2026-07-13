--翡翠幼龙
local s,id=GetID()
function s.initial_effect(c)
	-- 标记为有「伊瑟拉」卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 对方发动怪兽效果时，丢1手卡特召自身（一回合一次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ② 特殊召唤成功时，超量召唤「伊瑟拉」并填充素材（一回合一次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)

	-- ②发动后的自肃：非风属性不能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.splimcon)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
end

-- ① 条件：对方发动怪兽效果 + 一回合一次
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.GetFlagEffect(tp,id)==0
end

-- ① cost：丢弃手卡1张此卡以外的卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

-- ① 目标：确认可以特召
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- ① 操作：特殊召唤并设置标志
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ② 条件：一回合一次
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
end

-- ② 目标：额外有伊瑟拉，墓地有记述伊瑟拉的怪兽
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFlagEffect(tp,id+100)>0 then return false end
		if not Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then return false end
		if not Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		return true
	end
end

-- 额外卡组的伊瑟拉
function s.xyzfilter(c,e,tp)
	return c:IsCode(44990100) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- 墓地记述「伊瑟拉」的怪兽（兼容）
function s.mfilter(c)
	if aux.IsCodeListed then
		return aux.IsCodeListed(c,44990100) and c:IsType(TYPE_MONSTER)
	else
		return c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
	end
end

-- ② 操作：特召伊瑟拉并叠放素材
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+100)>0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	-- 选择额外卡组的伊瑟拉
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #xg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=xg:Select(tp,1,1,nil):GetFirst()

	-- 选择墓地1只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,s.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #mg==0 then return end

	-- 特殊召唤伊瑟拉（视为超量召唤）
	if Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将场上的这张卡与墓地怪兽作为超量素材
		local og=Group.FromCards(c,mg:GetFirst())
		Duel.Overlay(xyz,og)

		-- 设置一回合一次标志与自肃标志
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end

-- 自肃条件
function s.splimcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+200)>0
end

-- 禁止非风属性特殊召唤
function s.splimit(e,c,tp,sumtp)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end