--倾墨 留清
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddLinkProcedure(c,this.matfilter,2,2,this.matcheck)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(this.con)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.matfilter(c)
    return c:IsRace(RACE_CYBERSE)
end
function this.matcheck(g)
    return g:IsExists(Card.IsSetCard,1,nil,0x677)
end
function this.filter(c)
    return c:IsRace(RACE_CYBERSE) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function this.gcheck(g)
    return g:IsExists(Card.IsSetCard,1,nil,0x677)
end
function this.thfilter(c)
    return c:IsSetCard(0x677) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(this.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
    if chk==0 then return g:CheckSubGroup(this.gcheck,2,2)
        and Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,tp,LOCATION_GRAVE+LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(this.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tg=g:SelectSubGroup(tp,this.gcheck,false,2,2)
    if tg and #tg==2 and Duel.SendtoDeck(tg,tp,LOCATION_DECKSHF,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if tc then
            Duel.SendtoHand(tc,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end
