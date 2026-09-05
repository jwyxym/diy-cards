--书仙激愤
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,45205409)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	--手卡发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

function s.costfilter(c)
	return c:IsCode(45205409) and not c:IsPublic()
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.costfilter,e:GetHandlerPlayer(),LOCATION_DECK+LOCATION_HAND,0,1,nil)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		Duel.ConfirmCards(tp,tc)
		Duel.ShuffleDeck(tp)
	else
		Duel.ConfirmCards(1-tp,tc)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.shujofilter(c)
	return c:IsFaceup() and c:IsCode(45205409)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local has_shujo=Duel.IsExistingMatchingCard(s.shujofilter,tp,LOCATION_MZONE,0,1,nil)
	
	--效果1：对方魔陷送墓时给500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.dmgcon1)
	e1:SetOperation(s.dmgop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
	--效果2：有淑女时，对方召唤·特召给500
	if has_shujo then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(s.dmgcon2)
		e2:SetOperation(s.dmgop2)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetCondition(s.dmgcon2)
		e3:SetOperation(s.dmgop2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end

function s.dmgcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
		and eg:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP)
end

function s.dmgop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end

function s.dmgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.dmgop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end

return s
