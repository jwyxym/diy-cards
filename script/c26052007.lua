-- 逆时残响 泥鯭的士
-- ID: 26052007
-- 字段：逆时残响 0x910 / 升阶 0x911
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上当作「升阶」卡
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x911)
    c:RegisterEffect(e0)

    -- ① 抽卡以外加入手牌时特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 召唤·特召成功时，检索或特召本家
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- ③ 宣言1~6，等级变为宣言值
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_LVCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end

-- ① 条件：抽卡以外加入手牌
function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r, REASON_DRAW)==0 and e:GetHandler():IsLocation(LOCATION_HAND)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 检索/特召
function s.thfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rankup_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x911) and c:IsType(TYPE_SYNCHRO)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        local b2 = Duel.IsExistingMatchingCard(s.rankup_filter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
        return b1 or b2
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local has_rankup = Duel.IsExistingMatchingCard(s.rankup_filter,tp,LOCATION_MZONE,0,1,nil)
    local b1 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    local b2 = has_rankup and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    if not b1 and not b2 then return end
    local op = 0
    if b1 and b2 then
        op = Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif b2 then
        op = 1
    end
    if op == 0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    -- 自肃：本回合只能特召魔法师族同调
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_SYNCHRO))
end

-- ③ 宣言1~6，等级变为宣言值
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
    local lv=Duel.AnnounceLevel(tp,1,6)
    e:SetLabel(lv)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lv=e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() and lv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end