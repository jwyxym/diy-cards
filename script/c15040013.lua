-- 转学生 千早爱音
-- ID: 15040013
-- 字段：千早爱音 (0xb12)
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己主要阶段，从卡组特召1只「千早爱音」怪兽（自身除外），并附加自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 被送去墓地时，展示手卡1张「千早爱音」卡，将其送墓，自身从墓地特召
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

-- ① 目标：卡组存在可特殊召唤的「千早爱音」怪兽（自身除外）
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xb12) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：直到回合结束，自己不是「千早爱音」怪兽不能从手卡·卡组特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
-- 自肃：非「千早爱音」怪兽不能从手卡·卡组特殊召唤（其他区域不受影响）
function s.splimit(e,c)
    if c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK) then
        return not c:IsSetCard(0xb12)
    end
    return false
end

-- ② cost：展示手卡1张「千早爱音」卡，并将其记录为标签对象
function s.cfilter(c)
    return c:IsSetCard(0xb12) and not c:IsPublic()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
    e:SetLabelObject(g:GetFirst())
end
-- ② 目标：自身从墓地特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ② 操作：把展示的卡送墓，然后自身从墓地特召
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_HAND) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end