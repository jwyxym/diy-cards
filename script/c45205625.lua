--战华永续魔法
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --①效果：从手卡·卡组·墓地·除外状态把吕奉和董颖在双方场上各1只无视召唤条件特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    
    --②效果：从场上离开送去墓地的场合，除外吕奉和董颖各1只，从额外特召迦楼罗
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

function s.spfilter1(c)
    return c:IsCode(82791472) or c:IsCode(79582540)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        return g:IsExists(Card.IsCode,1,nil,82791472) and g:IsExists(Card.IsCode,1,nil,79582540)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    
    local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg1=g:Select(tp,1,1,nil)
    local tc1=sg1:GetFirst()
    
    local code2 = (tc1:IsCode(82791472) and 79582540) or 82791472
    local g2=g:Filter(Card.IsCode,nil,code2)
    if #g2==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg2=g2:Select(tp,1,1,nil)
    local tc2=sg2:GetFirst()
    
    Duel.SpecialSummonStep(tc1,0,tp,tp,true,false,POS_FACEUP)
    Duel.SpecialSummonStep(tc2,0,tp,1-tp,true,false,POS_FACEUP)
    Duel.SpecialSummonComplete()
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.rmfilter(c)
    return (c:IsCode(82791472) or c:IsCode(79582540)) and c:IsAbleToRemove()
end

function s.spfilter2(c,e,tp)
    return c:IsCode(11765832) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
        local b2=Duel.IsExistingMatchingCard(s.rmfilter,1-tp,LOCATION_ONFIELD,0,1,nil)
        local b3=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        return b1 and b3
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    local g_opp=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
    g:Merge(g_opp)
    if #g==0 then return end
    
    local g1=g:Filter(Card.IsCode,nil,82791472):Select(tp,1,1,nil)
    local g2=g:Filter(Card.IsCode,nil,79582540):Select(tp,1,1,nil)
    if #g1>0 and #g2>0 then
        g1:Merge(g2)
        if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)~=0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
            end
        end
    end
end

return s
