local s,id=GetID()
local SET_SEIKI = 0x474
local SET_MOKUSHOKU = 0x747

function s.initial_effect(c)
    -- ① 发动效果（选发）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- ② 圣辉怪兽回卡组/额外，特召同阶级暗属性超量
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(2,id+1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- ③ 被怪兽效果送墓，表侧放置
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+1)
    e3:SetCondition(s.gycon)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- ① 发动时处理（增加选发弹窗）
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSetCard(SET_SEIKI) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
    end, tp, LOCATION_HAND+LOCATION_REMOVED, 0, nil)
    
    if #g>0 then
        -- ★ 核心修改：先询问是否要放置
        if Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.MoveToField(sg:GetFirst(), tp, tp, LOCATION_SZONE, POS_FACEUP, true)
            end
        end
    end
end

-- ② 条件：怪兽回卡组/额外卡组
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) 
        return (c:IsSetCard(SET_SEIKI) or c:IsSetCard(SET_MOKUSHOKU)) and c:IsType(TYPE_MONSTER) 
    end, 1, nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local tc = eg:GetFirst()
        local lv = tc:GetLevel()
        return Duel.IsExistingMatchingCard(function(c) 
            return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:GetRank() == lv 
                and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) 
        end, tp, LOCATION_EXTRA, 0, 1, nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc = eg:GetFirst()
    if not tc then return end
    local lv = tc:GetLevel()
    local g = Duel.GetMatchingGroup(function(c) 
        return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:GetRank() == lv
            and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false) 
    end, tp, LOCATION_EXTRA, 0, nil)
    
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        local sc = sg:GetFirst()
        if sc then
            Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP_ATTACK)
            sc:CompleteProcedure()
        end
    end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT) and re and re:GetHandler():IsType(TYPE_MONSTER)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end