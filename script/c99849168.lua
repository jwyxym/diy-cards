--削魂的死灵灵域
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,23205979,85684223)  
	
 
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)

	c:RegisterEffect(e0)
	
  
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)   
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_SZONE,0)
	e2:SetTarget(s.immutetg)
	e2:SetCondition(s.immunecon)
	e2:SetValue(s.immuneval)
	c:RegisterEffect(e2)
	

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_FZONE,0)
	e3:SetTarget(s.indetg)
	e3:SetValue(1)
	e3:SetCondition(s.indcon)   
	c:RegisterEffect(e3)
	

	-- ②
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e4:SetTarget(s.sumlimit)
	e4:SetDescription(aux.Stringid(id,1))
	c:RegisterEffect(e4)
end


function s.thfilter(c)
	return (c:IsCode(23205979) or aux.IsCodeListed(c,23205979)) and c:IsAbleToHand()
end


function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end


function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.immunecon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end


function s.immutetg(e,c)
	if c:GetControler()~=e:GetHandlerPlayer() then return false end
	if c:IsCode(23205979) then return true end
	if c:IsType(TYPE_SPELL) and aux.IsCodeListed(c,23205979) then return true end
	return false
end


function s.immuneval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,85684223)
end


function s.indetg(e,c)
	return c==e:GetHandler()
end

-- ========== ② ==========

function s.sumlimit(e,c)
	return c:IsCode(23205979)
end