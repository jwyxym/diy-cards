local s, id, o = GetID()

function s.initial_effect(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.nonsetcost)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
    
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCost(s.setcost)
    c:RegisterEffect(e2)
    
    local e3 = Effect.CreateEffect(c)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCost(s.gycost)
    e3:SetHintTiming(TIMING_END_PHASE)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    e3:SetCountLimit(1, id + o)
    c:RegisterEffect(e3)
end

function s.cfilter(c)
    return c:IsType(TYPE_TRAP) and not c:IsPublic()
end

function s.costcheck(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetActivityCount(tp, ACTIVITY_NORMALSUMMON) == 0
end

function s.nonsetcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return s.costcheck(e, tp, eg, ep, ev, re, r, rp) 
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetTargetRange(1, 0)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_CANNOT_MSET)
    Duel.RegisterEffect(e2, tp)
end

function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return (Duel.CheckLPCost(tp, math.ceil(Duel.GetLP(tp) / 2)) or 
                Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil)) and 
               s.costcheck(e, tp, eg, ep, ev, re, r, rp)
    end
    
    if not s.costcheck(e, tp, eg, ep, ev, re, r, rp) then 
        return false 
    end
    
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetTargetRange(1, 0)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_CANNOT_MSET)
    Duel.RegisterEffect(e2, tp)
    
    local b1 = Duel.CheckLPCost(tp, math.ceil(Duel.GetLP(tp) / 2))
    local b2 = Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil)
    
    if b1 and b2 then
        local op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
        if op == 0 then
            Duel.PayLPCost(tp, math.ceil(Duel.GetLP(tp) / 2))
        else
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
            local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
            Duel.ConfirmCards(1 - tp, g)
        end
    elseif b1 then
        Duel.PayLPCost(tp, math.ceil(Duel.GetLP(tp) / 2))
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
        local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.gycost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return s.costcheck(e, tp, eg, ep, ev, re, r, rp) and e:GetHandler():IsAbleToRemoveAsCost()
    end
    
    if not s.costcheck(e, tp, eg, ep, ev, re, r, rp) then 
        return false 
    end
    
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetTargetRange(1, 0)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_CANNOT_MSET)
    Duel.RegisterEffect(e2, tp)
    
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return e:IsCostChecked()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1c6, TYPES_NORMAL_TRAP_MONSTER, 800, 2200, 4, RACE_SPELLCASTER, ATTRIBUTE_WATER, POS_FACEUP, tp)
    end
    
    local c = e:GetHandler()
   
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
            Duel.SetOperationInfo(0, CATEGORY_TOHAND + CATEGORY_SEARCH, nil, 1, tp, LOCATION_DECK)
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1c6, TYPES_NORMAL_TRAP_MONSTER, 800, 2200, 4, RACE_SPELLCASTER, ATTRIBUTE_WATER, POS_FACEUP, tp) then 
        return 
    end
    
    c:AddMonsterAttribute(TYPE_NORMAL)
    
    if Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP) ~= 0 then
        local g = Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_DECK, 0, nil, tp)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            Duel.BreakEffect()
            local sg = g:Select(tp, 1, 1, nil)
            if #sg > 0 then
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end

function s.thfilter(c, tp)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end