--魔王的小槌
local cm,m,o=GetID()
Duel.LoadScript("c666PublicFunctionLibrary.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--Activate
	xiaoye.EquipActivateAndLimit(c,cm.eqlimit,true,true)
	--inactivatable
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(cm.effectfilter)
	c:RegisterEffect(e2)
	--damage
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(cm.damcon)
	e6:SetTarget(cm.damtg)
	e6:SetOperation(cm.damop)
	c:RegisterEffect(e6)
end
function cm.eqlimit(c)
    return c:IsRace(RACE_FIEND)
end
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function cm.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetEquipTarget():GetControler()
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function cm.effectfilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    return e:GetHandler():GetEquipTarget() and te:GetHandler()==e:GetHandler():GetEquipTarget()
end