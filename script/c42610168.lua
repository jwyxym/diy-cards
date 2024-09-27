--为美好世界献上祝福! 惠惠
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700141)
    --link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --leave
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(cm.recon)
	e2:SetValue(LOCATION_DECK)
	c:RegisterEffect(e2)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER) and g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_FIRE)
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

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0x0c,0x0c,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0x0c,0x0c,1,1,nil)
	Duel.HintSelection(g)
    local tc=g:GetFirst()
    e:SetLabel(tc:GetControler(),tc:GetLocation(),tc:GetSequence())
    local dg=tc:GetCrossFieldCard(tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local cp,loc,seq=e:GetLabel()
    local rg=Duel.GetCrossFieldCard(tp,cp,loc,seq)
    if #rg>0 then
        Duel.Destroy(rg,REASON_EFFECT)
    end
    local c=e:GetHandler()
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end

function cm.conrfilter(c)
    return not c:IsCode(m)
end

function cm.recon(e)
	return Duel.IsExistingMatchingCard(cm.conrfilter,e:GetHandlerPlayer(),0x04,0,1,nil)
end