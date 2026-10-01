-- 逆时残响 苏芙比
-- ID: 26052000
-- 字段：逆时残响 0x910
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
    e0b:SetValue(0x910)
    c:RegisterEffect(e0b)

    -- ① 连接召唤时解放自身，检索魔陷
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 从墓地特召（决斗中1次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

-- 【修正】链接素材过滤：只能是「逆时残响」怪兽
function s.lkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)
end

function s.linkcon(e,c,og,lmat,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    -- 一回合一次
    if Duel.GetFlagEffect(tp,id+500)>0 then return false end
    -- 【修正】素材必须是「逆时残响」怪兽
    return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
    if c==nil then return end
    Duel.RegisterFlagEffect(tp,id+500,RESET_PHASE+PHASE_END,0,1)

    -- 【修正】只从「逆时残响」怪兽中选择素材
    local g = Duel.GetMatchingGroup(s.lkfilter, tp, LOCATION_MZONE, 0, nil)
    if #g < 1 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg = g:Select(tp, 1, 1, nil)
    if #sg < 1 then return end
    c:SetMaterial(sg)
    Duel.SendtoGrave(sg, REASON_MATERIAL+REASON_LINK)
end

-- ① 条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.thfilter(c)
    return c:IsSetCard(0x910) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
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
function s.splimit(e,c)
    return not c:IsRace(RACE_SPELLCASTER)
end

-- ② 条件
function s.faceupfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id+1000)>0 then return false end
    return Duel.IsExistingMatchingCard(s.faceupfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id+1000,0,0,1)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end