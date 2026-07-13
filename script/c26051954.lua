-- 无垠轨途 那由他
-- ID: 26051954
-- 字段: 无垠轨途 (0x903)
local s,id=GetID()
function s.initial_effect(c)
    -- Link召唤限制：包含「无垠轨途」怪兽的怪兽2只以上
    aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
    c:EnableReviveLimit()

    -- ① 攻击力上升自己场上「无垠轨途」怪兽数量×400
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- ② 双方回合，苏生自己墓地1只魔法师族怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- ③ 不受对方发动的怪兽·魔法卡的效果影响
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)
end

-- 链接素材检查：遍历素材组，至少1只「无垠轨途」怪兽
function s.lcheck(g)
    local tc=g:GetFirst()
    while tc do
        if tc:IsSetCard(0x903) then return true end
        tc=g:GetNext()
    end
    return false
end

-- ① 攻击力计算
function s.atkfilter(c)
    return c:IsSetCard(0x903) and c:IsFaceup()
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*400
end

-- ② 苏生对象：自己墓地的魔法师族怪兽
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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

-- ③ 免疫过滤：对方发动的怪兽效果或魔法卡效果
function s.immval(e,te)
    local tp=e:GetHandlerPlayer()
    return te:GetOwnerPlayer()~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsActiveType(TYPE_SPELL))
end