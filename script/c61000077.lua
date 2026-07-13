--路观大王
local s,id,o=GetID()
function s.initial_effect(c)
  local e0=Effect.CreateEffect(c)
  e0:SetDescription(aux.Stringid(id,0))
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  e0:SetCondition(s.handcon)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetHintTiming(0,TIMING_BATTLE_START)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_PIERCE)
  e2:SetRange(LOCATION_REMOVED)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
  e2:SetValue(0)
  c:RegisterEffect(e2)
end


function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)<=1
end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.rmfilter(c)
    return c:IsFaceup() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.excountfilter(c)
    return c:IsSetCard(0x97C0) and c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    local atk=tc:GetTextAttack()
    if atk<0 then atk=0 end
    if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
        Duel.Damage(tp,atk,REASON_EFFECT)
        Duel.Damage(1-tp,atk,REASON_EFFECT)
        local exg=Duel.GetMatchingGroup(s.excountfilter,tp,LOCATION_REMOVED,0,nil)
        local ct=#exg
        if ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct 
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Remove(Duel.GetDecktopGroup(tp,ct),POS_FACEUP,REASON_EFFECT)
        end
        if c:IsRelateToEffect(e) then
            Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        end
    end
end