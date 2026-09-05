-- 《圣夜辉星龙》
-- 卡号：55236532
local s,id=GetID()

function s.initial_effect(c)
    -- ① 暗属性怪兽效果发动时，无效并破坏（不限位置）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- ② 不受暗属性怪兽效果影响
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- ③ 其他光属性从场上回手时，从手卡特召
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rp==1-tp and rc and rc:IsAttribute(ATTRIBUTE_DARK)
        and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev) then
        local rc=re:GetHandler()
        local c=e:GetHandler()
        -- 直接破坏那只暗属性怪兽（锁缚龙式写法，不限位置）
        if rc and rc:IsRelateToEffect(re) then
            Duel.Destroy(rc,REASON_EFFECT)
        end
        -- 辉星龙自己回手卡
        if c and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    end
end
function s.immval(e,te)
    local rc=te:GetHandler()
    return rc and rc:IsAttribute(ATTRIBUTE_DARK) and te:IsActiveType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=eg:GetFirst()
    while g do
        if g:IsPreviousLocation(LOCATION_ONFIELD)
            and g:IsAttribute(ATTRIBUTE_LIGHT)
            and not g:IsCode(c:GetCode()) then
            return true
        end
        g=eg:GetNext()
    end
    return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end