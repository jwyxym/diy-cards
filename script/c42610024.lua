--黄金拼图 爱丽丝.卡塔雷特
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
	c:EnableReviveLimit()
    --splimit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cm.regcon)
	e1:SetOperation(cm.regop)
	c:RegisterEffect(e1)
    --remove
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m)
    e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
end

function cm.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g,ph=Duel.GetFieldGroup(tp,LOCATION_MZONE,0),Duel.GetCurrentPhase()
	return #g==1 and g:GetFirst():IsType(0x48020d0) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
	if chk==0 then return tc:IsType(0x40020d0) or (tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=1 then return false end
    local c=e:GetHandler()
    local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
    if tc:IsType(TYPE_NORMAL) then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(m,0))
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EFFECT_IMMUNE_EFFECT)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e3:SetValue(cm.efilter)
        tc:RegisterEffect(e3)
    end
    if tc:IsType(TYPE_FUSION) then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(m,1))
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EFFECT_CANNOT_REMOVE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
    if tc:IsType(TYPE_RITUAL) then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(m,2))
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
    if tc:IsType(TYPE_SYNCHRO) then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(m,3))
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
    if tc:IsType(TYPE_XYZ) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            Duel.HintSelection(g)
            if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e1:SetCode(EVENT_PHASE+PHASE_END)
                e1:SetReset(RESET_PHASE+PHASE_END)
                e1:SetLabelObject(tc)
                e1:SetCountLimit(1)
                e1:SetOperation(cm.retop)
                Duel.RegisterEffect(e1,tp)
            end
        end
    end
    if tc:IsType(TYPE_LINK) then
        Duel.Recover(tp,1000,REASON_EFFECT)
    end
end

function cm.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_RETURN+REASON_TEMPORARY)
end