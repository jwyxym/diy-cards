local s,id=GetID()
local id_toki=65200090

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c, aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE), aux.NonTuner(Card.IsRace,RACE_ZOMBIE), 1, 99)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(s.protcon)
    e2:SetTarget(s.prottg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_RELEASE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetCondition(s.thcon1)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.thcon2)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

function s.spcon(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.spfilter(c,e,tp) return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function s.spfilter2(c) return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsRace(RACE_ZOMBIE) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local b1 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
    local b2 = Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)

    local op=0
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b2 then op=1 end

    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
        if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
        if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
    end
end

function s.protcon(e) return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN) end
function s.prottg(e,c) return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_EFFECT) end

function s.thcon1(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(function(c) return c:IsType(TYPE_TOKEN) and c:GetPreviousControler()==tp end, 1, nil) end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(function(c) return c:IsType(TYPE_TOKEN) and c:GetPreviousControler()==tp and c:GetReasonPlayer()==1-tp end, 1, nil) end

function s.thfilter(c) return c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki) end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        local b2 = Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,RACE_ZOMBIE) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,id_toki)
        return b1 or b2
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local has_toki = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,id_toki)
    local f = function(c) return c:IsAbleToHand() and (s.thfilter(c) or (has_toki and c:IsRace(RACE_ZOMBIE))) end
    if Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
        if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
    end
end