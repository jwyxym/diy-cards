-- CryChic
-- ID: 15040027
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)
    c:EnableReviveLimit()

    -- 不能同调召唤 / 不能以其他方式特殊召唤
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- 自身特殊召唤手续：把2只记述「春日影」的表侧怪兽送去墓地
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ① 从额外卡组特殊召唤成功时，苏生自己墓地最多2只记述怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- ② 对方发动效果时，解放自身，本回合自己场上的「春日影」不受对方效果影响
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.immcon)
    e3:SetCost(s.immcost)
    e3:SetOperation(s.immop)
    c:RegisterEffect(e3)
end

-- 限制仅对从额外卡组特殊召唤生效
function s.splimit(e,se,sp,st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

-- 自身特殊召唤手续：条件（移除空位检查，因为送墓会腾出格子）
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
    return g:GetCount()>=2
end

-- 素材过滤：表侧表示，记述「春日影」，可送去墓地
function s.matfilter(c)
    return c:IsFaceup() and aux.IsCodeListed(c,26062911) and c:IsAbleToGrave()
end

-- 选择并记录素材
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
    if g:GetCount()<2 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:Select(tp,2,2,nil)
    if #sg~=2 then return false end
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end

-- 执行送去墓地，引擎自动特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg and #sg==2 then
        Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_SYNCHRO)
    end
end

-- ① 条件：从额外卡组特殊召唤
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

-- ① 苏生对象：自己墓地记述「春日影」的怪兽
function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    local tc=g:GetFirst()
    while tc do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        tc=g:GetNext()
    end
    Duel.SpecialSummonComplete()
end

-- ② 条件：对方发动效果
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end

-- ② cost：解放自身
function s.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- ② 操作：本回合自己场上的「春日影」不受对方效果影响
function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(s.immtg)
    e1:SetValue(s.immval)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.immtg(e,c)
    return c:IsCode(26062911)
end
function s.immval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end