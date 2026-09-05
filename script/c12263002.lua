--天水 ：底格里斯
local s,id,o=GetID()
function s.initial_effect(c)
    --①效果：修复DELAY+独立ID+双方触发
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY) -- 必加！
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,12263002) -- 绝对独立
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    --②效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SSET+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,122630021)
    e2:SetCondition(s.spscon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

--==============================
-- ①条件：双方连接/仪式（去掉tp）
--==============================
function s.cfilter(c)
    return c:IsType(TYPE_LINK+TYPE_RITUAL) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil)
end

--==============================
-- ①目标：全场表侧（去掉CheckUniqueOnField）
--==============================
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

--==============================
-- ①处理
--==============================
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc:IsRelateToEffect(e) or tc:IsFacedown() then
        Duel.SendtoGrave(c,REASON_EFFECT)
        return
    end
    if not Duel.Equip(tp,c,tc) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(s.eqlimit)
    e1:SetLabelObject(tc)
    c:RegisterEffect(e1)
end

function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end

--==============================
-- ②效果
--==============================
function s.spscon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.setfilter(c)
    return c:IsSetCard(0x5244) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.exfilter(c)
    return c:IsRace(RACE_CYBERSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g) end

    local dg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
    if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local sg=dg:Select(tp,1,1,nil)
        Duel.Destroy(sg,REASON_EFFECT)
    end

    -- 修复召唤限制：写法更稳，不锁手卡/墓地的3002
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- 【修复】召唤限制：只限制“从额外特召”
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK)
end
