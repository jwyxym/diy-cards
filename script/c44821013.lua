-- BLACK SHOUT
-- ID: 44821013
-- 通常魔法
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- ① 自己场上没有怪兽时，从手卡·卡组融合召唤7星以下记述「Roselia」的融合怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.fucon)
    e1:SetTarget(s.futg)
    e1:SetOperation(s.fuop)
    c:RegisterEffect(e1)

    -- ② 除外墓地的此卡，回收2只记述「Roselia」的怪兽，并禁止发动其及同名卡效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.recost)
    e2:SetTarget(s.retg)
    e2:SetOperation(s.reop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上没有怪兽
function s.fucon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- ① 融合素材：记述「Roselia」的怪兽（手卡·卡组）
function s.matfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_MONSTER)
end

-- ① 融合怪兽过滤：记述「Roselia」、融合、7星以下
function s.ffilter(c,e,tp,mg)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_FUSION) and c:IsLevelBelow(7)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,PLAYER_NONE)
end

function s.futg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
        return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fuop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
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

    -- 自肃：本回合额外卡组只能特召植物族融合怪兽
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not (c:IsRace(RACE_PLANT) and c:IsType(TYPE_FUSION))
    end
    return false
end

-- ② cost：除外墓地的此卡
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ② 回收对象：记述「Roselia」的怪兽
function s.retfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,2,2,nil)
    if #sg<2 then return end
    local codes={}
    local tc=sg:GetFirst()
    while tc do
        codes[tc:GetCode()]=true
        tc=sg:GetNext()
    end
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
    -- 禁止发动这些卡及同名卡的效果
    for code in pairs(codes) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(s.aclimit)
        e1:SetLabel(code)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.aclimit(e,re,tp)
    local code=e:GetLabel()
    local rc=re:GetHandler()
    return rc and rc:GetCode()==code
end