--姬装战线·MAUS
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --同调召唤：地属性调整+调整以外的地属性怪兽1只以上
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),
        aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),
        1, 99)
    c:EnableReviveLimit()
    
    --①：这张卡同调召唤的场合，或者对方把怪兽特殊召唤的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果无效。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon1)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    
    local e1b=Effect.CreateEffect(c)
    e1b:SetDescription(aux.Stringid(id,0))
    e1b:SetCategory(CATEGORY_DISABLE)
    e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1b:SetCountLimit(1,id)
    e1b:SetCondition(s.negcon2)
    e1b:SetTarget(s.negtg)
    e1b:SetOperation(s.negop)
    c:RegisterEffect(e1b)
    
    --②：自己场上的「姬装战线」怪兽不受对方发动的魔法·陷阱卡的效果影响。
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.immtg)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)
    
    --③：这张卡在墓地存在的场合，以自己场上1张里侧表示的卡为对象才能发动。那张卡破坏，这张卡特殊召唤。
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+o)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.negcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.oppfilter,1,nil,1-tp)
end

function s.oppfilter(c,tp)
    return c:IsControler(tp)
end

function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled()) then return end
    
    --永久无效
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
end

--===============================================================================
-- ②效果：只免疫"发动"的魔法·陷阱卡效果
--===============================================================================
function s.immtg(e,c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER)
end

function s.immval(e,re)
    -- 只免疫对方"发动"的魔法·陷阱卡效果
    -- 发动的效果有 EFFECT_TYPE_ACTIVATE，永续效果没有
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
        and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
        and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

--===============================================================================
-- ③效果
--===============================================================================
function s.desfilter(c)
    return c:IsFacedown()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c,tc=e:GetHandler(),Duel.GetFirstTarget()
    
    --前置条件检查
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (c and c:IsRelateToEffect(e)) then return end
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    local des=false
    if tc:IsDestructable(e,REASON_EFFECT) then
        des=Duel.Destroy(tc,REASON_EFFECT)>0
    end
    
    --破坏失败则不处理特殊召唤
    if not des then return end
    
    --特殊召唤这张卡
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    
    --自肃：直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
    return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end
