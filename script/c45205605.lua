--战华方略之卷 (45205605)
function c45205605.initial_effect(c)
    -- 效果①：发动时选择是否检索+选择是否特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(45205605,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,45205605)  -- 增加：卡名1回合1次
    e1:SetTarget(c45205605.target)
    e1:SetOperation(c45205605.activate)
    c:RegisterEffect(e1)
    
    -- 效果②：对方场上卡被破坏时触发炸1卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(45205605,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,45205605+100)  -- 使用不同的code，与效果①区分
    e2:SetCondition(c45205605.descond)
    e2:SetTarget(c45205605.destg)
    e2:SetOperation(c45205605.desop)
    c:RegisterEffect(e2)
    
    -- 效果③：自己的战华陷阱可以在盖放的回合发动
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_SZONE,0)
    e3:SetTarget(c45205605.traptg)
    c:RegisterEffect(e3)
end

-- 效果①的发动条件与目标
function c45205605.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return true
    end
    local search=Duel.SelectYesNo(tp,aux.Stringid(45205605,3))
    if search then
        e:SetLabel(1)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetLabel(0)
    end
end

-- 效果①的发动处理
function c45205605.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 第一步：检索（可选）
    if e:GetLabel()==1 then
        if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x137) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x137)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
    
    -- 第二步：特殊召唤（可选，且只能选怪兽）
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c45205605.spfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(45205605,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,c45205605.spfilter,tp,LOCATION_HAND,0,1,1,nil)
        local sc=sg:GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- 特殊召唤的过滤条件：战华字段 + 怪兽类型
function c45205605.spfilter(c)
    return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER)
end

-- 效果②的条件
function c45205605.descond(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsPreviousControler,1,nil,1-tp)
        and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_ONFIELD)
        and (eg:IsExists(Card.IsReason,1,nil,REASON_BATTLE)
            or eg:IsExists(Card.IsReason,1,nil,REASON_EFFECT))
end

-- 效果②的目标
function c45205605.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- 效果②的破坏处理
function c45205605.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- 效果③的目标
function c45205605.traptg(e,c)
    return c:IsSetCard(0x137) and c:IsType(TYPE_TRAP)
end