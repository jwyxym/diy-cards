--战华史略-衣带文诏
--卡密ID: 45205605
--字段代码: 0x0137

local s,id=GetID()

function s.initial_effect(c)
    --永续陷阱发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --特殊规则：自己场上有「战华之德-刘玄」时，盖放的回合也能发动
    local e_quick=Effect.CreateEffect(c)
    e_quick:SetType(EFFECT_TYPE_SINGLE)
    e_quick:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e_quick:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e_quick:SetCondition(s.quickcon)
    c:RegisterEffect(e_quick)
    
    --①效果：选自己场上1只「战华」怪兽回手卡，然后从卡组特召1只「战华」怪兽（2速，取对象）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.returntg)
    e1:SetOperation(s.returnop)
    c:RegisterEffect(e1)
    
    --②效果：这张卡从魔陷区送去墓地时，从手卡特召1只「战华」怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

--特殊规则条件：自己场上有「战华之德-刘玄」
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,40428851)
end

--①效果目标：选自己场上1只「战华」怪兽回手卡
function s.retfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x137)
end

function s.returntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

--①效果处理
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK,0,nil,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--②效果条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE)
end

function s.spfilter3(c,e,tp)
    return c:IsSetCard(0x137) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end