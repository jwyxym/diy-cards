-- 渴求虚恋之槌 Amoris
-- ID: 15040042
-- 电子界族 / 「赞颂音乐的人偶」(15040037) 卡名记述
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」

    -- ① 自己场上有电子界族以外的记述「赞颂音乐的人偶」的怪兽时，从手卡特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 主要阶段，丢弃1张手卡（或取除场上1个超量素材），从卡组特召记述怪兽或「丰川祥子」怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon2)
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- ③ 作为超量素材被取除的场合，以自己墓地·除外1张记述「赞颂音乐的人偶」的卡为对象，加入手卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.retcon)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上有电子界族以外的记述「赞颂音乐的人偶」的怪兽
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,15040037)
        and not c:IsRace(RACE_CYBERSE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- 自肃：本回合只能特殊召唤记述「赞颂音乐的人偶」或「丰川祥子」怪兽（额外卡组除外）
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then return false end
    return not (aux.IsCodeListed(c,15040037) or c:IsSetCard(0xb10))
end

-- ② 条件：主要阶段
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ② cost：丢弃1张手卡，或取除场上1个超量素材
function s.ovfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
        local b2=Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        return b1 or b2
    end
    local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)

    local use_ov=false
    if b1 and b2 then
        -- 两种方式都可用，让玩家选择（0=丢手卡，1=取除超量素材）
        use_ov = Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==1
    elseif b2 then
        use_ov=true
    end

    if use_ov then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            tc:RemoveOverlayCard(tp,1,1,REASON_COST)
        end
    else
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
    end
end

-- ② 特召对象：记述「赞颂音乐的人偶」的怪兽或「丰川祥子」怪兽
function s.spfilter2(c,e,tp)
    return (aux.IsCodeListed(c,15040037) or c:IsSetCard(0xb10))
        and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ② 操作：特召，然后施加自肃
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- ③ 条件：作为超量素材被取除
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end

-- ③ 对象：自己墓地·除外1张记述「赞颂音乐的人偶」的卡
function s.retfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsAbleToHand()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end