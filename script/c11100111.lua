--遗胤死物·隐士饮酒依旧
local cm,m,o=GetID()
function cm.initial_effect(c)
    Duel.LoadScript("c11100117.lua")
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(m,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.spcon)
    e1:SetTarget(cm.sptg)
    e1:SetOperation(cm.spop)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(m,ACTIVITY_CHAIN,cm.chainfilter)
    lion_dance.ass_synchro_material(c,m,cm.synchro_filter,cm.tg,cm.op)
end
function cm.chainfilter(re,tp,cid)
    local rc=re:GetHandler()
    return rc:IsCode(m) or not ((rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE))
        or (rc:IsSetCard(0xa64)))
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(m,tp,ACTIVITY_CHAIN)>0
        or Duel.GetCustomActivityCount(m,1-tp,ACTIVITY_CHAIN)>0
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
    lion_dance.splimit(e:GetHandler(),tp)
end
function cm.synchro_filter(c)
    return (c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_SPELLCASTER)) or (c:IsSetCard(0xa64))
end
function cm.filter(c)
    return c:IsSetCard(0xa64) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if tc and Duel.SSet(tp,tc)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(m,0))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end