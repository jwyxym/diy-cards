-- 即将终结的轮回
-- ID: 12950002
-- 字段：恐吓爪牙族 0x17a / 珠泪哀歌族 0x181 / 俱舍怒威族 0x189 / 末那愚子族 0x190
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上视作四个字段
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x17a)
    c:RegisterEffect(e0)
    local e0a=e0:Clone()
    e0a:SetValue(0x181)
    c:RegisterEffect(e0a)
    local e0b=e0:Clone()
    e0b:SetValue(0x189)
    c:RegisterEffect(e0b)
    local e0c=e0:Clone()
    e0c:SetValue(0x190)
    c:RegisterEffect(e0c)

    -- ① 双方主阶：卡组选1只四字段怪兽除外，特召同属性的俱舍怪兽，之后自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tgtg1)
    e1:SetOperation(s.tgop1)
    c:RegisterEffect(e1)

    -- ② 除外状态，阿莱斯哈特因对方离场：除外卡组/墓地莱斯哈特，特召阿莱斯哈特
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

-- ① 修复：加入同属性俱舍怪兽的检查，防止因为卡组无对应属性而无法发动
function s.rmfilter1(c, tp)
    if not c:IsType(TYPE_MONSTER) then return false end
    if not (c:IsSetCard(0x189) or c:IsSetCard(0x17a) or c:IsSetCard(0x181) or c:IsSetCard(0x190)) then return false end
    local attr = c:GetAttribute()
    -- 必须在卡组里有同属性的俱舍怪兽
    return Duel.IsExistingMatchingCard(function(sc)
        return sc:IsSetCard(0x189) and sc:IsType(TYPE_MONSTER) and sc:GetAttribute()==attr
    end, tp, LOCATION_DECK, 0, 1, nil)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.IsExistingMatchingCard(s.rmfilter1,tp,LOCATION_DECK,0,1,nil,tp) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        e:SetLabel(g:GetFirst():GetAttribute())
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end

function s.spfilter1(c,e,tp,attr)
    return c:IsSetCard(0x189) and c:IsType(TYPE_MONSTER) and c:GetAttribute()==attr
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    -- 支付cost时已经判断过，这里直接允许发动
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
    -- 自肃：不是超量不能额外特召
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    return not c:IsType(TYPE_XYZ)
end

-- ②
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsLocation(LOCATION_REMOVED) then return false end
    return eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.cfilter2(c,tp)
    return c:IsCode(48626373) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.rmfilter2(c)
    return c:IsCode(31149212) and c:IsAbleToRemove()
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
        and Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spfilter2(c,e,tp)
    return c:IsCode(48626373) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
    
    if Duel.GetLocationCountFromEx(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    end
end