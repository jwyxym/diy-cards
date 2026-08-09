--梦境之龙麦琳瑟拉
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990100)

	-- 超量召唤手续：有「伊瑟拉」的卡名记述的8星怪兽×2
	aux.AddXyzProcedure(c, s.xyzfilter, 8, 2)
	c:EnableReviveLimit()

	-- ① 卡名当作「伊瑟拉」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(44990100)
	c:RegisterEffect(e1)

	-- ② 改变对方效果（取除全部素材）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)

	-- ③ 对方回合去1素材升阶超量召唤「伊瑟拉」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.xzcon)
	e3:SetCost(s.xzcost)
	e3:SetTarget(s.xztg)
	e3:SetOperation(s.xzop)
	c:RegisterEffect(e3)
end

-- 素材条件：有「伊瑟拉」记述即可，等级由引擎配合 EFFECT_XYZ_LEVEL 处理
function s.xyzfilter(c)
	return aux.IsCodeListed(c,44990100)
end

-- ② 条件
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if re:IsActiveType(TYPE_MONSTER) then return true end
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local rc=re:GetHandler()
		return rc:IsType(TYPE_SPELL) and not rc:IsType(TYPE_CONTINUOUS+TYPE_FIELD+TYPE_EQUIP+TYPE_RITUAL)
	end
	return false
end

-- ② 目标检查
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():GetOverlayCount()>0
			and Duel.IsExistingMatchingCard(s.ysfilter,1-tp,0,LOCATION_GRAVE,1,nil,REASON_EFFECT)
	end
end

-- ② 操作
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local og=c:GetOverlayGroup()
	if og:GetCount()==0 then return end
	Duel.SendtoGrave(og,REASON_EFFECT)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ysfilter,tp,0,LOCATION_GRAVE,1,1,nil,REASON_EFFECT)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

function s.ysfilter(c)
	return aux.IsCodeListed(c,44990100) and c:IsAbleToHand()
end

-- ③ 条件：对方回合
function s.xzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- ③ cost
function s.xzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ③ 可升阶的「伊瑟拉」超量怪兽（不限定阶级）
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

-- ③ 目标检查
function s.xztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ③ 操作：升阶超量召唤
function s.xzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			Duel.Overlay(sc,Group.FromCards(c))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end