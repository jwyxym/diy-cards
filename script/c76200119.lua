--炽神界·天狮
local cm,m,o=GetID()
function cm.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(cm.cost)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --act in set turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCondition(cm.actcon)
    c:RegisterEffect(e2)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
    return true
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if e:GetLabel()==0 then return false end
        e:SetLabel(0)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0x721,TYPES_NORMAL_TRAP_MONSTER,1500,700,4,RACE_FAIRY,ATTRIBUTE_FIRE) end
    e:SetLabel(0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0x721,TYPES_NORMAL_TRAP_MONSTER,1500,700,4,RACE_FAIRY,ATTRIBUTE_FIRE) then
        c:AddMonsterAttribute(TYPE_NORMAL)
        Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
    end
end
function cm.actcon(e)
    return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.filter(c)
    return c:IsSetCard(0x721) and c:IsLevel(4) and c:IsFaceup()
end