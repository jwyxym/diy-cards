-- 属于我们的歌 丰川祥子
-- ID: 26062906
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- 同调召唤限制：协调1只 + “初次的邂逅 丰川祥子”(26062901)
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),
        aux.FilterBoolFunction(Card.IsCode,26062901), 1)

    -- ① 同调召唤成功时，以自己墓地1只记述「春日影」的怪兽为对象特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 只要自己场上存在“春日影”，自己场上的记述「春日影」怪兽不会被战斗破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(aux.IsCodeListed,26062911))
    e2:SetValue(1)
    e2:SetCondition(s.indcon)
    c:RegisterEffect(e2)
end

-- ① 条件：同调召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ① 对象：自己墓地1只记述「春日影」的怪兽
function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c,26062911) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 条件：自己场上存在“春日影”(26062911)
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsCode(26062911) and c:IsFaceup() end,tp,LOCATION_ONFIELD,0,1,nil)
end