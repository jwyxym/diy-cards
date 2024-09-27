--夹心酱 小邪神
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,0x80008),2,2)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.eqtg)
	e2:SetOperation(cm.eqop)
	c:RegisterEffect(e2)
    --
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(0x0c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,m+1)
	e1:SetCondition(cm.descon)
	e1:SetTarget(cm.destg)
	e1:SetOperation(cm.desop)
	c:RegisterEffect(e1)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x04) and chkc:IsFaceup() end
	if chk==0 then return not e:GetHandler():IsForbidden() and Duel.IsExistingTarget(Card.IsFaceup,tp,0x04,0x04,1,nil) and Duel.GetLocationCount(tp,0x08)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0x04,0x04,1,1,nil)
end

function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c,tc,ct=e:GetHandler(),Duel.GetFirstTarget(),Duel.GetLocationCount(tp,0x08)
    if c:IsRelateToChain() and not c:IsForbidden() and tc:IsRelateToChain() and tc:IsFaceup() and ct>0 then
        Duel.Equip(tp,c,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cm.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3)
    end
end

function cm.eqlimit(e,c)
	return e:GetLabelObject()==c
end

function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	local ph,ec=Duel.GetCurrentPhase(),e:GetHandler():GetEquipTarget()
	return (ph==PHASE_STANDBY or ph==PHASE_MAIN2) and (not ec or ec:GetControler()~=tp)
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(0x0c) end
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(aux.TRUE,tp,0x0c,0x0c,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0x0c,0x0c,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,nil,nil)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToChain() then
		local val1=aux.SequenceToGlobal(c:GetControler(),c:GetLocation(),c:GetSequence())
		if Duel.Remove(c,POS_FACEUP,REASON_EFFECT) then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToChain() then
				local val2=aux.SequenceToGlobal(tc:GetControler(),tc:GetLocation(),tc:GetSequence())
				if Duel.Destroy(tc,REASON_EFFECT) then
					val1=val1|val2
				end
			end
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_DISABLE_FIELD)
			e2:SetValue(val1)
			Duel.RegisterEffect(e2,tp)
		end
	end
end