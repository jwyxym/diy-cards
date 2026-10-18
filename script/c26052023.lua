-- 深海之锚 格吕恩·蒂夫海姆
-- ID: 26052023
-- L5/水/水族/4000
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 【修正】链接召唤：水族怪兽3只以上，最多5只，合计链接值5
    aux.AddLinkProcedure(c, s.lmfilter, 3, 5)

    -- ① 场上有「暗夜织者的主人 洛蕾莱·纳赫特」时不受其他卡效果影响
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- ② 双方回合1次，解放1只其他水族，破坏对方全部怪兽并提升攻击力
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- ③ 链接召唤时，墓地5张回卡组，翻开5张加1张，其余回卡组底
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.exccon)
    e3:SetTarget(s.exctg)
    e3:SetOperation(s.excop)
    c:RegisterEffect(e3)

    -- ④ 墓地时，除外3只水族或1只「主人」特召自身，离场除外
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id+1000)
    e4:SetCost(s.spcost4)
    e4:SetTarget(s.sptg4)
    e4:SetOperation(s.spop4)
    c:RegisterEffect(e4)
end

function s.lmfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_AQUA)
end

-- ①
function s.kirbyfilter(c)
    return c:IsFaceup() and c:IsCode(26052016)
end
function s.immcon(e)
    return Duel.IsExistingMatchingCard(s.kirbyfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.immval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end

-- ②
function s.relfilter(c,e)
    return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsReleasable() and c~=e:GetHandler()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e)
    Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    local ct=Duel.Destroy(g,REASON_EFFECT)
    if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

-- ③
function s.exccon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,5,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,5,5,nil)
    if #g<5 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    local top=Duel.GetDecktopGroup(tp,5)
    if #top==0 then return end
    Duel.ConfirmDecktop(tp,5)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=top:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
        top:RemoveCard(sg:GetFirst())
    end
    if #top>0 then
        Duel.SendtoDeck(top,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end

-- ④
function s.aquafilter(c)
    return c:IsRace(RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
function s.kirbyfilter2(c)
    return c:IsCode(26052016) and c:IsAbleToRemoveAsCost()
end
function s.spcost4(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g1=Duel.GetMatchingGroup(s.aquafilter,tp,LOCATION_GRAVE,0,nil)
        local g2=Duel.GetMatchingGroup(s.kirbyfilter2,tp,LOCATION_GRAVE,0,nil)
        return #g1>=3 or #g2>=1
    end
    local g1=Duel.GetMatchingGroup(s.aquafilter,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.kirbyfilter2,tp,LOCATION_GRAVE,0,nil)
    local opt=0
    if #g1>=3 and #g2>=1 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif #g2>=1 then
        opt=1
    end
    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g1:Select(tp,3,3,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_COST)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g2:Select(tp,1,1,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_COST)
    end
end
function s.sptg4(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop4(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end