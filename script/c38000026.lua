--惑星兽 尼德霍格
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1380),aux.NonTuner(nil),1,1)
    c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.thcon)
	e1:SetTarget(this.thtg)
	e1:SetOperation(this.thop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(this.tgcost)
    e2:SetTarget(this.tgtg)
    e2:SetOperation(this.tgop)
    c:RegisterEffect(e2)
end
function this.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function this.thfilter(c)
	return c:IsCode(38000031) and c:IsAbleToHand()
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function this.tgfilter(c,lv)
    return c:IsSetCard(0x1380) and c:IsLevelBelow(4) and c:GetLevel()<lv
end
function this.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,500) end
		Duel.PayLPCost(1-tp,500)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,500) end
		Duel.PayLPCost(tp,500)
	end
end
function this.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.tgfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetLevel()) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function this.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.tgfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetLevel()):GetFirst()
    if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
    end
end
