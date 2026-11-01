-- 我，该怎么办… 白金燐子
-- ID: 44821005
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- ① 自己场上有「Roselia」或记述「Roselia」的怪兽时，从手卡特殊召唤，并附加自肃
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

    -- ② 召唤·特殊召唤成功时，三选一
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.optg)
    e2:SetOperation(s.opot)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上有「Roselia」或记述「Roselia」的怪兽
-- 注意：「Roselia」是场地魔法，需要搜索 LOCATION_ONFIELD
function s.fieldfilter(c)
    return c:IsFaceup() and (c:IsCode(44821000) or (c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,44821000)))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：本回合额外卡组只能特召植物族融合怪兽
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not (c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION))
    end
    return false
end

-- ② 选项1：墓地记述「Roselia」的怪兽（自身除外）
function s.spfilter1(c,e,tp)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选项2：墓地记述「Roselia」的魔法·陷阱
function s.setfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 选项3：记述「Roselia」的融合怪兽
function s.ffilter(c,e,tp,mg)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,PLAYER_NONE)
end

-- ② 目标
function s.optg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
        local mg=Duel.GetFusionMaterial(tp)
        local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_HAND,0,nil)
        mg:Merge(mg2)
        local b3=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
        return b1 or b2 or b3
    end
end

-- ② 操作
function s.opot(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
    local mg=Duel.GetFusionMaterial(tp)
    local mg2=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_HAND,0,nil)
    mg:Merge(mg2)
    local b3=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)

    local ops={}
    local opval={}
    if b1 then
        ops[#ops+1]=aux.Stringid(id,2)
        opval[#opval+1]=1
    end
    if b2 then
        ops[#ops+1]=aux.Stringid(id,3)
        opval[#opval+1]=2
    end
    if b3 then
        ops[#ops+1]=aux.Stringid(id,4)
        opval[#opval+1]=3
    end
    if #ops==0 then return end
    local sel=opval[Duel.SelectOption(tp,table.unpack(ops))+1]

    if sel==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif sel==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    elseif sel==3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
        local sc=sg:GetFirst()
        if not sc then return end
        local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,PLAYER_NONE)
        if mat:GetCount()==0 then return end
        sc:SetMaterial(mat)
        Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end