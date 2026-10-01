-- 逆时残响 Mr.Apple
-- ID: 26051992
-- 字段：逆时残响 0x910
local s,id=GetID()
function s.initial_effect(c)
    aux.EnablePendulumAttribute(c)

    -- 灵摆效果：破坏自身，从手卡·卡组把其他本家灵摆放置到灵摆区
    local pe1=Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id,0))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pencon)
    pe1:SetTarget(s.pentg)
    pe1:SetOperation(s.penop)
    c:RegisterEffect(pe1)

    -- ① 自己场上的表侧怪兽被效果破坏时，手牌特召 + 可选特召额外/墓地本家
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 解放自己场上1只本家，检索本家魔法卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+2000)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- 灵摆效果 卡名一回合一次
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.penfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Destroy(c,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

-- ① 条件：自己场上的表侧怪兽被效果破坏
function s.spfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
        and c:IsType(TYPE_MONSTER) and bit.band(c:GetReason(),REASON_EFFECT)~=0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end

-- ① 特召过滤器（修正：额外卡组必须表侧）
function s.spfilter2(c,e,tp)
    if not (c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)) then return false end
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
    -- 额外卡组的怪兽必须表侧表示才能特召
    if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
    return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- ② cost：解放自己场上1只本家
function s.relfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and c:IsReleasable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
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