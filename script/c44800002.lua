-- 妖仙兽 颓马旋
-- ID: 44800002
-- 字段: 0xb3
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·反转·灵摆成功时检索，并可以追加召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg1)
    e1:SetOperation(s.thop1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.pspcon)
    c:RegisterEffect(e3)

    -- ② 有其他2种类以上妖仙兽时抽1，并可以追加召唤
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1000)
    e4:SetCondition(s.drawcon)
    e4:SetTarget(s.drawtg)
    e4:SetOperation(s.drawop)
    c:RegisterEffect(e4)

    -- ③ 召唤的回合结束阶段回手
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.retcon)
    e5:SetTarget(s.rettg)
    e5:SetOperation(s.retop)
    c:RegisterEffect(e5)
end

-- ① 检索过滤
function s.thfilter1(c)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.pspcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- 给予额外通常召唤次数
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        -- 立刻询问是否召唤1只「妖仙兽」怪兽
        if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #sg>0 then
                Duel.Summon(tp,sg:GetFirst(),true,nil)
            end
        end
    end
end
function s.sumfilter(c)
    return c:IsSetCard(0xb3) and c:IsSummonable(true,nil)
end

-- ② 条件：有其他2种类以上妖仙兽怪兽
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.otherfilter,tp,LOCATION_MZONE,0,nil,e:GetHandler():GetCode())
    return g:GetClassCount(Card.GetCode)>=2
end
function s.otherfilter(c,code)
    return c:IsFaceup() and c:IsSetCard(0xb3) and not c:IsCode(code)
end
-- ② 抽1
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
        -- 给予额外通常召唤次数
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        -- 立刻询问是否召唤1只「妖仙兽」怪兽
        if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #sg>0 then
                Duel.Summon(tp,sg:GetFirst(),true,nil)
            end
        end
    end
end

-- ③ 回手
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp and c:IsSummonType(SUMMON_TYPE_NORMAL)
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