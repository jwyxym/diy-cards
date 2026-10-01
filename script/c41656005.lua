-- 一日蓝堇的临照
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--① 伤害计算时，将手卡·场上的这张卡给对方确认，以场上1张卡为对象
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(3,id)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--② 免疫对方蓝堇卡效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end

-- ① 条件：任何战斗（含直接攻击）
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()~=nil
end

-- ① cost：将手卡的这张卡给对方确认
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (c:IsLocation(LOCATION_HAND) and not c:IsPublic()) or c:IsLocation(LOCATION_MZONE) end
	if c:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,c)
		Duel.ShuffleHand(tp)
	end
end

-- ① target：场上1张卡
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ① 赋予字段
function s.codefilter(c,code)
	return c:IsCode(code) and not c:IsSetCard(0xe96)
end

-- ① operation：解放/赋予字段 + 在场时永久加攻
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsSetCard(0xe96) then
			Duel.Release(tc,REASON_EFFECT)
		else
			local code=tc:GetCode()
			local cg=Duel.GetMatchingGroup(s.codefilter,tp,
				LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,
				LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,nil,code)
			local tc2=cg:GetFirst()
			while tc2 do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
				e1:SetValue(0xe96)
				tc2:RegisterEffect(e1)
				tc2=cg:GetNext()
			end
		end
	end
	-- 这张卡在场上时，永久 +1750
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1750)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

-- ② 免疫
function s.efilter(e,te)
	return te:GetHandler():IsSetCard(0xe96) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end