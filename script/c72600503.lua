--胸部之谷 热情迷唇
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_REMOVED+LOCATION_MZONE+LOCATION_GRAVE,0,aux.tdcfop(c))
	--sp
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--limit summons
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.lscon)
	e1:SetOperation(s.lsop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(s.batkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.eatkop)
	c:RegisterEffect(e3)
	--immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.immval)
	c:RegisterEffect(e4)
	--destory
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCost(s.descost)
	e5:SetCondition(s.descon)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(2,id)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCost(s.descost1)
	e6:SetCondition(s.descon1)
	c:RegisterEffect(e6)
end
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.batkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local upatk=bc:GetBaseAttack()
	if bc:GetBaseAttack()<bc:GetBaseDefense() then upatk=bc:GetBaseDefense() end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re and re:GetOwner()==e:GetHandler()
		and eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function s.eatkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_MONSTER)
	local c=e:GetHandler()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		if tc:GetTextAttack()>0 then
			atk=atk+tc:GetTextAttack()
		end
		tc=g:GetNext()
	end
	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.immval(e,te)
	return te:GetOwner()~=e:GetOwner() and te:IsActiveType(TYPE_MONSTER) and te:GetOwner():GetAttack()>=e:GetHandler():GetAttack()
end
--destory
function s.exfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not (Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE,0,1,c) and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN))
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
function s.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.costfilter1(c)
	return c:IsAbleToRemove()
end
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not (Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE,0,1,c) and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN))
	and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
