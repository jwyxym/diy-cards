-- 沉寂死亡之弦 Mortis
-- ID: 15040041
-- 「赞颂音乐的人偶」(15040037) 卡名记述
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」

    -- ① 自己·对方的主要阶段及对方战斗阶段，丢弃这张卡，取除场上1个超量素材，之后可特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rmcon)
    e1:SetCost(s.rmcost)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- ② 这张卡在墓地，自己主要阶段，取除自己场上1个超量素材，这张卡特殊召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- ① 条件：主要阶段或对方战斗阶段
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if ph==PHASE_MAIN1 or ph==PHASE_MAIN2 then return true end
    if Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then return true end
    return false
end

-- ① cost：丢弃这张卡
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- ① 目标：场上存在有超量素材的超量怪兽
function s.ovfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

-- ① 操作：取除场上1个超量素材，之后可特召
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
    if not tc then return end
    tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)

    -- 之后可以从手卡·墓地·除外状态特召1只记述「赞颂音乐的人偶」的植物族以外怪兽
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local spfilter=function(c,e,tp)
        return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER)
            and not c:IsRace(RACE_PLANT)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    local sgroup=Duel.GetMatchingGroup(spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    if #sgroup>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local spg=sgroup:Select(tp,1,1,nil)
        if #spg>0 then
            Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- ② 条件：自己主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ② cost：取除自己场上1个超量素材
function s.ovfilter2(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.ovfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        tc:RemoveOverlayCard(tp,1,1,REASON_COST)
    end
end

-- ② 目标：自身从墓地特召
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ② 操作：特召自身，并赋予离场除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end