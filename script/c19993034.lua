--
function c19993034.initial_effect(c)
	c:SetUniqueOnField(1,0,19993034)
	c:SetSPSummonOnce(19993034)
	--link summon
	aux.AddLinkProcedure(c,c19993034.lfilter,1,1)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c19993034.spcost)
	c:RegisterEffect(e0)
	--copy name and effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19993034,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19993034)
	e1:SetTarget(c19993034.copytg)
	e1:SetOperation(c19993034.copyop)
	c:RegisterEffect(e1)
	c19993034.sps_effect=e1
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19993034,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,19993034+100)
	e2:SetCondition(c19993034.bancon)
	e2:SetTarget(c19993034.bantg)
	e2:SetOperation(c19993034.banop)
	c:RegisterEffect(e2)
end
function c19993034.lfilter(c)
	return c:IsCode(19993013)
end
function c19993034.cfilter(c)
	return c:IsSetCard(0xb35) and bit.band(c:GetType(),0x20004)==0x20004 and c:IsFaceup()
end
function c19993034.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	return Duel.IsExistingMatchingCard(c19993034.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
function c19993034.copyfilter(c)
	return c:IsCode(19993013) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED))
end
function c19993034.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c19993034.copyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19993034.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c19993034.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function c19993034.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		--copy name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetOriginalCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--copy effects
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,1)
	end
end
function c19993034.bancon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function c19993034.banfilter(c)
	return c:IsAbleToRemove()
end
function c19993034.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c19993034.banfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19993034.banfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c19993034.banfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c19993034.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
