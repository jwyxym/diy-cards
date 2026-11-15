-- 心之雨
-- ID: 15040045
-- 永续魔法
-- 「若叶睦」字段：0xb11
local s,id=GetID()
function s.initial_effect(c)
    -- 永续魔法的发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 场上的表侧表示「若叶睦」怪兽及墓地「若叶睦」怪兽变为幻想魔族
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE, LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetTarget(s.racetg)
    e1:SetValue(RACE_ILLUSION or 0x2000000)  -- 兼容不同环境下的幻想魔族常量
    c:RegisterEffect(e1)

    -- ② 以自己场上1只「若叶睦」怪兽为对象，检索不同种族的怪兽并除外对象
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ③ 只在这张卡表侧表示存在期间有1次，从卡组检索1只「若叶睦」怪兽
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.th2con)
    e3:SetTarget(s.th2tg)
    e3:SetOperation(s.th2op)
    c:RegisterEffect(e3)
end

-- ① 目标过滤：场上表侧表示 或 墓地里的「若叶睦」怪兽
function s.racetg(e,c)
    if c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsSetCard(0xb11)
    elseif c:IsLocation(LOCATION_GRAVE) then
        return c:IsSetCard(0xb11) and c:IsType(TYPE_MONSTER)
    end
    return false
end

-- ② 对象过滤：自己场上表侧表示的「若叶睦」怪兽
function s.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb11) and c:IsType(TYPE_MONSTER)
end
-- ② 检索过滤：与对象怪兽种族不同的「若叶睦」怪兽
function s.thfilter(c,race)
    return c:IsSetCard(0xb11) and c:IsType(TYPE_MONSTER) and c:GetRace()~=race and c:IsAbleToHand()
end
-- ② 检查是否存在可检索的怪兽
function s.chkfilter(c,tp)
    return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace())
end

-- ② 目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
        return #g>0 and g:IsExists(s.chkfilter,1,nil,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

-- ② 操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local race=tc:GetRace()
    
    -- 检索不同种族的怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    
    -- 对象怪兽除外
    if tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

-- ③ 条件：这张卡在场期间只可使用1次，且需在自己主要阶段
function s.th2con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)==0
        and Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ③ 目标
function s.th2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.th2filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ③ 操作
function s.th2filter(c)
    return c:IsSetCard(0xb11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.th2op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- 赋予Flag，只要这张卡表侧表示存在就不会重置
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.th2filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end