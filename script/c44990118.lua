--梦境吐息
local s,id=GetID()
function s.initial_effect(c)
	-- 有「伊瑟拉」的卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 效果：双方主要阶段发动的抽卡与超量召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)

	-- ② 效果：结束阶段墓地回收
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end

-- 检查场上是否有「伊瑟拉」或有那个卡名记述的怪兽
function s.IsYseraOrListed(tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and (c:IsCode(44990100) or aux.IsCodeListed(c,44990100))
	end,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 条件：双方主要阶段 + 场上有符合要求的怪兽 + 同名牌本回合未发动
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_MAIN1 and Duel.GetCurrentPhase()<=PHASE_MAIN2)
		and s.IsYseraOrListed(tp)
		and Duel.GetFlagEffect(tp,id)==0
end

-- ① 目标：总是可以发动，设置同名牌一回合标志
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ① 操作
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 自己抽1张
	Duel.Draw(tp,1,REASON_EFFECT)

	-- 检查能否展示手牌的有「伊瑟拉」卡名记述的怪兽
	if not Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_HAND,0,1,nil) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

	-- 展示1张符合条件的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #sg==0 then return end
	Duel.ConfirmCards(1-tp,sg)

	-- 选自己墓地1只有记述的怪兽特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g==0 then return end
	local spc=g:GetFirst()
	if Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	-- 进行超量召唤：用包含那只怪兽的自己场上怪兽，超量召唤1只「伊瑟拉」怪兽
	s.XyzSummonFromSp(tp,spc,e)
end

-- 展示用过滤：手牌有记述的怪兽
function s.showfilter(c)
	return aux.IsCodeListed(c,44990100) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end

-- 特召用过滤：墓地有记述且能特召的怪兽
function s.spfilter(c,e,tp)
	return aux.IsCodeListed(c,44990100) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 超量召唤处理（手动兼容版）
function s.XyzSummonFromSp(tp, spc, e)
	-- 确认那只怪兽还在场上
	if not spc:IsLocation(LOCATION_MZONE) or not spc:IsFaceup() then return end

	-- 选择额外卡组的「伊瑟拉」超量怪兽
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=xyzg:Select(tp,1,1,nil):GetFirst()

	-- 素材数量默认为2（伊瑟拉超量怪兽均为2素材）
	local minc=2

	-- 场上能作为该超量素材的怪兽（必须包含 spc）
	local matg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsCanBeXyzMaterial(xyz) end,tp,LOCATION_MZONE,0,nil)
	if not matg:IsContains(spc) then return end
	if #matg<minc then return end

	-- 强制将 spc 加入素材，再选其余素材
	local mg=Group.FromCards(spc)
	if minc>1 then
		local remg=matg:Clone()
		remg:RemoveCard(spc)
		local need=minc-1
		if #remg<need then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=remg:Select(tp,need,need,nil)
		mg:Merge(sg)
	end

	-- 执行超量召唤（兼容方式）
	if Duel.SpecialSummonStep(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
		-- 叠放素材
		Duel.Overlay(xyz,mg)
		-- 完成召唤
		Duel.SpecialSummonComplete()
	end
end

-- 额外卡组的伊瑟拉超量怪兽过滤（接受 Effect 参数）
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

-- ② 条件：自己结束阶段，场上有「伊瑟拉」
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
		end,tp,LOCATION_MZONE,0,1,nil)
end

-- ② 目标：这张卡可以加入手卡
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- ② 操作：墓地回收
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end