-- 潘地曼尼南·放逐之渊
-- ID: 12931707
-- 场地魔法
local s,id=GetID()
function s.initial_effect(c)
    -- ① 发动时检索堕天使怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ①b 场地限制：只能特召天使族·暗属性怪兽
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1b:SetRange(LOCATION_FZONE)
    e1b:SetTargetRange(1,0)
    e1b:SetTarget(s.splimit)
    c:RegisterEffect(e1b)

    -- ② 对方不能对应天使族·暗属性召唤·特召发动反击陷阱
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    -- ③ 检索堕天使魔法卡，如有融合怪兽可追加堆墓
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end

-- ①
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.thfilter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ①b
function s.splimit(e,c)
    return not (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK))
end

-- ② 反击陷阱禁止
function s.aclimit(e,re,tp)
    -- 只在召唤·特殊召唤成功时，禁止对方发动反击陷阱
    return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
        and re:GetHandler():IsType(TYPE_COUNTER)
end

-- ③
function s.th3filter(c)
    -- 同名卡不在墓地
    local code=c:GetCode()
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL)
        and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, code)
end
-- 注：由于 tp 未传入，改用全局遍历
function s.th3check(c,tp)
    local code=c:GetCode()
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL)
        and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,code)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.th3check,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.th3check,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    else
        return
    end
    -- 场上有天使族·暗属性融合怪兽时，追加堆墓
    if Duel.IsExistingMatchingCard(s.fus_filter,tp,LOCATION_MZONE,0,1,nil) then
        if Duel.IsExistingMatchingCard(s.tg3filter2,tp,LOCATION_DECK,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g2=Duel.SelectMatchingCard(tp,s.tg3filter2,tp,LOCATION_DECK,0,1,1,nil)
            if #g2>0 then
                Duel.SendtoGrave(g2,REASON_EFFECT)
            end
        end
    end
end
function s.fus_filter(c)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsType(TYPE_FUSION)
end
function s.tg3filter2(c)
    return c:IsSetCard(0xef) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToGrave()
end