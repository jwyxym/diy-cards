--大千录 剥皮覆物
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.acon)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(this.rtg)
    e2:SetOperation(this.rop)
    c:RegisterEffect(e2)
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>PHASE_MAIN1 and ph<PHASE_MAIN2
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_DISABLE)
    e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e7:SetTarget(this.distg)
    e7:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e7,tp)
    Duel.Damage(tp,1000,REASON_EFFECT)
end
function this.distg(e,c)
	return c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0
end
function this.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function this.rop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Recover(tp,1000,REASON_EFFECT) then
        Duel.BreakEffect()
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end
