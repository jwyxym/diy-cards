local s, id,o = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id, LOCATION_FZONE)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)
    
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(s.atktg)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(1,0)
    e4:SetValue(s.acttg)
    c:RegisterEffect(e4)
    
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

function s.setfilter(c, tp)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_TRAP) and c:IsSSetable() 
        and (c:IsLocation(LOCATION_DECK) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_DECK, nil, 1, tp, LOCATION_DECK + LOCATION_REMOVED)
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then return end
    
    local g = Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_DECK + LOCATION_REMOVED, 0, nil, tp)
    if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
        local sg = g:Select(tp, 1, 1, nil)
        if #sg > 0 then
            Duel.SSet(tp, sg:GetFirst())
        end
    end
end

function s.atktg(e, c)
    return c:IsSetCard(0x1c6)
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(Card.IsType, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, nil, TYPE_TRAP) * 100
end

function s.acttg(e,re,tg)
    return re:IsActiveType(TYPE_MONSTER)
end

function s.cfilter(c)
	return c:IsSetCard(0x1c6) and c:IsFaceup()
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsSummonPlayer, 1, nil, 1 - tp) and 
           Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.thfilter(c)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:RandomSelect(1-tp,1)
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
