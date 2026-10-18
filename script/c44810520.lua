-- 无闻的勇者 纳格迩·钴格
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己·对方场上有暗属性以外的战士族·天使族怪兽时，从手卡·墓地特殊召唤（1回合1次）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- ② 召唤·特殊召唤成功时，从手卡·卡组·墓地特召1只「誓约的精灵 希欧娜·埃德尔」
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- ③ 1回合最多5次，宣言1个属性，这张卡的属性变成宣言的属性
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(5,id+2)
    e4:SetOperation(s.attop)
    c:RegisterEffect(e4)
end

-- ① 条件：自己或对方场上有暗属性以外的战士族·天使族怪兽
function s.spfilter(c)
    return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
        and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_FAIRY))
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

-- ② 特殊召唤对象「誓约的精灵 希欧娜·埃德尔」
function s.spfilter2(c,e,tp)
    return c:IsCode(44810521) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ③ 宣言属性并变更
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local attr=Duel.AnnounceAttribute(tp,1,0x7f)
    if attr==0 then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(attr)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end

