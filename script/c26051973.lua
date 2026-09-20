-- 兔女郎 凛
-- ID: 26051973
-- 字段：跃音萌行 0x906 / 凛 0x907
local s,id=GetID()
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
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.lkcon)
    e2:SetCost(s.lkcost)
    e2:SetTarget(s.lktg)
    e2:SetOperation(s.lkop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x908) or c:IsSetCard(0x909))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x906)
end

function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
        and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.lkfilter(c)
    return c:IsType(TYPE_LINK) and c:GetLink()>=3
        and c:IsRace(RACE_CYBERSE)
        and c:IsLinkSummonable(nil)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.LinkSummon(tp,tc,nil)
    end
end