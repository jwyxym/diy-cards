local s,id=GetID()
local id_dream_inf = 58850000

function s.initial_effect(c)
    aux.AddCodeList(c, id_dream_inf)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.efcon)
    e2:SetTarget(s.eftg)
    e2:SetOperation(s.efop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,id_dream_inf)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local targetp=tp
    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    
    if ft1>0 and ft2>0 then
        if Duel.SelectOption(tp, aux.Stringid(id,2), aux.Stringid(id,3))==1 then
            targetp=1-tp
        end
    elseif ft2>0 then
        targetp=1-tp
    elseif ft1<=0 then
        return
    end
    Duel.SpecialSummon(c,0,tp,targetp,false,false,POS_FACEUP)
end

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end

function s.thfilter(c)
    return c:IsRace(RACE_PSYCHO) and c:IsLevel(3) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=c:IsPreviousControler(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
    local b2=not c:IsPreviousControler(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    
    if chk==0 then return b1 or b2 end
    
    if b1 then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
    else
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPreviousControler(tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end