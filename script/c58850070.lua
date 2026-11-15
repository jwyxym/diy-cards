local s,id=GetID()
local id_dream_inf = 58850000

function s.initial_effect(c)
    aux.AddCodeList(c, id_dream_inf)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

function s.ismonster(c)
    local code = c:GetCode()
    return c:IsType(TYPE_MONSTER) and (aux.IsCodeListed(c, id_dream_inf) or (code >= 58850010 and code <= 58850210))
end

function s.fieldfilter(c)
    return c:IsFaceup() and s.ismonster(c)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.fieldfilter, tp, LOCATION_MZONE, 0, nil)
    if g:GetCount() < 2 then return false end
    
    local mask = 0
    for tc in aux.Next(g) do
        mask = mask | tc:GetAttribute()
    end
    
    local count = 0
    local temp = mask
    while temp > 0 do
        if temp & 1 == 1 then count = count + 1 end
        temp = temp >> 1
    end
    return count >= 2
end

function s.spfilter(c,mask,e,tp)
    return s.ismonster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:GetAttribute() & mask) == 0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.fieldfilter,tp,LOCATION_MZONE,0,nil)
        local mask=0
        for tc in aux.Next(g) do
            mask=mask|tc:GetAttribute()
        end
        return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,mask,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.fieldfilter,tp,LOCATION_MZONE,0,nil)
    local mask=0
    for tc in aux.Next(g) do
        mask=mask|tc:GetAttribute()
    end

    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if ft1<=0 and ft2<=0 then return end

    local g_deck = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_DECK, 0, nil, mask, e, tp)
    local g_grave = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_GRAVE, 0, nil, mask, e, tp)
    local g_all = g_deck + g_grave

    if #g_all == 0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g_all:Select(tp,1,1,nil)
    if #sg==0 then return end
    
    local tc=sg:GetFirst()
    local targetp=tp
    if ft1>0 and ft2>0 then
        if Duel.SelectOption(tp, aux.Stringid(id,2), aux.Stringid(id,3))==1 then
            targetp=1-tp
        end
    elseif ft2>0 then
        targetp=1-tp
    end

    Duel.SpecialSummon(tc,0,tp,targetp,false,false,POS_FACEUP)
end

function s.desfilter(c,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SYNCHRO) and c:IsReason(REASON_MATERIAL)
        and c:GetReasonPlayer()==tp and c:GetPreviousControler()==1-tp
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.desfilter,1,nil,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end