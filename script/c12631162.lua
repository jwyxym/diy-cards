-- 刻录机块 瑞科德鼹
local s,id=GetID()
local SET_KIHAI=0x014b

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.mvcost2)
    e2:SetTarget(s.mvtg2)
    e2:SetOperation(s.mvop2)
    c:RegisterEffect(e2)
end

s.listed_series={SET_KIHAI}

function s.cfilter1(c)
    return c:IsSetCard(SET_KIHAI) and c:IsAbleToRemoveAsCost()
end

function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.stfilter1(c)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsSSetable()
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    local g=Duel.GetMatchingGroup(s.stfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    end
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if Duel.IsExistingMatchingCard(s.stfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.stfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    end

    local e1=Effect.CreateEffect(c)
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

function s.mvcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.mvfilter2(c)
    return c:IsFaceup() and c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
end

function s.mvtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.mvfilter2,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
    end
end

function s.mvop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
    local g=Duel.SelectMatchingCard(tp,s.mvfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
        local nseq=math.floor(math.log(s,2)+0.5)
        Duel.MoveSequence(g:GetFirst(),nseq)
    end
end