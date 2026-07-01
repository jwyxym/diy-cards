--极星神域 阿斯加德
--ID:14151813

function c14151813.initial_effect(c)
    --激活效果（必须！让场地魔法能从手牌发动）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --1效果：从手卡召唤1只极星怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(14151813,0))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,14151813)
    e1:SetTarget(c14151813.sumtg)
    e1:SetOperation(c14151813.sumop)
    c:RegisterEffect(e1)
    
    --2效果：墓地/除外5只极星·极神回卡组抽2
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(14151813,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,14151814)
    e2:SetTarget(c14151813.rectg)
    e2:SetOperation(c14151813.recop)
    c:RegisterEffect(e2)
    
    --3效果：极神特召时炸1卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(14151813,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,14151815)
    e3:SetCondition(c14151813.descon)
    e3:SetTarget(c14151813.destg)
    e3:SetOperation(c14151813.desop)
    c:RegisterEffect(e3)
end

--【修复】极星判断：必须是怪兽
function c14151813.nordic(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER)
end

--极神判断 (0x4b)
function c14151813.aesir(c)
    return c:IsSetCard(0x4b)
end

--1效果：选卡（只能选极星怪兽）
function c14151813.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(c14151813.nordic,tp,LOCATION_HAND,0,1,nil)
    end
end

--1效果：执行
function c14151813.sumop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,c14151813.nordic,tp,LOCATION_HAND,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.Summon(tp,g:GetFirst(),true,nil)
    end
end

--2效果：过滤器
function c14151813.retfilter(c)
    return (c14151813.nordic(c) or c14151813.aesir(c)) and c:IsAbleToDeck()
end

--2效果：选卡
function c14151813.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c14151813.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if chk==0 then return g:GetCount()>=5 and Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

--2效果：执行
function c14151813.recop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c14151813.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if g:GetCount()<5 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:Select(tp,5,5,nil)
    if sg:GetCount()<5 then return end
    Duel.HintSelection(sg)
    if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end

--3效果：条件
function c14151813.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c14151813.aesir,1,nil) and eg:GetFirst():GetSummonPlayer()==tp
end

--3效果：选卡
function c14151813.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

--3效果：执行
function c14151813.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    if g:GetCount()>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end