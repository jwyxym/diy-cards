-- 跃音萌行 稚曲同栖
-- ID: 26051986
-- 字段：跃音萌行 0x906
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.drcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_CANNOT_REMOVE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.indcon)
    c:RegisterEffect(e4)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.thfilter(c)
    return c:IsSetCard(0x906) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.drfilter(c)
    return c:IsSetCard(0x906) and c:IsType(TYPE_MONSTER)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end
function s.lkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE)
end
function s.indcon(e)
    return Duel.IsExistingMatchingCard(s.lkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end