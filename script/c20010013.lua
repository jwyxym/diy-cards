--
function c20010013.initial_effect(c)
	c:SetSPSummonOnce(20010013)
	c:SetUniqueOnField(1,0,20010013)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,12,3,nil,nil,99)
	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20010013.lvtg)
	e1:SetValue(c20010013.lvval)
	c:RegisterEffect(e1)
	--spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.xyzlimit)
	c:RegisterEffect(e2)
	--maintain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetDescription(aux.Stringid(20010013,5))
	e3:SetCountLimit(1)
	e3:SetCondition(c20010013.mtcon)
	e3:SetOperation(c20010013.mtop)
	c:RegisterEffect(e3)
	--cannot direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
	--negate
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetDescription(aux.Stringid(20010013,2))
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,20010013)
	e6:SetCondition(c20010013.discon)
	e6:SetCost(c20010013.discost)
	e6:SetTarget(c20010013.distg)
	e6:SetOperation(c20010013.disop)
	c:RegisterEffect(e6)
end
function c20010013.lvtg(e,c)
	return c:IsLevelAbove(1) and c:IsSetCard(0xb33)
end
function c20010013.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 12
	else return lv end
end
function c20010013.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010013.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010013.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010013.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010013,0),aux.Stringid(20010013,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010013,1))+1
	end
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,cg)
		Duel.ShuffleHand(tp)
	else
		Duel.Destroy(c,REASON_COST)
	end
end
function c20010013.discon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP)) and Duel.IsChainNegatable(ev) and rp==1-tp
end
function c20010013.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c20010013.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c20010013.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end