-- No.8 纹章王 纹章褫夺 (ID: 98765404)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 关联卡片 Passcode（不明: 77571455）
	aux.AddCodeList(c,77571455)

	-- 超量召唤手续：4星「纹章兽」怪兽×3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x76),4,3)
	c:EnableReviveLimit()

	-- ①：自己·对方回合1次，把这张卡的1个超量素材取除，以场上1张表侧表示的卡为对象才能发动。那张卡的卡名当作「不明」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON) -- 补全对方回合提示时点
	e1:SetCountLimit(1) -- 单卡 1回合1次 (SOPT)
	e1:SetCost(s.codecost)
	e1:SetTarget(s.codetg)
	e1:SetOperation(s.codeop)
	c:RegisterEffect(e1)

	-- ②（自身生效）：选场上任意数量卡名为「不明」的卡无效，那之后可以超量召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON) -- 补全对方回合提示时点
	e2:SetCountLimit(1) -- 单卡 1回合1次 (SOPT)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	-- ②（素材赋予）：把这张卡作为超量素材中的「No.」超量怪兽获得相同的效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON) -- 补全对方回合提示时点
	e3:SetCondition(s.xmatcon)
	e3:SetCountLimit(1)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end

-- 编号注册：No.8
aux.xyz_number[id]=8

-- ==================== ① 效果：取除素材改名「不明」 ====================
function s.codecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(77571455)
end

function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and not chkc:IsCode(77571455) end
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.codefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(77571455)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- ==================== ② 效果：无效「不明」卡并加速超量 ====================
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	-- 素材赋予条件：必须是「No.」超量怪兽
	return e:GetHandler():IsSetCard(0x48) and e:GetHandler():IsType(TYPE_XYZ)
end

function s.disfilter(c)
	return c:IsFaceup() and c:IsCode(77571455) and aux.NegateAnyFilter(c)
end

function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,tp,LOCATION_ONFIELD)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local disabled=false
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		local sg=g:Select(tp,1,#g,nil)
		Duel.HintSelection(sg)
		for tc in aux.Next(sg) do
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
		disabled=true
	end

	-- “那之后”的 BreakEffect 独立时点切断
	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		if disabled then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		if xyz then
			Duel.XyzSummon(tp,xyz,nil)
		end
	end
end