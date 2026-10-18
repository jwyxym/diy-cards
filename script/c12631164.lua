-- 路由机块 鲁塔狐
local s,id=GetID()
local SET_KIHAI=0x014b
local CARD_KIHAI_WORLD=3875465

function s.initial_effect(c)
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_KIHAI),1,1)
    c:EnableReviveLimit()

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCondition(s.lkcon)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon1)
    e1:SetTarget(s.thtg1)
    e1:SetOperation(s.thop1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.reccon2)
    e2:SetCost(s.reccost2)
    e2:SetTarget(s.rectg2)
    e2:SetOperation(s.recop2)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.atkcon3)
    e3:SetOperation(s.atkop3)
    c:RegisterEffect(e3)
end

s.listed_series={SET_KIHAI}

function s.lkcon(e)
    return e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end

function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter1(c)
    return c:IsCode(CARD_KIHAI_WORLD) and c:IsAbleToHand()
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
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
    return not c:IsRace(RACE_MACHINE)
end

function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if Duel.GetTurnPlayer()==tp then
        return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
    else
        return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
    end
end

function s.reccost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.recfilter2(c,e,tp)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER) and c:IsLevel(1)
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.rectg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.recfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    end
end

function s.recop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.recfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()

    local tohand=tc:IsAbleToHand()
    local tosp=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0

    local op=0
    if tohand and tosp then
        op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif tohand then
        op=0
    elseif tosp then
        op=1
    else
        return
    end

    if op==0 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.atkcon3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:GetMutualLinkedGroupCount()>0
end

function s.atkop3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    if c:GetMutualLinkedGroupCount()==0 then return end

    local lg=Duel.GetMatchingGroup(s.linkfilter3,tp,LOCATION_MZONE,0,nil)
    local ct=0
    for lc in aux.Next(lg) do
        ct=ct+lc:GetLink()
    end
    if ct<=0 then return end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(-ct*100)
    e1:SetReset(RESET_PHASE+PHASE_BATTLE)
    Duel.RegisterEffect(e1,tp)
end

function s.linkfilter3(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK)
end