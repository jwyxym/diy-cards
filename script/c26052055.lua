-- 畴狱黑主 摩莉甘
-- ID: 26052055
-- 字段：穚镰鸦姬 0x914
local s,id=GetID()
local RACE_BIRD = 512

function s.is_bird(c)
    if not c then return false end
    local r=c:GetRace()
    return (r & RACE_BIRD)~=0 or r==1029
end

function s.initial_effect(c)
    -- 规则上当作本家卡
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x914)
    c:RegisterEffect(e0)

    c:EnableReviveLimit()
    -- 素材：11星鸟兽族怪兽×2
    aux.AddXyzProcedure(c,s.mfilter,11,2)

    -- ① 特殊召唤时自己场上卡全部破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- ② 被送去墓地时：进行1只鸟兽族怪兽的上级召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.advtg)
    e2:SetOperation(s.advop)
    c:RegisterEffect(e2)
end

-- 素材过滤：11星鸟兽族怪兽
function s.mfilter(c)
    return c:IsLevel(11) and s.is_bird(c)
end

-- ①
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
    if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end

-- ② 过滤：鸟兽族 + 等级5以上 + 需要至少1个祭品
-- 去掉了 c:IsSummonable 的调用，彻底避免引擎参数报错
function s.advfilter(c)
    if not s.is_bird(c) then return false end
    if not c:IsLevelAbove(5) then return false end
    return c:GetTributeRequirement() > 0
end

-- 对方场上可作为代替祭品的怪兽
function s.relfilter(c)
    return c:IsType(TYPE_MONSTER)
        and not c:IsHasEffect(EFFECT_UNRELEASABLE_SUM)
        and not c:IsHasEffect(EFFECT_UNRELEASABLE_NONSUM)
end

function s.advtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.relfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.advfilter,tp,LOCATION_HAND,0,1,nil)
    end
    -- 对方有可解放怪兽时，选择 1 只作为代替祭品（可选）
    if Duel.IsExistingTarget(s.relfilter,tp,0,LOCATION_MZONE,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        Duel.SelectTarget(tp,s.relfilter,tp,0,LOCATION_MZONE,1,1,nil)
    end
end

function s.advop(e,tp,eg,ep,ev,re,r,rp)
    -- 给对象注册 EFFECT_EXTRA_RELEASE，允许作为上级召唤祭品
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_RELEASE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
    -- 选择手卡中需要祭品的鸟兽族怪兽
    local g=Duel.GetMatchingGroup(s.advfilter,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    -- 引擎按怪兽等级自动要求祭品，执行真正的上级召唤
    Duel.Summon(tp,sc,true,nil)
end