local s,id=GetID()

function s.spell_filter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL)
end

function s.initial_effect(c)
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
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DEFCHANGE+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.damcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)
end

function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(s.spell_filter,tp,LOCATION_SZONE,LOCATION_SZONE,2,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.setcon(e,tp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local owner=c:GetControler()
    return eg:IsExists(Card.IsControler,1,nil,1-owner)
        and Duel.IsExistingMatchingCard(s.spell_filter,owner,LOCATION_SZONE,0,3,nil)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,1000,REASON_EFFECT)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,1-tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetValue(-1500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
    local dg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetDefense()<=0 end, 1-tp, LOCATION_MZONE, 0, nil)
    if dg:GetCount()>0 then
        Duel.SendtoGrave(dg, REASON_EFFECT)
    end
end