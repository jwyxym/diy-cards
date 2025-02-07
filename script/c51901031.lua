--《次元·方舟》迷途
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(this.setcost)
	e2:SetTarget(this.settg)
	e2:SetOperation(this.setop)
	c:RegisterEffect(e2)
end
function this.rmfilter(c)
    return c:IsSetCard(0x51c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function this.spfilter(c,e,tp)
    return (c:IsSetCard(0x51c) or Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsRace(RACE_MACHINE+RACE_PSYCHO)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.rmfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,this.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
    if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc2=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
        if tc2 then Duel.SpecialSummon(tc2,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP) end
    end
end
function this.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
