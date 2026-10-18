local s,id=GetID()
local HOLY=0x474

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(2,id+100)
    e2:SetCondition(s.damcon1)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+100)
    e3:SetCondition(s.damcon2)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
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

function s.thfilter(c)
    return c:IsSetCard(HOLY) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end

function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.damfilter1,1,nil,tp)
end
function s.damfilter1(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.damfilter2,1,nil,tp)
end
function s.damfilter2(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,700,REASON_EFFECT)
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_ONFIELD) then return false end
    if not c:IsPreviousPosition(POS_FACEUP) then return false end
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