-- 逆时残响 箱中巡游
-- ID: 26051993
-- 字段：逆时残响 0x910
local s,id=GetID()
function s.initial_effect(c)
    -- ① 发动时检索本家怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.con1)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 本家召唤·特召时给100伤害
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- ③ 换手
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,id+1000)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- ① 同名卡一回合一次
function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.thfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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

-- ② 伤害
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsSetCard,1,nil,0x910)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,100,REASON_EFFECT)
end

-- ③ 换手：严格检查条件，防空发
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查场上有本家 + 手牌有不同名本家
function s.check_pair(tp,e)
    local field = Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x910)
    local hand = Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
    if #field == 0 or #hand == 0 then return false end
    local fc = field:GetFirst()
    while fc do
        local hc = hand:GetFirst()
        while hc do
            if hc:GetCode() ~= fc:GetCode() then return true end
            hc = hand:GetNext()
        end
        fc = field:GetNext()
    end
    return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsSetCard(0x910) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and s.check_pair(tp,e)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,1,1,nil,0x910)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local code=tc:GetCode()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    -- 手牌选不同名本家
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
    local valid=Group.CreateGroup()
    local hc=g:GetFirst()
    while hc do
        if hc:GetCode()~=code then valid:AddCard(hc) end
        hc=g:GetNext()
    end
    if #valid==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=valid:Select(tp,1,1,nil)
    if #sg>0 then
        if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
        end
    end
end