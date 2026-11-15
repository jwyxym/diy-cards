-- 俱舍怒威族·半人马
-- ID: 12950001
-- 字段：俱舍怒威族 0x189
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上没有怪兽的场合，从手卡特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 主阶：选场上1张卡回手，卡组特召1只俱舍，之后可以选自己手卡·墓地1张除外
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.tgtg2)
    e2:SetOperation(s.tgop2)
    c:RegisterEffect(e2)

    -- ③ 攻击宣言时或对方把怪兽效果发动时，随机确认对方1张手卡，是怪兽卡的场合可以里侧除外
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.rmcon3)
    e3:SetTarget(s.rmtg3)
    e3:SetOperation(s.rmop3)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_CHAINING)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCondition(s.rmcon4)
    c:RegisterEffect(e4)
end

function s.spcon1(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
end

-- ②
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then
        local b1=Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
        return b1 and b2
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
    -- 之后可以选自己手卡·墓地1张除外
    if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)>0 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
            if #rg>0 then Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) end
        end
    end
end

-- ③
function s.rmcon3(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker()==e:GetHandler()
end
function s.rmcon4(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.rmtg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.rmop3(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g==0 then return end
    local sg=g:RandomSelect(tp,1)
    Duel.ConfirmCards(tp,sg)
    local tc=sg:GetFirst()
    if tc:IsType(TYPE_MONSTER) then
        if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
        end
    end
end