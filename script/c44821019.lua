-- 按捺不住的泪水 凑友希那
-- ID: 44821007
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)          -- 此卡记述「Roselia」
    aux.AddMaterialCodeList(c,44821001)  -- 融合素材包含「歌姬的觉悟 凑友希那」

    -- 融合召唤：只能用融合召唤
    c:EnableReviveLimit()
    aux.AddFusionProcMix(c, false, true,
        aux.FilterBoolFunction(Card.IsFusionCode,44821001),  -- ① 「歌姬的觉悟 凑友希那」
        function(c2)
            return c2:IsFusionType(TYPE_FUSION) and c2:IsRace(RACE_PLANT) and c2:IsAttribute(ATTRIBUTE_DARK)
        end,                                                  -- ② 植物族·暗属性融合怪兽
        function(c2)
            return c2:IsRace(RACE_PLANT) and c2:IsAttribute(ATTRIBUTE_DARK) and c2:IsType(TYPE_MONSTER)
                and not c2:IsFusionCode(44821001)             -- ③ 植物族·暗属性怪兽（排除已作为素材①的凑友希那）
        end
    )

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- ① 融合召唤成功时，从墓地尽可能特殊召唤守备力2700的植物族融合怪兽（同名最多1只），然后自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 只要这张卡在怪兽区域存在，自己场上的融合怪兽控制权不能变更
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
    c:RegisterEffect(e2)

    -- ③ 自己场上有3只以上记述「Roselia」的怪兽时，对方把卡的效果发动时，无效并除外
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

-- ① 条件：融合召唤成功
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ① 操作
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 then return end
    -- 去重同名，每张卡名最多1只
    local sg=Group.CreateGroup()
    local codes={}
    local tc=g:GetFirst()
    while tc do
        local code=tc:GetCode()
        if not codes[code] then
            codes[code]=true
            sg:AddCard(tc)
        end
        tc=g:GetNext()
    end
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local tc=sg:GetFirst()
    while tc and ft>0 do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            ft=ft-1
        end
        tc=sg:GetNext()
    end
    Duel.SpecialSummonComplete()

    -- 自肃：直到回合结束不能把怪兽特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(aux.TRUE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
-- ① 可苏生对象：守备力2700的植物族融合怪兽（自身除外）
function s.revfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PLANT)
        and c:GetBaseDefense()==2700 and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ③ 条件：对方发动效果，且自己场上有3只以上记述「Roselia」的怪兽
function s.negfilter(c)
    return c:IsFaceup() and aux.IsCodeListed(c,44821000)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    return Duel.GetMatchingGroupCount(s.negfilter,tp,LOCATION_MZONE,0,nil)>=3
end
-- ③ 目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
-- ③ 操作：无效并除外
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc and rc:IsRelateToEffect(re) then
            Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
        end
    end
end