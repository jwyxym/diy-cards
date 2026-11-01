-- Iseri Nina
-- ID: 72800000
-- 炎属性 / 天使族 / 4星 / ATK 1700 / DEF 1520
-- 「GIRLS BAND CRY」：72800002
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·特殊召唤成功时，从卡组选1只「GIRLS BAND CRY」加入手卡或特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ② 墓地存在时，破坏自己场上1张卡，这张卡加入手卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    c:RegisterEffect(e3)
end

-- ① 检索/特殊召唤对象：「GIRLS BAND CRY」(72800002)
function s.thfilter(c)
    return c:IsCode(72800002)
end
function s.spfilter(c,e,tp)
    return c:IsCode(72800002) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 目标
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        return g:IsExists(Card.IsAbleToHand,1,nil)
            or g:IsExists(s.spfilter,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ① 操作
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    local can_th=g:Filter(Card.IsAbleToHand,nil)
    local can_sp=g:Filter(s.spfilter,nil,e,tp)
    local avail=Group.CreateGroup()
    avail:Merge(can_th)
    avail:Merge(can_sp)
    if #avail==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local tc=avail:Select(tp,1,1,nil):GetFirst()
    if not tc then return end

    local b1=tc:IsAbleToHand()
    local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)

    if b1 and b2 then
        local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if op==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif b1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    elseif b2 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 目标：自己场上1张可破坏的卡
function s.desfilter(c)
    return c:IsDestructable()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ② 操作：破坏选择的卡，然后这张卡加入手卡
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end