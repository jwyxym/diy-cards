-- 命运女郎的剧场
local s,id,o=GetID()
function s.initial_effect(c)
  
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x31))
	e2:SetDescription(aux.Stringid(id,7))  
	c:RegisterEffect(e2)
	
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.syncop)
	c:RegisterEffect(e3)
end


function s.thfilter(c)
	return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end  
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end


function s.syncop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsLocation(LOCATION_FZONE) then return end
	
	local tc=eg:GetFirst()
	while tc do
	   
		if tc:IsType(TYPE_SYNCHRO) and tc:IsFaceup() and tc:IsControler(tp) then
		   
			local mat_group=tc:GetMaterial()
			if mat_group and mat_group:GetCount()>0 then
				local att=0
				local mat=mat_group:GetFirst()
				while mat do
				 
					if mat:IsSetCard(0x31) then
						att=bit.bor(att,mat:GetOriginalAttribute())
					end
					mat=mat_group:GetNext()
				end
				
		   
				if att~=0 then
					s.register_effect(tc,att)
				end
			end
		end
		tc=eg:GetNext()
	end
end


function s.register_effect(c,att)
  
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	

	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	
 
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,3))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
	

	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,4))
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(s.immfilter_trap)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	end
	

	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,5))
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_UPDATE_ATTACK)
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e5:SetRange(LOCATION_MZONE)
		e5:SetValue(1000)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e5)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e6)
	end
	

	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(aux.Stringid(id,6))
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetCode(EFFECT_IMMUNE_EFFECT)
		e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e7:SetRange(LOCATION_MZONE)
		e7:SetValue(s.immfilter_spell)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e7)
	end
end


function s.immfilter_trap(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end


function s.immfilter_spell(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end