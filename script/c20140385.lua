local s,id,o=GetID()
function s.initial_effect(c)
    -- ① 连锁3以后：手卡·场上发动，1星融合召唤+卡名代用
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    -- ② 结束阶段回收
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.con2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end
-- ①
function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain()>1
end
function s.fusfilter(c,e,tp)
    return c:IsLevel(1)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local e_sub=Effect.CreateEffect(c)
    e_sub:SetType(EFFECT_TYPE_SINGLE)
    e_sub:SetCode(EFFECT_FUSION_SUBSTITUTE)
    c:RegisterEffect(e_sub)
    local fe=FusionSpell.CreateSummonEffect(e:GetHandler(),{
        fusfilter=function(card) return s.fusfilter(card,e,tp) end,
        matfilter=function(card) return card:IsSetCard(0x2b1) end,
        pre_select_mat_location=LOCATION_HAND+LOCATION_MZONE,
    })
    e:SetLabelObject(fe)
    local res
    if chk==0 then
        res=fe:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)
    else
        fe:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1)
        res=true
    end
    e_sub:Reset()
    return res
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e_sub=Effect.CreateEffect(c)
    e_sub:SetType(EFFECT_TYPE_SINGLE)
    e_sub:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e_sub:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE)
    c:RegisterEffect(e_sub)
    local fe=e:GetLabelObject()
    if fe then
        fe:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
    end
end
-- ②
function s.lv1fusfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsLevel(1) and c:IsFaceup()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.lv1fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
