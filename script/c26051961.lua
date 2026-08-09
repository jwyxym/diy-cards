-- 新星同盟 破镜魅塔
-- ID: 26051961（请根据数据库实际ID修改）
-- 字段: 0x902
local s,id=GetID()
function s.initial_effect(c)
    -- ① 二选一
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- 一回合一次
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

-- 检索过滤
function s.thfilter(c)
    return c:IsCode(26051905) or c:IsCode(26051956) -- 魅塔骑士/暗魅塔骑士
end

-- 目标：选择效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2 = Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,5,nil)
    if chk==0 then return b1 or b2 end
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op = Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op = Duel.SelectOption(tp,aux.Stringid(id,2)) + 1
    end
    e:SetLabel(op)
    if op==0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    end
end

-- 操作：执行选中的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

    local op = e:GetLabel()
    if op==0 then
        -- 检索
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        -- 回收墓地5张，抽2
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
        if #g==5 then
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
            Duel.Draw(tp,2,REASON_EFFECT)
        end
    end
end

-- 回收过滤
function s.tdfilter(c)
    return c:IsSetCard(0x902) and c:IsAbleToDeck()
end