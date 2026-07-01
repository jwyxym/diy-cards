--ゴーストリック
local s,id,o=GetID()
function s.initial_effect(c)
    -- 融合素材
    aux.AddFusionProcFun2(c,s.matfilter1,nil,true,true)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    -- 这张卡不能作为融合素材
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    -- 特殊召唤条件：解放2张鬼计卡从额外卡组特招
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.selfspcon)
    e1:SetTarget(s.selfsptg)
    e1:SetOperation(s.selfspop)
    e1:SetValue(SUMMON_TYPE_SPECIAL)
    c:RegisterEffect(e1)

    -- ①效果：特召时发动场地魔法
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ACTIVATE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- ②效果：特召鬼计怪兽
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)

    -- ③效果：反转时其他怪兽变表示形式
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_FLIP)
    e4:SetCountLimit(1,id)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetTarget(s.postg)
    e4:SetOperation(s.posop)
    c:RegisterEffect(e4)
end

-- 融合素材：鬼计怪兽
function s.matfilter1(c)
    return c:IsFusionSetCard(0x8d)
end

-- 特殊召唤条件：解放2张鬼计卡
function s.hspchk(g,tp,sc)
    return Duel.GetLocationCountFromEx(tp,tp,g,sc) > 0
end

function s.selfspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local rg=Duel.GetMatchingGroup(s.gufufilter,tp,LOCATION_ONFIELD,0,nil,tp,e:GetHandler())
    return rg:CheckSubGroup(s.hspchk, 2, 2,tp,e:GetHandler())
end

function s.gufufilter(c,tp,sc)
    return c:IsSetCard(0x8d) and c:IsReleasable(REASON_SPSUMMON) and c:IsControler(tp) and c:IsCanBeFusionMaterial(sc, SUMMON_TYPE_SPECIAL)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local rg=Duel.GetMatchingGroup(s.gufufilter,tp,LOCATION_ONFIELD,0,nil,tp,e:GetHandler())
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local sg=rg:SelectSubGroup(tp,s.hspchk,true,2,2,tp,e:GetHandler())
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else
        return false
    end
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local g=e:GetLabelObject()
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end

-- ①效果：特召时发动场地魔法
function s.fieldfilter(c,tp)
    return c:IsSetCard(0x8d) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
    if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1) end
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fieldfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.ResetFlagEffect(tp,id)
    local tc=g:GetFirst()
    if tc then
        local te=tc:GetActivateEffect()
        if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1) end
        local b2=te:IsActivatable(tp,true,true)
        Duel.ResetFlagEffect(tp,id)
        if b2 then
            local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
            if fc then
                Duel.SendtoGrave(fc,REASON_RULE)
                Duel.BreakEffect()
            end
            Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
            te:UseCountLimit(tp,1,true)
            local tep=tc:GetControler()
            local cost=te:GetCost()
            if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
            Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
        end
    end
end

-- ②效果：特召鬼计怪兽（表侧攻击或里侧守备），这张卡变里侧
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x8d) and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0 then
        local tc=g:GetFirst()
        if tc:IsFacedown() then
            Duel.ConfirmCards(1-tp,tc)
        end
        Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
    end
end

-- ③效果：反转时其他怪兽变表示形式
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
    local tc=g:GetFirst()
    while tc do
        if tc:IsFaceup() then
            Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        else
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
        end
        tc=g:GetNext()
    end
end