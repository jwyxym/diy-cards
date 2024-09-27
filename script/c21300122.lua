--祭法魔女 守护
local m=21300122
local cm=_G["c"..m]
function c21300122.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.thcon)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,m+100)
	e2:SetTarget(cm.desreptg)
	e2:SetValue(cm.desrepval)
	e2:SetOperation(cm.desrepop)
	c:RegisterEffect(e2)
end
function cm.repfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) end
function cm.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(cm.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) and c:IsReleasable() end,tp,LOCATION_HAND,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function cm.desrepval(e,c)
	return cm.repfilter(c,e:GetHandlerPlayer())
end
function cm.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) and c:IsReleasable() end,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.Release(tc,REASON_EFFECT)
end
function cm.spnfilter(c,e,tp)
	return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(cm.spnfilter,1,nil,e,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e) then
Duel.Destroy(tc,REASON_EFFECT)
end
end


