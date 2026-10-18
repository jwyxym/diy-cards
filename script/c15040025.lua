-- 命运的邂逅
-- 永续魔法
-- ID: 15040025
-- 「长崎爽世」字段：0xb14
-- 「春日影」：26062911
-- 「属于我们的歌 长崎爽世」：26062907
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 此卡记述「春日影」

    -- ① 发动时的效果处理
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- ② 表侧表示被破坏时，苏生自己墓地1只4星以下怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- ① 目标
function s.thfilter(c)
    return c:IsSetCard(0xb14) and c:IsAbleToHand()
end
function s.spfilter1(c,e,tp)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,26062907)
            and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
        return b1 or b2
    end
end

-- ① 操作
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：发动后，自己不是同调怪兽不能从额外卡组特殊召唤
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0:SetTargetRange(1,0)
    e0:SetTarget(s.splimit)
    e0:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e0,tp)

    local has_song=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,26062907)
    local can_sp=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)

    if has_song and can_sp and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif can_th then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- ① 自肃：额外卡组只能特殊召唤同调怪兽
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not c:IsType(TYPE_SYNCHRO)
    end
    return false
end

-- ② 条件：表侧表示被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY)
end

-- ② 目标：自己墓地1只4星以下怪兽
function s.spfilter2(c,e,tp)
    return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- ② 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end