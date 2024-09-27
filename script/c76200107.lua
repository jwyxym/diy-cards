--炽神界·火鸟神使
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),5,3,nil,nil,3)
	c:EnableReviveLimit()
	--get effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_XMATERIAL)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(cm.efilter)
	e0:SetCondition(cm.mcon)
	c:RegisterEffect(e0)
	--dam
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
	--lpcost replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_LPCOST_REPLACE)
	e3:SetCondition(cm.lrcon)
	e3:SetOperation(cm.lrop)
	c:RegisterEffect(e3)
end
function cm.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	local lp=Duel.GetLP(ep)
	if lp<ev then return false end
	if not re or not re:IsActivated() then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0x721)
end
function cm.lrop(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_TRAP) and e:GetHandler():GetFlagEffect(1)>0 then
		Duel.Damage(1-tp,700,REASON_EFFECT)
	end
end
function cm.mcon(e)
	return e:GetHandler():GetOriginalRace()==RACE_FAIRY
end
function cm.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and e:GetHandlerPlayer()~=te:GetOwnerPlayer() and te:IsActivated()
end