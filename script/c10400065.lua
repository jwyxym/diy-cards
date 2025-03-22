--大千录 焚皮迎火
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.acon)
	e1:SetTarget(this.atg)
	e1:SetOperation(this.aop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(aux.bfgcost)
    e2:SetCondition(aux.exccon)
    e2:SetOperation(this.regop)
    c:RegisterEffect(e2)
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.Damage(tp,1000,REASON_EFFECT)>0 and Duel.Damage(1-tp,500,REASON_EFFECT)>0 then
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end
function this.regop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(this.damop)
	Duel.RegisterEffect(e1,tp)
end
function this.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,500,REASON_EFFECT,true)
    Duel.Damage(1-tp,500,REASON_EFFECT,true)
    Duel.RDComplete()
end
