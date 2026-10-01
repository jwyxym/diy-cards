-- 荆棘环绕处 槲寄生
-- ID: 26052010
-- 字段：逆时残响 0x910 / 升阶 0x911
-- 4星调整/风/魔法师
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上也当作「升阶」「逆时残响」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x911)
    c:RegisterEffect(e0)
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x910)
    c:RegisterEffect(e0b)

    -- ① 手卡特召 + 立即同调召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

-- 本家怪兽过滤
function s.honka_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x910)
end

-- 同调怪兽过滤
function s.synfilter(c,lv)
    return c:IsSetCard(0x910) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==lv
end

-- ① 条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if not (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then return false end
    if not e:GetHandler():IsLocation(LOCATION_HAND) then return false end
    return Duel.IsExistingMatchingCard(s.honka_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.honka_filter(chkc) end
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
        local g=Duel.GetMatchingGroup(s.honka_filter,tp,LOCATION_MZONE,0,nil)
        if #g==0 then return false end
        local lv_c=c:GetLevel()
        local tc=g:GetFirst()
        while tc do
            local lv=lv_c+tc:GetLevel()
            if Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,lv) then
                return true
            end
            tc=g:GetNext()
        end
        return false
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.honka_filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- ① 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    -- 特召自身
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- 判断同调素材：确保1调整+1非调整
    if tc:IsType(TYPE_TUNER) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_NONTUNER)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end

    -- 计算等级和
    local lv=c:GetLevel()+tc:GetLevel()

    -- 选择额外卡组的同调怪兽
    local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,lv)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end

    -- 手动送墓：逐张处理素材（最基础 API）
    Duel.SendtoGrave(Group.FromCards(c), REASON_MATERIAL+REASON_SYNCHRO)
    Duel.SendtoGrave(Group.FromCards(tc), REASON_MATERIAL+REASON_SYNCHRO)

    -- 特召同调怪兽
    Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
end