-- 客人，看看菜单
-- ID: 26052019
-- 字段：暗夜织者 0x912
-- 通常魔法
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

-- 怪兽过滤：本家怪兽，不同卡名
function s.mfilter(c)
    return c:IsSetCard(0x912) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

    -- 从卡组选2只不同卡名的本家怪兽
    local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
    if #g<2 then return end

    -- 检查是否有2只不同卡名
    local codes={}
    local tc=g:GetFirst()
    while tc do
        codes[tc:GetCode()]=true
        tc=g:GetNext()
    end
    local unique_codes={}
    for code,_ in pairs(codes) do
        table.insert(unique_codes, code)
    end
    if #unique_codes<2 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=g:Select(tp,1,1,nil)
    local tc1=g1:GetFirst()
    local code1=tc1:GetCode()
    local g2=g:Filter(Card.IsCode,nil,code1)
    local g3=g:Clone()
    g3:RemoveCard(tc1)
    g3=g3:Filter(function(c) return c:GetCode()~=code1 end, nil)
    if #g3==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg2=g3:Select(tp,1,1,nil)
    local tc2=sg2:GetFirst()

    -- 组成展示组
    local show=Group.FromCards(tc1,tc2)
    Duel.ConfirmCards(1-tp,show)
    -- 对方选择1只加入自己手卡
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local pick=show:Select(1-tp,1,1,nil):GetFirst()
    if pick then
        Duel.SendtoHand(pick,nil,REASON_EFFECT)
        Duel.ConfirmCards(tp,pick)
        show:RemoveCard(pick)
        -- 剩余回卡组
        Duel.SendtoDeck(show,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        -- 检索卡
        local lv=pick:GetLevel()
        local b1=lv>=4
        local b2=lv>=8
        if b2 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,26052022) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,26052022)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        elseif b1 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,26052020) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,26052020)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end

function s.thfilter2(c,code)
    return c:IsCode(code) and c:IsAbleToHand()
end