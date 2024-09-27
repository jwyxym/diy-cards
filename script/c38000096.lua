--惑星吞噬
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCost(this.discost)
	e3:SetTarget(this.distg)
	e3:SetOperation(this.disop)
	c:RegisterEffect(e3)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCost(this.thcost)
    e1:SetTarget(this.thtg)
    e1:SetOperation(this.thop)
    c:RegisterEffect(e1)
end
function this.rmfilter(c)
	return c:IsSetCard(0x380) and c:IsAbleToRemoveAsCost()
end
function this.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,this.rmfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetLabel(g:GetBaseAttack())
end
function this.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function this.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT) then
		Duel.BreakEffect()
        Duel.Recover(tp,e:GetLabel(),REASON_EFFECT)
	end
end
function this.thfilter(c)
    return c:IsSetCard(0x380) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function this.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b=e:GetHandler():IsAbleToRemoveAsCost()
    if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
        if chk==0 then return Duel.CheckLPCost(1-tp,1000) and b end
        Duel.PayLPCost(1-tp,1000)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
    else
        if chk==0 then return Duel.CheckLPCost(tp,1000) and b end
        Duel.PayLPCost(tp,1000)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
    end
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if tc then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
