--幼女战记 维多利亚·伊万诺夫娜·谢列布里亚科娃
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700108)
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
    --atk record
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CUSTOM+10700111)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cm.ad1op)
	c:RegisterEffect(e2)
	--atk check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(cm.ad2op)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
    local e10=e3:Clone()
    e10:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e10)
    --destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CUSTOM+10700112)
    e4:SetCountLimit(1,m)
	e4:SetTarget(cm.target)
	e4:SetOperation(cm.operation)
	c:RegisterEffect(e4)
    --destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,m+1)
	e1:SetCondition(cm.descon)
	e1:SetTarget(cm.destg)
	e1:SetOperation(cm.desop)
	c:RegisterEffect(e1)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_FIEND) or c:IsLinkAttribute(ATTRIBUTE_FIRE)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil)
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

function cm.ad1op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0x04,0,nil)
    for tc in aux.Next(g) do
        tc:ResetFlagEffect(10700113)
        tc:RegisterFlagEffect(10700113,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL,0,1,tc:GetAttack())
    end
	e:GetHandler():RegisterFlagEffect(10700112,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL,0,1)
end

function cm.ad2op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:GetFlagEffect(10700112)==0 then
		Duel.RaiseEvent(c,EVENT_CUSTOM+10700111,e,0,0,0,0)
	end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0x04,0,nil)
    for tc in aux.Next(g) do
		if tc:GetFlagEffect(10700113)~=0 and tc:GetAttack()==0 and tc:GetFlagEffectLabel(10700113)~=0 then
			Duel.RaiseEvent(c,EVENT_CUSTOM+10700112,e,0,0,0,0)
		end
    end
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+10700111,e,0,0,0,0)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,0x04,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,0x04)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,0x04,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDisabled()
end

function cm.tgdfilter(c,e)
    return c:IsType(TYPE_LINK) and c:IsCanBeEffectTarget(e)
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=e:GetHandler():GetLinkedGroup()
    if chkc then return g:IsContains(chkc) and chkc:IsType(TYPE_LINK) end
	if chk==0 then return g:IsExists(cm.tgdfilter,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	g=g:FilterSelect(tp,cm.tgdfilter,1,1,nil,e)
    Duel.SetTargetCard(g)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
    end
end
