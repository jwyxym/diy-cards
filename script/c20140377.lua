local s,id,o=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcCodeFunRep(c,20140363,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),1,127,true,true)
    -- ① 每连锁双方最多1次特召
    local e_lock=Effect.CreateEffect(c)
    e_lock:SetType(EFFECT_TYPE_FIELD)
    e_lock:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_lock:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e_lock:SetTargetRange(1,1)
    e_lock:SetRange(LOCATION_MZONE)
    e_lock:SetCondition(s.lockcon)
    c:RegisterEffect(e_lock)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.limitop)
    c:RegisterEffect(e1)
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1b:SetCode(EVENT_CHAIN_END)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetOperation(s.chainendop)
    c:RegisterEffect(e1b)
    -- ② 特召→除外（3体以上除外2张）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    -- ③ 战阶开始→解放自身→特召其他闪星
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+o)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local ct=1
    local mat3=e:GetHandler():GetMaterialCount()>=3 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
    if mat3 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then ct=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,ct,ct,nil)
    if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.spfilter3(c,e,tp)
    return c:IsSetCard(0x2b1) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable()
        and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Release(e:GetHandler(),REASON_EFFECT)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
-- ① 连锁中第1次特召后打flag→后续封锁、连锁结束时清除
function s.lockcon(e)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.limitop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentChain()==0 then return end
    if e:GetHandler():GetFlagEffect(id)==0 then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
    end
end
function s.chainendop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():ResetFlagEffect(id)
end
