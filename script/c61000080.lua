-- 孽灾 瓦尔基亚 (ID: 61000080)
local s,id,o=GetID()
local CARD_BLACK_SHARK_DRONE=61000081 -- 「黑鲨子机」

function s.initial_effect(c)
	-- 超量召唤手续：8星怪兽×3
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- 记述卡号关联
	aux.AddCodeList(c,CARD_BLACK_SHARK_DRONE)

	-- ①：双方回合1次，给对方怪兽装备「黑鲨子机」，若由③特召则可追加里侧除外并加攻
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	-- ②：向攻击力较低怪兽攻击的伤步开始时，那只怪兽里侧除外＋回血＋继续攻击
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	-- ③：因对方从场上离开的场合，支付一半基本分特殊召唤（决斗中只能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL) -- 决斗限制宏
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果逻辑 ====================

function s.eqfilter(c)
	return c:IsCode(CARD_BLACK_SHARK_DRONE) and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	local ec=g:GetFirst()
	if not ec then return end

	if not Duel.Equip(tp,ec,tc) then return end

	-- 装备限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)

	-- 若是由③效果特殊召唤的场合，可以追加里侧除外并加攻
	if c:GetFlagEffect(id)~=0 and tc:IsAbleToRemove(tp,POS_FACEDOWN) and ec:IsAbleToRemove(tp,POS_FACEDOWN)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local rg=Group.FromCards(tc,ec)
		Duel.BreakEffect()
		if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			local atk=0
			for rc in aux.Next(og) do
				local batk=rc:GetBaseAttack()
				if batk>0 then atk=atk+batk end
			end
			if atk>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(atk)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
			end
		end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

-- ==================== ② 效果逻辑 ====================

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c==Duel.GetAttacker() and bc and bc:IsControler(1-tp) and bc:GetAttack()<c:GetAttack()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsAbleToRemove(tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
	local batk=bc:GetBaseAttack()
	if batk>0 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,batk)
	end
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() and Duel.Remove(bc,POS_FACEDOWN,REASON_EFFECT)>0 then
		local batk=bc:GetBaseAttack()
		if batk>0 then
			Duel.BreakEffect()
			Duel.Recover(tp,batk,REASON_EFFECT)
		end
		-- 连续攻击处理
		if c:IsRelateToBattle() then
			Duel.ChainAttack()
		end
	end
end

-- ==================== ③ 效果逻辑 ====================

-- 判定因对方从场上离开（对齐冰剑龙官方逻辑）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:GetReasonPlayer()==1-tp
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 标记由③效果特殊召唤成功，持续至离场
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end