-- 逆时残响 世多别离
-- ID: 26051996
-- 字段：逆时残响 0x910
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_RELEASE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

-- 效果A：解放1只怪兽，墓地本家特召
function s.relfilter(c)
    return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE))) and c:IsReleasable()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.b1ok(tp,e)
    return Duel.CheckReleaseGroup(tp,s.relfilter,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 效果B：场上1张表侧卡回手
function s.b2ok(tp,e)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,0x910)
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=s.b1ok(tp,e)
    local b2=s.b2ok(tp,e)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetTargetCard(g)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local op=e:GetLabel()
    if op==0 then
        -- 解放1只怪兽（从手牌或场上）
        local g1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
        local g2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND,0,nil)
        g1:Merge(g2)
        if #g1==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local sg=g1:Select(tp,1,1,nil)
        if Duel.Release(sg,REASON_EFFECT)==0 then return end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    else
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
        end
    end
end