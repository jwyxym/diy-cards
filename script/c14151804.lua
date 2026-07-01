--加拉尔号角
local s,id=GetID()

function s.initial_effect(c)
    --①效果：发动时检索极星怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    --②效果：从墓地发动，无效并破坏
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end

--①效果的目标：极星怪兽
function s.thfilter(c)
    return c:IsSetCard(0x42) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--①效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --检索极星怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    --【关键】参照光封：发动时注册计数效果
    c:SetTurnCounter(0)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetCountLimit(1)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.descon)
    e3:SetOperation(s.desop)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
    c:RegisterEffect(e3)
    c:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,3)
end

--②效果条件：自己场上或墓地有极神(0x4b)或幻神兽族(RACE_DIVINE)
function s.filter(c)
    return (c:IsSetCard(0x4b) or c:IsRace(RACE_DIVINE))
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then
        return false
    end
    if ep==tp then return false end
    return Duel.IsChainDisablable(ev)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    if eg:GetFirst():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        --【关键】盖放回场时重新注册计数效果（重置计数）
        c:SetTurnCounter(0)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e3:SetCountLimit(1)
        e3:SetRange(LOCATION_SZONE)
        e3:SetCondition(s.descon)
        e3:SetOperation(s.desop)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
        c:RegisterEffect(e3)
        c:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,3)
        if Duel.NegateActivation(ev) then
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end
end

--③效果条件：自己的准备阶段，且这张卡在魔法陷阱区
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp and c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
end

--③效果处理：增加计数，满3次触发伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_SZONE) then return end
    
    local ct=c:GetTurnCounter()
    ct=ct+1
    c:SetTurnCounter(ct)
    
    if ct==3 then
        -- 计算自己场上全部怪兽攻击力合计
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
        local sum=0
        local tc=g:GetFirst()
        while tc do
            sum=sum+tc:GetAttack()
            tc=g:GetNext()
        end
        -- 除外自己的全部怪兽和这张卡
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        -- 给予伤害
        if sum>0 then
            Duel.Damage(1-tp,sum,REASON_EFFECT)
        end
        -- 清除标记
        c:ResetFlagEffect(1082946)
    end
end