-- 画龙之北·黑
local s,id,o=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    -- 不能超量召唤（只能用自身效果特殊召唤）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.FALSE)
    c:RegisterEffect(e1)
    -- 通过除外场上素材特殊召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_EXTRA)
    e2:SetValue(SUMMON_VALUE_SELF)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- 特殊召唤成功时，选场上卡重叠
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetTarget(s.ovtg)
    e3:SetOperation(s.ovop)
    c:RegisterEffect(e3)
end

function s.refilter(c,tp)
    return ((c:GetOriginalRace()&RACE_WYRM>0 and not c:IsLocation(LOCATION_MZONE)) or c:IsRace(RACE_WYRM))
        and (c:IsControler(tp) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function s.rfilter(c,tp)
    return ((c:GetOriginalAttribute()&ATTRIBUTE_DARK>0 and not c:IsLocation(LOCATION_MZONE)) or c:IsAttribute(ATTRIBUTE_DARK))
        and (c:IsControler(tp) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function s.fselect(g,tp)
    return g:IsExists(s.rfilter,1,nil,tp) and Duel.GetMZoneCount(tp,g)>0
end
function s.spcon(e,c,tp)
    if c==nil then return true end
    local rg=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
    return rg:CheckSubGroup(s.fselect,2,2,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local rg=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
    local g1=g:Filter(Card.IsPreviousLocation,nil,LOCATION_MZONE)
    local g2=g:Filter(Card.IsPreviousLocation,nil,LOCATION_SZONE)
    local atk=g1:GetSum(Card.GetPreviousAttackOnField)+g2:GetSum(Card.GetBaseAttack)
    local def=g1:GetSum(Card.GetPreviousDefenseOnField)+g2:GetSum(Card.GetBaseDefense)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_DEFENSE)
    e2:SetValue(def)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
    c:RegisterEffect(e2)
    g:DeleteGroup()
end

function s.ovfilter(c)
    return c:IsCanOverlay()
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=math.floor(e:GetHandler():GetAttack()/2000)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,ct,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=math.floor(c:GetAttack()/2000)
    if ct<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
    if #g>0 then
        Duel.Overlay(c,g)
    end
end