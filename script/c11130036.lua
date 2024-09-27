--陨宇祀圣之震慑
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(this.condition)
	e1:SetTarget(this.target)
	e1:SetOperation(this.operation)
	c:RegisterEffect(e1)
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0xa63)
		and Duel.IsChainNegatable(ev)
end
function this.thfilter(c)
    return c:IsSetCard(0xa63) and c:IsLevel(4) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function this.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
    local v1,v2,v3=0,1,2
    local b1,b2,b3=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) and Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil),
                    Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil),
                    Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0xa63)
    if not (b1 or b2 or b3) then return end
    if not b1 then v1,v2,v3=v1-1,v2-1,v3-1 end
    if not b2 then v2,v3=v2-1,v3-1 end
    if not b3 then v3=v3-1 end
    local op={}
    if b1 then table.insert(op,aux.Stringid(id,0)) end
    if b2 then table.insert(op,aux.Stringid(id,1)) end
    if b3 then table.insert(op,aux.Stringid(id,2)) end
    local v=Duel.SelectOption(tp,table.unpack(op))
    if v==v1 and b1 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
        if tc then Duel.SendtoHand(tc,tp,REASON_EFFECT) end
    elseif v==v2 and b2 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
        if tc then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
    else
        local g=Duel.GetMatchingGroup(this.filter,tp,LOCATION_MZONE,0,nil)
        local tc=g:GetFirst()
        while tc do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,3))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            tc=g:GetNext()
        end
    end
end
function this.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
