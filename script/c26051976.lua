-- 问题少女 凛
-- ID: 26051976
-- 字段：跃音萌行 0x906 / 凛 0x907 / 布若 0x908 / 玛莉嘉 0x909
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.linkcon)
    e0:SetOperation(s.linkop)
    e0:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e0)

    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x906)
    c:RegisterEffect(e0b)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- 链接条件：场上至少2只怪兽，至少1只「凛」
function s.linkcon(e,c,og,lmat,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    if #g < 2 then return false end
    return g:FilterCount(Card.IsSetCard, nil, 0x907) >= 1
end
-- 两步选择：第1步必选本家，第2步选其他
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
    if c==nil then return end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local honka = g:Filter(Card.IsSetCard, nil, 0x907)
    if #honka < 1 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg1 = honka:Select(tp, 1, 1, nil)
    if #sg1 < 1 then return end
    local mat1 = sg1:GetFirst()
    local g2 = g:Clone()
    g2:RemoveCard(mat1)
    if #g2 < 1 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg2 = g2:Select(tp, 1, 1, nil)
    if #sg2 < 1 then return end
    local sg = sg1:Clone()
    sg:Merge(sg2)
    c:SetMaterial(sg)
    Duel.SendtoGrave(sg, REASON_MATERIAL+REASON_LINK)
end

function s.thfilter(c)
    return c:IsSetCard(0x906) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local ph = Duel.GetCurrentPhase()
    if ph ~= PHASE_MAIN1 and ph ~= PHASE_MAIN2 then return false end
    return not Duel.IsExistingMatchingCard(s.fieldfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.fieldfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x908) or c:IsSetCard(0x909))
end
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x908) or c:IsSetCard(0x909))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_CYBERSE)
end