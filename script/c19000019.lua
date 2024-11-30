--金焰巨龙
function c19000019.initial_effect(c)
	c:SetUniqueOnField(1,0,19000019)
	--link summon
	aux.AddLinkProcedure(c,c19000019.mfilter,3)
	c:EnableReviveLimit()
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetDescription(aux.Stringid(19000019,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19000019)
	e1:SetCondition(c19000019.descon)
	e1:SetTarget(c19000019.destg)
	e1:SetOperation(c19000019.desop)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000019,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+19000019)
	e2:SetCountLimit(1,19000019+100)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19000019.condition)
	e2:SetTarget(c19000019.target)
	e2:SetOperation(c19000019.operation)
	c:RegisterEffect(e2)
	if not c19000019.global_check then
		c19000019.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c19000019.regcon)
		ge1:SetOperation(c19000019.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c19000019.mfilter(c)
	return c:IsLevelAbove(4) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
function c19000019.cfilter(c,tp)
	return c:IsPreviousControler(tp) and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:GetOriginalAttribute()==ATTRIBUTE_FIRE and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c19000019.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19000019.cfilter,1,nil,tp)
end
function c19000019.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c19000019.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c19000019.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and not c:IsCode(19000019)
end
function c19000019.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c19000019.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c19000019.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function c19000019.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+19000019,re,r,rp,ep,e:GetLabel())
end
function c19000019.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
function c19000019.filter(c)
	return (c:IsRace(RACE_DRAGON) and c:IsLevelAbove(4) and c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToHand()
end
function c19000019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000019.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19000019.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000019.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end