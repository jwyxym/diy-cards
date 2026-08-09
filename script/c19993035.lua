--
function c19993035.initial_effect(c)
	c:SetUniqueOnField(1,0,19993035)
	c:SetSPSummonOnce(19993035)
	--link summon
	aux.AddLinkProcedure(c,c19993035.lfilter,1,1)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c19993035.spcost)
	c:RegisterEffect(e0)
	--copy name and effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19993035,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19993035)
	e1:SetTarget(c19993035.copytg)
	e1:SetOperation(c19993035.copyop)
	c:RegisterEffect(e1)
	c19993035.sps_effect=e1
	--opponent monsters to facedown
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19993035,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,19993035+100)
	e2:SetTarget(c19993035.postg)
	e2:SetOperation(c19993035.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_MSET)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetCondition(c19993035.poscon)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c19993035.poscon)
	c:RegisterEffect(e5)
end
function c19993035.lfilter(c)
	return c:IsCode(19993012)
end
function c19993035.cfilter(c)
	return c:IsSetCard(0xb35) and bit.band(c:GetType(),0x20004)==0x20004 and c:IsFaceup()
end
function c19993035.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_LINK~=SUMMON_TYPE_LINK then return true end
	return Duel.IsExistingMatchingCard(c19993035.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
function c19993035.copyfilter(c)
	return c:IsCode(19993012) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED))
end
function c19993035.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c19993035.copyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19993035.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c19993035.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function c19993035.copyop(e,tp,eg,ep,ev,re,r,rp)
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
function c19993035.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end
function c19993035.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function c19993035.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
	--then, if opponent still has face-up cards, they must send all face-up cards to GY
	local fg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if #fg>0 then
		Duel.SendtoGrave(fg,REASON_EFFECT)
	end
end
