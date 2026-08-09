-- No.8 纹章王 虚饰 (ID: 98765403)
local s,id,o=GetID()
-- 种族宏兼容（防止 RACE_PSYCHO/RACE_PSYCHIC 因环境差异取到 nil 导致 c:IsRace(nil) 返回 false）
local RACE_PSYCHO = RACE_PSYCHO or RACE_PSYCHIC or 0x100000

function s.initial_effect(c)
	-- Xyz 召唤手续：4星「纹章兽」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x76),4,2)
	c:EnableReviveLimit()
	-- 关联卡片 Passcode（不明: 77571455）
	aux.AddCodeList(c,77571455)

	-- ①：1回合1次，把这张卡的1个超量素材取除才能发动。从自己的卡组把1张「纹章」卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1) -- SOPT (单卡1回合1次)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tgtg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，以自己场上1只念动力族超量怪兽为对象才能发动。把墓地的这张卡重叠在那只怪兽下面作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id) -- ②效果 HOPT
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.tgtg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- ③：把这张卡作为超量素材中的「No.」超量怪兽得到以下效果。
	-- ●自己·对方回合1次，可以发动。把1只念动力族「No.」超量怪兽在这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽不能作为超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1) -- 单卡1回合1次
	e3:SetCondition(s.xmatcon)
	e3:SetTarget(s.bullettg)
	e3:SetOperation(s.bulletop)
	c:RegisterEffect(e3)
end

-- 编号注册：No.8
aux.xyz_number[id]=8

-- ==================== ① 效果：检索/送墓「纹章」卡 ====================
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.filter1(c)
	return (c:IsSetCard(0x92) or c:IsSetCard(0x76)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	local b2=tc:IsAbleToGrave()
	if b1 and b2 then
		local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		if op==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	elseif b1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

-- ==================== ② 效果：墓地自身垫入念动力族超量怪兽 ====================
function s.filter2(c)
	-- 严格按照卡文：必须是【表侧表示】+【念动力族 (0x100000)】+【超量怪兽】
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end

function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

-- ==================== ③ 效果：素材赋予（直接重叠超量召唤） ====================
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end

function s.bulletfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsRace(RACE_PSYCHO)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function s.bullettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
			and Duel.IsExistingMatchingCard(s.bulletfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.bulletop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsImmuneToEffect(e) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.bulletfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
	local sc=g:GetFirst()
	if sc then
		-- 继承原怪兽的全部超量素材
		local mg=c:GetOverlayGroup()
		if #mg>0 then
			Duel.Overlay(sc,mg)
		end
		mg:AddCard(c)
		sc:SetMaterial(mg)
		Duel.Overlay(sc,Group.FromCards(c))
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			-- 限制：不能作为超量召唤的素材
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
		end
	end
end