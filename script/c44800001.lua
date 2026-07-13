-- 妖仙兽 镰合太刀
-- ID: 44800001
-- 字段: 0xb3
local s,id=GetID()
function s.initial_effect(c)
    -- ① 丢弃自身，从卡组盖放1张「妖仙兽」魔法卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 灵摆区放置/怪兽回手·卡组时，墓地除外自身，进行1次灵摆召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAIN_ACTIVATE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.cond2a)
    e2:SetCost(s.bfgcost)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_TO_HAND)
    e2b:SetCondition(s.cond2b)
    c:RegisterEffect(e2b)
    local e2c=e2:Clone()
    e2c:SetCode(EVENT_TO_DECK)
    e2c:SetCondition(s.cond2b)
    c:RegisterEffect(e2c)

    -- ③ 特殊召唤的回合结束阶段回手
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.retcon)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter1(c)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_SPELL) and not c:IsForbidden()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g:GetFirst()) end
end

function s.cond2a(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return rc:IsSetCard(0xb3) and rc:IsLocation(LOCATION_PZONE)
end
function s.cond2b(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter2b,1,nil,tp)
end
function s.filter2b(c,tp)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
        and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK))
end
function s.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)<2 then return false end
        local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
        local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        if not lc or not rc then return false end
        local lscale=lc:GetLeftScale()
        local rscale=rc:GetRightScale()
        if lscale==0 or rscale==0 then return false end
        local low=math.min(lscale,rscale)
        local high=math.max(lscale,rscale)
        if low>=high then return false end
        -- 检查手卡或额外表侧是否有可灵摆召唤的妖仙兽怪兽
        return Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_HAND,0,1,nil,e,tp,low,high)
            or Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,low,high)
    end
end
-- 灵摆召唤过滤：妖仙兽灵摆怪兽，等级在low和high之间
function s.pendfilter(c,e,tp,low,high)
    local lv=c:GetLevel()
    return c:IsSetCard(0xb3) and c:IsType(TYPE_PENDULUM) and lv>low and lv<high
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    if not lc or not rc then return end
    local lscale=lc:GetLeftScale()
    local rscale=rc:GetRightScale()
    local low=math.min(lscale,rscale)
    local high=math.max(lscale,rscale)
    local g1=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_HAND,0,nil,e,tp,low,high)
    local g2=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_EXTRA,0,nil,e,tp,low,high)
    local mg=g1:Clone()
    mg:Merge(g2)
    if #mg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=mg:Select(tp,1,#mg,nil)
    if #sg>0 then
        local tc=sg:GetFirst()
        while tc do
            Duel.SpecialSummonStep(tc,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)
            tc=sg:GetNext()
        end
        Duel.SpecialSummonComplete()
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToHand() then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end