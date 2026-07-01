-- 源计划 天眼
-- ID: 26051946
-- 字段：0x904 / 0x905
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上当作「源计划公司」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x905)
    c:RegisterEffect(e0)

    -- ① 自己的「源计划」怪兽被效果破坏时，从手卡·墓地特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 破坏自己场上1只「源计划」怪兽，确认对方手卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(s.descost2)
    e2:SetTarget(s.thtg2)
    e2:SetOperation(s.thop2)
    c:RegisterEffect(e2)
end

-- ① 条件：自己的「源计划」怪兽被效果破坏
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter1,1,nil,tp)
end
function s.spfilter1(c,tp)
    return c:IsSetCard(0x904) and c:IsControler(tp) and bit.band(c:GetReason(),REASON_EFFECT)~=0
end
-- ① 目标：自身特召
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② cost：破坏自己场上1只「源计划」怪兽
function s.costfilter2(c)
    return c:IsSetCard(0x904) and c:IsFaceup()
end
function s.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Destroy(g,REASON_COST)
end
-- ② 目标：无，只需确认
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- ② 操作：随机确认1张对方手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g>0 then
        Duel.ConfirmCards(tp,g:RandomSelect(tp,1))
    end
end