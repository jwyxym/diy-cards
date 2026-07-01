-- 极神使者 胡基与穆宁
local s,id=GetID()
function s.initial_effect(c)
    --链接召唤规则
     c:EnableReviveLimit()
    aux.AddLinkProcedure(c,s.matfilter,2,2)
    
    --①效果：链接召唤时，除外卡组3只等级合计10的极星怪兽，从额外特召极神怪兽视作同调召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --②效果：双方回合，从墓地·除外状态特召5星以下极星怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

--链接素材：极星怪兽
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x42,lc,sumtype,tp)
end

--①效果条件：链接召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--①效果过滤：极星怪兽
function s.rmfilter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

--等级合计检查
function s.lvcheck(g)
    return g:GetSum(Card.GetLevel)==10
end

--①效果额外过滤：极神同调怪兽
function s.exfilter(c,e,tp)
    return c:IsSetCard(0x4B) and c:IsType(TYPE_SYNCHRO)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

--①效果目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil)
        return g:CheckSubGroup(s.lvcheck,3,3)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--①效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil)
    if #g<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=g:SelectSubGroup(tp,s.lvcheck,false,3,3)
    if rg and #rg==3 then
        local ct=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        if ct==3 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
            if #sg>0 then
                local sc=sg:GetFirst()
                Duel.SpecialSummonStep(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
                --设置正规出场标记
                sc:CompleteProcedure()
                Duel.SpecialSummonComplete()
            end
        end
    end
end

--②效果过滤：墓地·除外状态的5星以下极星怪兽
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x42) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--②效果目标
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

--②效果处理
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end