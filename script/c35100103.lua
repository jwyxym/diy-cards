--异质绝望 狂宴
local m=35100103
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e11=Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_COUNTER+CATEGORY_ATKCHANGE)
	e11:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e11:SetRange(LOCATION_SZONE)
	e11:SetCode(EVENT_SUMMON_SUCCESS)
	e11:SetCondition(cm.damcon)
	e11:SetOperation(cm.disop)
	c:RegisterEffect(e11)
	local e12=e11:Clone()
	e12:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e12)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.atkcon)
	e3:SetTarget(cm.atktg)
	e3:SetOperation(cm.atkop)
	c:RegisterEffect(e3)
end
function cm.ctfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.ctfilter,1,nil,1-tp)
end
function cm.filter(c)
	return c:IsFaceup()
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,m)
	c:AddCounter(0x1a90,1)
	local g=Duel.GetMatchingGroup(cm.filter,1-tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		if atk>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-500)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetAttack()==0 then
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end
		tc=g:GetNext()
	end
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1a90)>0 and Duel.GetTurnPlayer()~=tp
end
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ct=c:GetCounter(0x1a90)
	if ct>0 then
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end