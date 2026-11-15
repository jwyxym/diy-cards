-- 穚镰鸦姬 伊索尔德
-- ID: 26052050
-- 字段：穚镰鸦姬 0x914
local s,id=GetID()
local RACE_BIRD = 512

function s.initial_effect(c)
    -- ① 双方主要阶段，展示手卡，进行鸟兽族怪兽的上级召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(99,id,EFFECT_COUNT_CODE_CHAIN)
    e1:SetCondition(s.cond1)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 上级召唤成功：本家卡回手，破坏场上2张卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(99,id,EFFECT_COUNT_CODE_CHAIN)
    e2:SetCondition(s.cond2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

function s.is_bird(c)
    local r=c:GetRace()
    return (r & RACE_BIRD)~=0 or r==1029
end

function s.adv(e,tp,filter)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSummonable(true,nil) and c:IsLevelAbove(5) and (not filter or filter(c))
    end,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    Duel.Summon(tp,tc,true,nil)
end

function s.mfilter(c) return c:IsSetCard(0x914) and c:IsType(TYPE_MONSTER) end
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if ph~=PHASE_MAIN1 and ph~=PHASE_MAIN2 then return false end
    return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(function(c)
        return c:IsSummonable(true,nil) and c:IsLevelAbove(5) and s.is_bird(c)
    end,tp,LOCATION_HAND,0,1,nil) end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    s.adv(e,tp,function(c) return s.is_bird(c) end)
end

function s.cond2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.tfilter(c) return c:IsSetCard(0x914) end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.tfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,LOCATION_ONFIELD)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
    if g:GetCount()>0 then
        Duel.BreakEffect()
        Duel.Destroy(g,REASON_EFFECT)
    end
end