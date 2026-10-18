-- 灰灭的焚墟呼魂
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad
local CARD_HAIMETSU_CITY=3055018
local CARD_VIDOS=78783557

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_HAIMETSU}

function s.thfilter(c)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.cityfilter(c)
    return c:IsCode(CARD_HAIMETSU_CITY) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)

    if Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)==0 then
        if Duel.IsExistingMatchingCard(s.cityfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
            local cg=Duel.SelectMatchingCard(tp,s.cityfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            if #cg>0 then
                local tc=cg:GetFirst()
                local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
                local target_player=op==0 and tp or 1-tp
                Duel.MoveToField(tc,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
            end
        end
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

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.vidosfilter(c,e,tp)
    return c:IsCode(CARD_VIDOS) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then
        return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.vidosfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,1-tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end

    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.vidosfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,1-tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
        end
    end
end