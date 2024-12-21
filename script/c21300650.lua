--尸朽虫 双生龙
local cm,m,o=GetID()
function cm.initial_effect(c)
    c:EnableReviveLimit()
    --material
    aux.AddSynchroMixProcedure(c,aux.Tuner(cm.sycfilter),aux.Tuner(cm.sycfilter),nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1,1)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.synlimit)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(cm.con)
    e1:SetValue(function (e,re)
        return re:IsActivated()
    end)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetCondition(cm.con)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_MATERIAL_CHECK)
    e3:SetValue(cm.matcheck)
    c:RegisterEffect(e3)
    --todeck
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(m,0))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCondition(cm.rmcon)
    e4:SetTarget(cm.rmtg)
    e4:SetOperation(cm.rmop)
    e4:SetLabelObject(e3)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e5:SetTarget(cm.sptg)
    e5:SetOperation(cm.spop)
    c:RegisterEffect(e5)
end
function cm.sycfilter(c)
    return c:IsSetCard(0x679) and c:IsSynchroType(TYPE_SYNCHRO)
end
function cm.con(e)
    return Duel.IsExistingMatchingCard(function (c)
        return c:IsSetCard(0x679) and c:IsFaceup()
    end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function cm.matcheck(e,c)
    local ct=c:GetMaterial():Filter(Card.IsType,nil,TYPE_TUNER):GetCount()
    e:SetLabel(ct)
end
function cm.rmfilter(c)
    return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
function cm.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsType(TYPE_MONSTER) and chkc:IsAbleToRemove() end
    local ct=e:GetLabelObject():GetLabel()
    if chk==0 then return Duel.IsExistingTarget(cm.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and ct>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,cm.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function cm.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local g=tg:Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
function cm.spfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x679)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cm.filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(cm.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,cm.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local tg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
        if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=tg:Select(tp,1,1,nil)
            Duel.SynchroSummon(tp,sg:GetFirst(),nil)
        end
    end
end