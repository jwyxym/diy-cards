-- Kawaragi Momoka
-- ID: 72800007
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上有「TOGENASHI TOGEARI」卡时，从手卡特殊召唤，之后可选从卡组盖放1张记述「TOGENASHI TOGEARI」的魔法·陷阱
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 永续：自己受到的战斗·效果伤害1回合只有1次变成0
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)

    -- ③-1 属性不足3种时：一速起动效果（自己主要阶段）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(aux.NOT(s.attrcon))
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- ③-2 属性3种以上时：二速（双方回合均可发动）
    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e4:SetCondition(s.attrcon)
    c:RegisterEffect(e4)
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
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.BreakEffect()
                Duel.SSet(tp,g:GetFirst())
            end
        end
    end
end
-- ① 盖放对象：记述「TOGENASHI TOGEARI」的魔法·陷阱卡
function s.setfilter(c)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

-- ② 伤害变为0（每回合仅1次，战斗伤害与效果伤害共用同一 Flag）
function s.damval(e,re,dam,r,rp,rc)
    local tp=e:GetHandlerPlayer()
    if dam==nil then return nil end
    if dam>0 and Duel.GetFlagEffect(tp,id)==0 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        return 0
    end
    return dam
end

-- ③ 条件判断：自己场上表侧怪兽的属性达到3种以上
function s.attrcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local attrs={}
    local cnt=0
    local tc=g:GetFirst()
    while tc do
        local a=tc:GetAttribute()
        if not attrs[a] then
            attrs[a]=true
            cnt=cnt+1
        end
        tc=g:GetNext()
    end
    return cnt>=3
end

-- ③ 目标：场上1张魔法·陷阱卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③ 操作：破坏目标
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end