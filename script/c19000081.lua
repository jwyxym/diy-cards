--统·治·者 灵龙
function c19000081.initial_effect(c)
	c:SetUniqueOnField(1,0,19000081)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c19000081.mfilter,nil,2,99)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19000081.atkval)
	c:RegisterEffect(e1)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000081,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19000081.condition)
	e1:SetTarget(c19000081.target)
	e1:SetOperation(c19000081.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCountLimit(1,19000081)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCountLimit(1,19000081)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(c19000081.dreptg)
	e3:SetOperation(c19000081.drepop)
	c:RegisterEffect(e3)
end
function c19000081.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,9) or (c:IsType(TYPE_XYZ) and c:IsRank(9))
end
function c19000081.atkval(e,c)
	return Duel.GetOverlayCount(c:GetControler(),LOCATION_MZONE,1)*300
end
function c19000081.cfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk and not c:IsType(TYPE_TOKEN) and c:IsCanOverlay()
end
function c19000081.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19000081.cfilter,1,nil,e:GetHandler():GetAttack()) and not eg:IsContains(e:GetHandler())
end
function c19000081.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c19000081.cfilter,nil,e:GetHandler():GetAttack())
	Duel.SetTargetCard(g)
end
function c19000081.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetHandler():GetAttack()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(c19000081.cfilter,nil,e:GetHandler():GetAttack())
	if g:GetFirst():GetOverlayCount()>0 then Duel.SendtoGrave(g:GetFirst():GetOverlayGroup(),REASON_RULE) end
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
function c19000081.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local atk=e:GetHandler():GetAttack()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c19000081.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end