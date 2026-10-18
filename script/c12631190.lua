-- 灰灭都的传说-英雄的赞歌
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad
local CARD_HAIMETSU_CITY=3055018
local CARD_VIDOS=78783557

function s.initial_effect(c)
    aux.AddLinkProcedure(c,s.matfilter,2,2)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.sscon)
    e1:SetTarget(s.sstg)
    e1:SetOperation(s.ssop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_HAIMETSU}

function s.matfilter(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_MONSTER)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.ssfilter(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    if not c then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        return not c:IsRace(RACE_PYRO)
    end
    return false
end

function s.cityfilter(c)
    return c:IsCode(CARD_HAIMETSU_CITY) and c:IsFaceup()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cityfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.thfilter(c)
    return c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thfilter2(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,tc)

    if tc:IsCode(CARD_VIDOS) then
        if Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end
