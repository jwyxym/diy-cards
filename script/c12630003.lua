--闪耀群星·依零一式
--脚本作者：AI

local s,id=GetID()
function s.initial_effect(c)
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end

function s.rmfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp)
            and chkc:IsType(TYPE_SPELL+TYPE_TRAP)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
            Duel.Recover(1-tp,1000,REASON_EFFECT)
        end
    end
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.lvfilter(c)
    -- 必须是有效果的怪兽，且必须有等级（排除超量·连接怪兽）
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(0)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
            and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) and chkc:IsLevelAbove(0)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end

    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    local val=1
    if opt==1 then
        val=-1
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end
