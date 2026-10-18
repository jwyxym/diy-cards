-- 伦敦精神病人
-- ID: 15040021
-- 「千早爱音」字段：0xb12
local RACE_ILLUSION = RACE_ILLUSION or 0x2000000
local s,id=GetID()
function s.initial_effect(c)
    -- Link召唤限制：包含「千早爱音」怪兽的怪兽2只
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c, nil, 2, 2, s.lcheck)

    -- ① 场上只能有1张表侧表示存在
    c:SetUniqueOnField(1,0,id)

    -- ② 对方回合1次，支付500基本分，从卡组除外1只6星以下光属性怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.con2)
    e1:SetCost(s.cost2)
    e1:SetTarget(s.tg2)
    e1:SetOperation(s.op2)
    c:RegisterEffect(e1)

    -- ③ 自己战斗阶段，除外区有3只以上种族不同的怪兽时，ATK+3000（1回合1次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+1)            -- 新增：1回合1次
    e2:SetCondition(s.con3)
    e2:SetOperation(s.op3)
    c:RegisterEffect(e2)
end

-- Link素材检查：至少包含1只「千早爱音」怪兽
function s.lcheck(g)
    local tc=g:GetFirst()
    while tc do
        if tc:IsSetCard(0xb12) then return true end
        tc=g:GetNext()
    end
    return false
end

-- ② 条件：对方回合
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end

-- ② cost：支付500基本分
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

-- ② 目标：卡组存在6星以下光属性怪兽
function s.rmfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(6) and c:IsAbleToRemove()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end

-- 注册"同名卡不能发动/召唤"的限制（整场决斗）
function s.register_ban(c,tp)
    if Duel.GetFlagEffect(tp,id)==0 then
        Duel.RegisterFlagEffect(tp,id,0,0,1)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(s.actlimit)
        Duel.RegisterEffect(e1,tp)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_SUMMON)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(1,0)
        e2:SetTarget(s.sumlimit)
        Duel.RegisterEffect(e2,tp)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(1,0)
        e3:SetTarget(s.sumlimit)
        Duel.RegisterEffect(e3,tp)
    end
end
function s.actlimit(e,re,tp)
    local rc=re:GetHandler()
    if rc and rc:IsType(TYPE_MONSTER) then
        return Duel.GetFlagEffect(tp, id+rc:GetCode())>0
    end
    return false
end
function s.sumlimit(e,c)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(), id+c:GetCode())>0
end

-- ② 操作
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLP(tp)<=500 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
    local code=tc:GetCode()
    local race=tc:GetRace()
    Duel.RegisterFlagEffect(tp, id+code, 0, 0, 1)
    s.register_ban(c, tp)

    if race==RACE_WINDBEAST then
        if Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
            local sg=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
            Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
        end
    elseif race==RACE_WARRIOR then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_PIERCE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb12))
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
    elseif race==RACE_SPELLCASTER then
        if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #sg>0 then Duel.Destroy(sg,REASON_EFFECT) end
        end
    elseif race==RACE_PLANT then
        local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        if #hg>0 then
            Duel.ConfirmCards(1-tp,hg)
            if #hg>=2 then
                Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
                local rg=hg:Select(1-tp,2,2,nil)
                Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
            else
                Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)
            end
        end
        local ohg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
        if #ohg>0 then
            local dtc=ohg:RandomSelect(1-tp,1):GetFirst()
            Duel.SendtoGrave(dtc,REASON_EFFECT)
        end
    elseif race==RACE_FIEND then
        local ffilter=function(fc) return fc:IsSetCard(0xb12) and fc:IsAbleToHand() end
        if Duel.IsExistingMatchingCard(ffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=Duel.SelectMatchingCard(tp,ffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    elseif race==RACE_BEASTWARRIOR then
        local sf=function(sc) return sc:IsType(TYPE_SPELL+TYPE_TRAP) and sc:IsFaceup() end
        if Duel.IsExistingMatchingCard(sf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=Duel.SelectMatchingCard(tp,sf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #sg>0 then Duel.Destroy(sg,REASON_EFFECT) end
        end
    elseif race==RACE_CYBERSE then
        local hf=function(hc) return hc:IsSetCard(0xb12) and hc:IsAbleToRemove() end
        if Duel.IsExistingMatchingCard(hf,tp,LOCATION_HAND,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=Duel.SelectMatchingCard(tp,hf,tp,LOCATION_HAND,0,1,1,nil)
            if #sg>0 then
                Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
                Duel.BreakEffect()
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    elseif race==RACE_ILLUSION then
        if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
            if #sg>0 then Duel.Remove(sg,POS_FACEUP,REASON_EFFECT) end
        end
    elseif race==RACE_FAIRY then
        if c:IsRelateToEffect(e) then
            Duel.Destroy(c,REASON_EFFECT)
        end
        local bg=Duel.GetMatchingGroup(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
        if #bg>0 then
            Duel.SendtoDeck(bg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    else
        Duel.Damage(1-tp,500,REASON_EFFECT)
    end
end

-- ③ 条件：自己战斗阶段，自己除外区有3只以上种族不同的怪兽
function s.con3(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    local ph=Duel.GetCurrentPhase()
    if ph<PHASE_BATTLE_START or ph>PHASE_BATTLE then return false end
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_REMOVED,0,nil,TYPE_MONSTER)
    local races={}
    local cnt=0
    local tc=g:GetFirst()
    while tc do
        local r=tc:GetRace()
        if not races[r] then
            races[r]=true
            cnt=cnt+1
        end
        tc=g:GetNext()
    end
    return cnt>=3
end
-- ③ 操作：ATK+3000
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(3000)
        c:RegisterEffect(e1)
    end
end