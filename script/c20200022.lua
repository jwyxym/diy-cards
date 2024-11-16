--爱丽丝，仙境的少女
function c20200022.initial_effect(c)
	c:SetUniqueOnField(1,0,c20200022.limit)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_MZONE+LOCATION_GRAVE)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsCode,20200003),6,2,nil,nil,99)
	c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c20200022.atkval)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20200022,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c20200022.copytg)
	e2:SetOperation(c20200022.copyop)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20200022,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c20200022.mttg)
	e3:SetOperation(c20200022.mtop)
	c:RegisterEffect(e3)
end
function c20200022.limit(c)
	return c:IsOriginalCodeRule(20200022)
end
function c20200022.atkval(e,c)
	return c:GetOverlayCount()*200
end
function c20200022.filter(c)
	return c:IsCode(20200003) and (c:IsType(TYPE_EFFECT) or c:IsType(TYPE_CONTINUOUS)) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not c:IsOriginalCodeRule(20200022)
end
function c20200022.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD) and c20200022.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20200022.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c20200022.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD,0,1,1,nil)
end
function c20200022.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(code)
		e1:SetLabel(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(20200022,2))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(c20200022.rstcon)
		e2:SetOperation(c20200022.rstop)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
function c20200022.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	return Duel.GetTurnPlayer()~=e1:GetLabel()
end
function c20200022.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c20200022.mtfilter(c)
	return c:IsSetCard(0xb31,0xb32) and c:IsCanOverlay()
end
function c20200022.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c20200022.mtfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_ONFIELD,0,1,e:GetHandler()) end
end
function c20200022.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,c20200022.mtfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end