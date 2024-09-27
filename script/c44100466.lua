--诺艾尔 武装红魔鬼
function c44100466.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,c44100466.synfilter1,aux.NonTuner(c44100466.synfilter2),1)
	c:EnableReviveLimit()
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44100466,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44100466)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44100466.eqcon)
	e1:SetTarget(c44100466.eqtg)
	e1:SetOperation(c44100466.eqop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100466,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44110466)
	e2:SetCost(c44100466.descost)
	e2:SetTarget(c44100466.destg)
	e2:SetOperation(c44100466.desop)
	c:RegisterEffect(e2) 
end
function c44100466.synfilter1(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_SYNCHRO)
end
function c44100466.synfilter2(c)
	return c:IsSetCard(0x44a)
end
function c44100466.eqcon(e)
	return e:GetHandler():GetEquipCount()==0
end
function c44100466.eqfilter(c)
	return c:IsSetCard(0x44a) and c:IsLevelBelow(6) and not c:IsForbidden()
end
function c44100466.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c44100466.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c44100466.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c44100466.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,tc,c) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c44100466.eqlimit)
		tc:RegisterEffect(e1)
		local def=tc:GetDefense()-400
		if def>0 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(math.ceil(def))
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(c44100466.repval)
			tc:RegisterEffect(e3)
		end
	end
end
function c44100466.eqlimit(e,c)
	return e:GetOwner()==c
end
function c44100466.repval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
function c44100466.desfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
function c44100466.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(c44100466.desfilter,1,nil,e:GetHandlerPlayer()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,c44100466.desfilter,1,1,nil,e:GetHandlerPlayer())
	Duel.SendtoGrave(g,REASON_COST)
end
function c44100466.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c44100466.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c44100466.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c44100466.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
