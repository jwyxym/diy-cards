-- 《<梦魇>乌鸦杂耍师》
-- 卡号：65200030  暗/不死族/6星 2500/2500
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·特殊召唤时破坏1只怪兽，可选苏生墓地2星以下
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

-- 目标：选场上1只怪兽破坏
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_MZONE)
end

-- 操作：破坏→可选苏生墓地2星以下
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if #dg>0 then
        Duel.HintSelection(dg)
        if Duel.Destroy(dg,REASON_EFFECT)~=0 then
            local sg=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
            if #sg>0 and Duel.SelectYesNo(tp,"要特殊召唤墓地1只2星以下的怪兽吗？") then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local rg=sg:Select(tp,1,1,nil)
                Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

-- 苏生过滤：2星以下
function s.revfilter(c,e,tp)
    return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end