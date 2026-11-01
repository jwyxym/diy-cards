-- Requiem for Fate
-- ID: 44821017
-- 永续陷阱
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- 卡的发动（卡名1回合只能发动1张）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e0)

    -- ① 自己场上只能有1张表侧表示存在
    c:SetUniqueOnField(1,0,id)

    -- ② 对方把魔法卡发动时，把这张卡以外的自己场上1张表侧永续魔陷送去墓地，无效那个发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_F)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- ③-1 被记述「Roselia」的卡效果送去墓地时，记录回合数并设置 Flag
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)

    -- ③-2 下个回合的准备阶段，将此卡表侧放置
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetCountLimit(1)
    e3:SetCondition(s.setcon)
    e3:SetOperation(s.setop)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
end

-- ② 条件：对方发动魔法卡，且该连锁可被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not re:IsActiveType(TYPE_SPELL) then return false end
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
    return Duel.IsChainNegatable(ev)
end

-- ② cost：把这张卡以外的自己场上1张表侧永续魔法·永续陷阱送去墓地
function s.costfilter(c,e)
    return c~=e:GetHandler() and c:IsFaceup()
        and c:IsType(TYPE_CONTINUOUS)
        and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
        and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
    Duel.SendtoGrave(g,REASON_COST)
end

-- ② 目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- ② 操作：无效魔法卡的发动
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end

-- ③-1 记录回合数并设置 Flag
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_GRAVE) then return end
    if not re then return end
    local rc=re:GetHandler()
    if not (rc and aux.IsCodeListed(rc,44821000)) then return end
    e:SetLabel(Duel.GetTurnCount())
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end

-- ③-2 条件：在墓地、有 Flag、且已过了至少一个回合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_GRAVE) then return false end
    if c:GetFlagEffect(id)==0 then return false end
    return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount()
end

-- ③-2 操作：将卡从墓地以表侧表示放置到魔法与陷阱区域
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end