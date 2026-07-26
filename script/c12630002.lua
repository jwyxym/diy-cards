--阿尔戈☆群星-心神之希波墨
--字段：阿尔戈☆群星（0x01C1）

local s,id,o=GetID()
local SET_ALGO_STARS=0x01C1

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetTarget(s.indestg)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1)
    e3:SetHintTiming(0,TIMING_END_PHASE)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1)
    e4:SetHintTiming(0,TIMING_MAIN_END)
    e4:SetCondition(s.setcon)
    e4:SetTarget(s.settg)
    e4:SetOperation(s.setop)
    c:RegisterEffect(e4)
end

function s.indestg(e,c)
    return c:IsFaceup()
end

--===============================================================================
-- ②效果：Cost（除外1张手卡，适配圣枪检测）
--===============================================================================
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=0 then return false end
        if Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_REMOVE) then return false end
        if Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_CANNOT_REMOVE) then return false end
        return true
    end
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and c:GetFlagEffect(id)==0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ALGO_STARS,TYPES_EFFECT_TRAP_MONSTER,1600,1600,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)
    end
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.setfilter(c)
    return c:IsSetCard(SET_ALGO_STARS) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
        and not c:IsCode(id) and c:IsSSetable()
end

function s.exfilter(c)
    return c:IsSetCard(SET_ALGO_STARS) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ALGO_STARS,TYPES_EFFECT_TRAP_MONSTER,1600,1600,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
    
    c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
    
    if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0 then
        if Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_REMOVED,0,1,nil) then
            local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
            if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
                local sg=g:Select(tp,1,1,nil)
                if #sg>0 then
                    Duel.BreakEffect()
                    Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                end
            end
        end
    end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and e:GetHandler():IsCanBePlacedOnField()
    end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
