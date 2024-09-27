--为美好世界献上祝福! 维兹
local cm,m=GetID()

function cm.initial_effect(c)
    aux.AddCodeList(c,10700141)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,2)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --tograve
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.spcon)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
    --tograve
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,m+1)
    e2:SetCondition(cm.discon)
	e2:SetTarget(cm.distg)
	e2:SetOperation(cm.disop)
	c:RegisterEffect(e2)
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

function cm.consfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(0x04) and c:GetReasonPlayer()==1-tp
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.consfilter,1,nil,tp)
end

function cm.tgsfilter(c)
    return c:IsAbleToGrave() and c:IsRace(RACE_ZOMBIE)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgsfilter,tp,0x01,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,0x01)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,cm.tgsfilter,tp,0x01,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT) then
        local c=e:GetHandler()
        if c:IsRelateToChain() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(3000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            c:RegisterEffect(e1)
        end
    end
end

function cm.condfilter(c)
    return c:IsFaceup() and c:IsSummonLocation(LOCATION_GRAVE) and c:IsRace(RACE_ZOMBIE)
end

function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.condfilter,1,nil)
end

function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,0x0c)>0 end
end

function cm.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,0x0c,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if tc:IsFacedown() then
            Duel.ConfirmCards(tp,tc)
        end
        Duel.HintSelection(g)
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetLabel(tc:GetCode())
        e1:SetValue(cm.aclimit)
		Duel.RegisterEffect(e1,tp)
        local ng=Duel.GetMatchingGroup(Card.IsCode,tp,0xff,0xff,nil,tc:GetCode())
        for nc in aux.Next(ng) do
            nc:RegisterFlagEffect(m,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,0))
        end
    end
end

function cm.aclimit(e,re,tp)
    local rc=re:GetHandler()
	return rc:IsCode(e:GetLabel()) and not rc:IsLocation(0x10)
end