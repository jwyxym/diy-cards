local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,99,s.matcheck)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.avoidtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x74b)
end
function s.matcheck(g)
	return g:FilterCount(s.matfilter,nil)>=1
end
function s.avoidtg(e,c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x74b)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 then
		local atk=rc:GetBaseAttack()
		if atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
