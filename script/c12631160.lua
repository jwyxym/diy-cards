-- 空调机块 艾巴特蝠
local s,id=GetID()
local SET_KIHAI=0x014b

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetValue(s.spval)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.matcon)
    e2:SetTarget(s.mattg)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_KIHAI}

function s.linkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK)
end

function s.checkzone(tp)
    local zone=0
    local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        zone=bit.bor(zone,tc:GetLinkedZone(tp))
    end
    return bit.band(zone,0x1f)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local zone=s.checkzone(tp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end

function s.spval(e,c)
    local tp=c:GetControler()
    local zone=s.checkzone(tp)
    return 0,zone
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_MZONE) then return false end
    if not c:IsReason(REASON_MATERIAL+REASON_LINK) then return false end
    local rc=c:GetReasonCard()
    if not rc then return false end
    return rc:IsSetCard(SET_KIHAI) and rc:IsType(TYPE_LINK)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not c:IsCode(id)
end

function s.stfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    if Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
    end
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.stfilter,tp,0,LOCATION_SZONE,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
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
    return not c:IsRace(RACE_MACHINE)
end