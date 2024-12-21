--亡骨邪界龙
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100400)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.sumcost)
    e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
    --effect
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+o)
    e1:SetCost(s.cost)
	e1:SetOperation(s.ceop)
	c:RegisterEffect(e1)
    s.sum_effect=e1
end
--sum
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_DRAGON)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_DRAGON) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
--ef
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToGraveAsCost() 
    and ((c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_DRAGON) and c:IsAttack(1550) and c:IsDefense(1250)) or c:IsCode(11100400))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
    local sc=g:GetFirst()
	Duel.SendtoGrave(sc,REASON_COST)
    sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local sc=e:GetLabelObject()
	if sc:IsRelateToEffect(e)  then
        if sc:IsLevel(4) then
            local te=sc.sum_effect
            local op=te:GetOperation()
            if op then op(e,tp,eg,ep,ev,re,r,rp) end
        else
            if sc:IsLevel(8) then
            Duel.Draw(tp,1,REASON_EFFECT)
                if c:IsFaceup() then
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CHANGE_CODE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    e1:SetValue(11100400)
                    e:GetHandler():RegisterEffect(e1)
                    local e2=Effect.CreateEffect(e:GetHandler())
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e2:SetCode(EFFECT_CHANGE_LEVEL)
                    e2:SetValue(8)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    e:GetHandler():RegisterEffect(e2)
                end
            end
        end
	end
end