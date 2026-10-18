--机块维修工坊
local s,id=GetID()
local SET_KIHAI=0x014b

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_MOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.atktg)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,id+100)
    e4:SetTarget(s.tdtg)
    e4:SetOperation(s.tdop)
    c:RegisterEffect(e4)
end

s.listed_series={SET_KIHAI}

function s.mvfilter(c,tp)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
        and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.mvfilter,1,nil,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

function s.linkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK)
end

function s.atktg(e,c)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local lg=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
    local ct=0
    for lc in aux.Next(lg) do
        ct=ct+lc:GetLink()
    end
    return ct*100
end

function s.tdfilter(c)
    if c:IsLocation(LOCATION_GRAVE) then
        return c:IsSetCard(SET_KIHAI) and c:IsAbleToDeck()
    end
    if c:IsLocation(LOCATION_REMOVED) then
        return c:IsFaceup() and c:IsSetCard(SET_KIHAI) and c:IsAbleToDeck()
    end
    return false
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
            and Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not g then return end
    local tg=g:Filter(s.tdfilter,nil)
    if #tg<3 then return end

    local sg=Group.CreateGroup()
    local cg=tg:Clone()
    for i=1,3 do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tc=cg:Select(tp,1,1,nil):GetFirst()
        sg:AddCard(tc)
        cg:RemoveCard(tc)
    end

    Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)

    if Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end