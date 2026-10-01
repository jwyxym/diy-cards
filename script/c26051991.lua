-- 逆时残响 槲寄生
-- ID: 26051991
-- 字段：逆时残响 0x910
local s,id=GetID()
function s.initial_effect(c)
    -- ① 场上有其他本家时，手牌特召（当作调整使用）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 作为同调素材时，可当作调整以外使用
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_NONTUNER)
    e2:SetValue(s.ntval)
    c:RegisterEffect(e2)

    -- ③ 宣言1~8，等级变为宣言值
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_LVCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetTarget(s.lvtg)
    e3:SetOperation(s.lvop)
    c:RegisterEffect(e3)
end

-- ① 条件
function s.otherfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.otherfilter,tp,LOCATION_MZONE,0,1,nil)
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

-- ② 是否可当作非调整
function s.ntval(e,c)
    return c:IsSetCard(0x910)
end

-- ③ 宣言等级
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
    local lv=Duel.AnnounceLevel(tp,1,8)
    e:SetLabel(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lv=e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() and lv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end