-- 逆时残响 维拉
-- ID: 26052001
-- 字段：逆时残响 0x910 / 升阶 0x911
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.linkcon)
    e0:SetOperation(s.linkop)
    e0:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e0)

    -- 规则上也当作「升阶」卡
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x911)
    c:RegisterEffect(e0b)

    -- ① 连接召唤时，从卡组特召1只本家调整
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 宣言等级
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end

function s.lkfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end

-- 链接条件：只做素材检查，不做位置检查
function s.linkcon(e,c,og,lmat,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local g = Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
    if #g < 2 then return false end
    return g:FilterCount(Card.IsSetCard,nil,0x910) >= 1
end

function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
    if c==nil then return end
    local g = Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
    local honka = g:Filter(Card.IsSetCard,nil,0x910)
    if #honka < 1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg1 = honka:Select(tp,1,1,nil)
    if #sg1 < 1 then return end
    local mat1 = sg1:GetFirst()
    local g2 = g:Clone()
    g2:RemoveCard(mat1)
    if #g2 < 1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg2 = g2:Select(tp,1,1,nil)
    if #sg2 < 1 then return end
    local sg = sg1:Clone()
    sg:Merge(sg2)
    c:SetMaterial(sg)
    Duel.SendtoGrave(sg, REASON_MATERIAL+REASON_LINK)
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_TUNER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.splimit(e,c)
    return not c:IsRace(RACE_SPELLCASTER)
end

-- ② 等级变化
function s.lvfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and not c:IsType(TYPE_LINK) and c:IsLevelAbove(1)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
    local lv=Duel.AnnounceLevel(tp,1,8)
    e:SetLabel(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local lv=e:GetLabel()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and lv>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end