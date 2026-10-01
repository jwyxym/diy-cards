local s,id=GetID()
local NM=0x32a

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop2)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

function s.matfilter1(c)
    return c:IsSetCard(NM)
end
function s.matfilter2(c)
    return c:IsSetCard(NM)
end

function s.spfilter1(c)
    return c:IsSetCard(NM) and c:IsLevelAbove(6)
end
function s.spfilter2(c)
    return c:IsSetCard(NM) and c:IsLevelBelow(2)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
    if #g1==0 or #g2==0 then return false end
    for tc1 in aux.Next(g1) do
        for tc2 in aux.Next(g2) do
            local diff=math.abs(tc1:GetLevel()-tc2:GetLevel())
            if diff<=4 and diff>0 then return true end
        end
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
    local tg=Group.CreateGroup()
    for tc1 in aux.Next(g1) do
        for tc2 in aux.Next(g2) do
            local diff=math.abs(tc1:GetLevel()-tc2:GetLevel())
            if diff<=4 and diff>0 then
                tg:AddCard(tc1)
                tg:AddCard(tc2)
                break
            end
        end
        if #tg>0 then break end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=tg:Select(tp,2,2,nil)
    Duel.SendtoGrave(sg,REASON_COST)
end

function s.fusfilter(c)
    return c:IsLevelBelow(4) or (c:IsType(TYPE_XYZ) and c:GetRank()<=4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.spop2(e,tp)
    local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg1=g:Select(tp,1,1,nil)
    local tc1=sg1:GetFirst()
    local g2=g:Filter(function(c) return c~=tc1 end,nil)
    if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg2=g2:Select(tp,1,1,nil)
        local tc2=sg2:GetFirst()
        Duel.SendtoDeck(tc2,nil,2,REASON_EFFECT)
    end
    if tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.negcon(e,tp)
    return Duel.GetFlagEffect(tp,id)>0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFlagEffect(tp,id)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,ct,PLAYER_ALL,LOCATION_MZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFlagEffect(tp,id)
    if ct<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CHANGE_RACE)
        e3:SetValue(RACE_ZOMBIE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
end

if not _G.NM_TOKEN_REL_REG then
    _G.NM_TOKEN_REL_REG = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_RELEASE)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in aux.Next(eg) do
            if tc:GetPreviousControler()==tp and tc:IsType(TYPE_TOKEN) then
                Duel.RegisterFlagEffect(tp, 65200220, RESET_PHASE+PHASE_END, 0, 1)
            end
        end
    end)
    Duel.RegisterEffect(ge, 0)
end