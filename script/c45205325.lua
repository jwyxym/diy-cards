--谜题漩涡：福尔摩斯 (45205325)
--卡密ID: 45205325
--字段代码: 0x1D5C

local s,id=GetID()

function s.initial_effect(c)
    --融合召唤限制
    c:EnableReviveLimit()
    aux.AddFusionProcMix(c,true,true,
        aux.FilterBoolFunction(s.fusfilter1),
        aux.FilterBoolFunction(s.fusfilter2))
    
    -- ★★★ 规则上也当作「侦探」卡使用 ★★★
    local e_code=Effect.CreateEffect(c)
    e_code:SetType(EFFECT_TYPE_SINGLE)
    e_code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e_code:SetCode(EFFECT_ADD_SETCODE)
    e_code:SetValue(0x1D5C)
    c:RegisterEffect(e_code)
    
    --不能作为融合素材
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e0:SetValue(1)
    c:RegisterEffect(e0)
    
    --①效果：保护自己场上的魔法师族怪兽（战斗·效果破坏抗性）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.indetg)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_MZONE,0)
    e1b:SetTarget(s.indetg)
    e1b:SetValue(1)
    c:RegisterEffect(e1b)
    
    --自肃：不能特殊召唤魔法师族以外的怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.splimit)
    e2:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e2)
    
    --②效果：从卡组送墓
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.gvtg)
    e3:SetOperation(s.gvop)
    c:RegisterEffect(e3)
    
    --③效果：魔陷发动时从卡组·手卡特召侦探怪兽
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+100)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

--融合素材条件1：7星以上的侦探怪兽
function s.fusfilter1(c)
    return c:IsSetCard(0x1D5C) and c:IsLevelAbove(7)
end

--融合素材条件2：魔法师族怪兽
function s.fusfilter2(c)
    return c:IsRace(RACE_SPELLCASTER)
end

--①效果保护目标（魔法师族）
function s.indetg(e,c)
    return c:IsRace(RACE_SPELLCASTER)
end

--①效果自肃
function s.splimit(e,c)
    return not c:IsRace(RACE_SPELLCASTER)
end

--②效果：从卡组送墓过滤
function s.gvfilter(c)
    if not c:IsType(TYPE_MONSTER) then return false end
    return c:IsSetCard(0x1D5C) or (c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7))
end

function s.gvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.gvfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.gvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gvfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

--③效果：魔陷发动时特召侦探怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end