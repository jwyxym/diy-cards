local s,id=GetID()
local TOKEN_ID=65200900
local ALMISS_LISTED = {
    65200270,
    65200280,
    65200290,
    65200300,
    65200310,
    65200320,
}

-- 检索过滤：仪式怪兽以外、记载了魔神的怪兽
function s.thfilter(c)
    if c:IsType(TYPE_RITUAL) then return false end
    if not c:IsType(TYPE_MONSTER) then return false end
    for _, code in ipairs(ALMISS_LISTED) do
        if c:IsCode(code) then return true end
    end
    return false
end

function s.initial_effect(c)
    -- ① 二选一发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 墓地除外加攻守
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- ① 目标：二选一
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2 = Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
    if chk==0 then return b1 or b2 end
    
    local opt
    if b1 and b2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        opt=0
    else
        opt=1
    end
    e:SetLabel(opt)
    
    if opt==0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,1-tp,0)
        Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    end
end

-- ① 处理
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        -- 分支1：检索或堆墓
        if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g==0 then return end
        local tc=g:GetFirst()
        local b1=tc:IsAbleToHand()
        local b2=tc:IsAbleToGrave()
        if b1 and b2 then
            if Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0 then
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            else
                Duel.SendtoGrave(tc,REASON_EFFECT)
            end
        elseif b1 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        elseif b2 then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    else
        -- 分支2：降对方攻守，生衍生物
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        if g:GetCount()==0 then return end
        for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-800)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            tc:RegisterEffect(e2)
        end
        
        -- 计算攻守为0的怪兽数量
        local zero_g=Duel.GetMatchingGroup(function(c) 
            return c:IsFaceup() and (c:GetAttack()==0 or c:GetDefense()==0) 
        end,tp,0,LOCATION_MZONE,nil)
        
        local num=zero_g:GetCount()
        if num<=0 then return end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        num=math.min(num,ft)
        if num<=0 then return end
        
        -- 特召骷髅士兵衍生物
        for i=1,num do
            if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then break end
            if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ID,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
                local token=Duel.CreateToken(tp,TOKEN_ID)
                Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
            end
        end
        Duel.SpecialSummonComplete()
    end
end

-- ② Cost：除外墓地自身
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ② 目标：以自己场上1只怪兽为对象
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end

-- ② 处理：加攻守800
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(800)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(e2)
end