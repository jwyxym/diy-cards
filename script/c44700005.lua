local s,id=GetID()
local HOLY_TWILIGHT=44770000

function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_ALL)
    e0:SetValue(0x474)
    c:RegisterEffect(e0)

    local ea=Effect.CreateEffect(c)
    ea:SetType(EFFECT_TYPE_SINGLE)
    ea:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    ea:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ea:SetRange(LOCATION_SZONE)
    ea:SetCondition(s.actcon)
    c:RegisterEffect(ea)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(2,id+100)
    e2:SetCondition(s.descon1)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+100)
    e3:SetCondition(s.descon2)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(2,id+100)
    e4:SetCondition(s.retcon)
    e4:SetTarget(s.rettg)
    e4:SetOperation(s.retop)
    c:RegisterEffect(e4)
end

function s.monster_filter(c)
    return c:IsType(TYPE_MONSTER) and not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

function s.no_other_attr(tp)
    local g1 = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g1) do
        if s.monster_filter(tc) then return false end
    end

    local g2 = Duel.GetMatchingGroup(s.monster_filter, tp, LOCATION_GRAVE, 0, nil)
    if g2:GetCount()>0 then return false end

    return true
end

function s.actcon(e)
    return s.no_other_attr(e:GetHandlerPlayer())
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
    return c:IsCode(HOLY_TWILIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.descon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.desfilter1,1,nil,tp)
end
function s.desfilter1(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.descon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.desfilter2,1,nil,tp)
end
function s.desfilter2(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
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

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_ONFIELD) then return false end
    if not re then return false end
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    return true
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end