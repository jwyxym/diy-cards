--与你共赴，新的未来。
local s,id=GetID()
function s.initial_effect(c)
    --超量召唤：8星怪兽×2
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c, s.xyzfilter, 8, 2)

    --① 用指定两只怪兽为素材超量召唤成功时，取除全部素材，除外对方全部魔陷
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rmcon)
    e1:SetCost(s.rmcost)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    --② 自己回合，让这张卡回到额外卡组，从墓地·除外特召指定两只怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

--超量素材条件：8星怪兽
function s.xyzfilter(c)
    return c:IsLevel(8)
end

--①条件：超量召唤成功，且素材包含指定的两只怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_XYZ) then return false end
    local mg=c:GetMaterial()
    if not mg then return false end
    return mg:IsExists(Card.IsCode,1,nil,44810520)
        and mg:IsExists(Card.IsCode,1,nil,44810521)
end

--① cost：取除全部超量素材
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetOverlayCount()
    if chk==0 then return ct>0 and c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
    c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end

--①目标：对方场上魔法·陷阱卡全部除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
    end
    local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

--②条件：自己回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

--②目标
function s.spfilter(c,e,tp)
    return c:IsCode(44810520,44810521) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        if not c:IsAbleToExtra() then return false end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
        return g:IsExists(Card.IsCode,1,nil,44810520)
            and g:IsExists(Card.IsCode,1,nil,44810521)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

--②操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    if not (g1:IsExists(Card.IsCode,1,nil,44810520) and g1:IsExists(Card.IsCode,1,nil,44810521)) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or c:IsLocation(LOCATION_EXTRA) then return end

    --特召「无闻的勇者 纳格迩·钴格」
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg1=Duel.SelectMatchingCard(tp,function(tc,e,tp)
        return tc:IsCode(44810520) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc1=sg1:GetFirst()
    if not tc1 then return end
    if Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc1:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
        tc1:RegisterEffect(e2)
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
        tc1:RegisterEffect(e3)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
        tc1:RegisterEffect(e4)
    end

    --特召「誓约的精灵 希欧娜·埃德尔」
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg2=Duel.SelectMatchingCard(tp,function(tc,e,tp)
        return tc:IsCode(44810521) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc2=sg2:GetFirst()
    if tc2 and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc2:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
        tc2:RegisterEffect(e2)
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
        tc2:RegisterEffect(e3)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
        tc2:RegisterEffect(e4)
    end
    Duel.SpecialSummonComplete()
end


