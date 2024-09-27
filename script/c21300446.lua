--涬溟之苍炎
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(this.acost)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,id+1)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(this.thtg)
	e3:SetOperation(this.thop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,this.counterfilter)
end
function this.counterfilter(c)
	return not (c:IsSummonType(SUMMON_TYPE_PENDULUM) and not c:IsSetCard(0x678))
end
function this.acost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c)
    return c:IsSummonType(SUMMON_TYPE_PENDULUM) and not c:IsSetCard(0x678)
end
function this.afilter(c)
    return c:IsSetCard(0x678) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_DECK,0,1,nil) end
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,this.afilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
        Duel.Destroy(dc,REASON_EFFECT)
    end
end
function this.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x678) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
    if tc then 
        if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end
