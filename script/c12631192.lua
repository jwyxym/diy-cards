-- 灰灭的熔灰胄
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id+o)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

s.listed_series={SET_HAIMETSU}

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqlimit(e,c)
    return e:GetOwner()==c
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(s.eqlimit)
        c:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetTargetRange(1,0)
        e2:SetTarget(s.splimit)
        Duel.RegisterEffect(e2,tp)
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    if not c then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        return not c:IsRace(RACE_PYRO)
    end
    return false
end

function s.atkfilter(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_MONSTER)
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
    return ct*200
end

function s.thfilter(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToHand()
            and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,c)
        if g:GetCount()>0 then
            Duel.HintSelection(g)
            g:AddCard(c)
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
