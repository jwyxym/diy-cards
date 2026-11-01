-- Awa Subaru
-- ID: 72800009
-- 风属性 / 念动力族 / 6星 / ATK 1700 / DEF 1580
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上有「TOGENASHI TOGEARI」卡时，从手卡特殊召唤，之后可选从墓地把1张「TOGENASHI TOGEARI」卡加入手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 不能成为对方的效果对象
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(s.tgval)
    c:RegisterEffect(e2)

    -- ③-1 一速起动效果（种族不足3种时，自己主要阶段）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2)
    e3:SetCondition(aux.NOT(s.racecon))
    e3:SetTarget(s.swaptg)
    e3:SetOperation(s.swapop)
    c:RegisterEffect(e3)

    -- ③-2 二速（种族3种以上时，双方回合均可发动）
    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e4:SetCondition(s.racecon)
    c:RegisterEffect(e4)
end

-- ② 免疫对方效果对象
function s.tgval(e,re,rp)
    return rp~=e:GetHandlerPlayer()
end

-- ① 条件：自己场上有「TOGENASHI TOGEARI」卡
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ① 回收对象：「TOGENASHI TOGEARI」卡
function s.thfilter(c)
    return c:IsSetCard(0xb15) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
            if #g>0 then
                Duel.BreakEffect()
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end

-- ③ 条件判断：自己场上表侧怪兽的种族达到3种以上
function s.racecon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local races={}
    local cnt=0
    local tc=g:GetFirst()
    while tc do
        local a=tc:GetRace()
        if not races[a] then
            races[a]=true
            cnt=cnt+1
        end
        tc=g:GetNext()
    end
    return cnt>=3
end

-- ③ 特召对象：手卡中的「TOGENASHI TOGEARI」怪兽（同名卡以外）
function s.swapfilter(c,e,tp)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ③ 目标
function s.swaptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.swapfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        and c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ③ 操作：从手卡特召1只同名卡以外的「TOGENASHI TOGEARI」怪兽，然后场上的这张卡回到手卡
function s.swapop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.swapfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToHand() then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    end
end