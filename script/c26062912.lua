-- 为什么要演奏春日影？！ 长崎爽世
-- ID: 26062912
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述，使其可以被「春日影」检索

    -- ① 场地魔法卡发动成功后，从手卡另开连锁特召，并视情况破坏双方场地
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 双方回合，除外墓地「春日影」，攻击力上升800，获得双倍穿防，结束阶段送墓
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end

-- ① 条件：解决的那条连锁是场地魔法卡的发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

-- ① 目标：特召自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,26062911) then
            local dg=Group.CreateGroup()
            local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
            if fc then dg:AddCard(fc) end
            fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
            if fc then dg:AddCard(fc) end
            if #dg>0 then
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end

-- ② 目标：自己或对方墓地的1张「春日影」(26062911)
function s.rmfilter(c)
    return c:IsCode(26062911) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rmfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

-- ② 操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
        -- 攻击力上升800
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(800)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        -- 双倍穿防
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_PIERCE)
        e2:SetValue(DOUBLE_DAMAGE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
        -- 结束阶段送墓
        local fid=c:GetFieldID()
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_PHASE+PHASE_END)
        e4:SetCountLimit(1)
        e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e4:SetLabel(fid)
        e4:SetLabelObject(c)
        e4:SetCondition(s.sendcon)
        e4:SetOperation(s.sendop)
        Duel.RegisterEffect(e4,tp)
    end
end

-- 结束阶段送墓条件
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
        e:Reset()
        return false
    end
    return true
end

-- 结束阶段送墓操作
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end