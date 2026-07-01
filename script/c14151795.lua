-- 极星灵 光精灵（动画）
--效果：这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。
--把这两只怪兽的等级之和相同等级的一只怪兽从手卡特殊召唤。
--效果：这张卡召唤成功时，选择这张卡以外的自己场上表侧表示存在的1只怪兽才能发动。
--把这两只怪兽的等级之和相同等级的一只怪兽从手卡特殊召唤。
local s,id=GetID()
function s.initial_effect(c)
    -- 召唤成功时的效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.filter(c,e,tp,sum_lv)
    return c:IsLevel(sum_lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=c end
    if chk==0 then
        local lv=c:GetLevel()
        -- 检查是否存在符合条件的场上怪兽
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
        for tc in aux.Next(g) do
            local tlv=tc:GetLevel()
            if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,lv+tlv) then
                return true
            end
        end
        return false
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    local sum_lv=c:GetLevel()+tc:GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,sum_lv)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end